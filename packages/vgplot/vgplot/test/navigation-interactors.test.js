import assert from 'node:assert/strict';
import { afterAll, test } from 'vitest';
import { JSDOM } from 'jsdom';
import { ZoomTransform } from 'd3';
import { Plot } from '@uwdata/mosaic-plot';
import * as vg from '../src/index.js';

const dom = new JSDOM('<!DOCTYPE html>', {pretendToBeVisual: true});
for (const key of ['window', 'document', 'Node', 'Element', 'HTMLElement', 'SVGElement']) globalThis[key] = dom.window[key];
globalThis.requestAnimationFrame = dom.window.requestAnimationFrame.bind(dom.window);
globalThis.cancelAnimationFrame = dom.window.cancelAnimationFrame.bind(dom.window);
const rows = [{a: 1, b: 2}, {a: 5, b: 6}, {a: 9, b: 8}];
function plot() {
  const plot = new Plot();
  vg.dot(rows, {x: 'b', y: 'a'})(plot);
  vg.dot(rows, {x: 'a', y: 'b'})(plot);
  for (const [key, value] of Object.entries({xDomain: [0, 10], yDomain: [0, 10], width: 500, height: 300})) plot.setAttribute(key, value);
  return plot;
}

for (const {name, zoom, panx, pany} of [
  {name: 'pan', zoom: false, panx: true, pany: true},
  {name: 'panX', zoom: false, panx: true, pany: false},
  {name: 'panY', zoom: false, panx: false, pany: true},
  {name: 'panZoom', zoom: true, panx: true, pany: true},
  {name: 'panZoomX', zoom: true, panx: true, pany: false},
  {name: 'panZoomY', zoom: true, panx: false, pany: true},
]) {
  test(name + ' keeps native defaults and selects the last mark', () => {
    const chart = plot();
    vg[name].call({unrelated: true})(chart);
    const interactor = chart.interactors[0];
    assert.equal(interactor.constructor.name, 'PanZoom');
    assert.equal(interactor.mark, chart.marks[1]);
    assert.equal(interactor.xfield, 'a');
    assert.equal(interactor.yfield, 'b');
    assert.deepEqual(interactor.zoom, zoom ? [0, Infinity] : [1, 1]);
    assert.equal(interactor.panx, panx);
    assert.equal(interactor.pany, pany);
    assert.notEqual(interactor.xsel, interactor.ysel);
    const another = plot();
    vg[name]()(another);
    assert.notEqual(interactor.xsel, another.interactors[0].xsel);
  });
}

test('navigation preserves shared selections, explicit fields and forced controls', async () => {
  const chart = plot(), x = vg.Selection.intersect(), y = vg.Selection.intersect();
  vg.panX({x, y, xfield: 'explicit_x', yfield: 'explicit_y', zoom: [1, 20], panx: [-100, 600], pany: true})(chart);
  const i = chart.interactors[0];
  assert.equal(i.xsel, x);
  assert.equal(i.ysel, y);
  assert.equal(i.xfield, 'explicit_x');
  assert.equal(i.yfield, 'explicit_y');
  assert.deepEqual(i.zoom, [1, 1]);
  assert.deepEqual(i.panx, [-100, 600]);
  assert.equal(i.pany, false);
  await chart.render();
  const before = chart.getAttribute('yDomain');
  i.publish(new ZoomTransform(1, 20, 30));
  await x.pending('value');
  assert.deepEqual(chart.getAttribute('xDomain'), x.value);
  assert.deepEqual(chart.getAttribute('yDomain'), before);
  assert.equal(x.active.source, i);
  assert.equal(x.active.clients, chart.markSet);
  assert.match(String(x.active.predicate), /explicit_x.*BETWEEN/);
});

test('selection feedback drives enabled domains while disabled axes stay unchanged', async () => {
  const chart = plot(), x = vg.Selection.intersect(), y = vg.Selection.intersect();
  vg.panZoomX({x, y})(chart);
  await chart.render();
  const i = chart.interactors[0];
  x.update(i.clause([2, 7], 'a', i.xscale));
  y.update(i.clause([3, 8], 'b', i.yscale));
  await x.pending('value');
  await y.pending('value');
  assert.deepEqual(chart.getAttribute('xDomain'), [2, 7]);
  assert.deepEqual(chart.getAttribute('yDomain'), [0, 10]);
});

test('native null and ordinary parameter inputs retain their runtime limitations', async () => {
  assert.throws(() => vg.panZoom({x: null})(plot()), /addEventListener/);
  assert.throws(() => vg.panZoom(null)(plot()), TypeError);
  assert.doesNotThrow(() => vg.pan(null)(plot()));
  assert.doesNotThrow(() => vg.panY({x: null})(plot()));
  const chart = plot();
  vg.panZoom({x: vg.Param.value([0, 10])})(chart);
  await chart.render();
  assert.throws(() => chart.interactors[0].activate(), /activate is not a function/);
});

afterAll(() => dom.window.close());
