import { spawnSync } from 'node:child_process';
import { mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = fileURLToPath(new URL('../../..', import.meta.url));

export function validateSpec(values, { root = ROOT, cue = process.env.CUE_BIN } = {}) {
  const directory = mkdtempSync(join(tmpdir(), 'mosaic-spec-admission-'));
  try {
    return values.map((value, index) => {
      const candidate = join(directory, `candidate-${index}.json`);
      writeFileSync(candidate, JSON.stringify(value));
      const result = spawnSync(cue, ['vet', '-c', resolve(root, 'packages/vgplot/spec/src/generated/spec.cue'), candidate, '-d', '#Spec'], {
        cwd: root, encoding: 'utf8', maxBuffer: 128 * 1024 * 1024
      });
      if (result.error) throw result.error;
      if (result.signal || (result.status !== 0 && result.status !== 1)) {
        throw new Error(`Native admission process failed: ${result.stderr || result.signal}`);
      }
      return { accepted: result.status === 0, diagnostics: result.stderr.trim() };
    });
  } finally {
    rmSync(directory, { recursive: true, force: true });
  }
}
