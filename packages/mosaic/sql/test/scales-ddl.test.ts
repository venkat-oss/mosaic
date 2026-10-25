import { DuckDB } from '@uwdata/mosaic-duckdb';
import { describe, expect, it } from 'vitest';
import {
  asLiteral, column, compile, compileBatch, cond, createExecutionContext,
  createSchema, createTable, dropSchema, eq, float64, literal, Query,
  scaleTransform, tableRef
} from '../src/index.js';
import type { ScaleOptions } from '../src/index.js';

const context = createExecutionContext({ backend: 'native-scales-ddl-test' });

describe('native scalar and scale closure', () => {
  it('executes conditional chains including a false ternary condition', async () => {
    const base = cond().when(eq('x', 1), literal('one'));
    const derived = base.when(eq('x', 2), literal('two')).else(literal('other'));
    const query = Query.from('numbers').select({ x: 'x', label: derived, otherwise: cond(false, 1, 2) }).orderby('x');
    const db = new DuckDB(':memory:', {}, '');
    try {
      await db.exec('CREATE TABLE numbers(x DOUBLE); INSERT INTO numbers VALUES (1),(2),(3)');
      expect(await db.query(compile([query], context)[0])).toEqual([
        { x: 1, label: 'one', otherwise: 2 },
        { x: 2, label: 'two', otherwise: 2 },
        { x: 3, label: 'other', otherwise: 2 }
      ]);
      expect(await db.query(compile([Query.from('numbers').select({ label: base.else(literal('missing')) }).orderby('x')], context)[0]))
        .toEqual([{ label: 'one' }, { label: 'missing' }, { label: 'missing' }]);
    } finally {
      db.close();
    }
  });

  it('matches JavaScript scale transforms and their SQL inverses', async () => {
    const options: ScaleOptions[] = [
      { type: 'identity' }, { type: 'linear' }, { type: 'log' },
      { type: 'log', base: 10 }, { type: 'log', base: 2 },
      { type: 'symlog', constant: 2 }, { type: 'sqrt' }, { type: 'pow', exponent: 3 }
    ];
    const db = new DuckDB(':memory:', {}, '');
    try {
      await db.exec('CREATE TABLE numbers(x DOUBLE); INSERT INTO numbers VALUES (-9),(-4),(-1),(0),(1),(4),(9),(NULL)');
      for (const option of options) {
        const scale = scaleTransform<number>(option);
        const transformed = scale.sqlApply(column('x'));
        const query = Query.from('numbers').select({ x: 'x', value: transformed, inverse: scale.sqlInvert(transformed) }).orderby('x');
        const rows = await db.query(compile([query], context)[0]);
        for (const row of rows) {
          const expected = row.x == null ? null : scale.apply(Number(row.x));
          if (expected == null || !Number.isFinite(expected)) {
            expect(row.value).toBeNull();
            expect(row.inverse).toBeNull();
          } else {
            expect(row.value).toBeCloseTo(expected, 9);
            expect(row.inverse).toBeCloseTo(scale.invert(expected), 9);
          }
        }
      }
      expect(() => scaleTransform({ type: 'unknown' })).toThrow(/Unrecognized scale/);
    } finally {
      db.close();
    }
  });

  it('uses canonical temporal conversion for Date objects and native literals', async () => {
    const dates = [new Date('0001-01-01T00:00:00.000Z'), new Date('1969-12-31T23:59:59.999Z'), new Date('2020-06-01T12:34:56.789Z')];
    const db = new DuckDB(':memory:', {}, '');
    try {
      for (const type of ['time', 'utc']) {
        const scale = scaleTransform<Date>({ type });
        for (const date of dates) {
          const query = Query.select({ direct: float64(scale.sqlApply(date)), native: float64(scale.sqlApply(asLiteral(date))) });
          expect(await db.query(compile([query], context)[0])).toEqual([{ direct: +date, native: +date }]);
          expect(+scale.invert(scale.apply(date))).toBe(+date);
        }
      }
    } finally {
      db.close();
    }
  });
});

describe('native scratch statements', () => {
  it('executes schema, CTAS, view and drop helpers as reusable Query handles', async () => {
    let reads = 0;
    const parameter = { get value() { return ++reads; }, addEventListener() {}, removeEventListener() {} };
    const source = Query.select({ value: asLiteral(parameter) });
    const data = tableRef(['scratch', 'data'])!;
    const view = tableRef(['scratch', 'view'])!;
    const statements = [createSchema('scratch'), createTable(data, source), createTable(view, source, { view: true })];
    expect(statements.every(statement => statement instanceof Query)).toBe(true);
    expect(reads).toBe(0);
    const db = new DuckDB(':memory:', {}, '');
    try {
      const compiled = compileBatch(statements, context);
      expect(reads).toBe(1);
      await db.exec(compiled.join(';\n'));
      expect(await db.query(compile([Query.from(data)], context)[0])).toEqual([{ value: 1 }]);
      expect(await db.query(compile([Query.from(view)], context)[0])).toEqual([{ value: 1 }]);
      await db.exec(compileBatch([createTable(data, source), createTable(view, source, { view: true })], context).join(';\n'));
      expect(await db.query(compile([Query.from(data)], context)[0])).toEqual([{ value: 1 }]);
      expect(await db.query(compile([Query.from(view)], context)[0])).toEqual([{ value: 1 }]);
      await db.exec(compile([createTable(view, Query.select({ value: literal(9) }), { view: true, replace: true })], context)[0]);
      expect(await db.query(compile([Query.from(view)], context)[0])).toEqual([{ value: 9 }]);
      await db.exec(compile([createSchema('scratch')], context)[0]);
      await expect(db.exec(compile([createSchema('scratch', { strict: true })], context)[0])).rejects.toThrow();
      await db.exec(compile([dropSchema('scratch', { cascade: true })], context)[0]);
      await expect(db.query('SELECT * FROM scratch.data')).rejects.toThrow();
      await db.exec(compile([dropSchema('scratch')], context)[0]);
    } finally {
      db.close();
    }
  });
});
