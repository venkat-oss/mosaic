import { clauseList } from '../src/clause/index.js';
import { DuckDB } from '@uwdata/mosaic-duckdb';
import { column, count, literal, Query, tableRef } from '@uwdata/mosaic-sql';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { Coordinator } from '../src/Coordinator.js';
import { NodeConnector } from '../src/connectors/NodeConnector.js';
import { MosaicClient } from '../src/MosaicClient.js';
import { SqlContext } from '../src/sql-context.js';
import { Param } from '../src/Param.js';

const db = new DuckDB();
const connector = new NodeConnector(db);
const table = "list's rows";
beforeAll(() => db.exec(`CREATE TABLE "${table}"(id INTEGER,items VARCHAR[],other VARCHAR[]);
  INSERT INTO "${table}" VALUES
    (1,['Alpha','Beta'],['else']), (2,['Alpha',NULL],[]),
    (3,['Beta'],['Alpha']), (4,[],NULL), (5,NULL,['Alpha']), (6,[NULL],[])
`));
afterAll(() => db.close());

describe('native list selection clauses', () => {
  it.each(['any', 'all'] as const)('executes %s membership with original field ownership and scalar values', async listMatch => {
    const native = new SqlContext();
    const coordinator = new Coordinator(connector, { sql: native, logger: null, cache: false });
    const source = new MosaicClient();
    const field = column('items', tableRef('main', table));
    const selected = ['Alpha', 'Beta'];
    const clause = clauseList(field, selected, { source, listMatch });
    const query = (predicate: typeof clause.predicate) => Query.from(table).select('id').where(predicate ?? []).orderby('id');
    try {
      expect(clause.fields[0]).toBe(field);
      expect(clause.source).toBe(source);
      expect(clause.clients).toEqual(new Set([source]));
      expect(clause.meta).toEqual({ type: 'list', match: listMatch });
      expect(clause.value).toBe(selected);
      expect(Array.from(await coordinator.query(query(clause.predicate)), row => row.id))
        .toEqual(listMatch === 'all' ? [1] : [1, 2, 3]);
      expect(Array.from(await coordinator.query(query(clauseList(field, 'Alpha', { source, listMatch }).predicate)), row => row.id))
        .toEqual([1, 2]);
      for (const value of [undefined, []]) expect(clauseList(field, value, { source, listMatch }).predicate).toBeNull();
      const nullClause = clauseList(field, null, { source, listMatch });
      expect(nullClause.predicate).not.toBeNull();
      expect(nullClause.value).toBeNull();
      expect(Array.from(await coordinator.query(query(nullClause.predicate)))).toEqual([]);
      expect(Array.from(await coordinator.query(query(clauseList(field, [null], { source, listMatch }).predicate)), row => row.id))
        .toEqual(listMatch === 'all' ? [1, 2, 3, 4, 6] : []);
    } finally { coordinator.clear(); }
  });

  it('retains live identifier bindings', async () => {
    const native = new SqlContext();
    const coordinator = new Coordinator(connector, { sql: native, logger: null, cache: false });
    const name = Param.value('items');
    const clause = clauseList(column(name), ['Alpha'], { source: {} });
    const query = Query.from(table).select('id').where(clause.predicate!).orderby('id');
    try {
      expect(Array.from(await coordinator.query(query), row => row.id)).toEqual([1, 2]);
      name.update('other');
      await name.pending('value');
      expect(Array.from(await coordinator.query(query), row => row.id)).toEqual([3, 5]);
    } finally { coordinator.clear(); }
  });
});

// https://github.com/uwdata/mosaic/issues/977
it.each([
  [['Drafting Lines'], 'any'], [['Markers'], 'any'],
  [['Roads', 'Lakes'], 'any'], [['Roads', 'Lakes'], 'all']
] as const)('quotes list values %j with %s membership', async (values, listMatch) => {
  const coordinator = new Coordinator(connector, { logger: null });
  const clause = clauseList('tags', [...values], { source: {}, listMatch });
  try {
    const data = Query.select({ tags: literal(values) });
    const matched = await coordinator.query(Query.from(data).select({ n: count() }).where(clause.predicate!));
    expect(Array.from(matched)).toEqual([{ n: 1 }]);
  } finally { coordinator.clear(); }
});
