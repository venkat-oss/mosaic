import { mkdtemp, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { DuckDB } from '@uwdata/mosaic-duckdb';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import * as sql from '../src/native/index.js';
import type { SqlRoot } from '../src/native/index.js';

const db = new DuckDB(':memory:', {}, '');
const execution = sql.createExecutionContext();
let directory: string;
const execute = (input: SqlRoot) => db.exec(sql.compile([input], execution)[0]);
const rows = (table: string) => db.query(sql.compile([sql.Query.from(table)], execution)[0]);

beforeAll(async () => { directory = await mkdtemp(join(tmpdir(), "mosaic-load-O'Reilly-")); });
afterAll(async () => { db.close(); await rm(directory, { recursive: true, force: true }); });

describe('native data loading', () => {
  it('preserves quoted paths, nested reader options and deferred expression options', async () => {
    const file = join(directory, "authors' notes.csv");
    await writeFile(file, "author's name\ncan't\nAda\n");
    let value = "can't";
    let reads = 0;
    const parameter = { get value() { ++reads; return value; }, addEventListener() {}, removeEventListener() {} };
    const query = sql.loadCSV('native_authors', file, {
      replace: true,
      columns: { "author's name": 'VARCHAR' },
      nullstr: sql.asLiteral(parameter),
      header: true
    });
    expect(reads).toBe(0);
    await execute(query);
    expect(reads).toBe(1);
    expect(await rows('native_authors')).toEqual([{ "author's name": null }, { "author's name": 'Ada' }]);
    value = 'Ada';
    await execute(query);
    expect(reads).toBe(2);
    expect(await rows('native_authors')).toEqual([{ "author's name": "can't" }, { "author's name": null }]);
  });

  it('loads CSV, JSON and Parquet through native reader relations and projected expressions', async () => {
    const csv = join(directory, 'numbers.csv');
    await writeFile(csv, 'x,y\n1,2\n3,4\n');
    await execute(sql.loadCSV('native_csv_projection', csv, { select: ['y', 'x + y AS total'], where: 'x > 1' }));
    expect(await rows('native_csv_projection')).toEqual([{ y: '4', total: '7' }]);
    const json = join(directory, 'numbers.json');
    await writeFile(json, JSON.stringify([{ x: 1, y: 2 }, { x: 3, y: 4 }]));
    await execute(sql.loadJSON('native_json_projection', json, { select: ['y', 'x + y AS total'], where: sql.gt('x', 1) }));
    expect(await rows('native_json_projection')).toEqual([{ y: '4', total: '7' }]);
    const parquet = join(directory, "numbers' file.parquet");
    const path = sql.compile([sql.literal(parquet)], execution)[0];
    await db.exec(`COPY (SELECT 1 AS x, 2 AS y UNION ALL SELECT 3, 4) TO ${path} (FORMAT PARQUET)`);
    await execute(sql.loadParquet('native_parquet_projection', parquet, { select: ['y', 'x + y AS total'], where: 'x > 1', view: true }));
    expect(await rows('native_parquet_projection')).toEqual([{ y: 4, total: 7 }]);
  });

  it('unions all objects before projecting, retains types and quotes every object key', async () => {
    const data = [
      Object.fromEntries([['a"b', 1], ['__proto__', 2], ['text', "O'Reilly"], ['at', new Date('2024-02-29T00:00:00Z')]]),
      Object.fromEntries([['a"b', 3], ['__proto__', 4], ['text', null], ['at', new Date('2024-03-01T00:00:00Z')]])
    ];
    await execute(sql.loadObjects('native_objects', data, {
      select: ['"__proto__"', '"a""b" + "__proto__" AS total', 'text', '"at"'], where: '"a""b" > 1'
    }));
    expect(await rows('native_objects')).toEqual([{ ['__proto__']: 4, total: 7, text: null, at: '2024-03-01' }]);
    expect(await db.query(sql.compile([sql.sqlFrom(data, { columns: { 'a"b': 'renamed', text: 'label' } })], execution)[0]))
      .toEqual([{ renamed: 1, label: "O'Reilly" }, { renamed: 3, label: null }]);
    expect(() => sql.loadObjects('native_empty', [])).toThrow('empty column set');
    expect(() => sql.sqlFrom([], { columns: ['x'] })).toThrow('empty row set');
  });

  it('keeps backend-specific readers and spatial calls out of PostgreSQL execution', () => {
    const target = sql.createExecutionContext({ targetDialect: sql.Dialect.PostgreSQL });
    const queries = [
      sql.loadCSV('rows', 'rows.csv'), sql.loadJSON('rows', 'rows.json'),
      sql.loadParquet('rows', 'rows.parquet'), sql.loadSpatial('rows', 'rows.geojson'),
      sql.Query.select({ geometry: sql.geojson('geom') }),
      sql.Query.select({ x: sql.centroidX('geom'), y: sql.centroidY('geom') })
    ];
    for (const query of queries) expect(() => sql.compile([query], target)).toThrow(/unsupported|DuckDB|spatial|reader/i);
    expect(() => sql.compileBatch([sql.loadExtension('spatial')], target)).toThrow(/matching source and target/);
  });
});
