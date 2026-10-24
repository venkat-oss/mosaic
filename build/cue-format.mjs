import { spawnSync } from 'node:child_process';
import { resolve } from 'node:path';

const cue = resolve(process.env.RUNFILES_DIR || process.env.JS_BINARY__RUNFILES, process.argv[2]);
const result = spawnSync(cue, ['fmt', '--check', './api/...', 'cue.mod/module.cue'], {
  stdio: 'inherit',
  env: { ...process.env, CUE_CACHE_DIR: process.env.TEST_TMPDIR, CUE_REGISTRY: 'none' },
});
if (result.error) throw result.error;
process.exit(result.status ?? 1);
