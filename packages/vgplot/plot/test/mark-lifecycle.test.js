// @vitest-environment jsdom
import { Coordinator, Param, QueryError } from '@uwdata/mosaic-core';
import { NodeConnector } from '@uwdata/mosaic-core/node-connector';
import * as sql from '@uwdata/mosaic-sql';
import { afterAll, beforeAll, describe, expect, it, vi } from 'vitest';
import { Mark } from '../src/marks/Mark.js';
import { Density1DMark } from '../src/marks/Density1DMark.js';
import { Plot } from '../src/plot.js';

class Database extends NodeConnector {
  close() { this._db.close(); }
}

const database = new Database();
beforeAll(() => database.query({ type: 'exec', sql: 'CREATE TABLE mark_lifecycle AS SELECT 1.0::DOUBLE AS x, 2.0::DOUBLE AS y' }));
afterAll(() => database.close());

function setup(mark) {
  const errors = [];
  const coordinator = new Coordinator(database, { logger: null, cache: false, consolidate: false });
  coordinator.logger({ ...coordinator.logger(), error: error => errors.push(error) });
  const plot = new Plot();
  const healthy = new Mark('dot', { table: 'mark_lifecycle' }, { x: 'x', y: 'y' });
  plot.addMark(mark).addMark(healthy);
  coordinator.connect(mark);
  coordinator.connect(healthy);
  return {
    coordinator, plot, healthy, errors,
    close() { mark.destroy(); healthy.destroy(); coordinator.clear(); }
  };
}

const flush = () => new Promise(resolve => setTimeout(resolve, 0));

/** @param {Mark} mark */
function values(mark, name) {
  if (!('columns' in mark.data)) throw new TypeError('Expected columnar mark data.');
  return Array.from(mark.data.columns[name]);
}

function deferred() {
  let resolve = () => {};
  let reject = error => { void error; };
  const promise = new Promise((ready, fail) => {
    resolve = () => ready(undefined);
    reject = fail;
  });
  return { promise, resolve, reject };
}

describe('mark failure lifecycle', () => {
  it('preserves metadata rejection while rendering healthy siblings and retrying a corrected field', async () => {
    const field = Param.value('missing');
    const mark = new Mark('dot', { table: 'mark_lifecycle' }, { x: sql.column(field), y: 'y' });
    const state = setup(mark);
    try {
      const failed = mark.pending;
      await expect(failed).rejects.toThrow(/missing/);
      expect(mark._failed).toBe(true);
      await state.healthy.pending;
      expect(state.plot.element.querySelector('svg')).not.toBeNull();
      expect(values(state.healthy, 'x')).toEqual([1]);
      await expect(failed).rejects.toThrow(/missing/);

      field.update('x');
      await field.pending('value');
      await mark.pending;
      expect(mark.initialized).toBe(true);
      expect(mark._failed).toBe(false);
      expect(values(mark, 'x')).toEqual([1]);
      expect(state.plot.element.querySelectorAll('svg circle')).toHaveLength(2);
    } finally { state.close(); }
  });

  it('releases query failures without hiding their errors and permits retry', async () => {
    const mark = new Mark('dot', { table: 'mark_lifecycle' }, { x: 'x', y: 'y' });
    vi.spyOn(mark, 'query').mockReturnValueOnce(sql.Query.from('missing_mark_source').select('x', 'y'));
    const state = setup(mark);
    try {
      await mark.pending;
      await state.healthy.pending;
      expect(mark._failed).toBe(true);
      expect(state.errors).toHaveLength(1);
      expect(state.errors[0]).toBeInstanceOf(QueryError);
      expect(String(state.errors[0])).toContain('missing_mark_source');
      expect(state.plot.element.querySelector('svg')).not.toBeNull();

      mark.initialize();
      expect(mark._failed).toBe(false);
      await mark.pending;
      expect(values(mark, 'y')).toEqual([2]);
      expect(state.plot.element.querySelectorAll('svg circle')).toHaveLength(2);
      expect(state.errors).toHaveLength(1);
    } finally { state.close(); }
  });

  it('skips failed specialized marks while retaining constant marks', async () => {
    const mark = new Density1DMark('lineY', { table: 'mark_lifecycle' }, { x: 'missing' });
    const specs = vi.spyOn(mark, 'plotSpecs');
    const state = setup(mark);
    const frame = new Mark('frame', null, { stroke: 'red' });
    const frameSpecs = vi.spyOn(frame, 'plotSpecs');
    state.plot.addMark(frame);
    try {
      await expect(mark.pending).rejects.toThrow(/missing/);
      await state.healthy.pending;
      expect(specs).not.toHaveBeenCalled();
      expect(frameSpecs).toHaveBeenCalled();
      expect(state.plot.element.querySelector('svg [aria-label="frame"]')).not.toBeNull();
      expect(state.plot.element.querySelectorAll('svg circle')).toHaveLength(1);
      expect(values(state.healthy, 'y')).toEqual([2]);
    } finally { state.close(); }
  });

  it('does not release a newer preparation when an obsolete generation rejects', async () => {
    class HeldMark extends Mark {
      preparations = [];
      async prepare() {
        const gate = deferred();
        this.preparations.push(gate);
        await gate.promise;
        return super.prepare();
      }
    }
    const mark = new HeldMark('dot', { table: 'mark_lifecycle' }, { x: 'x', y: 'y' });
    const state = setup(mark);
    const render = vi.spyOn(state.plot, 'render');
    try {
      const obsolete = mark.pending;
      await flush();
      mark.initialize();
      const current = mark.pending;
      await flush();
      expect(mark.preparations).toHaveLength(2);
      mark.preparations[0].reject(new Error('obsolete metadata failure'));
      await obsolete;
      await flush();
      expect(mark._failed).toBe(false);
      expect(render).not.toHaveBeenCalled();

      mark.preparations[1].resolve();
      await Promise.all([current, state.healthy.pending]);
      expect(render).toHaveBeenCalledOnce();
      expect(values(mark, 'x')).toEqual([1]);
      expect(state.errors).toEqual([]);
    } finally { state.close(); }
  });
});
