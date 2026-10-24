// @vitest-environment jsdom
import { afterAll, beforeAll, describe, expect, it, vi } from 'vitest';
import { Coordinator, NativeSqlContext, Param } from '@uwdata/mosaic-core';
import { NodeConnector } from '@uwdata/mosaic-core/node-connector';
import * as sql from '@uwdata/mosaic-sql/native';
import { Plot } from '../src/plot.js';
import { ConnectedMark } from '../src/marks/ConnectedMark.js';
import { DenseLineMark } from '../src/marks/DenseLineMark.js';
import { Density1DMark } from '../src/marks/Density1DMark.js';

class TestConnector extends NodeConnector {
  close() { this._db.close(); }
}

const connection = new TestConnector;
const createElement = document.createElement.bind(document);
const descriptor = Object.getOwnPropertyDescriptor(document, 'createElement');
beforeAll(async () => {
  Object.defineProperty(document, 'createElement', { configurable: true, value(tag, options) {
    const element = createElement(tag, options);
    if (tag === 'canvas') {
      Object.defineProperty(element, 'getContext', { value: () => ({
        getImageData: (_, __, width, height) => ({ data: new Uint8ClampedArray(width * height * 4) }),
        putImageData() {}
      }) });
      Object.defineProperty(element, 'toDataURL', { value: () => 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jB3sAAAAASUVORK5CYII=' });
    }
    return element;
  } });
  await connection.query({ type: 'exec', sql: `
    CREATE TABLE native_connected AS SELECT
      (i % 500)::DOUBLE AS t, sin((i % 500) / 12.0) + floor(i / 500.0) AS v,
      (i % 500 + 1)::DOUBLE AS w,
      CASE WHEN i < 500 THEN 'A' ELSE 'B' END AS series,
      CASE WHEN i < 500 THEN 'a' ELSE 'b' END AS category
      FROM range(1000) r(i);
    CREATE TABLE native_density AS SELECT * FROM (VALUES
      ('A','a',0.0,0.0,1.0),('A','a',1.0,1.0,2.0),('A','a',2.0,2.0,3.0),('A','a',3.0,3.0,4.0),('A','a',4.0,4.0,5.0),
      ('B','b',0.0,4.0,2.0),('B','b',1.0,3.0,3.0),('B','b',2.0,2.0,4.0),('B','b',3.0,1.0,5.0),('B','b',4.0,0.0,6.0)
    ) d(series,category,t,v,w);
    CREATE TABLE native_density_changed AS SELECT series,category,t+10 AS t,v,w FROM native_density;
    CREATE TABLE native_density_dates AS SELECT series,category,TIMESTAMP '2024-01-01' + to_days(t::INTEGER) AS d,v,w FROM native_density;
    CREATE TABLE native_vertical AS SELECT * FROM (VALUES
      ('A','a',0.0,0.0),('A','a',1.0,4.0),('B','b',0.0,4.0),('B','b',1.0,0.0)
    ) d(series,category,t,v);
  ` });
});
afterAll(() => {
  if (descriptor) Object.defineProperty(document, 'createElement', descriptor);
  else delete document.createElement;
  connection.close();
});

async function mount(create, attributes = {}) {
  const native = new NativeSqlContext();
  const coordinator = new Coordinator(connection, { native, logger: null, cache: false, consolidate: false });
  const errors = [];
  coordinator.logger({ ...coordinator.logger(), error: error => errors.push(error) });
  const selection = native.selection();
  const plot = new Plot(undefined, native);
  for (const [key, value] of Object.entries({ width: 240, height: 180, ...attributes })) plot.setAttribute(key, value);
  const mark = create(native, selection);
  plot.addMark(mark);
  coordinator.connect(mark);
  await mark.pending;
  return { native, coordinator, selection, plot, mark, errors, close() { mark.destroy(); coordinator.clear(); } };
}

function columns(mark) {
  const data = mark.data;
  if (!data || !('columns' in data)) throw new TypeError('Expected columnar mark data.');
  return data.columns;
}

describe('native connected marks', () => {
  it('keeps M4 point values, series ordering and live identifier updates', async () => {
    const field = Param.value('t');
    const state = await mount((native, selection) => new ConnectedMark('lineY', {
      table: 'native_connected', options: { filterBy: selection, optimize: true }
    }, { x: sql.column(field), y: 'v', stroke: 'category', z: 'series' }, native), { width: 120 });
    try {
      const query = state.mark.query();
      expect('union' in query.expression).toBe(true);
      expect(state.mark.data.numRows).toBeLessThan(1000);
      const original = Array.from(await state.coordinator.query(sql.Query.from('native_connected').select('t', 'v', 'series')));
      const points = new Set(original.map(row => JSON.stringify([Number(row.t), Number(row.v), row.series])));
      const data = columns(state.mark);
      for (let index = 0; index < state.mark.data.numRows; ++index) {
        expect(points.has(JSON.stringify([Number(data.x[index]), Number(data.v[index]), data.series[index]]))).toBe(true);
      }
      expect([...data.series].filter((value, index, array) => index === 0 || value !== array[index - 1])).toEqual(['A', 'B']);
      expect(state.plot.element.querySelectorAll('g[aria-label="line"] path')).toHaveLength(2);
      field.update('w');
      await field.pending('value');
      await state.mark.pending;
      expect(Math.min(...Array.from(columns(state.mark).x, Number))).toBe(1);
      expect(state.plot.element.outerHTML).not.toMatch(/NaN|Infinity/);
      expect(state.errors).toEqual([]);
    } finally { state.close(); }
  });

  it('preserves the unoptimized native source ordering', async () => {
    const state = await mount((native, selection) => new ConnectedMark('lineY', {
      table: 'native_density', options: { filterBy: selection, optimize: false }
    }, { x: 't', y: 'v', z: 'series' }, native));
    try {
      expect('select' in state.mark.query().expression).toBe(true);
      expect([...columns(state.mark).t].map(Number)).toEqual([0, 0, 1, 1, 2, 2, 3, 3, 4, 4]);
      expect(state.errors).toEqual([]);
    } finally { state.close(); }
  });
});

describe('native one-dimensional density marks', () => {
  it('preserves weighted mass and group aliases while bandwidth updates reuse SQL results', async () => {
    const bandwidth = Param.value(4);
    const table = Param.value('native_density');
    const state = await mount((native, selection) => new Density1DMark('areaY', {
      table, options: { filterBy: selection }
    }, { x: 't', weight: 'w', fill: 'category', bins: 16, bandwidth }, native));
    try {
      const rows = Array.from(await state.coordinator.query(state.mark.query()));
      const totals = rows.reduce((result, row) => {
        result[row.category] = (result[row.category] ?? 0) + Number(row.density);
        return result;
      }, {});
      expect(totals.a).toBeCloseTo(15, 10);
      expect(totals.b).toBeCloseTo(20, 10);
      expect(state.mark.groupby).toEqual(['category']);
      expect(state.mark.data.numRows).toBe(32);
      expect(state.plot.element.querySelectorAll('g[aria-label="area"] path')).toHaveLength(2);
      const query = vi.spyOn(state.mark, 'query');
      bandwidth.update(8);
      await bandwidth.pending('value');
      expect(query).not.toHaveBeenCalled();
      query.mockRestore();
      table.update('native_density_changed');
      await table.pending('value');
      await state.mark.pending;
      expect(Number(columns(state.mark).t[0])).toBe(10);
      expect(state.plot.element.outerHTML).not.toMatch(/NaN|Infinity/);
      expect(state.errors).toEqual([]);
    } finally { state.close(); }
  });

  it('bins temporal values with matching numeric clipping units', async () => {
    const state = await mount((native, selection) => new Density1DMark('areaY', {
      table: 'native_density_dates', options: { filterBy: selection }
    }, { x: 'd', fill: 'category', bins: 8, bandwidth: 4 }, native));
    try {
      const rows = Array.from(await state.coordinator.query(state.mark.query()));
      expect(rows.reduce((sum, row) => sum + Number(row.density), 0)).toBeCloseTo(10, 10);
      expect(new Date(Number(columns(state.mark).d[0])).toISOString()).toBe('2024-01-01T00:00:00.000Z');
      expect(state.plot.element.querySelectorAll('g[aria-label="area"] path')).toHaveLength(2);
      expect(state.errors).toEqual([]);
    } finally { state.close(); }
  });
});

describe('native dense line marks', () => {
  it('rasterizes real series with normalization and stable native group aliases', async () => {
    const normalize = Param.value(false);
    const state = await mount((native, selection) => new DenseLineMark({
      table: 'native_vertical', options: { filterBy: selection }
    }, { x: 't', y: 'v', z: 'series', fill: 'category', width: 2, height: 5, normalize }, native));
    try {
      const query = () => state.coordinator.query(state.mark.query());
      const pixels = Array.from(await query());
      const rows = pixels.filter(row => row.category === 'a');
      expect(rows.map(row => Number(row.index))).toEqual([0, 2, 5, 7, 9]);
      expect(rows.map(row => Number(row.density))).toEqual([1, 1, 1, 1, 1]);
      const descending = pixels.filter(row => row.category === 'b');
      expect(descending.map(row => Number(row.index))).toEqual([3, 5, 6, 8]);
      expect(descending.map(row => Number(row.density))).toEqual([1, 1, 1, 1]);
      expect(state.mark.groupby).toEqual(['category']);
      expect(state.plot.element.querySelectorAll('g[aria-label="image"] image')).toHaveLength(2);
      normalize.update(true);
      await normalize.pending('value');
      await new Promise(resolve => requestAnimationFrame(resolve));
      await state.mark.pending;
      const weights = Array.from(await query());
      const normalized = weights.filter(row => row.category === 'a');
      normalized.forEach((row, index) => expect(Number(row.density)).toBeCloseTo(index < 2 ? 0.5 : 1 / 3, 10));
      expect(weights.filter(row => row.category === 'b').map(row => Number(row.density))).toEqual([0.5, 0.5, 0.5, 0.5]);
      expect(state.plot.element.outerHTML).not.toMatch(/NaN|Infinity/);
      expect(state.errors).toEqual([]);
    } finally { state.close(); }
  });

  it('keeps crossing segments while preserving non-axis and OR filter scopes', async () => {
    const relation = sql.from('native_vertical', 'source lines');
    const x = sql.column('t', 'source lines');
    const y = sql.column('v', 'source lines');
    const state = await mount((native, selection) => new DenseLineMark({
      table: relation, options: { filterBy: selection }
    }, { x, y, z: sql.column('series', 'source lines'), fill: sql.column('category', 'source lines'), width: 2, height: 5, normalize: false }, native));
    try {
      const interval = state.native.interval(x, [0.2, 0.8], { source: {} });
      const point = state.native.point(sql.column('category', 'source lines'), 'a', { source: {} });
      const source = await state.coordinator.query(sql.Query.from(relation).select({ n: sql.count() }).where(interval.predicate));
      expect(Number(source.get(0).n)).toBe(0);
      const crossing = Array.from(await state.coordinator.query(state.mark.query(sql.and(interval.predicate, point.predicate))));
      expect(crossing.length).toBeGreaterThan(0);
      expect(crossing.every(row => row.category === 'a')).toBe(true);
      const disjunction = Array.from(await state.coordinator.query(state.mark.query(sql.or(interval.predicate, point.predicate))));
      expect(disjunction.length).toBeGreaterThan(0);
      expect(disjunction.every(row => row.category === 'a')).toBe(true);
      expect(Array.from(state.plot.getAttribute('xDomain'))).toEqual([0, 1]);
      expect(disjunction.reduce((total, row) => total + Number(row.density), 0)).toBe(5);
      const empty = await state.coordinator.query(state.mark.query(sql.and(interval.predicate,
        state.native.point(sql.column('category', 'source lines'), 'missing', { source: {} }).predicate)));
      expect(empty.numRows).toBe(0);
      expect(state.errors).toEqual([]);
    } finally { state.close(); }
  });
});
