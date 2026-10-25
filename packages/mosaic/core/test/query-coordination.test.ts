import { clauseInterval } from '../src/clause/index.js';
import { DuckDB } from '@uwdata/mosaic-duckdb';
import { asLiteral, column, count, deferred, gte, native, Query, sql, sum, verbatim } from '@uwdata/mosaic-sql';

import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { Coordinator } from '../src/Coordinator.js';
import { makeClient } from '../src/make-client.js';
import { Param } from '../src/Param.js';
import { SqlContext } from '../src/sql-context.js';
import { NodeConnector } from '../src/connectors/NodeConnector.js';
import { Selection } from '../src/Selection.js';
import { clausePoint } from '../src/clause/PointClause.js';

const db = new DuckDB();
const connector = NodeConnector.make(db);
const source = 'native rows';

beforeAll(async () => {
  await db.exec(`CREATE TABLE "${source}" AS SELECT * FROM (VALUES
    (1, 10), (2, 20), (3, 30), (NULL, 40)
  ) t("x value", "y value")`);
});
afterAll(() => db.close());

function setup() {
  const native = new SqlContext();
  const ready = connector.then(connection => new Coordinator(connection, { sql: native, logger: null }));
  return { native, ready };
}

describe('native query coordination', () => {
  it('executes parsed statements and reactive result templates through the native boundary', async () => {
    const { ready } = setup();
    const coordinator = await ready;
    const field = Param.value('x value');
    const lower = Param.value(2);
    const query = sql`WITH rows AS (SELECT * FROM ${column(source)}) SELECT ${column(field)} AS value FROM rows WHERE ${column(field)} >= ${lower} ORDER BY value`;
    try {
      await coordinator.exec(verbatim('CREATE OR REPLACE TEMP TABLE native_template_output AS SELECT 42 AS value'));
      expect(Array.from(await coordinator.query(query))).toEqual([{ value: 2 }, { value: 3 }]);
      field.update('y value');
      lower.update(25);
      expect(Array.from(await coordinator.query(query))).toEqual([{ value: 30 }, { value: 40 }]);
      expect(Array.from(await coordinator.query(native.select([native.alias(asLiteral(7), 'value')])))).toEqual([{ value: 7 }]);
      await expect(coordinator.query(verbatim('DROP TABLE native_template_output'))).rejects.toThrow('result-producing query');
      await expect(coordinator.query(verbatim('SELECT FROM'))).rejects.toThrow(SyntaxError);
    } finally {
      coordinator.clear();
    }
  });

  it('executes reactive count/sum selections through Arrow', async () => {
    const { ready } = setup();
    const coordinator = await ready;
    const selection = Selection.intersect({ cross: true });
    const rows: unknown[] = [];
    const producer = {};
    const client = makeClient({
      coordinator,
      selection,
      query: filter => Query.from(source)
        .select({ n: count(), total: sum('x value') })
        .where(filter ?? []),
      queryResult: table => rows.push(Array.from(table as Iterable<unknown>))
    });
    try {
      await client.pending;
      expect(rows.at(-1)).toEqual([{ n: 4, total: 6 }]);
      selection.update(clauseInterval('x value', [1, 2], { source: producer }));
      await selection.pending('value');
      expect(rows.at(-1)).toEqual([{ n: 2, total: 3 }]);
      selection.update(clausePoint('x value', null, { source: producer }));
      await selection.pending('value');
      expect(rows.at(-1)).toEqual([{ n: 1, total: null }]);
      selection.reset();
      await selection.pending('value');
      expect(rows.at(-1)).toEqual([{ n: 4, total: 6 }]);
      expect(coordinator.preaggregator.enabled).toBe(true);
    } finally {
      client.destroy();
      coordinator.clear();
    }
  });

  it('preserves field identity, union/empty resolution and independent selections', async () => {
    const { native, ready } = setup();
    const coordinator = await ready;
    const field = column('x value');
    const a = clausePoint(field, 1, { source: {} });
    expect(a.fields[0]).toBe(field);
    if (!a.predicate || !('null_safe_eq' in a.predicate)) throw new Error('Expected null-safe predicate.');
    expect(a.predicate.null_safe_eq.left).toBe(field);
    const selection = Selection.union({ empty: true });
    try {
      expect(Array.from(await coordinator.query(Query.from(source).select({ n: count() }).where(selection.predicate() ?? [])))).toEqual([{ n: 0 }]);
      selection.update(a);
      selection.update(clausePoint(field, 3, { source: {} }));
      await selection.pending('value');
      expect(Array.from(await coordinator.query(Query.from(source).select({ n: count() }).where(selection.predicate() ?? [])))).toEqual([{ n: 2 }]);
      expect(selection.clone().clauses).toBe(selection.clauses);
      expect(selection.remove(a.source).clauses).toHaveLength(1);
      const included = Selection.intersect({ include: selection });
      expect(included).toBeInstanceOf(Selection);
      expect(() => new Coordinator(coordinator.databaseConnector()!, { sql: native })).toThrow('already attached');
    } finally {
      coordinator.clear();
    }
  });

  it('reads current scalar and identifier bindings at submission and preserves query reuse', async () => {
    const { ready } = setup();
    const coordinator = await ready;
    const name = Param.value('x value');
    const lower = Param.value(2);
    const query = Query.from(source).select({ n: count() }).where(gte(column(name), asLiteral(lower)));
    try {
      expect(Array.from(await coordinator.query(query))).toEqual([{ n: 2 }]);
      name.update('y value');
      await name.pending('value');
      expect(Array.from(await coordinator.query(query))).toEqual([{ n: 4 }]);
      lower.update(25);
      await lower.pending('value');
      expect(Array.from(await coordinator.query(query))).toEqual([{ n: 2 }]);
      coordinator.clear({ clients: false });
      lower.update(10);
      await lower.pending('value');
      expect(Array.from(await coordinator.query(query))).toEqual([{ n: 4 }]);
    } finally {
      coordinator.clear();
    }
  });

  it('keeps compilation failure reporting safe and includes submitted SQL in execution errors', async () => {
    const { ready } = setup();
    const coordinator = await ready;
    try {
      const metadata = await coordinator.query(Query.describe(Query.from(source).select('x value')));
      expect(Array.from(metadata)[0]).toMatchObject({ column_name: 'x value' });
      await expect(coordinator.query(new Query(asLiteral(1)))).rejects.toThrow('result-producing query');
      expect(Array.from(await coordinator.query('SELECT 1 AS value'))).toEqual([{ value: 1 }]);
      await expect(coordinator.query(Query.from('missing table').select({ n: count() })))
        .rejects.toMatchObject({ sql: expect.stringContaining('missing table') });
      const errors: Error[] = [];
      const client = makeClient({
        coordinator,
        query: () => Query.select({ missing: deferred(() => native.parameter('__mosaic_binding_missing')) }),
        queryError: error => errors.push(error)
      });
      await client.pending;
      expect(errors).toHaveLength(1);
      expect(errors[0].message).toContain('Unresolved native SQL binding');
      client.destroy();
    } finally {
      coordinator.clear();
    }
  });
});
