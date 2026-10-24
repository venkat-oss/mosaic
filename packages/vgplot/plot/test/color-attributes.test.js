// @vitest-environment jsdom
import { interpolateBlues, interpolateRgb, interpolateViridis, symbolStar, symbolTriangle } from 'd3';
import { describe, expect, it } from 'vitest';
import { Fixed, Mark, Plot } from '../src/index.js';
import { plotRenderer } from '../src/plot-renderer.js';

function configured(attributes) {
  const plot = new Plot();
  for (const [name, value] of Object.entries(attributes)) plot.setAttribute(name, value);
  return plot;
}

it.each(['colorRange', 'opacityRange', 'symbolRange'])('%s preserves the unsupported Fixed-range error', async name => {
  const plot = configured({ [name]: Fixed });
  await expect(plotRenderer(plot)).rejects.toThrow(`Unsupported fixed attribute: ${name}`);
});

it.each([
  { scale: 'color', channel: 'fill' },
  { scale: 'opacity', channel: 'opacity' },
  { scale: 'symbol', channel: 'symbol' }
])('$scale retains its admitted null-scale renderer limitation', async ({ scale, channel }) => {
  const plot = configured({ [`${scale}Scale`]: null });
  plot.addMark(new Mark('dot', [{ value: 2 }], { x: 1, y: 1, [channel]: 'value' }));
  await expect(plotRenderer(plot)).rejects.toThrow('unknown scale type: null');
});

it('normalizes native scheme casing while open-object wire values still reject at rendering', async () => {
  const colors = [];
  for (const scheme of ['YlGnBu', 'ylgnbu', 'YLGNBU']) {
    const svg = await plotRenderer(configured({ colorScale: 'linear', colorDomain: [0, 1], colorScheme: scheme }));
    colors.push([svg.scale('color').apply(0), svg.scale('color').apply(0.5), svg.scale('color').apply(1)]);
  }
  expect(colors[1]).toEqual(colors[0]);
  expect(colors[2]).toEqual(colors[0]);
  expect(new Set(colors[0]).size).toBe(3);
  await expect(plotRenderer(configured({ colorScale: 'linear', colorDomain: [0, 1], colorScheme: {} })))
    .rejects.toThrow('unknown quantitative scheme: [object object]');
  await expect(plotRenderer(configured({ colorScale: 'linear', colorDomain: [0, 1], colorScheme: 'Bogus' })))
    .rejects.toThrow('unknown quantitative scheme: bogus');
});

describe('native interpolation and range execution', () => {
  it('preserves a one-argument sequential interpolator as the actual function', async () => {
    const plot = configured({ colorScale: 'linear', colorDomain: [0, 1], colorInterpolate: interpolateBlues });
    const svg = await plotRenderer(plot);
    expect(plot.getAttribute('colorInterpolate')).toBe(interpolateBlues);
    expect(svg.scale('color').apply(0.5)).toBe(interpolateBlues(0.5));
  });

  it('preserves a two-argument interpolation factory with explicit CSS color endpoints', async () => {
    const interpolate = interpolateRgb.gamma(2.2);
    const plot = configured({ colorScale: 'linear', colorDomain: [0, 1], colorRange: ['red', 'blue'], colorInterpolate: interpolate });
    const svg = await plotRenderer(plot);
    expect(plot.getAttribute('colorInterpolate')).toBe(interpolate);
    expect(svg.scale('color').apply(0.5)).toBe(interpolate('red', 'blue')(0.5));
  });

  it('passes an ordinal color-range callback its domain without converting the native function', async () => {
    const observed = [];
    const range = domain => { observed.push(domain); return ['red', 'blue']; };
    const plot = configured({ colorScale: 'ordinal', colorDomain: ['A', 'B'], colorRange: range });
    const svg = await plotRenderer(plot);
    expect(plot.getAttribute('colorRange')).toBe(range);
    expect(observed).toEqual([['A', 'B']]);
    expect(svg.scale('color').apply('A')).toBe('red');
    expect(svg.scale('color').apply('B')).toBe('blue');
  });

  it('uses numeric color-range bounds to select a portion of a named scheme', async () => {
    const plot = configured({ colorScale: 'ordinal', colorDomain: ['A', 'B'], colorScheme: 'Viridis', colorRange: [0.2, 0.8] });
    const svg = await plotRenderer(plot);
    expect(svg.scale('color').apply('A')).toBe(interpolateViridis(0.2));
    expect(svg.scale('color').apply('B')).toBe(interpolateViridis(0.8));
  });

  it('uses numeric opacity ranges as output values', async () => {
    const svg = await plotRenderer(configured({ opacityScale: 'linear', opacityDomain: [0, 1], opacityRange: [0.2, 0.9] }));
    expect(svg.scale('opacity').apply(0)).toBe(0.2);
    expect(svg.scale('opacity').apply(1)).toBe(0.9);
  });

  it.each([{ range: ['STAR', 'Triangle'] }, { range: [symbolStar, symbolTriangle] }])('admits symbol-range names or native symbol objects: %j', async ({ range }) => {
    const svg = await plotRenderer(configured({ symbolScale: 'ordinal', symbolDomain: ['A', 'B'], symbolRange: range }));
    expect(svg.scale('symbol').apply('A')).toBe(symbolStar);
    expect(svg.scale('symbol').apply('B')).toBe(symbolTriangle);
  });
});
