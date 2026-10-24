import { DuckDB } from '@uwdata/mosaic-duckdb';
import { Query as LegacyQuery, count as legacyCount, column as legacyColumn } from '@uwdata/mosaic-sql';
import { asLiteral, column, count, deferred, gte, native, Query, sum } from '@uwdata/mosaic-sql/native';
import type { SqlExpression } from '@uwdata/mosaic-sql/native';
import { afterAll, beforeAll, describe, expect, it, vi } from 'vitest';
import { Coordinator } from '../src/Coordinator.js';
import { makeClient } from '../src/make-client.js';
import { Param } from '../src/Param.js';
import { NativeSqlContext } from '../src/native-sql.js';
import { NodeConnector } from '../src/connectors/NodeConnector.js';
import { MosaicClient } from '../src/MosaicClient.js';
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
  const native = new NativeSqlContext();
  const ready = connector.then(connection => new Coordinator(connection, { native, logger: null }));
  return { native, ready };
}

describe('native query coordination', () => {
  it('executes reactive count/sum selections through Arrow without changing the legacy coordinator', async () => {
    const { native, ready } = setup();
    const coordinator = await ready;
    const selection = native.selection({ cross: true });
    const rows: unknown[] = [];
    const producer = {};
    const client = makeClient<SqlExpression>({
      coordinator,
      selection,
      query: filter => Query.from(source)
        .select({ n: count(), total: sum('x value') })
        .where(filter ?? []),
      queryResult: table => rows.push(Array.from(table as Iterable<unknown>))
    });
    const legacy = new Coordinator(await connector, { logger: null });
    try {
      await client.pending;
      expect(rows.at(-1)).toEqual([{ n: 4, total: 6 }]);
      selection.update(native.interval('x value', [1, 2], { source: producer }));
      await selection.pending('value');
      expect(rows.at(-1)).toEqual([{ n: 2, total: 3 }]);
      selection.update(native.point('x value', null, { source: producer }));
      await selection.pending('value');
      expect(rows.at(-1)).toEqual([{ n: 1, total: null }]);
      selection.reset();
      await selection.pending('value');
      expect(rows.at(-1)).toEqual([{ n: 4, total: 6 }]);
      expect(Array.from(await legacy.query(LegacyQuery.from(source).select({ n: legacyCount() })))).toEqual([{ n: 4 }]);
      expect(coordinator.preaggregator.enabled).toBe(false);
      expect(legacy.preaggregator.enabled).toBe(true);
    } finally {
      client.destroy();
      coordinator.clear();
      legacy.clear();
    }
  });

  it('preserves native field identity, union/empty resolution and graph ownership', async () => {
    const { native, ready } = setup();
    const coordinator = await ready;
    const field = column('x value');
    const a = native.point(field, 1, { source: {} });
    expect(a.fields[0]).toBe(field);
    if (!a.predicate || !('null_safe_eq' in a.predicate)) throw new Error('Expected null-safe predicate.');
    expect(a.predicate.null_safe_eq.left).toBe(field);
    const selection = native.selection({ union: true, empty: true });
    try {
      expect(Array.from(await coordinator.query(Query.from(source).select({ n: count() }).where(selection.predicate() ?? [])))).toEqual([{ n: 0 }]);
      selection.update(a);
      selection.update(native.point(field, 3, { source: {} }));
      await selection.pending('value');
      expect(Array.from(await coordinator.query(Query.from(source).select({ n: count() }).where(selection.predicate() ?? [])))).toEqual([{ n: 2 }]);
      expect(selection.clone().owner).toBe(native);
      expect(selection.remove(a.source).owner).toBe(native);
      expect(() => native.selection({ include: new NativeSqlContext().selection() })).toThrow('different SQL contexts');
      expect(() => selection.update({ source: {}, fields: [], predicate: null, value: null })).toThrow('different SQL contexts');
      expect(() => coordinator.connect(new MosaicClient())).toThrow('coordinator SQL context');
      const unmigrated = new MosaicClient(selection);
      const prepare = vi.spyOn(unmigrated, 'prepare');
      const query = vi.spyOn(unmigrated, 'query');
      expect(() => coordinator.connect(unmigrated)).toThrow('coordinator SQL context');
      expect(prepare).not.toHaveBeenCalled();
      expect(query).not.toHaveBeenCalled();
      expect(() => new Coordinator(coordinator.databaseConnector()!, { native })).toThrow('already attached');
      expect(() => new Coordinator().connect(new MosaicClient(selection))).toThrow('coordinator SQL context');
      expect(() => Reflect.apply(native.selection, native, [{ include: Selection.intersect() }])).toThrow('different SQL contexts');
    } finally {
      coordinator.clear();
    }
  });

  it('releases transient adoption state when the last native client disconnects', async () => {
    const { native, ready } = setup();
    const coordinator = await ready;
    const selection = native.selection();
    const first = makeClient<SqlExpression>({ coordinator, selection, enabled: false });
    const second = makeClient<SqlExpression>({ coordinator, selection, enabled: false });
    const clause = clausePoint(legacyColumn('x value'), 1, { source: {} });
    const adopted = native.adoptClause(clause);
    try {
      expect(native.adoptClause(clause).fields[0]).toBe(adopted.fields[0]);
      first.destroy();
      expect(native.adoptClause(clause).fields[0]).toBe(adopted.fields[0]);
      second.destroy();
      expect(coordinator.filterGroups.size).toBe(0);
      expect(native.adoptClause(clause).fields[0]).not.toBe(adopted.fields[0]);
    } finally {
      first.destroy();
      second.destroy();
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
      await expect(coordinator.query(new Query(asLiteral(1)))).rejects.toThrow('SELECT or DESCRIBE');
      await expect(coordinator.query('SELECT 1')).rejects.toThrow('structured query');
      await expect(coordinator.query(Query.from('missing table').select({ n: count() })))
        .rejects.toMatchObject({ sql: expect.stringContaining('missing table') });
      const errors: Error[] = [];
      const client = makeClient<SqlExpression>({
        coordinator,
        sqlOwner: coordinator.nativeContext!,
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
