import { asNode } from './expression.js';
import { native } from './runtime.js';
import type { ExprValue, SqlExpression } from './types.js';

export const abs = (value: ExprValue): SqlExpression => native.scalar('abs', asNode(value));
export const sign = (value: ExprValue): SqlExpression => native.scalar('sign', asNode(value));
export const exp = (value: ExprValue): SqlExpression => native.scalar('exp', asNode(value));
export const ln = (value: ExprValue): SqlExpression => native.scalar('ln', asNode(value));
export const sqrt = (value: ExprValue): SqlExpression => native.scalar('sqrt', asNode(value));
export const ceil = (value: ExprValue): SqlExpression => native.ceil(asNode(value));
export const floor = (value: ExprValue): SqlExpression => native.floor(asNode(value));
export const log = (value: ExprValue): SqlExpression => native.log(asNode(value));
export const epoch_ms = (value: ExprValue): SqlExpression => native.scalar('epoch_ms', asNode(value));

export function round(value: ExprValue, places?: ExprValue): SqlExpression {
  return native.round(asNode(value), places === undefined ? undefined : asNode(places));
}

export function coalesce(...values: ExprValue[]): SqlExpression {
  return native.coalesce(values.map(asNode));
}

export function nullif(left: ExprValue, right: ExprValue): SqlExpression {
  return native.scalarBinary('null_if', asNode(left), asNode(right));
}
