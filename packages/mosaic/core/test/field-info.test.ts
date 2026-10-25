import { DuckDB } from '@uwdata/mosaic-duckdb';
import { dateDay, float64, list, tableFromArrays, utf8 } from '@uwdata/flechette';
import * as nativeSQL from '@uwdata/mosaic-sql';
import { afterAll, beforeAll, describe, it, expect } from 'vitest';
import type { Coordinator } from '../src/index.js';
import { Coordinator as QueryCoordinator, SqlContext, queryFieldInfo } from '../src/index.js';
import { NodeConnector } from '../src/connectors/NodeConnector.js';

describe('native queryFieldInfo', () => {
  const db = new DuckDB();
  let mc: Coordinator;
  const table = ['metadata schema', 'metadata rows'];

  beforeAll(async () => {
    await db.exec(`CREATE SCHEMA "metadata schema";
      CREATE TABLE "metadata schema"."metadata rows" AS
      SELECT * FROM (VALUES (1, 'a'), (2, 'a'), (NULL, 'b')) t("x value", label);
      CREATE TABLE "metadata schema".dates AS
      SELECT * FROM (VALUES (DATE '2024-01-02'), (DATE '2024-03-04'), (NULL)) t(day);
      CREATE TABLE "metadata schema".lists AS
      SELECT * FROM (VALUES ([1,NULL,3]), ([]), (NULL)) t(items)`);
    mc = new QueryCoordinator(await NodeConnector.make(db), { sql: new SqlContext(), logger: null });
  });
  afterAll(async () => {
    mc.clear();
    await db.close();
  });

  it('retains request identity/order and relation qualifiers for fields with identical SQL', async () => {
    const relation = nativeSQL.from(table, 'source alias');
    const first = nativeSQL.column('x value', 'source alias');
    const second = nativeSQL.column('x value', 'source alias');
    const requests = [first, second].map(column => ({
      table: relation, column, stats: ['count', 'nulls', 'distinct', 'min', 'max'] as const
    }));
    const info = await queryFieldInfo(mc, requests.map(entry => ({ ...entry, stats: [...entry.stats] })));
    expect(info).toHaveLength(2);
    for (let i = 0; i < info.length; ++i) {
      expect(info[i].column).toBe(requests[i].column);
      expect(info[i].table).toBe(relation);
      expect(info[i]).toMatchObject({ type: 'number', nullable: true, count: 2, nulls: 1, distinct: 2, min: 1, max: 2 });
    }
  });

  it('returns schema and zero/null statistics for an empty relation', async () => {
    const empty = nativeSQL.Query.from(nativeSQL.from(table)).select('*').where(nativeSQL.literal(false));
    const column = nativeSQL.column('x value');
    const [info] = await queryFieldInfo(mc, [{ table: empty, column, stats: ['count', 'nulls', 'distinct', 'min', 'max'] }]);
    expect(info.column).toBe(column);
    expect(info).toMatchObject({ sqlType: 'INTEGER', type: 'number', nullable: true, count: 0, nulls: 0, distinct: 0, min: null, max: null });
    const columns = await queryFieldInfo(mc, [{ table: empty, column: '*' }], {});
    expect(columns.map(({ column, type }) => ({ column, type }))).toEqual([
      { column: 'x value', type: 'number' }, { column: 'label', type: 'string' }
    ]);
  });

  it('uses actual resolved bin groups for aggregate statistics and preserves explicit aliases', async () => {
    const bin = nativeSQL.floor(nativeSQL.div(nativeSQL.column('x value'), nativeSQL.literal(10)));
    const measure = nativeSQL.count();
    const query = nativeSQL.Query.from(nativeSQL.from(table)).select({ 'bin alias': bin, 'count alias': measure }).groupby(bin);
    const [info] = await queryFieldInfo(mc, [{ table, column: measure, stats: ['min', 'max', 'count'] }], { query });
    expect(info.column).toBe(measure);
    expect(info).toMatchObject({ type: 'number', min: 1, max: 2, count: 2 });
  });

  it('returns date and text extrema that callers narrow before use', async () => {
    const [date, text] = await queryFieldInfo(mc, [
      { table: ['metadata schema', 'dates'], column: nativeSQL.column('day'), stats: ['min', 'max'] },
      { table, column: nativeSQL.column('label'), stats: ['min', 'max'] }
    ]);
    expect(date.type).toBe('date');
    if (!(date.min instanceof Date) || !(date.max instanceof Date)) throw new Error('Expected date extrema.');
    if (!(date.min instanceof Date) || !(date.max instanceof Date)) throw new TypeError('Expected temporal metadata bounds.');
    expect([date.min.toISOString(), date.max.toISOString()]).toEqual([
      '2024-01-02T00:00:00.000Z', '2024-03-04T00:00:00.000Z'
    ]);
    expect(text.type).toBe('string');
    if (typeof text.min !== 'string' || typeof text.max !== 'string') throw new Error('Expected text extrema.');
    expect([text.min.toUpperCase(), text.max.toUpperCase()]).toEqual(['A', 'B']);
  });

  it('describes nested group/window expressions in their authored projection scope', async () => {
    const group = nativeSQL.column('label');
    const measure = nativeSQL.sum(nativeSQL.sum('x value')).partitionby(group);
    const query = nativeSQL.Query.from(nativeSQL.from(table)).select({ 'group alias': group, 'window alias': measure }).groupby(group);
    const [window, label] = await queryFieldInfo(mc, [
      { table, column: measure, stats: ['count', 'nulls', 'min', 'max'] },
      { table, column: group, stats: ['count', 'distinct'] }
    ], { query });
    expect(window.column).toBe(measure);
    expect(window).toMatchObject({ type: 'number', count: 1, nulls: 1, min: 3, max: 3 });
    expect(label.column).toBe(group);
    expect(label).toMatchObject({ type: 'string', count: 3, distinct: 2 });
  });

  it('does not fabricate metadata for invalid fields or descriptor associations', async () => {
    await expect(queryFieldInfo(mc, [{ table, column: nativeSQL.column('missing') }])).rejects.toThrow();
    const first = nativeSQL.column('x value');
    const sameSQL = nativeSQL.column('x value');
    const query = nativeSQL.Query.from(nativeSQL.from(table)).select({ value: first });
    await expect(queryFieldInfo(mc, [{ table, column: sameSQL }], { query })).rejects.toThrow('named projection');
  });

  it('describes expanded list elements and summarizes their output rows', async () => {
    const table = ['metadata schema', 'lists'];
    const column = nativeSQL.unnest('items');
    const [info] = await queryFieldInfo(mc, [{ table, column, stats: ['count', 'nulls', 'min', 'max'] }]);
    expect(info.column).toBe(column);
    expect(info).toMatchObject({ sqlType: 'INTEGER', type: 'number', count: 2, nulls: 1, min: 1, max: 3 });
    const empty = nativeSQL.Query.from(nativeSQL.from(table)).select('*').where(nativeSQL.literal(false));
    const [zero] = await queryFieldInfo(mc, [{ table: empty, column, stats: ['count', 'nulls', 'min', 'max'] }]);
    expect(zero).toMatchObject({ sqlType: 'INTEGER', type: 'number', count: 0, nulls: 0, min: null, max: null });
  });

  it('associates descriptor outputs by original projection position despite duplicate aliases', async () => {
    const first = nativeSQL.literal(1);
    const second = nativeSQL.literal('second');
    const source = nativeSQL.Query.from(nativeSQL.from(table));
    const alias = nativeSQL.native.identifier('value', true).identifier;
    const query = new nativeSQL.Query(nativeSQL.native.select([
      nativeSQL.native.alias(first, alias), nativeSQL.native.alias(second, alias)
    ], { from: nativeSQL.inspectSelect(source).from }));
    const info = await queryFieldInfo(mc, [{ table, column: first }, { table, column: second }], { query });
    expect(info.map(({ type }) => type)).toEqual(['number', 'string']);
    expect(info[0].column).toBe(first);
    expect(info[1].column).toBe(second);
  });
});

describe('native Arrow metadata', () => {
  it('reads types and nullability from a zero-row result schema without DESCRIBE', async () => {
    const schema = tableFromArrays({ value: [], label: [], day: [], items: [] }, {
      types: { value: float64(), label: utf8(), day: dateDay(), items: list(float64()) }
    });
    schema.schema.fields[0].nullable = false;
    schema.schema.fields[1].metadata = new Map([['mosaic.sqlType', 'text']]);
    const sqlContext = new SqlContext({ backend: 'postgres', targetDialect: nativeSQL.Dialect.PostgreSQL });
    const calls: string[] = [];
    const mc = {
      sqlContext,
      query: async (query: nativeSQL.Query) => {
        calls.push(nativeSQL.compile([query], sqlContext.execution)[0]);
        return schema;
      }
    } as unknown as Coordinator;
    const info = await queryFieldInfo(mc, [{ table: 'empty table', column: '*' }], {});
    expect(info.map(({ column, type, sqlType, nullable }) => ({ column, type, sqlType, nullable }))).toEqual([
      { column: 'value', type: 'number', sqlType: 'DOUBLE', nullable: false },
      { column: 'label', type: 'string', sqlType: 'text', nullable: true },
      { column: 'day', type: 'date', sqlType: 'DATE', nullable: true },
      { column: 'items', type: 'array', sqlType: 'LIST', nullable: true }
    ]);
    expect(calls).toHaveLength(1);
    expect(calls[0]).toContain('LIMIT 0');
    expect(calls[0]).not.toMatch(/DESC|GROUP BY ALL/);
  });
});
