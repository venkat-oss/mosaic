import type { PlotAttributes } from '../src/index.js';

export const facets: PlotAttributes = {
  facetMargin: '$margin', facetMarginTop: 12, facetMarginBottom: 18,
  facetMarginLeft: 24, facetMarginRight: 12, facetGrid: 'day', facetLabel: null,
  fxDomain: ['B', 'A'], fyDomain: 'Fixed', fxRange: 'Fixed', fyRange: '$range',
  fxInset: 4, fyInset: 60, fxInsetLeft: 2, fxInsetRight: 3,
  fyInsetTop: 4, fyInsetBottom: 5, fxRound: true, fyRound: '$round',
  fxAlign: 0.3, fyAlign: '$align', fxPadding: 0.2, fyPaddingInner: 0.1,
  fxPaddingOuter: 0.1, fxAxis: 'both', fyAxis: null, fxTicks: [1, 2], fyTicks: 'day',
  fxTickSize: 4, fyTickSpacing: 40, fxTickPadding: 2, fyTickFormat: null,
  fxTickFormat: '.1f', fyTickRotate: 30, fxGrid: 4, fyGrid: null,
  fxLine: false, fyLine: true, fxLabel: 'Columns', fyLabel: null,
  fxLabelAnchor: 'top', fyLabelAnchor: 'left', fxLabelOffset: 30,
  fyFontVariant: 'normal', fxAriaLabel: 'Column groups',
  fyAriaDescription: 'The row grouping', fxReverse: false, fyReverse: '$reverse'
};
// @ts-expect-error No public facet-scale type attribute exists.
export const facetScale: PlotAttributes = { fxScale: 'band' };
// @ts-expect-error Facet labels do not have a label-arrow attribute.
export const facetArrow: PlotAttributes = { fyLabelArrow: true };
// @ts-expect-error Horizontal facet axis orientation is axis-specific.
export const wrongAxis: PlotAttributes = { fxAxis: 'left' };
// @ts-expect-error Native callbacks exceed the declarative formatter type.
export const formatter: PlotAttributes = { fyTickFormat: (value: string) => value.toUpperCase() };
// @ts-expect-error Position padding is numeric or a parameter reference.
export const booleanPadding: PlotAttributes = { fxPadding: true };
// @ts-expect-error Window interval dictionaries are not scale interval strings.
export const windowInterval: PlotAttributes = { fxTicks: { days: 1 } };
