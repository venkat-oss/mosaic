import { DuckDB } from '@uwdata/mosaic-duckdb';
import * as sql from '@uwdata/mosaic-sql/native';
import { afterAll, beforeAll, describe, expect, it, vi } from 'vitest';
import { Coordinator } from '../src/Coordinator.js';
import { NodeConnector } from '../src/connectors/NodeConnector.js';
import { NativeSqlContext } from '../src/native-sql.js';
import { Param } from '../src/Param.js';
import { nativeBaseExpression, nativeBaseTable, nativeStarExpression, nativeTablePath } from '../src/preagg/lineage.js';
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

  it('retains qualified star modifier expressions through lineage and execution', async () => {
    const name = 'source rows';
    const original = sql.column('c', name);
    const replacement = sql.mul(sql.column('b', name), 2);
    const relation = sql.Query.from(sql.from('native_lineage', name)).select(sql.star(name, {
      exclude: [sql.column('a', name)], replace: { b: replacement }, rename: [[original, 'd']]
    }));
    const query = sql.Query.from(relation).select('x', 'b', 'd');
    expect(nativeBaseExpression(query, sql.column('d'))).toBe(original);
    expect(nativeBaseExpression(query, sql.column('b'))).toBe(replacement);
    expect(nativeBaseExpression(query, sql.column('a'))).toBeUndefined();
    expect(nativeBaseExpression(query, sql.column('c'))).toBeUndefined();
    expect(sql.columnParts(nativeBaseExpression(query, sql.column('x'))!)).toEqual([name, 'x']);
    const coordinator = new Coordinator(await connection, { native: new NativeSqlContext(), logger: null, consolidate: false });
    try {
      expect(Array.from(await coordinator.query(query))).toEqual([{ x: 1, b: 6, d: 4 }]);
    } finally { coordinator.clear(); }
  });

  it('matches star modifiers against complete relation paths and declines ambiguous sources', () => {
    const left = ['s1', 't'];
    const right = ['s2', 't'];
    const original = sql.column('c', right);
    const relation = sql.Query.from(sql.tableRef(left)!).select(sql.star(null, {
      exclude: [sql.column('a', right)], rename: [[original, 'd']]
    }));
    expect(sql.columnParts(nativeStarExpression(relation, 'a', [left])!)).toEqual(['a']);
    expect(nativeStarExpression(relation, 'a', [right])).toBeUndefined();
    expect(nativeStarExpression(relation, 'd', [left])).toBeUndefined();
    expect(nativeStarExpression(relation, 'd', [right])).toBe(original);
    expect(nativeStarExpression(relation, 'c', [right])).toBeUndefined();
    const qualified = sql.Query.from(sql.tableRef(left)!).select(sql.star(left));
    expect(sql.columnParts(nativeStarExpression(qualified, 'a')!)).toEqual([...left, 'a']);
    expect(nativeStarExpression(qualified, 'a', [right])).toBeUndefined();
    const joined = sql.Query.from(sql.join(sql.from('native_lineage', 'l'), sql.from('native_lineage', 'r'), { using: ['x'] }))
      .select(sql.star());
    expect(nativeStarExpression(joined, 'a')).toBeUndefined();
    expect(nativeBaseExpression(sql.Query.from(joined).select('a'), sql.column('a'))).toBeUndefined();
  });

  it('keeps live renamed field identity without reading bindings during lineage analysis', async () => {
    const parameter = Param.value('c');
    const read = vi.spyOn(parameter, 'value', 'get');
    const original = sql.column(parameter, 'rows');
    const relation = sql.Query.from(sql.from('native_lineage', 'rows'))
      .select(sql.star('rows', { rename: [[original, 'renamed']] }));
    const query = sql.Query.from(relation).select('renamed');
    expect(nativeStarExpression(relation, 'renamed')).toBe(original);
    expect(nativeBaseExpression(query, sql.column('renamed'))).toBe(original);
    expect(read).not.toHaveBeenCalled();
    const coordinator = new Coordinator(await connection, { native: new NativeSqlContext(), logger: null, consolidate: false });
    try {
      expect(Array.from(await coordinator.query(query))).toEqual([{ renamed: 4 }]);
      parameter.update('a');
      expect(Array.from(await coordinator.query(query))).toEqual([{ renamed: 2 }]);
    } finally { read.mockRestore(); coordinator.clear(); }
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
