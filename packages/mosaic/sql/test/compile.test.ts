import { DuckDB } from '@uwdata/mosaic-duckdb';
import { DatabaseSync } from 'node:sqlite';
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
import type { SqlSourceSchema } from '../src/index.js';

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

  it('copies and deeply freezes an explicit source schema without freezing caller data', () => {
    const sourceSchema: SqlSourceSchema = {
      tables: [{
        name: 'measurements',
        columns: [{ name: 'a', type: 'INTEGER', references: { table: 'other', column: 'id' } }],
        uniqueKeys: [['a']]
      }]
    };
    const context = createExecutionContext({ sourceSchema });
    expect(context.sourceSchema).toEqual(sourceSchema);
    expect(context.sourceSchema).not.toBe(sourceSchema);
    expect(Object.isFrozen(context.sourceSchema!.tables)).toBe(true);
    expect(Object.isFrozen(context.sourceSchema!.tables[0].columns[0].references)).toBe(true);
    expect(Object.isFrozen(context.sourceSchema!.tables[0].uniqueKeys![0])).toBe(true);
    sourceSchema.tables[0].columns[0].type = 'DOUBLE';
    sourceSchema.tables[0].uniqueKeys![0].push('b');
    expect(context.sourceSchema!.tables[0].columns[0].type).toBe('INTEGER');
    expect(context.sourceSchema!.tables[0].uniqueKeys).toEqual([['a']]);
    expect(Object.isFrozen(sourceSchema.tables[0].columns[0])).toBe(false);
    expect(() => { context.sourceSchema!.tables[0].columns[0].type = 'DOUBLE'; }).toThrow(TypeError);
  });

  it('uses source column types for native division without mutating trees or rereading live bindings', async () => {
    for (const type of ['INTEGER', 'DOUBLE']) {
      let minimum = 0;
      let reads = 0;
      const parameter = { get value() { ++reads; return minimum; }, addEventListener() {}, removeEventListener() {} };
      const query = native.select([
        native.alias(native.scalarBinary('int_div', column('a'), column('b')), 'value')
      ], {
        from: native.from([native.table('measurements')]).from,
        where_clause: native.where(native.binary('gt', column('id'), asLiteral(parameter))).where,
        order_by: native.orderBy([native.ordered(column('id')).ordered]).order_by
      });
      const payload = JSON.stringify(query);
      const sourceSchema: SqlSourceSchema = {
        tables: [{ name: 'measurements', columns: [
          { name: 'id', type: 'INTEGER' }, { name: 'a', type }, { name: 'b', type }
        ] }]
      };
      const target = createExecutionContext({ targetDialect: Dialect.SQLite, sourceSchema });
      const source = createExecutionContext({ sourceSchema });
      const db = new DuckDB(':memory:', {}, '');
      const sqlite = new DatabaseSync(':memory:');
      try {
        const setup = `CREATE TABLE measurements(id INTEGER,a ${type},b ${type}); INSERT INTO measurements VALUES (1,7,2),(2,-7,2)`;
        await db.exec(setup);
        sqlite.exec(setup);
        const statements = compile([query, query], target);
        expect(reads).toBe(1);
        expect(statements[0]).toBe(statements[1]);
        const rows = sqlite.prepare(statements[0]).all().map(row => ({ ...row }));
        expect(rows).toEqual(await db.query(compile([query], source)[0]));
        expect(rows.map(row => row.value)).toEqual(type === 'INTEGER' ? [3, -3] : [3.5, -3.5]);
        expect(reads).toBe(2);
        minimum = 1;
        expect(sqlite.prepare(compile([query], target)[0]).all().map(row => row.value))
          .toEqual(type === 'INTEGER' ? [-3] : [-3.5]);
        expect(reads).toBe(3);
        expect(JSON.stringify(query)).toBe(payload);
      } finally {
        sqlite.close();
        db.close();
      }
    }
  });

  it.each(['INTEGER', 'DOUBLE'])('preserves %s math result types before native integer division', async type => {
    const value = column('a');
    const operands = {
      abs: native.scalar('abs', value), floor: native.floor(value), ceil: native.ceil(value),
      round: native.round(value), sign: native.scalar('sign', value)
    };
    const query = native.select(Object.entries(operands).map(([name, operand]) =>
      native.alias(native.scalarBinary('int_div', operand, literal(2)), name)
    ), {
      from: native.from([native.table('measurements')]).from,
      order_by: native.orderBy([native.ordered(column('id')).ordered]).order_by
    });
    const payload = JSON.stringify(query);
    const sourceSchema: SqlSourceSchema = {
      tables: [{ name: 'measurements', columns: [{ name: 'id', type: 'INTEGER' }, { name: 'a', type }] }]
    };
    const target = createExecutionContext({ targetDialect: Dialect.SQLite, sourceSchema });
    const source = createExecutionContext({ sourceSchema });
    const db = new DuckDB(':memory:', {}, '');
    const sqlite = new DatabaseSync(':memory:');
    try {
      const input = type === 'INTEGER' ? '7' : '7.5';
      const setup = `CREATE TABLE measurements(id INTEGER,a ${type}); INSERT INTO measurements VALUES (1,${input}),(2,-${input})`;
      await db.exec(setup);
      sqlite.exec(setup);
      const expected = await db.query(compile([query], source)[0]);
      const actual = sqlite.prepare(compile([query], target)[0]).all().map(row => ({ ...row }));
      expect(actual).toEqual(expected);
      expect(actual.map(row => row.sign)).toEqual([0, 0]);
      expect(JSON.stringify(query)).toBe(payload);
    } finally {
      sqlite.close();
      db.close();
    }
  });
});
