import type { RowNumber, Rank, DenseRank, PercentRank, CumeDist, NTile, Lag, Lead, FirstValue, LastValue, NthValue, IntervalTransform, Years, Months, Days, Hours, Minutes, Seconds, Milliseconds, Microseconds } from '../src/index.js';

export const windowTypes = {
  rowNumber: { row_number: null } satisfies RowNumber,
  rank: { rank: [] } satisfies Rank,
  denseRank: { dense_rank: null } satisfies DenseRank,
  percentRank: { percent_rank: null } satisfies PercentRank,
  cumeDist: { cume_dist: null } satisfies CumeDist,
  ntile: { ntile: { sql: '2' } } satisfies NTile,
  lag: { lag: ['x'] } satisfies Lag,
  lead: { lead: ['x', 2, new Date()] } satisfies Lead,
  firstValue: { first_value: 'x' } satisfies FirstValue,
  lastValue: { last_value: ['x'] } satisfies LastValue,
  nthValue: { nth_value: ['x', 2] } satisfies NthValue,
  years: { years: 1 } satisfies Years,
  months: { months: 2 } satisfies Months,
  days: { days: 3 } satisfies Days,
  hours: { hours: 4 } satisfies Hours,
  minutes: { minutes: 5 } satisfies Minutes,
  seconds: { seconds: 6 } satisfies Seconds,
  milliseconds: { milliseconds: 7 } satisfies Milliseconds,
  microseconds: { microseconds: 8 } satisfies Microseconds,
  interval: { days: 2 } satisfies IntervalTransform
};

// @ts-expect-error NTile retains TransformField admission despite its numeric SQL meaning.
export const numericBuckets: NTile = { ntile: 2 };
// @ts-expect-error Nullary window signatures reject empty strings.
export const emptyRank: Rank = { rank: '' };
// @ts-expect-error Interval units require numbers.
export const stringDays: Days = { days: '2' };
// @ts-expect-error Offset cannot be boolean.
export const booleanLag: Lag = { lag: ['x', false, null] };
