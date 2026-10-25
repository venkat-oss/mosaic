import { asNode } from './expression.js';
import { native } from './runtime.js';
import type { ExprValue, MaybeArray, SqlExpression } from './types.js';

type BinaryOperator = Parameters<typeof native.binary>[0];

function binary(operator: BinaryOperator, left: ExprValue, right: ExprValue): SqlExpression {
  return native.binary(operator, asNode(left), asNode(right));
}

export const add = (left: ExprValue, right: ExprValue): SqlExpression => binary('add', left, right);
export const sub = (left: ExprValue, right: ExprValue): SqlExpression => binary('sub', left, right);
export const mul = (left: ExprValue, right: ExprValue): SqlExpression => binary('mul', left, right);
export const div = (left: ExprValue, right: ExprValue): SqlExpression => binary('div', left, right);
export const idiv = (left: ExprValue, right: ExprValue): SqlExpression => native.scalarBinary('int_div', asNode(left), asNode(right));
export const mod = (left: ExprValue, right: ExprValue): SqlExpression => binary('mod', left, right);
export const bitAnd = (left: ExprValue, right: ExprValue): SqlExpression => binary('bitwise_and', left, right);
export const bitOr = (left: ExprValue, right: ExprValue): SqlExpression => binary('bitwise_or', left, right);
export const bitLeft = (left: ExprValue, right: ExprValue): SqlExpression => binary('bitwise_left_shift', left, right);
export const bitRight = (left: ExprValue, right: ExprValue): SqlExpression => binary('bitwise_right_shift', left, right);
export const pow = (left: ExprValue, right: ExprValue): SqlExpression => native.scalarBinary('power', asNode(left), asNode(right));
export const eq = (left: ExprValue, right: ExprValue): SqlExpression => binary('eq', left, right);
export const neq = (left: ExprValue, right: ExprValue): SqlExpression => binary('neq', left, right);
export const lt = (left: ExprValue, right: ExprValue): SqlExpression => binary('lt', left, right);
export const lte = (left: ExprValue, right: ExprValue): SqlExpression => binary('lte', left, right);
export const gt = (left: ExprValue, right: ExprValue): SqlExpression => binary('gt', left, right);
export const gte = (left: ExprValue, right: ExprValue): SqlExpression => binary('gte', left, right);

export function and(...values: MaybeArray<ExprValue>[]): SqlExpression {
  return logical('and', values.flat().filter(value => value != null).map(asNode));
}

export function or(...values: MaybeArray<ExprValue>[]): SqlExpression {
  return logical('or', values.flat().filter(value => value != null).map(asNode));
}

function logical(operator: 'and' | 'or', values: SqlExpression[]): SqlExpression {
  return values.length
    ? values.reduce((left, right) => native.binary(operator, left, right))
    : native.literal(operator === 'and');
}

export function not(value: ExprValue): SqlExpression {
  return native.unary('not', asNode(value));
}

export function bitNot(value: ExprValue): SqlExpression {
  return native.unary('bitwise_not', asNode(value));
}

export function isNull(value: ExprValue): SqlExpression {
  return native.binary('is', asNode(value), native.literal(null));
}

export function isNotNull(value: ExprValue): SqlExpression {
  return not(isNull(value));
}

export function isNotDistinct(left: ExprValue, right: ExprValue): SqlExpression {
  return native.binary('null_safe_eq', asNode(left), asNode(right));
}

export function isDistinct(left: ExprValue, right: ExprValue): SqlExpression {
  return native.binary('null_safe_neq', asNode(left), asNode(right));
}

export function between(value: ExprValue, extent: readonly [ExprValue, ExprValue]): SqlExpression {
  const expression = asNode(value);
  return and(gte(expression, asNode(extent[0])), lte(expression, asNode(extent[1])));
}

export function notBetween(value: ExprValue, extent: readonly [ExprValue, ExprValue]): SqlExpression {
  return not(between(value, extent));
}

export function isIn(value: ExprValue, values: readonly ExprValue[]): SqlExpression {
  const expression = asNode(value);
  return values.length ? native.inList(expression, values.map(asNode)) : native.literal(false);
}

export function asc(value: ExprValue, nullsFirst?: boolean): SqlExpression {
  return native.ordered(asNode(value), { nulls_first: nullsFirst ?? null });
}

export function desc(value: ExprValue, nullsFirst?: boolean): SqlExpression {
  return native.ordered(asNode(value), { desc: true, nulls_first: nullsFirst ?? null });
}

export function isInDistinct(value: ExprValue, values: readonly ExprValue[]): SqlExpression {
  const expression = asNode(value);
  const nodes = values.map(asNode);
  const included = nodes.filter(node => !('null' in node));
  const predicate = isIn(expression, included);
  return included.length === nodes.length ? predicate
    : included.length ? or(predicate, isNull(expression)) : isNull(expression);
}

export function isBetween(value: ExprValue, extent?: readonly ExprValue[] | null): SqlExpression {
  if (!extent) return literalTrue();
  if (extent.length !== 2) throw new RangeError('A native interval requires two bounds.');
  return between(value, [extent[0], extent[1]]);
}

export function isNotBetween(value: ExprValue, extent?: readonly ExprValue[] | null): SqlExpression {
  return extent ? not(isBetween(value, extent)) : literalTrue();
}

function literalTrue(): SqlExpression {
  return native.literal(true);
}
