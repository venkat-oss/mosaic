import { DuckDB } from '@uwdata/mosaic-duckdb';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import * as sql from '../src/index.js';
import { stubParam } from './util/stub-param.js';

const db = new DuckDB(':memory:', {}, '');
const context = sql.createExecutionContext();
const execute = (query: sql.SqlRoot) => db.query(sql.compile([query], context)[0]);
beforeAll(() => db.exec(`
  CREATE TABLE helper_rows(x INTEGER,y INTEGER,label VARCHAR);
  INSERT INTO helper_rows VALUES (1,1,'a'),(2,3,'b'),(NULL,3,NULL);
`));
afterAll(() => db.close());

describe('public SQL helpers', () => {
  it('retains reference conversions and distinguishes literal strings from parsed SQL', async () => {
    const table = sql.asTableRef('helper_rows');
    expect(sql.asTableRef(table)).toBe(table);
    expect(sql.asTableRef()).toBeUndefined();
    const relation = sql.asFrom(table);
    expect(sql.asFrom(relation)).toBe(relation);
    expect(sql.isTableRef(table)).toBe(true);
    expect(sql.isTableRef(relation)).toBe(true);
    expect(sql.isColumnRef(table)).toBe(false);
    expect(sql.isColumnRef(sql.column('x'))).toBe(true);
    expect(sql.isColumnRef(sql.literal('x'))).toBe(false);
    expect(await execute(sql.Query.from(relation).select({
      parsed: sql.asVerbatim('x + 1'), literal: sql.asLiteral('x + 1'),
      passed: sql.asVerbatim(sql.add('x', 2))
    }).where(sql.eq('x', 1)))).toEqual([{ parsed: 2, literal: 'x + 1', passed: 3 }]);
    const quoted = sql.asTableRef(['schema.with.dots', 'a"b']);
    expect(sql.compile([quoted], context)).toEqual(['"schema.with.dots"."a""b"']);
  });

  it('collects unique canonical free columns, expansions and replacement dependencies', () => {
    const left = sql.column('x', ['a.b']);
    const right = sql.column('x', ['a', 'b']);
    const combined = sql.add(sql.add(left, sql.column('x', ['a.b'])), right);
    expect(sql.collectColumns(combined)).toEqual([left, right]);
    const selected = sql.collectColumns(sql.columns(['x', 'y']));
    expect(selected.map(sql.columnParts)).toEqual([['x'], ['y']]);
    expect(sql.collectColumns(sql.columns('^x')).map(sql.columnParts)).toEqual([['*']]);
    expect(sql.collectColumns(sql.positionalRef(2)).map(sql.columnParts)).toEqual([['*']]);
    const star = sql.star('r', { exclude: ['y'], rename: { label: 'name' }, replace: { x: sql.add('x', 1) } });
    expect(sql.collectColumns(star).map(sql.columnParts)).toEqual([['r', '*'], ['x']]);
    const captured = sql.column('x', 'source');
    const body = sql.lambda('x', value => sql.add(value, captured));
    expect(sql.collectColumns(body)).toEqual([captured]);
  });

  it('collects shared live parameters without freezing scalar reads', async () => {
    const name = stubParam('x');
    let reads = 0;
    const value = { get value() { ++reads; return 1; }, addEventListener() {}, removeEventListener() {} };
    const field = sql.column(name);
    const expression = sql.add(field, sql.asLiteral(value));
    expect(sql.collectColumns(expression)).toEqual([field]);
    expect(sql.collectParams(expression)).toEqual([name, value]);
    expect(sql.isParamLike(name)).toBe(true);
    expect(sql.isParamLike(sql.literal(1))).toBe(false);
    expect(reads).toBe(0);
    expect(await execute(sql.Query.from('helper_rows').select({ value: expression }).where(sql.eq('x', 1))))
      .toEqual([{ value: 2 }]);
    expect(reads).toBe(1);
    name.value = 'y';
    expect(sql.collectColumns(expression)).toEqual([field]);
    expect(sql.fields(expression)[0].column).toBe('y');
    expect(reads).toBe(1);
  });

  it('preserves column-valued IN arguments and explicit null inclusion', async () => {
    const query = sql.Query.from('helper_rows').select({
      x: 'x', column: sql.isIn('x', ['y']), literal: sql.isIn('label', [sql.literal('a')]),
      empty: sql.isIn('x', []), distinct: sql.isInDistinct('x', ['y']),
      includeNull: sql.isInDistinct('x', [1, null]), onlyNull: sql.isInDistinct('x', [null])
    }).orderby(sql.asc('x', false));
    expect(await execute(query)).toEqual([
      { x: 1, column: true, literal: true, empty: false, distinct: true, includeNull: true, onlyNull: false },
      { x: 2, column: false, literal: false, empty: false, distinct: false, includeNull: false, onlyNull: false },
      { x: null, column: null, literal: null, empty: false, distinct: null, includeNull: true, onlyNull: true }
    ]);
    expect(await execute(sql.Query.select({ value: sql.isInDistinct(null, []) }))).toEqual([{ value: false }]);
  });

  it('executes scalar arithmetic, comparisons, null logic and casts', async () => {
    const [row] = await execute(sql.Query.select({
      add: sql.add(7, 2), sub: sql.sub(7, 2), mul: sql.mul(7, 2), div: sql.div(7, 2),
      mod: sql.mod(7, 2), power: sql.pow(3, 2), eq: sql.eq(1, 1), neq: sql.neq(1, 2),
      lt: sql.lt(1, 2), lte: sql.lte(2, 2), gt: sql.gt(2, 1), gte: sql.gte(2, 2),
      not: sql.not(false), and: sql.and(true, null, true), or: sql.or(false, null, true),
      emptyAnd: sql.and(), emptyOr: sql.or(), missing: sql.isNull(null), present: sql.isNotNull(1),
      distinct: sql.isDistinct(null, 1), equalNull: sql.isNotDistinct(null, null),
      between: sql.isBetween(2, [1, 2]), outside: sql.isNotBetween(3, [1, 2]),
      noBounds: sql.isBetween(3, null), noExcludedBounds: sql.isNotBetween(3, null),
      coalesce: sql.coalesce(null, 2), nullif: sql.nullif(2, 2), int: sql.int32(2.2),
      float: sql.float32(2), double: sql.float64(2)
    }));
    expect(row).toEqual({
      add: 9, sub: 5, mul: 14, div: 3.5, mod: 1, power: 9,
      eq: true, neq: true, lt: true, lte: true, gt: true, gte: true,
      not: true, and: true, or: true, emptyAnd: true, emptyOr: false,
      missing: true, present: true, distinct: true, equalNull: true,
      between: true, outside: true, noBounds: true, noExcludedBounds: true,
      coalesce: 2, nullif: null, int: 2, float: 2, double: 2
    });
    await expect(execute(sql.Query.select({ invalid: sql.cast(sql.literal('bad'), 'INTEGER') })))
      .rejects.toThrow(/convert|conversion/i);
  });

  it('applies explicit null ordering in either direction', async () => {
    for (const [order, expected] of [
      [sql.asc('x', true), [null, 1, 2]], [sql.asc('x', false), [1, 2, null]],
      [sql.desc('x', true), [null, 2, 1]], [sql.desc('x', false), [2, 1, null]]
    ] as const) {
      const rows = await execute(sql.Query.from('helper_rows').select('x').orderby(order));
      expect(rows.map(row => row.x)).toEqual(expected);
    }
  });

  it('executes every interval helper with calendar and subsecond precision', async () => {
    const date = sql.cast(sql.literal('2024-01-31'), 'TIMESTAMP');
    const format = (value: sql.ExprValue) => sql.cast(sql.add(date, value), 'VARCHAR');
    expect(await execute(sql.Query.select({
      years: format(sql.years(1)), months: format(sql.months(1)), days: format(sql.days(2)),
      hours: format(sql.hours(3)), minutes: format(sql.minutes(4)), seconds: format(sql.seconds(5)),
      milliseconds: format(sql.milliseconds(6)), microseconds: format(sql.microseconds(7)),
      interval: format(sql.interval('DAY', -1))
    }))).toEqual([{
      years: '2025-01-31 00:00:00', months: '2024-02-29 00:00:00', days: '2024-02-02 00:00:00',
      hours: '2024-01-31 03:00:00', minutes: '2024-01-31 00:04:00', seconds: '2024-01-31 00:00:05',
      milliseconds: '2024-01-31 00:00:00.006', microseconds: '2024-01-31 00:00:00.000007',
      interval: '2024-01-30 00:00:00'
    }]);
  });
});
