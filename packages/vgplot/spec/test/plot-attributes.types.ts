import type { PlotAttributes } from '../src/index.js';

export const container: PlotAttributes = {
  name: 'chart', width: '$dimension', height: 200, aspectRatio: false,
  margin: 10, marginTop: '$top', marginRight: 12, marginBottom: 13, marginLeft: 14,
  margins: { top: '$top', right: 0 }, inset: 4,
  style: { color: 'red', fontSize: '12px', length: 2 }, align: 0.5, padding: 0.2,
  axis: 'both', grid: '$grid', ariaLabel: null, ariaDescription: 'Three points', clip: 'frame'
};

// @ts-expect-error TypeScript dimensions retain ParamRef syntax.
export const plainWidth: PlotAttributes = { width: 'wire-only' };
// @ts-expect-error Margins retain their explicit side keys.
export const extraMargin: PlotAttributes = { margins: { center: 2 } };
// @ts-expect-error Nested margin sides exclude booleans.
export const booleanMargin: PlotAttributes = { margins: { top: false } };
// @ts-expect-error CSS known properties retain DOM value types.
export const numericColor: PlotAttributes = { style: { color: 2 } };
// @ts-expect-error PlotAttributes excludes the runtime-only label route.
export const runtimeLabel: PlotAttributes = { label: 'Measure' };
// @ts-expect-error Grid excludes numeric tick counts in this existing declaration.
export const numericGrid: PlotAttributes = { grid: 5 };
// @ts-expect-error Clip retains its literal/boolean/reference vocabulary.
export const arbitraryClip: PlotAttributes = { clip: 'wire-only' };
