import { asNode } from './expression.js';
import { native } from './runtime.js';
import type { ExprValue, SqlExpression, SqlExpressionHandle } from './types.js';

class Case implements SqlExpressionHandle {
  constructor(readonly expression: SqlExpression = native.caseExpression()) {}

  when(condition: ExprValue, value: ExprValue): Case {
    if (!('case' in this.expression)) throw new TypeError('Expected a native CASE expression.');
    const { whens, else_: otherwise, ...options } = this.expression.case;
    return new Case(native.caseExpression([...whens, [asNode(condition), asNode(value)]], otherwise, options));
  }

  else(value: ExprValue): Case {
    if (!('case' in this.expression)) throw new TypeError('Expected a native CASE expression.');
    const data = this.expression.case;
    return new Case(native.caseExpression(data.whens, asNode(value), {
      operand: data.operand, comments: data.comments, inferred_type: data.inferred_type
    }));
  }
}

export function cond(condition?: ExprValue, value?: ExprValue, otherwise?: ExprValue): Case {
  return condition === undefined && value === undefined && otherwise === undefined
    ? new Case()
    : new Case(native.caseWhen(asNode(condition), asNode(value), asNode(otherwise)));
}
