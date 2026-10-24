import assert from 'node:assert/strict';
import test from 'node:test';
import { JSDOM } from 'jsdom';
import { curveBasis } from 'd3';
import { Plot } from '@uwdata/mosaic-plot';
import { ConnectedMark } from '@uwdata/mosaic-plot';
import * as vg from '../../packages/vgplot/vgplot/src/api.js';

const dom = new JSDOM('<!DOCTYPE html>');
for (const name of ['window', 'document', 'Node', 'Element', 'HTMLElement', 'SVGElement']) globalThis[name] = dom.window[name];
const data = [
  { t: 0, v: 2, u: 1, w: 3, series: 'a' },
  { t: 1, v: 4, u: 2, w: 1, series: 'a' },
  { t: 2, v: 1, u: 3, w: 4, series: 'a' },
  { t: 0, v: 3, u: 1, w: 2, series: 'b' },
  { t: 1, v: 1, u: 2, w: 4, series: 'b' },
  { t: 2, v: 4, u: 3, w: 1, series: 'b' }
];
const cases = [
  ['line', { x: 't', y: 'v' }], ['lineX', { x: 't', y: 'v' }], ['lineY', { x: 't', y: 'v' }],
  ['area', { x1: 't', x2: 't', y1: 0, y2: 'v' }],
  ['areaX', { x1: 0, x2: 'v', y: 't' }], ['areaY', { x: 't', y1: 0, y2: 'v' }],
  ['arrow', { x1: 't', x2: 'u', y1: 'v', y2: 'w' }],
  ['link', { x1: 't', x2: 'u', y1: 'v', y2: 'w' }]
];
for (const [name, channels] of cases) test(`${name} renders actual grouped paths with its retained class`, async () => {
  const plot = new Plot();
  vg[name](data, { ...channels, z: 'series', stroke: 'series', curve: 'linear' })(plot);
  await plot.render();
  const mark = plot.marks[0];
  assert.equal(mark instanceof ConnectedMark, name.startsWith('area') || name.startsWith('line'));
  const paths = [...plot.element.querySelectorAll(`g[aria-label="${name.startsWith('line') ? 'line' : name.startsWith('area') ? 'area' : name}"] path`)];
  assert.equal(paths.length, name === 'arrow' || name === 'link' ? 6 : 2);
  for (const path of paths) {
    const geometry = path.getAttribute('d');
    assert.ok(geometry?.startsWith('M'));
    assert.doesNotMatch(geometry, /NaN|Infinity/);
    if (name.startsWith('area')) assert.match(geometry, /Z$/);
  }
});

test('nullable line coordinates break actual paths without joining across the gap', async () => {
  const plot = new Plot();
  vg.line([{ x: 0, y: 0 }, { x: 1, y: 1 }, { x: 2, y: null }, { x: 3, y: 3 }, { x: 4, y: 4 }], { x: 'x', y: 'y' })(plot);
  await plot.render();
  const path = plot.element.querySelector('g[aria-label="line"] path').getAttribute('d');
  assert.equal((path.match(/M/g) || []).length, 2);
  assert.doesNotMatch(path, /NaN|Infinity/);
});

test('native curve functions retain their actual D3 object identity beyond wire values', async () => {
  const plot = new Plot();
  vg.line(data, { x: 't', y: 'v', z: 'series', curve: curveBasis })(plot);
  assert.equal(plot.marks[0].channel('curve').value, curveBasis);
  await plot.render();
  const paths = [...plot.element.querySelectorAll('g[aria-label="line"] path')];
  assert.equal(paths.length, 2);
  for (const path of paths) assert.match(path.getAttribute('d'), /C/);
});

test.after(() => dom.window.close());
