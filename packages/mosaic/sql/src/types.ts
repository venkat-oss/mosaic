import type { ast } from '#polyglot';

export type SqlExpression = ast.Expression;
export type SqlValue = string | number | bigint | boolean | Date | RegExp | null | undefined;
export interface SqlExpressionHandle {
  readonly expression: SqlExpression;
}
export type SqlRoot = SqlExpression | SqlExpressionHandle;
export type ExprValue = SqlRoot | SqlValue | ParamLike;
export type MaybeArray<T> = T | readonly T[];
export type ParamReader = (param: ParamLike) => unknown;

export interface ParamLike {
  /** The current parameter value. */
  value: unknown;
  /** Add an event listener callback. */
  addEventListener(type: string, callback: EventCallback): void;
  /** Remove an event listener callback. */
  removeEventListener(type: string, callback: EventCallback): void;
}

export type EventCallback = <T>(value: unknown) => Promise<T> | undefined;

export type ExprVarArgs = MaybeArray<ExprValue>;
export type StringValue = SqlRoot | ParamLike | string;
export type NumberValue = SqlRoot | ParamLike | number;
