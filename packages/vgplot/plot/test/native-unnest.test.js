import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { Coordinator, NativeSqlContext } from '@uwdata/mosaic-core';
import { NodeConnector } from '@uwdata/mosaic-core/node-connector';
import { column, isExpression, tableRef } from '@uwdata/mosaic-sql/native';
import { Mark } from '../src/marks/Mark.js';
import { Toggle } from '../src/interactors/Toggle.js';

class Database extends NodeConnector {
  close() { this._db.close(); }
}

const database = new Database;
beforeAll(() => database.query({ type: 'exec', sql: `
  CREATE TABLE native_unnest_rows(id INTEGER,items VARCHAR[]);
  INSERT INTO native_unnest_rows VALUES (1,['Alpha','Beta']),(2,['Alpha',NULL]),(3,[]),(4,NULL),(5,['Beta']),(6,[NULL]);
` }));
afterAll(() => database.close());

/** @returns {clause is import('@uwdata/mosaic-core').NativeSelectionClause} */
function isNativeClause(clause) {
  return clause.context !== undefined && clause.fields.every(isExpression)
    && (clause.predicate == null || isExpression(clause.predicate));
}

async function setup(listMatch) {
  const native = new NativeSqlContext();
  const coordinator = new Coordinator(database, { native, logger: null, cache: false, consolidate: false });
  const errors = [];
  coordinator.logger({ ...coordinator.logger(), error: error => errors.push(error) });
  const selection = native.selection();
  const field = column('items', tableRef('main', 'native_unnest_rows'));
  const mark = new Mark('dot', {
    table: ['main', 'native_unnest_rows'], options: { unnest: ['items'], filterBy: selection }
  }, { x: field, y: 'id' }, { x: ['count', 'nulls', 'distinct'] }, native);
  Object.assign(mark, { plot: {
    markSet: new Set([mark]), pending() {}, update() { return Promise.resolve(); }
  } });
  const toggle = new Toggle(mark, { channels: ['x'], selection, listMatch });
  coordinator.connect(mark);
  await mark.pending;
  const columns = () => {
    const data = mark.data;
    if (!('columns' in data)) throw new TypeError('Expected columnar unnested results.');
    return data.columns;
  };
  return {
    native, coordinator, mark, selection, toggle, field, errors, columns,
    ids() { return Array.from(columns().id).map(Number).sort((a, b) => a - b); },
    select(value) {
      const clause = toggle.clause(value);
      if (!isNativeClause(clause)) throw new TypeError('Expected a native list clause.');
      selection.update(clause);
      return selection.pending('value');
    },
    close() { mark.destroy(); coordinator.clear(); }
  };
}

describe('native unnested marks', () => {
  it('prepares scalar element metadata and statistics from actual expanded Arrow rows', async () => {
    const state = await setup('any');
    try {
      const info = state.mark.channelField('x');
      expect(info.field).toBe(state.field);
      expect(info.sqlType).toBe('VARCHAR');
      expect(info.type).toBe('string');
      expect(Number(info.count)).toBe(4);
      expect(Number(info.nulls)).toBe(2);
      expect(Number(info.distinct)).toBe(2);
      expect(state.mark.data.numRows).toBe(6);
      expect(state.ids()).toEqual([1, 1, 2, 2, 5, 6]);
      expect(Array.from(state.columns().items).sort()).toEqual(['Alpha', 'Alpha', 'Beta', 'Beta', null, null]);
      expect(state.errors).toEqual([]);
    } finally { state.close(); }
  });

  it.each(['any', 'all'])('filters source lists through %s toggle clauses and resets empty selections', async listMatch => {
    const state = await setup(listMatch);
    try {
      const clause = state.toggle.clause([['Alpha'], ['Beta']]);
      if (!isNativeClause(clause)) throw new TypeError('Expected a native list clause.');
      expect(clause.context).toBe(state.native);
      expect(clause.fields[0]).toBe(state.field);
      expect(clause.meta).toEqual({ type: 'list', match: listMatch });
      expect(clause.clients).toBe(state.mark.plot.markSet);
      expect(clause.value).toEqual(['Alpha', 'Beta']);
      state.selection.update(clause);
      await state.selection.pending('value');
      expect(state.ids()).toEqual(listMatch === 'all' ? [1, 1] : [1, 1, 2, 2, 5]);
      await state.select([['Alpha']]);
      expect(state.ids()).toEqual([1, 1, 2, 2]);
      await state.select(null);
      expect(state.ids()).toEqual([1, 1, 2, 2, 5, 6]);
      expect(state.selection.value).toBeUndefined();
      expect(state.errors).toEqual([]);
    } finally { state.close(); }
  });
});
