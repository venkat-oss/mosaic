import { readFile } from 'node:fs/promises';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { expect, it, vi } from 'vitest';
import { astToPython, parseSpec } from '../src/index.js';
import { inputNames } from '../src/config/inputs.js';

const schema = JSON.parse(await readFile(new URL('../dist/mosaic-schema.json', import.meta.url), 'utf8'));
const ajv = new Ajv({ allowUnionTypes: true, allErrors: true });
addFormats.default(ajv);
ajv.addSchema(schema, 'table');
const validate = ajv.getSchema('table#/definitions/Table');
const parseWire = value => parseSpec(/** @type {any} */ (value));

it('preserves required table source/discriminator and exact dictionary value constraints', () => {
  for (const value of [
    { input: 'table', from: 'rows' },
    { input: 'table', from: 'ordinary-reference', align: { 'column.with space': 'justify' }, width: { 'column.with space': -2.5 } },
    { input: 'table', from: '$source', rowBatch: 0, height: -1, maxWidth: 0, width: 2.5 }
  ]) expect(validate(value), JSON.stringify(validate.errors)).toBe(true);
  for (const value of [
    {}, { input: 'table' }, { from: 'rows' }, { input: 'custom', from: 'rows' },
    { input: 'table', from: 3 }, { input: 'table', from: 'rows', columns: [3] },
    { input: 'table', from: 'rows', align: { x: 'start' } },
    { input: 'table', from: 'rows', width: { x: '30' } },
    { input: 'table', from: 'rows', height: null },
    { input: 'table', from: 'rows', format: {} }, { input: 'table', from: 'rows', element: {} }
  ]) expect(validate(value)).toBe(false);
});

it('retains generic parser options beyond wire admission and dispatches the context-owned table helper', () => {
  const spec = { input: 'table', from: 'rows', raw_option: null, format: {} };
  expect(validate(spec)).toBe(false);
  const ast = parseWire(spec);
  expect(ast.toJSON()).toEqual(spec);
  const helper = vi.fn().mockReturnValue('table-element');
  expect(ast.root.instantiate({ api: { table: helper } })).toBe('table-element');
  expect(helper).toHaveBeenCalledExactlyOnceWith({ from: 'rows', raw_option: null, format: {} });
});

it('preserves source/selection aliases and the table_input Python widget name', () => {
  const source = astToPython(parseWire({ input: 'table', from: '$source', as: '$brush', filterBy: '$brush', maxWidth: 400, rowBatch: 2 }));
  expect(source).toContain('vg.table_input(');
  expect(source).toContain('source=source');
  expect(source).toContain('bind=brush');
  expect(source).toContain('filter_by=brush');
  expect(source).toContain('max_width=400');
  expect(source).toContain('row_batch=2');
  expect(astToPython(parseWire({ input: 'table' }))).toContain('vg.table_input()');
  expect([...inputNames()]).toEqual(['menu', 'search', 'slider', 'table']);
});
