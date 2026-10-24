import type { PlotAttributes } from '../src/index.js';

export const colorAttributeContracts = {
  colorScale: null,
  colorDomain: 'Fixed',
  colorRange: ['red', 'blue'],
  colorClamp: true,
  colorN: 4,
  colorNice: 'month',
  colorScheme: 'ylgnbu',
  colorInterpolate: 'lab',
  colorPivot: { arbitrary: true },
  colorSymmetric: true,
  colorLabel: null,
  colorPercent: false,
  colorReverse: true,
  colorZero: false,
  colorTickFormat: null,
  colorExponent: 2,
  colorBase: 2,
  colorConstant: 1,
  opacityScale: 'utc',
  opacityDomain: [0, 1],
  opacityRange: [0.2, 0.9],
  opacityClamp: false,
  opacityNice: true,
  opacityLabel: 'Alpha',
  opacityPercent: false,
  opacityReverse: true,
  opacityZero: false,
  opacityTickFormat: '.1f',
  opacityExponent: 2,
  opacityBase: 2,
  opacityConstant: 1,
  symbolScale: null,
  symbolDomain: ['A', 'B'],
  symbolRange: ['circle', 'star']
} satisfies PlotAttributes;

// @ts-expect-error Discrete symbol scales retain their narrower type vocabulary.
export const continuousSymbolScale: PlotAttributes = { symbolScale: 'linear' };
// @ts-expect-error Continuous opacity scales do not acquire categorical types.
export const categoricalOpacityScale: PlotAttributes = { opacityScale: 'categorical' };
// @ts-expect-error Native interpolation callbacks are JavaScript runtime values.
export const callbackInterpolation: PlotAttributes = { colorInterpolate: (value: number) => String(value) };
// @ts-expect-error Native range callbacks are not wire type expressions.
export const callbackRange: PlotAttributes = { colorRange: (domain: string[]) => domain };
// @ts-expect-error Scalar parameter references retain their TypeScript prefix.
export const ordinaryColorLabel: PlotAttributes = { colorClamp: 'ordinary-reference' };

// @ts-expect-error The wire alias open-object branch does not broaden TypeScript scheme values.
export const objectColorScheme: PlotAttributes = { colorScheme: {} };
