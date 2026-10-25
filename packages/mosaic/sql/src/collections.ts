import { asLiteral, asNode } from './expression.js';
import { rootExpression } from './bindings.js';
import { native } from './runtime.js';
import type { ExprValue, SqlExpression, SqlRoot } from './types.js';

export function list(values: readonly ExprValue[]): SqlExpression {
  return native.array(values.map(asLiteral));
}

function asList(value: ExprValue | readonly ExprValue[]): SqlExpression {
  return Array.isArray(value) ? list(value) : asNode(value);
}

export function listContains(values: ExprValue | readonly ExprValue[], value: ExprValue): SqlExpression {
  return native.scalarBinary('array_contains', asList(values), asLiteral(value));
}

export function listHasAll(left: ExprValue | readonly ExprValue[], right: ExprValue | readonly ExprValue[]): SqlExpression {
  return native.binary('array_contains_all', asList(left), asList(right));
}

export function listHasAny(left: ExprValue | readonly ExprValue[], right: ExprValue | readonly ExprValue[]): SqlExpression {
  return native.binary('array_overlaps', asList(left), asList(right));
}

export function lambda(parameters: string | readonly string[], body: SqlRoot | ((...variables: SqlExpression[]) => ExprValue)): SqlExpression {
  return native.lambda(typeof parameters === 'string' ? [parameters] : parameters,
    typeof body === 'function' ? (...variables) => asNode(body(...variables)) : rootExpression(body));
}

export function namedArg(name: string, value: ExprValue): SqlExpression {
  return native.namedArgument(native.identifier(name, true).identifier, asNode(value));
}

export function subscript(value: ExprValue, index: ExprValue): SqlExpression {
  return native.subscript(asNode(value), asLiteral(index));
}

export function slice(value: ExprValue, start?: ExprValue, end?: ExprValue, step?: ExprValue): SqlExpression {
  const bound = (value: ExprValue | undefined) => value == null ? undefined : asLiteral(value);
  return native.subscript(asNode(value), native.slice(bound(start), bound(end), bound(step)));
}

export function all(): SqlExpression {
  return native.all();
}

const comparisons = { '=': 'Eq', '<>': 'Neq', '!=': 'Neq', '<': 'Lt', '<=': 'Lte', '>': 'Gt', '>=': 'Gte' } as const;
export type ComparisonOp = keyof typeof comparisons;

export function compareAny(value: ExprValue, operator: ComparisonOp, query: SqlRoot): SqlExpression {
  return native.quantified('any', asNode(value), comparisons[operator], rootExpression(query));
}

export function compareAll(value: ExprValue, operator: ComparisonOp, query: SqlRoot): SqlExpression {
  return native.quantified('all', asNode(value), comparisons[operator], rootExpression(query));
}
