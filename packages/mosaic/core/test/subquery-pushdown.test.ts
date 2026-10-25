import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { DuckDB } from '@uwdata/mosaic-duckdb';
import * as sql from '@uwdata/mosaic-sql';
import { subqueryPushdown } from '../src/preagg/subquery-pushdown.js';
import { Coordinator } from '../src/Coordinator.js';
import { NodeConnector } from '../src/connectors/NodeConnector.js';

const db = new DuckDB();
let coordinator: Coordinator;
beforeAll(async () => {
  await db.exec(`
    CREATE TABLE data AS SELECT * FROM (VALUES
      (1,10,100,2,3,4,1,'cat',5,9),(2,20,200,12,13,14,2,'cat',7,19)
    ) t(x,y,z,a,b,c,k,category,value,other);
    CREATE TABLE other AS SELECT 10 AS x,100 AS y,1000 AS z,20 AS a,30 AS b,40 AS c,1 AS k;
    CREATE TABLE t AS SELECT 1 AS k,2 AS a,3 AS b;
    CREATE TABLE t1 AS SELECT 1 AS num1,2 AS num2;
    CREATE TABLE t2 AS SELECT 10 AS num1,20 AS num2;
    CREATE SCHEMA s1; CREATE SCHEMA s2;
    CREATE TABLE s1.t AS SELECT 1 AS k,2 AS a,3 AS b;
    CREATE TABLE s2.t AS SELECT 1 AS k,20 AS a,30 AS b;
  `);
  coordinator = new Coordinator(await NodeConnector.make(db), { logger: null, consolidate: false });
});
afterAll(() => { coordinator.clear(); db.close(); });

function push(query: sql.Query, source: string | readonly string[], columns: string[], supported = true): sql.Query {
  expect(subqueryPushdown(query, sql.tableRef(source)!, columns)).toBe(supported);
  return query;
}
const rows = async (query: sql.Query) => Array.from(await coordinator.query(query));
const names = async (query: sql.Query) => (await coordinator.query(query)).schema.fields.map(field => field.name);

describe('subqueryPushdown', () => {
  it('pushes dimensions into aggregate queries without duplicating case-insensitive columns', async () => {
    const query = sql.Query.from('data').select('category', { sum: sql.sum('value') }).groupby('category');
    expect(await rows(push(query, 'data', ['other']).orderby('other'))).toEqual([
      { category: 'cat', sum: 5, other: 9 }, { category: 'cat', sum: 7, other: 19 }
    ]);
    const existing = sql.Query.from('data').select('category', 'other', { sum: sql.sum('value') }).groupby('category', 'other');
    push(existing, 'data', ['CATEGORY', 'other']);
    expect(sql.inspectSelect(existing).group_by?.expressions).toHaveLength(2);
    expect(await names(existing)).toEqual(['category', 'other', 'sum']);
  });

  it('keeps nonaggregate and star queries ungrouped and appends only missing dimensions', async () => {
    const plain = push(sql.Query.from('data').select('x'), 'data', ['a']);
    expect(sql.inspectSelect(plain).group_by).toBeNull();
    expect(await rows(plain.orderby('x'))).toEqual([{ x: 1, a: 2 }, { x: 2, a: 12 }]);
    const star = push(sql.Query.from('data').select('*'), 'data', ['a']);
    expect(await names(star)).toEqual(['x', 'y', 'z', 'a', 'b', 'c', 'k', 'category', 'value', 'other']);
  });

  it('restores excluded and renamed columns while retaining replacement expressions', async () => {
    const query = sql.Query.from('data').select(sql.star(null, {
      exclude: ['A'], rename: { b: 'b2' }, replace: { c: sql.add('c', 1) }
    }));
    push(query, 'data', ['a', 'b', 'c', 'x']);
    expect(await names(query)).toEqual(['x', 'y', 'z', 'b2', 'c', 'k', 'category', 'value', 'other', 'a', 'b']);
    const result = await rows(query.orderby('x'));
    expect(result.map(row => [row.a, row.b, row.b2, row.c])).toEqual([[2, 3, 3, 5], [12, 13, 13, 15]]);
  });

  it('keeps COLUMNS expansion on the root and rejects hidden subquery dimensions', async () => {
    const direct = push(sql.Query.from('data').select(sql.columns('^[ab]$')), 'data', ['a']);
    expect(await names(direct)).toEqual(['a', 'b']);
    const expanded = () => sql.Query.from('data').select(sql.columns('^[xy]$'));
    push(sql.Query.from(expanded()).select('x'), 'data', ['a'], false);
    const visible = sql.Query.from('data').select(sql.columns('^[xy]$'), 'A');
    expect(await rows(push(sql.Query.from(visible).select('x'), 'data', ['a']).orderby('x')))
      .toEqual([{ x: 1, a: 2 }, { x: 2, a: 12 }]);
    push(sql.Query.from(sql.Query.unionAll(expanded(), sql.Query.from('data').select('x', 'y'))).select('x'), 'data', ['a'], false);
  });

  it('leaves other sources and scalar subquery scopes unchanged', async () => {
    const query = sql.Query.from('other').select('x', {
      total: sql.subquery(sql.Query.from('data').select({ total: sql.sum('y') }))
    });
    expect(await rows(push(query, 'data', ['c']))).toEqual([{ x: 10, total: 30 }]);
    expect(await names(push(sql.Query.from('other').select('x'), 'data', ['a']))).toEqual(['x']);
  });

  it('matches complete schema-qualified source paths', async () => {
    const query = sql.Query.from(sql.tableRef(['s1', 't'])!).select('k');
    expect(await rows(push(query, ['s1', 't'], ['a']))).toEqual([{ k: 1, a: 2 }]);
    expect(await names(push(sql.Query.from(sql.tableRef(['s2', 't'])!).select('k'), ['s1', 't'], ['a'])))
      .toEqual(['k']);
  });

  it('pushes through CTEs and sets while leaving unrelated CTE definitions intact', async () => {
    const query = sql.Query.with({
      unused: sql.Query.from('other').select('x'),
      part: sql.Query.unionAll(sql.Query.from('data').select('x'), sql.Query.from('data').select('x')),
      relay: sql.Query.from('part').select('x')
    }).from('relay').select('x');
    expect(await rows(push(query, 'data', ['c']).orderby('x', 'c'))).toEqual([
      { x: 1, c: 4 }, { x: 1, c: 4 }, { x: 2, c: 14 }, { x: 2, c: 14 }
    ]);
    const unused = sql.inspectSelect(query).with!.ctes.find(cte => cte.alias.name === 'unused')!;
    expect(sql.selectEntries(unused.this).map(entry => entry.alias)).toEqual(['x']);
  });

  it('respects source shadowing and nested CTE scopes', async () => {
    const shadowed = sql.Query.with({ data: sql.Query.from('other').select('x') }).from('data').select('x');
    expect(await rows(push(shadowed, 'data', ['c']))).toEqual([{ x: 10 }]);
    const inner = sql.Query.with({ local: sql.Query.from('data').select('x') }).from('local').select('x');
    const outer = sql.Query.with({ local: sql.Query.from('other').select('x') })
      .from(sql.from(inner, 'derived'), sql.from('local', 'outside'))
      .select({ value: sql.column('x', 'derived') });
    expect(await rows(push(outer, 'data', ['c']).orderby('value'))).toEqual([{ value: 1, c: 4 }, { value: 2, c: 14 }]);
  });

  it('pushes through filtered FROM subqueries and join inputs', async () => {
    const aggregate = sql.Query.from(sql.Query.from('data').select('x').where(sql.gt('x', 0)))
      .select({ n: sql.count() });
    expect(await rows(push(aggregate, 'data', ['c']).orderby('c'))).toEqual([{ n: 1, c: 4 }, { n: 1, c: 14 }]);
    const joined = sql.Query.from(sql.join(
      sql.from(sql.Query.from('data').select('x', 'k'), 'l'),
      sql.from(sql.Query.from('other').select('y', 'k'), 'r'), { using: ['k'] }
    )).select('x', 'y');
    expect(await rows(push(joined, 'data', ['c']))).toEqual([{ x: 1, y: 100, c: 4 }]);
  });

  it.each(['t1', 't2', 'T1'])('applies star modifier qualifier %s to its relation', async excluded => {
    const query = sql.Query.from(sql.cross_join('t1', 't2'))
      .select(sql.star(null, { exclude: [sql.column('num1', excluded)] }));
    push(query, 't1', ['num1']);
    expect((await names(query)).filter(name => name === 'num1')).toHaveLength(excluded.toLowerCase() === 't1' ? 2 : 1);
    expect(sql.selectEntries(query)).toHaveLength(excluded.toLowerCase() === 't1' ? 2 : 1);
  });

  it.each([['s1', 't'], ['s2', 't'], ['t']].map(excluded => ({ excluded })))('matches star modifier schema path $excluded', async ({ excluded }) => {
    const query = sql.Query.from(sql.cross_join(['s1', 't'], ['s2', 't']))
      .select(sql.star(null, { exclude: [sql.column('a', excluded)] }));
    push(query, ['s1', 't'], ['a']);
    expect(sql.selectEntries(query)).toHaveLength(excluded[0] === 's2' ? 1 : 2);
    if (excluded.length > 1) expect((await names(query)).filter(name => name === 'a')).toHaveLength(excluded[0] === 's1' ? 2 : 1);
  });

  it('retains implicit-alias scope and rejects ambiguous backend qualifiers', async () => {
    const excluded = sql.column('a', ['s2', 't']);
    const implicit = sql.Query.from(sql.cross_join(sql.from(sql.tableRef(['s1', 't'])!, 'T'), ['s2', 't']))
      .select(sql.star(null, { exclude: [excluded] }));
    push(implicit, ['s1', 't'], ['a']);
    expect(sql.selectEntries(implicit)).toHaveLength(1);
    const projection = sql.selectEntries(implicit)[0].expr;
    if (!('star' in projection)) throw new TypeError('Expected a wildcard projection.');
    expect(projection.star.except?.[0]).toBe(excluded);
    await expect(coordinator.query(implicit)).rejects.toThrow(/ambiguous/i);
    await expect(coordinator.query('SELECT * EXCLUDE(s2.t.a) FROM s1.t AS T CROSS JOIN s2.t'))
      .rejects.toThrow(/ambiguous/i);
    const selfJoin = () => sql.join(sql.from('t', 'x'), 't', { using: ['k'] });
    for (const alias of ['x', 't']) {
      const query = sql.Query.from(selfJoin()).select(sql.star(null, { exclude: [sql.column('a', alias)] }));
      push(query, 't', ['a']);
      expect(await names(query)).toEqual(alias === 'x' ? ['k', 'b', 'a', 'b'] : ['k', 'a', 'b', 'b']);
    }
  });

  it('rejects ambiguous self-join dimensions and accepts existing qualified grouping', async () => {
    const selfJoin = () => sql.join(sql.from('t', 'x'), 't', { using: ['k'] });
    push(sql.Query.from(selfJoin()).select(sql.star(null, { exclude: [sql.column('a', 'x'), sql.column('a', 't')] })), 't', ['a'], false);
    push(sql.Query.from(selfJoin()).select({ n: sql.count() }), 't', ['a'], false);
    push(sql.Query.from(selfJoin()).select('*', { n: sql.count() }).groupby('k'), 't', ['a'], false);
    const grouped = sql.Query.from(selfJoin()).select({ a: sql.column('a', 'x'), n: sql.count() }).groupby(sql.column('a', 'x'));
    expect(await rows(push(grouped, 't', ['a']))).toEqual([{ a: 2, n: 1 }]);
  });

  it('qualifies source dimensions absent from other-table stars or aggregate grouping', async () => {
    const star = sql.Query.from(sql.cross_join('t1', 't2')).select(sql.star('t2'));
    push(star, 't1', ['num1']);
    expect(sql.columnParts(sql.selectEntries(star).at(-1)!.expr)).toEqual(['t1', 'num1']);
    expect(await names(star)).toEqual(['num1', 'num2', 'num1']);
    const aggregate = sql.Query.from(sql.cross_join('t1', 't2')).select({ n: sql.count() }).groupby(sql.column('num1', 't2'));
    expect(await rows(push(aggregate, 't1', ['num1']))).toEqual([{ n: 1, num1: 1 }]);
  });

  it('pads non-source set branches and retains already-visible wildcard positions', async () => {
    const query = sql.Query.unionAll(sql.Query.from('data').select('x'), sql.Query.from('other').select('x'));
    expect(await rows(push(query, 'data', ['c']).orderby('x'))).toEqual([{ x: 1, c: 4 }, { x: 2, c: 14 }, { x: 10, c: null }]);
    const stars = sql.Query.unionAll(sql.Query.from('t2').select(sql.star('t2')), sql.Query.from('t1').select(sql.star('t1')));
    push(stars, 't1', ['num1']);
    expect(await names(stars)).toEqual(['num1', 'num2']);
    expect(await rows(stars)).toEqual([{ num1: 10, num2: 20 }, { num1: 1, num2: 2 }]);
  });

  it('rejects unknown wildcard positions while accepting aligned explicit outputs', () => {
    const query = (a: sql.Query, b: sql.Query, supported: boolean) =>
      push(sql.Query.unionAll(a, b), 'data', ['a'], supported);
    query(sql.Query.from('data').select('x'), sql.Query.from('data').select('*'), false);
    query(sql.Query.from('data').select('x'), sql.Query.from('other').select('*'), false);
    query(sql.Query.from('other').select('x'), sql.Query.from('data').select(sql.star('data')), false);
    query(sql.Query.from('data').select('*'), sql.Query.from('data').select('*'), true);
    query(sql.Query.from('data').select('x'), sql.Query.from('other').select('y'), true);
  });

  it('aligns pushed dimensions by position across differently named set inputs', async () => {
    const query = sql.Query.unionAll(
      sql.Query.from('data').select({ s: 'a', v: 'x' }),
      sql.Query.from('data').select('b', 'y'),
      sql.Query.from('other').select('c', 'z')
    );
    expect(await rows(push(query, 'data', ['a', 'y']).orderby('s'))).toEqual([
      { s: 2, v: 1, a: 2, y: 10 }, { s: 3, v: 10, a: 2, y: 10 },
      { s: 12, v: 2, a: 12, y: 20 }, { s: 13, v: 20, a: 12, y: 20 },
      { s: 40, v: 1000, a: null, y: null }
    ]);
  });
});
