import { DuckDB } from '@uwdata/mosaic-duckdb';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import * as sql from '../src/native/index.js';
import { stubParam } from './util/stub-param.js';

const db = new DuckDB(':memory:', {}, '');
const context = sql.createExecutionContext();
const execute = (query: sql.SqlRoot) => db.query(sql.compile([query], context)[0]);
beforeAll(() => db.exec(`
  CREATE SCHEMA "collection schema";
  CREATE TABLE "collection schema"."collection rows"(x INTEGER,y INTEGER,label VARCHAR);
  INSERT INTO "collection schema"."collection rows" VALUES (1,2,'a'),(3,4,'b');
`));
afterAll(() => db.close());

describe('native collections', () => {
  it('preserves list indexing, omitted bounds, NULLs and empty arrays', async () => {
    const values = sql.list([1, 2, 3, 4]);
    const [row] = await execute(sql.Query.select({
      first: sql.subscript(values, 1), zero: sql.subscript(values, 0),
      last: sql.subscript(values, -1), missing: sql.subscript(values, 5),
      odds: sql.slice(values, undefined, undefined, 2), reverse: sql.slice(values, undefined, undefined, -1),
      tail: sql.slice(values, 3), explicitEnd: sql.slice(values, undefined, -1, -1),
      empty: sql.slice(values, 3, 1), nullIndex: sql.subscript(values, null),
      emptyList: sql.list([]), contains: sql.listContains([1, null], 1),
      nullContains: sql.listContains([1, null], null),
      all: sql.listHasAll([1, null], [null]), any: sql.listHasAny([1, null], [null])
    }));
    expect(row).toEqual({ first: 1, zero: null, last: 4, missing: null,
      odds: [1, 3], reverse: [4, 3, 2, 1], tail: [3, 4], explicitEnd: [4], empty: [], nullIndex: null,
      emptyList: [], contains: true, nullContains: null, all: true, any: false });
  });

  it('keeps recursive UNNEST options structured and resolves depth bindings at submission', async () => {
    const depth = stubParam(1);
    const nested = sql.list([sql.list([1, 2]), sql.list([]), sql.list([3])]);
    const expression = sql.unnest(nested, { recursive: false, max_depth: depth });
    const query = sql.Query.select({ item: expression });
    expect(await execute(query)).toEqual([{ item: [1, 2] }, { item: [] }, { item: [3] }]);
    depth.value = 2;
    expect(await execute(query)).toEqual([{ item: 1 }, { item: 2 }, { item: 3 }]);
    expect(await execute(sql.Query.select({ item: sql.unnest(sql.list([])) }))).toEqual([]);
    expect(sql.params(expression)).toEqual([depth]);
  });

  it('preserves canonical operands named expression in unaliased projections', async () => {
    const expression = sql.listContains([1, 2], 1);
    const query = sql.Query.select(expression);
    expect(sql.selectEntries(query)[0].expr).toBe(expression);
    expect(Object.values((await execute(query))[0])).toEqual([true]);
  });

  it('preserves qualified wildcard selectors, replacements and live field identities', async () => {
    const path = ['collection schema', 'collection rows'];
    const fieldName = stubParam('x');
    const field = sql.column(fieldName, path);
    const wildcard = sql.star(path, {
      exclude: [sql.column('y', path)], replace: { x: sql.add(field, 10) },
      rename: [[sql.column('label', path), 'renamed label']]
    });
    const query = sql.Query.from(sql.from(path, 'source')).select(wildcard).orderby('x');
    expect(await execute(query)).toEqual([{ x: 11, 'renamed label': 'a' }, { x: 13, 'renamed label': 'b' }]);
    expect(sql.fields(wildcard).map(({ column, table }) => [table, column])).toEqual([
      ['collection schema.collection rows', '*'], ['collection schema.collection rows', 'x']
    ]);
    const clone = sql.cloneExpression(query);
    fieldName.value = 'y';
    expect(await execute(clone)).toEqual([{ x: 12, 'renamed label': 'a' }, { x: 14, 'renamed label': 'b' }]);
    expect(sql.params(clone)).toEqual([fieldName]);
    expect(sql.rootExpression(wildcard)).toBe(wildcard);
  });

  it('keeps lambda parameters local and COLUMNS selectors separate from free field dependencies', async () => {
    const selector = sql.lambda('name', name => sql.prefix(name, 'x'));
    expect(sql.fields(selector)).toEqual([]);
    const query = sql.Query.from(sql.from(['collection schema', 'collection rows'])).select(sql.columns(selector)).orderby('x');
    expect(await execute(query)).toEqual([{ x: 1 }, { x: 3 }]);
    expect(sql.fields(sql.columns(selector)).map(field => field.column)).toEqual(['*']);
    expect(sql.fields(sql.columns(['x', 'label'])).map(field => field.column)).toEqual(['x', 'label']);
    const free = sql.column('y', 'source');
    const body = sql.lambda('value', value => sql.add(value, free));
    expect(sql.fields(body)).toEqual([{ node: free, column: 'y', table: 'source' }]);
    expect(sql.hasColumnExpansion(query)).toBe(true);
  });

  it('executes quantified comparisons and canonical GROUP/ORDER BY ALL', async () => {
    const source = sql.Query.from(sql.from(['collection schema', 'collection rows'])).select('x');
    const empty = source.clone().where(sql.literal(false));
    expect(await execute(sql.Query.select({
      any: sql.compareAny(1, '=', source), all: sql.compareAll(5, '>', source),
      emptyAny: sql.compareAny(1, '=', empty), emptyAll: sql.compareAll(1, '=', empty)
    }))).toEqual([{ any: true, all: true, emptyAny: false, emptyAll: true }]);
    const grouped = sql.Query.from(sql.from(['collection schema', 'collection rows']))
      .select({ label: 'label', value: sql.sum('x') }).groupby(sql.all()).orderby(sql.all());
    expect((await execute(grouped)).map(row => [row.label, Number(row.value)])).toEqual([['a', 1], ['b', 3]]);
    expect(() => grouped.clone().groupby('label')).toThrow(/ALL/);
    const postgres = sql.createExecutionContext({ targetDialect: sql.Dialect.PostgreSQL });
    for (const expression of [sql.columns('x'), sql.star(undefined, { exclude: ['x'] }), sql.listContains([1, null], null), sql.slice(sql.list([1, 2]), 1, 2, 2)]) {
      expect(() => sql.compile([sql.Query.select(expression)], postgres), Object.keys(expression)[0]).toThrow(/unsupported|schema|slice|array|NULL|star|COLUMNS/i);
    }
  });
});
