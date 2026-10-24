import { DuckDB } from '@uwdata/mosaic-duckdb';
import { describe, expect, it } from 'vitest';
import * as legacy from '../src/index.js';
import {
  asLiteral, asNode, BindingScope, cloneExpression, column, compile, compileBatch,
  count, createExecutionContext, deferred, Dialect, fields, gt, inspectSelect, isNotDistinct,
  LegacyInputAdapter, literal, native, params, Query, snapshot, snapshotAll, sum
} from '../src/native/index.js';
import { stubParam } from './util/stub-param.js';

const context = createExecutionContext({ backend: 'native-query-test' });

describe('native query authoring', () => {
  it('distinguishes aliases named after native variants from raw native expressions', async () => {
    const parameter = stubParam(1);
    const query = Query.from({ table: 'data' })
      .select({ first: asLiteral(parameter) })
      .select({ second: literal(2) })
      .select({ table: column('x', 'table') })
      .select({ sum: literal(4) })
      .select({ literal: 5 });
    const aggregate = Query.from(native.table('data')).select({ sum: sum('x') });
    const nullQuery = Query.select(native.literal(null));
    expect(inspectSelect(nullQuery).expressions).toEqual([native.literal(null)]);
    const db = new DuckDB(':memory:', {}, '');
    try {
      await db.exec('CREATE TABLE data (x INTEGER); INSERT INTO data VALUES (7)');
      expect(await db.query(compile([query], context)[0])).toEqual([
        { first: 1, second: 2, table: 7, sum: 4, literal: 5 }
      ]);
      parameter.value = 9;
      expect((await db.query(compile([query], context)[0]))[0].first).toBe(9);
      expect(Number((await db.query(compile([aggregate], context)[0]))[0].sum)).toBe(7);
      expect(compile([nullQuery], context)).toEqual(['SELECT NULL']);
    } finally {
      db.close();
    }
  });

  it('reads scalar and identifier parameters at submission and preserves field identity', async () => {
    const name = stubParam('x');
    const selected = stubParam(1);
    const field = column(name);
    const predicate = isNotDistinct(field, asLiteral(selected));
    const query = Query.from('data').select({ rows: count(), total: sum(field) }).where(predicate);
    expect(fields(query)[0]).toMatchObject({ node: field, column: 'x' });
    expect(params(query)).toEqual([name, selected]);
    const db = new DuckDB(':memory:', {}, '');
    try {
      await db.exec('CREATE TABLE data (x DOUBLE, y DOUBLE); INSERT INTO data VALUES (1,10),(2,20),(NULL,30)');
      const first = await db.query(compile([query], context)[0]);
      expect(Number(first[0].rows)).toBe(1);
      expect(first[0].total).toBe(1);
      name.value = 'y';
      selected.value = 20;
      expect(fields(query)[0]).toMatchObject({ node: field, column: 'y' });
      const resolved = snapshot(query);
      const select = inspectSelect(resolved);
      const projection = select.expressions[1];
      const where = select.where_clause!.this;
      expect('alias' in projection && 'sum' in projection.alias.this
        && 'null_safe_eq' in where && projection.alias.this.sum.this === where.null_safe_eq.left).toBe(true);
      const second = await db.query(compile([query], context)[0]);
      expect(Number(second[0].rows)).toBe(1);
      expect(second[0].total).toBe(20);
      expect('parameter' in field).toBe(true);
    } finally {
      db.close();
    }
  });

  it('keeps mutable query methods and clone edits independent with shared native fields', () => {
    const value = stubParam(1);
    const field = column('x');
    const predicate = gt(field, asLiteral(value));
    const original = Query.select({ value: field }).from('data').where(predicate);
    expect(original.select({ marker: literal(0) })).toBe(original);
    const cloned = original.clone().select({ marker: literal(false) }).where(gt(field, 2)).limit(3);
    expect(inspectSelect(original).expressions).toHaveLength(2);
    expect(inspectSelect(cloned).expressions).toHaveLength(2);
    expect(inspectSelect(original).limit).toBeNull();
    expect(inspectSelect(original).where_clause!.this).toBe(predicate);
    expect(fields(original)[0].node).toBe(fields(cloned)[0].node);
    const copy = cloneExpression(original);
    const copiedField = fields(copy)[0].node;
    expect(copiedField).not.toBe(field);
    expect(params(copy)).toEqual([value]);
    value.value = 7;
    expect(compile([copy], context)[0]).toContain('> 7');
    expect(compile([original], context)[0]).toContain('> 7');
  });

  it('reads one parameter value once across a mixed exec batch and retains every output', async () => {
    let reads = 0;
    const value = {
      get value() { return ++reads; },
      addEventListener() {},
      removeEventListener() {}
    };
    const first = Query.select({ value: asLiteral(value) });
    const second = Query.select({ value: asLiteral(value) });
    const sql = compileBatch([first, null, 'SELECT 99 AS value', second], context);
    expect(reads).toBe(1);
    expect(sql).toHaveLength(3);
    const db = new DuckDB(':memory:', {}, '');
    try {
      const rows = [];
      for (const statement of sql) rows.push(await db.query(statement));
      expect(rows).toEqual([[{ value: 1 }], [{ value: 99 }], [{ value: 1 }]]);
    } finally {
      db.close();
    }
    const postgres = createExecutionContext({ targetDialect: Dialect.PostgreSQL });
    expect(() => compileBatch([first, 'SELECT 1'], postgres)).toThrow(/matching source and target/);
  });

  it('rebases colliding binding IDs while retaining binding kind and parameter identity', () => {
    const leftParam = stubParam(1);
    const rightParam = stubParam(2);
    const first = new BindingScope().bind({
      kind: 'scalar', parameters: [leftParam], resolve: read => literal(read(leftParam))
    });
    const second = new BindingScope().bind({
      kind: 'scalar', parameters: [rightParam], resolve: read => literal(read(rightParam))
    });
    if (!('parameter' in first) || !('parameter' in second)) throw new Error('Expected parameter slots.');
    second.parameter.name = first.parameter.name;
    const owner = new BindingScope();
    const tree = native.binary('eq', first, second);
    const adopted = owner.adopt(tree);
    if (!('eq' in adopted) || !('parameter' in adopted.eq.left) || !('parameter' in adopted.eq.right)) {
      throw new Error('Expected rebased equality.');
    }
    expect(adopted.eq.left.parameter.name).not.toBe(adopted.eq.right.parameter.name);
    expect(params(adopted)).toEqual([leftParam, rightParam]);
    expect(compile([adopted], context)).toEqual(['1 = 2']);
    expect(() => snapshot(native.parameter('__mosaic_binding_unresolved'))).toThrow(/Unresolved/);
    owner.reset();
    expect(compile([owner.adopt(tree)], context)).toEqual(['1 = 2']);
  });

  it('resolves deferred expressions late and rejects cycles without poisoning later snapshots', () => {
    const value = stubParam(1);
    const expression = deferred(read => literal(read(value)), [value]);
    const query = Query.select({ value: expression });
    value.value = 2;
    expect(compile([query], context)).toEqual(['SELECT 2 AS "value"']);
    let cyclic = literal(0);
    cyclic = deferred(() => cyclic);
    expect(() => snapshot(cyclic)).toThrow(/Cyclic native SQL binding/);
    expect(snapshotAll([literal(1), literal(2)])).toEqual([native.literal(1), native.literal(2)]);
  });

  it('preserves UTC date and scalar edge values in native literals', () => {
    const date = new Date('0001-01-01T00:00:00.000Z');
    const timestamp = new Date('1969-12-31T23:59:59.999Z');
    expect(literal(date)).toEqual(native.literal({ literal_type: 'date', value: '0001-01-01' }));
    expect(literal(timestamp)).toEqual(native.literal({ literal_type: 'timestamp', value: '1969-12-31 23:59:59.999' }));
    for (const value of [undefined, NaN, Infinity, -Infinity, new Date(NaN)]) {
      expect(literal(value)).toEqual(native.literal(null));
    }
    expect(literal(/O'Reilly/)).toEqual(native.literal("O'Reilly"));
    expect(literal(9007199254740993n)).toEqual(native.numeric('9007199254740993'));
  });
});

describe('one-way legacy input adapter', () => {
  it('rejects legacy nodes at native query authoring boundaries', () => {
    const field = legacy.column('x');
    const table = legacy.Query.from('data')._from[0];
    for (const value of [field, { value: field }]) {
      expect(() => Reflect.apply(Query.select, Query, [value])).toThrow(TypeError);
    }
    for (const value of [table, { value: table }]) {
      expect(() => Reflect.apply(Query.from, Query, [value])).toThrow(TypeError);
    }
  });

  it('shares one conversion memo across clause fields, predicates and query consumers', async () => {
    const field = legacy.column('x');
    const predicate = legacy.isBetween(field, [1, 2]);
    const adapter = new LegacyInputAdapter();
    const clause = adapter.clause({ fields: [field], predicate, value: [1, 2], source: {} });
    const oldQuery = legacy.Query.select({ value: field }).from('data').where(predicate);
    const query = adapter.query(oldQuery);
    expect(fields(query)[0].node).toBe(clause.fields[0]);
    expect(fields(clause.predicate!)[0].node).toBe(clause.fields[0]);
    expect(adapter.expression(field)).toBe(clause.fields[0]);
    expect(() => asNode(field)).toThrow(TypeError);
    const db = new DuckDB(':memory:', {}, '');
    try {
      await db.exec('CREATE TABLE data (x DOUBLE); INSERT INTO data VALUES (0),(1),(2),(3)');
      expect(await db.query(compile([query], context)[0])).toEqual([{ value: 1 }, { value: 2 }]);
      oldQuery.setWhere(legacy.gt(field, 2));
      expect(await db.query(compile([adapter.query(oldQuery)], context)[0])).toEqual([{ value: 3 }]);
    } finally {
      db.close();
    }
    adapter.reset();
    expect(adapter.expression(field)).not.toBe(clause.fields[0]);
  });

  it('retains live legacy scalar/identifier parameters and null-safe point predicates', async () => {
    const name = stubParam('x');
    const value = stubParam(null);
    const field = legacy.column(name);
    const predicate = legacy.isNotDistinct(field, legacy.asLiteral(value));
    const adapter = new LegacyInputAdapter();
    const clause = adapter.clause({ fields: [field], predicate });
    const query = Query.select({ value: clause.fields[0] }).from('data').where(clause.predicate);
    const db = new DuckDB(':memory:', {}, '');
    try {
      await db.exec('CREATE TABLE data (x DOUBLE, y DOUBLE); INSERT INTO data VALUES (NULL,10),(2,NULL)');
      expect(await db.query(compile([query], context)[0])).toEqual([{ value: null }]);
      name.value = 'y';
      value.value = 10;
      expect(await db.query(compile([query], context)[0])).toEqual([{ value: 10 }]);
      expect(params(query)).toEqual([name, value]);
    } finally {
      db.close();
    }
  });
});
