// @vitest-environment jsdom
import { describe, expect, it, vi } from 'vitest';
import { Coordinator, NativeSqlContext, Param } from '@uwdata/mosaic-core';
import { NodeConnector } from '@uwdata/mosaic-core/node-connector';
import { createAPIContext } from '../src/context.js';

class Database extends NodeConnector {
  constructor() { super(); this.calls = []; }

  holdNext(type = 'arrow') {
    let release = () => {};
    let arrived = () => {};
    const promise = new Promise(resolve => { release = () => resolve(undefined); });
    const submitted = new Promise(resolve => { arrived = () => resolve(undefined); });
    this.gate = { type, promise, arrived };
    return { release, submitted };
  }

  close() { this._db.close(); }

  /**
   * @overload
   * @param {import('@uwdata/mosaic-core').ArrowQueryRequest} request
   * @returns {Promise<Uint8Array[]>}
   */
  /**
   * @overload
   * @param {import('@uwdata/mosaic-core').ExecQueryRequest} request
   * @returns {Promise<void>}
   */
  /**
   * @param {import('@uwdata/mosaic-core').ArrowQueryRequest | import('@uwdata/mosaic-core').ExecQueryRequest} request
   * @returns {Promise<Uint8Array[] | void>}
   */
  query(request) {
    this.calls.push(request);
    const result = request.type === 'exec' ? super.query(request) : super.query(request);
    const gate = this.gate;
    if (gate?.type === request.type) {
      this.gate = null;
      gate.arrived();
      return Promise.all([result, gate.promise]).then(([value]) => value);
    }
    return result;
  }
}

async function setup() {
  const database = new Database;
  const coordinator = new Coordinator(database, { native: new NativeSqlContext(), logger: null, cache: false, consolidate: false });
  const errors = [];
  coordinator.logger({ ...coordinator.logger(), error: error => errors.push(error) });
  await coordinator.exec(`
    CREATE TABLE input_first(id INTEGER,old VARCHAR); INSERT INTO input_first VALUES (1,'a'),(2,'b'),(3,'c'),(4,'d'),(5,'e');
    CREATE TABLE input_second(key INTEGER,fresh VARCHAR); INSERT INTO input_second VALUES (11,'new'),(12,'rows');
  `);
  const source = Param.value('input_first');
  return {
    database, coordinator, errors, source, api: createAPIContext({ coordinator }),
    close() { coordinator.clear(); database.close(); }
  };
}

const client = element => Reflect.get(element, 'value');
const values = table => [...table.body.rows].map(row => Number(row.cells[0].innerText));

describe('native input lifecycle', () => {
  it('clears and activates selections safely while initial metadata is pending', async () => {
    const state = await setup();
    const gate = state.database.holdNext();
    try {
      const native = state.coordinator.nativeContext;
      if (!native) throw new Error('Expected a native coordinator.');
      const selection = native.selection();
      const table = client(state.api.table({ from: state.source, as: selection, rowBatch: 2 }));
      await gate.submitted;
      expect(table.initialized).toBe(false);
      expect(table.schema).toEqual([]);
      expect(table.clause().predicate).toBeNull();
      expect(table.clause([]).predicate).not.toBeNull();
      table.body.dispatchEvent(new Event('pointerleave'));
      await selection.pending('value');
      expect(selection.predicate()).toEqual([]);
      expect(() => table.activate()).not.toThrow();
      gate.release();
      await table.pending;
      expect(values(table)).toEqual([1, 2]);
      expect(state.errors).toEqual([]);
    } finally { gate.release(); state.close(); }
  });

  it('ignores obsolete metadata when a source changes during preparation', async () => {
    const state = await setup();
    const gate = state.database.holdNext();
    try {
      const table = client(state.api.table({ from: state.source, rowBatch: 2 }));
      const headers = vi.spyOn(table.head, 'appendChild');
      const previous = table.pending;
      await gate.submitted;
      state.source.update('input_second');
      await state.source.pending('value');
      gate.release();
      await Promise.all([previous, table.pending]);
      expect(headers).toHaveBeenCalledTimes(1);
      expect([...table.head.querySelectorAll('th')].map(node => node.textContent)).toEqual(['key', 'fresh']);
      expect(values(table)).toEqual([11, 12]);
      expect(state.errors).toEqual([]);
    } finally { gate.release(); state.close(); }
  });

  it('cancels queued pages and prefetch before restarting a different source', async () => {
    const state = await setup();
    const gate = state.database.holdNext('exec');
    try {
      const table = client(state.api.table({ from: state.source, rowBatch: 2 }));
      await table.pending;
      const barrier = state.coordinator.exec('SELECT 1');
      await gate.submitted;
      const previous = table.requestData(2);
      state.source.update('input_second');
      await state.source.pending('value');
      gate.release();
      await barrier;
      await Promise.all([previous, table.pending]);
      expect(values(table)).toEqual([11, 12]);
      expect(state.database.calls.some(request => /\bOFFSET (2|4)\b/i.test(request.sql))).toBe(false);
      expect(state.errors).toEqual([]);
    } finally { gate.release(); state.close(); }
  });

  it('leaves detached table DOM and source listeners unchanged after delayed metadata', async () => {
    const state = await setup();
    const gate = state.database.holdNext();
    try {
      const table = client(state.api.table({ from: state.source }));
      const previous = table.pending;
      await gate.submitted;
      table.destroy();
      const initialize = vi.spyOn(table, 'initialize');
      state.source.update('input_second');
      await state.source.pending('value');
      gate.release();
      await previous;
      expect(initialize).not.toHaveBeenCalled();
      expect(table.head.childElementCount).toBe(0);
      expect(table.body.childElementCount).toBe(0);
      expect(state.errors).toEqual([]);
    } finally { gate.release(); state.close(); }
  });
});
