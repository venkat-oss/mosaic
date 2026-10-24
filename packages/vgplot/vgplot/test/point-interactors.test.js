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
const rows = [{ a: 1, b: 2, group: 'A', color: 'red' }, { a: 3, b: 4, group: 'B', color: 'blue' }];
function chart() {
  const plot = new Plot();
  for (let i = 0; i < 2; i++)
    vg.dot(rows, { x: 'a', y: 'b', z: 'group', fill: 'color' })(plot);
  return plot;
}
const variants = [
  ['highlight', 'Highlight'], ['nearest', 'Nearest'], ['nearestX', 'Nearest'], ['nearestY', 'Nearest'],
  ['toggle', 'Toggle'], ['toggleX', 'Toggle'], ['toggleY', 'Toggle'], ['toggleZ', 'Toggle'], ['toggleColor', 'Toggle']
];
for (const [name, type] of variants)
  test(name + ' attaches its retained runtime to the last preceding mark', () => {
    const plot = chart();
    const selection = vg.Selection.intersect();
    const options = { as: selection, by: selection, channels: ['x'], peers: false };
    const directive = vg[name].call({ unrelated: true }, options);
    assert.equal(typeof directive, 'function');
    assert.equal(directive(plot), undefined);
    const interactor = plot.interactors[0];
    assert.equal(interactor.constructor.name, type);
    assert.equal(interactor.mark, plot.marks[1]);
    assert.equal(interactor.selection, selection);
  });
for (const {name,pointer,channels} of [{name:'nearest',pointer:'xy',channels:['x','y']},{name:'nearestX',pointer:'x',channels:['x']},{name:'nearestY',pointer:'y',channels:['y']}])
  test(name + ' retains pointer policy, field inference and single-point clauses', () => {
    const plot = chart();
    vg[name]({ as: vg.Selection.intersect(), pointer: 'overridden', maxRadius: 12 })(plot);
    const interactor = plot.interactors[0];
    assert.equal(interactor.pointer, pointer);
    assert.deepEqual(interactor.channels, channels);
    assert.deepEqual(interactor.fields, channels.map(c => c === 'x' ? 'a' : 'b'));
    assert.equal(interactor.maxRadius, 12);
    const clause = interactor.clause(channels.map((_, i) => i + 2));
    assert.equal(clause.meta.type, 'point');
    assert.equal(clause.clients.size, 1);
    assert.equal(clause.source, interactor);
    assert.deepEqual(clause.value, channels.length === 1 ? 2 : [[2, 3]]);
    assert.equal(interactor.clause(undefined).predicate, null);
  });
for (const [name, field] of [['toggleX', 'a'], ['toggleY', 'b'], ['toggleZ', 'group'], ['toggleColor', 'color']])
  test(name + ' retains forced channels, backing fields and peer exclusion', () => {
    const plot = chart();
    vg[name]({ as: vg.Selection.intersect(), channels: ['missing'] })(plot);
    const interactor = plot.interactors[0];
    assert.deepEqual(interactor.as, [field]);
    const clause = interactor.clause([[2], [3]]);
    assert.equal(clause.clients, plot.markSet);
    assert.equal(clause.clients.size, 2);
    assert.equal(clause.source, interactor);
    assert.deepEqual(clause.value, [[2], [3]]);
    assert.equal(interactor.clause(null).predicate, null);
    vg[name]({ as: vg.Selection.intersect(), peers: false })(plot);
    assert.deepEqual([...plot.interactors[1].clause([[2]]).clients], [plot.marks[1]]);
  });
test('nearest explicit fields override inference while legacy singular field is ignored', () => {
  const plot = chart();
  vg.nearestX({ as: vg.Selection.intersect(), field: 'singular', fields: ['explicit'] })(plot);
  assert.deepEqual(plot.interactors[0].fields, ['explicit']);
  vg.nearestX({ as: vg.Selection.intersect(), field: 'singular' })(plot);
  assert.deepEqual(plot.interactors[1].fields, ['a']);
});
test('toggle preserves an exact missing-channel error', () => {
  assert.throws(() => vg.toggle({ as: vg.Selection.intersect(), channels: ['missing'] })(chart()), /^Error: Missing channel: missing$/);
});
test('highlight retains default styles, camelized names and native extra styles', () => {
  const plot = chart();
  vg.highlight({ by: vg.Selection.intersect() })(plot);
  assert.deepEqual(plot.interactors[0].channels, [['opacity', 0.2]]);
  vg.highlight({ by: vg.Selection.intersect(), fillOpacity: 0.4, arbitrary: 8 })(plot);
  assert.deepEqual(plot.interactors[1].channels, [['fill-opacity', 0.4], ['arbitrary', 8]]);
});
for (const { name, expected } of [{ name: 'nearest', expected: [[1, 2]] }, { name: 'nearestX', expected: 1 }, { name: 'nearestY', expected: 2 }])
  test(name + ' updates and clears actual pointer selection against rendered SVG', async () => {
    const plot = chart();
    const selection = vg.Selection.intersect();
    vg[name]({ as: selection })(plot);
    await plot.render();
    const svg = plot.element.querySelector('svg');
    const clientX = svg['scale']('x').apply(1);
    const clientY = svg['scale']('y').apply(2);
    svg.dispatchEvent(new dom.window.MouseEvent('pointermove', { clientX, clientY }));
    assert.deepEqual(selection.value, expected);
    assert.equal(selection.active.source, plot.interactors[0]);
    svg.dispatchEvent(new dom.window.MouseEvent('pointermove', { clientX: 100000, clientY: 100000 }));
    assert.equal(selection.value, undefined);
  });
for (const [name, expected] of [['toggleX', 1], ['toggleY', 2], ['toggleZ', 'A'], ['toggleColor', 'red']])
  test(name + ' toggles actual SVG elements and clears on the second click', async () => {
    const plot = chart();
    const selection = vg.Selection.intersect();
    vg[name]({ as: selection })(plot);
    await plot.render();
    const node = plot.element.querySelector('[data-index="1"] circle');
    assert.ok(node);
    node.dispatchEvent(new dom.window.MouseEvent('pointerdown', { bubbles: true }));
    assert.deepEqual(selection.value, [[expected]]);
    assert.equal(selection.active.source, plot.interactors[0]);
    node.dispatchEvent(new dom.window.MouseEvent('pointerdown', { bubbles: true }));
    assert.equal(selection.value, null);
  });
afterAll(() => dom.window.close());
