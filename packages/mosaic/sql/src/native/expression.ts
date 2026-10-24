import type { ast } from '#polyglot';
import { ast as syntax, native } from './runtime.js';

export type SqlExpression = ast.Expression;
export type SqlValue = string | number | bigint | boolean | null | undefined;

export function asNode(value: SqlValue | SqlExpression): SqlExpression {
  return typeof value === 'string'
    ? native.column(native.identifier(value, true).identifier)
    : asLiteral(value);
}

export function asLiteral(value: SqlValue | SqlExpression): SqlExpression {
  if (syntax.isExpressionValue(value)) return value;
  if (value == null || typeof value === 'number' && !Number.isFinite(value)) {
    return native.literal(null);
  }
  return native.literal(value);
}
