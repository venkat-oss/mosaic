import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';
import { runInNewContext } from 'node:vm';

const cue = process.env.CUE_BIN;

function project(input) {
  const directory = mkdtempSync(join(tmpdir(), 'mosaic-transform-registry-'));
  try {
    const path = join(directory, 'input.json');
    writeFileSync(path, JSON.stringify(input));
    execFileSync(cue, ['vet', '-c', './api/compose', path, '-d', '#TransformRegistry'], { stdio: 'pipe' });
    return JSON.parse(execFileSync(cue, ['export', './api/compose', path, '-d', '#TransformRegistry', '-e', 'files'], { encoding: 'utf8', stdio: 'pipe' }));
  } finally {
    rmSync(directory, { recursive: true, force: true });
  }
}

test('transform registry preserves declared order and caller extension semantics', () => {
  const files = project({ owned: [{ key: 'avg', order: 1 }, { key: 'years', order: 3 }, { key: 'bin', order: 2 }, { key: 'column', order: 0 }] });
  const source = files['packages/vgplot/spec/src/config/transforms.js'];
  const transformNames = runInNewContext(source.replace('export function', 'function') + '\ntransformNames');
  assert.deepEqual([...transformNames()], ['column', 'avg', 'bin', 'years']);
  assert.deepEqual([...transformNames(['bin', 'custom'])], ['column', 'avg', 'bin', 'years', 'custom']);
  const first = transformNames();
  first.add('onlyFirst');
  assert.equal(transformNames().has('onlyFirst'), false);
});

for (const [name, input] of [
  ['duplicate keys', { owned: [{ key: 'bin', order: 0 }, { key: 'bin', order: 1 }] }],
  ['duplicate positions', { owned: [{ key: 'avg', order: 0 }, { key: 'bin', order: 0 }] }],
  ['missing order', { owned: [{ key: 'bin' }] }],
  ['source injection', { owned: [{ key: 'bin();', order: 0 }] }]
]) {
  test(`transform registry rejects ${name} at complete admission`, () => {
    assert.throws(() => project(input));
  });
}
