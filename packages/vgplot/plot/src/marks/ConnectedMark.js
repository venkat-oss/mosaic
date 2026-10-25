import * as sql from '@uwdata/mosaic-sql';
import { binExpr } from './util/bin-expr.js';
import { filteredExtent } from './util/extent.js';
import { Mark } from './Mark.js';

export class ConnectedMark extends Mark {
  constructor(type, source, encodings) {
    const dim = type.endsWith('X') ? 'y' : type.endsWith('Y') ? 'x' : null;
    const req = dim ? { [dim]: ['count', 'min', 'max'] } : undefined;
    super(type, source, encodings, req);
    this.dim = dim;
  }

  /**
   * Return a query specifying the data needed by this Mark client.
   * @param {*} [filter] The filtering criteria to apply in the query.
   * @returns {*} The client query
   */
  query(filter = []) {
    const { plot, dim, source } = this;
    const q = super.query(filter);
    if (!q || !dim) return q;
    let optimize = source?.options?.optimize;

    const ortho = dim === 'x' ? 'y' : 'x';
    const value = this.channelField(ortho, { exact: true })?.as;
    const { field, as, type, count, min, max } = this.channelField(dim);
    const isContinuous = type === 'date' || type === 'number';

    const plotSize = dim === 'x' ? plot.innerWidth() : plot.innerHeight();
    const size = Math.ceil(plotSize * (globalThis.devicePixelRatio || 1))

    optimize ??= (count / size) > 10; // threshold for applying M4

    if (optimize && isContinuous && value) {
      // TODO: handle stacked data
      const [lo, hi] = filteredExtent(filter, field) || [min, max];
      const [expr] = binExpr(this, dim, size, [lo, hi], 1, as);
      const groups = sql.selectEntries(q)
        .map(({ alias }) => alias)
        .filter(alias => alias !== undefined && alias !== as && alias !== value)
        .map(alias => sql.column(alias));
      return sql.m4(q, expr, as, value, groups);
    } else {
      return q.orderby(as);
    }
  }
}
