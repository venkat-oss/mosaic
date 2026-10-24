import { Query, and, lineDensity } from '@uwdata/mosaic-sql';
import * as nativeSQL from '@uwdata/mosaic-sql/native';
import { binExpr, nativeBinExpr } from './util/bin-expr.js';
import { extentX, extentY } from './util/extent.js';
import { handleParam } from './util/handle-param.js';
import { RasterMark } from './RasterMark.js';

export class DenseLineMark extends RasterMark {
  constructor(source, options, sqlContext = null) {
    const { normalize = true, ...rest } = options;
    super(source, rest, sqlContext);

    /** @type {boolean} */
    this.normalize = handleParam(normalize, value => {
      return (this.normalize = value, this.requestUpdate());
    });
  }

  query(filter = []) {
    if (this.sqlContext) return this.nativeQuery(filter);
    const { channels, normalize, pad } = this;
    const [nx, ny] = this.bins = this.binDimensions();
    const [x] = binExpr(this, 'x', nx, extentX(this, filter), pad);
    const [y] = binExpr(this, 'y', ny, extentY(this, filter), pad);

    const q = Query
      .from(this.sourceTable())
      .where(stripXY(this, filter));

    this.aggr = ['density'];
    const groupby = this.groupby = [];
    const z = [];
    for (const c of channels) {
      if (Object.hasOwn(c, 'field')) {
        const { channel, field } = c;
        if (channel === 'z') {
          q.select({ [channel]: field });
          z.push('z');
        } else if (channel !== 'x' && channel !== 'y') {
          q.select({ [channel]: field });
          groupby.push(channel);
        }
      }
    }

    return lineDensity(q, x, y, z, nx, ny, groupby, normalize);
  }

  nativeQuery(filter) {
    const channels = this.queryChannels();
    const [nx, ny] = this.bins = this.binDimensions();
    const [x] = nativeBinExpr(this, 'x', nx, extentX(this, filter), this.pad);
    const [y] = nativeBinExpr(this, 'y', ny, extentY(this, filter), this.pad);
    const query = nativeSQL.Query.from(nativeSQL.from(this.sourceTable())).where(nativeStripXY(this, filter));
    this.aggr = ['density'];
    const groups = this.groupby = [];
    const series = [];
    for (const entry of channels) {
      if (!entry.field || entry.channel === 'x' || entry.channel === 'y' || entry.channel === 'orderby') continue;
      query.select({ [entry.as]: entry.field });
      const dimensions = entry.channel === 'z' ? series : groups;
      if (!dimensions.includes(entry.as)) dimensions.push(entry.as);
    }
    return nativeSQL.lineDensity(query, x, y, series, nx, ny, groups, this.normalize).orderby(groups, 'index');
  }
}

function nativeStripXY(mark, filter) {
  const key = expression => mark.sqlContext.structuralKey(nativeSQL.asNode(expression));
  const axes = new Set(['x', 'y'].map(channel => {
    const entry = mark.channelField(channel);
    return key(entry.column ?? entry.field);
  }));
  const boundary = expression => 'literal' in expression
    && (expression.literal.literal_type === 'number' && Number.isFinite(Number(expression.literal.value))
      || expression.literal.literal_type === 'date' || expression.literal.literal_type === 'timestamp');
  const strip = input => {
    if (!nativeSQL.isExpression(input) && !nativeSQL.isExpressionHandle(input)) return input;
    const terms = [];
    const flatten = node => {
      if ('and' in node) { flatten(node.and.left); flatten(node.and.right); }
      else terms.push(node);
    };
    flatten(nativeSQL.rootExpression(input));
    const ranges = new Map;
    const remove = new Set;
    terms.forEach((node, index) => {
      if ('between' in node && !node.between.not && !node.between.symmetric && axes.has(key(node.between.this))
        && boundary(node.between.low) && boundary(node.between.high)) {
        remove.add(index);
        return;
      }
      const low = 'gte' in node ? node.gte : 'gt' in node ? node.gt : null;
      const high = 'lte' in node ? node.lte : 'lt' in node ? node.lt : null;
      const comparison = low ?? high;
      if (!comparison) return;
      const left = key(comparison.left);
      const right = key(comparison.right);
      const field = axes.has(left) && boundary(comparison.right) ? left
        : axes.has(right) && boundary(comparison.left) ? right : undefined;
      if (field === undefined) return;
      const direction = field === left ? !!low : !!high;
      const range = ranges.get(field) ?? { low: [], high: [] };
      range[direction ? 'low' : 'high'].push(index);
      ranges.set(field, range);
    });
    for (const range of ranges.values()) {
      if (range.low.length && range.high.length) [...range.low, ...range.high].forEach(index => remove.add(index));
    }
    const remaining = terms.filter((_, index) => !remove.has(index));
    return remaining.length ? nativeSQL.and(remaining) : undefined;
  };
  return [filter].flat().map(strip).filter(value => value !== undefined);
}

// strip x, y fields from filter predicate
// to prevent improper clipping of line segments
// TODO: improve, perhaps with supporting query utilities
function stripXY(mark, filter) {
  if (Array.isArray(filter) && !filter.length) return filter;

  // get column expressions for x and y encoding channels
  const xc = mark.channelField('x').column;
  const yc = mark.channelField('y').column;

  // test if a range predicate filters the x or y channels
  const test = p => {
    const col = `${p.expr}`;
    return p.type !== 'BETWEEN' || (col !== xc && col !== yc);
  };

  // filter boolean 'and' operations
  const filterAnd = p => p.op === 'AND'
    ? and(p.clauses.filter(c => test(c)))
    : p;

  return Array.isArray(filter)
    ? filter.filter(p => test(p)).map(p => filterAnd(p))
    : filterAnd(filter);
}
