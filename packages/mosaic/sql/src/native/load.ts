import { createTable } from './create.js';
import type { CreateTableOptions } from './create.js';
import { asLiteral, isExpression, isExpressionHandle, tableRef } from './expression.js';
import { rootExpression } from './bindings.js';
import { parseExpression } from './ingress.js';
import { from, type TableArg } from './relational.js';
import { Query } from './query.js';
import { Dialect, native } from './runtime.js';
import type { ExprValue, SqlExpression, SqlRoot } from './types.js';

export type LoadOptions = CreateTableOptions & {
  readonly select?: readonly (string | SqlRoot)[];
  readonly where?: ExprValue | readonly ExprValue[];
  readonly [option: string]: unknown;
};

export interface SQLFromOptions {
  readonly columns?: readonly string[] | Readonly<Record<string, string>>;
}

function tableName(name: TableArg) {
  return typeof name === 'string' || Array.isArray(name) ? tableRef(name)! : name as SqlRoot;
}

function optionValue(value: unknown): SqlExpression {
  if (isExpressionHandle(value)) return rootExpression(value);
  if (isExpression(value)) {
    const payload: unknown = Object.values(value)[0];
    if (payload === null || typeof payload === 'object' && !Array.isArray(payload)) return value;
  }
  if (Array.isArray(value)) return native.array(value.map(optionValue));
  if (value && typeof value === 'object' && !(value instanceof Date) && !(value instanceof RegExp)
      && !('addEventListener' in value)) {
    return native.struct(Object.entries(value).map(([key, item]) => [key, optionValue(item)]));
  }
  return asLiteral(value);
}

function project(query: Query, select?: readonly (string | SqlRoot)[]) {
  return select?.length
    ? query.select(select.map(value => typeof value === 'string' ? parseExpression(value) : rootExpression(value)))
    : query;
}

function read(method: string, fileName: unknown, options: Record<string, unknown>) {
  const args = Object.entries(options).map(([name, value]) => native.namedArgument(name, optionValue(value), 'Eq'));
  const file = optionValue(fileName);
  return method === 'read_csv' ? native.readCSV(file, args)
    : method === 'read_parquet' ? native.readParquet([file, ...args])
    : native.call(method, [file, ...args], { source_dialect: Dialect.DuckDB });
}

function load(method: string, name: TableArg, fileName: unknown, options: LoadOptions = {}, defaults = {}) {
  const { select, where, view, temp, replace, ...file } = options;
  const query = project(Query.from(read(method, fileName, { ...defaults, ...file })), select);
  if (where != null) query.where(...[where].flat());
  return createTable(tableName(name), query, { view, temp, replace });
}

export function loadCSV(name: TableArg, fileName: unknown, options?: LoadOptions): Query {
  return load('read_csv', name, fileName, options, { auto_detect: true, sample_size: -1 });
}

export function loadJSON(name: TableArg, fileName: unknown, options?: LoadOptions): Query {
  return load('read_json', name, fileName, options, { auto_detect: true, format: 'auto' });
}

export function loadParquet(name: TableArg, fileName: unknown, options?: LoadOptions): Query {
  return load('read_parquet', name, fileName, options);
}

export function loadSpatial(name: TableArg, fileName: unknown, options: LoadOptions = {}): Query {
  const { options: openOptions, ...rest } = options;
  if (openOptions != null) {
    const values = Array.isArray(openOptions) ? openOptions
      : typeof openOptions === 'string' ? [openOptions]
      : Object.entries(openOptions).map(([key, value]) => `${key}=${value}`);
    return load('st_read', name, fileName, { ...rest, open_options: values.map(value => String(value).toUpperCase()) });
  }
  return load('st_read', name, fileName, rest);
}

export function sqlFrom(data: readonly Readonly<Record<string, unknown>>[], { columns = Object.keys(data[0] ?? {}) }: SQLFromOptions = {}): Query {
  const mapping = Array.isArray(columns)
    ? columns.map(name => [name, name])
    : Object.entries(columns);
  if (!mapping.length) throw new Error('Can not create table from empty column set.');
  if (!data.length) throw new Error('Can not create table from empty row set.');
  return Query.unionAll(data.map(datum => Query.select(mapping.map(([key, name]) => [name, optionValue(datum[key])] as const))));
}

export function loadObjects(name: TableArg, data: readonly Readonly<Record<string, unknown>>[], options: LoadOptions = {}): Query {
  const { select, where, view, temp, replace } = options;
  const source = sqlFrom(data);
  const query = select?.length || where != null ? project(Query.from(from(source)), select) : source;
  if (where != null) query.where(...[where].flat());
  return createTable(tableName(name), query, { view, temp, replace });
}
