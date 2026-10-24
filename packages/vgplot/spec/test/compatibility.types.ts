import type { Circle, ColorScheme, Hexagon, RuleY } from '../src/index.js';

export const canonicalScheme: ColorScheme = 'YlGnBu';
export const lowercaseScheme: ColorScheme = 'ylgnbu';
// @ts-expect-error TypeScript accepts canonical and lowercase scheme spellings.
export const uppercaseScheme: ColorScheme = 'YLGNBU';
// @ts-expect-error The schema admits objects, while the TypeScript type does not.
export const objectScheme: ColorScheme = {};

export const ruleY: RuleY = { mark: 'ruleY', y1: 1, y2: 2, insetTop: 3 };
// @ts-expect-error RuleY currently inherits RuleXOptions and excludes x1.
export const horizontalRuleY: RuleY = { mark: 'ruleY', x1: 1 };
export const circle: Circle = { mark: 'circle', data: [{}], symbol: 'star' };
export const hexagon: Hexagon = { mark: 'hexagon', data: [{}], symbol: 'star' };
