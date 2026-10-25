import { toDataColumns } from '@uwdata/mosaic-core';
import { array, grid2d } from './util/grid.js';
import { extentX, extentY } from './util/extent.js';
import { RasterMark } from './RasterMark.js';

export class RasterTileMark extends RasterMark {
  constructor(source, options) {
    const { origin = [0, 0], dim = 'xy', ...markOptions } = options;
    super(source, markOptions);

    // TODO: make part of data source instead of options?
    this.origin = origin;
    this.tileX = dim.toLowerCase().includes('x');
    this.tileY = dim.toLowerCase().includes('y');
  }

  query(filter = []) {
    this._filter = filter;
    return null;
  }

  tileQuery(extent) {
    return this.gridQuery(extent, this._filter, this.interpolate === 'linear'
      ? [!this.tileX && !!this.pad, !this.tileY && !!this.pad]
      : !!this.pad);
  }

  update() {
    return this.coordinator ? this.requestTiles() : super.update();
  }

  _cancelQuery() {
    super._cancelQuery();
    this.coordinator?.cancel([...(this.tiles ?? []), ...(this.prefetch ?? [])]);
    this.tiles = null;
    this.prefetch = null;
  }

  destroy() {
    this._cancelQuery();
    super.destroy();
  }

  requestTiles() {
    const mc = this.coordinator;
    this._cancelQuery();
    if (!mc || !this.enabled) return Promise.resolve();
    this.queryPending();

    // get view extent info
    const { pad, tileX, tileY, interpolate, origin: [tx, ty] } = this;
    const linear = interpolate === 'linear';
    const [m, n] = this.bins = this.binDimensions();
    const [x0, x1] = extentX(this, this._filter);
    const [y0, y1] = extentY(this, this._filter);
    const xspan = x1 - x0;
    const yspan = y1 - y0;
    const xx = Math.floor((x0 - tx) * (m - pad) / xspan);
    const yy = Math.floor((y0 - ty) * (n - pad) / yspan);

    const tileExtent = (i, j) => [
      [tx + i * xspan, tx + (i + 1) * xspan],
      [ty + j * yspan, ty + (j + 1) * yspan]
    ];

    // get tile coords that overlap current view extent
    const i0 = Math.floor((x0 - tx) / xspan);
    const i1 = tileX ? (linear && pad ? Math.floor : tileFloor)((x1 - tx) / xspan) : i0;
    const j0 = Math.floor((y0 - ty) / yspan);
    const j1 = tileY ? (linear && pad ? Math.floor : tileFloor)((y1 - ty) / yspan) : j0;

    // query for currently needed data tiles
    const coords = [];
    for (let i = i0; i <= i1; ++i) {
      for (let j = j0; j <= j1; ++j) {
        coords.push([i, j]);
      }
    }
    const queries = this.tiles = coords.map(
      ([i, j]) => mc.query(this.tileQuery(tileExtent(i, j)))
    );

    // prefetch tiles along periphery of current tiles
    const prefetchCoords = [];
    if (tileX) {
      for (let j = j0; j <= j1; ++j) {
        prefetchCoords.push([i1 + 1, j]);
        prefetchCoords.push([i0 - 1, j]);
      }
    }
    if (tileY) {
      const x0 = tileX ? i0 - 1 : i0;
      const x1 = tileX ? i1 + 1 : i1;
      for (let i = x0; i <= x1; ++i) {
        prefetchCoords.push([i, j1 + 1]);
        prefetchCoords.push([i, j0 - 1]);
      }
    }
    /** @type {import('@uwdata/mosaic-core').QueryResult<import('@uwdata/flechette').Table>[]} */
    this.prefetch = prefetchCoords.map(
      ([i, j]) => mc.prefetch(this.tileQuery(tileExtent(i, j)))
    );

    this.prefetch.forEach(request => request.catch(() => {}));
    const current = () => this.tiles === queries && this.coordinator === mc;
    return this._pending = Promise.all(queries).then(tiles => {
      if (!current()) return;
      this.grids0 = processTiles(m, n, pad, xx, yy, coords, tiles, this.aggr, this.groupby, linear);
      this.convolve();
      return super.update();
    }, error => {
      if (current()) throw error;
    });
  }

}

function processTiles(m, n, pad, x, y, coords, tiles, aggregates, groupby, linear) {
  const index = [];
  const names = [...aggregates, ...groupby];
  const columns = Object.fromEntries(names.map(name => [name, []]));
  const prototypes = {};
  tiles.forEach((data, tile) => {
    const [i, j] = coords[tile];
    const tx = i * (m - pad) - x;
    const ty = j * (n - pad) - y;
    const values = toDataColumns(data);
    if (!('columns' in values)) throw new TypeError('Raster tiles require columnar query results.');
    if (values.numRows) aggregates.forEach(name => prototypes[name] ??= values.columns[name]);
    for (let row = 0; row < values.numRows; ++row) {
      const idx = Number(values.columns.index[row]);
      const cx = tx + (idx % m);
      const cy = ty + Math.floor(idx / m);
      if (cx < 0 || cx >= m || cy < 0 || cy >= n) continue;
      index.push(cx + cy * m);
      for (const name of names) columns[name].push(values.columns[name][row]);
    }
  });
  aggregates.forEach(name => {
    const values = columns[name];
    const copy = array(values.length, prototypes[name]);
    values.forEach((value, i) => copy[i] = value);
    columns[name] = copy;
  });
  return grid2d(m, n, index, columns, aggregates, groupby, undefined, linear);
}

function tileFloor(value) {
  const floored = Math.floor(value);
  return floored === value ? floored - 1 : floored;
}
