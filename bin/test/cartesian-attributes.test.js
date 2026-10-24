import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { resolve } from 'node:path';
import { after, test } from 'node:test';
import { fileURLToPath } from 'node:url';

const ROOT = fileURLToPath(new URL('../..', import.meta.url));
const cue = process.env.CUE_BIN;
const roots = [];

function workspace() {
  const root = mkdtempSync(resolve(tmpdir(), 'mosaic-cartesian-attributes-'));
  roots.push(root);
  return root;
}

after(() => roots.forEach(root => rmSync(root, { recursive: true, force: true })));

test('native Cartesian helpers retain all mixed LabelArrow literals and its bounded enum', () => {
  const root = workspace();
  const file = resolve(root, 'payload.json');
  for (const [values, expected] of [
    [['auto', 'up', 'right', 'down', 'left', 'none', true, false, null], 0],
    [['wire-only', 1, [], {}], 1]
  ]) for (const value of values) {
    writeFileSync(file, JSON.stringify(value));
    const result = spawnSync(cue, ['vet', '-c', resolve(ROOT, 'packages/vgplot/spec/src/generated/cartesian-attributes.cue'), file, '-d', '#LabelArrow'], { cwd: ROOT, encoding: 'utf8' });
    assert.equal(result.error, undefined);
    assert.equal(result.status, expected, `${JSON.stringify(value)}\n${result.stderr}`);
  }
});

for (const [name, accepted, rejected] of [
  ['xScale', ['linear', null, 'wire-only'], [false, 1]],
  ['yDomain', [[0, 4], 'Fixed', '$domain'], [null, false]],
  ['xRange', [[20, 180], 'Fixed'], [true, {}]],
  ['yNice', [true, 4, '2 weeks'], [null, { days: 1 }]],
  ['xTicks', [4, 'day', ['$tick', 2]], [false, { days: 1 }]],
  ['yGrid', [true, 'day', [1, 2]], [null, 4]],
  ['xTickFormat', ['.1f', null], [true, {}]],
  ['yLabelArrow', [false, null, 'wire-only'], [1, []]],
  ['xyDomain', [[0, 4], 'Fixed', '$domain'], [null, false, 1]]
]) {
  test(`native Cartesian ${name} independently preserves its wire boundary`, () => {
    const root = workspace();
    const file = resolve(root, 'payload.json');
    for (const [values, expected] of [[accepted, 0], [rejected, 1]]) for (const value of values) {
      writeFileSync(file, JSON.stringify({ [name]: value }));
      const result = spawnSync(cue, ['vet', '-c', resolve(ROOT, 'packages/vgplot/spec/src/generated/cartesian-attributes.cue'), file, '-d', '#CartesianAttributes'], { cwd: ROOT, encoding: 'utf8' });
      assert.equal(result.error, undefined);
      assert.equal(result.status, expected, `${name}: ${JSON.stringify(value)}\n${result.stderr}`);
    }
  });
}
