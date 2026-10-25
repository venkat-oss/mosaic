import { Client } from 'pg';
import type { ClientConfig, QueryResult } from 'pg';
import { arrowIPC } from './schema.js';
import type { CatalogField } from './schema.js';

export type PostgresConnectionOptions = Omit<ClientConfig, 'types' | 'query_timeout' | 'binary'>;

interface QueryRequest {
  type: string;
  sql: string;
}

interface QueryOptions {
  signal?: AbortSignal;
  baseColumnNullability?: boolean;
}

const rawTypes = { getTypeParser: (_oid: number, format?: string) => {
  if (format && format !== 'text') throw new TypeError('PostgreSQL connector requires text protocol fields.');
  return (value: string | Buffer) => {
    if (typeof value !== 'string') throw new TypeError('PostgreSQL connector requires text protocol values.');
    return value;
  };
} };
const sessionSettings = "SET TIME ZONE 'UTC'; SET DateStyle TO ISO, YMD; SET bytea_output TO hex";
const fieldCatalog = `SELECT f.position, pg_catalog.format_type(f.type_oid, f.typmod) AS sql_type,
  a.attnotnull AS base_not_null
FROM unnest($1::oid[], $2::int[], $3::oid[], $4::smallint[])
  WITH ORDINALITY AS f(type_oid, typmod, table_oid, column_id, position)
LEFT JOIN pg_catalog.pg_attribute a ON a.attrelid = f.table_oid AND a.attnum = f.column_id
ORDER BY f.position`;

export class PostgresConnector {
  readonly dialect = 'postgres';
  readonly ready: Promise<void>;
  private readonly client: Client;
  private readonly control: Client;
  private readonly lifetime = new AbortController();
  private tail: Promise<unknown> = Promise.resolve();
  private closing?: Promise<void>;
  private failure?: unknown;
  private pid = 0;

  static async make(config: PostgresConnectionOptions | string = {}): Promise<PostgresConnector> {
    const connector = new PostgresConnector(config);
    await connector.ready;
    return connector;
  }

  constructor(config: PostgresConnectionOptions | string = {}) {
    const options = typeof config === 'string' ? { connectionString: config } : config;
    const clientOptions: ClientConfig & { binary: false } = { ...options, types: rawTypes, query_timeout: 0, binary: false };
    this.client = new Client(clientOptions);
    this.control = new Client(clientOptions);
    const failed = (error: Error) => { this.failure = error; };
    this.client.on('error', failed);
    this.control.on('error', failed);
    this.ready = this.connect();
    this.ready.catch(() => {});
  }

  private async connect(): Promise<void> {
    try {
      await Promise.all([this.client.connect(), this.control.connect()]);
      await this.client.query(sessionSettings);
      const result = await this.client.query<{ pid: string }>('SELECT pg_backend_pid() AS pid');
      this.pid = Number(result.rows[0].pid);
    } catch (error) {
      this.failure = error;
      await Promise.allSettled([this.client.end(), this.control.end()]);
      throw error;
    }
  }

  query(request: QueryRequest & { type: 'arrow' }, options?: QueryOptions): Promise<Uint8Array>;
  query(request: QueryRequest & { type: 'exec' }, options?: QueryOptions): Promise<void>;
  query(request: QueryRequest, options: QueryOptions = {}): Promise<Uint8Array | void> {
    if (request.type !== 'arrow' && request.type !== 'exec') return Promise.reject(new TypeError(`Unsupported PostgreSQL request type: ${request.type}`));
    const signal = options.signal ? AbortSignal.any([options.signal, this.lifetime.signal]) : this.lifetime.signal;
    const result = this.tail.then(async () => {
      await this.ready;
      signal.throwIfAborted();
      if (this.failure) throw this.failure;
      return this.execute(request, signal, options.baseColumnNullability ?? false);
    });
    this.tail = result.catch(() => {});
    return result;
  }

  private async cancel(): Promise<void> {
    try {
      await this.control.query('SELECT pg_cancel_backend($1)', [this.pid]);
    } catch (error) {
      this.failure = error;
      await this.client.end();
      throw error;
    }
  }

  private async execute(request: QueryRequest, signal: AbortSignal, baseColumnNullability: boolean): Promise<Uint8Array | void> {
    let active = false;
    let cancellation: Promise<void> | undefined;
    const abort = () => {
      if (!active || cancellation) return;
      cancellation = this.cancel();
      cancellation.catch(() => {});
    };
    signal.addEventListener('abort', abort, { once: true });
    try {
      signal.throwIfAborted();
      active = true;
      const result = await this.client.query<(string | null)[]>({ text: request.sql, rowMode: 'array' });
      active = false;
      signal.throwIfAborted();
      if (request.type === 'exec') return;
      if (Array.isArray(result) || !result.fields.length) throw new TypeError('PostgreSQL Arrow queries require exactly one result statement.');
      active = true;
      const catalog = await this.catalog(result);
      active = false;
      signal.throwIfAborted();
      return arrowIPC(result, catalog, baseColumnNullability);
    } catch (error) {
      signal.throwIfAborted();
      throw error;
    } finally {
      active = false;
      signal.removeEventListener('abort', abort);
      // A late cancellation must be acknowledged before another query can use this session.
      if (cancellation) await cancellation;
    }
  }

  private async catalog(result: QueryResult<(string | null)[]>): Promise<CatalogField[]> {
    const { fields } = result;
    const metadata = await this.client.query<{ sql_type: string; base_not_null: string | null }>(fieldCatalog, [
      fields.map(field => field.dataTypeID), fields.map(field => field.dataTypeModifier),
      fields.map(field => field.tableID), fields.map(field => field.columnID)
    ]);
    return metadata.rows.map(row => ({ sqlType: row.sql_type.toUpperCase(), baseNotNull: row.base_not_null === null ? null : row.base_not_null === 't' }));
  }

  close(): Promise<void> {
    if (!this.closing) {
      this.lifetime.abort(new Error('PostgreSQL connector closed.'));
      this.closing = (async () => {
        await this.ready.catch(() => {});
        await this.tail;
        await Promise.all([this.client.end(), this.control.end()]);
      })();
    }
    return this.closing;
  }
}
