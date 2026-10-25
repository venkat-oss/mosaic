import type { ast } from '#polyglot';
import { isParamLike } from './util/type-check.js';
import { ast as syntax, native } from './runtime.js';
import { bind, rootExpression } from './bindings.js';
import type { ParamLike, ParamReader, SqlExpression, SqlRoot } from './types.js';

export type { ExprValue, SqlExpression, SqlExpressionHandle, SqlRoot, SqlValue } from './types.js';

export function isExpressionHandle(value: unknown): value is { readonly expression: SqlExpression } {
  return !!value && typeof value === 'object'
    && 'expression' in value && syntax.isExpressionValue(value.expression);
}

export function asNode(value: unknown): SqlExpression {
  return typeof value === 'string' ? column(value) : asLiteral(value);
}

export function asLiteral(value: unknown): SqlExpression {
  return expressionValue(value, new Set());
}

function expressionValue(value: unknown, ancestors: Set<object>): SqlExpression {
  if (syntax.isExpressionValue(value)) return isQueryExpression(value) ? native.subquery(value) : value;
  if (isExpressionHandle(value)) {
    const expression = value.expression;
    return isQueryExpression(expression) ? native.subquery(expression) : expression;
  }
  if (isParamLike(value)) {
    return bind({ kind: 'scalar', parameters: [value], resolve: read => literal(read(value)) });
  }
  return literalValue(value, child => expressionValue(child, ancestors), ancestors);
}

export function isQueryExpression(expression: SqlExpression): boolean {
  return 'select' in expression || 'union' in expression || 'intersect' in expression
    || 'except' in expression || 'values' in expression || 'pivot' in expression;
}

export function literal(value: unknown): SqlExpression {
  const ancestors = new Set<object>();
  const convert = (item: unknown): SqlExpression => literalValue(item, convert, ancestors);
  return convert(value);
}

export function literalValue(value: unknown, child: (value: unknown) => SqlExpression, ancestors: Set<object>): SqlExpression {
  if (value == null || typeof value === 'number' && !Number.isFinite(value)) {
    return native.literal(null);
  }
  if (value instanceof Date) {
    const timestamp = +value;
    if (!Number.isFinite(timestamp)) return native.literal(null);
    const [date, time] = value.toISOString().slice(0, -1).split('T');
    const midnight = value.getUTCHours() === 0 && value.getUTCMinutes() === 0
      && value.getUTCSeconds() === 0 && value.getUTCMilliseconds() === 0;
    return native.literal(midnight
      ? { literal_type: 'date', value: date }
      : { literal_type: 'timestamp', value: date + ' ' + time });
  }
  if (value instanceof RegExp) return native.literal(value.source);
  if (typeof value === 'string' || typeof value === 'number' || typeof value === 'bigint' || typeof value === 'boolean') {
    return native.literal(value);
  }
  const tag = Object.prototype.toString.call(value);
  if (tag === '[object ArrayBuffer]' || ArrayBuffer.isView(value) && (tag === '[object Uint8Array]' || tag === '[object DataView]')) {
    const buffer = value as ArrayBuffer | ArrayBufferView;
    const bytes = ArrayBuffer.isView(buffer) ? new Uint8Array(buffer.buffer, buffer.byteOffset, buffer.byteLength) : new Uint8Array(buffer);
    return native.literal({ literal_type: 'hex_string', value: Array.from(bytes, byte => byte.toString(16).padStart(2, '0')).join('') });
  }
  if (typeof value !== 'object') throw new TypeError('Native literals require SQL data values.');
  const array = Array.isArray(value) || ArrayBuffer.isView(value);
  if (!array && Object.getPrototypeOf(value) !== Object.prototype && Object.getPrototypeOf(value) !== null) {
    throw new TypeError('Native literals require arrays, plain records or scalar data values.');
  }
  if (ancestors.has(value)) throw new TypeError('Native literal data cannot contain cycles.');
  ancestors.add(value);
  try {
    return array ? native.array(Array.from(value as ArrayLike<unknown>, child))
      : native.struct(Object.entries(value).map(([name, item]) => [name, child(item)]));
  } finally {
    ancestors.delete(value);
  }
}

export function tableRef(...ids: (string | readonly string[])[]) {
  const path = ids.flat();
  if (!path.length) return undefined;
  if (path.length > 3) throw new TypeError('Native table paths support catalog, schema and table names.');
  const name = native.identifier(path[path.length - 1], true).identifier;
  return native.table(name, {
    schema: path.length > 1 ? native.identifier(path[path.length - 2], true).identifier : null,
    catalog: path.length > 2 ? native.identifier(path[path.length - 3], true).identifier : null
  });
}

function tableIdentifiers(table?: string | readonly string[] | SqlExpression): ast.Identifier[] {
  if (typeof table === 'string') return [native.identifier(table, true).identifier];
  if (Array.isArray(table)) return table.map(name => native.identifier(name, true).identifier);
  if (table && 'table' in table) return table.table.alias
    ? [table.table.alias]
    : [table.table.catalog, table.table.schema, table.table.name].filter((value): value is ast.Identifier => value != null);
  if (table && 'identifier' in table) return [table.identifier];
  if (table) throw new TypeError('Column qualifiers require a table reference or name.');
  return [];
}

export function column(name: string | ParamLike, table?: string | readonly string[] | SqlExpression): SqlExpression {
  const qualifiers = tableIdentifiers(table);
  const create = (name: string): SqlExpression => {
    if (name === '*') return native.star(qualifiers.length < 2 ? qualifiers[0] : tableRef(qualifiers.map(value => value.name)));
    const path = [...qualifiers, native.identifier(name, name !== '*').identifier];
    if (path.length === 1) return native.column(path[0]);
    let result: SqlExpression = native.column(path[1], { table: path[0] });
    for (let i = 2; i < path.length; ++i) result = native.dot(result, path[i]);
    return result;
  };
  if (!isParamLike(name)) return create(name);
  return bind({
    kind: 'identifier',
    parameters: [name],
    qualifier: qualifiers.map(value => value.name),
    resolve: read => create(String(read(name))),
    field: read => ({ column: String(read(name)), table: qualifiers.length ? qualifiers.map(value => value.name).join('.') : undefined })
  });
}

export function deferred(
  resolve: (read: ParamReader) => SqlRoot,
  parameters: readonly ParamLike[] = []
): SqlExpression {
  return bind({ kind: 'deferred', parameters, resolve });
}

export function isExpression(value: unknown): value is SqlExpression {
  return syntax.isExpressionValue(value);
}

export function toExpression(input: SqlRoot): SqlExpression {
  return rootExpression(input);
}
