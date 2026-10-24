import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { expect, it } from 'vitest';
import { createTable, loadCSV, loadJSON, loadObjects, loadParquet, loadSpatial } from '@uwdata/mosaic-sql';
import { astToESM, astToPython, parseSpec } from '../src/index.js';
import { resolveExtensions } from '../src/config/extensions.js';

const schema = JSON.parse(await readFile(resolve(import.meta.dirname, '../dist/mosaic-schema.json'), 'utf8'));
const validator = new Ajv({ allowUnionTypes: true, allErrors: true });
addFormats.default(validator);
validator.addSchema(schema, 'data-contracts');
validator.compile(schema);
const definition = name => validator.getSchema(`data-contracts#/definitions/${name}`);
const parse = data => parseSpec({ data: { rows: data }, plot: [] });

it.each([
  ['DataQuery', ['SELECT 1', ''], [null, 3, {}]],
  ['DataArray', [[], [{}], [{ nested: [1, null] }]], [[1], [null], {}]],
  ['DataFile', [{ file: 'rows.csv' }, { file: 'arbitrary.CSV?x=1' }], [{}, { file: 1 }, { file: 'rows.csv', type: 'unknown' }]],
  ['DataTable', [{ type: 'table', query: 'SELECT 1' }, { type: 'table', query: '', where: ['x=1', 'y=2'], temp: false }], [{ type: 'table' }, { query: 'SELECT 1' }, { type: 'csv', query: 'SELECT 1' }]],
  ['DataParquet', [{ type: 'parquet', file: 'no-suffix', select: [], replace: false }], [{ type: 'parquet' }, { type: 'parquet', file: 'f', select: 'x' }]],
  ['DataCSV', [{ type: 'csv', file: 'f', delimiter: ';', sample_size: -1 }], [{ type: 'csv', file: 'f', sample_size: 'all' }, { type: 'csv', file: 'f', custom: null }]],
  ['DataSpatial', [{ type: 'spatial', file: 'f', layer: '' }], [{ type: 'spatial', file: 'f', layer: 3 }]],
  ['DataJSON', [{ type: 'json', file: 'f' }], [{ type: 'json', data: [] }, { type: 'json', file: 'f', data: [] }]],
  ['DataJSONObjects', [{ data: [] }, { type: 'json', data: [{}] }], [{ type: 'json' }, { data: [1] }, { data: [], file: 'f' }]],
  ['PlotDataInline', [[], [null, 1, 'a', { x: true }]], [{}, null]],
  ['PlotFrom', [{ from: 'rows' }, { from: '$table', filterBy: 'plain-wire-reference', optimize: false }], [{}, { from: 1 }, { from: 'rows', unnest: ['items'] }, { from: 'rows', optimize: null }]]
])('%s retains independent admission and rejection cases', (name, accepted, rejected) => {
  const validate = definition(name);
  expect(validate).toBeTypeOf('function');
  for (const value of accepted) expect(validate(value), JSON.stringify(value)).toBe(true);
  for (const value of rejected) expect(validate(value), JSON.stringify(value)).toBe(false);
});

it('keeps inference, explicit format precedence, and the missing-type inline-object mismatch', () => {
  expect(parse(' SELECT 1 ').toJSON().data.rows).toEqual({ type: 'table', query: 'SELECT 1' });
  expect(parse([{ x: 1 }]).toJSON().data.rows).toEqual({ type: 'json', data: [{ x: 1 }] });
  expect(parse({ file: 'rows.csv' }).toJSON().data.rows).toEqual({ type: 'csv', file: 'rows.csv' });
  expect(parse({ type: 'parquet', file: 'rows.csv' }).toJSON().data.rows.type).toBe('parquet');
  expect(parse({ data: [{ x: 1 }] }).toJSON().data.rows).toEqual({ type: 'table', query: undefined, data: [{ x: 1 }] });
  expect(definition('DataJSONObjects')({ data: [{ x: 1 }] })).toBe(true);
  for (const file of ['rows.CSV', 'rows.csv?download=1', 'rows.csv#fragment']) expect(() => parse({ file })).toThrow('Unrecognized data format');
  expect(parse({ file: '.csv' }).toJSON().data.rows.type).toBe('table');
});

it('retains loader and table option defaults through the actual AST and SQL paths', () => {
  expect(String(createTable('rows', 'SELECT 1'))).toBe('CREATE TABLE IF NOT EXISTS "rows" AS SELECT 1');
  const context = { api: { createTable, loadCSV, loadJSON, loadParquet, loadSpatial, loadObjects } };
  const table = parse('SELECT 1').data.rows;
  expect(String(table.instantiateQuery(context))).toBe('CREATE TABLE IF NOT EXISTS "rows" AS SELECT 1');
  for (const type of ['csv', 'json', 'parquet', 'spatial']) {
    const node = parse({ type, file: 'rows.file' }).data.rows;
    const query = node.instantiateQuery(context);
    expect(query).toMatchObject({ temp: false, replace: false, view: false });
  }
  expect(parse({ type: 'csv', file: 'rows.csv', temp: true, replace: true, view: true }).data.rows.instantiateQuery(context)).toMatchObject({ temp: true, replace: true, view: true });
  expect(() => parse([]).data.rows.instantiateQuery(context)).toThrow('empty column set');
  expect(definition('DataArray')([])).toBe(true);
});

it('resolves file URLs, extension prerequisites, and loading order without changing discovery', () => {
  const ast = parseSpec({ config: { extensions: ['json', 'spatial'] }, data: { first: { type: 'spatial', file: 'shape.geojson' }, second: { type: 'csv', file: 'rows.csv' } }, plot: [] });
  expect([...resolveExtensions(ast)]).toEqual(['json', 'spatial']);
  const code = astToESM(ast, { baseURL: 'https://example.test/base/' });
  expect(code).toContain('loadSpatial("first", "https://example.test/base/shape.geojson"');
  expect(code.indexOf('loadExtension("spatial")')).toBeLessThan(code.indexOf('loadSpatial("first"'));
  expect(code.indexOf('loadSpatial("first"')).toBeLessThan(code.indexOf('loadCSV("second"'));
});

it('preserves raw parser options, source selection references, and non-schema native unnest', () => {
  const ast = parseSpec(/** @type {any} */ ({ data: { rows: { type: 'csv', file: 'rows.csv', raw_option: null } }, params: { brush: { select: 'intersect' }, table: 'rows' }, plot: [{ mark: 'dot', data: { from: '$table', filterBy: '$brush', optimize: false, unnest: ['items'] }, x: 'items' }] }));
  expect(ast.toJSON().data.rows.raw_option).toBeNull();
  expect(ast.toJSON().plot[0].data).toEqual({ from: '$table', filterBy: '$brush', optimize: false, unnest: ['items'] });
});

it.each(['csv', 'parquet', 'json', 'bare', '.csv', '.parquet', 'rows.csv', 'rows.parquet', 'rows.json', 'rows.CSV', 'rows.csv?download=1'])('preserves direct arbitrary-AST Python fallback for %s', file => {
  const output = astToPython({ toJSON: () => ({ data: { rows: { file } }, plot: [] }) });
  if (file.endsWith('.csv')) expect(output).toContain(`rows = vg.csv("${file}")`);
  else if (file.endsWith('.parquet')) expect(output).toContain(`rows = vg.parquet("${file}")`);
  else expect(output.replace(/\s/g, '')).toContain(`rows={"file":"${file}"}`);
});

it('preserves the raw table-options Python fallback and safe dataset/parameter names', () => {
  const output = astToPython(parseSpec({ data: { rows: { type: 'table', query: 'SELECT 1 AS x', temp: true } }, params: { rows: 1 }, plot: [{ mark: 'dot', data: { from: 'rows' }, x: 'x' }] }));
  expect(output.replace(/\s/g, '')).toContain('rows_data={"type":"table","query":"SELECT1ASx","temp":True}');
  expect(output).toContain('data={"rows": rows_data}');
  expect(output).toContain('rows = vg.param(1)');
});
