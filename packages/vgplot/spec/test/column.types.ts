import type {
  AggregateExpression, Bin, BinInterval, Centroid, CentroidX, CentroidY, Column,
  DateDay, DateMonth, DateMonthDay, Expression, FrameExclude, FrameValue,
  GeoJSON, SQLExpression, TransformField, WindowOptions
} from '../src/index.js';

export const validColumns = {
  bin: { bin: ['x'], interval: 'month', step: 2, nice: false } satisfies Bin,
  column: { column: ['$field'] } satisfies Column,
  dateMonth: { dateMonth: new Date('2024-01-01') } satisfies DateMonth,
  dateMonthDay: { dateMonthDay: [new Date('2024-01-01')] } satisfies DateMonthDay,
  dateDay: { dateDay: { sql: 'time' } } satisfies DateDay,
  centroid: { centroid: 'geometry' } satisfies Centroid,
  centroidX: { centroidX: ['geometry'] } satisfies CentroidX,
  centroidY: { centroidY: { sql: 'geometry' } } satisfies CentroidY,
  geojson: { geojson: { centroid: 'geometry' } } satisfies GeoJSON,
  sql: { sql: 'x + $offset', label: 'Position' } satisfies SQLExpression,
  aggregate: { agg: 'AVG(x)', label: 'Average' } satisfies AggregateExpression,
  expression: { agg: 'COUNT(*)' } satisfies Expression,
  field: { bin: { sql: 'x + 1' } } satisfies TransformField,
  frame: { days: 2 } satisfies FrameValue,
  frameExclude: 'CURRENT ROW' satisfies FrameExclude,
  window: { rows: [null, 0], exclude: 'current row', orderby: ['x', '$field'] } satisfies WindowOptions,
  interval: 'number' satisfies BinInterval
};

// @ts-expect-error Unary tuples contain exactly one argument.
export const invalidBinTuple: Bin = { bin: ['x', 'y'] };
// @ts-expect-error Column accepts names and parameter references, not expressions.
export const invalidColumn: Column = { column: { sql: 'x' } };
// @ts-expect-error Date transforms still require an argument.
export const emptyDate: DateMonth = { dateMonth: [] };
// @ts-expect-error FrameExclude itself preserves canonical uppercase names.
export const lowercaseExclude: FrameExclude = 'current row';
// @ts-expect-error Window frames contain exactly two bounds.
export const incompleteFrame: WindowOptions = { rows: [0] };
// @ts-expect-error Exclusion case adapters allow all-uppercase or all-lowercase.
export const mixedExclude: WindowOptions = { exclude: 'Current Row' };
