import { asNode } from './expression.js';
import { native } from './runtime.js';
import type { ExprValue, SqlExpression } from './types.js';

export const unnest = (value: ExprValue): SqlExpression => native.unnest(asNode(value));
