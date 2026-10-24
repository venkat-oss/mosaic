import assert from 'node:assert/strict';
import { readFileSync, writeFileSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { installPackages } from './npm-install.mjs';

const [sqlPath, duckdbPath, nodeApiPath, flechettePath, pnpmPath, tscPath] = process.argv.slice(2);
const [sql, duckdb, pnpm, tsc] = [sqlPath, duckdbPath, pnpmPath, tscPath].map(path => resolve(process.env.TEST_SRCDIR, path));
const nodeApi = resolve(process.env.TEST_SRCDIR, process.env.TEST_WORKSPACE, nodeApiPath);
const flechette = resolve(process.env.TEST_SRCDIR, process.env.TEST_WORKSPACE, flechettePath);
const { directory, run } = installPackages(pnpm, {
  '@uwdata/mosaic-sql': sql,
  '@uwdata/mosaic-duckdb': duckdb
}, {
  '@duckdb/node-api': nodeApi,
  '@uwdata/flechette': flechette,
  '@polyglot-sql/sdk': resolve(process.env.TEST_SRCDIR, process.env.TEST_WORKSPACE, 'packages/mosaic/sql/node_modules/@polyglot-sql/sdk')
});
run(process.execPath, ['--input-type=module', '-e', `
import assert from 'node:assert/strict';
import { Query, literal } from '@uwdata/mosaic-sql';
import { DuckDB } from '@uwdata/mosaic-duckdb';
import { asLiteral, asNode, compile, createExecutionContext, native } from '@uwdata/mosaic-sql/native';
const db = new DuckDB(':memory:', {}, '');
assert.deepEqual(await db.query(String(Query.select({ value: literal(42) }))), [{ value: 42 }]);
await db.exec('CREATE TABLE native_values (amount INTEGER); INSERT INTO native_values VALUES (1), (2), (3)');
const column = asNode('amount');
const query = native.select([
  native.alias(native.count(), 'rows'),
  native.alias(native.aggregate('sum', column), 'total')
], {
  from: native.from([native.table('native_values')]).from,
  where_clause: native.where(native.binary('gte', column, asLiteral(2))).where
});
const context = createExecutionContext({ backend: 'installed-sql' });
const statements = compile([query, native.select([asLiteral(7)])], context);
assert.equal(statements.length, 2);
const rows = await db.query(statements[0]);
assert.equal(Number(rows[0].rows), 2);
assert.equal(Number(rows[0].total), 5);
assert.equal(Object.values((await db.query(statements[1]))[0])[0], 7);
db.close();
`]);
writeFileSync(join(directory, 'consumer.ts'), `
import { Query, literal } from '@uwdata/mosaic-sql';
import { DuckDB } from '@uwdata/mosaic-duckdb';
import { compile, createExecutionContext, Dialect, native, type SqlExpression } from '@uwdata/mosaic-sql/native';
const dialect: Dialect.DuckDB = Dialect.DuckDB;
const expression: SqlExpression = native.select([native.literal(42)]);
const statements: string[] = compile([expression], createExecutionContext({ targetDialect: dialect }));
void statements;
const query: string = Query.select({ value: literal(42) }).toString();
const rows: Promise<Record<string, unknown>[]> = new DuckDB().query(query);
void rows;
`);
writeFileSync(join(directory, 'tsconfig.json'), JSON.stringify({
  compilerOptions: { strict: true, noEmit: true, module: 'Node16', target: 'ES2022', skipLibCheck: true, types: [] },
  files: ['consumer.ts']
}));
run(tsc, ['--project', join(directory, 'tsconfig.json')]);
writeFileSync(join(directory, 'input.csv'), 'value\n42\n');
const installed = join(directory, 'node_modules/@uwdata/mosaic-duckdb');
const manifest = JSON.parse(readFileSync(join(installed, 'package.json'), 'utf8'));
for (const [command, script] of Object.entries(manifest.bin)) {
  const extension = { 'to-csv': 'csv', 'to-parquet': 'parquet', 'to-arrow': 'arrow' }[command];
  const output = join(directory, `result.${extension}`);
  run(process.execPath, [join(installed, script), join(directory, 'input.csv'), output]);
  assert.ok(readFileSync(output).length > 0);
}
assert.match(readFileSync(join(directory, 'result.csv'), 'utf8'), /value\r?\n42/);
