import type { LabelArrow, PlotAttributes } from '../src/index.js';

export const cartesian: PlotAttributes = {
  xScale: 'utc', yScale: 'band', xDomain: [new Date()], yDomain: 'Fixed',
  xRange: 'Fixed', yRange: '$range', xyDomain: '$domain',
  xNice: '2 weeks', yNice: 4, xInset: -2, xInsetLeft: 2, xInsetRight: 3,
  yInset: '$inset', yInsetTop: 4, yInsetBottom: 5, xClamp: false, yClamp: '$clamp',
  xRound: true, yRound: false, xAlign: 0.5, yAlign: '$align',
  xPadding: 0.2, yPaddingInner: 0, yPaddingOuter: 0.1,
  xAxis: null, yAxis: 'both', xTicks: [1, 2], yTicks: 'day',
  xTickSize: 4, yTickSpacing: 30, xTickPadding: 2, yTickRotate: 45,
  xTickFormat: '.2f', yTickFormat: null, xGrid: 'day', yGrid: 4,
  xLine: true, yLine: false, xLabel: null, yLabel: 'Value',
  xLabelAnchor: 'top', yLabelAnchor: 'left', xLabelArrow: null, yLabelArrow: false,
  xLabelOffset: 4, yFontVariant: 'tabular-nums', xAriaLabel: 'Time',
  yAriaDescription: 'The vertical values', xPercent: true, yReverse: false,
  xZero: false, yExponent: 2, xBase: 10, yConstant: 1
};
export const arrowDirections: LabelArrow[] = ['auto', 'up', 'right', 'down', 'left', 'none', true, false, null];
// @ts-expect-error LabelArrow excludes arbitrary strings.
export const unknownArrow: LabelArrow = 'middle';
// @ts-expect-error LabelArrow excludes numbers.
export const numericArrow: LabelArrow = 1;
// @ts-expect-error Native callbacks exceed the declarative formatter contract.
export const formatter: PlotAttributes = { xTickFormat: (value: number) => String(value) };
export const nullGrid: PlotAttributes = { xGrid: null };
// @ts-expect-error Position scale names retain their declared vocabulary.
export const unknownScale: PlotAttributes = { xScale: 'unknown' };
// @ts-expect-error Axis orientations remain axis-specific.
export const wrongAxis: PlotAttributes = { yAxis: 'top' };
// @ts-expect-error Window unit dictionaries are not scale interval strings.
export const windowInterval: PlotAttributes = { xNice: { days: 1 } };
