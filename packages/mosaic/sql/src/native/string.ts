import { asLiteral, asNode } from './expression.js';
import { native } from './runtime.js';
import type { ExprValue, SqlExpression } from './types.js';

export const lower = (value: ExprValue): SqlExpression => native.scalar('lower', asNode(value));
export const upper = (value: ExprValue): SqlExpression => native.scalar('upper', asNode(value));
export const length = (value: ExprValue): SqlExpression => native.scalar('length', asNode(value));
export const contains = (value: ExprValue, substring: ExprValue): SqlExpression => native.scalarBinary('contains', asNode(value), asLiteral(substring));
export const prefix = (value: ExprValue, substring: ExprValue): SqlExpression => native.scalarBinary('starts_with', asNode(value), asLiteral(substring));
export const suffix = (value: ExprValue, substring: ExprValue): SqlExpression => native.scalarBinary('ends_with', asNode(value), asLiteral(substring));
export const collate = (value: ExprValue, collation: string): SqlExpression => native.collate(asNode(value), collation);

export function regexp_matches(value: ExprValue, pattern: ExprValue, options?: ExprValue): SqlExpression {
  return native.regexpMatches(asNode(value), asLiteral(pattern), options === undefined ? null : asLiteral(options));
}
