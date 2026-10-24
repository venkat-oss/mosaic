import { erfinv } from './util/stats.js';
import { Mark, markPlotSpec, markQuery, nativeMarkQuery } from './Mark.js';
import { handleParam } from './util/handle-param.js';

export class ErrorBarMark extends Mark {
  constructor(type, source, options, sqlContext = null) {
    const dim = type.endsWith('X') ? 'y' : 'x';
    const { ci = 0.95, ...channels } = options;
    super(type, source, channels, undefined, sqlContext);
    this.dim = dim;
    this.field = this.channelField(dim).field;
    this.channels = this.channels.filter(c => c.channel !== dim);

    /** @type {number} */
    this.ci = handleParam(ci, value => {
      return (this.ci = value, this.update());
    });
  }

  query(filter = []) {
    return errorBarQuery(this, this.sql, filter);
  }

  plotSpecs() {
    const { type, dim, detail, data, ci, channels } = this;

    // compute confidence interval channels
    const p = Math.SQRT2 * erfinv(ci);
    // @ts-expect-error Correct the data column type
    const { columns: { __avg__: u, __se__: s } } = data;
    const options = {
      [`${dim}1`]: u.map((u, i) => u - p * s[i]),
      [`${dim}2`]: u.map((u, i) => u + p * s[i])
    };

    return markPlotSpec(type, detail, channels, data, options);
  }
}

function errorBarQuery(mark, sql, filter) {
  const { field } = mark;
  const { avg, count, div, sqrt, stddev } = sql;
  const channels = mark.queryChannels();
  const fields = channels.concat([
    { field: avg(field), as: '__avg__' },
    { field: div(stddev(field), sqrt(count(field))), as: '__se__', }
  ]);
  const query = mark.sqlOwner ? nativeMarkQuery(fields, mark.sourceTable()) : markQuery(fields, mark.sourceTable());
  return query.where(filter);
}
