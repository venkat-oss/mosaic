import { writeFileSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { installPackages } from '../../../../build/npm-install.mjs';

const runfile = path => resolve(process.env.TEST_SRCDIR, path);
const workspaceFile = path => resolve(process.env.TEST_SRCDIR, process.env.TEST_WORKSPACE, path);
const packages = Object.fromEntries(Object.entries(JSON.parse(process.env.MOSAIC_PACKAGES)).map(([name, path]) => [name, runfile(path)]));
const links = Object.fromEntries(Object.entries(JSON.parse(process.env.MOSAIC_LINKS)).map(([name, path]) => [name, workspaceFile(path)]));
const { directory, run } = installPackages(runfile(process.env.PNPM_BIN), packages, links);

run(process.execPath, ['--input-type=module', '-e', `
import assert from 'node:assert/strict';
import { PostgresConnector } from '@uwdata/mosaic-postgres';
import { PostgresConnector as CoreConnector } from '@uwdata/mosaic-core/postgres-connector';
assert.equal(CoreConnector, PostgresConnector);
const connector = new CoreConnector({host:'127.0.0.1',port:1,connectionTimeoutMillis:500});
await assert.rejects(connector.ready);
await connector.close();
`]);

writeFileSync(join(directory, 'consumer.ts'), `
import { PostgresConnector } from '@uwdata/mosaic-postgres';
import { Coordinator, SqlContext } from '@uwdata/mosaic-core';
import { PostgresConnector as CoreConnector } from '@uwdata/mosaic-core/postgres-connector';
import { Dialect, Query } from '@uwdata/mosaic-sql';
const connector: PostgresConnector = new CoreConnector({host:'localhost',database:'mosaic'});
const coordinator = new Coordinator(connector, {sql:new SqlContext({targetDialect:Dialect.PostgreSQL})});
void coordinator.query(Query.select({value:1}));
void connector.query({type:'arrow',sql:'SELECT 1'}, {baseColumnNullability:true});
void connector.close();
// @ts-expect-error port requires a number in the installed declaration
new PostgresConnector({port:'5432'});
`);
writeFileSync(join(directory, 'tsconfig.json'), JSON.stringify({
  compilerOptions: { strict: true, noEmit: true, module: 'Node16', target: 'ES2022', skipLibCheck: true, types: [] },
  files: ['consumer.ts']
}));
run(runfile(process.env.TSC_BIN), ['--project', join(directory, 'tsconfig.json')]);
