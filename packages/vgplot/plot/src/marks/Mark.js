/** @import { SelectQuery } from '@uwdata/mosaic-sql' */
/** @import { DataColumns } from '@uwdata/mosaic-core' */
import { isParam, MosaicClient, queryFieldInfo, toDataColumns } from '@uwdata/mosaic-core';
import { Query, collectParams, column, isAggregateExpression, isColumnParam, isColumnRef, isNode, isParamLike, unnest } from '@uwdata/mosaic-sql';
import * as legacySQL from '@uwdata/mosaic-sql';
import * as nativeSQL from '@uwdata/mosaic-sql/native';
import { binInfo, resolveBins } from '../transforms/bin.js';
import { isColor } from './util/is-color.js';
import { isConstantOption } from './util/is-constant-option.js';
import { isSymbol } from './util/is-symbol.js';
import { Transform } from '../symbols.js';

const isColorChannel = channel => channel === 'stroke' || channel === 'fill';
const isOpacityChannel = channel => /opacity$/i.test(channel);
const isSymbolChannel = channel => channel === 'symbol';

// column name for a plain column reference or name string, else null
const unnestableColumn = (field, native = false) => {
  if (field == null) return null;
  return native
    ? typeof field === 'string' ? field : nativeSQL.columnParts(nativeSQL.rootExpression(field))?.at(-1)
    : isColumnRef(field) ? field.column : typeof field === 'string' ? field : null;
};
const isFieldObject = (channel, field) => {
  return channel !== 'sort' && channel !== 'tip'
    && field != null && !Array.isArray(field);
};
const isNativeField = (channel, field) => nativeSQL.isExpressionHandle(field)
  || isFieldObject(channel, field) && nativeSQL.isExpression(field);
const fieldEntry = (channel, field, native = false) => ({
  channel,
  field,
  as: native
    ? nativeSQL.columnParts(field)?.at(-1) ?? channel
    : isColumnRef(field) && !isColumnParam(field) ? field.column : channel
});
const valueEntry = (channel, value) => ({ channel, value });

// checks if a data source is an explicit array of values
// as opposed to a database table reference
export const isDataArray = source => Array.isArray(source);

/**
 * The minimal mark surface consumed by interactors, allowing marks
 * and lightweight stand-ins to be used interchangeably.
 * @typedef {object} InteractorMark
 * @property {import('../plot.js').Plot} plot
 *   The plot the mark belongs to.
 * @property {(channel: string, options?: { exact?: boolean }) =>
 *   ({ field?: any, as?: any } | null | undefined)} channelField
 *   Look up the channel entry bound to a channel, if any.
 * @property {(field: any) => boolean} isUnnested
 *   Whether the given field is unnested by the mark's source.
 * @property {DataColumns} [data]
 *   Materialized column data, when available.
 * @property {number} [index]
 *   The mark's index within the plot.
 * @property {import('@uwdata/mosaic-core').NativeSqlContext | null} [sqlContext]
 */

/**
 * @implements {InteractorMark}
 */
export class Mark extends MosaicClient {
  constructor(type, source, encodings, reqs = {}, sqlContext = null) {
    super(source?.options?.filterBy, sqlContext);
    this.type = type;
    this.reqs = reqs;
    this.source = source;
    this.sqlContext = sqlContext;
    this.sql = sqlContext ? nativeSQL : legacySQL;

    const channels = this.channels = [];
    const detail = this.detail = new Set;
    const params = this.params = new Set;

    if (isDataArray(source)) {
      this.data = toDataColumns(source);
    } else if (isParam(source?.table)) {
      params.add(source.table);
    }

    const process = (channel, entry) => {
      const type = typeof entry;
      if (channel === 'channels') {
        for (const name in entry) {
          detail.add(name);
          process(name, entry[name]);
        }
      } else if (type === 'function' && entry[Transform]) {
        const enc = entry(this, channel);
        for (const key in enc) {
          process(key, enc[key]);
        }
      } else if (type === 'string') {
        if (
          isConstantOption(channel) ||
          isColorChannel(channel) && isColor(entry) ||
          isSymbolChannel(channel) && isSymbol(entry)
        ) {
          // interpret constants and color/symbol names as values, not fields
          channels.push(valueEntry(channel, entry));
        } else {
          channels.push(fieldEntry(channel, sqlContext ? nativeSQL.column(entry) : column(entry), !!sqlContext));
        }
      } else if (isParamLike(entry)) {
        const c = valueEntry(channel, entry.value);
        channels.push(c);
        // @ts-expect-error FIXME
        entry.addEventListener('value', value => {
          // update immediately, the value is simply passed to Plot
          c.value = value;
          return this.update();
        });
      } else if (sqlContext && isNativeField(channel, entry)) {
        const field = nativeSQL.asNode(entry);
        nativeSQL.params(field).forEach(p => params.add(p));
        channels.push(fieldEntry(channel, field, true));
      } else if (isNode(entry)) {
        if (sqlContext) throw new TypeError('Native marks require native SQL expressions.');
        collectParams(entry).forEach(p => params.add(p));
        channels.push(fieldEntry(channel, entry))
      } else if (isNativeField(channel, entry)) {
        throw new TypeError('Native SQL expressions require a native plot context.');
      } else if (type === 'object' && isFieldObject(channel, entry)) {
        channels.push(fieldEntry(channel, entry));
      } else if (entry !== undefined) {
        channels.push(valueEntry(channel, entry));
      }
    };

    for (const channel in encodings) {
      process(channel, encodings[channel]);
    }
  }

  /**
   * @param {import('../plot.js').Plot} plot The plot.
   * @param {number} index
   */
  setPlot(plot, index) {
    this.plot = plot;
    this.index = index;
    plot.addParams(this, this.params);
    if (this.sqlOwner && this.channels.some(c => binInfo(c.field))) {
      for (const channel of ['x', 'y']) {
        for (const name of ['Scale', 'Base', 'Exponent', 'Constant']) {
          plot.addAttributeListener(channel + name, () => this.initialize());
        }
      }
    }
    if (this.source?.table) this.queryPending();
  }

  sourceTable() {
    const table = this.source?.table;
    return table ? (isParam(table) ? table.value : table) : null;
  }

  /**
   * The source field names to unnest, as declared by the `unnest` option.
   * @returns {string[]}
   */
  get unnestFields() {
    const { unnest } = this.source?.options ?? {};
    return unnest == null ? [] : [unnest].flat();
  }

  /**
   * Check if the given field is unnested by this mark's source.
   * @param {*} field A field reference or column name.
   * @returns {boolean}
   */
  isUnnested(field) {
    const name = unnestableColumn(field, !!this.sqlOwner);
    return name != null && this.unnestFields.includes(name);
  }

  hasOwnData() {
    return this.source == null || isDataArray(this.source);
  }

  hasFieldInfo() {
    return !!this._fieldInfo;
  }

  initialize() {
    if (this.sqlOwner) this._fieldInfo = false;
    return super.initialize();
  }

  channel(channel) {
    return this.channels.find(c => c.channel === channel);
  }

  channelField(channel, { exact = false } = {}) {
    const c = exact
      ? this.channel(channel)
      : this.channels.find(c => c.channel.startsWith(channel));
    return c?.field ? c : null;
  }

  async prepare() {
    if (this.hasOwnData()) return null;
    if (this.sqlOwner) return this.prepareNative();

    const { channels, reqs } = this;
    const fields = new Map;
    for (const { channel, field } of channels) {
      if (!field) continue;
      const stats = field.stats?.stats || [];
      const key = field.stats?.column ?? field;
      const entry = fields.get(key) ?? fields.set(key, new Set).get(key);
      stats.forEach(s => entry.add(s));
      reqs[channel]?.forEach(s => entry.add(s));
    }

    const table = this.sourceTable();
    const info = await queryFieldInfo(
      this.coordinator,
      Array.from(fields, ([c, s]) => ({ table, column: c, stats: Array.from(s) }))
    );

    const lookup = Object.fromEntries(info.map(x => [x.column, x]));
    for (const entry of this.channels) {
      const { field } = entry;
      if (field) {
        Object.assign(entry, lookup[field.stats?.column ?? field]);
      }
    }
    this._fieldInfo = true;
  }

  async prepareNative() {
    const pending = this.pending;
    const table = this.sourceTable();
    const requests = new Map;
    const projected = [];
    for (const entry of this.channels) {
      if (!entry.field) continue;
      const info = binInfo(entry.field);
      const field = info?.source ?? entry.field;
      if (nativeSQL.isAggregateExpression(field) || isWindowExpression(field)) {
        projected.push(entry);
        continue;
      }
      const request = requests.get(field) ?? { table, column: field, stats: new Set, entries: [] };
      if (info) ['min', 'max'].forEach(stat => request.stats.add(stat));
      this.reqs[entry.channel]?.forEach(stat => request.stats.add(stat));
      request.entries.push(entry);
      requests.set(field, request);
    }
    const base = [...requests.values()];
    const metadata = await queryFieldInfo(this.coordinator, base.map(({ stats, ...request }) => ({ ...request, stats: [...stats] })));
    if (this.pending !== pending || !this.coordinator) return;
    metadata.forEach((info, index) => base[index].entries.forEach(entry => Object.assign(entry, info)));
    this._fieldInfo = true;
    if (projected.length) {
      const channels = this.queryChannels();
      const query = nativeMarkQuery(channels, table);
      const fields = projected.map(entry => {
        const field = channels.find(channel => channel === entry || channel.channel === entry.channel)?.field;
        return { table, column: field, stats: this.reqs[entry.channel] ?? [] };
      });
      const info = await queryFieldInfo(this.coordinator, fields, { query });
      if (this.pending !== pending || !this.coordinator) return;
      info.forEach((value, index) => Object.assign(projected[index], value));
    }
    this._fieldInfo = true;
  }

  queryChannels() {
    if (!this.sqlOwner) return this.channels;
    const memo = new Map;
    return this.channels.map(entry => entry.field
      ? { ...entry, field: resolveBins(entry.field, memo) }
      : entry);
  }

  /**
   * Return a query specifying the data needed by this Mark client.
   * @param {*} [filter] The filtering criteria to apply in the query.
   * @returns {*} The client query
   */
  query(filter = []) {
    if (this.hasOwnData()) return null;
    const { unnestFields } = this;
    const prepared = this.queryChannels();
    // wrap unnested column fields in UNNEST() so arrays expand into rows
    const channels = unnestFields.length === 0
      ? prepared
      : prepared.map(c => {
          if (!c.field) return c;
          const name = unnestableColumn(c.field, !!this.sqlOwner);
          return name != null && unnestFields.includes(name)
            ? { ...c, field: this.sqlOwner ? nativeSQL.unnest(c.field) : unnest(c.field) }
            : c;
        });
    const query = this.sqlOwner ? nativeMarkQuery(channels, this.sourceTable()) : markQuery(channels, this.sourceTable());
    return query.where(filter);
  }

  queryPending() {
    this.plot.pending(this);
    return this;
  }

  /**
   * Provide query result data to the mark.
   */
  queryResult(data) {
    this.data = toDataColumns(data);
    return this;
  }

  update() {
    return this.plot.update(this);
  }

  /**
   * Generate an array of Plot mark specifications.
   * @returns {object[]}
   */
  plotSpecs() {
    const { type, data, detail, channels } = this;
    return markPlotSpec(type, detail, channels, data);
  }
}

/**
 * Helper method for setting a channel option in a Plot specification.
 * Checks if a constant value or a data field is needed.
 * Also avoids misinterpretation of data values as color names.
 * @param {*} c a visual encoding channel spec
 * @param {object} [columns] named data column arrays
 * @returns the Plot channel option
 */
export function channelOption(c, columns) {
  // use a scale override for color channels to sidestep
  // https://github.com/observablehq/plot/issues/1593
  const value = columns?.[c.as] ?? c.as;
  return Object.hasOwn(c, 'value') ? c.value
    : isColorChannel(c.channel) ? { value, scale: 'color' }
    : isOpacityChannel(c.channel) ? { value, scale: 'opacity' }
    : value;
}

/**
 * Default query construction for a mark.
 * Tracks aggregates by checking fields for an aggregate flag.
 * If aggregates are found, groups by all non-aggregate fields.
 * @param {*} channels array of visual encoding channel specs.
 * @param {*} table the table to query.
 * @param {*} skip an optional array of channels to skip.
 *  Mark subclasses can skip channels that require special handling.
 * @returns {SelectQuery} a Query instance
 */
export function markQuery(channels, table, skip = []) {
  return populateQuery(Query.from({ source: table }), channels, skip, isAggregateExpression);
}

export function nativeMarkQuery(channels, table, skip = []) {
  return populateQuery(nativeSQL.Query.from(nativeSQL.from(table)), channels, skip, nativeSQL.isAggregateExpression, isWindowExpression);
}

/**
 * @template {SelectQuery | import('@uwdata/mosaic-sql/native').Query} Q
 * @param {Q} q
 * @param {(field: *) => boolean} [window]
 * @returns {Q}
 */
function populateQuery(q, channels, skip, aggregate, window = () => false) {
  const dims = new Set;
  let aggr = false;

  for (const c of channels) {
    const { channel, field, as } = c;
    if (skip.includes(channel)) continue;

    if (channel === 'orderby') {
      q.orderby(c.value ?? field);
    } else if (field) {
      if (aggregate(field)) {
        aggr = true;
      } else if (!window(field)) {
        if (dims.has(as)) continue;
        dims.add(as);
      }
      q.select({ [as]: field });
    }
  }

  if (aggr) {
    q.groupby(Array.from(dims));
  }

  return q;
}

function isWindowExpression(expression) {
  let result = false;
  nativeSQL.walk(expression, node => {
    if ('subquery' in node) return 1;
    if ('window_function' in node) { result = true; return -1; }
  });
  return result;
}


/**
 * Generate an array of Plot mark specifications.
 * @returns {object[]}
 */
export function markPlotSpec(type, detail, channels, data, options = {}) {
  // @ts-ignore
  const { numRows: length, values, columns } = data ?? {};

  // populate plot specification options
  const side = {};
  for (const c of channels) {
    const obj = detail.has(c.channel) ? side : options;
    obj[c.channel] = channelOption(c, columns);
  }
  if (detail.size) options.channels = side;

  // if provided raw source values (not objects) pass as-is
  // otherwise we pass columnar data directy in the options
  const specData = values ?? (data ? { length } : null);
  const spec = [{ type, data: specData, options }];
  return spec;
}
