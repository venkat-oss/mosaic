import { DuckDB } from '@uwdata/mosaic-duckdb';
import * as sql from '@uwdata/mosaic-sql/native';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { Coordinator } from '../src/Coordinator.js';
import { NodeConnector } from '../src/connectors/NodeConnector.js';
import { NativeSqlContext } from '../src/native-sql.js';
import { nativeBaseExpression, nativeBaseTable, nativeTablePath } from '../src/preagg/lineage.js';
import { nativeSubqueryPushdown } from '../src/preagg/subquery-pushdown.js';

const key = new sql.StructuralKeyScope();
const db = new DuckDB();
const connection = NodeConnector.make(db);

beforeAll(async () => {
  await db.exec('CREATE TABLE native_lineage AS SELECT 1 AS x, 2 AS a, 3 AS b, 4 AS c');
  await db.exec('CREATE TABLE native_other AS SELECT 5 AS x');
});
afterAll(() => db.close());

function table(query: sql.Query): string[] | null {
  const source = nativeBaseTable(query);
  return source && nativeTablePath(source);
}

describe('native preaggregation lineage', () => {
  it('retains CTE scope, shadowing, schema qualifiers and positional sets', () => {
    expect(table(sql.Query.from(sql.tableRef('main', 'native_lineage')!).select('x'))).toEqual(['main', 'native_lineage']);
    const shadow = sql.Query.with({ native_lineage: sql.Query.from('native_other').select('x') }).from('NATIVE_LINEAGE').select('x');
    expect(table(shadow)).toEqual(['native_other']);
    const self = sql.Query.with({ native_lineage: sql.Query.from('native_lineage').select('x') }).from('native_lineage').select('x');
    expect(table(self)).toEqual(['native_lineage']);
    const q = sql.Query.from(sql.Query.unionAll(
      sql.Query.from('native_lineage').select({ v: 'x' }), sql.Query.from('native_lineage').select({ other: 'x' })
    )).select('v');
    expect(table(q)).toEqual(['native_lineage']);
    expect(key.key(nativeBaseExpression(q, sql.column('v'))!)).toBe(key.key(sql.column('x')));
    const mismatched = sql.Query.from(sql.Query.unionAll(
      sql.Query.from('native_lineage').select({ v: 'x' }), sql.Query.from('native_lineage').select({ v: 'a' })
    )).select('v');
    expect(nativeBaseExpression(mismatched, sql.column('v'))).toBeUndefined();
    expect(table(sql.Query.from(sql.join('native_lineage', 'native_other', { using: ['x'] })).select('x'))).toBeNull();
  });

  it('resolves derived expressions and native star modifiers without crossing scalar scopes', () => {
    const star = sql.native.star();
    star.star.except = [sql.native.identifier('a', true).identifier];
    star.star.replace = [sql.native.alias(sql.mul('b', 2), sql.native.identifier('b', true).identifier).alias];
    star.star.rename = [[sql.native.identifier('c', true).identifier, sql.native.identifier('d', true).identifier]];
    const relation = sql.Query.from('native_lineage').select(star, { upper: sql.add('x', 1) });
    const query = sql.Query.from(relation).select('d');
    expect(key.key(nativeBaseExpression(query, sql.column('d'))!)).toBe(key.key(sql.column('c')));
    expect(key.key(nativeBaseExpression(query, sql.column('b'))!)).toBe(key.key(sql.mul('b', 2)));
    expect(nativeBaseExpression(query, sql.column('a'))).toBeUndefined();
    expect(key.key(nativeBaseExpression(query, sql.column('upper'))!)).toBe(key.key(sql.add('x', 1)));
    const aggregate = sql.Query.from(sql.Query.from('native_lineage').select({ n: sql.count() })).select('n');
    expect(nativeBaseExpression(aggregate, sql.column('n'))).toBeUndefined();
    const window = sql.Query.from(sql.Query.from('native_lineage').select({ n: sql.sum('x').window() })).select('n');
    expect(nativeBaseExpression(window, sql.column('n'))).toBeUndefined();
    expect(nativeBaseExpression(query, sql.positionalRef(1))).toBeUndefined();
  });

  it('pushes grouping columns through nested CTEs and positional set operands', async () => {
    const source = sql.Query.from('native_lineage').select('x', 'a', 'b');
    const set = sql.Query.unionAll(sql.Query.from('r').select({ v: 'x' }), sql.Query.from('r').select({ other: 'b' }));
    const query = sql.Query.with({ r: source, s: set }).from('s').select({ measure: sql.sum('v') });
    expect(nativeSubqueryPushdown(query, sql.tableRef('native_lineage')!, ['c'])).toBe(true);
    const native = new NativeSqlContext();
    const coordinator = new Coordinator(await connection, { native, logger: null, consolidate: false });
    try {
      const rows = await coordinator.query(query);
      expect(Array.from(rows)).toEqual([{ measure: 4, c: 4 }]);
    } finally {
      coordinator.clear();
    }
  });

  it('pads non-source set branches with NULL while retaining positional output aliases', async () => {
    const query = sql.Query.unionAll(
      sql.Query.from('native_lineage').select({ value: 'x' }),
      sql.Query.from('native_other').select({ different: 'x' })
    );
    expect(nativeSubqueryPushdown(query, sql.tableRef('native_lineage')!, ['a'])).toBe(true);
    const coordinator = new Coordinator(await connection, { native: new NativeSqlContext(), logger: null, consolidate: false });
    try {
      expect(Array.from(await coordinator.query(query))).toEqual([{ value: 1, a: 2 }, { value: 5, a: null }]);
    } finally {
      coordinator.clear();
    }
  });

  it('rejects positional expansion and ambiguous self joins instead of changing their meaning', () => {
    const expanded = sql.Query.from(sql.Query.unionAll(
      sql.Query.from('native_lineage').select({ value: 'x' }), sql.Query.from('native_lineage').select('*')
    )).select({ measure: sql.sum('value') });
    expect(nativeSubqueryPushdown(expanded, sql.tableRef('native_lineage')!, ['a'])).toBe(false);
    const joined = sql.Query.from(sql.join(sql.from('native_lineage', 'l'), sql.from('native_lineage', 'r'), { using: ['x'] }))
      .select({ n: sql.count() });
    expect(nativeSubqueryPushdown(joined, sql.tableRef('native_lineage')!, ['a'])).toBe(false);
  });
});
