import { tableFromArrays, tableToIPC } from '@uwdata/flechette';
import { column, Dialect, from, gt, idiv, join, literal, Query, sql } from '@uwdata/mosaic-sql';
import type { SqlSourceSchema } from '@uwdata/mosaic-sql';
import { describe, expect, it } from 'vitest';
import { Coordinator } from '../src/Coordinator.js';
import type { ArrowQueryRequest, Connector, ConnectorQueryOptions, ExecQueryRequest } from '../src/connectors/Connector.js';
import type { ArrowIPCBytes, QueryType } from '../src/types.js';
import { SqlContext } from '../src/sql-context.js';

const bytes = tableToIPC(tableFromArrays({ value: [1] }), {})!;

class TestConnector implements Connector {
  readonly calls: { request: ArrowQueryRequest | ExecQueryRequest; options?: ConnectorQueryOptions }[] = [];
  beforeArrow?: () => Promise<void>;

  constructor(readonly dialect: 'duckdb' | 'postgres') {}

  query(request: ArrowQueryRequest, options?: ConnectorQueryOptions): Promise<ArrowIPCBytes>;
  query(request: ExecQueryRequest, options?: ConnectorQueryOptions): Promise<void>;
  async query(request: ArrowQueryRequest | ExecQueryRequest, options?: ConnectorQueryOptions): Promise<ArrowIPCBytes | void> {
    this.calls.push({ request, options });
    if (request.type === 'arrow') {
      await this.beforeArrow?.();
      return bytes;
    }
  }
}

describe('connector backend profiles', () => {
  it('selects PostgreSQL generation while preserving DuckDB source semantics', async () => {
    const connector = new TestConnector('postgres');
    const coordinator = new Coordinator(connector, { logger: null, consolidate: false });
    try {
      expect(coordinator.executionContext()).toMatchObject({
        backend: 'postgres', sourceDialect: Dialect.DuckDB, targetDialect: Dialect.PostgreSQL
      });
      expect(coordinator.preaggregator.enabled).toBe(false);
      expect(Array.from(await coordinator.query(Query.select({ value: literal(1) })))).toEqual([{ value: 1 }]);
      expect(connector.calls[0].request).toEqual({ type: 'arrow', sql: 'SELECT 1 AS "value"' });
    } finally { coordinator.clear(); }
  });

  it('rejects explicit PostgreSQL preaggregation at construction and through the setter', () => {
    expect(() => new Coordinator(new TestConnector('postgres'), { logger: null, preagg: { enabled: true } }))
      .toThrow(/preaggregation.*not supported/i);
    const coordinator = new Coordinator(new TestConnector('postgres'), { logger: null });
    try {
      expect(() => { coordinator.preaggregator.enabled = true; }).toThrow(/preaggregation.*not supported/i);
      expect(coordinator.preaggregator.enabled).toBe(false);
    } finally { coordinator.clear(); }
  });

  it('updates connection generation, target and default materialization when swapping backends', () => {
    const postgres = new TestConnector('postgres');
    const duckdb = new TestConnector('duckdb');
    const coordinator = new Coordinator(postgres, { logger: null });
    try {
      const before = coordinator.executionContext();
      expect(coordinator.databaseConnector(duckdb)).toBe(duckdb);
      expect(coordinator.executionContext()).toMatchObject({
        backend: 'duckdb', sourceDialect: Dialect.DuckDB, targetDialect: Dialect.DuckDB,
        generation: before.generation + 1
      });
      expect(coordinator.preaggregator.enabled).toBe(true);
      coordinator.databaseConnector(postgres);
      expect(coordinator.executionContext()).toMatchObject({
        backend: 'postgres', targetDialect: Dialect.PostgreSQL, generation: before.generation + 2
      });
      expect(coordinator.preaggregator.enabled).toBe(false);
    } finally { coordinator.clear(); }
  });

  it('retains an explicit materialization disable when a supported backend is selected', () => {
    const coordinator = new Coordinator(new TestConnector('postgres'), { logger: null, preagg: { enabled: false } });
    try {
      coordinator.databaseConnector(new TestConnector('duckdb'));
      expect(coordinator.preaggregator.enabled).toBe(false);
      coordinator.preaggregator.enabled = true;
      expect(coordinator.preaggregator.enabled).toBe(true);
    } finally { coordinator.clear(); }
  });

  it('invalidates cached and pending reads when only the source schema changes', async () => {
    const schema = (type: string): SqlSourceSchema => ({
      tables: [{ name: 'measurements', columns: [{ name: 'a', type }, { name: 'b', type }] }]
    });
    const connector = new TestConnector('duckdb');
    const coordinator = new Coordinator(connector, {
      logger: null, consolidate: false,
      sql: new SqlContext({ targetDialect: Dialect.SQLite, sourceSchema: schema('INTEGER') })
    });
    let release = () => {};
    const held = new Promise<void>(resolve => { release = resolve; });
    const query = Query.from('measurements').select({ value: idiv('a', 'b') });
    try {
      const previous = coordinator.executionContext();
      const cached = await coordinator.query(query);
      const oldKey = coordinator.sqlContext.cacheKey(connector.calls[0].request.sql, previous);
      expect(coordinator.manager.cache().get(oldKey)).toBe(cached);
      connector.beforeArrow = () => held;
      const obsolete = coordinator.query(query.clone().where(gt('a', 0)));
      const rejected = expect(obsolete).rejects.toBe('Cleared');
      expect(connector.calls).toHaveLength(2);
      const signal = connector.calls[1].options!.signal!;
      coordinator.executionContext({ sourceSchema: schema('DOUBLE') });
      await rejected;
      expect(signal.aborted).toBe(true);
      expect(coordinator.manager.cache().get(oldKey)).toBeUndefined();
      expect(coordinator.executionContext().generation).toBe(previous.generation + 1);
      expect(coordinator.executionContext().targetDialect).toBe(previous.targetDialect);
      connector.beforeArrow = undefined;
      release();
      const current = await coordinator.query(query);
      expect(current).not.toBe(cached);
      expect(connector.calls).toHaveLength(3);
      expect(connector.calls[0].request.sql).toMatch(/AS INTEGER/i);
      expect(connector.calls[2].request.sql).not.toMatch(/AS INTEGER/i);
      expect(await coordinator.query(query)).toBe(current);
      expect(connector.calls).toHaveLength(3);
    } finally {
      release();
      coordinator.clear();
    }
  });

  it('keeps an initial source schema and clears it when the database connector is replaced', () => {
    const sourceSchema: SqlSourceSchema = {
      tables: [{ name: 'measurements', columns: [{ name: 'a', type: 'INTEGER' }] }]
    };
    const first = new TestConnector('duckdb');
    const coordinator = new Coordinator(first, { logger: null, sql: new SqlContext({ sourceSchema }) });
    try {
      const previous = coordinator.executionContext();
      expect(previous.sourceSchema).toEqual(sourceSchema);
      coordinator.databaseConnector(first);
      expect(coordinator.executionContext()).toBe(previous);
      coordinator.databaseConnector(new TestConnector('postgres'));
      expect(coordinator.executionContext().sourceSchema).toBeUndefined();
      expect(coordinator.executionContext().generation).toBe(previous.generation + 1);
      expect(coordinator.executionContext().targetDialect).toBe(Dialect.PostgreSQL);
    } finally { coordinator.clear(); }
  });
});

const base = Query.from('base_rows').select('value');
const cases: { name: string; query: QueryType; supported: boolean }[] = [
  { name: 'plain base table', query: base, supported: true },
  { name: 'aliased base table', query: Query.from(from('base_rows', 'rows')).select(column('value', 'rows')), supported: true },
  { name: 'canonical SELECT data', query: base.expression, supported: true },
  { name: 'grouped base table', query: base.clone().groupby('value'), supported: false },
  { name: 'ROLLUP grouping', query: sql`SELECT value FROM base_rows GROUP BY ROLLUP(value)`, supported: false },
  { name: 'CUBE grouping', query: sql`SELECT value FROM base_rows GROUP BY CUBE(value)`, supported: false },
  { name: 'GROUPING SETS', query: sql`SELECT value FROM base_rows GROUP BY GROUPING SETS ((value), ())`, supported: false },
  { name: 'CTE source', query: Query.with({ rows: base }).from('rows').select('value'), supported: false },
  { name: 'unused CTE', query: base.clone().with({ unused: Query.select({ value: literal(1) }) }), supported: false },
  { name: 'subquery source', query: Query.from(base).select('value'), supported: false },
  { name: 'outer join', query: Query.from(join('base_rows', 'other_rows', { type: 'LEFT', using: ['value'] })).select('value'), supported: false },
  { name: 'multiple sources', query: Query.from('base_rows', 'other_rows').select(column('value', 'base_rows')), supported: false },
  { name: 'raw SQL string', query: 'SELECT value FROM base_rows', supported: false },
  { name: 'parsed result template', query: sql`SELECT value FROM base_rows`, supported: true },
  { name: 'no source', query: Query.select({ value: literal(1) }), supported: false }
];

it.each(cases)('provides conservative base-column nullability for $name', async ({ query, supported }) => {
  const connector = new TestConnector('duckdb');
  const coordinator = new Coordinator(connector, { logger: null, cache: false, consolidate: false });
  try {
    await coordinator.query(query);
    expect(connector.calls).toHaveLength(1);
    expect(connector.calls[0].options?.baseColumnNullability).toBe(supported);
    expect(connector.calls[0].options?.signal).toBeInstanceOf(AbortSignal);
    expect(Object.keys(connector.calls[0].request).sort()).toEqual(['sql', 'type']);
  } finally { coordinator.clear(); }
});
