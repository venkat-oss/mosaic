import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';

const leaf = (type, kind = 'primitive') => ({kind, [kind === 'literal' ? 'value' : 'type']: type});
const property = (name, type, required = false) => ({name, type, required, description: name + ' prose.'});
const contract = (name, properties) => ({name, kind: 'interface', wire: false, description: name + ' prose.', extends: [], properties});
function fixture() {
  return {
    contracts: [
      contract('Base', [property('mark', 'markLiteral', true), property('value', 'numberValue', true)]),
      contract('LineOptions', [property('type', 'lineLiteral', true), property('curve', 'booleanValue')]),
      contract('DotOptions', [property('type', 'dotLiteral'), property('r', 'numberValue')]),
      {name: 'Example', kind: 'alias', wire: true, description: 'An ordered union.', expression: 'choice'}
    ],
    expressions: {
      markLiteral: leaf('fixture', 'literal'), lineLiteral: leaf('line', 'literal'), dotLiteral: leaf('dot', 'literal'),
      numberValue: leaf('number'), booleanValue: leaf('boolean'),
      choice: {kind: 'interface-union', base: 'Base', alternatives: ['LineOptions', 'DotOptions']}
    }
  };
}
function project(input, expression = 'contractProjections.Example') {
  const directory = mkdtempSync(join(tmpdir(), 'mosaic-interface-union-'));
  try {
    const path = join(directory, 'input.json');
    writeFileSync(path, JSON.stringify(input));
    const args = ['./api/render', path, '-d', '#ShapeProjection'];
    const admitted = spawnSync(process.env.CUE_BIN, ['vet', '-c', ...args], {encoding: 'utf8'});
    if (admitted.status) return admitted;
    return spawnSync(process.env.CUE_BIN, ['export', ...args, '-e', expression], {encoding: 'utf8'});
  } finally {
    rmSync(directory, {recursive: true, force: true});
  }
}

test('interface unions preserve source structure, ordered branches, prose and requiredness', () => {
  const result = project(fixture());
  assert.equal(result.status, 0, result.stderr);
  const output = JSON.parse(result.stdout);
  assert.equal(output.typescript, 'Base & (LineOptions | DotOptions)');
  assert.equal(output.schema.anyOf.length, 2);
  assert.deepEqual(output.schema.anyOf.map(branch => branch.properties.type.const), ['line', 'dot']);
  assert.deepEqual(output.schema.anyOf.map(branch => branch.required), [['mark', 'value', 'type'], ['mark', 'value']]);
  assert.ok(output.schema.anyOf.every(branch => branch.additionalProperties === false));
  assert.equal(output.schema.anyOf[0].properties.curve.description, 'curve prose.');
  assert.equal(output.schema.anyOf[1].properties.r.description, 'r prose.');
  assert.deepEqual(output.propertyBranches.map(branch => branch.map(value => value.name)), [['mark', 'value', 'type', 'curve'], ['mark', 'value', 'type', 'r']]);
  const directory = mkdtempSync(join(tmpdir(), 'mosaic-interface-union-native-'));
  try {
    const definitions = join(directory, 'native.cue');
    const input = join(directory, 'input.json');
    writeFileSync(definitions, 'package fixture\n#Example: ' + output.native + '\n');
    for (const [value, expected] of [
      [{mark: 'fixture', value: 2, type: 'line', curve: true}, true],
      [{mark: 'fixture', value: 2, type: 'dot', r: 3}, true],
      [{mark: 'fixture', value: 2}, true],
      [{mark: 'fixture', value: 2, type: 'line', r: 3}, false],
      [{mark: 'fixture', value: 2, type: 'dot', curve: true}, false],
      [{mark: 'fixture', value: 2, type: 'area'}, false],
      [{mark: 'fixture', type: 'line'}, false]
    ]) {
      writeFileSync(input, JSON.stringify(value));
      const native = spawnSync(process.env.CUE_BIN, ['vet', '-c', definitions, input, '-d', '#Example'], {encoding: 'utf8'});
      assert.equal(native.status === 0, expected, JSON.stringify(value) + ': ' + native.stderr);
    }
  } finally {
    rmSync(directory, {recursive: true, force: true});
  }
});

test('complete interface union admission rejects invalid used and unused source relationships', () => {
  for (const mutate of [
    input => {input.expressions.choice.base = 'Missing';},
    input => {input.expressions.choice.alternatives = ['LineOptions', 'Missing'];},
    input => {input.expressions.choice.alternatives = ['LineOptions', 'LineOptions'];},
    input => {input.expressions.choice.base = 'Example';},
    input => {input.contracts[1].properties[0].required = false;},
    input => {input.expressions.choice.nativeAdapter = 'permissive';},
    input => {input.contracts[1].properties.push(property('value', 'booleanValue', true));},
    input => {input.expressions.unused = {...input.expressions.choice, base: 'Missing'};},
    input => {input.expressions.unused = {...input.expressions.choice, source: 'execute()'};}
  ]) {
    const input = fixture();
    mutate(input);
    assert.equal(project(input, '{}').status, 1);
  }
});

test('native alias validators preserve required fields under an outer validator', () => {
  const result = project(fixture(), 'admissionDefinitions');
  assert.equal(result.status, 0, result.stderr);
  const definitions = JSON.parse(result.stdout);
  assert.match(definitions.Example, /^matchN\(/);
  const directory = mkdtempSync(join(tmpdir(), 'mosaic-composed-union-native-'));
  try {
    const source = join(directory, 'native.cue');
    const input = join(directory, 'input.json');
    writeFileSync(source, 'package fixture\n' + Object.entries(definitions).map(([name, body]) => '#' + name + ': ' + body).join('\n') + '\n#Root: {item!: matchN(>=1, [#Example])}\n');
    for (const [value, expected] of [
      [{ mark: 'fixture', value: 2, type: 'line' }, true],
      [{ mark: 'fixture', value: 2 }, true],
      [{ mark: 'fixture', type: 'line' }, false],
      [{ mark: 'fixture', value: 2, type: 'line', r: 3 }, false],
      [{ mark: 'fixture', value: 2, type: 'dot', curve: true }, false]
    ]) {
      writeFileSync(input, JSON.stringify({ item: value }));
      const native = spawnSync(process.env.CUE_BIN, ['vet', '-c', source, input, '-d', '#Root'], { encoding: 'utf8' });
      assert.equal(native.status === 0, expected, JSON.stringify(value) + ': ' + native.stderr);
    }
  } finally {
    rmSync(directory, { recursive: true, force: true });
  }
});
