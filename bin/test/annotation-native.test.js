import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import test from 'node:test';

test('annotation native vector aliases enforce the declared finite vocabulary', () => {
  const directory = mkdtempSync(join(tmpdir(), 'mosaic-annotation-native-'));
  try {
    const input = join(directory, 'input.json');
    for (const name of ['VectorShapeName', 'VectorShape']) {
      for (const value of ['arrow', 'spike', 'triangle', '$shape', false, {}]) {
        writeFileSync(input, JSON.stringify(value));
        const result = spawnSync(process.env.CUE_BIN, ['vet', '-c', resolve('packages/vgplot/spec/src/generated/annotation-values.cue'), input, '-d', '#' + name], {encoding: 'utf8'});
        assert.equal(result.status === 0, value === 'arrow' || value === 'spike', name + ': ' + JSON.stringify(value) + ': ' + result.stderr);
      }
    }
  } finally {
    rmSync(directory, {recursive: true, force: true});
  }
});
