import { mkdirSync } from 'node:fs';
import { resolve } from 'node:path';
import { pathToFileURL } from 'node:url';

for (const name of ['CUE_BIN', 'TSC_BIN', 'PYTHON_BIN']) {
  if (process.env[name]) process.env[name] = resolve(process.env.TEST_SRCDIR, process.env[name]);
}
process.env.CUE_CACHE_DIR = resolve(process.env.TEST_TMPDIR, 'cue-cache');
process.env.CUE_REGISTRY = 'none';
mkdirSync(process.env.CUE_CACHE_DIR, { recursive: true });
process.chdir(resolve(process.env.TEST_SRCDIR, process.env.TEST_WORKSPACE));
await import(pathToFileURL(resolve(process.env.TEST_SRCDIR, process.argv[2])).href);
