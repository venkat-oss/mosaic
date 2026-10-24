import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import test from 'node:test';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';

const root = resolve(import.meta.dirname, '../..');
const vg = await import(pathToFileURL(resolve(root, 'packages/vgplot/vgplot/src/api.js')));
const schema = JSON.parse(readFileSync(resolve(root, 'packages/vgplot/spec/dist/mosaic-schema.json'), 'utf8'));
const validator = new Ajv({ allowUnionTypes: true });
addFormats.default(validator);
validator.addSchema(schema, 'common');
const cases = [
  ['ChannelValueSpec', [{ value: 'x', label: 'Values', scale: 'color' }, { value: 'x', scale: false }], [{ value: 'x', scale: 'bogus' }, { value: 'x', scale: '$scale' }, { value: 'x', extra: true }]],
  ['ChannelValueIntervalSpec', [{ value: 'x', interval: 'arbitrary' }], [{ value: 'x', interval: 2 }, { value: 'x', interval: 'day', label: 'Values' }]],
  ['ChannelDomainValue', ['data', '-data', '-width', '-x', null], ['color', '-color', '--x']],
  ['ChannelDomainSort', [{}, { color: { value: 'fill', reduce: 'mean', limit: [1, 3], order: null } }], [{ missing: 'x' }, { x: { value: 'y', limit: [] } }, { x: { value: 'y', limit: [1] } }]],
  ['SortOrder', [{}, { value: 'x', order: 'descending' }, { channel: '-x', order: 'ascending' }], [{ value: 'x', channel: 'y' }, { order: null }, { channel: '-color' }]],
  ['Curve', ['linear', 'step'], ['auto']],
];
const definitions = new Map(cases.map(([name]) => [name, validator.getSchema(`common#/definitions/${name}`)]));
const dot = validator.getSchema('common#/definitions/Dot');
const area = validator.getSchema('common#/definitions/Area');
for (const [name, accepted, rejected] of cases) test(`${name} preserves its independent common-mark boundary`, () => {
  for (const value of accepted) assert.equal(definitions.get(name)(value), true, JSON.stringify(value));
  for (const value of rejected) assert.equal(definitions.get(name)(value), false, JSON.stringify(value));
});

test('tooltip intersection preserves elided base validation and open extra properties', () => {
  assert.equal(dot({ mark: 'dot', data: [], tip: { pointer: 'x', arbitrary: 1, filter: { invalid: true } } }), true);
  assert.equal(dot({ mark: 'dot', data: [], tip: { pointer: 'z' } }), false);
  assert.equal(dot({ mark: 'dot', data: [], tip: { format: { unknown: '%' } } }), false);
});

test('mark channels use arbitrary dictionary keys with string values', () => {
  assert.equal(dot({ mark: 'dot', data: [], channels: { raw_alias: 'x', 'field name': 'y' } }), true);
  assert.equal(dot({ mark: 'dot', data: [], channels: { raw_alias: 2 } }), false);
  assert.equal(area({ mark: 'area', data: [], curve: 'auto' }), true);
});

function mark(name, args) {
  let result;
  vg[name](...args)({ addMark: value => { result = value; } });
  return result;
}
test('ordinary mark factory distinguishes arrays, one options argument and explicit source/options', () => {
  assert.deepEqual(mark('dot', [{ x: 1 }]).source, [{}]);
  assert.deepEqual(mark('dot', [{ x: 1 }]).channels, [{ channel: 'x', value: 1 }]);
  const rows = [{ x: 1 }];
  assert.equal(mark('dot', [rows]).source, rows);
  const source = { table: 'records' };
  assert.equal(mark('dot', [source, { x: 1 }]).source, source);
  assert.equal(mark('dot', []).source, undefined);
});
test('ordinary decorative options-only calls have null sources while explicit arrays stay arrays', () => {
  assert.equal(mark('frame', [{ stroke: 'red' }]).source, null);
  assert.equal(mark('hexgrid', [{}]).source, null);
  const rows = [];
  assert.equal(mark('frame', [rows]).source, rows);
});
