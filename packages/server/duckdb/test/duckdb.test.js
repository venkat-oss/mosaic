import { describe, it, expect, beforeAll, afterAll, vi } from 'vitest';
import path from 'path'
import { mkdtemp, readdir, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { tableFromIPC } from '@uwdata/flechette';
import { db } from './db.js';
import { DuckDB, loadArrow } from '../src/index.js';

describe('DuckDB', () => {
  beforeAll(async () => {
    const file = path.resolve(__dirname, '../../../../data/penguins.csv');
    await db.exec(`CREATE TABLE penguins AS SELECT * FROM '${file}'`);
  });

  afterAll(async () => {
    await db.exec('DROP TABLE penguins');
  });

  describe('arrowBuffer', () => {
    it('returns arrow ipc buffers', async () => {
      const chunks = await db.arrowBuffer('SELECT * FROM penguins');
      expect(Array.isArray(chunks)).toBe(true);
      const table = tableFromIPC(chunks);
      expect(table.numRows).toBe(342);
      expect(table.numCols).toBe(7);
    });

    it('handles empty results', async () => {
      const result = await db.arrowBuffer('SELECT * FROM penguins WHERE 1 = 0');
      expect(Array.isArray(result)).toBe(true);
      const table = tableFromIPC(result);
      expect(table.numRows).toBe(0);
      expect(table.numCols).toBe(7);
      expect(table.names).toContain('species');
      expect(Array.from(Buffer.concat(result).subarray(-8))).toEqual([255, 255, 255, 255, 0, 0, 0, 0]);
    });

    it('accepts semicolons and trailing comments', async () => {
      const table = tableFromIPC(await db.arrowBuffer('SELECT 42::INTEGER AS value; -- complete statement'));
      expect(table.toArray()).toEqual([{ value: 42 }]);
    });

    it('serializes DML RETURNING once and preserves caller transactions', async () => {
      await db.exec('CREATE TEMP TABLE returning_values (value INTEGER)');
      try {
        await db.exec('BEGIN TRANSACTION');
        const table = tableFromIPC(await db.arrowBuffer('INSERT INTO returning_values VALUES (42) RETURNING value;'));
        expect(table.toArray()).toEqual([{ value: 42 }]);
        expect(await db.query('SELECT count()::INTEGER AS count FROM returning_values')).toEqual([{ count: 1 }]);
        await db.exec('ROLLBACK');
        expect(await db.query('SELECT count()::INTEGER AS count FROM returning_values')).toEqual([{ count: 0 }]);
      } finally {
        await db.exec('DROP TABLE returning_values');
      }
    });

    it('exports results inside a caller read-only transaction', async () => {
      await db.exec('BEGIN TRANSACTION READ ONLY');
      try {
        const table = tableFromIPC(await db.arrowBuffer('SELECT 42::INTEGER AS value'));
        expect(table.toArray()).toEqual([{ value: 42 }]);
      } finally {
        await db.exec('ROLLBACK');
      }
    });

    it('preserves quoted, duplicate and empty result column names', async () => {
      const sql = 'SELECT 1 AS x, 2 AS x, 3 AS \'quoted"name\', 4 AS \'\'';
      const nativeNames = (await db.con.run(sql)).columnNames();
      const table = tableFromIPC(await db.arrowBuffer(sql));
      expect(table.names).toEqual(nativeNames);
      expect(table.names.slice(0, 3)).toEqual(['x', 'x', 'quoted"name']);
      expect(table.children.map(column => column.get(0))).toEqual([1, 2, 3, 4]);
      const empty = tableFromIPC(await db.arrowBuffer(sql + ' WHERE false'));
      expect(empty.names).toEqual(nativeNames);
      expect(empty.numRows).toBe(0);
    });

    it('preserves native Arrow types and values without JSON conversion', async () => {
      const table = tableFromIPC(await db.arrowBuffer(`SELECT
        18446744073709551615::UBIGINT AS integer,
        123.456::DECIMAL(10, 3) AS decimal,
        TIMESTAMP '2026-10-23 12:34:56.123456' AS timestamp,
        DATE '2026-10-23' AS date,
        [1, NULL, 3] AS list,
        {'x': 1, 'label': 'value'} AS struct,
        'abc'::BLOB AS blob
      `), { useBigInt: true, useDecimalInt: true, useBigIntTimestamp: true, useDate: true });
      const row = table.get(0);
      expect(row.integer).toBe(18446744073709551615n);
      expect(row.decimal).toBe(123456n);
      expect(row.timestamp).toBe(1792758896123456n);
      expect(row.date).toEqual(new Date('2026-10-23T00:00:00Z'));
      expect(Array.from(row.list)).toEqual([1, null, 3]);
      expect(row.struct).toEqual({ x: 1, label: 'value' });
      expect(Buffer.from(row.blob).toString()).toBe('abc');
    });

    it('cleans temporary tables and files when Arrow export fails', async () => {
      const directory = await mkdtemp(path.join(tmpdir(), 'mosaic-arrow-failure-'));
      const isolated = new DuckDB(':memory:', {}, 'INSTALL nanoarrow FROM community; LOAD nanoarrow; SET enable_external_access=false');
      vi.stubEnv('TMPDIR', directory);
      try {
        await expect(isolated.arrowBuffer('SELECT 42 AS value')).rejects.toThrow(/disabled|permission/i);
        expect(await isolated.query("SELECT table_name FROM duckdb_tables() WHERE table_name LIKE '_mosaic_arrow_%'")).toEqual([]);
        expect(await readdir(directory)).toEqual([]);
      } finally {
        vi.unstubAllEnvs();
        isolated.close();
        await rm(directory, { recursive: true, force: true });
      }
    });

    it('handles DESC queries', async () => {
      const result = await db.arrowBuffer('DESC SELECT * FROM penguins');
      const table = tableFromIPC(result);
      expect(table.numRows).toBe(7);
    });
  });

  describe('loadArrow', () => {
    it('quotes table names and temporary paths when loading Arrow', async () => {
      const directory = await mkdtemp(path.join(tmpdir(), "mosaic'arrow-"));
      vi.stubEnv('TMPDIR', directory);
      try {
        await loadArrow(db, 'arrow"table', await db.arrowBuffer('SELECT * FROM penguins'));
        const result = await db.query('SELECT count()::INTEGER AS count FROM "arrow""table"');
        expect(result[0]?.count).toBe(342);
        expect(await readdir(directory)).toEqual([]);
      } finally {
        vi.unstubAllEnvs();
        await db.exec('DROP TABLE IF EXISTS "arrow""table"');
        await rm(directory, { recursive: true, force: true });
      }
    });

    it('loads an arrow ipc buffer', async () => {
      await loadArrow(db, 'arrow', await db.arrowBuffer('SELECT * FROM penguins'));
      const res = await db.query('SELECT count()::INTEGER AS count FROM arrow');
      expect(res[0]?.count).toBe(342);
      await db.exec('DROP TABLE arrow');
    });
  });
});
