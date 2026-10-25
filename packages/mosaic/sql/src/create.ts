import { rootExpression } from './bindings.js';
import { tableRef } from './expression.js';
import { parseExpression } from './ingress.js';
import { native } from './runtime.js';
import { Query } from './query.js';
import type { SqlRoot } from './types.js';

export interface CreateTableOptions {
  readonly replace?: boolean;
  readonly temp?: boolean;
  readonly view?: boolean;
}

export interface CreateSchemaOptions {
  readonly strict?: boolean;
}

function tableName(name: string | SqlRoot) {
  const expression = typeof name === 'string' ? tableRef(name)! : rootExpression(name);
  if (!('table' in expression)) throw new TypeError('Native table/schema names require a table reference.');
  return expression.table;
}

export function createSchema(name: string | SqlRoot, { strict = false }: CreateSchemaOptions = {}): Query {
  const value = tableName(name);
  return new Query(native.createSchema([value.catalog, value.schema, value.name].filter(value => value != null), { if_not_exists: !strict }));
}

export function createTable(name: string | SqlRoot, query: string | SqlRoot, { replace = false, temp = false, view = false }: CreateTableOptions = {}): Query {
  const value = typeof query === 'string' ? parseExpression(query) : rootExpression(query);
  const options = { or_replace: replace, if_not_exists: !replace, temporary: temp };
  return new Query(view ? native.createView(tableName(name), value, options) : native.createTable(tableName(name), value, options));
}

export function dropSchema(name: string | SqlRoot, { ifExists = true, cascade = false } = {}): Query {
  const value = tableName(name);
  if (value.schema || value.catalog) throw new TypeError('Dropping a scratch schema requires a single schema name.');
  return new Query(native.dropSchema(value.name, { if_exists: ifExists, cascade }));
}
