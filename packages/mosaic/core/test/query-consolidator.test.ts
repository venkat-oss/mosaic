import { SqlContext } from '../src/sql-context.js';
import { afterAll, beforeAll, describe, it, expect, vi } from 'vitest';
import { type Table, tableFromArrays, tableToIPC } from '@uwdata/flechette';
import { Query, add, columns, count, literal, sql, star, sum } from '@uwdata/mosaic-sql';
import { DuckDB } from '@uwdata/mosaic-duckdb';
import { Coordinator } from '../src/Coordinator.js';
import { NodeConnector } from '../src/connectors/NodeConnector.js';
import type { ArrowQueryRequest, Connector } from '../src/connectors/Connector.js';
import { consolidator as createConsolidator } from '../src/QueryConsolidator.js';
import { Priority } from '../src/QueryManager.js';
import type { Cache, QueryEntry } from '../src/types.js';
import { voidCache } from '../src/util/cache.js';
import { decodeIPC } from '../src/util/decode-ipc.js';
import { QueryResult, QueryState } from '../src/util/query-result.js';

function consolidator(enqueue: (entry: QueryEntry, priority?: number) => void, cache: () => Cache, generation = () => 0) {
  const context = new SqlContext();
  return createConsolidator((entry, priority) => {
    entry.prepare?.();
    enqueue(entry, priority);
  }, cache, generation, () => context);
}

describe('QueryConsolidation', () => {
  async function getConsolidatedQueries(...qs: Query[]) {
    const consolidated: string[] = [];
    const c = consolidator(q => consolidated.push(q.request.query.toString()), voidCache);
    for(const q of qs) {
      c.add({ request: { type: 'arrow', query: q }, result: new QueryResult() }, Priority.Normal);
    }
    await new Promise(resolve => setImmediate(resolve));
    return consolidated;
  }

  it('should consolidate non-grouped aggregated queries', async () => {
    const q1 = Query.from({ source: 'table' }).select({ c: count() });
    const q2 = Query.from({ source: 'table' }).select({ c: sum('foo') });
    const consolidated = await getConsolidatedQueries(q1, q2);
    expect(consolidated).toEqual([
      Query.from({ source: 'table' }).select({ col0: count(), col1: sum('foo') }).toString(),
    ]);
    });

  it('should consolidate non-grouped non-aggregated queries', async () => {
    const q1 = Query.from({ source: 'table' }).select({ c: 'x' });
    const q2 = Query.from({ source: 'table' }).select({ c: 'y' });
    const consolidated = await getConsolidatedQueries(q1, q2);
    expect(consolidated).toEqual([
      Query.from({ source: 'table' }).select({ col0: 'x', col1: 'y' }).toString(),
    ]);
  });

  it('should consolidate grouped aggregated queries', async () => {
    const q1 = Query.from({ source: 'table' }).select({ c: count() }).groupby('bar');
    const q2 = Query.from({ source: 'table' }).select({ c: sum('foo') }).groupby('bar');
    const consolidated = await getConsolidatedQueries(q1, q2);
    expect(consolidated).toEqual([
      Query.from({ source: 'table' })
        .select({ col0: count(), col1: sum('foo') })
        .groupby('bar')
        .toString(),
    ]);
  });

  it('should consolidate grouped aggregated queries with different group by orders', async () => {
    const q1 = Query.from({ source: 'table' }).select({ c: count() }).groupby('bar', 'baz');
    const q2 = Query.from({ source: 'table' }).select({ c: sum('foo') }).groupby('baz', 'bar');
    const consolidated = await getConsolidatedQueries(q1, q2);
    expect(consolidated).toEqual([
      Query.from({ source: 'table' })
        .select({ col0: count(), col1: sum('foo') })
        .groupby('bar', 'baz')
        .toString(),
    ]);
  });

  it('should consolidate grouped aggregated queries with positional reference', async () => {
    const q1 = Query.from({ source: 'table' }).select({ b: 'bar', c: count() }).groupby('bar');
    const q2 = Query.from({ source: 'table' }).select({ b: 'bar', c: sum('foo') }).groupby(literal(1));
    const consolidated = await getConsolidatedQueries(q1, q2);
    expect(consolidated).toEqual([
      Query.from({ source: 'table' })
        .select({ col0: 'bar', col1: count(), col2: sum('foo') })
        .groupby('bar')
        .toString(),
    ]);
  });

  it('should consolidate grouped aggregated queries with positional reference first', async () => {
    const q1 = Query.from({ source: 'table' }).select({ a: 'bar', b: 'bar', c: count() }).groupby(literal(2));
    const q2 = Query.from({ source: 'table' }).select({ b: 'bar', c: sum('foo') }).groupby('bar');
    const consolidated = await getConsolidatedQueries(q1, q2);
    expect(consolidated).toEqual([
      Query.from({ source: 'table' })
        .select({ col0: 'bar', col1: count(), col2: sum('foo') })
        .groupby('bar')
        .toString(),
    ]);
  });

  it('should not consolidate non-grouped aggregated and non-aggregated queries', async () => {
    const q1 = Query.from({ source: 'table' }).select({ c: 'x' });
    const q2 = Query.from({ source: 'table' }).select({ c: count() });
    const consolidated = await getConsolidatedQueries(q1, q2);
    expect(consolidated).toEqual([
      q1.toString(),
      q2.toString(),
    ]);
  });

  it('should not consolidate select distinct queries', async () => {
    const q1 = Query.from({ source: 'table' }).select({ u: 'x' }).distinct();
    const q2 = Query.from({ source: 'table' }).select({ v: 'y' });
    const q3 = Query.from({ source: 'table' }).select({ w: 'z' });
    const consolidated = await getConsolidatedQueries(q1, q2, q3);
    expect(consolidated).toEqual([
      q1.toString(),
      Query.from({ source: 'table' }).select({ col0: 'y', col1: 'z' }).toString(),
    ]);
  });
});

describe('QueryConsolidationCaching', () => {
  it('rejects every original request if any projected result fails', async () => {
    const entries: QueryEntry[] = ['x', 'y'].map(c => ({
      request: {type: 'arrow', query: Query.from('source').select({c}), cache: true},
      result: new QueryResult()
    }));
    const data = tableFromArrays({col0: [1]});
    const set = vi.fn();
    const cache: Cache = {get: () => undefined, set, clear: () => {}, bytes: () => 0};
    const c = consolidator(entry => entry.result.fulfill(data), () => cache);
    for (const entry of entries) c.add(entry, Priority.Normal);

    const results = await Promise.allSettled(entries.map(({result}) => result));
    expect(results.map(result => result.status)).toEqual(['rejected', 'rejected']);
    expect(set).not.toHaveBeenCalled();
  });

  it('should charge projected extracts to the merged table', async () => {
    const bytes = tableToIPC(tableFromArrays({ col0: [1, 2], col1: [3, 4] }), {})!;
    const data = decodeIPC(bytes);
    const queries = ['x', 'y'].map(c => Query.from({ source: 'table' }).select({ c }));
    const entries: QueryEntry[] = queries.map(query => ({
      request: { type: 'arrow', cache: true, query },
      result: new QueryResult()
    }));

    const calls: unknown[][] = [];
    const cache: Cache = {
      get: () => undefined,
      set: (...args) => (calls.push(args), args[1]),
      clear: () => {},
      bytes: () => 0
    };
    const c = consolidator(entry => {
      if (entry.request.cache === false) entry.result.fulfill(data);
    }, () => cache);
    for (const entry of entries) {
      c.add(entry, Priority.Normal);
    }
    const extracts = await Promise.all(entries.map(entry => entry.result)) as Table[];

    expect(Array.from(extracts[1])).toEqual([{ c: 3 }, { c: 4 }]);
    expect(calls).toEqual([
      [new SqlContext().cacheKey(String(queries[0])), extracts[0], bytes.length],
      [new SqlContext().cacheKey(String(queries[1])), extracts[1], bytes.length]
    ]);

    const remove = vi.fn(() => true);
    c.remove(remove);
    expect(remove).not.toHaveBeenCalled();
  });

  it('delivers but does not cache extracts from an older generation', async () => {
    const data = decodeIPC(tableToIPC(tableFromArrays({ col0: [1, 2], col1: [3, 4] }), {})!);
    const queries = ['x', 'y'].map(c => Query.from({ source: 'table' }).select({ c }));
    const entries: QueryEntry[] = queries.map(query => ({
      request: { type: 'arrow', cache: true, query },
      result: new QueryResult()
    }));

    const calls: unknown[][] = [];
    const cache: Cache = {
      get: () => undefined,
      set: (...args) => (calls.push(args), args[1]),
      clear: () => {},
      bytes: () => 0
    };
    let generation = 0;
    const combined: QueryEntry[] = [];
    const c = consolidator(entry => combined.push(entry), () => cache, () => generation);
    for (const entry of entries) {
      c.add(entry, Priority.Normal);
    }
    await new Promise(resolve => setImmediate(resolve));

    generation += 1;
    combined[0].result.fulfill(data);
    const extracts = await Promise.all(entries.map(entry => entry.result)) as Table[];

    expect(Array.from(extracts[1])).toEqual([{ c: 3 }, { c: 4 }]);
    expect(calls).toEqual([]);
  });

  it('does not deliver to entries removed before their extracts', async () => {
    const data = decodeIPC(tableToIPC(tableFromArrays({ col0: [1, 2], col1: [3, 4] }), {})!);
    const entries: QueryEntry[] = ['x', 'y'].map(c => ({
      request: { type: 'arrow', query: Query.from({ source: 'table' }).select({ c }) },
      result: new QueryResult()
    }));
    const combined: QueryEntry[] = [];
    const c = consolidator(entry => combined.push(entry), voidCache);
    for (const entry of entries) {
      c.add(entry, Priority.Normal);
    }
    await new Promise(resolve => setImmediate(resolve));

    const rejected = entries.map(({ result }) => expect(result).rejects.toBe('Cleared'));
    combined[0].result.fulfill(data);
    c.remove(({ result }) => (result.reject('Cleared'), true));
    await Promise.all(rejected);
    await new Promise(resolve => setImmediate(resolve));

    expect(entries.map(({ result }) => result.state)).toEqual([QueryState.error, QueryState.error]);
  });
});

describe('Native consolidated query results', () => {
  const db = new DuckDB();
  const connector = NodeConnector.make(db);
  beforeAll(async () => {
    await db.exec('CREATE TABLE consolidation_data AS SELECT 1 AS x, 2 AS y');
  });
  afterAll(() => db.close());

  it.each([
    {name: 'star', projection: '*', names: ['x', 'y'], expected: [1, 2]},
    {name: 'qualified star', projection: star('consolidation_data'), names: ['x', 'y'], expected: [1, 2]},
    {name: 'modified star', projection: star(null, {rename: {y: 'z'}}), names: ['x', 'z'], expected: [1, 2]},
    {name: 'columns', projection: columns(['x', 'y']), names: ['x', 'y'], expected: [1, 2]},
    {name: 'raw star', projection: {computed: sql`*`}, names: ['computed', 'computed'], expected: [1, 2]},
    {name: 'raw qualified star', projection: {computed: sql`consolidation_data.*`}, names: ['computed', 'computed'], expected: [1, 2]},
    {name: 'raw columns', projection: {computed: sql`COLUMNS(['x', 'y'])`}, names: ['computed', 'computed'], expected: [1, 2]},
    {name: 'commented raw columns', projection: {computed: sql`columns /* projected */ (['x', 'y'])`}, names: ['computed', 'computed'], expected: [1, 2]},
    {name: 'nested columns', projection: {computed: add(columns(['x', 'y']), 1)}, names: ['computed', 'computed'], expected: [2, 3]}
  ])('preserves every $name output alongside a scalar query', async ({projection, names, expected}) => {
    const coordinator = new Coordinator(await connector, {logger: null});
    try {
      const [expanded, scalar] = await Promise.all([
        coordinator.query(Query.from('consolidation_data').select(projection)),
        coordinator.query(Query.from('consolidation_data').select('x'))
      ]);
      expect(expanded.schema.fields.map(field => field.name)).toEqual(names);
      expect(expanded.numRows).toBe(1);
      expect(expanded.schema.fields.map((_, index) => expanded.getChildAt(index).at(0))).toEqual(expected);
      expect(Array.from(scalar)).toEqual([{x: 1}]);
    } finally {
      coordinator.clear();
    }
  });

  it.each(['before decode', 'after decode'])('isolates extraction options changed %s from cached and in-flight results', async timing => {
    const native = await connector;
    const responses: Promise<unknown>[] = [];
    const coordinator = new Coordinator({
      query(request: ArrowQueryRequest) {
        const response = native.query(request);
        responses.push(response);
        return response;
      }
    } as Connector, {logger: null, consolidate: false});
    try {
      const sql = "SELECT DATE '2024-01-01' AS value";
      const first = coordinator.query(sql);
      if (timing === 'after decode') await responses[0].then(() => coordinator.manager.ipc({useDate: false}));
      else coordinator.manager.ipc({useDate: false});
      const second = coordinator.query(sql);
      const [oldResult, newResult] = await Promise.all([first, second]);
      expect(oldResult.getChild('value').at(0)).toEqual(new Date('2024-01-01T00:00:00Z'));
      expect(newResult.getChild('value').at(0)).toBe(1704067200000);
      expect(await coordinator.query(sql)).toBe(newResult);
      expect(responses).toHaveLength(2);
    } finally {
      coordinator.clear();
    }
  });
});
