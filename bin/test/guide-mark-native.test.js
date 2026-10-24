import assert from 'node:assert/strict';
import test from 'node:test';
import { fileURLToPath } from 'node:url';
import { validateSpec } from './util/spec-admission.js';

const root = fileURLToPath(new URL('../..', import.meta.url));
test('native root preserves independent guide wire admission', () => {
  const cases = [];
  for (const mark of ['frame', 'axisX', 'axisY', 'axisFx', 'axisFy', 'gridX', 'gridY', 'gridFx', 'gridFy', 'hexgrid']) {
    for (const [options, accepted] of [[{}, true], [{ stroke: 'red', opacity: 0 }, true], [{ data: [] }, false], [{ arbitraryGuideOption: true }, false]]) cases.push({ value: { plot: [{ mark, ...options }] }, accepted });
  }
  for (const [entry, accepted] of [
    [{ mark: 'axisX', tickFormat: null, ticks: [0, 5, 10] }, true],
    [{ mark: 'axisX', tickFormat: {} }, false],
    [{ mark: 'gridY', x1: 0, x2: 10 }, true],
    [{ mark: 'gridY', y1: 0 }, false],
    [{ mark: 'hexgrid', fill: 'red' }, true],
    [{ mark: 'notAGuide' }, false],
  ]) cases.push({ value: { plot: [entry] }, accepted });
  const results = validateSpec(cases.map(item => item.value), { root });
  assert.equal(results.length, cases.length);
  for (const [index, result] of results.entries()) assert.equal(result.accepted, cases[index].accepted, JSON.stringify(cases[index].value) + '\n' + result.diagnostics);
});
