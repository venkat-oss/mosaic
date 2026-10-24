// @vitest-environment jsdom
import { describe, expect, it } from 'vitest';
import { Fixed, Plot } from '../src/index.js';
import { plotRenderer } from '../src/plot-renderer.js';
import { attributeMap } from '../src/plot-attributes.js';

describe('retained Cartesian fixed-range limitation', () => {
  it.each(['xRange', 'yRange'])('%s rejects Fixed while fixed domains use inference', async name => {
    const plot = new Plot();
    plot.setAttribute(name, Fixed);
    await expect(plotRenderer(plot)).rejects.toThrow(`Unsupported fixed attribute: ${name}`);
  });
});


describe('retained Cartesian label-anchor orientation', () => {
  it.each([['xLabelAnchor', 'top'], ['xLabelAnchor', 'bottom'], ['yLabelAnchor', 'left'], ['yLabelAnchor', 'right']])('%s rejects %s beyond its orientation', async (name, value) => {
    const plot = new Plot();
    plot.setAttribute('xDomain', [0, 1]);
    plot.setAttribute('yDomain', [0, 1]);
    plot.setAttribute(name, value);
    await expect(plotRenderer(plot)).rejects.toThrow(`invalid labelAnchor: ${value}`);
  });
});

describe('retained Cartesian null-scale limitation', () => {
  it.each(['x', 'y'])('%s rejects an explicit null scale despite its wire admission', async axis => {
    const plot = new Plot();
    plot.setAttribute(`${axis}Domain`, [0, 1]);
    plot.setAttribute(`${axis}Scale`, null);
    await expect(plotRenderer(plot)).rejects.toThrow('unknown scale type: null');
  });
});


it('keeps all seventy Cartesian routes in their original global positions and paired domains outside the map', () => {
  const suffixes = ['Scale', 'Domain', 'Range', 'Nice', 'Inset', 'Clamp', 'Round', 'Align', 'Padding', 'PaddingInner', 'PaddingOuter', 'Axis', 'Ticks', 'TickSize', 'TickSpacing', 'TickPadding', 'TickFormat', 'TickRotate', 'Grid', 'Line', 'Label', 'LabelAnchor', 'LabelArrow', 'LabelOffset', 'FontVariant', 'AriaLabel', 'AriaDescription', 'Percent', 'Reverse', 'Zero', 'Base', 'Exponent', 'Constant'];
  const expected = [];
  for (const axis of ['x', 'y']) {
    const ordered = [...suffixes];
    ordered.splice(5, 0, ...(axis === 'x' ? ['InsetLeft', 'InsetRight'] : ['InsetTop', 'InsetBottom']));
    for (const suffix of ordered) expected.push([axis + suffix, axis + '.' + (suffix === 'Scale' ? 'type' : suffix[0].toLowerCase() + suffix.slice(1))]);
  }
  expect([...attributeMap].slice(15, 85)).toEqual(expected);
  expect(attributeMap.has('xyDomain')).toBe(false);
});
