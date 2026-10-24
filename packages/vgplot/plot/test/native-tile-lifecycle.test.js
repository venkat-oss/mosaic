import { describe, expect, it } from 'vitest';
import { Coordinator, NativeSqlContext } from '@uwdata/mosaic-core';
import { NodeConnector } from '@uwdata/mosaic-core/node-connector';
import { RasterTileMark } from '../src/marks/RasterTileMark.js';

class DelayedDatabase extends NodeConnector {
  holdNext() {
    let release = () => {};
    let arrived = () => {};
    let completed = () => {};
    const promise = new Promise(resolve => { release = () => resolve(undefined); });
    const submitted = new Promise(resolve => { arrived = () => resolve(undefined); });
    const received = new Promise(resolve => { completed = () => resolve(undefined); });
    this.gate = { promise, arrived, completed };
    return { release, submitted, received };
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
    const result = request.type === 'exec' ? super.query(request) : super.query(request);
    const gate = this.gate;
    if (request.type === 'arrow' && gate) {
      this.gate = null;
      gate.arrived();
      return Promise.all([result, gate.promise]).then(([value]) => value).finally(gate.completed);
    }
    return result;
  }
}

class Tiles extends RasterTileMark {
  convolve() { this.grids = this.grids0; return this; }
}

async function setup(dim = 'x') {
  const database = new DelayedDatabase;
  const native = new NativeSqlContext();
  const coordinator = new Coordinator(database, { native, logger: null, cache: false, consolidate: false });
  const errors = [];
  coordinator.logger({ ...coordinator.logger(), error: error => errors.push(error) });
  await coordinator.exec(`
    CREATE TABLE tile_rows(x DOUBLE,y DOUBLE);
    INSERT INTO tile_rows VALUES (3.5,2),(4.5,2);
    CREATE TABLE tile_other(x DOUBLE,y DOUBLE);
    INSERT INTO tile_other VALUES (2,2),(3,2),(4,2);
    CREATE TABLE tile_boundary(x DOUBLE,y DOUBLE);
    INSERT INTO tile_boundary VALUES (4,2);
    CREATE TABLE tile_y_boundary(x DOUBLE,y DOUBLE);
    INSERT INTO tile_y_boundary VALUES (2,4);
  `);
  const source = { table: 'tile_rows' };
  const mark = new Tiles(source, {
    x: 'x', y: 'y', fill: 'density', width: 5, height: 5,
    interpolate: 'linear', origin: [0, 0], dim
  }, native);
  const attributes = { xDomain: [0, 4], yDomain: [0, 4], width: 100, height: 100 };
  let updates = 0;
  Object.assign(mark, { plot: {
    innerWidth: () => attributes.width,
    innerHeight: () => attributes.height,
    getAttribute: name => attributes[name],
    setAttribute: (name, value) => attributes[name] = value,
    pending() {}, update() { ++updates; return Promise.resolve(); }
  } });
  coordinator.connect(mark);
  await mark.pending;
  await Promise.allSettled(mark.prefetch);
  return {
    database, coordinator, mark, source, attributes, errors,
    updates: () => updates,
    close() {
      mark.destroy();
      coordinator.clear();
      database.close();
    }
  };
}

const mass = mark => Array.from(mark.grids0.columns.density?.[0] ?? []).reduce((sum, value) => sum + Number(value), 0);

describe('native raster tile lifecycle', () => {
  it.each([['x', 'tile_y_boundary'], ['y', 'tile_boundary']])('retains the untiled dimension endpoint with dim %s', async (dim, table) => {
    const state = await setup(dim);
    try {
      state.source.table = table;
      state.mark.initialize();
      await state.mark.pending;
      expect(mass(state.mark)).toBeCloseTo(1, 12);
      expect(state.errors).toEqual([]);
    } finally { await state.close(); }
  });

  it('combines partial weights across tiles without counting exact boundary points twice', async () => {
    const state = await setup();
    try {
      state.attributes.xDomain = [2, 6];
      await state.mark.update();
      expect(mass(state.mark)).toBeCloseTo(2, 12);
      state.source.table = 'tile_boundary';
      state.mark.initialize();
      await state.mark.pending;
      expect(mass(state.mark)).toBeCloseTo(1, 12);
      state.attributes.xDomain = [0, 4];
      await state.mark.update();
      expect(mass(state.mark)).toBeCloseTo(1, 12);
      expect(state.errors).toEqual([]);
    } finally { await state.close(); }
  });

  it('ignores a delayed viewport result after the replacement Arrow grid renders', async () => {
    const state = await setup();
    const gate = state.database.holdNext();
    try {
      const previous = state.mark.update();
      await gate.submitted;
      state.attributes.xDomain = [2, 8];
      await state.mark.update();
      expect(mass(state.mark)).toBeCloseTo(2, 12);
      const current = state.mark.grids0;
      const updates = state.updates();
      gate.release();
      await gate.received;
      await state.coordinator.exec('SELECT 1');
      await previous;
      expect(state.mark.grids0).toBe(current);
      expect(state.updates()).toBe(updates);
      expect(state.errors).toEqual([]);
    } finally { gate.release(); await state.close(); }
  });

  it('keeps source preparation current while an obsolete tile response is delayed', async () => {
    const state = await setup();
    const gate = state.database.holdNext();
    try {
      const previous = state.mark.update();
      await gate.submitted;
      state.source.table = 'tile_other';
      state.mark.initialize();
      await state.mark.pending;
      expect(mass(state.mark)).toBeCloseTo(3, 12);
      const current = state.mark.grids0;
      const updates = state.updates();
      gate.release();
      await gate.received;
      await state.coordinator.exec('SELECT 1');
      await previous;
      expect(state.mark.grids0).toBe(current);
      expect(state.updates()).toBe(updates);
      expect(state.errors).toEqual([]);
    } finally { gate.release(); await state.close(); }
  });

  it('cancels tile work on destroy and ignores a late Arrow response', async () => {
    const state = await setup();
    const gate = state.database.holdNext();
    try {
      const previous = state.mark.update();
      await gate.submitted;
      const current = state.mark.grids0;
      const updates = state.updates();
      state.mark.destroy();
      expect(state.mark.coordinator).toBeNull();
      gate.release();
      await gate.received;
      await state.coordinator.exec('SELECT 1');
      await previous;
      expect(state.mark.grids0).toBe(current);
      expect(state.updates()).toBe(updates);
      expect(state.errors).toEqual([]);
    } finally { gate.release(); await state.close(); }
  });
});
