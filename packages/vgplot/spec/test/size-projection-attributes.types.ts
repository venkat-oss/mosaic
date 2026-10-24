import type { PlotAttributes } from '../src/index.js';

export const sizeProjectionContracts = {
  rScale: 'sqrt', rDomain: 'Fixed', rRange: [2, 12], rClamp: { custom: true },
  rNice: 'month', rLabel: null, rPercent: false, rZero: true,
  rExponent: 0.5, rBase: 2, rConstant: 1,
  lengthScale: 'linear', lengthDomain: [-10, -1], lengthRange: '$range',
  lengthClamp: [], lengthNice: true, lengthPercent: true, lengthZero: false,
  lengthExponent: 2, lengthBase: 2, lengthConstant: 1,
  projectionType: 'mercator', projectionDomain: { type: 'Sphere' },
  projectionRotate: [10, 20], projectionParallels: [29.5, 45.5],
  projectionPrecision: 0.2, projectionClip: null, projectionInset: '$inset',
  projectionInsetTop: 10, projectionInsetRight: 20,
  projectionInsetBottom: 30, projectionInsetLeft: 40
} satisfies PlotAttributes;

export const nativeObjectDomain: PlotAttributes = { projectionDomain: [] };

// @ts-expect-error Continuous size scales retain their declared vocabulary.
export const categoricalRadius: PlotAttributes = { rScale: 'categorical' };
// @ts-expect-error Scalar references require the declared parameter prefix.
export const plainSizeReference: PlotAttributes = { lengthBase: 'ordinary' };
// @ts-expect-error Size nice excludes interval option objects.
export const objectNice: PlotAttributes = { rNice: { unit: 'month' } };
// @ts-expect-error Projection names exclude native initializer functions.
export const nativeProjection: PlotAttributes = { projectionType: () => ({}) };
// @ts-expect-error Projection rotation requires at least two angles.
export const shortRotation: PlotAttributes = { projectionRotate: [10] };
// @ts-expect-error Projection rotation retains its upper arity bound.
export const longRotation: PlotAttributes = { projectionRotate: [10, 20, 0, 0] };
// @ts-expect-error Projection parallels retain their two-angle shape.
export const longParallels: PlotAttributes = { projectionParallels: [10, 20, 30] };
