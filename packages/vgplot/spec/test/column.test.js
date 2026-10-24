import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { describe, expect, it } from 'vitest';
import { astToESM, astToPython, parseSpec } from '../src/index.js';
import { LiteralNode } from '../src/ast/LiteralNode.js';

const schema = JSON.parse(await readFile(resolve(import.meta.dirname, '../dist/mosaic-schema.json'), 'utf8'));
const validator = new Ajv({ allowUnionTypes: true, allErrors: true });
addFormats.default(validator);
validator.addSchema(schema, 'column-contracts');
const cases = [
  ['SQLExpression', [{ sql: 'x + $offset', label: 'Position' }], [{ sql: 1 }, { sql: 'x', extra: true }]],
  ['AggregateExpression', [{ agg: 'AVG(x)', label: 'Average' }], [{ agg: null }, { agg: 'AVG(x)', sql: 'x' }]],
  ['TransformField', ['x', '$field', { sql: 'x + 1' }, { bin: { sql: 'x + 1' } }], [1, null, {}]],
  ['FrameValue', [null, 0, { days: 2 }], ['unbounded', { days: '2' }]],
  ['BinInterval', ['date', 'number', 'millisecond', 'year'], ['week', 'DAY', 1]],
  ['Bin', [{ bin: 'x' }, { bin: ['$field'], step: 2, steps: 8, minstep: 1, nice: false, offset: 1 }], [{ bin: [] }, { bin: ['x', 'y'] }, { bin: 'x', step: '2' }, { bin: 'x', unknown: 1 }]],
  ['Column', [{ column: 'x' }, { column: ['$field'] }], [{ column: [] }, { column: ['x', 'y'] }, { column: { sql: 'x' } }]],
  ...['DateMonth', 'DateMonthDay', 'DateDay', 'Centroid', 'CentroidX', 'CentroidY', 'GeoJSON'].map(name => {
    const key = name === 'GeoJSON' ? 'geojson' : name[0].toLowerCase() + name.slice(1);
    return [name, [{ [key]: 'x' }, { [key]: [{ sql: 'x' }] }], [{ [key]: [] }, { [key]: ['x', 'y'] }, { [key]: 'x', extra: true }]];
  })
];

const definitions = new Map(cases.map(([name]) => [name, validator.getSchema(`column-contracts#/definitions/${name}`)]));

function parseWire(input) {
  return parseSpec(input);
}

describe('column and expression contracts', () => {
  it.each(cases)('%s preserves independent definition admission', (name, accepted, rejected) => {
    const validate = definitions.get(name);
    expect(validate).toBeTypeOf('function');
    for (const value of accepted) expect(validate(value), JSON.stringify(value)).toBe(true);
    for (const value of rejected) expect(validate(value), JSON.stringify(value)).toBe(false);
  });

  it('preserves SQL parser label dropping and skips references inside quoted strings', () => {
    const ast = parseWire({ plot: [{ mark: 'dot', x: { sql: '"$quoted" + $offset + $$column', label: 'Dropped label' } }] });
    const node = ast.root.children[0].options.options.x;
    const capture = node.instantiate({
      activeParams: new Map().set('offset', 11).set('column', 'amount'),
      api: { sql: (spans, ...args) => ({ spans, args }), column: value => ({ column: value }) }
    });
    expect(capture).toEqual({ spans: ['"$quoted" + ', ' + ', ''], args: [11, { column: 'amount' }] });
    expect(node.toJSON()).toEqual({ sql: '"$quoted" + $offset + $$column' });
    expect(astToESM(ast)).not.toContain('Dropped label');
    expect(astToPython(ast)).not.toContain('Dropped label');
  });

  it('keeps declared aggregate and empty SQL forms as literal parser fallbacks', () => {
    for (const expression of [{ agg: 'AVG(x)', label: 'Literal label' }, { sql: '' }]) {
      const ast = parseWire({ plot: [{ mark: 'dot', x: expression }] });
      const node = ast.root.children[0].options.options.x;
      expect(node).toBeInstanceOf(LiteralNode);
      expect(node.instantiate()).toEqual(expression);
      expect(ast.toJSON().plot[0].x).toEqual(expression);
      if ('agg' in expression) expect(astToPython(ast)).not.toContain('vg.sql(');
      else expect(astToPython(ast)).toContain('vg.sql("")');
    }
  });

  it('retains parser-only bin argument truncation while the wire contract rejects two arguments', () => {
    const input = { bin: ['first', 'ignored'], steps: 8 };
    expect(validator.getSchema('column-contracts#/definitions/Bin')(input)).toBe(false);
    const ast = parseWire({ plot: [{ mark: 'dot', x: input }] });
    expect(ast.toJSON().plot[0].x).toEqual({ bin: 'first', steps: 8 });
    expect(astToESM(ast)).toContain('bin("first", {steps: 8})');
    expect(astToPython(ast)).toContain('vg.bin("first", steps=8)');
  });
});
