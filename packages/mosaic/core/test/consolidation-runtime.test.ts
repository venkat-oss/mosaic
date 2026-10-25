import { DuckDB } from '@uwdata/mosaic-duckdb';
import { tableFromArrays } from '@uwdata/flechette';
import { add, asLiteral, column, count, deferred, inspectSelect, list, literal, native, Query, sql, sum, unnest } from '@uwdata/mosaic-sql';
import type { ParamLike, SqlExpression } from '@uwdata/mosaic-sql';
import { afterAll, beforeAll, describe, expect, it, vi } from 'vitest';
import { Coordinator } from '../src/Coordinator.js';
import { NodeConnector } from '../src/connectors/NodeConnector.js';
import type { ArrowQueryRequest, Connector, ConnectorQueryOptions, ExecQueryRequest } from '../src/connectors/Connector.js';
import type { ArrowIPCBytes, Cache, QueryEntry } from '../src/types.js';
import { SqlContext } from '../src/sql-context.js';
import { Param } from '../src/Param.js';
import { consolidator } from '../src/QueryConsolidator.js';
import { Priority } from '../src/QueryManager.js';
import { QueryResult } from '../src/util/query-result.js';

class RecordingConnector implements Connector {
  readonly calls: string[] = [];
  private gate?: Promise<void>;

  constructor(private readonly connector: Connector) {}

  hold(): () => void {
    let release!: () => void;
    this.gate = new Promise(resolve => { release = resolve; });
    return () => { this.gate = undefined; release(); };
  }

  query(request: ArrowQueryRequest, options?: ConnectorQueryOptions): Promise<ArrowIPCBytes>;
  query(request: ExecQueryRequest, options?: ConnectorQueryOptions): Promise<void>;
  query(request: ArrowQueryRequest | ExecQueryRequest, options?: ConnectorQueryOptions): Promise<ArrowIPCBytes | void> {
    this.calls.push(request.sql);
    if (request.type === 'exec') return this.connector.query(request, options);
    const response = this.connector.query(request, options);
    return this.gate ? Promise.all([response, this.gate]).then(([bytes]) => bytes) : response;
  }
}

const db = new DuckDB();
const connection = NodeConnector.make(db);
const source = 'native_consolidation';
const tick = () => new Promise<void>(resolve => setImmediate(resolve));

beforeAll(async () => {
  await db.exec(`CREATE TABLE ${source} AS SELECT * FROM (VALUES
    ('a', 1, 10), ('a', 2, NULL), ('b', 3, 30), ('b', 4, 40)
  ) t(g, x, y)`);
  await db.exec('CREATE MACRO consolidation_aggregate(a) AS max(a); CREATE MACRO "quantile"(a,b,c) AS a+b+c; CREATE SCHEMA consolidation_calls; CREATE MACRO consolidation_calls."sum"(a,b,c) AS a+b+c');
});
afterAll(() => db.close());

async function setup() {
  const connector = new RecordingConnector(await connection);
  const native = new SqlContext();
  const coordinator = new Coordinator(connector, { sql: native, logger: null });
  return { connector, native, coordinator };
}

function withSource(query: Query, child: Query): Query {
  inspectSelect(query).with = native.withClause([native.cte('local_source', child.expression).cte]).with;
  return query;
}

describe('native query consolidation', () => {
  it('combines count and sum and caches each original projection', async () => {
    const { connector, coordinator } = await setup();
    const first = Query.from(source).select({ n: count() });
    const second = Query.from(source).select({ total: sum('x') });
    try {
      const [a, b] = await Promise.all([coordinator.query(first), coordinator.query(second)]);
      expect(Array.from(a)).toEqual([{ n: 4 }]);
      expect(Array.from(b)).toEqual([{ total: 10 }]);
      expect(connector.calls).toHaveLength(1);
      expect(await coordinator.query(first)).toBe(a);
      expect(await coordinator.query(second)).toBe(b);
      expect(connector.calls).toHaveLength(1);
    } finally {
      coordinator.clear();
    }
  });

  it('resolves grouped aliases and ordinals while preserving null columns', async () => {
    const { connector, coordinator } = await setup();
    try {
      const [a, b] = await Promise.all([
        coordinator.query(Query.from(source).select({ label: 'g', n: count() }).groupby('label')),
        coordinator.query(Query.from(source).select({ group: 'g', total: sum('y'), missing: literal(null) }).groupby(literal(1)))
      ]);
      expect(Array.from(a).sort((a, b) => a.label.localeCompare(b.label))).toEqual([
        { label: 'a', n: 2 }, { label: 'b', n: 2 }
      ]);
      expect(Array.from(b).sort((a, b) => a.group.localeCompare(b.group))).toEqual([
        { group: 'a', total: 10, missing: null }, { group: 'b', total: 70, missing: null }
      ]);
      expect(connector.calls).toHaveLength(1);
    } finally {
      coordinator.clear();
    }
  });

  it.each(['cube', 'rollup', 'grouping_sets'] as const)('keeps %s alias grouping on the direct path', async kind => {
    const { connector, coordinator } = await setup();
    const grouping: SqlExpression = kind === 'cube'
      ? { cube: { expressions: [column('label')], options: null } }
      : kind === 'rollup'
        ? { rollup: { expressions: [column('label')], options: null } }
        : { grouping_sets: { expressions: [native.tuple([column('label')]), native.tuple([])], options: null } };
    try {
      const [counts, totals] = await Promise.all([
        coordinator.query(Query.from(source).select({ label: 'g', n: count() }).groupby(grouping)),
        coordinator.query(Query.from(source).select({ label: 'g', total: sum('y') }).groupby(grouping))
      ]);
      expect(Array.from(counts).sort((a, b) => String(a.label).localeCompare(String(b.label)))).toEqual([
        { label: 'a', n: 2 }, { label: 'b', n: 2 }, { label: null, n: 4 }
      ]);
      expect(Array.from(totals).sort((a, b) => String(a.label).localeCompare(String(b.label)))).toEqual([
        { label: 'a', total: 10 }, { label: 'b', total: 70 }, { label: null, total: 80 }
      ]);
      expect(connector.calls).toHaveLength(2);
    } finally {
      coordinator.clear();
    }
  });

  it('keeps row queries separate from ungrouped aggregates and honors scalar boundaries', async () => {
    const { connector, coordinator } = await setup();
    try {
      const scalar = native.subquery(Query.from(source).select({ n: count() }).expression);
      const [rows, scalarRows, aggregate] = await Promise.all([
        coordinator.query(Query.from(source).select('x')),
        coordinator.query(Query.from(source).select({ n: scalar })),
        coordinator.query(Query.from(source).select({ n: count() }))
      ]);
      expect(Array.from(rows)).toEqual([{ x: 1 }, { x: 2 }, { x: 3 }, { x: 4 }]);
      expect(Array.from(scalarRows)).toEqual([{ n: 4 }, { n: 4 }, { n: 4 }, { n: 4 }]);
      expect(Array.from(aggregate)).toEqual([{ n: 4 }]);
      expect(connector.calls).toHaveLength(2);
    } finally {
      coordinator.clear();
    }
  });

  it.each([
    ['"max"(x) FILTER (WHERE x < 4)', 3],
    ['consolidation_aggregate(x)', 4]
  ] as const)('keeps unresolved aggregate %s separate from row projections', async (expression, expected) => {
    const { connector, coordinator } = await setup();
    try {
      const [aggregate, rows] = await Promise.all([
        coordinator.query(Query.from(source).select({ value: sql`${expression}` })),
        coordinator.query(Query.from(source).select({ row: 'x' }))
      ]);
      expect(Array.from(aggregate)).toEqual([{ value: expected }]);
      expect(Array.from(rows)).toEqual([{ row: 1 }, { row: 2 }, { row: 3 }, { row: 4 }]);
      expect(connector.calls).toHaveLength(2);
    } finally { coordinator.clear(); }
  });

  it.each(['"quantile"', 'consolidation_calls."sum"'])('keeps unresolved scalar %s on the direct path alongside known aggregates', async name => {
    const { connector, coordinator } = await setup();
    try {
      const [scalar, aggregate, rows] = await Promise.all([
        coordinator.query(Query.from(source).select({ value: sql`${name}(x, 1, 2)` })),
        coordinator.query(Query.from(source).select({ total: sum('x') })),
        coordinator.query(Query.from(source).select({ row: 'x' }))
      ]);
      expect(Array.from(scalar)).toEqual([{ value: 4 }, { value: 5 }, { value: 6 }, { value: 7 }]);
      expect(Array.from(aggregate)).toEqual([{ total: 10 }]);
      expect(Array.from(rows)).toEqual([{ row: 1 }, { row: 2 }, { row: 3 }, { row: 4 }]);
      expect(connector.calls).toHaveLength(3);
    } finally { coordinator.clear(); }
  });

  it('keeps row-expanding UNNEST projections separate from ordinary row queries', async () => {
    const { connector, coordinator } = await setup();
    try {
      const [expanded, rows] = await Promise.all([
        coordinator.query(Query.from(source).select({ value: unnest(list([column('x'), column('x')])) })),
        coordinator.query(Query.from(source).select({ row: 'x' }))
      ]);
      expect(Array.from(expanded)).toEqual([
        { value: 1 }, { value: 1 }, { value: 2 }, { value: 2 },
        { value: 3 }, { value: 3 }, { value: 4 }, { value: 4 }
      ]);
      expect(Array.from(rows)).toEqual([{ row: 1 }, { row: 2 }, { row: 3 }, { row: 4 }]);
      expect(connector.calls).toHaveLength(2);
    } finally { coordinator.clear(); }
  });

  it('keeps deferred aggregates and dynamic wildcard projections on the direct path', async () => {
    const { connector, coordinator } = await setup();
    const field = Param.value('x');
    const dynamic = Query.from(source).select({ value: column(field) });
    try {
      const [rows, aggregate] = await Promise.all([
        coordinator.query(Query.from(source).select({ x: 'x' })),
        coordinator.query(Query.from(source).select({ n: deferred(() => count()) }))
      ]);
      expect(rows.numRows).toBe(4);
      expect(Array.from(aggregate)).toEqual([{ n: 4 }]);
      expect(connector.calls).toHaveLength(2);
      field.update('*');
      await field.pending('value');
      const [expanded] = await Promise.all([
        coordinator.query(dynamic),
        coordinator.query(Query.from(source).select({ other: 'x' }))
      ]);
      expect(expanded.schema.fields.length).toBe(3);
      expect(connector.calls).toHaveLength(4);
    } finally {
      coordinator.clear();
    }
  });

  it('preserves complete CTE bodies in structural compatibility', async () => {
    const { connector, coordinator } = await setup();
    const firstSource = Query.from(source).select('x');
    const otherSource = Query.from(source).select({ x: add('x', 100) });
    try {
      const [a, b, c] = await Promise.all([
        coordinator.query(withSource(Query.from('local_source').select({ x: 'x' }), firstSource)),
        coordinator.query(withSource(Query.from('local_source').select({ next: add('x', 1) }), firstSource)),
        coordinator.query(withSource(Query.from('local_source').select({ x: 'x' }), otherSource))
      ]);
      expect(Array.from(a)[0]).toEqual({ x: 1 });
      expect(Array.from(b)[0]).toEqual({ next: 2 });
      expect(Array.from(c)[0]).toEqual({ x: 101 });
      expect(connector.calls).toHaveLength(2);
    } finally {
      coordinator.clear();
    }
  });

  it.each([
    native.star(),
    native.star(source),
    { columns: { this: native.literal('x|y'), unpack: null } } satisfies SqlExpression
  ])('runs expanding projections independently', async expansion => {
    const { connector, coordinator } = await setup();
    try {
      const [expanded, scalar] = await Promise.all([
        coordinator.query(Query.from(source).select({ expanded: expansion })),
        coordinator.query(Query.from(source).select({ value: 'x' }))
      ]);
      expect(expanded.numRows).toBe(4);
      expect(expanded.schema.fields.length).toBeGreaterThan(1);
      expect(Array.from(scalar)[0]).toEqual({ value: 1 });
      expect(connector.calls).toHaveLength(2);
    } finally {
      coordinator.clear();
    }
  });

  it('uses one submitted parameter snapshot for execution and constituent cache keys', async () => {
    const { connector, coordinator } = await setup();
    const value = Param.value(1);
    const binding = asLiteral(value);
    const first = Query.from(source).select({ n: add(count(), binding) });
    const second = Query.from(source).select({ total: add(sum('x'), binding) });
    const release = connector.hold();
    try {
      const pending = Promise.all([coordinator.query(first), coordinator.query(second)]);
      await tick();
      expect(connector.calls).toHaveLength(1);
      value.update(7);
      await value.pending('value');
      release();
      const [oldCount, oldSum] = await pending;
      expect(Array.from(oldCount)).toEqual([{ n: 5 }]);
      expect(Array.from(oldSum)).toEqual([{ total: 11 }]);
      expect(Array.from(await coordinator.query(first))).toEqual([{ n: 11 }]);
      expect(connector.calls).toHaveLength(2);
      value.update(1);
      await value.pending('value');
      expect(await coordinator.query(first)).toBe(oldCount);
      expect(connector.calls).toHaveLength(2);
    } finally {
      release();
      coordinator.clear();
    }
  });

  it('reuses cached simultaneous projections from one live parameter snapshot', async () => {
    const { connector, coordinator } = await setup();
    const value = Param.value(1);
    const binding = asLiteral(value);
    const first = Query.from(source).select({ n: add(count(), binding) });
    const second = Query.from(source).select({ total: add(sum('x'), binding) });
    const read = vi.spyOn(value, 'value', 'get');
    const request = () => Promise.all([coordinator.query(first), coordinator.query(second)]);
    try {
      const initial = request();
      expect(read).not.toHaveBeenCalled();
      const [a, b] = await initial;
      expect(Array.from(a)).toEqual([{ n: 5 }]);
      expect(Array.from(b)).toEqual([{ total: 11 }]);
      expect(read).toHaveBeenCalledTimes(1);
      expect(connector.calls).toHaveLength(1);

      read.mockClear();
      const cached = request();
      expect(read).not.toHaveBeenCalled();
      const [cachedA, cachedB] = await cached;
      expect(cachedA).toBe(a);
      expect(cachedB).toBe(b);
      expect(read).toHaveBeenCalledTimes(1);
      expect(connector.calls).toHaveLength(1);

      value.update(2);
      await value.pending('value');
      read.mockClear();
      const [changedA, changedB] = await request();
      expect(Array.from(changedA)).toEqual([{ n: 6 }]);
      expect(Array.from(changedB)).toEqual([{ total: 12 }]);
      expect(changedA).not.toBe(a);
      expect(changedB).not.toBe(b);
      expect(read).toHaveBeenCalledTimes(1);
      expect(connector.calls).toHaveLength(2);

      value.update(1);
      await value.pending('value');
      read.mockClear();
      const [restoredA, restoredB] = await request();
      expect(restoredA).toBe(a);
      expect(restoredB).toBe(b);
      expect(read).toHaveBeenCalledTimes(1);
      expect(connector.calls).toHaveLength(2);
    } finally {
      read.mockRestore();
      coordinator.clear();
    }
  });

  it('matches structure without reading parameters before submission', async () => {
    let reads = 0;
    const parameter: ParamLike = {
      get value() { return ++reads; },
      addEventListener() {},
      removeEventListener() {}
    };
    const binding = asLiteral(parameter);
    const native = new SqlContext();
    const entries: QueryEntry[] = [
      Query.select({ a: binding }), Query.select({ b: add(binding, 1) })
    ].map(query => ({ request: { type: 'arrow', query }, result: new QueryResult() }));
    const submitted: QueryEntry[] = [];
    const cache: Cache = { get: () => undefined, set: (_key, value) => value, clear() {}, bytes: () => 0 };
    const c = consolidator(entry => submitted.push(entry), () => cache, () => 0, () => native);
    for (const entry of entries) c.add(entry, Priority.Normal);
    await tick();
    expect(reads).toBe(0);
    expect(submitted).toHaveLength(1);
    expect(submitted[0].prepare?.()).toContain('SELECT');
    expect(reads).toBe(1);
    submitted[0].result.fulfill(tableFromArrays({ col0: [1], col1: [2] }));
    await Promise.all(entries.map(({ result }) => result));
  });

  it('clears pending groups and cached extracts when the execution context changes', async () => {
    const { connector, coordinator } = await setup();
    const queries = [Query.from(source).select({ n: count() }), Query.from(source).select({ total: sum('x') })];
    try {
      const obsolete = queries.map(query => coordinator.query(query));
      const cleared = obsolete.map(result => expect(result).rejects.toBe('Cleared'));
      coordinator.executionContext({ backend: 'replacement-session' });
      const current = await Promise.all(queries.map(query => coordinator.query(query)));
      await Promise.all(cleared);
      expect(Array.from(current[0])).toEqual([{ n: 4 }]);
      expect(connector.calls).toHaveLength(1);
      expect(await coordinator.query(queries[0])).toBe(current[0]);
      coordinator.executionContext({ backend: 'third-session' });
      expect(Array.from(await coordinator.query(queries[0]))).toEqual([{ n: 4 }]);
      expect(connector.calls).toHaveLength(2);
    } finally {
      coordinator.clear();
    }
  });

  it('cancels one constituent while delivering the surviving projection', async () => {
    const { connector, coordinator } = await setup();
    const release = connector.hold();
    try {
      const first = coordinator.query(Query.from(source).select({ n: count() }));
      const second = coordinator.query(Query.from(source).select({ total: sum('x') }));
      await tick();
      const cancelled = expect(first).rejects.toBe('Canceled');
      coordinator.cancel([first]);
      release();
      await cancelled;
      expect(Array.from(await second)).toEqual([{ total: 10 }]);
      expect(connector.calls).toHaveLength(1);
    } finally {
      release();
      coordinator.clear();
    }
  });

  it('captures extraction options per consolidated flight and isolates result caching', async () => {
    const { connector, coordinator } = await setup();
    const date = literal(new Date('2024-01-01T00:00:00Z'));
    const queries = [Query.select({ a: date }), Query.select({ b: date })];
    const release = connector.hold();
    try {
      const first = Promise.all(queries.map(query => coordinator.query(query)));
      await tick();
      coordinator.manager.ipc({ useDate: false });
      const second = Promise.all(queries.map(query => coordinator.query(query)));
      await tick();
      expect(connector.calls).toHaveLength(2);
      release();
      const [old, current] = await Promise.all([first, second]);
      expect(Array.from(old[0])[0]).toEqual({ a: new Date('2024-01-01T00:00:00Z') });
      expect(Array.from(current[0])[0]).toEqual({ a: 1704067200000 });
      expect(await coordinator.query(queries[0])).toBe(current[0]);
      expect(connector.calls).toHaveLength(2);
    } finally {
      release();
      coordinator.clear();
    }
  });

  it('rejects every constituent before caching if any extraction fails', async () => {
    const native = new SqlContext();
    const set = vi.fn();
    const cache: Cache = { get: () => undefined, set, clear() {}, bytes: () => 0 };
    const c = consolidator(entry => entry.result.fulfill(tableFromArrays({ col0: [1] })), () => cache, () => 0, () => native);
    const entries: QueryEntry[] = ['x', 'y'].map(field => ({
      request: { type: 'arrow', cache: true, query: Query.from(source).select({ value: column(field) }) },
      result: new QueryResult()
    }));
    for (const entry of entries) c.add(entry, Priority.Normal);
    expect((await Promise.allSettled(entries.map(({ result }) => result))).map(result => result.status))
      .toEqual(['rejected', 'rejected']);
    expect(set).not.toHaveBeenCalled();
  });
});
