import type { ast } from '#polyglot';
import { isParamLike } from '../util/type-check.js';
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
  if (syntax.isExpressionValue(value)) return value;
  if (isExpressionHandle(value)) return value.expression;
  if (isParamLike(value)) {
    return bind({ kind: 'scalar', parameters: [value], resolve: read => literalValue(read(value)) });
  }
  return literalValue(value);
}

export function literal(value: unknown): SqlExpression {
  return literalValue(value);
}

function literalValue(value: unknown): SqlExpression {
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
  throw new TypeError('Native scalar bindings require a SQL literal value.');
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

function tableIdentifier(table?: string | SqlExpression): ast.Identifier | null {
  if (typeof table === 'string') return native.identifier(table, true).identifier;
  if (table && 'table' in table) return table.table.alias ?? table.table.name;
  if (table && 'identifier' in table) return table.identifier;
  if (table) throw new TypeError('Column qualifiers require a table reference or name.');
  return null;
}

export function column(name: string | ParamLike, table?: string | SqlExpression): SqlExpression {
  const qualifier = tableIdentifier(table);
  const create = (name: string) => name === '*'
    ? native.star(qualifier ?? undefined)
    : native.column(native.identifier(name, true).identifier, { table: qualifier });
  if (!isParamLike(name)) return create(name);
  return bind({
    kind: 'identifier',
    parameters: [name],
    resolve: read => create(String(read(name))),
    field: read => ({ column: String(read(name)), table: qualifier?.name })
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
