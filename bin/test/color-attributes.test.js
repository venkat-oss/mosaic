import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { resolve } from 'node:path';
import { after, test } from 'node:test';
import { fileURLToPath } from 'node:url';

const ROOT = fileURLToPath(new URL('../..', import.meta.url));
const cue = process.env.CUE_BIN;
const workspaces = [];
function workspace() {
  const root = mkdtempSync(resolve(tmpdir(), 'mosaic-color-attributes-'));
  workspaces.push(root);
  return root;
}
after(() => workspaces.forEach(root => rmSync(root, { recursive: true, force: true })));

test('standalone native color attributes retain schema breadth and reject wrong typed values', () => {
  const root = workspace();
  const candidate = resolve(root, 'candidate.json');
  const native = resolve(ROOT, 'packages/vgplot/spec/src/generated/color-attributes.cue');
  const accepted = [{ colorScale: null }, { symbolScale: 'other' }, { colorScheme: { custom: 1 } }, { colorPivot: { arbitrary: [1] } }, { colorRange: [{}] }];
  const rejected = [{ colorScale: 3 }, { symbolScale: false }, { colorDomain: {} }, { colorClamp: 0 }, { colorN: false }, { opacityNice: {} }, { colorScheme: null }, { colorInterpolate: [] }, { colorLabel: 3 }, { colorTickFormat: {} }, { symbolDomain: false }, { opacityRange: 3 }, { unknown: 1 }];
  for (const [value, expected] of [...accepted.map(value => [value, 0]), ...rejected.map(value => [value, 1])]) {
    writeFileSync(candidate, JSON.stringify(value));
    const result = spawnSync(cue, ['vet', '-c', native, candidate, '-d', '#ColorAttributes'], { encoding: 'utf8' });
    assert.equal(result.status, expected, result.stderr);
    if (expected === 0) {
      const output = spawnSync(cue, ['export', native, candidate, '-d', '#ColorAttributes', '--out', 'json'], { encoding: 'utf8' });
      assert.equal(output.status, 0, output.stderr);
      assert.deepEqual(JSON.parse(output.stdout), value);
    }
  }
});
