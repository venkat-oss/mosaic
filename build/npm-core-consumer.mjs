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
import { Coordinator, makeClient, NativeSqlContext, Param, Selection } from '@uwdata/mosaic-core';
import { NodeConnector } from '@uwdata/mosaic-core/node-connector';
import { DuckDB } from '@uwdata/mosaic-duckdb';
import { asLiteral, count, cte, gte, Query, sum } from '@uwdata/mosaic-sql/native';
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
const native = new NativeSqlContext();
const nativeConnector = await NodeConnector.make(db);
const calls = [];
const nativeCoordinator = new Coordinator({
  query(request, options) {
    calls.push(request.sql);
    return nativeConnector.query(request, options);
  }
}, { native, logger: null });
await nativeCoordinator.exec('CREATE TABLE native_consumer (amount INTEGER); INSERT INTO native_consumer VALUES (1), (2), (3), (NULL)');
const selection = native.selection();
const source = {};
selection.update(native.interval('amount', [2, 3], { source }));
await selection.pending('value');
let row;
const nativeErrors = [];
const client = makeClient({
  coordinator: nativeCoordinator,
  selection,
  query: filter => Query.select({ rows: count(), total: sum('amount') }).from('native_consumer').where(filter ?? []),
  queryResult: data => { row = Array.from(data)[0]; },
  queryError: error => { nativeErrors.push(error); }
});
await client.pending;
assert.equal(Number(row.rows), 2);
assert.equal(Number(row.total), 5);
selection.update(native.interval('amount', [3, 3], { source }));
await selection.pending('value');
assert.equal(Number(row.rows), 1);
assert.equal(Number(row.total), 3);
selection.update(native.point('amount', 2, { source }));
await selection.pending('value');
assert.equal(Number(row.rows), 1);
assert.equal(Number(row.total), 2);
assert.deepEqual(nativeErrors, []);
assert.ok(nativeCoordinator.preaggregator.entries.get(client)?.result);
assert.ok(calls.some(sql => /CREATE TABLE.*preagg_/is.test(sql)));
assert.ok(calls.some(sql => /^SELECT\\b/i.test(sql) && /FROM\\s+"mosaic"\\."preagg_/i.test(sql)));
const bound = Param.value(2);
const query = Query.select({ rows: count() }).from('native_consumer').where(gte('amount', asLiteral(bound)));
assert.equal(Number(Array.from(await nativeCoordinator.query(query))[0].rows), 2);
await bound.update(3);
assert.equal(Number(Array.from(await nativeCoordinator.query(query))[0].rows), 1);
const description = await nativeCoordinator.query(Query.from('native_consumer').describe());
assert.equal(Array.from(description)[0].column_name, 'amount');
const child = Query.from('native_consumer');
const first = Query.from('local_source').with(cte('local_source', child)).select({ rows: count() });
const second = Query.from('local_source').with(cte('local_source', child)).select({ total: sum('amount') });
const issued = calls.length;
const [counts, totals] = await Promise.all([nativeCoordinator.query(first), nativeCoordinator.query(second)]);
assert.equal(Number(Array.from(counts)[0].rows), 4);
assert.equal(Number(Array.from(totals)[0].total), 6);
assert.equal(calls.length, issued + 1);
assert.equal(await nativeCoordinator.query(first), counts);
assert.equal(await nativeCoordinator.query(second), totals);
assert.equal(calls.length, issued + 1);
nativeCoordinator.clear();
db.close();
`]);
writeFileSync(join(directory, 'consumer.ts'), `
import { Coordinator, makeClient, NativeSqlContext, Param, Selection } from '@uwdata/mosaic-core';
import { NodeConnector } from '@uwdata/mosaic-core/node-connector';
import { count, Query } from '@uwdata/mosaic-sql/native';
const coordinator = new Coordinator(new NodeConnector());
const result: PromiseLike<unknown> = coordinator.query('SELECT 1');
const value: number | undefined = Param.value(7).value;
void [result, value, Selection.crossfilter()];
const native = new NativeSqlContext();
const nativeCoordinator = new Coordinator(new NodeConnector(), { native });
const selection = native.selection();
const nativeResult: PromiseLike<unknown> = nativeCoordinator.query(Query.select({ rows: count() }));
makeClient({ coordinator: nativeCoordinator, selection, query: filter => Query.from('rows').where(filter ?? []) });
void nativeResult;
`);
writeFileSync(join(directory, 'tsconfig.json'), JSON.stringify({
  compilerOptions: { strict: true, noEmit: true, module: 'Node16', target: 'ES2022', skipLibCheck: true, types: [] },
  files: ['consumer.ts']
}));
run(tsc, ['--project', join(directory, 'tsconfig.json')]);
