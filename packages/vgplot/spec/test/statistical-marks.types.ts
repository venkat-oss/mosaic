import type { ErrorBarX, ErrorBarY, Hexbin, RegressionY } from '../src/index.js';

export const hexbin: Hexbin = {
  mark: 'hexbin', data: { from: 'rows' }, x: 'x', y: 'y',
  type: 'text', binWidth: '$width', fill: { count: null }
};
export const regression: RegressionY = {
  mark: 'regressionY', data: { from: 'rows' },
  x: 'x', y: 'y', ci: 0, precision: '$precision'
};
export const horizontal: ErrorBarX = {
  mark: 'errorbarX', data: { from: 'rows' }, x: 'value', y: 'group', ci: '$confidence'
};
export const vertical: ErrorBarY = {
  mark: 'errorbarY', data: { from: 'rows' }, x: 'group', y: 'value'
};

// @ts-expect-error The horizontal dependent channel is required.
export const missingX: ErrorBarX = { mark: 'errorbarX', data: { from: 'rows' } };
// @ts-expect-error The vertical dependent channel is required.
export const missingY: ErrorBarY = { mark: 'errorbarY', data: { from: 'rows' } };
// @ts-expect-error Statistical declarative contracts require data.
export const missingData: RegressionY = { mark: 'regressionY', x: 'x', y: 'y' };
// @ts-expect-error The bin width accepts a number or a parameter reference.
export const invalidWidth: Hexbin = { mark: 'hexbin', data: { from: 'rows' }, binWidth: {} };
