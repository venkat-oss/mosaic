import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';

const cue = process.env.CUE_BIN;
const leaf = (type, kind = 'primitive') => ({ kind, [kind === 'named' ? 'name' : 'type']: type });
const alias = (name, expression, fields = {}) => ({ name, expression, kind: 'alias', description: 'An independent contract.', wire: true, ...fields });

function project(input, expression = 'contractProjections.Example') {
  const directory = mkdtempSync(join(tmpdir(), 'mosaic-shape-render-'));
  try {
    const path = join(directory, 'input.json');
    writeFileSync(path, JSON.stringify(input));
    execFileSync(cue, ['vet', '-c', './api/render', path, '-d', '#ShapeProjection'], { stdio: 'pipe' });
    return JSON.parse(execFileSync(cue, ['export', './api/render', path, '-d', '#ShapeProjection', '-e', expression], { encoding: 'utf8', stdio: 'pipe' }));
  } finally {
    rmSync(directory, { recursive: true, force: true });
  }
}

test('shape references require an explicit owned or external target', () => {
  const input = { expressions: { value: leaf('External', 'named') }, contracts: [alias('Example', 'value')], externalReferences: [{ name: 'External', owner: 'spec', source: './Root.js' }] };
  const output = project(input);
  assert.equal(output.typescript, 'External');
  assert.equal(output.native, '#External');
  assert.deepEqual(output.schema, { $ref: '#/definitions/External', description: 'An independent contract.' });
  assert.throws(() => project({ ...input, externalReferences: [] }));
  assert.throws(() => project({ ...input, externalReferences: [{ name: 'Example', owner: 'spec', source: './Root.js' }] }));
  assert.throws(() => project({ ...input, externalReferences: [{ name: 'External', source: './Root.js' }] }));
});

test('open object rows preserve their target object representation', () => {
  const output = project({ expressions: { row: { kind: 'object' } }, contracts: [alias('Example', 'row')] });
  assert.equal(output.typescript, 'object');
  assert.equal(output.native, '{...}');
  assert.deepEqual(output.schema, { type: 'object', description: 'An independent contract.' });
});

test('native required singleton properties require explicit input presence', () => {
  const output = project({ expressions: {
    discriminator: { kind: 'literal', value: 'table' }
  }, contracts: [{ name: 'Example', kind: 'interface', description: 'A table definition.', wire: true, extends: [], properties: [
    { name: 'type', description: 'The data type.', required: true, type: 'discriminator' }
  ] }] });
  const directory = mkdtempSync(join(tmpdir(), 'mosaic-shape-presence-'));
  try {
    const native = join(directory, 'native.cue');
    const candidate = join(directory, 'candidate.json');
    writeFileSync(native, `package admission\n#Example: ${output.native}\n`);
    writeFileSync(candidate, '{"type":"table"}');
    execFileSync(cue, ['vet', '-c', native, candidate, '-d', '#Example'], { stdio: 'pipe' });
    writeFileSync(candidate, '{}');
    assert.throws(() => execFileSync(cue, ['vet', '-c', native, candidate, '-d', '#Example'], { stdio: 'pipe' }));
  } finally {
    rmSync(directory, { recursive: true, force: true });
  }
});

test('file template alternatives retain TypeScript suffixes and collapse the wire primitive list', () => {
  const template = suffix => ({ kind: 'template', parts: [{ primitive: 'string' }, { literal: suffix }], completion: 'plain', schemaAdapter: 'open-string' });
  const output = project({ expressions: {
    csv: template('.csv'), json: template('.json'),
    file: { kind: 'union', members: ['csv', 'json'], schemaAdapter: 'unique-primitive-type-array' }
  }, contracts: [alias('Example', 'file')] });
  assert.equal(output.typescript, '`${string}.csv` | `${string}.json`');
  assert.deepEqual(output.schema, { type: ['string'], description: 'An independent contract.' });
});

test('fixed homogeneous tuples keep their exact bounds and reject heterogeneous metadata', () => {
  const input = { expressions: {
    string: leaf('string'), number: leaf('number'),
    pair: { kind: 'tuple', elements: [{ type: 'string' }, { type: 'string' }] }
  }, contracts: [alias('Example', 'pair')] };
  const output = project(input);
  assert.equal(output.typescript, '[string, string]');
  assert.equal(output.native, '[string, string]');
  assert.deepEqual(output.schema, { type: 'array', minItems: 2, maxItems: 2, items: { type: 'string' }, description: 'An independent contract.' });
  input.expressions.pair.elements[1].type = 'number';
  assert.throws(() => project(input));
});

test('Date host adapters distinguish the date-time wire format from ordinary strings', () => {
  const output = project({ expressions: { date: { kind: 'host', adapter: 'date-time' } }, contracts: [alias('Example', 'date')] });
  assert.equal(output.typescript, 'Date');
  assert.equal(output.native, 'time.Time');
  assert.deepEqual(output.schema, { type: 'string', format: 'date-time', description: 'An independent contract.' });
});

test('generic argument applications flatten scalar unions while preserving singleton tuple items', () => {
  const output = project({ expressions: {
    string: leaf('string'), number: leaf('number'),
    scalar: { kind: 'union', members: ['string', 'number'] },
    argument: { kind: 'application', shape: 'Unary', argument: 'scalar' }
  }, argumentShapes: [{ name: 'Unary', parameter: 'T', description: 'One argument.', scalar: true, nullable: false, tupleSize: 1 }], contracts: [alias('Example', 'argument')] });
  assert.equal(output.typescript, 'Unary<string | number>');
  assert.deepEqual(output.schema, { anyOf: [
    { type: 'string' }, { type: 'number' },
    { type: 'array', minItems: 1, maxItems: 1, items: { anyOf: [{ type: 'string' }, { type: 'number' }] } }
  ], description: 'An independent contract.' });
});

test('reference-only descriptions remain available to docs without changing target annotations', () => {
  const output = project({ expressions: { value: leaf('string') }, contracts: [alias('Example', 'value', { documentationAdapter: 'reference-only' })] });
  assert.deepEqual(output.schema, { type: 'string' });
  assert.equal(output.declaration, 'export type Example = string;\n');
});

test('checked native union defaults select a concrete file branch without filling required discriminators', () => {
  const input = { expressions: {
    path: leaf('string'),
    csvType: { kind: 'literal', value: 'csv' },
    file: leaf('File', 'named'), csv: leaf('CSV', 'named'),
    definition: { kind: 'union', members: ['file', 'csv'], nativeDefault: 'file' }
  }, contracts: [
    { name: 'File', kind: 'interface', description: 'A file.', wire: true, extends: [], properties: [
      { name: 'file', description: 'The path.', required: true, type: 'path' }
    ] },
    { name: 'CSV', kind: 'interface', description: 'A typed CSV file.', wire: true, extends: [], properties: [
      { name: 'type', description: 'The data type.', required: true, type: 'csvType' },
      { name: 'file', description: 'The path.', required: true, type: 'path' }
    ] },
    alias('Example', 'definition')
  ] };
  const output = project(input, 'contractProjections');
  assert.deepEqual(output.Example.schema, { anyOf: [{ $ref: '#/definitions/File' }, { $ref: '#/definitions/CSV' }], description: 'An independent contract.' });
  const directory = mkdtempSync(join(tmpdir(), 'mosaic-shape-union-'));
  try {
    const native = join(directory, 'native.cue');
    const candidate = join(directory, 'candidate.json');
    writeFileSync(native, `package admission\n${Object.entries(output).map(([name, value]) => `#${name}: ${value.native}`).join('\n')}\n`);
    for (const value of [{ file: 'arbitrary' }, { type: 'csv', file: 'data.csv' }]) {
      writeFileSync(candidate, JSON.stringify(value));
      execFileSync(cue, ['vet', '-c', native, candidate, '-d', '#Example'], { stdio: 'pipe' });
    }
    for (const value of [{}, { type: 'csv' }, { type: 'unknown', file: 'data.csv' }, { file: 'data.csv', extra: true }]) {
      writeFileSync(candidate, JSON.stringify(value));
      assert.throws(() => execFileSync(cue, ['vet', '-c', native, candidate, '-d', '#Example'], { stdio: 'pipe' }));
    }
  } finally {
    rmSync(directory, { recursive: true, force: true });
  }
  input.expressions.definition.nativeDefault = 'missing';
  assert.throws(() => project(input));
});

test('inline records preserve closed object structure without introducing definition references', () => {
  const output = project({ expressions: {
    string: leaf('string'),
    choice: { kind: 'record', properties: [
      { name: 'value', description: 'A value.', documentationAdapter: 'reference-only', required: true, type: 'string' },
      { name: 'label', description: 'A label.', documentationAdapter: 'reference-only', required: false, type: 'string' }
    ] }
  }, contracts: [alias('Example', 'choice')] });
  assert.equal(output.typescript, '{ value: string; label?: string; }');
  assert.equal(output.native, '{"value"!: string, "label"?: string}');
  assert.deepEqual(output.schema, { type: 'object', additionalProperties: false, properties: { value: { type: 'string' }, label: { type: 'string' } }, required: ['value'], description: 'An independent contract.' });
});

test('optional declared tuple members retain the explicit fixed wire arity adapter', () => {
  const input = { expressions: {
    string: leaf('string'),
    tuple: { kind: 'tuple', elements: [{ type: 'string', label: 'value' }, { type: 'string', label: 'offset', required: false }], wireArity: 'all-elements', schemaAdapter: 'positional-items' }
  }, contracts: [alias('Example', 'tuple')] };
  const output = project(input);
  assert.equal(output.typescript, '[value: string, offset?: string]');
  assert.equal(output.native, '[string, string]');
  assert.equal(output.schema.minItems, 2);
  input.expressions.tuple.elements.reverse();
  assert.throws(() => project(input));
});

test('families reuse inherited contract records while owning only their own schema definitions', () => {
  const input = { expressions: { string: leaf('string') },
    baseContracts: [{ name: 'Base', kind: 'interface', description: 'A base.', wire: false, extends: [], properties: [
      { name: 'value', description: 'The value.', required: true, type: 'string' }
    ] }],
    contracts: [{ name: 'Example', kind: 'interface', description: 'A child.', wire: true, extends: ['Base'], properties: [] }]
  };
  const projections = project(input, 'contractProjections');
  assert.deepEqual(Object.keys(projections), ['Example']);
  assert.deepEqual(projections.Example.schema.required, ['value']);
  assert.match(projections.Example.declaration, /interface Example extends Base/);
  input.baseContracts[0].name = 'Other';
  assert.throws(() => project(input));
});

test('private aliases retain checked property spelling without adding wire references', () => {
  const input = { expressions: { string: leaf('string'), number: leaf('number') }, contracts: [
    alias('Private', 'string', { exported: false, documentationAdapter: 'reference-only', wire: false }),
    { name: 'Example', kind: 'interface', description: 'An independent contract.', wire: true, extends: [], properties: [
      { name: 'value', description: 'A value.', required: true, type: 'string', typescriptAlias: 'Private' }
    ] }
  ] };
  const projections = project(input, 'contractProjections');
  assert.equal(projections.Private.declaration, 'type Private = string;\n');
  assert.match(projections.Example.declaration, /value: Private;/);
  assert.equal(projections.Example.schema.properties.value.type, 'string');
  input.contracts[0].expression = 'number';
  assert.throws(() => project(input));
});

test('binary argument applications retain an unwrapped fixed-length schema', () => {
  const output = project({ expressions: { string: leaf('string'), binary: { kind: 'application', shape: 'Binary', argument: 'string' } },
    argumentShapes: [{ name: 'Binary', parameter: 'T', description: 'Both arguments are required.', scalar: false, nullable: false, tupleSize: 2 }],
    contracts: [alias('Example', 'binary')]
  });
  assert.deepEqual(output.schema, { type: 'array', minItems: 2, maxItems: 2, items: { type: 'string' }, description: 'An independent contract.' });
});

test('ordinary optional tuples admit each declared prefix length in native and wire projections', () => {
  const output = project({ expressions: { string: leaf('string'), tuple: { kind: 'tuple', elements: [{ type: 'string' }, { type: 'string', required: false }] } }, contracts: [alias('Example', 'tuple')] });
  assert.equal(output.typescript, '[string, (string)?]');
  assert.equal(output.native, '([string] | [string, string])');
  assert.equal(output.schema.minItems, 1);
  assert.equal(output.schema.maxItems, 2);
});

test('string dictionaries retain arbitrary keys and constrain every value', () => {
  const output = project({ expressions: { string: leaf('string'), dictionary: { kind: 'dictionary', values: 'string', keyName: 'column' } }, contracts: [alias('Example', 'dictionary')] });
  assert.equal(output.typescript, '{ [column: string]: string }');
  assert.equal(output.native, '{[string]: string}');
  assert.deepEqual(output.schema, { type: 'object', additionalProperties: { type: 'string' }, description: 'An independent contract.' });
  const directory = mkdtempSync(join(tmpdir(), 'mosaic-dictionary-'));
  try {
    const native = join(directory, 'native.cue');
    const candidate = join(directory, 'candidate.json');
    writeFileSync(native, `package admission\n#Example: ${output.native}\n`);
    for (const value of [{}, { 'x y': 'left', 'column.name': 'right' }]) {
      writeFileSync(candidate, JSON.stringify(value));
      execFileSync(cue, ['vet', '-c', native, candidate, '-d', '#Example'], { stdio: 'pipe' });
    }
    for (const value of [[], { column: 1 }, { column: null }]) {
      writeFileSync(candidate, JSON.stringify(value));
      assert.throws(() => execFileSync(cue, ['vet', '-c', native, candidate, '-d', '#Example'], { stdio: 'pipe' }));
    }
  } finally { rmSync(directory, { recursive: true, force: true }); }
  assert.throws(() => project({ expressions: { dictionary: { kind: 'dictionary', values: 'Missing' } }, contracts: [alias('Example', 'dictionary')] }));
});

test('mixed literal enums preserve ordered values and unique primitive types', () => {
  const values = ['left', true, null, 3, 'right', false];
  const expressions = Object.fromEntries(values.map((value, index) => [`literal${index}`, { kind: 'literal', value }]));
  expressions.enum = { kind: 'union', members: Object.keys(expressions), schemaAdapter: 'literal-enum' };
  const input = { expressions, contracts: [alias('Example', 'enum')] };
  const output = project(input);
  assert.equal(output.typescript, "'left' | true | null | 3 | 'right' | false");
  assert.deepEqual(output.schema, { enum: values, type: ['string', 'boolean', 'null', 'number'], description: 'An independent contract.' });
  const directory = mkdtempSync(join(tmpdir(), 'mosaic-literal-enum-'));
  try {
    const native = join(directory, 'native.cue');
    const candidate = join(directory, 'candidate.json');
    writeFileSync(native, `package admission\n#Example: ${output.native}\n`);
    for (const value of values) {
      writeFileSync(candidate, JSON.stringify(value));
      execFileSync(cue, ['vet', '-c', native, candidate, '-d', '#Example'], { stdio: 'pipe' });
    }
    for (const value of ['other', 2, {}, []]) {
      writeFileSync(candidate, JSON.stringify(value));
      assert.throws(() => execFileSync(cue, ['vet', '-c', native, candidate, '-d', '#Example'], { stdio: 'pipe' }));
    }
  } finally {
    rmSync(directory, { recursive: true, force: true });
  }
  for (const invalid of [
    { kind: 'primitive', type: 'string' },
    { kind: 'enum', values: ['left', 'right'] },
    expressions.literal0
  ]) {
    const candidate = structuredClone(input);
    candidate.expressions.unused = { kind: 'union', members: ['literal0', 'invalid'], schemaAdapter: 'literal-enum' };
    candidate.expressions.invalid = invalid;
    assert.throws(() => project(candidate));
  }
});

test('parent selections preserve utility syntax and the existing object Exclude behavior', () => {
  const property = (name, type, description = 'A selected property.') => ({ name, type, description, required: false });
  const input = { expressions: { string: leaf('string'), number: leaf('number') }, contracts: [
    { name: 'Base', kind: 'interface', description: 'Base properties.', wire: false, extends: [], properties: [property('keep', 'string'), property('drop', 'number')] },
    { name: 'Omitted', kind: 'interface', description: 'An omitted property.', wire: true, extends: [{ name: 'Base', operator: 'omit', keys: ['drop'] }], properties: [] },
    { name: 'Picked', kind: 'interface', description: 'A picked property.', wire: true, extends: [{ name: 'Base', operator: 'pick', keys: ['keep'] }], properties: [] },
    { name: 'Excluded', kind: 'interface', description: 'The existing Exclude object identity.', wire: true, extends: [{ name: 'Base', operator: 'exclude', keys: ['drop'] }], properties: [] },
    { name: 'Example', kind: 'interface', description: 'A transitive selected property.', wire: true, extends: [{ name: 'Omitted', operator: 'pick', keys: ['keep'] }], properties: [] }
  ] };
  const output = project(input, 'contractProjections');
  assert.deepEqual(Object.keys(output.Omitted.schema.properties), ['keep']);
  assert.deepEqual(Object.keys(output.Picked.schema.properties), ['keep']);
  assert.deepEqual(Object.keys(output.Excluded.schema.properties), ['keep', 'drop']);
  assert.deepEqual(Object.keys(output.Example.schema.properties), ['keep']);
  assert.match(output.Omitted.declaration, /extends Omit<Base, 'drop'>/);
  assert.match(output.Picked.declaration, /extends Pick<Base, 'keep'>/);
  assert.match(output.Excluded.declaration, /extends Exclude<Base, 'drop'>/);
  for (const selection of [
    { name: 'Base', operator: 'pick', keys: ['missing'] },
    { name: 'Base', operator: 'pick', keys: ['keep', 'keep'] },
    { name: 'Base', operator: 'rename', keys: ['keep'] },
    { name: 'Missing', operator: 'all' },
    { name: 'Base', operator: 'all', keys: ['keep'] }
  ]) {
    const invalid = structuredClone(input);
    invalid.contracts[1].extends = [selection];
    assert.throws(() => project(invalid));
  }
  const invalid = structuredClone(input);
  invalid.contracts[4].extends = ['Example'];
  assert.throws(() => project(invalid));
});

test('compatible inherited fields retain first-parent prose and reject conflicting types', () => {
  const property = (description, type = 'string') => ({ name: 'value', description, type, required: false });
  const input = { expressions: { string: leaf('string'), number: leaf('number') }, contracts: [
    { name: 'First', kind: 'interface', description: 'First parent.', wire: false, extends: [], properties: [property('The first description.')] },
    { name: 'Second', kind: 'interface', description: 'Second parent.', wire: false, extends: [], properties: [property('The second description.')] },
    { name: 'Example', kind: 'interface', description: 'Both parents.', wire: true, extends: ['First', 'Second'], properties: [] }
  ] };
  assert.equal(project(input).schema.properties.value.description, 'The first description.');
  const invalid = structuredClone(input);
  invalid.contracts[1].properties[0].type = 'number';
  assert.throws(() => project(invalid));
  const required = structuredClone(input);
  required.contracts[1].properties[0].required = true;
  assert.throws(() => project(required));
});

test('explicit union narrowing overrides retain the child constraint', () => {
  const input = { expressions: {
    linear: { kind: 'literal', value: 'linear' },
    auto: { kind: 'literal', value: 'auto' },
    both: { kind: 'union', members: ['linear', 'auto'] }
  }, contracts: [
    { name: 'Base', kind: 'interface', description: 'Both curves.', wire: false, extends: [], properties: [{ name: 'curve', description: 'Base curves.', type: 'both', required: false }] },
    { name: 'Example', kind: 'interface', description: 'A narrowed curve.', wire: true, extends: ['Base'], properties: [{ name: 'curve', description: 'The linear curve.', type: 'linear', required: false, override: true }] }
  ] };
  const output = project(input);
  assert.deepEqual(output.schema.properties.curve, { const: 'linear', type: 'string', description: 'The linear curve.' });
  assert.match(output.declaration, /curve\?: 'linear';/);
  const absent = structuredClone(input);
  delete absent.contracts[1].properties[0].override;
  assert.throws(() => project(absent));
  const unrelated = structuredClone(input);
  unrelated.contracts[1].properties[0].name = 'unrelated';
  assert.throws(() => project(unrelated));
});

test('object intersections reject duplicate fields with incompatible constraints', () => {
  const property = type => ({ name: 'value', description: 'A value.', type, required: false });
  const input = { expressions: {
    string: leaf('string'), number: leaf('number'),
    first: { kind: 'record', properties: [property('string')] },
    second: { kind: 'record', properties: [property('number')] },
    combined: { kind: 'intersection', members: ['first', 'second'] }
  }, contracts: [alias('Example', 'combined')] };
  assert.throws(() => project(input));
  input.expressions.second.properties[0].type = 'string';
  assert.equal(project(input).schema.properties.value.type, 'string');
});

test('finite references drive mapped keys and negative channel templates', () => {
  const input = { expressions: {
    names: {kind:'enum',values:['x','width']},
    namesRef: {kind:'reference',name:'Names',expression:'names'},
    negative: {kind:'finite-template',reference:'namesRef',prefix:'-'},
    string: leaf('string'),
    mapped: {kind:'mapped',keys:'namesRef',values:'string',required:false}
  }, contracts:[alias('Names','names'),alias('Example','negative'),alias('Mapped','mapped')] };
  const output=project(input,'contractProjections');
  assert.equal(output.Example.typescript,'`-${Names}`');
  assert.deepEqual(output.Example.schema.anyOf,[{const:'-x',type:'string'},{const:'-width',type:'string'}]);
  assert.deepEqual(Object.keys(output.Mapped.schema.properties),['x','width']);
  assert.match(output.Mapped.typescript,/key in Names/);
  const nonfinite = structuredClone(input);
  nonfinite.contracts[0].expression = 'string';
  nonfinite.expressions.namesRef.expression = 'string';
  assert.throws(() => project(nonfinite));
  for(const expression of [
    {kind:'reference',name:'Names',expression:'string'},
    {kind:'mapped',keys:'string',values:'string',required:false},
    {kind:'finite-template',reference:'string',prefix:'-'}
  ]) {
    const invalid=structuredClone(input);
    invalid.expressions.unused=expression;
    assert.throws(()=>project(invalid));
  }
});

test('generic aliases retain arbitrary TypeScript substitution and an explicit default specialization', () => {
  const input={expressions:{
    reducers:{kind:'enum',values:['sum','mean']},
    generic:{kind:'parameter',name:'T',default:'reducers'},
    keys:{kind:'enum',values:['x','y']},
    mapped:{kind:'mapped',keys:'keys',values:'generic',required:false}
  },contracts:[alias('Example','mapped',{parameters:[{name:'T',default:'reducers'}]})]};
  const output=project(input);
  assert.match(output.declaration,/Example<T = 'sum' \| 'mean'>/);
  assert.match(output.declaration,/: T/);
  assert.deepEqual(output.schema.properties.x.enum,['sum','mean']);
  const invalid=structuredClone(input);
  invalid.expressions.generic.name='Missing';
  assert.throws(()=>project(invalid));
  const duplicate = structuredClone(input);
  duplicate.contracts[0].parameters.push({name:'T',default:'reducers'});
  assert.throws(() => project(duplicate));
  const missing = structuredClone(input);
  missing.contracts[0].parameters[0].default='missing';
  assert.throws(() => project(missing));
});

test('indexed properties retain actual source constraints and nested source prose', () => {
  const input = { expressions: {
    number: leaf('number'), string: leaf('string'),
    source: { kind: 'union', members: ['number', 'string'] },
    indexed: { kind: 'indexed-property', contract: 'Base', property: 'value', expression: 'source' },
    combined: { kind: 'union', members: ['indexed', 'string'] }
  }, contracts: [
    { name: 'Base', kind: 'interface', description: 'The base contract.', wire: false, extends: [], properties: [{ name: 'value', description: 'The original value description.', type: 'source', required: false }] },
    alias('Example', 'combined')
  ] };
  const output = project(input);
  assert.equal(output.typescript, "Base['value'] | string");
  assert.deepEqual(output.schema.anyOf, [
    { anyOf: [{ type: 'number' }, { type: 'string' }], description: 'The original value description.' },
    { type: 'string' }
  ]);
  input.contracts[0].properties[0].description = 'Changed canonical property prose.';
  assert.equal(project(input).schema.anyOf[0].description, 'Changed canonical property prose.');
  for (const mutation of [{ property: 'missing' }, { contract: 'Missing' }, { expression: 'number' }]) {
    const unused = structuredClone(input);
    unused.contracts[1].expression = 'number';
    unused.expressions.unusedIndexed = { ...unused.expressions.indexed, ...mutation };
    assert.throws(() => project(unused));
    const invalid = structuredClone(input);
    Object.assign(invalid.expressions.indexed, mutation);
    assert.throws(() => project(invalid));
  }
});

test('indexed and owned alias types participate in checked inheritance narrowing', () => {
  const input = { expressions: {
    number: leaf('number'), string: leaf('string'), boolean: leaf('boolean'),
    source: { kind: 'union', members: ['number', 'string'] },
    indexed: { kind: 'indexed-property', contract: 'Base', property: 'value', expression: 'source' },
    combined: { kind: 'union', members: ['indexed', 'string'] },
    owned: leaf('Owned', 'named'),
    aliasSource: { kind: 'union', members: ['owned', 'boolean'] }
  }, contracts: [
    alias('Owned', 'source'),
    { name: 'Base', kind: 'interface', description: 'The base.', wire: false, extends: [], properties: [{ name: 'value', description: 'Base value.', type: 'source', required: false }] },
    { name: 'Example', kind: 'interface', description: 'Indexed override.', wire: true, extends: ['Base'], properties: [{ name: 'value', description: 'Own value.', type: 'combined', required: false, override: true }] },
    { name: 'AliasBase', kind: 'interface', description: 'Alias base.', wire: false, extends: [], properties: [{ name: 'value', description: 'Alias value.', type: 'aliasSource', required: false }] },
    { name: 'AliasChild', kind: 'interface', description: 'Alias child.', wire: false, extends: ['AliasBase'], properties: [{ name: 'value', description: 'Narrowed value.', type: 'owned', required: false, override: true }] }
  ] };
  assert.equal(project(input).schema.properties.value.anyOf[0].description, 'Base value.');
  const invalid = structuredClone(input);
  invalid.expressions.combined.members.push('boolean');
  assert.throws(() => project(invalid));
  const wrongAlias = structuredClone(input);
  wrongAlias.contracts[4].properties[0].type = 'string';
  wrongAlias.expressions.aliasSource.members = ['number', 'boolean'];
  assert.throws(() => project(wrongAlias));
});

test('native alias projection rejects a dropped alternatives handoff', () => {
  const directory = mkdtempSync(join(tmpdir(), 'mosaic-native-alternatives-'));
  try {
    const path = join(directory, 'input.json');
    const previous = {
      typescript: 'number | string',
      native: '(number | string)',
      schema: { anyOf: [{ type: 'number' }, { type: 'string' }] },
      nativeAlternativesRequired: true,
      nativeAlternatives: ['number', 'string']
    };
    for (const omitted of [null, 'nativeAlternatives', 'nativeAlternativesRequired']) {
      const value = { ...previous };
      if (omitted) delete value[omitted];
      writeFileSync(path, JSON.stringify({
        expression: { kind: 'parameter', name: 'T', default: 'choice' },
        previous: { choice: value }
      }));
      const command = () => execFileSync(cue, ['vet', '-c', './api/render', path, '-d', '#ShapeExpressionProjection'], { stdio: 'pipe' });
      if (omitted) assert.throws(command, omitted);
      else command();
    }
  } finally {
    rmSync(directory, { recursive: true, force: true });
  }
});
