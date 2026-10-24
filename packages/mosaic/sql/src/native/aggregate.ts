import { asNode } from './expression.js';
import { parseExpression } from './ingress.js';
import { native } from './runtime.js';
import { cloneExpression } from './bindings.js';
import type { ExprValue, MaybeArray, SqlExpression, SqlExpressionHandle } from './types.js';

export type AggregateName = 'count' | 'sum' | 'avg' | 'min' | 'max';

export class Aggregate implements SqlExpressionHandle {
  constructor(readonly expression: SqlExpression) {}

  private derive(options: Pick<NonNullable<Parameters<typeof native.aggregate>[2]>, 'distinct' | 'filter' | 'order_by'>): Aggregate {
    const expression = this.expression;
    if ('count' in expression) {
      const { order_by, ...countOptions } = options;
      if (order_by?.length) throw new TypeError('Ordered COUNT arguments require native aggregate support.');
      return new Aggregate(native.count(expression.count.this ?? undefined, { ...expression.count, ...countOptions }));
    }
    const aggregate = 'sum' in expression ? ['sum', expression.sum] as const
      : 'avg' in expression ? ['avg', expression.avg] as const
        : 'min' in expression ? ['min', expression.min] as const
          : 'max' in expression ? ['max', expression.max] as const
            : null;
    if (!aggregate) throw new TypeError('Expected a native aggregate expression.');
    const [name, value] = aggregate;
    return new Aggregate(native.aggregate(name, value.this, { ...value, ...options }));
  }

  distinct(value = true): Aggregate {
    return this.derive({ distinct: !!value });
  }

  where(value: ExprValue): Aggregate {
    return this.derive({ filter: typeof value === 'string' ? parseExpression(value) : asNode(value) });
  }

  argOrder(...values: MaybeArray<ExprValue>[]): Aggregate {
    return this.derive({ order_by: values.flat().map(value => {
      const node = asNode(value);
      return 'ordered' in node ? node.ordered : native.ordered(node).ordered;
    }) });
  }

  clone(): Aggregate {
    return new Aggregate(cloneExpression(this));
  }
}

export function count(value?: ExprValue): Aggregate {
  return new Aggregate(native.count(value === undefined ? undefined : asNode(value)));
}

export function sum(value: ExprValue): Aggregate {
  return new Aggregate(native.aggregate('sum', asNode(value)));
}

export function avg(value: ExprValue): Aggregate {
  return new Aggregate(native.aggregate('avg', asNode(value)));
}

export function min(value: ExprValue): Aggregate {
  return new Aggregate(native.aggregate('min', asNode(value)));
}

export function max(value: ExprValue): Aggregate {
  return new Aggregate(native.aggregate('max', asNode(value)));
}
