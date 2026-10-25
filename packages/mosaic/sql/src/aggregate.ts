import { asNode } from './expression.js';
import { parseExpression } from './ingress.js';
import { createExecutionContext, native } from './runtime.js';
import type { SqlExecutionContext } from './runtime.js';
import { compile } from './compile.js';
import { cloneExpression } from './bindings.js';
import { rootExpression } from './bindings.js';
import { Window } from './window.js';
import type { WindowFrame } from './window.js';
import type { ExprValue, MaybeArray, SqlExpression, SqlExpressionHandle, SqlRoot } from './types.js';

export type AggregateName = Parameters<typeof native.aggregateCall>[0];
export type AggregateInfo = NonNullable<ReturnType<typeof native.inspectAggregate>>;

export function inspectAggregate(input: SqlRoot): AggregateInfo | undefined {
  return native.inspectAggregate(rootExpression(input));
}

export class Aggregate implements SqlExpressionHandle {
  constructor(readonly expression: SqlExpression) {
    if (!native.inspectAggregate(expression)) throw new TypeError('Expected a native semantic aggregate expression.');
  }

  private derive(options: Parameters<typeof native.withAggregateOptions>[1]): Aggregate {
    return new Aggregate(native.withAggregateOptions(this.expression, options));
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

  toString(context: SqlExecutionContext = createExecutionContext()): string {
    return compile([this], context)[0];
  }

  window(): Window { return new Window(this); }
  partitionby(...values: MaybeArray<ExprValue>[]): Window { return this.window().partitionby(...values); }
  orderby(...values: MaybeArray<ExprValue>[]): Window { return this.window().orderby(...values); }
  frame(frame: WindowFrame): Window { return this.window().frame(frame); }
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

function call(operator: AggregateName, values: readonly ExprValue[]): Aggregate {
  return new Aggregate(native.aggregateCall(operator, values.map(asNode)));
}

export const argmax = (value: ExprValue, key: ExprValue): Aggregate => call('arg_max', [value, key]);
export const argmin = (value: ExprValue, key: ExprValue): Aggregate => call('arg_min', [value, key]);
export const arrayAgg = (value: ExprValue): Aggregate => call('array_agg', [value]);
export const corr = (x: ExprValue, y: ExprValue): Aggregate => call('corr', [x, y]);
export const covariance = (x: ExprValue, y: ExprValue): Aggregate => call('covar_samp', [x, y]);
export const covarPop = (x: ExprValue, y: ExprValue): Aggregate => call('covar_pop', [x, y]);
export const entropy = (value: ExprValue): Aggregate => call('entropy', [value]);
export const first = (value: ExprValue): Aggregate => call('first', [value]);
export const last = (value: ExprValue): Aggregate => call('last', [value]);
export const geomean = (value: ExprValue): Aggregate => call('geometric_mean', [value]);
export const kurtosis = (value: ExprValue): Aggregate => call('kurtosis', [value]);
export const mad = (value: ExprValue): Aggregate => call('mad', [value]);
export const median = (value: ExprValue): Aggregate => call('median', [value]);
export const mode = (value: ExprValue): Aggregate => call('mode', [value]);
export const product = (value: ExprValue): Aggregate => call('product', [value]);
export const quantile = (value: ExprValue, probability: ExprValue): Aggregate => call('quantile', [value, probability]);
export const regrAvgX = (x: ExprValue, y: ExprValue): Aggregate => call('regr_avgx', [x, y]);
export const regrAvgY = (x: ExprValue, y: ExprValue): Aggregate => call('regr_avgy', [x, y]);
export const regrCount = (x: ExprValue, y: ExprValue): Aggregate => call('regr_count', [x, y]);
export const regrIntercept = (x: ExprValue, y: ExprValue): Aggregate => call('regr_intercept', [x, y]);
export const regrR2 = (x: ExprValue, y: ExprValue): Aggregate => call('regr_r2', [x, y]);
export const regrSXX = (x: ExprValue, y: ExprValue): Aggregate => call('regr_sxx', [x, y]);
export const regrSXY = (x: ExprValue, y: ExprValue): Aggregate => call('regr_sxy', [x, y]);
export const regrSYY = (x: ExprValue, y: ExprValue): Aggregate => call('regr_syy', [x, y]);
export const regrSlope = (x: ExprValue, y: ExprValue): Aggregate => call('regr_slope', [x, y]);
export const skewness = (value: ExprValue): Aggregate => call('skewness', [value]);
export const stddev = (value: ExprValue): Aggregate => call('stddev', [value]);
export const stddevPop = (value: ExprValue): Aggregate => call('stddev_pop', [value]);
export const stringAgg = (value: ExprValue): Aggregate => call('string_agg', [value]);
export const variance = (value: ExprValue): Aggregate => call('var_samp', [value]);
export const varPop = (value: ExprValue): Aggregate => call('var_pop', [value]);
