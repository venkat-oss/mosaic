import type { MaybeArray, SqlExpression, SqlRoot, TableArg } from '@uwdata/mosaic-sql';
import type { QueryResult } from './util/query-result.js';

/** Arrow IPC bytes as returned by a connector. */
export type ArrowIPCBytes = ArrayBuffer | Uint8Array | Uint8Array[];

/** Query type accepted by a coordinator. */
export type QueryType = string | SqlRoot;

export type SelectionExpression = SqlExpression;

/** Type for a query request. */
export interface QueryRequest {
  type: 'exec' | 'arrow';
  query: MaybeArray<QueryType>;
  cache?: boolean;
  options?: Record<string, unknown>;
}

/** Type for an entry within a query manager. */
export interface QueryEntry {
  request: QueryRequest;
  result: QueryResult;
  prepare?: () => string | null;
}

/** String indicating a JavaScript data type. */
export type JSType =
  | 'number'
  | 'date'
  | 'boolean'
  | 'string'
  | 'array'
  | 'object';

/** String indicating a requested summary statistic. */
export type Stat =
  | 'count'
  | 'nulls'
  | 'max'
  | 'min'
  | 'distinct';

/** A reference to a database column or expression. */
export type FieldRef = string | SqlRoot;

export interface FieldInfoRequest {
  table: TableArg;
  column: FieldRef;
  stats?: Stat[];
}

export interface FieldInfoOptions {
  query?: SqlRoot;
}

export interface FieldInfo extends Partial<Record<Exclude<Stat, 'min' | 'max'>, number>> {
  table: TableArg;
  column: FieldRef;
  sqlType: string;
  type: JSType;
  nullable: boolean;
  min?: unknown;
  max?: unknown;
}

/** A result row from a DESCRIBE query. */
export interface ColumnDescription {
  column_name: string,
  column_type: string,
  null: 'YES' | 'NO'
}

/**
 * Interface for components that perform selection activation.
 */
export interface Activatable {
  /**
   * Activate the selection that this component publishes to.
   */
  activate(): void;
}

/**
 * Interface for cache implementations.
 */
export interface Cache {
  get(key: string): unknown;
  set(key: string, value: unknown, bytes: number): unknown;
  clear(): void;
  bytes(): number;
}

/**
 * Interface for logger implementations
 */
export interface Logger {
  debug(...args: unknown[]): void;
  info(...args: unknown[]): void;
  log(...args: unknown[]): void;
  warn(...args: unknown[]): void;
  error(...args: unknown[]): void;
  group(label?: unknown): void;
  groupCollapsed(label?: unknown): void;
  groupEnd(): void;
}
