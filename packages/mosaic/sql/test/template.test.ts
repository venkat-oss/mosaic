import { DuckDB } from '@uwdata/mosaic-duckdb';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import * as sql from '../src/index.js';
import type { SqlRoot } from '../src/index.js';

const db = new DuckDB(':memory:', {}, '');
const execution = sql.createExecutionContext();
const run = (input: SqlRoot) => db.query(sql.compile([input], execution).join(';\n'));

beforeAll(async () => {
  await db.exec('CREATE TABLE native_templates(x INTEGER,y INTEGER,"a.b" INTEGER); INSERT INTO native_templates VALUES(2,4,8),(3,5,9); CREATE TABLE native_templates_other AS SELECT 20 AS x');
});
afterAll(() => db.close());

describe('native SQL templates', () => {
  it('preserves raw string interpolation and SQL escaping', async () => {
    const operator = '+';
    const source = 'native_templates';
    const expression = sql.sql`SELECT x ${operator} y AS value, 'O''Reilly' AS text FROM ${source} ORDER BY x`;
    expect(await run(expression)).toEqual([{ value: 6, text: "O'Reilly" }, { value: 8, text: "O'Reilly" }]);
    expect(await run(sql.sql`SELECT ${sql.literal("O'Reilly")} AS text, ${sql.literal(/O'Reilly/)} AS pattern`))
      .toEqual([{ text: "O'Reilly", pattern: "O'Reilly" }]);
  });

  it('assembles partial fragments at the enclosing complete syntax boundary', async () => {
    const field = sql.column('x');
    const start = sql.sql`SUM(`;
    const end = sql.verbatim(')');
    const expression = sql.sql`SELECT ${start}${field}${end} + ${1} AS value FROM native_templates`;
    expect(sql.collect(expression, node => node === field)).toEqual([field]);
    expect(await run(expression)).toEqual([{ value: '6' }]);
    expect(() => start.expression).toThrow(SyntaxError);
    expect(await run(sql.sql`SELECT ${sql.sql`1 + 2`} * 3 AS value`)).toEqual([{ value: 7 }]);
    expect(await run(sql.sql`SELECT ${sql.add(1, 2)} * 3 AS value`)).toEqual([{ value: 9 }]);
  });

  it('retains native query and field references in relational interpolation', async () => {
    const field = sql.column('x');
    const query = sql.Query.from('native_templates').select({ value: field });
    const expression = sql.sql`SELECT value FROM (${query}) AS derived ORDER BY value`;
    expect(sql.collect(expression, node => node === field)).toEqual([field]);
    expect(await run(expression)).toEqual([{ value: 2 }, { value: 3 }]);
    query.where(sql.gt(field, 2));
    expect(await run(expression)).toEqual([{ value: 3 }]);
    expect(await run(sql.sql`SELECT x FROM ${sql.tableRef('native_templates')!} AS source ORDER BY x`))
      .toEqual([{ x: 2 }, { x: 3 }]);
  });

  it('captures shared scalar values once at submission without construction or analysis reads', async () => {
    let value = 4;
    let reads = 0;
    const parameter = { get value() { ++reads; return value; }, addEventListener() {}, removeEventListener() {} };
    const expression = sql.sql`SELECT ${parameter} + ${parameter} AS value`;
    const other = sql.Query.select({ value: sql.asLiteral(parameter) });
    expect(sql.params(expression)).toEqual([parameter]);
    new sql.StructuralKeyScope().key(expression);
    sql.collectAggregates(expression);
    expect(reads).toBe(0);
    const sources = sql.compile([expression, other], execution);
    expect(reads).toBe(1);
    expect(await db.query(sources[0])).toEqual([{ value: 8 }]);
    expect(await db.query(sources[1])).toEqual([{ value: 4 }]);
    value = 7;
    expect(await run(expression)).toEqual([{ value: 14 }]);
    expect(reads).toBe(2);
  });

  it('keeps live column bindings and original field identity', async () => {
    let value = 'x';
    let reads = 0;
    const parameter = { get value() { ++reads; return value; }, addEventListener() {}, removeEventListener() {} };
    const field = sql.column(parameter);
    const expression = sql.sql`SELECT ${field} AS value FROM native_templates ORDER BY x`;
    expect(sql.collect(expression, node => node === field)).toEqual([field]);
    new sql.StructuralKeyScope().key(expression);
    expect(reads).toBe(0);
    expect(await run(expression)).toEqual([{ value: 2 }, { value: 3 }]);
    value = 'a.b';
    expect(await run(expression)).toEqual([{ value: 8 }, { value: 9 }]);
    expect(reads).toBe(2);
  });

  it('resolves relation identifier bindings at submission', async () => {
    let value = 'native_templates';
    let reads = 0;
    const parameter = { get value() { ++reads; return value; }, addEventListener() {}, removeEventListener() {} };
    const expression = sql.sql`SELECT count(*) AS n FROM ${sql.column(parameter)}`;
    expect(reads).toBe(0);
    expect(await run(expression)).toEqual([{ n: '2' }]);
    value = 'native_templates_other';
    expect(await run(expression)).toEqual([{ n: '1' }]);
    expect(reads).toBe(2);
  });

  it('parses an explicit source dialect and refuses mixed raw fragments', async () => {
    const tag = sql.sql({ sourceDialect: sql.Dialect.MySQL });
    const expression = tag`SELECT \`a.b\` AS value FROM native_templates ORDER BY x`;
    const context = sql.createExecutionContext({ sourceDialect: sql.Dialect.MySQL });
    expect(await db.query(sql.compile([expression], context).join(';\n'))).toEqual([{ value: 8 }, { value: 9 }]);
    expect(() => sql.compile([expression], execution)).toThrow(/execution source dialect/);
    expect(() => sql.compileResolved(sql.snapshotAll([expression]), execution)).toThrow(/execution source dialect/);
    expect(() => sql.compile([sql.Query.from(expression)], execution)).toThrow(/execution source dialect/);
    expect(() => sql.compile([sql.Query.from(expression).clone()], execution)).toThrow(/execution source dialect/);
    expect(() => sql.sql`${expression} + 1`).toThrow(/same source dialect/);
  });

  it('keeps whole-field interpolation identity without assigning its source dialect to the shared field', () => {
    const field = sql.column('x');
    const duck = sql.sql`${field}`;
    const mysql = sql.sql({ sourceDialect: sql.Dialect.MySQL })`${field}`;
    expect(sql.collect(duck, node => node === field)).toEqual([field]);
    expect(sql.collect(mysql, node => node === field)).toEqual([field]);
    expect(() => sql.compile([duck], execution)).not.toThrow();
    expect(() => sql.compile([mysql], execution)).toThrow(/execution source dialect/);
    expect(() => sql.compile([field], execution)).not.toThrow();
    expect(() => sql.compile([mysql], sql.createExecutionContext({ sourceDialect: sql.Dialect.MySQL }))).not.toThrow();
  });

  it('rejects a source mismatch before reading scalar bindings and retains provenance through rewrites', () => {
    let reads = 0;
    const parameter = { get value() { ++reads; return 1; }, addEventListener() {}, removeEventListener() {} };
    const expression = sql.sql({ sourceDialect: sql.Dialect.MySQL })`SELECT ${parameter} AS value`;
    expect(() => sql.compile([expression], execution)).toThrow(/execution source dialect/);
    expect(() => sql.compileBatch(['SELECT 1', expression], execution)).toThrow(/execution source dialect/);
    const rewritten = sql.rewrite(expression, new Map());
    expect(() => sql.compile([rewritten], execution)).toThrow(/execution source dialect/);
    expect(reads).toBe(0);
  });

  it('detects reserved identifiers and rejects structurally invalid interpolation positions', () => {
    expect(() => sql.verbatim('__mosaic_sql_collision').expression).toThrow(/reserved/);
    expect(() => sql.sql`SELECT ${sql.column('x')} AS ${sql.column('name')}`.expression).toThrow(/complete expression or relation/);
    expect(() => sql.sql`SELECT '${sql.asLiteral(1)}'`.expression).toThrow(/outside quoted delimiters/);
    expect(() => sql.verbatim('SELECT FROM').expression).toThrow(SyntaxError);
    expect(() => sql.verbatim('SELECT 1; SELECT 2').expression).toThrow(/one SQL expression/);
    expect(sql.verbatim("'__mosaic_sql_literal'").expression).toHaveProperty('literal');
  });
});

describe('native reference ingress', () => {
  it('preserves quoted multipart identifiers using the SDK parser', () => {
    const column = sql.parseColumnRef('"a.b"."quote""name"');
    expect(sql.columnParts(column)).toEqual(['a.b', 'quote"name']);
    const table = sql.parseTableRef('"catalog.dot"."schema.dot"."table.dot"');
    expect(table.table.catalog?.name).toBe('catalog.dot');
    expect(table.table.schema?.name).toBe('schema.dot');
    expect(table.table.name.name).toBe('table.dot');
    expect(() => sql.parseColumnRef('x + 1')).toThrow(/column reference/);
    expect(() => sql.parseTableRef('x, y')).toThrow(/table reference/);
    expect(() => sql.parseTableRef('x AS y')).toThrow(/table reference/);
  });
});
