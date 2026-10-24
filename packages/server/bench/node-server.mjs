import { readFileSync, writeFileSync } from 'node:fs';
import { basename, resolve } from 'node:path';
import { gunzipSync } from 'node:zlib';
import { DuckDB, dataServer } from '../duckdb/src/index.js';

const extensions = process.argv.slice(2, -1);
const db = new DuckDB(':memory:', {
  extension_directory: resolve('extensions')
}, extensions.length ? '' : undefined);
for (const input of extensions) {
  const name = basename(input, '.gz');
  const path = resolve(name + '.duckdb_extension');
  writeFileSync(path, gunzipSync(readFileSync(resolve(process.env.RUNFILES_DIR, input))));
  await db.exec("INSTALL '" + path.replaceAll("'", "''") + "'; LOAD " + name);
}
if (extensions.length) await db.exec('INSTALL nanoarrow FROM community; LOAD nanoarrow');
dataServer(db, { port: Number(process.argv.at(-1)) });
