import { tableFromArrays, tableToIPC } from '@uwdata/flechette';
import { DuckDB } from '@uwdata/mosaic-duckdb';
import { column, literal, Query } from '@uwdata/mosaic-sql';

import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { Coordinator, makeClient, MosaicClient, SqlContext, Param, queryFieldInfo } from '../src/index.js';
import type { Connector, ConnectorQueryOptions, ConnectorQueryRequest, JSType } from '../src/index.js';
import { NodeConnector } from '../src/connectors/NodeConnector.js';

function deferred<T = void>() {
  let resolve!: (value: T | PromiseLike<T>) => void;
  const promise = new Promise<T>(ready => { resolve = ready; });
  return { promise, resolve };
}

const flush = () => new Promise(resolve => setImmediate(resolve));

describe('native client request lifecycle', () => {
  const db = new DuckDB();
  let connection: Connector;
  beforeAll(async () => {
    await db.exec(`CREATE TABLE client_before AS SELECT 1 AS x, 100 AS y;
      CREATE TABLE client_after AS SELECT 2 AS x, 'current' AS y`);
    connection = await NodeConnector.make(db);
  });
  afterAll(() => db.close());

  it('cancels a queued read when identifier/source metadata changes while preserving unrelated clients', async () => {
    const gate = deferred();
    const calls: ConnectorQueryRequest[] = [];
    const connector = {
      async query(request: ConnectorQueryRequest, options?: ConnectorQueryOptions) {
        calls.push(request);
        if (request.type === 'exec') await gate.promise;
        return request.type === 'arrow'
          ? connection.query({ ...request, type: 'arrow' }, options)
          : connection.query({ ...request, type: 'exec' }, options);
      }
    } as unknown as Connector;
    const native = new SqlContext();
    const mc = new Coordinator(connector, { sql: native, logger: null, consolidate: false, preagg: { enabled: false } });
    const results: unknown[] = [];
    const errors: unknown[] = [];
    class Client extends MosaicClient {
      table = 'client_before';
      field = Param.value('x');
      type?: JSType;
      constructor() { super(); }
      async prepare() {
        const pending = this.pending;
        const [info] = await queryFieldInfo(mc, [{ table: this.table, column: column(this.field) }]);
        if (pending === this.pending) this.type = info.type;
      }
      query() { return Query.from(this.table).select({ value: column(this.field) }); }
      queryResult(data: Iterable<unknown>) { results.push(Array.from(data)); return this; }
      queryError(error: unknown) { errors.push(error); return this; }
    }
    const client = new Client();
    mc.connect(client);
    await client.pending;
    expect(client.type).toBe('number');
    results.length = 0;
    calls.length = 0;
    const held = mc.exec('SELECT 1');
    const old = client.requestQuery();
    const other: unknown[] = [];
    const unrelated = makeClient({
      coordinator: mc,
      query: () => Query.select({ keep: literal(99) }),
      queryResult: data => other.push(Array.from(data as Iterable<unknown>))
    });
    client.table = 'client_after';
    client.field.update('y');
    client.initialize();
    const current = client.pending;
    await flush();
    expect(calls).toHaveLength(1);
    gate.resolve();
    await Promise.all([held, old, current, unrelated.pending]);
    expect(calls.some(call => call.sql.includes('client_before'))).toBe(false);
    expect(client.type).toBe('string');
    expect(results).toEqual([[{ value: 'current' }]]);
    expect(other).toEqual([[{ keep: 99 }]]);
    expect(errors).toEqual([]);
    client.destroy();
    unrelated.destroy();
    mc.clear();
  });

  it.each(['resolve', 'reject'] as const)('ignores a superseded shared read on %s without canceling its other client', async outcome => {
    const calls: {
      request: ConnectorQueryRequest;
      signal?: AbortSignal;
      resolve(value: unknown): void;
      reject(error: unknown): void;
    }[] = [];
    const connector = {
      query(request: ConnectorQueryRequest, options?: ConnectorQueryOptions) {
        return new Promise((resolve, reject) => calls.push({ request, signal: options?.signal, resolve, reject }));
      }
    } as unknown as Connector;
    const native = new SqlContext();
    const mc = new Coordinator(connector, { sql: native, logger: null, consolidate: false, preagg: { enabled: false } });
    const firstRows: unknown[] = [];
    const firstErrors: unknown[] = [];
    const otherRows: unknown[] = [];
    const otherErrors: unknown[] = [];
    let value = 1;
    const first = makeClient({
      coordinator: mc,
      query: () => Query.select({ value: literal(value) }),
      queryResult: data => firstRows.push(Array.from(data as Iterable<unknown>)),
      queryError: error => firstErrors.push(error)
    });
    const other = makeClient({
      coordinator: mc,
      query: () => Query.select({ value: literal(1) }),
      queryResult: data => otherRows.push(Array.from(data as Iterable<unknown>)),
      queryError: error => otherErrors.push(error)
    });
    await flush();
    expect(calls).toHaveLength(1);
    const old = first.pending;
    value = 2;
    first.initialize();
    const current = first.pending;
    const update = deferred();
    first.update = () => update.promise;
    let done = false;
    current.then(() => { done = true; });
    await flush();
    expect(calls).toHaveLength(2);
    expect(calls[0].signal?.aborted).toBe(false);
    calls[1].resolve(tableToIPC(tableFromArrays({ value: [2] }), {})!);
    if (outcome === 'resolve') calls[0].resolve(tableToIPC(tableFromArrays({ value: [1] }), {})!);
    else calls[0].reject(new Error('old read failed'));
    await flush();
    expect(done).toBe(false);
    update.resolve();
    await Promise.all([old, current, other.pending]);
    expect(firstRows).toEqual([[{ value: 2 }]]);
    expect(firstErrors).toEqual([]);
    expect(otherRows).toEqual(outcome === 'resolve' ? [[{ value: 1 }]] : []);
    expect(otherErrors).toHaveLength(outcome === 'resolve' ? 0 : 1);
    first.destroy();
    other.destroy();
    mc.clear();
  });

  it('does not issue reads from obsolete or destroyed preparation continuations', async () => {
    const native = new SqlContext();
    const mc = new Coordinator(connection, { sql: native, logger: null, preagg: { enabled: false } });
    const prepares: ReturnType<typeof deferred<void>>[] = [];
    const queries: number[] = [];
    const client = makeClient({
      coordinator: mc,
      prepare: () => {
        const gate = deferred();
        prepares.push(gate);
        return gate.promise;
      },
      query: () => { queries.push(prepares.length); return Query.select({ value: literal(1) }); }
    });
    const old = client.pending;
    await flush();
    client.initialize();
    const current = client.pending;
    await flush();
    prepares[1].resolve();
    await current;
    prepares[0].resolve();
    await old;
    expect(queries).toEqual([2]);
    client.initialize();
    const destroyed = client.pending;
    await flush();
    client.destroy();
    prepares[2].resolve();
    await destroyed;
    expect(queries).toEqual([2]);
    mc.clear();
  });

  it('finishes metadata preparation while disabled and defers the data request until enabled', async () => {
    const native = new SqlContext();
    const mc = new Coordinator(connection, { sql: native, logger: null, preagg: { enabled: false } });
    const ready = deferred();
    const rows: unknown[] = [];
    const client = makeClient({
      coordinator: mc,
      prepare: () => ready.promise,
      query: () => Query.select({ value: literal(1) }),
      queryResult: data => rows.push(Array.from(data as Iterable<unknown>))
    });
    await flush();
    client.enabled = false;
    ready.resolve();
    await client.pending;
    expect(client.initialized).toBe(true);
    expect(rows).toEqual([]);
    client.enabled = true;
    await client.pending;
    expect(rows).toEqual([[{ value: 1 }]]);
    client.destroy();
    mc.clear();
  });

  it('ignores obsolete preparation errors while retaining errors from current preparation', async () => {
    const native = new SqlContext();
    const mc = new Coordinator(connection, { sql: native, logger: null, preagg: { enabled: false } });
    const prepares: { reject(reason: unknown): void; promise: Promise<void> }[] = [];
    const client = makeClient({
      coordinator: mc,
      prepare: () => {
        let reject!: (reason: unknown) => void;
        const promise = new Promise<void>((_resolve, fail) => { reject = fail; });
        prepares.push({ reject, promise });
        return promise;
      }
    });
    const obsolete = client.pending;
    await flush();
    client.initialize();
    const current = expect(client.pending).rejects.toThrow('current metadata failed');
    await flush();
    prepares[0].reject(new Error('obsolete metadata failed'));
    await expect(obsolete).resolves.toBeUndefined();
    prepares[1].reject(new Error('current metadata failed'));
    await current;
    client.destroy();
    mc.clear();
  });
});
