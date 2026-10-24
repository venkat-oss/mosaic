import { DuckDB } from '@uwdata/mosaic-duckdb';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import * as sql from '../src/native/index.js';
import type { SqlRoot } from '../src/native/index.js';

const db = new DuckDB(':memory:', {}, '');
const context = sql.createExecutionContext();
const execute = (query: SqlRoot) => db.query(sql.compile([query], context)[0]);

beforeAll(async () => {
  await db.exec('CREATE TABLE native_bins(x DOUBLE,y DOUBLE,w DOUBLE); INSERT INTO native_bins VALUES (0.25,0.5,8)');
  await db.exec('CREATE TABLE native_histogram(x DOUBLE); INSERT INTO native_histogram VALUES (-1.5),(0),(0.5),(1),(1.5),(2),(NULL)');
  await db.exec("CREATE TABLE native_series(x INTEGER,y INTEGER,g VARCHAR); INSERT INTO native_series VALUES (0,10,'a'),(1,2,'a'),(2,20,'a'),(3,9,'a'),(4,8,'a'),(5,5,'a')");
  await db.exec("CREATE TABLE native_lines(x INTEGER,y INTEGER,g VARCHAR); INSERT INTO native_lines VALUES (0,0,'a'),(1,1,'a'),(2,2,'a'),(3,3,'a'),(0,0,'b'),(1,1,'b'),(2,2,'b'),(3,3,'b')");
});
afterAll(() => db.close());

describe('native numeric, text and temporal expressions', () => {
  it('executes finite checks, null-aware extrema and scalar rounding', async () => {
    expect(await execute(sql.Query.select({
      nan: sql.isNaN(sql.cast(sql.literal('NaN'), 'DOUBLE')),
      infinite: sql.isInfinite(sql.cast(sql.literal('-Infinity'), 'DOUBLE')),
      finite: sql.isFinite(sql.cast(sql.literal('Infinity'), 'DOUBLE')),
      date: sql.isFinite(sql.asLiteral(new Date('2024-01-01T00:00:00Z'))), empty: sql.isFinite(null),
      largest: sql.greatest(null, 1, 3), smallest: sql.least(null, 1, 3), truncated: sql.trunc(-1.8),
      rounded: sql.round(1.25, 1), logarithm: sql.log(100)
    }))).toEqual([{
      nan: true, infinite: true, finite: false, date: true, empty: null,
      largest: 3, smallest: 1, truncated: '-1', rounded: '1.3', logarithm: 2
    }]);
    expect(await execute(sql.Query.select({ valid: sql.tryCast(sql.literal('12'), 'INTEGER'), invalid: sql.tryCast(sql.literal('oops'), 'INTEGER') })))
      .toEqual([{ valid: 12, invalid: null }]);
    expect(() => sql.compile([sql.tryCast(sql.literal('oops'), 'INTEGER')], sql.createExecutionContext({ targetDialect: sql.Dialect.PostgreSQL }))).toThrow(/cast|unsupported/i);
  });

  it('keeps string arguments literal, preserves regex flags and resolves live patterns', async () => {
    let pattern = 'b';
    let reads = 0;
    const parameter = { get value() { ++reads; return pattern; }, addEventListener() {}, removeEventListener() {} };
    const text = sql.literal('Abc');
    const query = sql.Query.select({
      match: sql.regexp_matches(text, parameter, 'i'), contains: sql.contains(text, parameter),
      prefix: sql.prefix(text, 'A'), suffix: sql.suffix(text, 'c'), lower: sql.lower(text),
      upper: sql.upper(text), length: sql.length(text),
      escaped: sql.contains(sql.literal("O'Reilly"), "'"),
      collated: sql.eq(sql.collate(text, 'NOCASE'), sql.literal('abc'))
    });
    expect(await execute(query)).toEqual([{
      match: true, contains: true, prefix: true, suffix: true, lower: 'abc', upper: 'ABC',
      length: '3', escaped: true, collated: true
    }]);
    expect(reads).toBe(1);
    pattern = '^z';
    expect((await execute(query))[0].match).toBe(false);
    expect(reads).toBe(2);
  });

  it('preserves calendar anchors, leap-day comparisons, zones and frame intervals', async () => {
    const date = sql.cast(sql.literal('2024-02-29'), 'DATE');
    const week = sql.cast(sql.literal('2024-01-10'), 'DATE');
    expect(await execute(sql.Query.select({
      quarter: sql.cast(sql.dateBin(date, 'month', 3), 'VARCHAR'),
      fortnight: sql.cast(sql.dateBin(week, 'week', 2), 'VARCHAR'),
      month: sql.cast(sql.dateMonth(date), 'VARCHAR'),
      monthDay: sql.cast(sql.dateMonthDay(date), 'VARCHAR'),
      day: sql.cast(sql.dateDay(date), 'VARCHAR'),
      offset: sql.cast(sql.binDate(date, [0, 0], { interval: 'month', offset: 1 }), 'VARCHAR'),
      zoned: sql.epoch_ms(sql.timezone('America/New_York', sql.cast(sql.literal('2024-03-10 01:30:00'), 'TIMESTAMP')))
    }))).toEqual([{
      quarter: '2024-01-01', fortnight: '2024-01-01', month: '2012-02-01', monthDay: '2012-02-29',
      day: '2012-01-29', offset: '2024-03-01 00:00:00', zoned: String(Date.parse('2024-03-10T06:30:00Z'))
    }]);
    const data = sql.Query.select({
      ts: sql.cast(sql.literal('2024-01-01'), 'TIMESTAMP'), value: sql.literal(1)
    });
    const framed = sql.Query.from(data).select({
      value: sql.sum('value').orderby('ts').frame(sql.frameRange([sql.preceding(sql.days(1)), sql.currentRow()]))
    });
    expect(await execute(framed)).toEqual([{ value: '1' }]);
    expect(() => sql.compile([sql.dateBin(date, 'month')], sql.createExecutionContext({ targetDialect: sql.Dialect.PostgreSQL }))).toThrow(/unsupported|time.bucket/i);
  });
});

describe('native binning and series transforms', () => {
  it('executes signed histogram bins and applies offsets after flooring', async () => {
    const query = (offset = 0) => sql.Query.from('native_histogram').select({
      bin: sql.binHistogram('x', [-2, 2], { step: 1, offset }), count: sql.count()
    }).where(sql.isNotNull('x')).groupby('bin').orderby('bin');
    expect(await execute(query())).toEqual([
      { bin: -2, count: '1' }, { bin: 0, count: '2' }, { bin: 1, count: '2' }, { bin: 2, count: '1' }
    ]);
    expect(await execute(query(1))).toEqual([
      { bin: -1, count: '1' }, { bin: 1, count: '2' }, { bin: 2, count: '2' }, { bin: 3, count: '1' }
    ]);
    expect(await execute(sql.Query.select({
      forward: sql.bin1d(2, 1, 5, 4), reverse: sql.bin1d(2, 1, 5, 4, true),
      degenerate: sql.binHistogram(2, [2, 2], { offset: 1 })
    }))).toEqual([{ forward: 1, reverse: 3, degenerate: 3 }]);
    const log = sql.scaleTransform<number>({ type: 'log', base: 10 });
    const bins = await execute(sql.Query.from('native_series').select({ bin: sql.binHistogram(sql.mul(sql.add('x', 1), 10), [10, 1000], { step: 1 }, log) }).orderby('x'));
    for (const row of bins) expect(row.bin).toBeCloseTo(10, 9);
  });

  it('distributes linear weights across adjacent bins and honors zero weights', async () => {
    const query = sql.Query.from('native_bins');
    expect(await execute(sql.binLinear1d(query, 'x', 'w').orderby('index'))).toEqual([
      { index: 0, density: 6 }, { index: 1, density: 2 }
    ]);
    expect(await execute(sql.binLinear2d(query, 'x', 'y', 'w', 10).orderby('index'))).toEqual([
      { index: 0, density: 3 }, { index: 1, density: 1 }, { index: 10, density: 3 }, { index: 11, density: 1 }
    ]);
    expect(await execute(sql.binLinear1d(query, 'x', 0))).toEqual([]);
    expect(await execute(sql.binLinear2d(query, 'x', 'y', 0, 10))).toEqual([]);
    expect(sql.selectEntries(query).map(entry => entry.alias)).toEqual([undefined]);
  });

  it('retains M4 endpoints and extrema through a materialized CTE and qualified source', async () => {
    const group = sql.column('g', 's');
    const input = sql.Query.from(sql.from('native_series', 's')).select(sql.column('x', 's'), sql.column('y', 's'), group);
    const query = sql.m4(input, sql.div(sql.column('x', 's'), 6), 'x', 'y', [group]);
    expect(await execute(query)).toEqual([
      { x: 0, y: 10, g: 'a' }, { x: 1, y: 2, g: 'a' }, { x: 2, y: 20, g: 'a' }, { x: 5, y: 5, g: 'a' }
    ]);
    expect(sql.selectEntries(input).map(entry => entry.alias)).toEqual(['x', 'y', 'g']);
  });

  it('rasterizes real line series using exclusive range and native UNNEST', async () => {
    for (const normalize of [false, true]) {
      const input = sql.Query.from('native_lines').select('g');
      const query = sql.lineDensity(input, 'x', 'y', ['g'], 4, 4, [], normalize).orderby('index');
      const density = normalize ? 2 : '2';
      expect(await execute(query)).toEqual([
        { index: 0, density }, { index: 5, density }, { index: 10, density }, { index: 15, density }
      ]);
    }
  });
});
