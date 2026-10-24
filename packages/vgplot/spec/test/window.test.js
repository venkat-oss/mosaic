import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { describe, expect, it } from 'vitest';
import * as vg from '@uwdata/vgplot';
import * as sql from '@uwdata/mosaic-sql';
import { astToESM, astToPython, parseSpec } from '../src/index.js';
import { WindowFrameNode, parseWindowFrame } from '../src/ast/WindowFrameNode.js';
import { LiteralNode } from '../src/ast/LiteralNode.js';

const schema = JSON.parse(await readFile(resolve(import.meta.dirname, '../dist/mosaic-schema.json'), 'utf8'));
const ajv = new Ajv({ allowUnionTypes: true, allErrors: true });
addFormats.default(ajv);
ajv.addSchema(schema, 'window-contracts');
const cases = /** @type {[string, object[], object[]][]} */ ([
  ...[['RowNumber', 'row_number'], ['Rank', 'rank'], ['DenseRank', 'dense_rank'], ['PercentRank', 'percent_rank'], ['CumeDist', 'cume_dist']].map(([name, key]) => [name, [{ [key]: null }, { [key]: [], rows: [-1, 0], exclude: 'ties' }], [{ [key]: '' }, { [key]: 'x' }, { [key]: ['x'] }]]),
  ...[['NTile', 'ntile'], ['FirstValue', 'first_value'], ['LastValue', 'last_value']].map(([name, key]) => [name, [{ [key]: 'x' }, { [key]: [{ sql: '2' }] }], [{ [key]: 2 }, { [key]: [] }, { [key]: ['x', 'y'] }]]),
  ...[['Lag', 'lag'], ['Lead', 'lead']].map(([name, key]) => [name, [{ [key]: 'x' }, { [key]: ['x', 2, null] }, { [key]: ['x', { sql: '2' }, '2024-01-01T00:00:00.000Z'] }], [{ [key]: ['x'] }, { [key]: ['x', 2] }, { [key]: ['x', false, null] }]]),
  ['NthValue', [{ nth_value: ['x', 2] }, { nth_value: ['x', { sql: '2' }] }], [{ nth_value: ['x'] }, { nth_value: ['x', null] }]],
  ...['Years', 'Months', 'Days', 'Hours', 'Minutes', 'Seconds', 'Milliseconds', 'Microseconds'].map(name => [name, [{ [name.toLowerCase()]: 2 }], [{ [name.toLowerCase()]: '2' }, {}, { [name.toLowerCase()]: 2, unknown: true }]])
]);

function parseWire(input) {
  return parseSpec(input);
}

const definitions = new Map(cases.map(([name]) => [name, ajv.getSchema(`window-contracts#/definitions/${name}`)]));

describe('window and interval contracts', () => {
  it.each(cases)('%s preserves independent wire admission', (name, accepted, rejected) => {
    const validate = definitions.get(name);
    for (const value of accepted) expect(validate(value), JSON.stringify(value)).toBe(true);
    for (const value of [...rejected, { ...accepted[0], unknown: true }]) expect(validate(value), JSON.stringify(value)).toBe(false);
  });

  it('retains nullary parser normalization even though the normalized empty string is outside wire admission', () => {
    for (const key of ['row_number', 'rank', 'dense_rank', 'percent_rank', 'cume_dist']) for (const value of [null, []]) {
      const ast = parseWire({ plot: [{ mark: 'dot', x: { [key]: value } }] });
      expect(ast.toJSON().plot[0].x).toEqual({ [key]: '' });
      expect(astToPython(ast)).toContain(`vg.${key}()`);
    }
  });

  it('retains frame precedence, truthiness, whole-frame references, and case normalization', () => {
    const ctx = { paramRef: name => ({ name }) };
    const frame = parseWindowFrame({ rows: [null, 0], range: [-2, 0], groups: [-3, 0], exclude: 'ties' }, ctx);
    expect(frame.type).toBe('ROWS');
    expect(frame.toJSON()).toEqual({ rows: [null, 0], exclude: 'TIES' });
    expect(parseWindowFrame({ rows: null, range: [0, 1] }, ctx).type).toBe('RANGE');
    expect(parseWindowFrame({ rows: '$bounds' }, ctx).extent).toEqual({ name: 'bounds' });
    expect(parseWindowFrame({ rows: ['$lower', '$upper'] }, ctx).toJSON().rows).toEqual(['$lower', '$upper']);
  });

  it('retains known frame utilities and custom constructor fallback codegen', () => {
    const ctx = { ns: () => 'vg.', stringify: JSON.stringify };
    for (const [type, name] of [['ROWS', 'frameRows'], ['RANGE', 'frameRange'], ['GROUPS', 'frameGroups'], ['CUSTOM', 'frameCustom']]) {
      const node = new WindowFrameNode(type, [new LiteralNode(-1), new LiteralNode(0)], 'current row');
      expect(node.codegen(ctx)).toBe(`vg.${name}([-1, 0], 'CURRENT ROW')`);
    }
  });

  it('keeps interval dictionaries literal in Python while emitting native interval calls in JavaScript', () => {
    const ast = parseWire({ plot: [{ mark: 'dot', x: { sum: 'x', range: [{ days: 2 }, 0], orderby: 'time' } }] });
    expect(astToESM(ast)).toContain('days(2)');
    expect(astToPython(ast)).toMatch(/\{\s*"days": 2\s*\}/);
    expect(astToPython(ast)).not.toContain('vg.days(');
  });

  it('keeps selective SQL windows, intervals, and frame helper identities', () => {
    for (const key of ['row_number', 'rank', 'dense_rank', 'percent_rank', 'cume_dist', 'ntile', 'lag', 'lead', 'first_value', 'last_value', 'nth_value', 'interval', 'years', 'months', 'days', 'hours', 'minutes', 'seconds', 'milliseconds', 'microseconds', 'frameRows', 'frameRange', 'frameGroups']) expect(vg[key]).toBe(sql[key]);
    for (const key of ['preceding', 'following', 'currentRow']) expect(vg[key]).toBeUndefined();
  });
});
