import { chmodSync, cpSync, mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { resolve } from 'node:path';
import { spawnSync } from 'node:child_process';

const [pnpmRunfile, source, output, packagePath] = process.argv.slice(2);
const pnpm = resolve(process.env.RUNFILES_DIR || process.env.JS_BINARY__RUNFILES, pnpmRunfile);
const workspace = mkdtempSync(resolve(tmpdir(), 'mosaic-pack-'));
try {
  // Node's cp fast path ignores nested dereference; pnpm excludes those sandbox links.
  cpSync(resolve(source), workspace, { recursive: true, dereference: true, filter: () => true });
  chmodSync(workspace, 0o755);
  const result = spawnSync(pnpm, ['--dir', resolve(workspace, packagePath), 'pack', '--out', resolve(output)], {
    env: { ...process.env, BAZEL_BINDIR: '.' },
    stdio: 'inherit'
  });
  if (result.error) throw result.error;
  if (result.status !== 0) throw new Error(`pnpm pack exited ${result.status}`);
} finally {
  rmSync(workspace, { recursive: true, force: true });
}
