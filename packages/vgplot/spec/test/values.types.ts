import type {
  ColorScaleType, ColorScheme, ContinuousScaleType, CSSStyles, CurveName,
  DiscreteScaleType, Fixed, FrameAnchor, Interpolate, Interval,
  LiteralTimeInterval, PositionScaleType, ProjectionName, Reducer,
  ReducerPercentile, ScaleName, SymbolType, TimeIntervalName
} from '../src/index.js';

type Equal<X, Y> = (<T>() => T extends X ? 1 : 2) extends (<T>() => T extends Y ? 1 : 2) ? true : false;
type Assert<T extends true> = T;

export type GenericIntervals = [
  Assert<Equal<Interval<Date>, LiteralTimeInterval>>,
  Assert<Equal<Interval<number>, number>>,
  Assert<Equal<Interval<any>, LiteralTimeInterval | number>>, // eslint-disable-line @typescript-eslint/no-explicit-any
  Assert<Equal<Interval<Date | number>, LiteralTimeInterval | number>>,
  Assert<Equal<Interval<string>, never>>,
  Assert<Equal<Interval<unknown>, never>>,
  Assert<Equal<Interval<never>, never>>
];

export const acceptedValues = {
  fixed: 'Fixed' satisfies Fixed,
  timeName: 'half' satisfies TimeIntervalName,
  timeTemplates: ['3 months', '10 years', 'halfs', '-1.5 months', '1e3 days'] satisfies LiteralTimeInterval[],
  scale: 'length' satisfies ScaleName,
  position: 'band' satisfies PositionScaleType,
  color: 'diverging-symlog' satisfies ColorScaleType,
  continuous: 'utc' satisfies ContinuousScaleType,
  discrete: 'identity' satisfies DiscreteScaleType,
  projection: 'reflect-y' satisfies ProjectionName,
  interpolation: 'hcl' satisfies Interpolate,
  schemes: ['YlGnBu', 'ylgnbu'] satisfies ColorScheme[],
  symbol: 'triangle2' satisfies SymbolType,
  anchor: 'bottom-left' satisfies FrameAnchor,
  percentiles: ['p00', 'p01', 'p99'] satisfies ReducerPercentile[],
  reducers: ['proportion-facet', 'p00', 'p99'] satisfies Reducer[],
  curve: 'catmull-rom-closed' satisfies CurveName,
  css: { color: 'purple', fontSize: '13px', length: 2, 0: 'color' } satisfies CSSStyles
};

// @ts-expect-error Fixed retains its case-sensitive declarative spelling.
export const wrongFixed: Fixed = 'fixed';
// @ts-expect-error TimeIntervalName contains singular names.
export const pluralTimeName: TimeIntervalName = 'months';
// @ts-expect-error Native TypeScript time templates exclude arbitrary wire strings.
export const arbitraryTime: LiteralTimeInterval = 'a custom wire interval';
// @ts-expect-error Date intervals are time strings, not numeric intervals.
export const numericDateInterval: Interval<Date> = 2;
// @ts-expect-error Numeric intervals do not accept time strings.
export const timeNumberInterval: Interval<number> = 'month';
// @ts-expect-error ScaleName refers to encoding scales rather than marks.
export const wrongScale: ScaleName = 'area';
// @ts-expect-error Position scales use point or band rather than ordinal.
export const ordinalPosition: PositionScaleType = 'ordinal';
// @ts-expect-error ColorScaleType retains the existing finite vocabulary.
export const wrongColorScale: ColorScaleType = 'cyclic';
// @ts-expect-error Continuous scales exclude band scales.
export const bandContinuous: ContinuousScaleType = 'band';
// @ts-expect-error Discrete scales exclude linear scales.
export const linearDiscrete: DiscreteScaleType = 'linear';
// @ts-expect-error ProjectionName retains its declared projection vocabulary.
export const wrongProjection: ProjectionName = 'natural-earth';
// @ts-expect-error A color scheme is not an interpolation method.
export const wrongInterpolation: Interpolate = 'turbo';
// @ts-expect-error ColorScheme accepts canonical and lowercase spellings only.
export const uppercaseScheme: ColorScheme = 'YLGNBU';
// @ts-expect-error Empty objects are admitted by wire schema but not TypeScript.
export const objectScheme: ColorScheme = {};
// @ts-expect-error SymbolType excludes undeclared symbol variants.
export const wrongSymbol: SymbolType = 'triangle3';
// @ts-expect-error FrameAnchor uses middle rather than center.
export const wrongAnchor: FrameAnchor = 'center';
// @ts-expect-error Percentile reducers require exactly two decimal digits.
export const shortPercentile: ReducerPercentile = 'p0';
// @ts-expect-error Percentile reducers stop at p99.
export const excessivePercentile: ReducerPercentile = 'p100';
// @ts-expect-error Reducer retains percentile bounds.
export const excessiveReducer: Reducer = 'p100';
// @ts-expect-error CurveName excludes undeclared interpolation names.
export const wrongCurve: CurveName = 'bezier';
// @ts-expect-error CSS known properties retain DOM string types.
export const numericCssColor: CSSStyles = { color: 3 };
// @ts-expect-error CSS length retains its DOM numeric type.
export const stringCssLength: CSSStyles = { length: '2' };
// @ts-expect-error CSSStyles excludes arbitrary object keys at TypeScript ingress.
export const unknownCssKey: CSSStyles = { mosaicUnknown: 'allowed on the wire' };
// @ts-expect-error The DOM method adapter omits mutation methods.
export const cssMethod: CSSStyles = { setProperty: () => {} };
