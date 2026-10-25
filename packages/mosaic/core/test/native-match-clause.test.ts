import { DuckDB } from '@uwdata/mosaic-duckdb';
import { column, Query, tableRef } from '@uwdata/mosaic-sql/native';
import { afterAll, beforeAll, expect, it } from 'vitest';
import { Coordinator } from '../src/Coordinator.js';
import { NodeConnector } from '../src/connectors/NodeConnector.js';
import { NativeSqlContext } from '../src/native-sql.js';

const db = new DuckDB();
const connector = new NodeConnector(db);
beforeAll(() => db.exec("CREATE TABLE native_search_rows(id INTEGER,label VARCHAR); INSERT INTO native_search_rows VALUES (1,'Alpha'),(2,'ALPine'),(3,'beta'),(4,NULL),(5,'O''Reilly'),(6,'123')"));
afterAll(() => db.close());

it.each([
  ['contains', 'LP', [1, 2]], ['prefix', 'al', [1, 2]],
  ['suffix', 'HA', [1]], ['regexp', '^al.*a$', [1]], ['contains', "'", [5]]
] as const)('executes native %s text matching with literal values', async (method, value, ids) => {
  const native = new NativeSqlContext();
  const coordinator = new Coordinator(connector, { native, logger: null, cache: false });
  const field = column('label', tableRef('main', 'native_search_rows'));
  const source = {};
  const clause = native.match(field, value, { source, method });
  try {
    expect(clause.context).toBe(native);
    expect(clause.fields[0]).toBe(field);
    expect(clause.meta).toEqual({ type: 'match', method });
    expect(clause.source).toBe(source);
    expect(clause.clients).toBeUndefined();
    expect(Array.from(await coordinator.query(Query.from('native_search_rows').select('id').where(clause.predicate!).orderby('id')), row => row.id))
      .toEqual(ids);
    const sensitive = native.match(field, 'al', { source, method: 'prefix', caseSensitive: true });
    expect(Array.from(await coordinator.query(Query.from('native_search_rows').select('id').where(sensitive.predicate!)))).toEqual([]);
    for (const empty of ['', null, undefined]) expect(native.match(field, empty, { source, method }).predicate).toBeNull();
  } finally { coordinator.clear(); }
});

it('preserves regexp escapes and uses flags for case-insensitive matching', async () => {
  const native = new NativeSqlContext();
  const coordinator = new Coordinator(connector, { native, logger: null, cache: false });
  const ids = async (pattern: string, caseSensitive = false) => {
    const clause = native.match('label', pattern, { source: {}, method: 'regexp', caseSensitive });
    return Array.from(await coordinator.query(Query.from('native_search_rows').select('id').where(clause.predicate!).orderby('id')), row => row.id);
  };
  try {
    expect(await ids('\\D')).toEqual([1, 2, 3, 5]);
    expect(await ids('\\d')).toEqual([6]);
    expect(await ids('^AL')).toEqual([1, 2]);
    expect(await ids('^AL', true)).toEqual([2]);
  } finally { coordinator.clear(); }
});
