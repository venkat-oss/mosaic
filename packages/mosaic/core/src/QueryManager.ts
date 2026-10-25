import type { ExtractionOptions } from '@uwdata/flechette';
import { isExpression, isExpressionHandle, isResultQuery, rootExpression } from '@uwdata/mosaic-sql';
import type { SqlExecutionContext } from '@uwdata/mosaic-sql';
import { backendExecution, SqlContext } from './sql-context.js';
import { QueryError } from './util/query-error.js';
import type { QueryType } from './types.js';
import type { Connector } from './connectors/Connector.js';
import type { Cache, Logger, QueryEntry, QueryRequest } from './types.js';
import { consolidator } from './QueryConsolidator.js';
import { abortable } from './util/abort.js';
import { lruCache, voidCache } from './util/cache.js';
import { decodeIPC, tableByteLength } from './util/decode-ipc.js';
import { PriorityQueue } from './util/priority-queue.js';
import { QueryResult, QueryState } from './util/query-result.js';
import { voidLogger } from './util/void-logger.js';

export const Priority = Object.freeze({ High: 0, Normal: 1, Low: 2 });

interface Flight {
  sql: string;
  key: string;
  type: QueryRequest['type'];
  controller: AbortController;
  promise: Promise<unknown>;
}

export class QueryManager {
  private queue: PriorityQueue<QueryEntry>;
  private db: Connector | null;
  private clientCache: Cache;
  private _logger: Logger;
  private _logQueries: boolean;
  private _ipc?: ExtractionOptions;
  private _consolidate: ReturnType<typeof consolidator> | null;
  private _consolidating: boolean;
  private inflight: Map<string, Flight>;
  private flights: Set<Flight>;
  private _timeout: number;
  private _generation: number;
  private _sqlContext: SqlContext;
  private _contextReset?: () => void;
  /** Requests pending with the query manager. */
  public pendingResults: QueryResult[];
  private maxConcurrentRequests: number;
  private pendingExec: boolean;

  constructor(maxConcurrentRequests: number = 32) {
    this.queue = new PriorityQueue(3);
    this.db = null;
    this.clientCache = voidCache();
    this._logger = voidLogger();
    this._logQueries = false;
    this._consolidate = null;
    this._consolidating = false;
    this.inflight = new Map();
    this.flights = new Set();
    this._timeout = 0;
    this._generation = 0;
    this._sqlContext = new SqlContext();
    this._sqlContext.attach(this, () => this.invalidateContext());
    this.pendingResults = [];
    this.maxConcurrentRequests = maxConcurrentRequests;
    this.pendingExec = false;
  }

  next(): void {
    if (this.queue.isEmpty() || this.pendingResults.length > this.maxConcurrentRequests || this.pendingExec) {
      return;
    }

    const entry = this.queue.next();
    if (!entry) return;

    const { request, result } = entry;

    this.pendingResults.push(result);
    if (request.type === 'exec') this.pendingExec = true;

    this.submit(request, result, entry.prepare).finally(() => {
      // return from the queue all requests that are ready
      while (this.pendingResults.length && this.pendingResults[0].state !== QueryState.pending) {
        const result = this.pendingResults.shift()!;
        if (result.state === QueryState.ready) {
          result.fulfill();
        } else if (result.state === QueryState.done) {
          this._logger.warn('Found resolved query in pending results.');
        }
      }
      if (request.type === 'exec') this.pendingExec = false;
      this.next();
    });
  }

  /**
   * Add an entry to the query queue with a priority.
   * @param entry The entry to add.
   * @param priority The query priority, defaults to `Priority.Normal`.
   */
  enqueue(entry: QueryEntry, priority: number = Priority.Normal): void {
    this.queue.insert(entry, priority);
    this.next();
  }

  /**
   * Submit the query to the connector.
   * @param request The request.
   * @param result The query result.
   */
  async submit(request: QueryRequest, result: QueryResult, prepare?: () => string | null): Promise<void> {
    let sent: Promise<unknown> | undefined;
    let sql: string | undefined;
    let dispatched = false;
    const context = this._sqlContext;
    const execution = context.execution;
    try {
      const { query, type, cache = false, options } = request;
      const generation = this._generation;
      const prepared = prepare?.();
      sql = prepared === null ? undefined : prepared ?? this.sql(query, type, context, execution);
      if (generation !== this._generation) {
        throw new DOMException('SQL execution context changed during compilation.', 'AbortError');
      }
      if (sql === undefined) {
        result.ready(null);
        return;
      }
      const key = context.cacheKey(sql, execution);
      const ipc = this._ipc;

      if (cache) {
        const shared = this.inflight.get(key)?.promise;
        const cached = this.clientCache.get(key) ?? shared;
        if (cached) {
          dispatched = cached === shared;
          const data = await cached;
          this._logger.debug('Cache');
          result.ready(data);
          return;
        }
      }

      const t0 = performance.now();
      if (this._logQueries) {
        this._logger.debug('Query', { type, sql, ...options });
      }

      const controller = new AbortController();
      dispatched = true;
      // @ts-expect-error type may be exec | arrow
      const response = this.db!.query({ ...options, type, sql }, { signal: controller.signal, baseColumnNullability: type === 'arrow' && preservesBaseNullability(query) });
      sent = response;
      const promise: Promise<unknown> = type === 'arrow'
        ? response.then(bytes => decodeIPC(bytes, ipc))
        : response;
      const flight: Flight = { sql, key, type, controller, promise: abortable(promise, controller.signal) };
      const ms = this._timeout;
      const timer = ms
        ? setTimeout(() => this.abortFlight(flight, new DOMException(`Query timed out after ${ms} ms`, 'TimeoutError')), ms)
        : undefined;
      this.flights.add(flight);
      if (cache) this.inflight.set(key, flight);

      const data = await flight.promise.finally(() => {
        clearTimeout(timer);
        this.flights.delete(flight);
        if (this.inflight.get(key) === flight) this.inflight.delete(key);
      });

      if (cache && generation === this._generation) {
        this.clientCache.set(key, data, tableByteLength(data) ?? 0);
      }

      this._logger.debug(`Request: ${(performance.now() - t0).toFixed(1)}`);
      result.ready(type === 'exec' ? null : data);
    } catch (err) {
      const cancelled = err instanceof Error && (err.name === 'AbortError' || err.name === 'TimeoutError');
      result.reject(sql !== undefined && dispatched && !cancelled
        ? new QueryError(err, sql)
        : err);
      // later queries must not overtake an exec that the connector is still running
      if (request.type === 'exec') await sent?.catch(() => {});
    }
  }

  /**
   * Get or set the current query cache.
   * @param value Cache value to set
   * @returns Current cache
   */
  cache(value?: Cache | boolean): Cache {
    return value !== undefined
      ? (this.clientCache = value === true ? lruCache() : (value || voidCache()))
      : this.clientCache;
  }

  /**
   * Get or set the current logger.
   * @param value Logger to set
   * @returns Current logger
   */
  logger(): Logger;
  logger(value: Logger): Logger;
  logger(value?: Logger): Logger {
    return value ? (this._logger = value) : this._logger;
  }

  /**
   * Get or set the Arrow IPC extraction options.
   * @param value Extraction options to set
   * @returns Current extraction options
   */
  ipc(value?: ExtractionOptions): ExtractionOptions | undefined {
    if (value === undefined) return this._ipc;
    this._generation += 1;
    this.clientCache.clear();
    this.inflight.clear();
    return this._ipc = value;
  }

  /**
   * Get or set if queries should be logged.
   * @param value Whether to log queries
   * @returns Current logging state
   */
  logQueries(): boolean;
  logQueries(value: boolean): boolean;
  logQueries(value?: boolean): boolean {
    return value !== undefined ? this._logQueries = !!value : this._logQueries;
  }

  /**
   * Get or set the query timeout in milliseconds, measured from when a query
   * is sent to the connector. A value of zero disables the timeout.
   * @param value The timeout in milliseconds
   * @returns The current timeout
   */
  timeout(): number;
  timeout(value: number): number;
  timeout(value?: number): number {
    if (value !== undefined) {
      // setTimeout fires immediately for delays above 2^31 - 1 ms
      this._timeout = value > 0 && value <= 2 ** 31 - 1 ? value : 0;
    }
    return this._timeout;
  }

  /**
   * Get or set the database connector.
   * @param connector Connector to set
   * @returns Current connector
   */
  connector(): Connector | null;
  connector(connector: Connector): Connector;
  connector(connector?: Connector): Connector | null {
    if (connector && connector !== this.db) {
      const previous = this.db;
      this.db = connector;
      if (previous) this._sqlContext.replace(backendExecution(connector));
      else this.invalidateContext();
    }
    return this.db;
  }

  /**
   * Indicate if query consolidation should be performed.
   * @param flag Whether to enable consolidation
   */
  consolidate(flag: boolean): void {
    // a disabled consolidator is kept so that clear() can still reject the
    // requests it holds
    if (flag) {
      this._consolidate ??= consolidator(
        this.enqueue.bind(this),
        () => this.clientCache,
        () => this._generation,
        () => this._sqlContext
      );
    }
    this._consolidating = flag;
  }

  /**
   * Request a query result.
   * @param request The request.
   * @param priority The query priority, defaults to `Priority.Normal`.
   * @returns A query result promise.
   */
  request(request: QueryRequest, priority: number = Priority.Normal, prepare?: () => string | null): QueryResult {
    const result = new QueryResult();
    const entry = { request, result, prepare };
    if (this._consolidate && this._consolidating) {
      this._consolidate.add(entry, priority);
    } else {
      this.enqueue(entry, priority);
    }
    return result;
  }

  cancel(requests: readonly Promise<unknown>[]): void {
    const set = new Set(requests);
    if (set.size) {
      const remove = ({ result }: QueryEntry) => {
        if (set.has(result)) {
          result.reject('Canceled');
          return true;
        }
        return false;
      };
      this._consolidate?.remove(remove);
      this.queue.remove(remove);

      for (const result of this.pendingResults) {
        if (set.has(result)) {
          result.reject('Canceled');
        }
      }
    }
  }

  clear(): void {
    this._generation += 1;
    this._consolidate?.remove(({ result }) => {
      result.reject('Cleared');
      return true;
    });

    this.queue.remove(({ result }) => {
      result.reject('Cleared');
      return true;
    });

    for (const result of this.pendingResults) {
      result.reject('Cleared');
    }
    this.pendingResults = [];

    for (const flight of this.flights) {
      if (flight.type !== 'exec') this.abortFlight(flight);
    }
  }

  sqlContext(): SqlContext;
  sqlContext(context: SqlContext, reset?: () => void): SqlContext;
  sqlContext(context?: SqlContext, reset?: () => void): SqlContext {
    if (context !== undefined) {
      if (this._contextReset) throw new TypeError('Query managers cannot be shared between coordinators.');
      if (context !== this._sqlContext) this._sqlContext.detach(this);
      context.attach(this, () => this.invalidateContext());
      this.invalidateContext();
      this._sqlContext = context;
      this._contextReset = reset;
    }
    return this._sqlContext;
  }

  private invalidateContext(): void {
    this.clear();
    this.clientCache.clear();
    this.inflight.clear();
    this._contextReset?.();
  }

  private sql(
    query: QueryType | readonly QueryType[],
    type: QueryRequest['type'],
    context: SqlContext,
    execution: SqlExecutionContext
  ): string {
    const inputs = [query].flat().filter(value => value);
    const admitted = inputs.map(input => {
      if (isExpression(input) || isExpressionHandle(input)) {
        if (type === 'arrow' && !isResultQuery(input)) {
          throw new TypeError('Arrow requests require a result-producing query.');
        }
        return input;
      }
      if (typeof input !== 'string') {
        throw new TypeError('SQL requests require a query, expression or raw SQL string.');
      }
      if (execution.sourceDialect !== execution.targetDialect) {
        throw new TypeError('Raw SQL requires matching source and target dialects.');
      }
      return input;
    });
    const statements = context.compileBatch(admitted, execution);
    if (type === 'arrow' && statements.length !== 1) {
      throw new TypeError('Arrow requests require one result-producing SQL statement.');
    }
    return statements.join(';\n');
  }

  private abortFlight(flight: Flight, reason?: unknown): void {
    if (this.inflight.get(flight.key) === flight) this.inflight.delete(flight.key);
    flight.controller.abort(reason);
  }
}

function preservesBaseNullability(query: QueryType | readonly QueryType[]): boolean {
  const inputs = [query].flat();
  if (inputs.length !== 1 || typeof inputs[0] === 'string') return false;
  const root = rootExpression(inputs[0]);
  return 'select' in root && !root.select.with && !root.select.group_by && !root.select.joins.length
    && root.select.from?.expressions.length === 1 && 'table' in root.select.from.expressions[0];
}
