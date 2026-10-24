import { tableFromArrays, tableToIPC } from '@uwdata/flechette';
import type { ArrowIPCBytes } from '../src/types.js';
import type { ArrowQueryRequest, Connector, ConnectorQueryOptions, ExecQueryRequest } from '../src/connectors/Connector.js';
import { asLiteral, column, count, gte, Query } from '@uwdata/mosaic-sql/native';
import type { ParamLike } from '@uwdata/mosaic-sql';
import { describe, expect, it } from 'vitest';
import { NativeSqlContext } from '../src/native-sql.js';
import { Param } from '../src/Param.js';
import { QueryManager } from '../src/QueryManager.js';

interface Call {
  request: ArrowQueryRequest | ExecQueryRequest;
  signal?: AbortSignal;
  resolve(value: ArrowIPCBytes | void): void;
  reject(reason: unknown): void;
}

class HeldConnector implements Connector {
  readonly calls: Call[] = [];

  query(request: ArrowQueryRequest, options?: ConnectorQueryOptions): Promise<ArrowIPCBytes>;
  query(request: ExecQueryRequest, options?: ConnectorQueryOptions): Promise<void>;
  query(request: ArrowQueryRequest | ExecQueryRequest, options?: ConnectorQueryOptions): Promise<ArrowIPCBytes | void> {
    return new Promise((resolve, reject) => {
      this.calls.push({ request, signal: options?.signal, resolve, reject });
    });
  }
}

const bytes = tableToIPC(tableFromArrays({ n: [1] }), {})!;
const flush = () => new Promise<void>(resolve => setImmediate(resolve));
const query = () => Query.from('rows').select({ n: count() });

function setup() {
  const manager = new QueryManager();
  const connector = new HeldConnector();
  const native = new NativeSqlContext();
  manager.nativeContext(native);
  manager.connector(connector);
  manager.cache(true);
  manager.consolidate(true);
  return { manager, connector, native };
}

describe('native query submission', () => {
  it('resolves scalar and identifier changes after an exec barrier', async () => {
    const { manager, connector } = setup();
    const field = Param.value('before');
    const threshold = Param.value(1);
    const block = manager.request({ type: 'exec', query: 'SELECT 1' });
    const result = manager.request({
      type: 'arrow',
      query: Query.from('rows').select({ n: count() }).where(gte(column(field), asLiteral(threshold)))
    });
    expect(connector.calls).toHaveLength(1);
    field.update('after');
    threshold.update(7);
    await Promise.all([field.pending('value'), threshold.pending('value')]);
    connector.calls[0].resolve(undefined);
    await block;
    await flush();
    expect(connector.calls[1].request.sql).toContain('"after"');
    expect(connector.calls[1].request.sql).toContain('7');
    connector.calls[1].resolve(bytes);
    await result;
  });

  it('keeps the old exec barrier while replacing a connection and dropping old cache state', async () => {
    const { manager, connector, native } = setup();
    const oldGeneration = native.execution.generation;
    const blocked = manager.request({ type: 'exec', query: 'SELECT 1' });
    const cleared = expect(blocked).rejects.toBe('Cleared');
    const replacement = new HeldConnector();
    manager.connector(replacement);
    await cleared;
    expect(native.execution.generation).toBe(oldGeneration + 1);
    expect(connector.calls[0].signal?.aborted).toBe(false);
    const next = manager.request({ type: 'arrow', query: query(), cache: true });
    expect(replacement.calls).toHaveLength(0);
    connector.calls[0].resolve(undefined);
    await flush();
    expect(replacement.calls).toHaveLength(1);
    replacement.calls[0].resolve(bytes);
    await next;
    manager.clear();
  });

  it('aborts old reads and ignores their late results after replacement', async () => {
    const { manager, connector } = setup();
    const old = manager.request({ type: 'arrow', query: query(), cache: true });
    const cleared = expect(old).rejects.toBe('Cleared');
    const replacement = new HeldConnector();
    manager.connector(replacement);
    await cleared;
    expect(connector.calls[0].signal?.aborted).toBe(true);
    const next = manager.request({ type: 'arrow', query: query(), cache: true });
    connector.calls[0].resolve(bytes);
    replacement.calls[0].resolve(bytes);
    const current = await next;
    expect(await manager.request({ type: 'arrow', query: query(), cache: true })).toBe(current);
    expect(replacement.calls).toHaveLength(1);
    manager.clear();
  });

  it('captures IPC extraction options separately for simultaneous flights', async () => {
    const { manager, connector } = setup();
    const date = new Date('2024-01-01T00:00:00Z');
    const request = { type: 'arrow' as const, query: Query.select({ n: asLiteral(date) }), cache: true };
    const first = manager.request(request);
    manager.ipc({ useDate: false });
    const second = manager.request(request);
    const dateBytes = tableToIPC(tableFromArrays({ n: [date] }), {})!;
    connector.calls[0].resolve(dateBytes);
    connector.calls[1].resolve(dateBytes);
    const [a, b] = await Promise.all([first, second]);
    expect(Array.from(a as Iterable<{ n: unknown }>)[0].n).toEqual(date);
    expect(Array.from(b as Iterable<{ n: unknown }>)[0].n).toBe(+date);
    manager.clear();
  });

  it.each([false, true])('reads a shared parameter once across an ordered exec batch (mixed %s)', async mixed => {
    const { manager, connector } = setup();
    let reads = 0;
    const parameter: ParamLike = {
      get value() { reads += 1; return reads; },
      addEventListener() {},
      removeEventListener() {}
    };
    const first = Query.select({ first: asLiteral(parameter) });
    const second = Query.select({ second: asLiteral(parameter) });
    const result = manager.request({
      type: 'exec',
      query: mixed ? [first, 'CREATE TABLE batch_marker (x INT)', second] : [first, second]
    });
    expect(reads).toBe(1);
    const sql = connector.calls[0].request.sql;
    expect(sql.indexOf('first')).toBeLessThan(sql.indexOf('second'));
    if (mixed) {
      expect(sql.indexOf('first')).toBeLessThan(sql.indexOf('CREATE TABLE'));
      expect(sql.indexOf('CREATE TABLE')).toBeLessThan(sql.indexOf('second'));
    }
    connector.calls[0].resolve(undefined);
    await result;
    manager.clear();
  });

  it('includes submitted SQL for every consumer of a failed shared flight', async () => {
    const { manager, connector } = setup();
    const request = { type: 'arrow' as const, query: query(), cache: true };
    const first = manager.request(request);
    const second = manager.request(request);
    expect(connector.calls).toHaveLength(1);
    const sql = connector.calls[0].request.sql;
    const failures = [first, second].map(result => expect(result).rejects.toMatchObject({
      sql,
      message: expect.stringContaining('Backend failed')
    }));
    connector.calls[0].reject(new Error('Backend failed'));
    await Promise.all(failures);
    manager.clear();
  });

  it.each(['AbortError', 'TimeoutError'])('preserves connector %s identity', async name => {
    const { manager } = setup();
    const reason = new DOMException('Cancelled request', name);
    const connector: Connector = { query: (): Promise<never> => Promise.reject(reason) };
    manager.connector(connector);
    await expect(manager.request({ type: 'arrow', query: query() })).rejects.toBe(reason);
    manager.clear();
  });

  it('preserves the native query timeout error', async () => {
    const { manager, connector } = setup();
    manager.timeout(5);
    await expect(manager.request({ type: 'arrow', query: query() })).rejects.toMatchObject({ name: 'TimeoutError' });
    expect(connector.calls[0].signal?.aborted).toBe(true);
    manager.clear();
  });

  it('invalidates work when the exported context is changed directly', async () => {
    const { manager, connector, native } = setup();
    const previous = manager.request({ type: 'arrow', query: query(), cache: true });
    const cleared = expect(previous).rejects.toBe('Cleared');
    native.replace({ backend: 'another-session' });
    await cleared;
    expect(connector.calls[0].signal?.aborted).toBe(true);
    const next = manager.request({ type: 'arrow', query: query(), cache: true });
    expect(connector.calls).toHaveLength(2);
    connector.calls[1].resolve(bytes);
    await next;
    connector.calls[0].resolve(bytes);
    manager.clear();
  });

});
