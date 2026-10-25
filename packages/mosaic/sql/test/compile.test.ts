import { DuckDB } from '@uwdata/mosaic-duckdb';
import { describe, expect, it } from 'vitest';
import {
  asLiteral,
  add,
  and,
  column,
  deepClone,
  gt,
  from,
  literal,
  parseExpression,
  rewrite,
  row_number,
  sql,
  sum,
  asNode,
  compile,
  createExecutionContext,
  Dialect,
  native,
  SqlCompilationError
} from '../src/index.js';

describe('native compilation', () => {
  it('executes a manually constructed filtered aggregate without changing its tree', async () => {
    const value = asNode('a"b');
    const predicate = native.binary('gte', value, asLiteral(2));
    const query = native.select([
      native.alias(native.count(), 'rows'),
      native.alias(native.aggregate('sum', value), 'total'),
      native.alias(native.aggregate('min', value), 'lo'),
      native.alias(native.aggregate('max', value), 'hi')
    ], {
      from: native.from([
        native.table(native.identifier('native rows', true).identifier)
      ]).from,
      where_clause: native.where(predicate).where
    });
    const original = structuredClone(query);
    const context = createExecutionContext({ backend: 'aggregate-test' });
    const db = new DuckDB(':memory:', {}, '');
    try {
      await db.exec('CREATE TABLE "native rows" ("a""b" DOUBLE); INSERT INTO "native rows" VALUES (1), (2), (3), (NULL)');
      const [sql] = compile([query], context);
      const rows = await db.query(sql);
      expect(rows).toHaveLength(1);
      expect(Number(rows[0].rows)).toBe(2);
      expect(rows[0]).toMatchObject({ total: 5, lo: 2, hi: 3 });
      expect(query).toEqual(original);
      expect(predicate.gte.left).toBe(value);
      expect(query.select.where_clause?.this).toBe(predicate);
    } finally {
      db.close();
    }
  });

  it('preserves scalar roots, escaped values and every statement in a batch', async () => {
    const context = createExecutionContext({ backend: 'batch-test' });
    const first = native.select([
      native.alias(asLiteral("O'Reilly"), 'label'),
      native.alias(asLiteral(Infinity), 'missing')
    ]);
    const second = native.select([native.alias(asLiteral(7), 'value')]);
    const statements = compile([first, second], context);
    expect(statements).toHaveLength(2);
    expect(compile([asLiteral("O'Reilly")], context)).toEqual(["'O''Reilly'"]);
    expect(compile([], context)).toEqual([]);
    const db = new DuckDB(':memory:', {}, '');
    try {
      const rows = [];
      for (const sql of statements) rows.push(await db.query(sql));
      expect(rows).toEqual([[{ label: "O'Reilly", missing: null }], [{ value: 7 }]]);
      const columns = native.select([
        native.alias(asNode('literal'), 'identifier'),
        native.alias(asLiteral('literal'), 'value')
      ], { from: native.from([native.table('values_test')]).from });
      await db.exec('CREATE TABLE values_test (literal VARCHAR); INSERT INTO values_test VALUES (\'column value\')');
      expect(await db.query(compile([columns], context)[0])).toEqual([
        { identifier: 'column value', value: 'literal' }
      ]);
    } finally {
      db.close();
    }
  });

  it('preserves scalar SQL coercion without changing native payloads or live bindings', async () => {
    let value = 1;
    let reads = 0;
    const parameter = { get value() { ++reads; return value; }, addEventListener() {}, removeEventListener() {} };
    const field = column('a"b');
    const predicate = and(gt(field, asLiteral(parameter)), gt(field, literal(0)));
    const payload = JSON.stringify(predicate);
    expect(Object.keys(field)).toEqual(['column']);
    expect(Reflect.ownKeys(field)).toEqual(['column']);
    expect(String(field)).toBe('"a""b"');
    expect(literal("O'Reilly").toString()).toBe("'O''Reilly'");
    expect(reads).toBe(0);
    const db = new DuckDB(':memory:', {}, '');
    try {
      await db.exec('CREATE TABLE coercion ("a""b" INTEGER); INSERT INTO coercion VALUES (1), (2), (3)');
      expect(await db.query(`SELECT ${field} AS value FROM coercion WHERE ${predicate} ORDER BY 1`))
        .toEqual([{ value: 2 }, { value: 3 }]);
      expect(reads).toBe(1);
      value = 2;
      expect(await db.query(`SELECT ${field} AS value FROM coercion WHERE ${deepClone(predicate)} ORDER BY 1`))
        .toEqual([{ value: 3 }]);
      expect(reads).toBe(2);
      const replaced = rewrite(predicate, new Map([[field, literal(5)]]));
      expect(await db.query(`SELECT 1 AS value WHERE ${replaced}`)).toEqual([{ value: 1 }]);
      expect(JSON.stringify(predicate)).toBe(payload);
      expect(parseExpression('2 + 3').toString()).toBe('2 + 3');
    } finally { db.close(); }
  });

  it('coerces aggregate, window, template and relation handles through the native compiler', async () => {
    let value = 1;
    let reads = 0;
    const parameter = { get value() { ++reads; return value; }, addEventListener() {}, removeEventListener() {} };
    const field = column('a"b', 'r"q');
    const relation = from('handle rows', 'r"q');
    const aggregate = sum(add(field, asLiteral(parameter))).where(gt(field, asLiteral(parameter)));
    const window = row_number().orderby(field);
    const template = sql`${field} + ${asLiteral(parameter)}`;
    const roots = [aggregate, window, template, relation];
    const payloads = roots.map(handle => JSON.stringify(handle.expression));
    expect(reads).toBe(0);
    expect(String(relation)).toBe('"handle rows" AS "r""q"');
    const db = new DuckDB(':memory:', {}, '');
    try {
      await db.exec('CREATE TABLE "handle rows" ("a""b" DOUBLE); INSERT INTO "handle rows" VALUES (1), (2), (3)');
      expect(await db.query(`SELECT ${aggregate} AS total FROM ${relation}`)).toEqual([{ total: 7 }]);
      expect(reads).toBe(1);
      const rows = await db.query(`SELECT ${template} AS value, ${window} AS position FROM ${relation} ORDER BY 1`);
      expect(rows.map(row => [row.value, Number(row.position)])).toEqual([[2, 1], [3, 2], [4, 3]]);
      expect(reads).toBe(2);
      value = 2;
      expect(await db.query(`SELECT ${aggregate.clone()} AS total FROM ${relation}`)).toEqual([{ total: 5 }]);
      expect(reads).toBe(3);
      expect(roots.map(handle => JSON.stringify(handle.expression))).toEqual(payloads);
      const context = createExecutionContext({ targetDialect: Dialect.PostgreSQL });
      for (const handle of roots) expect(handle.toString(context)).toBe(compile([handle], context)[0]);
    } finally { db.close(); }
  });

  it('keeps independent immutable execution contexts and reports strict target failures', () => {
    const duckdb = createExecutionContext({ backend: 'duckdb-connection', generation: 3 });
    const postgres = createExecutionContext({
      backend: 'postgres-connection',
      targetDialect: Dialect.PostgreSQL,
      generation: 8
    });
    const query = native.describe(native.select([asLiteral(1)]));
    expect(compile([query], duckdb)).toHaveLength(1);
    const options = { pretty: false, unsupportedLevel: 'ignore' };
    try {
      compile([query], postgres, options);
      expect.fail('Unsupported PostgreSQL description compilation must reject.');
    } catch (error) {
      expect(error).toBeInstanceOf(SqlCompilationError);
      if (!(error instanceof SqlCompilationError)) throw error;
      expect(error.context).toBe(postgres);
      expect(error.diagnostic.success).toBe(false);
      expect(error.message).toMatch(/description queries/);
    }
    expect(compile([query], duckdb)).toHaveLength(1);
    expect(duckdb.targetDialect).toBe(Dialect.DuckDB);
    expect(duckdb.generation).toBe(3);
    expect(Object.isFrozen(duckdb)).toBe(true);
    expect(postgres.generation).toBe(8);
  });

  it('copies connection context data and rejects invalid connection generations', () => {
    const options = { backend: 'connection', generation: 1 };
    const context = createExecutionContext(options);
    options.generation = 2;
    expect(context.generation).toBe(1);
    expect(() => createExecutionContext({ generation: -1 })).toThrow(RangeError);
    expect(() => createExecutionContext({ generation: 0.5 })).toThrow(RangeError);
    expect(() => createExecutionContext({ backend: '' })).toThrow(TypeError);
  });
});
