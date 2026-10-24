// @vitest-environment jsdom
import { expect, it } from 'vitest';
import { Fixed, Mark, Plot } from '../src/index.js';
import { attributeMap, setAttributes } from '../src/plot-attributes.js';
import { plotRenderer } from '../src/plot-renderer.js';

const rows = [
  { x: 1, y: 1, column: 'A', row: 'Upper' },
  { x: 2, y: 3, column: 'B', row: 'Upper' },
  { x: 3, y: 2, column: 'A', row: 'Lower' },
  { x: 4, y: 4, column: 'B', row: 'Lower' }
];

function faceted(attributes = {}, data = rows) {
  const plot = new Plot();
  for (const [name, value] of Object.entries({ width: 480, height: 360, ...attributes })) {
    plot.setAttribute(name, value);
  }
  plot.addMark(new Mark('dot', data, { x: 'x', y: 'y', fx: 'column', fy: 'row' }));
  return plot;
}

it('renders crossed facets and retains explicitly requested empty panels', async () => {
  const svg = await plotRenderer(faceted({ fxDomain: ['B', 'A', 'Empty'], fyDomain: ['Upper', 'Lower'] }));
  expect(svg.scale('fx').domain).toEqual(['B', 'A', 'Empty']);
  expect(svg.scale('fy').domain).toEqual(['Upper', 'Lower']);
  expect(svg.querySelectorAll('circle')).toHaveLength(4);
});

it('admits empty faceted data with explicit scale domains', async () => {
  const svg = await plotRenderer(faceted({ fxDomain: ['A', 'B'], fyDomain: ['Upper', 'Lower'] }, []));
  expect(svg.scale('fx').domain).toEqual(['A', 'B']);
  expect(svg.scale('fy').domain).toEqual(['Upper', 'Lower']);
  expect(svg.querySelectorAll('circle')).toHaveLength(0);
});

it('suppresses both facet axes with null while preserving the facet scales', async () => {
  const svg = await plotRenderer(faceted({ fxAxis: null, fyAxis: null }));
  expect(svg.scale('fx').domain).toEqual(['A', 'B']);
  expect(svg.scale('fy').domain).toEqual(['Lower', 'Upper']);
  expect(svg.querySelector('[aria-label^="fx-axis"]')).toBeNull();
  expect(svg.querySelector('[aria-label^="fy-axis"]')).toBeNull();
});

it('executes JavaScript-only facet tick formatters on their respective domains', async () => {
  const xSeen = [];
  const ySeen = [];
  const svg = await plotRenderer(faceted({
    fxTickFormat: value => { xSeen.push(value); return value.toLowerCase(); },
    fyTickFormat: value => { ySeen.push(value); return value.toUpperCase(); }
  }));
  expect(new Set(xSeen)).toEqual(new Set(['A', 'B']));
  expect(new Set(ySeen)).toEqual(new Set(['Upper', 'Lower']));
  expect([...svg.querySelectorAll('text')].map(text => text.textContent)).toEqual(expect.arrayContaining(['a', 'b', 'UPPER', 'LOWER']));
});

it.each(['fxRange', 'fyRange'])('%s preserves the admitted Fixed-range rejection', async name => {
  await expect(plotRenderer(faceted({ [name]: Fixed }))).rejects.toThrow(`Unsupported fixed attribute: ${name}`);
});

it('resolves Fixed facet domains and retains their requested reverse ordering', async () => {
  const plot = faceted({ fxDomain: Fixed, fyDomain: Fixed, fxReverse: true });
  await plotRenderer(plot);
  expect(plot.getAttribute('fxDomain')).toEqual(['A', 'B']);
  expect(plot.getAttribute('fyDomain')).toEqual(['Lower', 'Upper']);
});

it('retains the comma in the fyInset route and its ineffective scale placement', async () => {
  const spec = {};
  setAttributes({ fyInset: 60, fyInsetTop: 4 }, spec, []);
  expect(spec).toEqual({ 'fy,inset': 60, fy: { insetTop: 4 } });
  const normal = await plotRenderer(faceted());
  const inset = await plotRenderer(faceted({ fyInset: 60 }));
  expect(inset.scale('fy').range).toEqual(normal.scale('fy').range);
});



it.each([['fxLabelAnchor', 'top'], ['fxLabelAnchor', 'bottom'], ['fyLabelAnchor', 'left'], ['fyLabelAnchor', 'right']])('%s preserves its admitted invalid %s anchor', async (name, value) => {
  await expect(plotRenderer(faceted({ [name]: value }))).rejects.toThrow(`invalid labelAnchor: ${value}`);
});

it('preserves all fifty-nine original facet routes and their ordering, including the comma destination', () => {
  const expected = [
    ['facetMargin', 'facet.margin'], ['facetMarginTop', 'facet.marginTop'], ['facetMarginBottom', 'facet.marginBottom'],
    ['facetMarginLeft', 'facet.marginLeft'], ['facetMarginRight', 'facet.marginRight'], ['facetGrid', 'facet.grid'], ['facetLabel', 'facet.label']
  ];
  const suffixes = ['Domain', 'Range', 'Inset', 'Round', 'Align', 'Padding', 'PaddingInner', 'PaddingOuter', 'Axis', 'Ticks', 'TickSize', 'TickSpacing', 'TickPadding', 'TickFormat', 'TickRotate', 'Grid', 'Line', 'Label', 'LabelAnchor', 'LabelOffset', 'FontVariant', 'AriaLabel', 'AriaDescription', 'Reverse'];
  for (const axis of ['fx', 'fy']) {
    const ordered = [...suffixes];
    ordered.splice(3, 0, ...(axis === 'fx' ? ['InsetLeft', 'InsetRight'] : ['InsetTop', 'InsetBottom']));
    for (const suffix of ordered) expected.push([axis + suffix, axis === 'fy' && suffix === 'Inset' ? 'fy,inset' : axis + '.' + suffix[0].toLowerCase() + suffix.slice(1)]);
  }
  expect([...attributeMap].slice(85, 144)).toEqual(expected);
  expect(attributeMap.has('fxScale')).toBe(false);
  expect(attributeMap.has('fyScale')).toBe(false);
});
