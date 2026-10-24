import type { AggregateOptions, AggregateTransform, Argmax, Argmin, Avg, Count, Covariance, CovarPop, First, Geomean, Last, Max, Min, Median, Mode, Product, Quantile, Stddev, StddevPop, Sum, Variance, VarPop } from '../src/index.js';

export const aggregateTypes = {
  options: { distinct: false } satisfies AggregateOptions,
  argmax: { argmax: ['x', '$field'] } satisfies Argmax,
  argmin: { argmin: [{ sql: 'x' }, 'y'] } satisfies Argmin,
  avg: { avg: 'x', rows: [null, 0], exclude: 'ties' } satisfies Avg,
  count: { count: null } satisfies Count,
  covariance: { covariance: ['x', 'y'] } satisfies Covariance,
  covarPop: { covarPop: ['x', 'y'] } satisfies CovarPop,
  first: { first: 'x' } satisfies First,
  geomean: { geomean: 'x' } satisfies Geomean,
  last: { last: 'x' } satisfies Last,
  max: { max: 'x' } satisfies Max,
  min: { min: ['x'] } satisfies Min,
  median: { median: 'x' } satisfies Median,
  mode: { mode: 'x' } satisfies Mode,
  product: { product: 'x' } satisfies Product,
  quantile: { quantile: ['x', 0.5] } satisfies Quantile,
  stddev: { stddev: 'x' } satisfies Stddev,
  stddevPop: { stddevPop: 'x' } satisfies StddevPop,
  sum: { sum: { avg: 'x' }, distinct: true } satisfies Sum,
  variance: { variance: 'x' } satisfies Variance,
  varPop: { varPop: 'x' } satisfies VarPop
};

// @ts-expect-error Binary aggregate signatures require both fields.
export const shortArgmax: Argmax = { argmax: ['x'] };
// @ts-expect-error Probabilities cannot be boolean.
export const booleanQuantile: Quantile = { quantile: ['x', false] };
// @ts-expect-error Covariance remains outside the historical root union.
export const unreachableCovariance: AggregateTransform = { covariance: ['x', 'y'] };
// @ts-expect-error Geomean remains outside the historical root union.
export const unreachableGeomean: AggregateTransform = { geomean: 'x' };
// @ts-expect-error Count does not accept bare numeric arguments.
export const numericCount: Count = { count: 0 };
