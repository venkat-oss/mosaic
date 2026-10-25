// @vitest-environment jsdom
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { Coordinator, NativeSqlContext, Param, coordinator as globalCoordinator } from '@uwdata/mosaic-core';
import { NodeConnector } from '@uwdata/mosaic-core/node-connector';
import { createAPIContext } from '../src/context.js';

class Database extends NodeConnector {
  close() { this._db.close(); }
}

const database = new Database;
beforeAll(() => database.query({ type: 'exec', sql: `
  CREATE TABLE native_input_rows(id INTEGER,label VARCHAR,items VARCHAR[]);
  INSERT INTO native_input_rows VALUES (1,'Alpha',['A','B']),(2,'ALPine',['A']),(3,'Beta',['B']),(4,'beta',[]),(5,'Other',NULL);
  CREATE TABLE native_input_other AS SELECT id+10 AS id,label,items FROM native_input_rows WHERE id<3;
  CREATE TABLE native_input_quoted AS SELECT 1 AS "__proto__", 2 AS constructor;
  CREATE TABLE native_input_complex AS SELECT 1 AS id, [1,NULL,3]::INTEGER[] AS items,
    {'literal': {'literal_type': 'number', 'value': '7'}, 'small': [1,255]::UTINYINT[], 'bytes': X'0041FF'} AS record,
    X'0041FF' AS bytes
    UNION ALL SELECT 2, [2,3]::INTEGER[],
    {'literal': {'literal_type': 'number', 'value': '8'}, 'small': [2]::UTINYINT[], 'bytes': X'FF'}, X'FF';
` }));
afterAll(() => database.close());

function setup() {
  const native = new NativeSqlContext();
  const coordinator = new Coordinator(database, { native, logger: null, cache: false, consolidate: false });
  const errors = [];
  coordinator.logger({ ...coordinator.logger(), error: error => errors.push(error) });
  const api = createAPIContext({ coordinator });
  return { native, coordinator, api, errors, close() { coordinator.clear(); } };
}

const client = element => Reflect.get(element, 'value');
const values = table => [...table.body.rows].map(row => Number(row.cells[0].innerText));

describe('native input clients', () => {
  it('forwards context to unbound and scalar inputs and executes menu/autocomplete queries', async () => {
    const state = setup();
    try {
      const binding = Param.value('A');
      const menu = client(state.api.menu({ from: 'native_input_rows', column: 'items', listMatch: 'any', as: binding }));
      const search = client(state.api.search({ from: 'native_input_rows', column: 'label' }));
      const scalar = client(state.api.search({ as: Param.value('initial') }));
      await Promise.all([menu.pending, search.pending, scalar.pending]);
      expect([menu.sqlOwner, search.sqlOwner, scalar.sqlOwner]).toEqual([state.native, state.native, state.native]);
      expect(menu.data.map(option => option.value)).toEqual(['', 'A', 'B']);
      expect([...search.datalist.options].map(option => option.value).sort()).toEqual(['ALPine', 'Alpha', 'Beta', 'Other', 'beta']);
      menu.selectedValue('B');
      menu.select.dispatchEvent(new Event('input'));
      await binding.pending('value');
      expect(binding.value).toBe('B');
      expect(state.errors).toEqual([]);
    } finally { state.close(); }
  });

  it('filters real Arrow rows with native menu and case-insensitive search clauses', async () => {
    const state = setup();
    try {
      const selection = state.native.selection();
      const menu = client(state.api.menu({ from: 'native_input_rows', column: 'items', listMatch: 'all', as: selection }));
      const table = client(state.api.table({ from: 'native_input_rows', columns: ['id', 'label'], filterBy: selection }));
      await Promise.all([menu.pending, table.pending]);
      menu.publish('A');
      await selection.pending('value');
      expect(values(table)).toEqual([1, 2]);
      menu.publish('');
      await selection.pending('value');
      expect(values(table)).toEqual([1, 2, 3, 4, 5]);
      const search = client(state.api.search({ as: selection, field: 'label', type: 'prefix' }));
      await search.pending;
      search.publish('al');
      await selection.pending('value');
      expect(values(table)).toEqual([1, 2]);
      search.publish(null);
      await selection.pending('value');
      expect(values(table)).toEqual([1, 2, 3, 4, 5]);
      expect(state.errors).toEqual([]);
    } finally { state.close(); }
  });

  it('pages, sorts, resets filters and source params using only the owning coordinator', async () => {
    const state = setup();
    const singleton = globalCoordinator();
    const prefetch = singleton.prefetch;
    singleton.prefetch = () => { throw new Error('Unexpected global prefetch.'); };
    try {
      const source = Param.value('native_input_rows');
      const selection = state.native.selection();
      const table = client(state.api.table({ from: source, columns: ['id', 'label'], rowBatch: 2, filterBy: selection }));
      await table.pending;
      expect(values(table)).toEqual([1, 2]);
      await table.requestData(2);
      expect(values(table)).toEqual([1, 2, 3, 4]);
      selection.update(state.native.point('label', 'Beta', { source: {} }));
      await selection.pending('value');
      expect(values(table)).toEqual([3]);
      selection.reset();
      await selection.pending('value');
      await table.requestData(2);
      source.update('native_input_other');
      await source.pending('value');
      await table.pending;
      expect(values(table)).toEqual([11, 12]);
      const header = table.head.querySelector('th');
      header.dispatchEvent(new MouseEvent('click'));
      await table.pending;
      header.dispatchEvent(new MouseEvent('click'));
      await table.pending;
      expect(values(table)).toEqual([12, 11]);
      expect(state.errors).toEqual([]);
    } finally { singleton.prefetch = prefetch; state.close(); }
  });

  it('renders prototype-named columns without inheriting formatter callbacks', async () => {
    const state = setup();
    try {
      const table = client(state.api.table({ from: 'native_input_quoted' }));
      await table.pending;
      expect([...table.head.querySelectorAll('th')].map(header => header.textContent)).toEqual(['__proto__', 'constructor']);
      expect(values(table)).toEqual([1]);
      expect(table.body.rows[0].cells[1].innerText).toBe('2');
      expect(state.errors).toEqual([]);
    } finally { state.close(); }
  });

  it('filters actual Arrow LIST, STRUCT and BLOB rows from native table hover selections', async () => {
    const state = setup();
    try {
      const selection = state.native.selection();
      const source = client(state.api.table({ from: 'native_input_complex', as: selection }));
      const filtered = client(state.api.table({ from: 'native_input_complex', columns: ['id'], filterBy: selection }));
      await Promise.all([source.pending, filtered.pending]);
      const clause = source.clause([0]);
      expect(clause.value[0][1]).toEqual([1, null, 3]);
      expect(clause.value[0][2].small).toEqual([1, 255]);
      for (const bytes of [clause.value[0][2].bytes, clause.value[0][3]]) {
        expect(ArrayBuffer.isView(bytes)).toBe(true);
        expect(Array.from(bytes)).toEqual([0, 65, 255]);
      }
      source.body.rows[0].cells[0].dispatchEvent(new MouseEvent('pointerover', { bubbles: true }));
      await selection.pending('value');
      expect(values(filtered)).toEqual([1]);
      source.body.rows[1].cells[0].dispatchEvent(new MouseEvent('pointerover', { bubbles: true }));
      await selection.pending('value');
      expect(values(filtered)).toEqual([2]);
      source.body.dispatchEvent(new MouseEvent('pointerleave'));
      await selection.pending('value');
      expect(values(filtered)).toEqual([1, 2]);
      expect(selection.value).toBeNull();
      expect(source.clause().predicate).toBeNull();
      const empty = source.clause([]);
      expect(empty.predicate).not.toBeNull();
      selection.update(empty);
      await selection.pending('value');
      expect(values(filtered)).toEqual([]);
      selection.update(source.clause());
      await selection.pending('value');
      expect(values(filtered)).toEqual([1, 2]);
      expect(state.errors).toEqual([]);
    } finally { state.close(); }
  });
});
