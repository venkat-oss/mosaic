// @vitest-environment jsdom
import assert from 'node:assert/strict';
import { test } from 'vitest';
import { Plot } from '@uwdata/mosaic-plot';
import * as vg from '../src/index.js';

const data = [{ x: 1, y: 2, label: 'First', value: 3, angle: 90, src: 'https://example.com/image.png' }, { x: 2, y: 3, label: 'Second', value: 5, angle: 180, src: 'https://example.com/other.png' }];
const cases = [
  { name: 'text', options: { x: 'x', y: 'y', text: 'label', fontSize: 14, textAnchor: 'start', lineAnchor: 'top' }, label: 'text', tag: 'text', count: 2 },
  { name: 'textX', options: { x: 'x', y: 'y', text: 'label', interval: 1 }, label: 'text', tag: 'text', count: 2 },
  { name: 'textY', options: { x: 'x', y: 'y', text: 'label', interval: 1 }, label: 'text', tag: 'text', count: 2 },
  { name: 'image', options: { x: 'x', y: 'y', src: 'src', width: 20, height: 10, preserveAspectRatio: 'xMidYMid slice' }, label: 'image', tag: 'image', count: 2 },
  { name: 'vector', options: { x: 'x', y: 'y', length: 'value', rotate: 'angle', anchor: 'start' }, label: 'vector', tag: 'path', count: 2 },
  { name: 'vectorY', options: { x: 'x', y: 'y', length: 'value', rotate: 'angle' }, label: 'vector', tag: 'path', count: 2 },
  { name: 'spike', options: { x: 'x', y: 'y', length: 'value', rotate: 'angle' }, label: 'vector', tag: 'path', count: 2 },
  { name: 'waffleX', options: { x: 'value', y: 'label', unit: 1, multiple: 4, gap: 1, round: true }, label: 'waffle', tag: 'path', count: 2 },
  { name: 'waffleY', options: { x: 'label', y: 'value', unit: 1, multiple: 4, gap: 1, round: true }, label: 'waffle', tag: 'path', count: 2 }
];
for (const { name, options, label, tag, count } of cases) test(`${name} renders retained annotation primitives`, async () => {
  const plot = new Plot();
  vg[name](data, options)(plot);
  assert.equal(plot.marks[0].type, name);
  await plot.render();
  const elements = [...plot.element.querySelectorAll(`g[aria-label="${label}"] ${tag}`)];
  assert.equal(elements.length, count);
  for (const element of elements) assert.doesNotMatch(element.outerHTML, /NaN|Infinity/);
  if (name === 'text') {
    assert.deepEqual(elements.map(element => element.textContent), ['First', 'Second']);
    assert.equal(elements[0].getAttribute('text-anchor') || elements[0].parentElement.getAttribute('text-anchor'), 'start');
  }
  if (name === 'image') {
    assert.equal(elements[0].getAttribute('href'), 'https://example.com/image.png');
    assert.equal(elements[0].getAttribute('width'), '20');
    assert.equal(elements[0].getAttribute('height'), '10');
  }
});

test('vectorX retains the recorded vectoX dispatch and actual TypeError expected failure', async () => {
  const plot = new Plot();
  vg.vectorX(data, { x: 'x', y: 'y', length: 'value' })(plot);
  assert.equal(plot.marks[0].type, 'vectoX');
  const [spec] = plot.marks[0].plotSpecs();
  assert.ok('type' in spec);
  assert.equal(spec.type, 'vectoX');
  await assert.rejects(plot.render(), { name: 'TypeError', message: /is not a function/ });
});

test('annotation wrappers preserve open native options and explicit channel values', () => {
  const plot = new Plot();
  vg.text(data, { x: 'x', text: 'label', futureStyle: 7, fill: null, dx: 0 })(plot);
  assert.equal(plot.marks[0].channel('futureStyle').value, 7);
  assert.equal(plot.marks[0].channel('fill').value, null);
  assert.equal(plot.marks[0].channel('dx').value, 0);
});
