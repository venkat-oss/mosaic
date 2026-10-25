import { beforeEach, describe, expect, it, vi } from 'vitest';
import { tableFromIPC } from '@uwdata/flechette';

const mock = vi.hoisted(() => ({ clients: [] as {
  config: unknown;
  connect: ReturnType<typeof vi.fn>;
  end: ReturnType<typeof vi.fn>;
  query: ReturnType<typeof vi.fn>;
}[] }));

vi.mock('pg', () => ({
  Client: class {
    connect = vi.fn(async () => {});
    end = vi.fn(async () => {});
    on() { return this; }
    query = vi.fn(async (input: string | { text: string }, values?: number[][]) => {
      const text = typeof input === 'string' ? input : input.text;
      if (text === 'SELECT pg_backend_pid() AS pid') return { rows: [{ pid: '123' }] };
      if (text.startsWith('SELECT f.position')) return { rows: values![0].map(() => ({ sql_type: 'integer', base_not_null: null })) };
      return { fields: [{ name: 'value', tableID: 0, columnID: 0, dataTypeID: 23, dataTypeModifier: -1, dataTypeSize: 4, format: 'text' }], rows: [['7']] };
    });
    constructor(readonly config: unknown) { mock.clients.push(this); }
  }
}));

import { PostgresConnector } from '../src/index.js';

function deferred<T>() {
  let resolve!: (value: T) => void;
  let reject!: (error: unknown) => void;
  const promise = new Promise<T>((ok, fail) => { resolve = ok; reject = fail; });
  return { promise, resolve, reject };
}

beforeEach(() => { mock.clients.length = 0; });

describe('PostgreSQL connector session ordering', () => {
  it('uses per-client raw parsers and serializes database and metadata queries', async () => {
    const connector = await PostgresConnector.make({ database: 'mosaic' });
    try {
      expect(mock.clients).toHaveLength(2);
      const config = mock.clients[0].config as { types: { getTypeParser: (oid: number, format?: string) => (value: string) => string }; query_timeout: number; binary: boolean };
      expect(config.types.getTypeParser(20)('9223372036854775807')).toBe('9223372036854775807');
      expect(config.query_timeout).toBe(0);
      expect(config.binary).toBe(false);
      expect(() => config.types.getTypeParser(20, 'binary')).toThrow(/text protocol/);
      const bytes = await connector.query({ type: 'arrow', sql: 'SELECT 7 AS value' });
      expect(tableFromIPC(bytes).getChild('value')!.at(0)).toBe(7);
      expect(mock.clients[0].query.mock.calls.map(([query]) => typeof query === 'string' ? query : query.text)).toEqual([
        expect.stringContaining('SET TIME ZONE'), 'SELECT pg_backend_pid() AS pid', 'SELECT 7 AS value', expect.stringContaining('SELECT f.position')
      ]);
    } finally { await connector.close(); }
  });

  it('holds the queue until a late cancellation is acknowledged', async () => {
    const connector = await PostgresConnector.make();
    const active = deferred<unknown>();
    const started = deferred<void>();
    const ack = deferred<unknown>();
    const data = mock.clients[0];
    const control = mock.clients[1];
    data.query.mockImplementationOnce(() => { started.resolve(); return active.promise; });
    control.query.mockImplementationOnce(() => ack.promise);
    const controller = new AbortController();
    const reason = new Error('stop this query');
    const first = connector.query({ type: 'exec', sql: 'SELECT pg_sleep(60)' }, { signal: controller.signal });
    const rejected = expect(first).rejects.toBe(reason);
    await started.promise;
    const second = connector.query({ type: 'exec', sql: 'SELECT 2' });
    controller.abort(reason);
    active.resolve({ fields: [], rows: [] });
    await Promise.resolve();
    await Promise.resolve();
    expect(control.query).toHaveBeenCalledExactlyOnceWith('SELECT pg_cancel_backend($1)', [123]);
    expect(data.query.mock.calls.some(([query]) => query.text === 'SELECT 2')).toBe(false);
    ack.resolve({ rows: [{ pg_cancel_backend: 't' }] });
    await rejected;
    await second;
    expect(data.query.mock.calls.some(([query]) => query.text === 'SELECT 2')).toBe(true);
    await connector.close();
  });

  it('never submits a queued query whose signal was canceled', async () => {
    const connector = await PostgresConnector.make();
    const active = deferred<unknown>();
    const started = deferred<void>();
    const data = mock.clients[0];
    data.query.mockImplementationOnce(() => { started.resolve(); return active.promise; });
    const first = connector.query({ type: 'exec', sql: 'SELECT 1' });
    await started.promise;
    const controller = new AbortController();
    const skipped = connector.query({ type: 'exec', sql: 'SELECT 999' }, { signal: controller.signal });
    const rejected = expect(skipped).rejects.toMatchObject({ name: 'AbortError' });
    controller.abort();
    active.resolve({ fields: [], rows: [] });
    await first;
    await rejected;
    expect(data.query.mock.calls.some(([query]) => query.text === 'SELECT 999')).toBe(false);
    expect(mock.clients[1].query).not.toHaveBeenCalled();
    await connector.close();
  });

  it('closes both owned sessions once and rejects later work', async () => {
    const connector = await PostgresConnector.make();
    const closing = connector.close();
    expect(connector.close()).toBe(closing);
    await closing;
    expect(mock.clients.every(client => client.end.mock.calls.length === 1)).toBe(true);
    await expect(connector.query({ type: 'exec', sql: 'SELECT 1' })).rejects.toThrow(/closed/);
  });
});
