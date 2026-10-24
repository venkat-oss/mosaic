import { writeFileSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { installPackages } from './npm-install.mjs';

const [sql, duckdb, core, pnpm, tsc] = process.argv.slice(2).map(path => resolve(process.env.TEST_SRCDIR, path));
const dependency = name => resolve(process.env.TEST_SRCDIR, process.env.TEST_WORKSPACE, 'packages/mosaic/core/node_modules', name);
const { directory, run } = installPackages(pnpm, {
  '@uwdata/mosaic-sql': sql,
  '@uwdata/mosaic-duckdb': duckdb,
  '@uwdata/mosaic-core': core
}, {
  '@polyglot-sql/sdk': resolve(process.env.TEST_SRCDIR, process.env.TEST_WORKSPACE, 'packages/mosaic/sql/node_modules/@polyglot-sql/sdk'),
  '@duckdb/node-api': resolve(process.env.TEST_SRCDIR, process.env.TEST_WORKSPACE, 'packages/server/duckdb/node_modules/@duckdb/node-api'),
  '@duckdb/duckdb-wasm': dependency('@duckdb/duckdb-wasm'),
  '@types/emscripten': dependency('@types/emscripten'),
  '@uwdata/flechette': dependency('@uwdata/flechette')
});
run(process.execPath, ['--input-type=module', '-e', `
import assert from 'node:assert/strict';
import { accessSync } from 'node:fs';
import { createRequire } from 'node:module';
import { Coordinator, Param, Selection } from '@uwdata/mosaic-core';
import { NodeConnector } from '@uwdata/mosaic-core/node-connector';
import { DuckDB } from '@uwdata/mosaic-duckdb';
const db = new DuckDB();
const coordinator = new Coordinator(await NodeConnector.make(db), { logger: null });
const table = await coordinator.query('SELECT 42::INTEGER AS value');
assert.equal(table.getChild('value').toArray()[0], 42);
assert.equal(Param.value(7).value, 7);
assert.ok(Selection.crossfilter());
const require = createRequire(import.meta.resolve('@uwdata/mosaic-core'));
accessSync(require.resolve('@duckdb/duckdb-wasm/dist/duckdb-mvp.wasm'));
accessSync(require.resolve('@duckdb/duckdb-wasm/dist/duckdb-browser-mvp.worker.js'));
coordinator.clear();
db.close();
`]);
writeFileSync(join(directory, 'consumer.ts'), `
import { Coordinator, Param, Selection } from '@uwdata/mosaic-core';
import { NodeConnector } from '@uwdata/mosaic-core/node-connector';
const coordinator = new Coordinator(new NodeConnector());
const result: PromiseLike<unknown> = coordinator.query('SELECT 1');
const value: number | undefined = Param.value(7).value;
void [result, value, Selection.crossfilter()];
`);
writeFileSync(join(directory, 'tsconfig.json'), JSON.stringify({
  compilerOptions: { strict: true, noEmit: true, module: 'Node16', target: 'ES2022', skipLibCheck: true, types: [] },
  files: ['consumer.ts']
}));
run(tsc, ['--project', join(directory, 'tsconfig.json')]);
