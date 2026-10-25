import { binSpec } from './transforms/util/bin-step.js';
import { timeInterval } from './transforms/util/time-interval.js';
import type { DateTimeValue, TimeUnit } from './transforms/util/time-interval.js';
import { sum } from './aggregate.js';
import { float64, int32 } from './cast.js';
import { dateBin, interval } from './datetime.js';
import { floor } from './numeric.js';
import { add, div, mul, neq, sub } from './operators.js';
import { Query } from './query.js';
import { scaleTransform } from './scales.js';
import type { Scale } from './scales.js';
import type { ExprValue, SqlExpression } from './types.js';

export function bin1d(value: ExprValue, lo: number, hi: number, bins: number, reverse = false): SqlExpression {
  const difference = reverse ? sub(hi, float64(value)) : sub(float64(value), lo);
  const scale = hi === lo ? 0 : bins / (hi - lo);
  return scale ? mul(difference, float64(scale)) : difference;
}

export function bin2d(query: Query, x: ExprValue, y: ExprValue, aggregates: Record<string, ExprValue>, width: number, groups: string[]): Query {
  return query.select({ index: add(int32(floor(x)), mul(int32(floor(y)), width)), ...aggregates }).groupby('index', groups);
}

export function binHistogram(
  field: ExprValue,
  extent: [number, number],
  options: BinHistogramOptions = {},
  transform: Scale<number> = scaleTransform({ type: 'linear' })
): SqlExpression {
  const [min, max] = extent;
  const { offset = 0 } = options;
  if (max === min) return offset ? add(offset, floor(field)) : floor(field);
  const { apply, sqlApply, sqlInvert } = transform;
  const bins = binSpec(apply(min), apply(max), options);
  const column = sqlApply(field);
  const step = ((bins.max - bins.min) / bins.steps) || 1;
  let expression = bins.min === 0 ? column : sub(column, bins.min);
  if (step !== 1) expression = div(expression, float64(step));
  expression = offset ? add(offset, floor(expression)) : floor(expression);
  if (step !== 1) expression = mul(step, expression);
  if (bins.min !== 0) expression = add(bins.min, expression);
  return sqlInvert(expression);
}

export function binDate(field: ExprValue, extent: [DateTimeValue, DateTimeValue], options: BinDateOptions = {}): SqlExpression {
  const { offset = 0 } = options;
  const { unit, step = 1 } = options.interval
    ? { unit: options.interval, step: options.step }
    : timeInterval(extent[0], extent[1], options.steps || 40);
  const bin = dateBin(field, unit, step);
  return offset ? add(bin, interval(unit, offset * step)) : bin;
}

export function binLinear1d(query: Query, value: ExprValue, weight?: ExprValue, groups: string[] = []): Query {
  const weighted = (expression: SqlExpression) => weight == null ? expression : mul(expression, weight);
  const lower = floor(value);
  const upper = add(lower, 1);
  return Query.from(Query.unionAll(
    query.clone().select({ i: int32(lower), w: weighted(sub(upper, value)) }),
    query.clone().select({ i: int32(upper), w: weighted(sub(value, lower)) })
  )).select({ index: 'i', density: sum('w') }, groups).groupby('index', groups).having(neq('density', 0));
}

export function binLinear2d(query: Query, x: ExprValue, y: ExprValue, weight: ExprValue | undefined, width: number, groups: string[] = []): Query {
  const weighted = (expression: SqlExpression) => weight == null ? expression : mul(expression, weight);
  const branch = (index: SqlExpression, expression: SqlExpression) => query.clone().select({ xp: x, yp: y, i: index, w: expression });
  const index = (x: ExprValue, y: ExprValue) => add(x, mul(y, width));
  const x0 = int32(floor(x));
  const y0 = int32(floor(y));
  const x1 = add(x0, 1);
  const y1 = add(y0, 1);
  const dx0 = sub(x, x0);
  const dx1 = sub(x1, x);
  const dy0 = sub(y, y0);
  const dy1 = sub(y1, y);
  return Query.from(Query.unionAll(
    branch(index(x0, y0), weighted(mul(dx1, dy1))),
    branch(index(x0, y1), weighted(mul(dx1, dy0))),
    branch(index(x1, y0), weighted(mul(dx0, dy1))),
    branch(index(x1, y1), weighted(mul(dx0, dy0)))
  )).select({ index: 'i', density: sum('w') }, groups).groupby('index', groups).having(neq('density', 0));
}

export interface BinDateOptions {
  /**
   * A string indicating a time interval unit,
   * such as 'year', 'day', or 'hour'.
   */
  interval?: TimeUnit;
  /**
   * The number of time interval steps to take, such as 2 years or 3 months.
   */
  step?: number;
  /**
   * The number of bin steps (default 0) by which to offset the result.
   */
  offset?: number;
  /**
   * The desired number of binning steps. This value is a hint,
   * it does not guarantee an exact number of steps.
   */
  steps?: number;
}

export interface BinHistogramOptions {
  /** An exact binning step to use. */
  step?: number;
  /**
   * The desired number of binning steps. This value is a hint,
   * it does not guarantee an exact number of steps.
   */
  steps?: number;
  /**
   * A minimum binning step value. No generated
   * step can be less than this value.
   */
  minstep?: number;
  /**
   * A boolean flag (default true) indicating if bin extents should be
   * snapped to "nice" numbers such as multiples of 5 or 10.
   */
  nice?: boolean;
  /**
   * The number of bin steps (default 0) by which to offset the result.
   */
  offset?: number;
}
