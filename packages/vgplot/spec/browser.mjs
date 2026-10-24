import { spawn } from 'node:child_process';
import { once } from 'node:events';
import { mkdir, mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import { realpathSync } from 'node:fs';
import { createRequire } from 'node:module';
import { tmpdir } from 'node:os';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { gunzipSync } from 'node:zlib';
import { createServer } from 'vite';
import { DuckDB, dataServer } from '../../server/duckdb/src/index.js';
import config from '../../../vite.config.js';

const root = resolve(dirname(realpathSync(fileURLToPath(import.meta.url))), '../../..');
const args = process.argv.slice(4);
const update = args.some(arg => arg.startsWith('-u') || arg === '--update-snapshots' || arg.startsWith('--update-snapshots='));
if (update && !process.env.BUILD_WORKSPACE_DIRECTORY) throw new Error('Snapshot updates require bazel run.');
const temporary = await mkdtemp(join(process.env.TEST_TMPDIR || tmpdir(), 'mosaic-browser-'));
process.env.HOME = join(temporary, 'home');
process.env.XDG_CONFIG_HOME = join(process.env.HOME, '.config');
await mkdir(process.env.HOME, { recursive: true });
process.chdir(temporary);

const db = new DuckDB(':memory:', {
  extension_directory: join(temporary, 'extensions')
}, '');
let database, vite, child;
try {
  const extensions = ['httpfs', 'spatial'];
  for (const [index, name] of extensions.entries()) {
    const input = resolve(process.env.RUNFILES_DIR || process.env.TEST_SRCDIR, process.argv[index + 2]);
    const path = join(temporary, name + '.duckdb_extension');
    await writeFile(path, gunzipSync(await readFile(input)));
    await db.exec("INSTALL '" + path.replaceAll("'", "''") + "'; LOAD " + name);
  }
  await db.exec('INSTALL nanoarrow FROM community; LOAD nanoarrow');
  database = dataServer(db, { port: 0 });
  await once(database, 'listening');
  const databasePort = database.address().port;
  const uri = `http://127.0.0.1:${databasePort}/`;
  vite = await createServer({
    root,
    configFile: false,
    cacheDir: join(temporary, 'vite'),
    resolve: config.resolve,
    optimizeDeps: { ...config.optimizeDeps, entries: ['packages/vgplot/spec/test/visual-harness.html'] },
    plugins: [{
      name: 'mosaic-test-database',
      transformIndexHtml: html => html.replace('<head>', `<head><script>window.__MOSAIC_DATABASE_URI=${JSON.stringify(uri)};</script>`)
    }],
    server: { host: '127.0.0.1', port: 0, strictPort: true, watch: null, fs: { allow: [root] } }
  });
  await vite.listen();
  const baseURL = `http://127.0.0.1:${vite.httpServer.address().port}`;
  const require = createRequire(import.meta.url);
  child = spawn(process.execPath, [require.resolve('@playwright/test/cli'), 'test', '--config', join(root, 'packages/vgplot/spec/playwright.config.js'), ...args], {
    cwd: root,
    stdio: 'inherit',
    env: {
      ...process.env,
      MOSAIC_TEST_BASE_URL: baseURL,
      MOSAIC_TEST_DATABASE_PORT: String(databasePort),
      MOSAIC_SNAPSHOT_ROOT: update ? process.env.BUILD_WORKSPACE_DIRECTORY : root,
      MOSAIC_BROWSER_OUTPUT: join(process.env.TEST_UNDECLARED_OUTPUTS_DIR || temporary, 'playwright')
    }
  });
  for (const signal of ['SIGINT', 'SIGTERM']) process.once(signal, () => child.kill(signal));
  const [code, signal] = await once(child, 'exit');
  process.exitCode = code ?? (signal ? 1 : 0);
} finally {
  try {
    if (child && child.exitCode === null && child.signalCode === null) child.kill('SIGTERM');
    db.close();
    await vite?.close();
    if (database) await new Promise(resolve => database.close(resolve));
  } finally {
    await rm(temporary, { recursive: true, force: true });
  }
}
