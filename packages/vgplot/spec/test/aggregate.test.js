import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { describe, expect, it } from 'vitest';
import * as vg from '@uwdata/vgplot';
import * as sql from '@uwdata/mosaic-sql';
import { astToESM, astToPython, parseSpec } from '../src/index.js';

const schema = JSON.parse(await readFile(resolve(import.meta.dirname, '../dist/mosaic-schema.json'), 'utf8'));
const ajv = new Ajv({ allowUnionTypes: true, allErrors: true });
addFormats.default(ajv);
ajv.addSchema(schema, 'aggregate-contracts');
const unary = ['Avg', 'First', 'Last', 'Max', 'Min', 'Median', 'Mode', 'Product', 'Stddev', 'StddevPop', 'Sum', 'Variance', 'VarPop'];
const cases = /** @type {[string, object[], object[]][]} */ ([
  ...unary.map(name => [name, [{ [name[0].toLowerCase() + name.slice(1)]: 'x' }, { [name[0].toLowerCase() + name.slice(1)]: [{ sql: 'x + 1' }], distinct: false, rows: [null, 0] }], [{ [name[0].toLowerCase() + name.slice(1)]: [] }, { [name[0].toLowerCase() + name.slice(1)]: ['x', 'y'] }]]),
  ['Argmax', [{ argmax: ['x', 'y'] }], [{ argmax: 'x' }, { argmax: ['x'] }, { argmax: ['x', 'y', 'z'] }]],
  ['Argmin', [{ argmin: [{ sql: 'x' }, '$field'] }], [{ argmin: ['x'] }, { argmin: ['x', 1] }]],
  ['Quantile', [{ quantile: ['x', 0.5] }, { quantile: ['x', { sql: '0.5' }] }], [{ quantile: 'x' }, { quantile: ['x'] }, { quantile: ['x', null] }]],
  ['Count', [{ count: null }, { count: [] }, { count: '' }, { count: 'x' }, { count: ['$field'] }], [{ count: 0 }, { count: false }, { count: ['x', 'y'] }]]
]);

function parseWire(input) {
  return parseSpec(input);
}

const definitions = new Map(cases.map(([name]) => [name, ajv.getSchema(`aggregate-contracts#/definitions/${name}`)]));

describe('aggregate transform contracts', () => {
  it.each(cases)('%s preserves independent wire admission', (name, accepted, rejected) => {
    const validate = definitions.get(name);
    for (const value of accepted) expect(validate(value), JSON.stringify(value)).toBe(true);
    for (const value of [...rejected, { ...accepted[0], unknown: true }]) expect(validate(value), JSON.stringify(value)).toBe(false);
  });

  it('preserves parser-only covariance and geometric mean support outside the wire union', () => {
    for (const [key, value] of Object.entries({ covariance: ['x', 'y'], covarPop: ['x', 'y'], geomean: 'x' })) {
      expect(schema.definitions[{ covariance: 'Covariance', covarPop: 'CovarPop', geomean: 'Geomean' }[key]]).toBeUndefined();
      const input = { plot: [{ mark: 'dot', x: { [key]: value } }] };
      expect(ajv.getSchema('aggregate-contracts')(input)).toBe(false);
      const ast = parseWire(input);
      expect(ast.toJSON().plot[0].x).toEqual({ [key]: value });
      expect(astToESM(ast)).toContain(`${key}(`);
      expect(astToPython(ast)).not.toContain(`vg.${key}(`);
    }
  });

  it('retains the count parser truthiness adapter for every falsy input', () => {
    for (const value of [undefined, null, false, 0, '', []]) {
      const ast = parseWire({ plot: [{ mark: 'dot', x: { count: value } }] });
      expect(ast.root.children[0].options.options.x.args).toHaveLength(0);
      expect(ast.toJSON().plot[0].x).toEqual({ count: '' });
      expect(astToESM(ast)).toContain('count()');
      expect(astToPython(ast)).toContain('vg.count()');
    }
  });

  it('retains distinct, window options, parameter references, and null codegen filtering', () => {
    const ast = parseWire({ params: { field: 'x' }, plot: [{ mark: 'dot', x: { sum: '$field', distinct: true, orderby: 'y', partitionby: 'g', rows: [-1, 0], exclude: 'current row' } }] });
    expect(ast.toJSON().plot[0].x).toEqual({ sum: '$field', distinct: true, orderby: 'y', partitionby: 'g', rows: [-1, 0], exclude: 'CURRENT ROW' });
    expect(astToESM(ast)).toContain('.distinct().orderby("y").partitionby("g").frame(');
    expect(astToPython(ast)).toContain('vg.sum(field, distinct=True');
    const absent = parseWire({ plot: [{ mark: 'dot', x: { avg: 'x', distinct: null } }] });
    expect(astToPython(absent)).not.toContain('distinct=');
  });

  it('keeps selective SQL aggregate exports as original function identities', () => {
    for (const key of ['argmax', 'argmin', 'avg', 'count', 'covariance', 'covarPop', 'first', 'geomean', 'last', 'max', 'min', 'median', 'mode', 'product', 'quantile', 'stddev', 'stddevPop', 'sum', 'variance', 'varPop', 'arrayAgg', 'corr', 'entropy', 'kurtosis', 'mad', 'skewness', 'stringAgg']) expect(vg[key]).toBe(sql[key]);
  });
});
