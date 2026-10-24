import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { resolve } from 'node:path';
import test from 'node:test';

const root = resolve(import.meta.dirname, '../..');

test('connected mark contracts preserve strict public TypeScript consumers', () => {
  const directory = mkdtempSync(resolve(tmpdir(), 'mosaic-connected-types-'));
  try {
    const config = resolve(directory, 'tsconfig.json');
    writeFileSync(config, JSON.stringify({
      extends: resolve(root, 'tsconfig.base.json'),
      include: [resolve(root, 'packages/vgplot/spec/test/connected-marks.types.ts')],
      compilerOptions: { strict: true, composite: false, incremental: false, noEmit: true }
    }));
    const result = spawnSync(process.env.TSC_BIN, ['-p', config], { encoding: 'utf8' });
    assert.equal(result.status, 0, result.stdout + result.stderr);
  } finally { rmSync(directory, { recursive: true, force: true }); }
});
