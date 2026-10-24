import { DuckDB } from '@uwdata/mosaic-duckdb';
import type { Table } from '@uwdata/flechette';
import * as sql from '@uwdata/mosaic-sql/native';
import type { SqlExpression, SqlRoot } from '@uwdata/mosaic-sql/native';
import { afterAll, beforeAll, describe, expect, it, vi } from 'vitest';
import { Coordinator } from '../src/Coordinator.js';
import { NodeConnector } from '../src/connectors/NodeConnector.js';
import type { ArrowQueryRequest, Connector, ConnectorQueryOptions, ExecQueryRequest } from '../src/connectors/Connector.js';
import type { ResolvedPredicate } from '../src/Selection.js';
import type { ArrowIPCBytes } from '../src/types.js';
import { makeClient } from '../src/make-client.js';
import { NativeSqlContext } from '../src/native-sql.js';
import { Param } from '../src/Param.js';
import { NativePreAggregateInfo } from '../src/preagg/PreAggregator.js';

class TestConnector implements Connector {
  readonly calls: { type: string; sql: string }[] = [];
  failCreate = false;
  failRead = false;
  private gate?: { match: (request: ArrowQueryRequest | ExecQueryRequest) => boolean; promise: Promise<void> };

  constructor(private readonly connection: Connector) {}

  hold(match: (request: ArrowQueryRequest | ExecQueryRequest) => boolean): () => void {
    let resolve!: () => void;
    this.gate = { match, promise: new Promise(release => { resolve = release; }) };
    return () => { this.gate = undefined; resolve(); };
  }

  query(request: ArrowQueryRequest, options?: ConnectorQueryOptions): Promise<ArrowIPCBytes>;
  query(request: ExecQueryRequest, options?: ConnectorQueryOptions): Promise<void>;
  query(request: ArrowQueryRequest | ExecQueryRequest, options?: ConnectorQueryOptions): Promise<ArrowIPCBytes | void> {
    this.calls.push({ type: request.type, sql: request.sql });
    if (this.failCreate && request.type === 'exec' && /CREATE TABLE/i.test(request.sql)) return Promise.reject(new Error('Scratch schema is read-only.'));
    if (this.failRead && request.type === 'arrow' && /preagg_/.test(request.sql)) return Promise.reject(new Error('Materialized read failed.'));
    const response = request.type === 'exec' ? this.connection.query(request, options) : this.connection.query(request, options);
    const gate = this.gate;
    return gate?.match(request) ? Promise.all([response, gate.promise]).then(([result]) => result) : response;
  }
}

const db = new DuckDB();
const connection = NodeConnector.make(db);
const tick = () => new Promise<void>(resolve => setImmediate(resolve));

beforeAll(async () => {
  await db.exec(`CREATE TABLE native_preagg AS SELECT * FROM (VALUES
    ('a', 'u', 1, 9), ('a', 'v', 2, 8), ('b', 'u', 3, 7), ('b', 'v', 4, 6), ('b', 'v', NULL, NULL)
  ) t(dim, cat, x, y)`);
  await db.exec(`CREATE TABLE native_preagg_constant AS SELECT * FROM (VALUES
    ('b', 2.0, 5.0), ('b', 2.0, 5.0), ('b', NULL, NULL), ('single', 2.0, 5.0),
    ('xconstant', 2.0, 1.0), ('xconstant', 2.0, 3.0), ('yconstant', 1.0, 2.0), ('yconstant', 3.0, 2.0)
  ) t(dim, x, y)`);
  await db.exec(`CREATE TABLE native_preagg_offset AS SELECT * FROM (VALUES
    ('b', 1000000000001.0, 3000000000002.0), ('b', 1000000000002.0, 3000000000004.0),
    ('b', 1000000000003.0, 3000000000006.0), ('b', 1000000000004.0, 3000000000008.0),
    ('b', NULL, 3000000000010.0), ('b', 1000000000006.0, NULL)
  ) t(dim, x, y)`);
  await db.exec(`CREATE TABLE native_extrema AS SELECT * FROM (VALUES
    (0, 'a', 1, 99), (0, NULL, 100, 0), (1, 'b', 50, 50)
  ) t(bucket, r, high, low)`);
  await db.exec(`CREATE TABLE native_preagg_dates AS SELECT * FROM (VALUES
    (TIMESTAMP '2024-01-01'), (TIMESTAMP '2024-01-02'), (TIMESTAMP '2024-01-03')
  ) t(ts)`);
  await db.exec("CREATE TABLE native_preagg_mutable AS SELECT 'b' AS dim, 1 AS x");
  await db.exec("CREATE TABLE native_preagg_duplicates AS SELECT * FROM (VALUES ('a', 1), ('b', 1)) t(dim, x)");
  await db.exec("CREATE TABLE native_preagg_split_nulls AS SELECT * FROM (VALUES ('a', 'k', 1, NULL), ('b', 'k', NULL, 2)) t(dim, g, x, y)");
});
afterAll(() => db.close());

async function setup() {
  const native = new NativeSqlContext();
  const connector = new TestConnector(await connection);
  const coordinator = new Coordinator(connector, { native, logger: null, cache: false, consolidate: false });
  const selection = native.selection({ single: true, cross: true });
  return { native, connector, coordinator, selection };
}

type QueryFactory = (filter?: ResolvedPredicate<SqlExpression>) => sql.Query;

async function clientFor(query: QueryFactory) {
  const state = await setup();
  let rows: Table | undefined;
  const errors: Error[] = [];
  const client = makeClient<SqlExpression>({
    coordinator: state.coordinator,
    selection: state.selection,
    query: filter => query(filter ?? []),
    queryResult: result => { rows = result as Table; },
    queryError: error => { errors.push(error); }
  });
  await client.pending;
  if (!rows) {
    client.destroy();
    state.coordinator.clear();
    throw errors[0] ?? new Error('Native client returned no initial rows.');
  }
  return { ...state, client, errors, rows: () => rows! };
}

function expectMaterialized(state: Awaited<ReturnType<typeof clientFor>>): void {
  const plan = state.coordinator.preaggregator.entries.get(state.client);
  expect(plan).toBeInstanceOf(NativePreAggregateInfo);
  if (!(plan instanceof NativePreAggregateInfo)) throw new TypeError('Expected a native preaggregation plan.');
  expect(plan.result).not.toBeNull();
  expect(state.errors).toEqual([]);
  const table = plan.table;
  if (!table) throw new TypeError('Expected a materialized native table.');
  expect(state.connector.calls.some(call => call.type === 'exec' && /CREATE TABLE/i.test(call.sql)
    && call.sql.includes(table.table.name.name))).toBe(true);
  expect(state.connector.calls.some(call => call.type === 'arrow' && call.sql.includes(table.table.name.name))).toBe(true);
}

function expectRows(actual: Table, expected: Table): void {
  const left = Array.from(actual);
  const right = Array.from(expected);
  expect(left).toHaveLength(right.length);
  for (let row = 0; row < right.length; ++row) {
    expect(Object.keys(left[row])).toEqual(Object.keys(right[row]));
    for (const name of Object.keys(right[row])) {
      const value = right[row][name];
      const result = left[row][name];
      if (typeof value === 'number' && Number.isFinite(value)) {
        if (typeof result !== 'number') throw new TypeError('Expected a numeric preaggregation result.');
        expect(Math.abs(result - value)).toBeLessThanOrEqual(Math.max(1e-8, Math.abs(value) * 1e-10));
      } else expect(result).toEqual(value);
    }
  }
}

const statistics: [string, () => SqlRoot][] = [
  ['count', () => sql.count()], ['count value', () => sql.count('x')],
  ['sum', () => sql.sum('x')], ['avg', () => sql.avg('x')], ['geomean', () => sql.geomean('x')],
  ['min', () => sql.min('x')], ['max', () => sql.max('x')], ['product', () => sql.product('x')],
  ['argmax', () => sql.argmax('x', 'y')], ['argmin', () => sql.argmin('x', 'y')],
  ['variance', () => sql.variance('x')], ['varPop', () => sql.varPop('x')],
  ['stddev', () => sql.stddev('x')], ['stddevPop', () => sql.stddevPop('x')],
  ['covariance', () => sql.covariance('y', 'x')], ['covarPop', () => sql.covarPop('y', 'x')],
  ['corr', () => sql.corr('y', 'x')], ['regrCount', () => sql.regrCount('y', 'x')],
  ['regrAvgX', () => sql.regrAvgX('y', 'x')], ['regrAvgY', () => sql.regrAvgY('y', 'x')],
  ['regrSXX', () => sql.regrSXX('y', 'x')], ['regrSYY', () => sql.regrSYY('y', 'x')],
  ['regrSXY', () => sql.regrSXY('y', 'x')], ['regrSlope', () => sql.regrSlope('y', 'x')],
  ['regrIntercept', () => sql.regrIntercept('y', 'x')], ['regrR2', () => sql.regrR2('y', 'x')]
];

describe('native preaggregation', () => {
  it.each(statistics)('matches direct %s over nullable, empty, constant and large-offset inputs', async (_name, measure) => {
    for (const [source, selected] of [
      ['native_preagg', 'b'], ['native_preagg', 'missing'],
      ['native_preagg_constant', 'b'], ['native_preagg_constant', 'single'],
      ['native_preagg_constant', 'xconstant'], ['native_preagg_constant', 'yconstant'], ['native_preagg_offset', 'b']
    ]) {
      const query: QueryFactory = (filter = []) => sql.Query.from(source).select({ measure: measure() }).where(filter);
      const state = await clientFor(query);
      try {
        state.selection.update(state.native.point('dim', selected, { source: {} }));
        await state.selection.pending('value');
        const filter = state.selection.predicate(state.client);
        const offsetMoment = source !== 'native_preagg_offset' ? undefined
          : _name === 'variance' ? sql.variance : _name === 'varPop' ? sql.varPop
            : _name === 'stddev' ? sql.stddev : _name === 'stddevPop' ? sql.stddevPop : undefined;
        // DuckDB loses low bits on uncentered 1e12 inputs; variance and stddev are translation-invariant.
        const reference = offsetMoment
          ? sql.Query.from(source).select({ measure: offsetMoment(sql.sub('x', 1e12)) }).where(filter ?? [])
          : query(filter);
        const expected = await state.coordinator.query(reference, { cache: false });
        expectRows(state.rows(), expected);
        if (offsetMoment) {
          const variance = _name === 'variance' || _name === 'stddev' ? 37 / 10 : 74 / 25;
          const truth = _name === 'stddev' || _name === 'stddevPop' ? Math.sqrt(variance) : variance;
          expect(Array.from(state.rows())[0].measure).toBeCloseTo(truth, 12);
        }
        if (source === 'native_preagg_constant' && (selected === 'xconstant' || selected === 'yconstant')
          && (_name === 'regrR2' || _name === 'regrIntercept')) {
          const value = selected === 'xconstant' ? null : _name === 'regrR2' ? 1 : 2;
          expect(Array.from(state.rows())).toEqual([{ measure: value }]);
        }
        expectMaterialized(state);
      } finally {
        state.client.destroy();
        state.coordinator.clear();
      }
    }
  });

  it.each([false, true])('preserves empty aggregate constants with authored grouping %s', async grouped => {
    const query: QueryFactory = (filter = []) => {
      const query = sql.Query.from('native_preagg').select({ label: sql.literal('fixed'), measure: sql.count() }).where(filter);
      return grouped ? query.groupby('label') : query;
    };
    const state = await clientFor(query);
    try {
      state.selection.update(state.native.point('dim', 'missing', { source: {} }));
      await state.selection.pending('value');
      expect(Array.from(state.rows())).toEqual(grouped ? [] : [{ label: 'fixed', measure: 0 }]);
      expectRows(state.rows(), await state.coordinator.query(query(state.selection.predicate(state.client))));
      expectMaterialized(state);
    } finally {
      state.client.destroy();
      state.coordinator.clear();
    }
  });

  it.each([
    'union', 'intersect', 'except', 'distinct', 'mean groups', 'count groups', 'nullable sum',
    'global count', 'global sum', 'having', 'qualify', 'limit', 'shadowed field'
  ] as const)('uses native fallback across unsafe %s domains', async kind => {
    const query: QueryFactory = (filter = []) => {
      if (kind === 'union' || kind === 'intersect' || kind === 'except') {
        const left = sql.Query.from('native_preagg_duplicates').select('x').where(filter);
        const right = sql.Query.from('native_preagg_duplicates').select('x').where(filter);
        const set = kind === 'union' ? sql.Query.union(left, right) : kind === 'intersect'
          ? sql.Query.intersect(left, right) : sql.Query.except(left, right.where(sql.eq('dim', sql.literal('b'))));
        return sql.Query.from(set).select({ measure: sql.sum('x') });
      }
      if (kind === 'distinct') {
        return sql.Query.from(sql.Query.from('native_preagg_duplicates').select('x').where(filter).distinct())
          .select({ measure: sql.sum('x') });
      }
      if (kind === 'mean groups' || kind === 'count groups') {
        const groups = sql.Query.from('native_preagg_duplicates').select({ x: 'x', n: sql.count() }).where(filter).groupby('x');
        return sql.Query.from(groups).select({ measure: kind === 'mean groups' ? sql.avg('n') : sql.count('n') });
      }
      if (kind === 'nullable sum') {
        const groups = sql.Query.from('native_preagg_split_nulls').select({ a: sql.sum('x'), b: sql.sum('y') }).where(filter).groupby('g');
        return sql.Query.from(groups).select({ measure: sql.sum(sql.add('a', 'b')) });
      }
      if (kind === 'global count' || kind === 'global sum') {
        const counts = sql.Query.from('native_preagg').select({ n: sql.count() }).where(filter);
        return sql.Query.with({ counts }).from('counts').select({ measure: kind === 'global count' ? sql.count() : sql.sum('n') });
      }
      if (kind === 'having') {
        const groups = sql.Query.from('native_preagg').select({ v: sql.sum('x') }).where(filter).groupby('cat').having(sql.gt(sql.sum('x'), 3));
        return sql.Query.from(groups).select({ measure: sql.sum('v') });
      }
      if (kind === 'qualify') {
        const ranked = sql.Query.from('native_preagg').select({ v: 'x', dim: 'dim', r: sql.row_number().orderby('x') })
          .where(filter).qualify(sql.lte('r', 1));
        return sql.Query.from(ranked).select({ measure: sql.sum('v') });
      }
      if (kind === 'shadowed field') {
        const source = sql.Query.from('native_preagg').select({ dim: sql.literal('fixed'), x: 'x' }).where(filter);
        return sql.Query.with({ source }).from('source').select({ measure: sql.sum('x') });
      }
      const limited = sql.Query.from('native_preagg').select({ v: 'x', dim: 'dim' }).where(filter).orderby('x').limit(1);
      return sql.Query.from(limited).select({ measure: sql.sum('v') });
    };
    const state = await clientFor(query);
    const values = kind === 'global count' || kind === 'global sum' ? [['missing']]
      : kind === 'qualify' || kind === 'limit' || kind === 'shadowed field' ? [['b']] : [['a'], ['b']];
    try {
      state.selection.update(state.native.points(['dim'], values, { source: {} }));
      await state.selection.pending('value');
      expectRows(state.rows(), await state.coordinator.query(query(state.selection.predicate(state.client))));
      const value = kind === 'except' ? null : kind === 'mean groups' ? 2 : kind === 'global sum' ? 0
        : kind === 'having' ? 10 : kind === 'nullable sum' ? 3 : kind === 'qualify' || kind === 'limit' ? 3 : kind === 'shadowed field' ? 7 : 1;
      expect(Array.from(state.rows())).toEqual([{ measure: value }]);
      expect(state.coordinator.preaggregator.entries.get(state.client)).toBeNull();
      expect(state.connector.calls.some(call => call.type === 'exec' && /CREATE TABLE/i.test(call.sql))).toBe(false);
      expect(state.errors).toEqual([]);
    } finally {
      state.client.destroy();
      state.coordinator.clear();
    }
  });

  it.each(['max', 'min'] as const)('excludes null return arguments from partial arg%s extrema', async kind => {
    const query: QueryFactory = (filter = []) => sql.Query.from('native_extrema')
      .select({ measure: kind === 'max' ? sql.argmax('r', 'high') : sql.argmin('r', 'low') }).where(filter);
    const state = await clientFor(query);
    try {
      state.selection.update(state.native.interval('bucket', [0, 1], {
        source: {}, scale: { type: 'identity', domain: [0, 1] }
      }));
      await state.selection.pending('value');
      expect(Array.from(state.rows())).toEqual([{ measure: 'b' }]);
      expectRows(state.rows(), await state.coordinator.query(query(state.selection.predicate(state.client))));
      expectMaterialized(state);
    } finally {
      state.client.destroy();
      state.coordinator.clear();
    }
  });

  it('preserves aggregate filters, empty counts, multiple statistics and native fallback eligibility', async () => {
    const measures = [
      sql.add(sql.sum('x').where(sql.gt('x', 2)), sql.product('x')),
      sql.count().where(sql.literal(false)),
      sql.count('x').distinct(),
      sql.sum('x').argOrder(sql.desc('x'))
    ];
    for (const measure of measures) {
      const query: QueryFactory = (filter = []) => sql.Query.from('native_preagg').select({ measure }).where(filter);
      const state = await clientFor(query);
      try {
        state.selection.update(state.native.point('dim', 'b', { source: {} }));
        await state.selection.pending('value');
        expectRows(state.rows(), await state.coordinator.query(query(state.selection.predicate(state.client))));
        const optimized = state.coordinator.preaggregator.entries.get(state.client) instanceof NativePreAggregateInfo;
        expect(optimized).toBe(measure === measures[0] || measure === measures[1]);
        if (optimized) expectMaterialized(state);
      } finally {
        state.client.destroy();
        state.coordinator.clear();
      }
    }
  });

  it.each(['grouped CTE', 'positional union', 'centered derived value', 'window', 'named window', 'having'] as const)('optimizes %s source plans', async kind => {
    const query: QueryFactory = (filter = []) => {
      if (kind === 'grouped CTE') {
        const counts = sql.Query.from('native_preagg').select({ item: 'x', freq: sql.count() }).groupby('x').where(filter);
        return sql.Query.with({ counts }).from('counts').select({ measure: sql.sum(sql.mul(2, 'freq')) });
      }
      if (kind === 'positional union') {
        const r = sql.Query.from('native_preagg').select('dim', 'x', 'y').where(filter);
        const s = sql.Query.unionAll(sql.Query.from('r').select({ series: 'dim', v: 'x' }), sql.Query.from('r').select('dim', 'y'));
        return sql.Query.with({ r, s }).from('s').select({ measure: sql.sum('v') });
      }
      if (kind === 'centered derived value') {
        const derived = sql.Query.from('native_preagg').select({ v: 'x', dim: 'dim' }).where(filter);
        return sql.Query.with({ derived }).from('derived').select({ measure: sql.variance('v') });
      }
      if (kind === 'named window') {
        return sql.Query.from('native_preagg').select({ measure: sql.sum(sql.sum('y')).window().over('w') })
          .groupby('dim', 'x').where(filter).window({ w: sql.over().orderby('x').frame(sql.frameRows([null, 0])) })
          .qualify(sql.gt('measure', 7));
      }
      if (kind === 'window') {
        return sql.Query.from('native_preagg').select({ measure: sql.sum(sql.sum('y')).orderby('x') })
          .groupby('dim', 'x').where(filter).qualify(sql.gt('measure', 7));
      }
      return sql.Query.from('native_preagg').select({ measure: sql.sum('y') }).groupby('dim')
        .where(filter).having(sql.gt(sql.avg('x'), 2)).orderby(sql.desc(sql.literal(1)));
    };
    const state = await clientFor(query);
    try {
      state.selection.update(state.native.point('dim', 'b', { source: {} }));
      await state.selection.pending('value');
      expectRows(state.rows(), await state.coordinator.query(query(state.selection.predicate(state.client))));
      expectMaterialized(state);
    } finally {
      state.client.destroy();
      state.coordinator.clear();
    }
  });

  it('skips an explicitly associated native producer while preaggregating the consumer', async () => {
    const state = await clientFor((filter = []) => sql.Query.from('native_preagg').select({ measure: sql.sum('x') }).where(filter));
    const produced = vi.fn();
    const producer = makeClient<SqlExpression>({
      coordinator: state.coordinator,
      selection: state.selection,
      query: (filter = []) => sql.Query.from('native_preagg').select({ n: sql.count() }).where(filter),
      queryResult: result => produced(Array.from(result as Table))
    });
    await producer.pending;
    const source = {};
    const clients = new Set([producer]);
    try {
      expect(produced).toHaveBeenLastCalledWith([{ n: 5 }]);
      state.selection.update(state.native.point('dim', 'b', { source, clients }));
      await state.selection.pending('value');
      expect(produced).toHaveBeenCalledTimes(1);
      expect(Array.from(state.rows())).toEqual([{ measure: 7 }]);
      expect(state.coordinator.preaggregator.entries.get(producer)).toEqual({ skip: true });
      expectMaterialized(state);
      state.selection.update(state.native.interval('x', [0, 2], {
        source, clients, scale: { type: 'identity', domain: [0, 4] }
      }));
      await state.selection.pending('value');
      expect(produced).toHaveBeenCalledTimes(1);
      expect(Array.from(state.rows())).toEqual([{ measure: 3 }]);
      expect(state.coordinator.preaggregator.entries.get(producer)).toEqual({ skip: true });
    } finally {
      producer.destroy();
      state.client.destroy();
      state.coordinator.clear();
    }
  });

  it('invalidates one source when its point field or interval metadata changes', async () => {
    const state = await clientFor((filter = []) => sql.Query.from('native_preagg').select({ measure: sql.sum('x') }).where(filter));
    const source = {};
    try {
      state.selection.update(state.native.point('dim', 'b', { source }));
      await state.selection.pending('value');
      const first = state.coordinator.preaggregator.entries.get(state.client);
      expect(Array.from(state.rows())).toEqual([{ measure: 7 }]);
      state.selection.update(state.native.point('cat', 'u', { source }));
      await state.selection.pending('value');
      expect(state.coordinator.preaggregator.entries.get(state.client)).not.toBe(first);
      expect(Array.from(state.rows())).toEqual([{ measure: 4 }]);
      expectMaterialized(state);
      const interval = { source, scale: { type: 'identity', domain: [0, 4] as [number, number] } };
      state.selection.update(state.native.interval('x', [0, 2], interval));
      await state.selection.pending('value');
      const binned = state.coordinator.preaggregator.entries.get(state.client);
      expect(Array.from(state.rows())).toEqual([{ measure: 3 }]);
      expectMaterialized(state);
      state.selection.update(state.native.interval('x', [0, 2], { ...interval, pixelSize: 2, bin: 'ceil' }));
      await state.selection.pending('value');
      expect(state.coordinator.preaggregator.entries.get(state.client)).not.toBe(binned);
      expect(Array.from(state.rows())).toEqual([{ measure: 3 }]);
      expectMaterialized(state);
      state.coordinator.executionContext({ backend: 'replacement-duckdb-session' });
      expect(state.coordinator.preaggregator.entries.size).toBe(0);
      state.selection.update(state.native.point('dim', 'b', { source }));
      await state.selection.pending('value');
      expect(Array.from(state.rows())).toEqual([{ measure: 7 }]);
      expectMaterialized(state);
      state.coordinator.clear({ clients: false });
      expect(state.coordinator.preaggregator.entries.size).toBe(0);
    } finally {
      state.client.destroy();
      state.coordinator.clear();
    }
  });

  it('reuses identity interval materialization when the domain upper bound follows the selection', async () => {
    const state = await clientFor((filter = []) => sql.Query.from('native_preagg').select({ measure: sql.sum('x') }).where(filter));
    const source = {};
    try {
      state.selection.update(state.native.interval('x', [0, 2], {
        source, scale: { type: 'identity', domain: [0, 2] }
      }));
      await state.selection.pending('value');
      expectMaterialized(state);
      expect(Array.from(state.rows())).toEqual([{ measure: 3 }]);
      const plan = state.coordinator.preaggregator.entries.get(state.client);
      if (!(plan instanceof NativePreAggregateInfo)) throw new TypeError('Expected a native preaggregation plan.');
      const table = plan.table;
      expect(state.connector.calls.filter(call => call.type === 'exec' && /CREATE TABLE/i.test(call.sql))).toHaveLength(1);
      state.selection.update(state.native.interval('x', [0, 4], {
        source, scale: { type: 'identity', domain: [0, 4] }
      }));
      await state.selection.pending('value');
      expect(Array.from(state.rows())).toEqual([{ measure: 10 }]);
      expect(state.coordinator.preaggregator.entries.get(state.client)).toBe(plan);
      expect(plan.table).toBe(table);
      expect(state.connector.calls.filter(call => call.type === 'exec' && /CREATE TABLE/i.test(call.sql))).toHaveLength(1);
      expectMaterialized(state);
    } finally {
      state.client.destroy();
      state.coordinator.clear();
    }
  });

  it('rewrites null-safe points and expression-valued selection fields by node identity', async () => {
    const state = await clientFor((filter = []) => sql.Query.from('native_preagg').select({ measure: sql.count() }).where(filter));
    const source = {};
    try {
      state.selection.update(state.native.point('x', null, { source }));
      await state.selection.pending('value');
      expect(Array.from(state.rows())).toEqual([{ measure: 1 }]);
      const expression = sql.mul('x', 2);
      state.selection.update(state.native.point(expression, 6, { source }));
      await state.selection.pending('value');
      expect(Array.from(state.rows())).toEqual([{ measure: 1 }]);
      expectMaterialized(state);
    } finally {
      state.client.destroy();
      state.coordinator.clear();
    }
  });

  it('optimizes multiple point fields and two-dimensional intervals', async () => {
    const state = await clientFor((filter = []) => sql.Query.from('native_preagg').select({ measure: sql.sum('x') }).where(filter));
    const source = {};
    try {
      state.selection.update(state.native.points(['dim', 'cat'], [['b', 'v'], ['a', 'u']], { source }));
      await state.selection.pending('value');
      expect(Array.from(state.rows())).toEqual([{ measure: 5 }]);
      expectMaterialized(state);
      state.selection.update(state.native.intervals(['x', 'y'], [[0, 4], [6, 9]], {
        source, scales: [{ type: 'identity', domain: [0, 4] }, { type: 'identity', domain: [6, 9] }]
      }));
      await state.selection.pending('value');
      expect(Array.from(state.rows())).toEqual([{ measure: 10 }]);
      expectMaterialized(state);
    } finally {
      state.client.destroy();
      state.coordinator.clear();
    }
  });

  it('bins temporal intervals through the native scale closure', async () => {
    const state = await clientFor((filter = []) => sql.Query.from('native_preagg_dates').select({ measure: sql.count() }).where(filter));
    const dates: [Date, Date] = [new Date('2024-01-01T00:00:00Z'), new Date('2024-01-03T00:00:00Z')];
    try {
      state.selection.update(state.native.interval('ts', [dates[0], new Date('2024-01-02T00:00:00Z')], {
        source: {}, scale: { type: 'utc', domain: dates, range: [0, 2] }
      }));
      await state.selection.pending('value');
      expect(Array.from(state.rows())).toEqual([{ measure: 2 }]);
      expectMaterialized(state);
    } finally {
      state.client.destroy();
      state.coordinator.clear();
    }
  });

  it.each(['create', 'read'] as const)('falls back to the original native query after a %s failure', async failure => {
    const state = await clientFor((filter = []) => sql.Query.from('native_preagg').select({ measure: sql.sum('x') }).where(filter));
    state.connector.failCreate = failure === 'create';
    state.connector.failRead = failure === 'read';
    try {
      state.selection.update(state.native.point('dim', 'b', { source: {} }));
      await state.selection.pending('value');
      expect(Array.from(state.rows())).toEqual([{ measure: 7 }]);
      expect(state.connector.calls.at(-1)?.sql).toContain('native_preagg');
      expect(state.connector.calls.at(-1)?.sql).not.toContain('preagg_');
    } finally {
      state.client.destroy();
      state.coordinator.clear();
    }
  });

  it('rebuilds writable scratch tables after source data changes and explicit schema invalidation', async () => {
    const state = await clientFor((filter = []) => sql.Query.from('native_preagg_mutable').select({ measure: sql.sum('x') }).where(filter));
    const source = {};
    state.coordinator.preaggregator.schema = 'mosaic_native_source_changes';
    try {
      state.selection.update(state.native.point('dim', 'b', { source }));
      await state.selection.pending('value');
      expect(Array.from(state.rows())).toEqual([{ measure: 1 }]);
      await state.coordinator.exec("INSERT INTO native_preagg_mutable VALUES ('b', 2)");
      await state.coordinator.preaggregator.dropSchema();
      state.selection.update(state.native.point('dim', 'b', { source }));
      await state.selection.pending('value');
      expect(Array.from(state.rows())).toEqual([{ measure: 3 }]);
      expectMaterialized(state);
    } finally {
      await state.coordinator.preaggregator.dropSchema();
      state.client.destroy();
      state.coordinator.clear();
    }
  });

  it('snapshots scalar Params once per flight after a held exec', async () => {
    const parameter = Param.value(2);
    const measure = sql.sum(sql.mul('x', sql.asLiteral(parameter)));
    const state = await clientFor((filter = []) => sql.Query.from('native_preagg').select({ measure }).where(filter));
    const read = vi.spyOn(parameter, 'value', 'get');
    const release = state.connector.hold(request => request.type === 'exec' && request.sql === 'SELECT 1');
    try {
      const barrier = state.coordinator.exec('SELECT 1');
      state.selection.update(state.native.point('dim', 'b', { source: {} }));
      await tick();
      expect(read).not.toHaveBeenCalled();
      parameter.update(3);
      await parameter.pending('value');
      release();
      await barrier;
      await state.selection.pending('value');
      expect(Array.from(state.rows())).toEqual([{ measure: 21 }]);
      expect(read).toHaveBeenCalledTimes(2);
      expectMaterialized(state);
    } finally {
      release();
      read.mockRestore();
      state.client.destroy();
      state.coordinator.clear();
    }
  });

  it('falls back safely if a scalar Param changes after CTAS dispatch, then rebuilds lazily', async () => {
    const parameter = Param.value(2);
    const measure = sql.sum(sql.mul('x', sql.asLiteral(parameter)));
    const state = await clientFor((filter = []) => sql.Query.from('native_preagg').select({ measure }).where(filter));
    const source = {};
    const release = state.connector.hold(request => request.type === 'exec' && /CREATE TABLE/i.test(request.sql));
    try {
      state.selection.update(state.native.point('dim', 'b', { source }));
      await tick();
      expect(state.connector.calls.some(call => /CREATE TABLE/i.test(call.sql))).toBe(true);
      parameter.update(3);
      await parameter.pending('value');
      release();
      await state.selection.pending('value');
      expect(Array.from(state.rows())).toEqual([{ measure: 21 }]);
      expect(state.coordinator.preaggregator.entries.has(state.client)).toBe(false);
      state.selection.update(state.native.point('dim', 'a', { source }));
      await state.selection.pending('value');
      expect(Array.from(state.rows())).toEqual([{ measure: 9 }]);
      expectMaterialized(state);
    } finally {
      release();
      state.client.destroy();
      state.coordinator.clear();
    }
  });

  it('retains authored CTE filter placement and reusable inputs during a queued scalar fallback', async () => {
    const parameter = Param.value(2);
    const reusable = sql.Query.from('native_preagg').select({ v: sql.mul('x', sql.asLiteral(parameter)) });
    const state = await clientFor((filter = []) => sql.Query.with({ derived: reusable.clone().where(filter) })
      .from('derived').select({ measure: sql.sum('v') }));
    const before = state.native.structuralKey(reusable);
    const read = vi.spyOn(parameter, 'value', 'get');
    const release = state.connector.hold(request => request.type === 'exec' && /CREATE TABLE/i.test(request.sql));
    try {
      state.selection.update(state.native.point('dim', 'b', { source: {} }));
      await tick();
      expect(state.connector.calls.some(call => call.type === 'exec' && /CREATE TABLE/i.test(call.sql))).toBe(true);
      parameter.update(3);
      await parameter.pending('value');
      release();
      await state.selection.pending('value');
      expect(Array.from(state.rows())).toEqual([{ measure: 21 }]);
      expect(read).toHaveBeenCalledTimes(2);
      expect(state.coordinator.preaggregator.entries.has(state.client)).toBe(false);
      expect(state.native.structuralKey(reusable)).toBe(before);
      expect(sql.selectEntries(reusable).map(({ alias }) => alias)).toEqual(['v']);
      expect(state.errors).toEqual([]);
      expect(state.connector.calls.at(-1)?.sql).toMatch(/WITH\s+"derived"\s+AS\s+\(SELECT.*WHERE.*"dim".*\)\s+SELECT/s);
    } finally {
      release();
      read.mockRestore();
      state.client.destroy();
      state.coordinator.clear();
    }
  });

  it('executes public native schema, CTAS, view and drop handles through the coordinator', async () => {
    const { coordinator } = await setup();
    const schema = 'native_ddl_ownership';
    const table = sql.tableRef(schema, 'rows')!;
    const view = sql.tableRef(schema, 'view')!;
    try {
      await coordinator.exec(sql.createSchema(schema));
      await coordinator.exec([
        sql.createTable(table, sql.Query.from('native_preagg').select('dim', 'x'), { temp: false }),
        sql.createTable(view, sql.Query.from(table).select('x'), { view: true })
      ]);
      expect(Array.from(await coordinator.query(sql.Query.from(view).select({ n: sql.count(), total: sql.sum('x') }))))
        .toEqual([{ n: 5, total: 10 }]);
      await coordinator.exec(sql.dropSchema(schema, { cascade: true }));
      await expect(coordinator.query(sql.Query.from(view).select('x'))).rejects.toThrow();
    } finally {
      await coordinator.exec(sql.dropSchema(schema, { ifExists: true, cascade: true }));
      coordinator.clear();
    }
  });

  it('limits native materialization to DuckDB targets', async () => {
    const native = new NativeSqlContext({ targetDialect: sql.Dialect.PostgreSQL });
    const coordinator = new Coordinator(await connection, { native, logger: null });
    expect(coordinator.preaggregator.enabled).toBe(false);
    coordinator.clear();
  });
});
