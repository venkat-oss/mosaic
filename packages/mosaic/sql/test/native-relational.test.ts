import { DuckDB } from '@uwdata/mosaic-duckdb';
import { describe, expect, it } from 'vitest';
import {
  asLiteral, asof_join, BindingScope, column, compile, compileResolved,
  createExecutionContext, cross_join, cte, deepClone, Dialect, eq, fields,
  filterPushdown, from, gt, hasColumnExpansion, isAggregateExpression,
  isResultQuery, join, literal, native, params, positional_join, positionalRef,
  Query, resolvePositional, rewrite, sample, selectEntries, snapshotAll,
  StructuralKeyScope, subquery, sum, tableRef, values, walk
} from '../src/native/index.js';
import { parseExpression } from '../src/native/ingress.js';
import { stubParam } from './util/stub-param.js';

const context = createExecutionContext({ backend: 'native-relational-test' });

describe('native relational authoring', () => {
  it('retains mutable child queries embedded before their projections are authored', async () => {
    const child = Query.from('data');
    const originalRoot = child.expression;
    const outer = Query.from({ d: child }).select({ value: column('x', 'd') });
    const common = Query.from('c').with(cte('c', child, false));
    const description = child.describe().clone();
    child.select({ x: 'y' });
    expect(child.expression).toBe(originalRoot);
    const clone = child.clone().setSelect({ x: 'x' });
    const scalar = Query.select({ value: literal(1) });
    const scalarOuter = Query.select({ value: scalar });
    scalar.setSelect({ value: literal(2) });
    const db = new DuckDB(':memory:', {}, '');
    try {
      await db.exec('CREATE TABLE data (x INTEGER, y INTEGER); INSERT INTO data VALUES (1,10),(2,20)');
      expect(await db.query(compile([outer], context)[0])).toEqual([{ value: 10 }, { value: 20 }]);
      expect(await db.query(compile([common], context)[0])).toEqual([{ x: 10 }, { x: 20 }]);
      expect(await db.query(compile([clone], context)[0])).toEqual([{ x: 1 }, { x: 2 }]);
      expect(await db.query(compile([scalarOuter], context)[0])).toEqual([{ value: 2 }]);
      expect((await db.query(compile([description], context)[0])).map(row => row.column_name)).toEqual(['x', 'y']);
    } finally {
      db.close();
    }
  });

  it('executes join kinds with their original operands and conditions', async () => {
    const left = from(values([[1], [2]]), 'l', undefined, ['x']);
    const right = from(values([[2], [3]]), 'r', undefined, ['x']);
    const db = new DuckDB(':memory:', {}, '');
    try {
      const rows = async (source: ReturnType<typeof join>) => db.query(compile([
        Query.from(source).select({ value: column('x', 'l') }).orderby('value')
      ], context)[0]);
      expect(await rows(join(left, right, { using: ['x'] }))).toEqual([{ value: 2 }]);
      expect(await rows(join(left, right, { type: 'LEFT', on: eq(column('x', 'l'), column('x', 'r')) })))
        .toEqual([{ value: 1 }, { value: 2 }]);
      expect(await rows(join(left, right, { type: 'SEMI', using: ['x'] }))).toEqual([{ value: 2 }]);
      expect(await rows(join(left, right, { type: 'ANTI', using: ['x'] }))).toEqual([{ value: 1 }]);
      expect(await rows(join(left, right, { type: 'RIGHT', using: ['x'] }))).toEqual([{ value: 2 }, { value: null }]);
      expect(await rows(join(left, right, { type: 'FULL', using: ['x'] }))).toEqual([{ value: 1 }, { value: 2 }, { value: null }]);
      expect(await rows(join(left, right))).toEqual([{ value: 2 }]);
      expect(await rows(join(left, right, { type: 'SEMI' }))).toEqual([{ value: 2 }]);
      expect(await rows(join(left, right, { type: 'ANTI' }))).toEqual([{ value: 1 }]);
      expect(await rows(cross_join(left, right))).toEqual([{ value: 1 }, { value: 1 }, { value: 2 }, { value: 2 }]);
      expect(await rows(positional_join(left, right))).toEqual([{ value: 1 }, { value: 2 }]);
      expect(await rows(asof_join(left, right, { on: native.binary('gte', column('x', 'l'), column('x', 'r')) })))
        .toEqual([{ value: 2 }]);
      expect(await rows(asof_join(left, right, { type: 'FULL', using: ['x'] }))).toEqual([{ value: 1 }, { value: 2 }, { value: null }]);
      expect(await rows(asof_join(left, right, { type: 'SEMI', using: ['x'] }))).toEqual([{ value: 2 }]);
      expect(await rows(asof_join(left, right, { type: 'ANTI', using: ['x'] }))).toEqual([{ value: 1 }]);
      expect(() => join(left, right, { on: literal(true), using: ['x'] })).toThrow(/Only one/);
      expect(() => asof_join(left, right, {})).toThrow(/requires a join condition/);
    } finally {
      db.close();
    }
  });

  it('executes VALUES, set operations, CTE column aliases and common modifiers', async () => {
    const first = Query.from(from(values([[1, 'a'], [2, 'b']]), 'v', undefined, ['id', 'label'])).select('id', 'label');
    const second = Query.select({ id: literal(2), label: literal('b') });
    const merged = Query.unionAll(first, second).orderby('id').offset(1).limit(2);
    const byName = Query.unionAllByName(Query.select({ a: literal(1) }), Query.select({ b: literal(2) }));
    const common = Query.from('quoted cte').with(cte('quoted cte', first, true, ['number', 'text'])).orderby('number');
    const single = Query.union(first).limit(1);
    const late = Query.from('source').select('id');
    const lateSet = Query.unionAll(Query.select({ id: literal(0) }), late).orderby('id');
    late.with({ source: Query.select({ id: literal(3) }) });
    const db = new DuckDB(':memory:', {}, '');
    try {
      expect(await db.query(compile([merged], context)[0])).toEqual([{ id: 2, label: 'b' }, { id: 2, label: 'b' }]);
      expect(await db.query(compile([Query.intersect(first, second)], context)[0])).toEqual([{ id: 2, label: 'b' }]);
      expect(await db.query(compile([Query.except(first, second)], context)[0])).toEqual([{ id: 1, label: 'a' }]);
      expect(await db.query(compile([byName], context)[0])).toEqual([{ a: 1, b: null }, { a: null, b: 2 }]);
      expect(await db.query(compile([common], context)[0])).toEqual([{ number: 1, text: 'a' }, { number: 2, text: 'b' }]);
      expect(await db.query(compile([single], context)[0])).toHaveLength(1);
      expect(await db.query(compile([first], context)[0])).toHaveLength(2);
      expect(await db.query(compile([lateSet], context)[0])).toEqual([{ id: 0 }, { id: 3 }]);
      expect(await db.query(compile([Query.union(first.clone().orderby('id').limit(1), second).orderby('id')], context)[0]))
        .toEqual([{ id: 1, label: 'a' }, { id: 2, label: 'b' }]);
      expect(isResultQuery(values([[1]]))).toBe(true);
      expect(isResultQuery(merged)).toBe(true);
      expect(isResultQuery(sum('id'))).toBe(false);
      const postgres = createExecutionContext({ targetDialect: Dialect.PostgreSQL });
      expect(() => compile([byName], postgres)).toThrow();
    } finally {
      db.close();
    }
  });

  it('preserves distinct, positions, sampling and pivot clone behavior', async () => {
    const input = from(values([['g', 'a', 2], ['g', 'b', 3], ['h', 'a', 4]]), 'v', undefined, ['g', 'k', 'n']);
    const pivot = Query.pivot(input).on('k').in('a').using({ total: sum('n') }).groupby('g').orderby('g');
    const clone = pivot.clone().in('b');
    const distinct = Query.from(input).select('g').distinct().orderby(positionalRef(1));
    const distinctOn = Query.from(input).select('g', 'n').distinctOn('g').orderby('g', 'n');
    const sampled = Query.from(input).sample(2, 'reservoir', 42);
    const toggled = Query.from(input).select('g').distinctOn('g').distinct(false).orderby('g');
    expect(() => Query.pivot(input).on('k').using({})).toThrow(/at least one aggregate expression/);
    expect(() => Query.pivot(input).on('k').using({ total: null })).toThrow(/at least one aggregate expression/);
    const db = new DuckDB(':memory:', {}, '');
    try {
      expect(await db.query(compile([pivot], context)[0])).toEqual([{ g: 'g', a_total: '2' }, { g: 'h', a_total: '4' }]);
      expect(await db.query(compile([clone], context)[0])).toEqual([{ g: 'g', a_total: '2', b_total: '3' }, { g: 'h', a_total: '4', b_total: null }]);
      expect(await db.query(compile([distinct], context)[0])).toEqual([{ g: 'g' }, { g: 'h' }]);
      expect(await db.query(compile([distinctOn], context)[0])).toEqual([{ g: 'g', n: 2 }, { g: 'h', n: 4 }]);
      expect(await db.query(compile([toggled], context)[0])).toEqual([{ g: 'g' }, { g: 'h' }]);
      expect(await db.query(compile([toggled.clone().setDistinctOn()], context)[0])).toEqual([{ g: 'g' }, { g: 'g' }, { g: 'h' }]);
      expect(await db.query(compile([toggled.clone().distinct().setDistinctOn()], context)[0])).toEqual([{ g: 'g' }, { g: 'h' }]);
      expect(await db.query(compile([sampled], context)[0])).toHaveLength(2);
      expect(await db.query(compile([Query.from(input).limitPercent(100)], context)[0])).toHaveLength(3);
      const percent = Query.from(from(values([[1], [2]]), 'v', sample(100, true, 'bernoulli', 42), ['x']));
      expect(await db.query(compile([percent], context)[0])).toHaveLength(2);
      const postgres = createExecutionContext({ targetDialect: Dialect.PostgreSQL });
      expect(() => compile([sampled], postgres)).toThrow();
      expect(() => compile([Query.from(input).limitPercent(100)], postgres)).toThrow();
      expect(() => compile([pivot], postgres)).toThrow();
      expect(() => compile([Query.select(positionalRef(1)).from(input)], postgres)).toThrow();
    } finally {
      db.close();
    }
  });

  it('composes colliding bindings without freezing reusable child queries', async () => {
    const first = stubParam(1);
    const second = stubParam(2);
    const left = asLiteral(first);
    const right = asLiteral(second);
    if (!('parameter' in left) || !('parameter' in right)) throw new Error('Expected native binding slots.');
    right.parameter.name = left.parameter.name;
    const child = Query.select({ value: right });
    const combined = Query.unionAll(Query.select({ value: left }), child);
    child.setSelect({ value: native.binary('add', right, literal(10)) });
    second.value = 3;
    expect(params(combined)).toEqual([first, second]);
    const db = new DuckDB(':memory:', {}, '');
    try {
      expect(await db.query(compile([combined], context)[0])).toEqual([{ value: 1 }, { value: 13 }]);
    } finally {
      db.close();
    }
  });
});

describe('native relational inspection and rewriting', () => {
  it('retains original-node identity and bindings through walks, clones and rewrites', () => {
    const value = stubParam(1);
    const field = column('x');
    const query = Query.from('data').select({ x: field }).where(gt(field, asLiteral(value)));
    const visited: typeof field[] = [];
    walk(query, node => { visited.push(node); });
    expect(visited).toContain(field);
    expect(visited.filter(node => node === field)).toHaveLength(1);
    const clone = deepClone(query);
    expect(fields(clone)[0].node).not.toBe(field);
    expect(params(clone)).toEqual([value]);
    const replacement = column('y');
    const changed = rewrite(query, new Map([[field, replacement]]));
    expect(fields(changed)[0].node).toBe(replacement);
    expect(fields(query)[0].node).toBe(field);
    expect(hasColumnExpansion(literal('*'))).toBe(false);
    expect(hasColumnExpansion(column('*'))).toBe(true);
    expect(fields(positionalRef(1))[0].column).toBe('*');
    expect(isAggregateExpression(sum('x'))).toBe(true);
    expect(isAggregateExpression(subquery(Query.select({ total: sum('x') }).from('data')))).toBe(false);
    expect(isAggregateExpression(parseExpression('sum(x) OVER ()'))).toBe(false);
    expect(isAggregateExpression(parseExpression('sum(sum(x)) OVER ()'))).toBe(true);
    expect(isAggregateExpression(parseExpression('lag(sum(x)) OVER ()'))).toBe(true);
    expect(isAggregateExpression(parseExpression('sum(x) OVER (ORDER BY sum(y))'))).toBe(true);
    expect(isAggregateExpression(parseExpression('lag((SELECT sum(x) FROM data)) OVER ()'))).toBe(false);
    expect(resolvePositional(literal(1), selectEntries(query))?.expr).toBe(field);
    expect(resolvePositional(positionalRef(1), selectEntries(query))?.alias).toBe('x');
  });

  it('keys binding semantics without reading values and compiles one resolved snapshot', () => {
    let reads = 0;
    const parameter = { get value() { return ++reads; }, addEventListener() {}, removeEventListener() {} };
    const scalar = asLiteral(parameter);
    const identifier = column(parameter);
    const keyScope = new StructuralKeyScope();
    const query = Query.select({ value: scalar });
    const bare = Query.select(identifier);
    reads = 0;
    expect(keyScope.key(query)).toBe(keyScope.key(deepClone(query)));
    expect(keyScope.key(scalar)).not.toBe(keyScope.key(identifier));
    expect(keyScope.key(column(parameter, 'a'))).not.toBe(keyScope.key(column(parameter, 'b')));
    const custom = (value: number) => new BindingScope().bind({ kind: 'deferred', parameters: [parameter], resolve: () => literal(value) });
    expect(keyScope.key(custom(1))).not.toBe(keyScope.key(custom(2)));
    expect(selectEntries(bare)[0].alias).toBeUndefined();
    expect(reads).toBe(0);
    expect(() => compileResolved([query.expression], context)).toThrow(/Unresolved/);
    expect(reads).toBe(0);
    const resolved = snapshotAll([query, query.clone()]);
    expect(reads).toBe(1);
    expect(compileResolved(resolved, context)).toEqual(['SELECT 1 AS "value"', 'SELECT 1 AS "value"']);
    expect(reads).toBe(1);
    keyScope.reset();
    expect(keyScope.key(query)).toBe(keyScope.key(deepClone(query)));
  });

  it('pushes filters into relational sources while respecting CTE and scalar boundaries', async () => {
    const shared = Query.from('data').select('x');
    const ordinary = Query.from({ d: shared }).select('x');
    const shadowed = Query.from({ d: shared }).select('x').with({ data: Query.select({ x: literal(99) }) });
    const set = Query.unionAll(ordinary, shadowed).orderby('x');
    const filteredSet = filterPushdown(set, 'data', gt('x', 1));
    const selfNamed = Query.from('data').with({ data: Query.from('data').select('x') }).select('x').orderby('x');
    const scalar = Query.select({ x: 'x', all: Query.from('data').select({ total: sum('x') }) }).from('data').orderby('x');
    const db = new DuckDB(':memory:', {}, '');
    try {
      await db.exec('CREATE TABLE data (x INTEGER); INSERT INTO data VALUES (0),(1),(2),(3)');
      expect(await db.query(compile([filteredSet], context)[0])).toEqual([{ x: 2 }, { x: 3 }, { x: 99 }]);
      expect(await db.query(compile([filterPushdown(selfNamed, 'data', gt('x', 1))], context)[0])).toEqual([{ x: 2 }, { x: 3 }]);
      expect(await db.query(compile([filterPushdown(scalar, 'data', gt('x', 1))], context)[0])).toEqual([{ x: 2, all: '6' }, { x: 3, all: '6' }]);
      expect(await db.query(compile([set], context)[0])).toHaveLength(5);
    } finally {
      db.close();
    }
  });

  it('preserves qualified static and live columns when replacing base-table sources', async () => {
    const source = tableRef(['s', 'data'])!;
    const name = stubParam('x');
    const field = column(name, source);
    const query = Query.from(source).select({ value: field }).orderby('value');
    const filtered = filterPushdown(query, source, gt(column('x', source), 1));
    const correlated = Query.from(source).select({
      value: Query.select({ x: column('x', source) }),
      all: Query.from(source).select({ total: sum(column('x', source)) })
    });
    const db = new DuckDB(':memory:', {}, '');
    try {
      await db.exec('CREATE SCHEMA s; CREATE TABLE s.data (x INTEGER, y INTEGER); INSERT INTO s.data VALUES (1,10),(2,20)');
      expect(await db.query(compile([query], context)[0])).toEqual([{ value: 1 }, { value: 2 }]);
      expect(await db.query(compile([filtered], context)[0])).toEqual([{ value: 2 }]);
      expect(await db.query(compile([filterPushdown(correlated, source, gt(column('x', source), 1))], context)[0]))
        .toEqual([{ value: 2, all: '3' }]);
      name.value = 'y';
      expect(await db.query(compile([filtered], context)[0])).toEqual([{ value: 20 }]);
      expect(params(filtered)).toEqual([name]);
      expect(fields(query)[0]).toMatchObject({ column: 'y', table: 's.data' });
      expect(fields(filtered)[0]).toMatchObject({ column: 'y', table: 'data' });
    } finally {
      db.close();
    }
  });
});
