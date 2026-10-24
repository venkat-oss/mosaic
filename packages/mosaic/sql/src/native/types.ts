import type { ast } from '#polyglot';
import type { ParamLike } from '../types.js';

export type SqlExpression = ast.Expression;
export type SqlValue = string | number | bigint | boolean | Date | RegExp | null | undefined;
export interface SqlExpressionHandle {
  readonly expression: SqlExpression;
}
export type SqlRoot = SqlExpression | SqlExpressionHandle;
export type ExprValue = SqlRoot | SqlValue | ParamLike;
export type MaybeArray<T> = T | readonly T[];
export type ParamReader = (param: ParamLike) => unknown;
export type { ParamLike };
