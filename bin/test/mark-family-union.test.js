import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';

const leaf = (value, kind = 'literal') => ({kind, [kind === 'literal' ? 'value' : 'type']: value});
const property = (name, type, required = false) => ({name, type, required, description: name + ' source prose.'});
function fixture() {
  const contracts = [
    {name: 'Base', properties: [property('mark', 'markLiteral', true), property('value', 'numberValue')]},
    {name: 'LineOptions', properties: [property('type', 'lineLiteral', true), property('curve', 'booleanValue')]},
    {name: 'DotOptions', properties: [property('type', 'dotLiteral'), property('r', 'numberValue')]}
  ].map(value => ({...value, description: value.name + ' prose.', wire: false, kind: 'interface', extends: []}));
  const names = [...contracts.map(value => value.name), 'Example'];
  return {
    identity: {slug: 'fixture'}, contracts,
    supportContracts: [{name: 'Example', description: 'The fixture mark.', kind: 'alias', wire: true, expression: 'choice'}],
    typeExpressions: {markLiteral: leaf('fixture'), lineLiteral: leaf('line'), dotLiteral: leaf('dot'), numberValue: leaf('number', 'primitive'), booleanValue: leaf('boolean', 'primitive'), choice: {kind: 'interface-union', base: 'Base', alternatives: ['LineOptions', 'DotOptions']}},
    declarationFiles: [{basename: 'Density', imports: [], contracts: names, ownership: 'sections', sections: names.map((contract, index) => ({contract, id: contract + '-' + index}))}],
    marks: [{name: 'fixture', contract: 'Example', branchKey: 'type', jsSection: 'fixture-1', profile: 'explicit', runtimeClass: 'Density1DMark', runtimeType: 'dot'}],
    referenceGroups: [{title: 'Fixture', names: ['fixture'], sections: {js: 'js-Fixture', python: 'python-Fixture'}}]
  };
}
function project(input, expression = '{fileData:files,sectionData:sections,pythonData:pythonRecords}') {
  const directory = mkdtempSync(join(tmpdir(), 'mosaic-mark-union-'));
  try {
    const path = join(directory, 'input.json');
    writeFileSync(path, JSON.stringify(input));
    const args = ['./api/marks/render', path, '-d', '#MarkFamilyProjection'];
    const admitted = spawnSync(process.env.CUE_BIN, ['vet', '-c', ...args], {encoding: 'utf8'});
    if (admitted.status) return admitted;
    return spawnSync(process.env.CUE_BIN, ['export', ...args, '-e', expression], {encoding: 'utf8', maxBuffer: 16 * 1024 * 1024});
  } finally {
    rmSync(directory, {recursive: true, force: true});
  }
}

test('concrete union marks retain ordered Python channels and single-writer declaration sections', () => {
  const result = project(fixture());
  assert.equal(result.status, 0, result.stderr);
  const {fileData, sectionData, pythonData} = JSON.parse(result.stdout);
  assert.equal(Object.hasOwn(fileData, 'packages/vgplot/spec/src/spec/marks/Density.ts'), false);
  assert.deepEqual(pythonData[0].channels, ['curve', 'type', 'value', 'r']);
  const sections = sectionData.filter(value => value.path.endsWith('/Density.ts'));
  assert.match(sections.find(value => value.id.startsWith('Example-')).text, /type Example = Base & \(LineOptions \| DotOptions\)/);
  assert.match(sectionData.find(value => value.id === 'fixture-1').text, /explicitType\(Density1DMark, 'dot', \.\.\.args\)/);
  const docs = sectionData.find(value => value.id === 'options-fixture').text;
  assert.match(docs, /LineOptions[\s\S]*curve source prose/);
  assert.match(docs, /DotOptions[\s\S]*r source prose/);
});

test('union mark and declaration ownership reject incomplete or ambiguous used records before output', () => {
  for (const mutate of [
    input => {delete input.marks[0].branchKey;},
    input => {input.marks[0].runtimeType = 'areaY';},
    input => {input.marks[0].branchKey = 'missing';},
    input => {input.marks[0].branchKey = 'mark';},
    input => {input.typeExpressions.dotLiteral.value = 'line';},
    input => {input.declarationFiles[0].sections.pop();},
    input => {input.declarationFiles[0].sections[1].id = input.declarationFiles[0].sections[0].id;},
    input => {input.declarationFiles[0].ownership = 'file';},
    input => {input.contracts[0].wire = true; input.marks[0].contract = 'Base';},
    input => {input.typeExpressions.choice = {kind: 'enum', values: ['line', 'dot']};}
  ]) {
    const input = fixture();
    mutate(input);
    assert.equal(project(input, '{}').status, 1);
  }
});
