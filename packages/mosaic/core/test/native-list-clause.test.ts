import { DuckDB } from '@uwdata/mosaic-duckdb';
import { column, Query, tableRef } from '@uwdata/mosaic-sql/native';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { Coordinator } from '../src/Coordinator.js';
import { NodeConnector } from '../src/connectors/NodeConnector.js';
import { MosaicClient } from '../src/MosaicClient.js';
import { NativeSqlContext } from '../src/native-sql.js';
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
    const native = new NativeSqlContext();
    const coordinator = new Coordinator(connector, { native, logger: null, cache: false });
    const source = new MosaicClient(undefined, native);
    const field = column('items', tableRef('main', table));
    const selected = ['Alpha', 'Beta'];
    const clause = native.list(field, selected, { source, listMatch });
    const query = (predicate: typeof clause.predicate) => Query.from(table).select('id').where(predicate ?? []).orderby('id');
    try {
      expect(clause.context).toBe(native);
      expect(clause.fields[0]).toBe(field);
      expect(clause.source).toBe(source);
      expect(clause.clients).toEqual(new Set([source]));
      expect(clause.meta).toEqual({ type: 'list', match: listMatch });
      expect(clause.value).toBe(selected);
      expect(Array.from(await coordinator.query(query(clause.predicate)), row => row.id))
        .toEqual(listMatch === 'all' ? [1] : [1, 2, 3]);
      expect(Array.from(await coordinator.query(query(native.list(field, 'Alpha', { source, listMatch }).predicate)), row => row.id))
        .toEqual([1, 2]);
      for (const value of [undefined, []]) expect(native.list(field, value, { source, listMatch }).predicate).toBeNull();
      const nullClause = native.list(field, null, { source, listMatch });
      expect(nullClause.predicate).not.toBeNull();
      expect(nullClause.value).toBeNull();
      expect(Array.from(await coordinator.query(query(nullClause.predicate)))).toEqual([]);
      expect(Array.from(await coordinator.query(query(native.list(field, [null], { source, listMatch }).predicate)), row => row.id))
        .toEqual(listMatch === 'all' ? [1, 2, 3, 4, 6] : []);
    } finally { coordinator.clear(); }
  });

  it('retains live identifier bindings and rejects list clauses from another context', async () => {
    const native = new NativeSqlContext();
    const coordinator = new Coordinator(connector, { native, logger: null, cache: false });
    const name = Param.value('items');
    const clause = native.list(column(name), ['Alpha'], { source: {} });
    const query = Query.from(table).select('id').where(clause.predicate!).orderby('id');
    try {
      expect(Array.from(await coordinator.query(query), row => row.id)).toEqual([1, 2]);
      name.update('other');
      await name.pending('value');
      expect(Array.from(await coordinator.query(query), row => row.id)).toEqual([3, 5]);
      expect(() => new NativeSqlContext().selection().update(clause)).toThrow('different SQL contexts');
    } finally { coordinator.clear(); }
  });
});
