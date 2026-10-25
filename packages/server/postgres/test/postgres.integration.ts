// @vitest-environment jsdom
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { setTimeout as delay } from 'node:timers/promises';
import { afterAll, beforeAll, describe, expect, it, vi } from 'vitest';
import { tableFromIPC, Type } from '@uwdata/flechette';
import { Coordinator, clausePoint, MosaicClient, Param, queryFieldInfo, Selection, SqlContext } from '@uwdata/mosaic-core';
import { DuckDB } from '@uwdata/mosaic-duckdb';
import { Table } from '@uwdata/mosaic-inputs';
import { avg, column, count, createTable, Dialect, gt, literal, loadCSV, lt, Query, row_number, sql, sum } from '@uwdata/mosaic-sql';
import { PostgresConnector } from '../src/index.js';

const run = promisify(execFile);
const image = 'postgres:18.6-alpine@sha256:898c60cb390d1085bc97bdd6a1ae968757421df394b071848b52b1c09c89d6a5';
let container: string;
let connector: PostgresConnector;
let options: { host: string; port: number; user: string; password: string; database: string };
let duck: DuckDB;

const setup = `CREATE TABLE mosaic_rows(id INTEGER NOT NULL, category TEXT, amount DOUBLE PRECISION);
  INSERT INTO mosaic_rows VALUES (1,'A',1.5),(2,'A',2.5),(3,'B',3.5),(4,NULL,NULL);`;

const decode = (bytes: Uint8Array) => tableFromIPC(bytes, {
  useBigInt: true, useBigIntTimestamp: true, useDecimalInt: true, useDate: false
});

const execution = () => new SqlContext({ sourceDialect: Dialect.DuckDB, targetDialect: Dialect.PostgreSQL, backend: 'postgres' });

beforeAll(async () => {
  container = (await run('docker', ['run', '--detach', '--rm', '--publish', '127.0.0.1::5432',
    '--env', 'POSTGRES_PASSWORD=mosaic', '--env', 'POSTGRES_DB=mosaic', image], { timeout: 120000 })).stdout.trim();
  try {
    const deadline = Date.now() + 60000;
    for (;;) {
      // Docker's temporary initialization server accepts Unix sockets before the final TCP server starts.
      try { await run('docker', ['exec', container, 'pg_isready', '--host', '127.0.0.1', '--port', '5432', '-U', 'postgres', '-d', 'mosaic']); break; }
      catch (error) { if (Date.now() >= deadline) throw error; await delay(100); }
    }
    const address = (await run('docker', ['port', container, '5432/tcp'])).stdout.trim();
    options = { host: '127.0.0.1', port: Number(address.split(':').at(-1)), user: 'postgres', password: 'mosaic', database: 'mosaic' };
    connector = await PostgresConnector.make(options);
    await connector.query({ type: 'exec', sql: setup });
    duck = new DuckDB(':memory:', {}, '');
    await duck.exec(setup);
  } catch (error) {
    try {
      const logs = await run('docker', ['logs', container]);
      console.error(logs.stdout + logs.stderr);
    } catch (logError) { console.error('Could not read PostgreSQL container logs:', logError); }
    throw error;
  }
});

afterAll(async () => {
  try {
    duck?.close();
    await connector?.close();
  } finally {
    if (container) await run('docker', ['rm', '--force', container]);
  }
});

describe('PostgreSQL 18.6 execution', () => {
  it('returns exact bigint/decimal/microsecond IPC and identical empty schemas', async () => {
    await connector.query({ type: 'exec', sql: `CREATE TABLE postgres_types(
      id BIGINT NOT NULL, amount NUMERIC(38,8), negative NUMERIC(5,-2),
      local TIMESTAMP(6), instant TIMESTAMPTZ(6), bytes BYTEA, "__proto__" INTEGER);
      INSERT INTO postgres_types VALUES (9223372036854775807,-123456789012345678901234567890.12345678,12300,
        TIMESTAMP '1969-12-31 23:59:59.999999', TIMESTAMPTZ '1970-01-01 02:30:00.123456+02:30',
        decode('0041ff','hex'),7);` });
    const table = decode(await connector.query({ type: 'arrow', sql: 'SELECT * FROM postgres_types' }, { baseColumnNullability: true }));
    const empty = decode(await connector.query({ type: 'arrow', sql: 'SELECT * FROM postgres_types WHERE FALSE' }, { baseColumnNullability: true }));
    expect(empty.numRows).toBe(0);
    expect(empty.schema).toEqual(table.schema);
    expect(table.getChild('id')!.at(0)).toBe(9223372036854775807n);
    expect(table.getChild('amount')!.at(0)).toBe(-12345678901234567890123456789012345678n);
    expect(table.getChild('negative')!.at(0)).toBe(12300n);
    expect(table.getChild('local')!.at(0)).toBe(-1n);
    expect(table.getChild('instant')!.at(0)).toBe(123456n);
    expect(Array.from(table.getChild('bytes')!.at(0) as Uint8Array)).toEqual([0, 65, 255]);
    expect(table.getChild('__proto__')!.at(0)).toBe(7);
    expect(table.schema.fields[0].nullable).toBe(false);
    expect(table.schema.fields[1].type).toMatchObject({ typeId: Type.Decimal, precision: 38, scale: 8 });
    expect(table.schema.fields[2].metadata?.get('mosaic.sqlType')).toBe('NUMERIC(5,-2)');
    expect(table.schema.fields[2].type).toMatchObject({ typeId: Type.Decimal, precision: 7, scale: 0 });
    const logical = tableFromIPC(await connector.query({ type: 'arrow', sql: 'SELECT negative FROM postgres_types' }));
    expect(logical.getChild('negative')!.at(0)).toBe(12300);
    const numeric = decode(await connector.query({ type: 'arrow', sql: 'SELECT AVG(id) AS mean FROM postgres_types' }));
    expect(numeric.schema.fields[0].type.typeId).toBe(Type.Utf8);
    expect(String(numeric.getChild('mean')!.at(0))).toMatch(/^9223372036854775807(?:\.0+)?$/);
    const coordinator = new Coordinator(connector, { logger: null, cache: false });
    try {
      await connector.query({ type: 'exec', sql: `CREATE TABLE postgres_scalars(
        boolean_value BOOLEAN, bytes_value BYTEA, small_value SMALLINT, integer_value INTEGER, big_value BIGINT,
        oid_value OID, real_value REAL, double_value DOUBLE PRECISION, internal_char "char", name_value NAME,
        text_value TEXT, char_value CHARACTER(3), varchar_value CHARACTER VARYING(12),
        json_value JSON, jsonb_value JSONB, uuid_value UUID, date_value DATE,
        time_value TIME, precise_time TIME(3), timestamp_value TIMESTAMP, precise_timestamp TIMESTAMP(3),
        zoned_timestamp TIMESTAMPTZ, precise_zoned_timestamp TIMESTAMPTZ(3),
        numeric_value NUMERIC, precise_numeric NUMERIC(5,2))` });
      const scalars = await queryFieldInfo(coordinator, [{ table: 'postgres_scalars', column: '*' }]);
      expect(scalars.map(({ column, sqlType, type }) => [column, sqlType, type])).toEqual([
        ['boolean_value', 'BOOLEAN', 'boolean'], ['bytes_value', 'BYTEA', 'object'],
        ['small_value', 'SMALLINT', 'number'], ['integer_value', 'INTEGER', 'number'], ['big_value', 'BIGINT', 'number'],
        ['oid_value', 'OID', 'number'], ['real_value', 'REAL', 'number'], ['double_value', 'DOUBLE PRECISION', 'number'],
        ['internal_char', '"CHAR"', 'string'], ['name_value', 'NAME', 'string'], ['text_value', 'TEXT', 'string'],
        ['char_value', 'CHARACTER(3)', 'string'], ['varchar_value', 'CHARACTER VARYING(12)', 'string'],
        ['json_value', 'JSON', 'string'], ['jsonb_value', 'JSONB', 'string'], ['uuid_value', 'UUID', 'string'],
        ['date_value', 'DATE', 'date'], ['time_value', 'TIME WITHOUT TIME ZONE', 'date'],
        ['precise_time', 'TIME(3) WITHOUT TIME ZONE', 'date'], ['timestamp_value', 'TIMESTAMP WITHOUT TIME ZONE', 'date'],
        ['precise_timestamp', 'TIMESTAMP(3) WITHOUT TIME ZONE', 'date'],
        ['zoned_timestamp', 'TIMESTAMP WITH TIME ZONE', 'date'], ['precise_zoned_timestamp', 'TIMESTAMP(3) WITH TIME ZONE', 'date'],
        ['numeric_value', 'NUMERIC', 'number'], ['precise_numeric', 'NUMERIC(5,2)', 'number']
      ]);
      const threshold = Param.value(new Date(0));
      const filtered = Query.from('postgres_types').select({ rows: count() }).where(lt('local', threshold));
      expect(Array.from(await coordinator.query(filtered), row => Number(row.rows))).toEqual([1]);
      threshold.update(new Date(-1));
      expect(Array.from(await coordinator.query(filtered), row => Number(row.rows))).toEqual([0]);
      threshold.update(new Date(0));
      expect(Array.from(await coordinator.query(filtered), row => Number(row.rows))).toEqual([1]);
    } finally { coordinator.clear(); }
  });

  it('keeps expression and outer-join nullability conservative', async () => {
    const direct = decode(await connector.query({ type: 'arrow', sql: 'SELECT id, id+1 AS expression FROM mosaic_rows LIMIT 0' }, { baseColumnNullability: true }));
    expect(direct.schema.fields.map(field => field.nullable)).toEqual([false, true]);
    const joined = decode(await connector.query({ type: 'arrow', sql: 'SELECT r.id FROM mosaic_rows l LEFT JOIN mosaic_rows r ON FALSE LIMIT 1' }));
    expect(joined.schema.fields[0].nullable).toBe(true);
    expect(joined.schema.fields[0].metadata?.get('postgres.baseNotNull')).toBe('true');
    expect(joined.getChild('id')!.at(0)).toBeNull();
    const coordinator = new Coordinator(connector, {
      sql: new SqlContext({ sourceDialect: Dialect.PostgreSQL, targetDialect: Dialect.PostgreSQL, backend: 'postgres' }),
      logger: null, cache: false
    });
    try {
      const postgres = sql({ sourceDialect: Dialect.PostgreSQL });
      const grouped = await coordinator.query(postgres`SELECT id, COUNT(*) AS rows FROM mosaic_rows GROUP BY ROLLUP(id) ORDER BY id NULLS LAST`);
      expect(grouped.schema.fields[0].nullable).toBe(true);
      expect(Array.from(grouped, row => [row.id, Number(row.rows)])).toEqual([[1, 1], [2, 1], [3, 1], [4, 1], [null, 4]]);
    } finally { coordinator.clear(); }
  });

  it('compiles grouped results, windows and live bindings through a coordinator', async () => {
    const coordinator = new Coordinator(connector, { sql: execution(), logger: null, cache: false, preagg: { enabled: false } });
    try {
      const field = Param.value('amount');
      const minimum = Param.value(1);
      const query = Query.from('mosaic_rows').select('category', {
        total: sum(column(field)), mean: avg(column(field)), rows: count()
      }).where(gt(column(field), minimum)).groupby('category').orderby('category');
      const values = Array.from(await coordinator.query(query), row => [row.category, Number(row.total), Number(row.mean), Number(row.rows)]);
      const expected = await duck.query('SELECT category,SUM(amount) AS total,AVG(amount) AS mean,COUNT(*) AS rows FROM mosaic_rows WHERE amount>1 GROUP BY category ORDER BY category');
      expect(values).toEqual(expected.map(row => [row.category, Number(row.total), Number(row.mean), Number(row.rows)]));
      minimum.update(2);
      const changed = Array.from(await coordinator.query(query), row => [row.category, Number(row.total)]);
      expect(changed).toEqual([['A', 2.5], ['B', 3.5]]);
      field.update('id');
      expect(Array.from(await coordinator.query(query), row => [row.category, Number(row.total)])).toEqual([['B', 3], [null, 4]]);
      const ambiguous = Query.from('mosaic_rows').select('id', { rank: row_number().orderby('id') }).qualify(gt('rank', 2)).orderby('id');
      const submitted = vi.spyOn(connector, 'query');
      try {
        await expect(coordinator.query(ambiguous)).rejects.toThrow(/QUALIFY requires/);
        expect(submitted).not.toHaveBeenCalled();
      } finally { submitted.mockRestore(); }
      const source = Query.from('mosaic_rows').select({ source_id: 'id' });
      const windows = Query.from(source).select({ id: 'source_id', rank: row_number().orderby('source_id') })
        .qualify(gt('rank', 2)).orderby('id');
      expect(Array.from(await coordinator.query(windows), row => [row.id, Number(row.rank)])).toEqual([[3, 3], [4, 4]]);
      const info = await queryFieldInfo(coordinator, [
        { table: 'mosaic_rows', column: 'id', stats: ['min', 'max', 'count', 'nulls'] },
        { table: 'mosaic_rows', column: 'amount', stats: ['min', 'max', 'count', 'nulls'] }
      ]);
      expect(info[0]).toMatchObject({ column: 'id', sqlType: 'INTEGER', nullable: false, min: 1, max: 4, count: 4, nulls: 0 });
      expect(info[1]).toMatchObject({ column: 'amount', sqlType: 'DOUBLE PRECISION', nullable: true, min: 1.5, max: 3.5, count: 3, nulls: 1 });
      await expect(coordinator.exec(loadCSV('unsupported', 'file.csv'))).rejects.toThrow();
      expect(Array.from(await coordinator.query(Query.select({ value: count() }).from('mosaic_rows')), row => Number(row.value))).toEqual([4]);
    } finally { coordinator.clear(); }
  });

  it('drives a rendered table through real selection updates', async () => {
    const coordinator = new Coordinator(connector, { logger: null, cache: false });
    const selection = Selection.crossfilter();
    const source = {};
    const table = new Table({ from: 'mosaic_rows', columns: ['id', 'category'], filterBy: selection });
    coordinator.connect(table);
    try {
      expect(coordinator.executionContext()).toMatchObject({ backend: 'postgres', sourceDialect: Dialect.DuckDB, targetDialect: Dialect.PostgreSQL });
      expect(coordinator.preaggregator.enabled).toBe(false);
      expect(() => { coordinator.preaggregator.enabled = true; }).toThrow(/not supported/);
      expect(() => new Coordinator(connector, { logger: null, preagg: { enabled: true } })).toThrow(/not supported/);
      await table.pending;
      expect(table.body.rows).toHaveLength(4);
      selection.update(clausePoint('category', 'A', { source }));
      await selection.pending('value');
      expect(Array.from(table.body.rows, row => row.cells[0].innerText)).toEqual(['1', '2']);
      selection.update(clausePoint('category', null, { source }));
      await selection.pending('value');
      expect(Array.from(table.body.rows, row => row.cells[0].innerText)).toEqual(['4']);
    } finally { table.destroy(); coordinator.clear(); }
  });

  it('cancels server work and releases the queue only after cancellation completes', async () => {
    const controller = new AbortController();
    const slow = connector.query({ type: 'exec', sql: 'SELECT pg_sleep(30)' }, { signal: controller.signal });
    const rejected = expect(slow).rejects.toMatchObject({ name: 'AbortError' });
    await delay(100);
    const after = connector.query({ type: 'arrow', sql: 'SELECT 42 AS answer' });
    controller.abort();
    await rejected;
    expect(decode(await after).getChild('answer')!.at(0)).toBe(42);
    await connector.query({ type: 'exec', sql: 'CREATE TEMP TABLE ordered_work(value INTEGER); INSERT INTO ordered_work VALUES(1); UPDATE ordered_work SET value=value+1' });
    expect(decode(await connector.query({ type: 'arrow', sql: 'SELECT value FROM ordered_work' })).getChild('value')!.at(0)).toBe(2);
  });

  it('isolates sessions and closes active requests without leaking a coordinator', async () => {
    const other = await PostgresConnector.make(options);
    const left = new Coordinator(connector, { logger: null });
    const right = new Coordinator(other, { logger: null });
    try {
      await Promise.all([
        left.exec(createTable('private_values', Query.select({ value: literal(1) }), { temp: true })),
        right.exec(createTable('private_values', Query.select({ value: literal(2) }), { temp: true }))
      ]);
      expect(Array.from(await left.query(Query.from('private_values')), row => row.value)).toEqual([1]);
      expect(Array.from(await right.query(Query.from('private_values')), row => row.value)).toEqual([2]);
      const client = new MosaicClient();
      right.connect(client);
      right.clear();
      expect(client.coordinator).toBeNull();
      const slow = other.query({ type: 'exec', sql: 'SELECT pg_sleep(30)' });
      const rejected = expect(slow).rejects.toThrow(/closed/);
      await delay(100);
      await other.close();
      await rejected;
    } finally { left.clear(); right.clear(); await other.close(); }
  });
});
