import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';

const leaf = type => ({kind: 'primitive', type});
const fixture = () => ({
  identity: {slug: 'fixture'},
  contracts: [{name: 'Fixture', kind: 'interface', description: 'The fixture mark.', wire: true, extends: [], properties: [{name: 'mark', required: true, description: 'A fixture mark.', type: 'fixtureLiteral'}]}],
  typeExpressions: {fixtureLiteral: {kind: 'literal', value: 'fixture'}},
  declarationFiles: [{basename: 'Fixture', imports: [], contracts: ['Fixture']}],
  marks: [{name: 'fixture', contract: 'Fixture', jsSection: 'fixture-1', profile: 'ordinary'}],
  referenceGroups: [{title: 'Fixture', names: ['fixture'], sections: {js: 'js-Fixture', python: 'python-Fixture'}}]
});
function project(input, expression = '{fileData:files,schemaData:schemaFragment,nativeData:nativeDefinitions,referenceData:sections}') {
  const directory = mkdtempSync(join(tmpdir(), 'mosaic-mark-family-'));
  try {
    const path = join(directory, 'input.json');
    writeFileSync(path, JSON.stringify(input));
    return spawnSync(process.env.CUE_BIN, ['export', './api/marks/render', path, '-d', '#MarkFamilyProjection', '-e', expression], {encoding: 'utf8', maxBuffer: 8 * 1024 * 1024});
  } finally {
    rmSync(directory, {recursive: true, force: true});
  }
}

test('mark families own exported alias declarations, schema and native definitions together', () => {
  const input = fixture();
  input.supportContracts = [{name: 'FixtureShape', kind: 'alias', description: 'Allowed fixture shapes.', wire: true, expression: 'shape'}];
  input.typeExpressions.shape = {kind: 'enum', values: ['arrow', 'spike']};
  input.declarationFiles[0].contracts.push('FixtureShape');
  const result = project(input);
  assert.equal(result.status, 0, result.stderr);
  const output = JSON.parse(result.stdout);
  assert.deepEqual(output.schemaData.definitions.FixtureShape, {description: 'Allowed fixture shapes.', enum: ['arrow', 'spike'], type: 'string'});
  assert.match(output.fileData['packages/vgplot/spec/src/spec/marks/Fixture.ts'], /export type FixtureShape = 'arrow' \| 'spike'/);
  assert.match(output.nativeData.FixtureShape, /arrow.*spike/);
  for (const mutate of [
    value => value.declarationFiles[0].contracts.pop(),
    value => {value.supportContracts[0] = {...value.contracts[0], name: 'FixtureShape'};},
    value => {value.supportContracts[0].expression = 'missing';},
    value => {value.marks[0].contract = 'FixtureShape';}
  ]) {
    const invalid = structuredClone(input);
    mutate(invalid);
    assert.equal(project(invalid, '{}').status, 1);
  }
});

test('mark families inherit actual cross-family contracts and check their import provenance', () => {
  const input = fixture();
  input.baseContracts = [{name: 'Base', kind: 'interface', description: 'The owning base.', wire: false, extends: [], properties: [{name: 'x', description: 'Inherited x.', required: false, type: 'baseNumber'}]}];
  input.baseExpressions = {baseNumber: leaf('number')};
  input.baseImports = [{name: 'Base', owner: 'basic', source: './Base.js'}];
  input.contracts[0].extends = ['Base'];
  input.declarationFiles[0].imports = ['Base'];
  const result = project(input);
  assert.equal(result.status, 0, result.stderr);
  const output = JSON.parse(result.stdout);
  assert.deepEqual(output.schemaData.definitions.Fixture.properties.x, {type: 'number', description: 'Inherited x.'});
  assert.match(output.referenceData.find(record => record.id === 'options-fixture').text, /Extends \[`Base`\]\(#base-options\)/);
  assert.match(output.fileData['packages/vgplot/spec/src/spec/marks/Fixture.ts'], /import \{ Base \} from '.\/Base.js'/);
  assert.match(output.fileData['packages/vgplot/spec/src/spec/marks/Fixture.ts'], /interface Fixture extends Base/);
  for (const mutate of [
    value => {value.baseImports = [];},
    value => {value.baseImports[0].name = 'Foreign';},
    value => {value.baseContracts[0].exported = false;},
    value => {value.baseImports[0].source = './Fixture.js';},
    value => {value.baseExpressions.unused = {kind: 'named', name: 'Missing'};}
  ]) {
    const invalid = structuredClone(input);
    mutate(invalid);
    assert.equal(project(invalid, '{}').status, 1);
  }
});
