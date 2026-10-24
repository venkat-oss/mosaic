import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { Coordinator, NativeSqlContext } from '@uwdata/mosaic-core';
import { NodeConnector } from '@uwdata/mosaic-core/node-connector';
import * as sql from '@uwdata/mosaic-sql/native';
import { Grid2DMark } from '../src/marks/Grid2DMark.js';
import { HexbinMark } from '../src/marks/HexbinMark.js';
import { RasterTileMark } from '../src/marks/RasterTileMark.js';

class Database extends NodeConnector {
  close() { this._db.close(); }
}

class Tiles extends RasterTileMark {
  convolve() { this.grids = this.grids0; return this; }
}

const database = new Database;
beforeAll(() => database.query({ type: 'exec', sql: `
  CREATE TABLE native_grid(x DOUBLE,y DOUBLE,value DOUBLE,series VARCHAR);
  INSERT INTO native_grid VALUES (0,0,1,'a'),(1,1,2,'a'),(2,2,3,'b'),(4,4,4,'b'),(NULL,2,100,'a');
  CREATE TABLE native_empty_grid AS SELECT * FROM native_grid WHERE false;
` }));
afterAll(() => database.close());

async function setup(create) {
  const native = new NativeSqlContext();
  const mc = new Coordinator(database, { native, cache: false, consolidate: false, logger: null });
  const errors = [];
  mc.logger({ ...mc.logger(), error: error => errors.push(error) });
  const mark = create(native);
  const attributes = { xDomain: [0, 4], yDomain: [0, 4], width: 100, height: 100, marginLeft: 0, marginTop: 0 };
  mark.plot = {
    innerWidth: () => attributes.width,
    innerHeight: () => attributes.height,
    getAttribute: name => attributes[name],
    setAttribute: (name, value) => attributes[name] = value,
    pending() {}, update: () => Promise.resolve()
  };
  mc.connect(mark);
  await mark.pending;
  return { mc, mark, attributes, errors, close() { mark.destroy(); mc.clear(); } };
}

const source = { table: ['main', 'native_grid'] };
const qualifier = sql.tableRef(source.table);
const coordinates = { x: sql.column('x', qualifier), y: sql.column('y', qualifier), width: 5, height: 5 };
const mass = values => Array.from(values).reduce((sum, value) => sum + Number(value), 0);

describe('native grid consumers', () => {
  it.each(['none', 'linear'])('preserves compound weights with %s binning', async interpolate => {
    const state = await setup(native => new Grid2DMark('dot', source, {
      ...coordinates, interpolate, weight: sql.mul(sql.column('value', qualifier), 2)
    }, native));
    try {
      expect(mass(state.mark.grids0.columns.density[0])).toBeCloseTo(20, 12);
      const query = state.mark.query([sql.lt(sql.column('x', qualifier), 2)]);
      expect(mass(Array.from(await state.mc.query(query), row => row.density))).toBeCloseTo(6, 12);
      expect(state.errors).toEqual([]);
    } finally { state.close(); }
  });

  it('preserves custom aggregate expressions and qualified grouping fields', async () => {
    const state = await setup(native => new Grid2DMark('dot', source, {
      ...coordinates, fill: sql.sum(sql.mul(sql.column('value', qualifier), 2)), stroke: 'series'
    }, native));
    try {
      const { columns } = state.mark.grids0;
      expect(Object.fromEntries(columns.series.map((value, i) => [value, mass(columns.fill[i])]))).toEqual({ a: 6, b: 14 });
      state.mark.pad = 0;
      const rows = await state.mc.query(state.mark.query());
      expect(mass(Array.from(rows, row => row.fill))).toBe(12);
      expect(state.errors).toEqual([]);
    } finally { state.close(); }
  });

  it('hexbin aggregates qualified source expressions after screen-space projection', async () => {
    const state = await setup(native => new HexbinMark(source, {
      x: coordinates.x, y: coordinates.y, fill: sql.sum(sql.column('value', qualifier)), stroke: 'series'
    }, native));
    try {
      const data = state.mark.data;
      expect(mass(data.columns.fill)).toBe(10);
      expect(new Set(data.columns.series)).toEqual(new Set(['a', 'b']));
      expect(Array.from(data.columns.x).every(Number.isFinite)).toBe(true);
      expect(Array.from(data.columns.y).every(Number.isFinite)).toBe(true);
      expect(state.errors).toEqual([]);
    } finally { state.close(); }
  });

  it('uses the owning coordinator for tiles, selection updates and empty results', async () => {
    const state = await setup(native => new Tiles(source, {
      ...coordinates, fill: 'density', origin: [0, 0], weight: sql.mul(sql.column('value', qualifier), 2), interpolate: 'linear'
    }, native));
    try {
      expect(state.mark.grids0.numRows).toBe(1);
      expect(mass(state.mark.grids0.columns.density[0])).toBeCloseTo(20, 12);
      state.mark.query([sql.lt(sql.column('x', qualifier), 2)]);
      await state.mark.update();
      expect(mass(state.mark.grids0.columns.density[0])).toBeCloseTo(6, 12);
      state.mark.query([sql.literal(false)]);
      await state.mark.update();
      expect(state.mark.grids0).toEqual({ numRows: 0, columns: {} });
      expect(state.errors).toEqual([]);
    } finally { state.close(); }
  });
});
