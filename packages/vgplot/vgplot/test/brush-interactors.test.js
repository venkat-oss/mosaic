import assert from 'node:assert/strict';
import { it as test, afterAll } from 'vitest';
import { JSDOM } from 'jsdom';
import { Plot } from '@uwdata/mosaic-plot';
import * as vg from '../src/api.js';

const dom = new JSDOM('<!DOCTYPE html>', { pretendToBeVisual: true });
for (const key of ['window', 'document', 'Node', 'Element', 'HTMLElement', 'SVGElement'])
  globalThis[key] = dom.window[key];
globalThis.requestAnimationFrame = dom.window.requestAnimationFrame.bind(dom.window);
globalThis.cancelAnimationFrame = dom.window.cancelAnimationFrame.bind(dom.window);
const rows = [{ a: 1, b: 2, group: 'A', bucket: 'U' }, { a: 3, b: 4, group: 'B', bucket: 'V' }, { a: 5, b: 6, group: 'A', bucket: 'U' }];
function chart(options = {}) {
  const plot = new Plot();
  for (let i = 0; i < 2; i++)
    vg.dot(rows, { x: 'a', y: 'b', z: 'group', ...options })(plot);
  return plot;
}
for (const [name, type, channel] of [['intervalX', 'Interval1D', 'x'], ['intervalY', 'Interval1D', 'y'], ['intervalXY', 'Interval2D'], ['region', 'Region']]) {
  test(name + ' attaches to the prior mark and preserves options, fields and peer policy', () => {
    const plot = chart(), selection = vg.Selection.intersect();
    vg[name].call({ unrelated: true }, { as: selection, channel: 'bad', channels: ['x', 'z'], pixelSize: 0, peers: false })(plot);
    const i = plot.interactors[0];
    assert.equal(i.constructor.name, type);
    assert.equal(i.mark, plot.marks[1]);
    assert.equal(i.selection, selection);
    if (channel) {
      assert.equal(i.channel, channel);
      assert.equal(i.field, channel === 'x' ? 'a' : 'b');
    }
    if (type === 'Interval2D') {
      assert.equal(i.xfield, 'a');
      assert.equal(i.yfield, 'b');
    }
    if (type === 'Region') {
      assert.deepEqual(i.fields, ['a', 'group']);
      assert.deepEqual(i.as, ['a', 'group']);
    }
    else
      assert.equal(i.pixelSize, 1);
    const c = i.clause(type === 'Region' ? [[1, 'A']] : type === 'Interval2D' ? [[1, 3], [2, 4]] : [1, 3]);
    assert.deepEqual([...c.clients], [plot.marks[1]]);
    assert.equal(c.source, i);
    assert.equal(i.clause(undefined).predicate, null);
  });
}
for (const name of ['intervalX', 'intervalY'])
  test(name + ' publishes snapped and ordered domain intervals from rendered D3 brushes', async () => {
    const plot = chart(), selection = vg.Selection.intersect();
    vg[name]({ as: selection, pixelSize: 8, brush: { fillOpacity: 0.4, strokeDasharray: '2,3', unknownStyle: 'yes' } })(plot);
    await plot.render();
    const i = plot.interactors[0], svg = plot.element.querySelector('svg');
    assert.ok(i.g.node());
    let activated;
    selection.addEventListener('activate', c => { activated = c; });
    svg.dispatchEvent(new dom.window.MouseEvent('pointerenter', { buttons: 0 }));
    assert.equal(activated.source, i);
    const extent = [i.scale.apply(2) + 3, i.scale.apply(4) + 1];
    i.g.call(i.brush.move, extent);
    const expected = extent.map(x => i.scale.invert(8 * Math.floor(x / 8))).sort((a, b) => a - b);
    assert.deepEqual(selection.value, expected);
    assert.equal(selection.active.clients, plot.markSet);
    assert.equal(selection.active.meta['pixelSize'], 8);
    assert.match(String(selection.active.predicate), /BETWEEN/);
    const rect = i.g.select('rect.selection');
    assert.equal(rect.attr('fill-opacity'), '0.4');
    assert.equal(rect.attr('stroke-dasharray'), '2,3');
    assert.equal(rect.attr('unknown-style'), 'yes');
    i.g.call(i.brush.move, null);
    assert.equal(selection.value, undefined);
    assert.equal(selection.active.predicate, null);
    i.reset();
    assert.equal(i.value, undefined);
  });
test('intervalXY preserves reversed y domains, 2D SQL clauses and silent reset', async () => {
  const plot = chart(), selection = vg.Selection.intersect();
  vg.intervalXY({ as: selection, xfield: 'explicit_x', yfield: 'explicit_y', pixelSize: 4 })(plot);
  await plot.render();
  const i = plot.interactors[0];
  const extent = [[i.xscale.apply(1.5), i.yscale.apply(5)], [i.xscale.apply(4), i.yscale.apply(2.5)]];
  i.g.call(i.brush.move, extent);
  const snap = (v, s) => s.invert(4 * Math.floor(v / 4));
  const expected = [[extent[0][0], extent[1][0]].map(v => snap(v, i.xscale)).sort((a, b) => a - b), [extent[0][1], extent[1][1]].map(v => snap(v, i.yscale)).sort((a, b) => a - b)];
  assert.deepEqual(selection.value, expected);
  assert.match(String(selection.active.predicate), /explicit_x.*BETWEEN.*AND.*explicit_y.*BETWEEN/);
  assert.equal(selection.active.meta.type, 'interval');
  const previous = selection.value;
  i.reset();
  assert.equal(i.value, undefined);
  assert.deepEqual(selection.value, previous);
  selection.reset();
  assert.equal(selection.value, undefined);
});
test('crossed facets create a brush per panel and share the domain selection', async () => {
  const plot = chart({ fx: 'group', fy: 'bucket' }), selection = vg.Selection.intersect();
  vg.intervalX({ as: selection })(plot);
  await plot.render();
  const i = plot.interactors[0];
  assert.equal(i.g.size(), 4);
  assert.ok(i.g.nodes().every(n => /^translate\(/.test(n.getAttribute('transform'))));
  const extent = [i.scale.apply(1), i.scale.apply(3)];
  i.g.call(i.brush.move, extent);
  assert.deepEqual(selection.value, extent.map(v => i.scale.invert(Math.floor(v))).sort((a, b) => a - b));
});
test('one horizontal facet retains the existing malformed transform suffix', async () => {
  const plot = chart({ fx: 'group' });
  vg.intervalX({ as: vg.Selection.intersect() })(plot);
  await plot.render();
  assert.ok(plot.interactors[0].g.nodes().every(n => /0\}\)$/.test(n.getAttribute('transform'))));
});
test('region requires actual channels and preserves default brush styles', () => {
  const plot = chart();
  assert.throws(() => vg.region({ as: vg.Selection.intersect() })(plot), TypeError);
  assert.throws(() => vg.region({ as: vg.Selection.intersect(), channels: ['missing'] })(plot), /^Error: Missing channel: missing$/);
  vg.region({ as: vg.Selection.intersect(), channels: ['x'] })(plot);
  assert.deepEqual(plot.interactors[0].style, { 'fill': 'none', 'stroke': 'currentColor', 'stroke-dasharray': '1,1' });
  const c = plot.interactors[0].clause([[1], [3]]);
  assert.match(String(c.predicate), /a.*IN/);
  assert.deepEqual(c.value, [[1], [3]]);
});
afterAll(() => dom.window.close());
