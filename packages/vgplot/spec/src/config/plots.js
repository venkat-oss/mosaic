import { INTERACTOR_NAMES } from '../generated/interactors.js';
import {
  attributeDirectives,
  legendDirectives,
  markDirectives
} from '@uwdata/vgplot';

export function plotNames({
  attributes = plotAttributeNames(),
  interactors = plotInteractorNames(),
  legends = plotLegendNames(),
  marks = plotMarkNames()
} = {}) {
  return { attributes, interactors, legends, marks };
}

/**
 * @returns {Set<string>}
 */
export function plotAttributeNames(overrides = []) {
  return new Set([
    ...Object.keys(attributeDirectives),
    ...overrides
  ]);
}

/**
 * @returns {Set<string>}
 */
export function plotInteractorNames(overrides = []) {
  return new Set([
    ...INTERACTOR_NAMES,
    ...overrides
  ]);
}

/**
 * @returns {Set<string>}
 */
export function plotLegendNames(overrides = []) {
  return new Set([
    ...Object.keys(legendDirectives),
    ...overrides
  ]);
}

/**
 * @returns {Set<string>}
 */
export function plotMarkNames(overrides = []) {
  return new Set([
    ...Object.keys(markDirectives),
    ...overrides
  ]);
}
