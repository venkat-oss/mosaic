import assert from 'node:assert/strict';
import { test, afterAll, vi } from 'vitest';
import { tableFromArrays } from '@uwdata/flechette';
import { Grid2DMark } from '../src/marks/Grid2DMark.js';
import { Density2DMark } from '../src/marks/Density2DMark.js';
import { ContourMark } from '../src/marks/ContourMark.js';
import { DenseLineMark } from '../src/marks/DenseLineMark.js';
import { RasterTileMark } from '../src/marks/RasterTileMark.js';
import { RasterMark } from '../src/marks/RasterMark.js';
import { Param } from '@uwdata/mosaic-core';
import { sum } from '@uwdata/mosaic-sql';
const databaseModule = new URL('../../../server/duckdb/src/DuckDB.js', import.meta.url).href;
const { DuckDB } = await import(databaseModule);
const database = new DuckDB(':memory:', {}, '');
await database.exec(`
  CREATE TABLE grid_data(x DOUBLE, y DOUBLE, series VARCHAR, value DOUBLE);
  INSERT INTO grid_data VALUES
    (0,0,'A',1),(1,1,'A',2),(2,2,'A',3),(3,3,'A',4),(4,4,'A',5),
    (0,4,'B',2),(1,3,'B',3),(2,2,'B',4),(3,1,'B',5),(4,0,'B',6)
`);

function ready(mark) {
  for (const dim of ['x', 'y']) {
    Object.assign(mark.channelField(dim), {type: 'number', min: 0, max: 4});
  }
  const attrs = {xDomain: [0, 4], yDomain: [0, 4]};
  mark.plot = {
    innerWidth: () => 100,
    innerHeight: () => 80,
    getAttribute: key => attrs[key],
    setAttribute: (key, value) => attrs[key] = value,
    update: () => Promise.resolve(),
  };
  return mark;
}

function grid(options = {}) {
  return ready(new Grid2DMark('dot', {table: 'grid_data'}, {
    x: 'x', y: 'y', width: 5, height: 5, pad: 1, ...options,
  }));
}

function arrow(rows) {
  const columns = Object.keys(rows[0]).map(key => [
    key,
    key === 'series'
      ? rows.map(row => row[key])
      : Float64Array.from(rows.map(row => Number(row[key]))),
  ]);
  return tableFromArrays(Object.fromEntries(columns));
}

async function compute(mark) {
  mark.queryResult(arrow(await database.query(String(mark.query()))));
  return mark;
}

test('grid resolution and pad preserve SQL bin inclusion independently of smoothing', async () => {
  const mark = grid();
  assert.deepEqual(mark.binDimensions(), [5, 5]);
  mark.width = undefined;
  mark.height = undefined;
  mark.pixelSize = 4;
  assert.deepEqual(mark.binDimensions(), [25, 20]);
  mark.width = 5;
  mark.height = 5;
  for (const [pad, total] of [[1, 10], [0, 7]]) {
    mark.pad = pad;
    const query = String(mark.query());
    assert.doesNotMatch(query, /deriche|gaussian/);
    const rows = await database.query(query);
    assert.equal(rows.reduce((n, row) => n + Number(row.density), 0), total);
  }
});

test('interpolation modes fill grids and reject unsupported values at the retained client boundary', async () => {
  for (const interpolate of ['none', 'linear', 'nearest', 'barycentric', 'random-walk']) {
    const mark = await compute(grid({ interpolate }));
    assert.equal(mark.grids0.columns.density[0].length, 25);
    assert.ok([...mark.grids0.columns.density[0]].every(Number.isFinite));
  }
  const mark = grid({ interpolate: 'invalid' });
  const rows = await database.query(String(mark.query()));
  assert.throws(() => mark.queryResult(arrow(rows)), /invalid interpolate: invalid/);
});

test('linear binning preserves mass and rejects custom aggregate combinations', async () => {
  const mark = grid({ interpolate: 'linear' });
  const rows = await database.query(String(mark.query()));
  assert.ok(Math.abs(rows.reduce((n, row) => n + Number(row.density), 0) - 10) < 1e-12);
  assert.throws(() => grid({ interpolate: 'linear', fill: sum('value') }).query(), /not applicable to custom aggregates/);
  assert.throws(() => grid({ interpolate: 'linear', fill: sum('value'), fillOpacity: sum('value') }).query(), /not applicable to multiple aggregates/);
  assert.throws(() => grid({ weight: 'value', fill: sum('value') }).query(), /Weight option can not be used with custom aggregates/);
});

test('density resolves derived channels and consumes its base type option', async () => {
  for (const type of ['dot', 'circle', 'hexagon', 'cell', 'text']) {
    const mark = await compute(ready(new Density2DMark({ table: 'grid_data' }, { x: 'x', y: 'y', width: 5, height: 5, bandwidth: 8, fill: 'density', type })));
    assert.equal(mark.type, type);
    assert.equal(mark.channelField('type'), null);
    assert.equal(mark.data.numRows, 25);
    assert.equal(mark.plotSpecs()[0].options.fill.length, 25);
    assert.ok([...mark.data.columns.density].every(Number.isFinite));
  }
});

test('bandwidth and contour thresholds update from existing bins without another SQL query', async () => {
  const bandwidth = Param.value(4);
  const mark = await compute(ready(new ContourMark({ table: 'grid_data' }, { x: 'x', y: 'y', width: 5, height: 5, bandwidth, thresholds: [0.1, 0.3], fill: 'density' })));
  assert.equal(mark.contourData.length, 2);
  assert.ok(mark.contourData.every(item => item.type === 'MultiPolygon'));
  let queries = 0;
  mark.query = () => {
    queries++;
    throw new Error('unexpected query');
  };
  await bandwidth.update(8);
  assert.equal(queries, 0);
  assert.equal(mark.bandwidth, 8);
});

test('dense line SQL bins segments and preserves optional normalization', async () => {
  for (const normalize of [true, false]) {
    const mark = ready(new DenseLineMark({ table: 'grid_data' }, { x: 'x', y: 'y', z: 'series', width: 5, height: 5, normalize }));
    const sql = String(mark.query());
    assert.match(sql, /UNNEST|unnest/);
    const rows = await database.query(sql);
    assert.ok(rows.length > 0);
    assert.ok(rows.every(row => Number.isFinite(Number(row.density))));
  }
});

test('raster tile retains origin and its independent SQL tile-query contract', async () => {
  const mark = ready(new RasterTileMark({ table: 'grid_data' }, { x: 'x', y: 'y', width: 5, height: 5, origin: [-4, -4], fill: 'density' }));
  assert.deepEqual(mark.origin, [-4, -4]);
  assert.equal(mark.query(), null);
  mark.bins = mark.binDimensions();
  const rows = await database.query(String(mark.tileQuery([[0, 4], [0, 4]])));
  assert.equal(rows.reduce((n, row) => n + Number(row.density), 0), 10);
});

test('raster clients recolor cached images once and resize their buffers', () => {
  const canvases = [];
  const writes = [];
  vi.stubGlobal('document', {
    createElement() {
      let pixels;
      const canvas = {
        setAttribute() {},
        getContext: () => ({
          getImageData: (x, y, w, h) => ({ data: new Uint8ClampedArray(w * h * 4) }),
          putImageData(image) { pixels = Uint8Array.from(image.data); writes.push(pixels); }
        }),
        toDataURL: () => `data:image/raw;base64,${Buffer.from(pixels).toString('base64')}`
      };
      canvases.push(canvas);
      return canvas;
    }
  });
  try {
    for (const Client of [RasterMark, RasterTileMark]) {
      const mark = ready(new Client(null, { x: 'x', y: 'y', fill: 'density', width: 2, height: 2, imageRendering: 'pixelated' }));
      const listeners = new Map();
      Object.assign(mark.plot, {
        addParams() {},
        addAttributeListener(name, callback) { assert.ok(!listeners.has(name)); listeners.set(name, callback); }
      });
      mark.setPlot(mark.plot, 3);
      mark._fieldInfo = true;
      mark.plot.setAttribute('colorDomain', [0, 3]);
      mark.plot.setAttribute('colorScheme', 'greys');
      mark.bins = [2, 2];
      mark.aggr = ['density'];
      mark.groupby = [];
      mark.grids0 = { numRows: 1, columns: { density: [Float64Array.from([0, 1, 2, 3])] } };
      const before = writes.length;
      assert.equal(mark.convolve(), mark);
      assert.equal(writes.length, before + 1);
      assert.deepEqual([...writes.at(-1).slice(4, 12)], [0, 0, 0, 255, 255, 255, 255, 255]);
      const pixels = writes.at(-1);
      const image = mark.image;
      const spec = mark.plotSpecs()[0];
      assert.equal(spec.type, 'image');
      assert.deepEqual(spec.data, { length: 1 });
      assert.equal(spec.options.src, mark.data.columns.src);
      assert.equal(spec.options.width, 100);
      assert.equal(spec.options.height, 80);
      assert.equal(spec.options.imageRendering, 'pixelated');
      mark.convolve();
      assert.equal(mark.image, image);
      mark.plot.setAttribute('colorScheme', 'reds');
      listeners.get('schemeColor')();
      assert.equal(writes.length, before + 3);
      assert.equal(mark.image, image);
      assert.notDeepEqual(writes.at(-1), pixels);
      mark.bins = [3, 2];
      mark.grids0.columns.density = [Float64Array.from([0, 1, 2, 3, 2, 1])];
      mark.convolve();
      assert.notEqual(mark.image, image);
      assert.equal(mark.image.img.data.length, 24);
    }
    assert.equal(canvases.length, 4);
  } finally {
    vi.unstubAllGlobals();
  }
});

afterAll(() => database.close());
