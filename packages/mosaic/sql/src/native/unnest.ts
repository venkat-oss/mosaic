import { asLiteral, asNode } from './expression.js';
import { native } from './runtime.js';
import type { ExprValue, SqlExpression } from './types.js';

export interface UnnestOptions {
  recursive?: ExprValue;
  max_depth?: ExprValue;
}

export function unnest(value: ExprValue, options: UnnestOptions = {}): SqlExpression {
  return native.unnest(asNode(value), {
    expressions: Object.entries(options).map(([name, value]) => native.namedArgument(name, asLiteral(value)))
  });
}
