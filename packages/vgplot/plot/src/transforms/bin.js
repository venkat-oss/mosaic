/** @import { SQLCodeGenerator } from '@uwdata/mosaic-sql'; */
import { ExprNode, binDate, binHistogram, duckDBCodeGenerator } from '@uwdata/mosaic-sql';
import * as nativeSQL from '@uwdata/mosaic-sql/native';
import { Transform } from '../symbols.js';
import { channelScale, nativeChannelScale } from '../marks/util/channel-scale.js';

const EXTENT = new Set([
  'rectY-x', 'rectX-y', 'rect-x', 'rect-y', 'ruleY-x', 'ruleX-y'
]);
const bins = new WeakMap;

/** @typedef {import('@uwdata/mosaic-sql').ExprNode | import('@uwdata/mosaic-sql/native').SqlExpression} BinExpression */
/** @typedef {Record<string, BinExpression>} BinChannels */

export function hasExtent(mark, channel) {
  return EXTENT.has(`${mark.type}-${channel}`);
}

export function bin(field, options = {}) {
  /** @returns {BinChannels} */
  const fn = (mark, channel) => {
    const source = mark.sqlOwner ? nativeSQL.asNode(field) : field;
    if (hasExtent(mark, channel)) {
      return {
        [`${channel}1`]: binNode(mark, channel, source, options),
        [`${channel}2`]: binNode(mark, channel, source, { ...options, offset: 1 })
      };
    } else {
      return {
        [channel]: binNode(mark, channel, source, options)
      };
    }
  };
  fn[Transform] = true;
  return fn;
}

/** @returns {BinExpression} */
function binNode(mark, channel, column, options) {
  if (mark.sqlOwner) {
    const info = { mark, channel, source: column, options };
    const expression = nativeSQL.deferred(() => resolveBin(info), nativeSQL.params(column));
    bins.set(expression, info);
    return expression;
  }
  return new BinTransformNode(column, mark, channel, options);
}

export function binInfo(expression) {
  return bins.get(expression);
}

function resolveBin({ mark, channel, source, options }) {
  const entry = mark.channelField(channel);
  if (!mark.hasFieldInfo() || !entry || entry.min === undefined || entry.max === undefined) {
    throw new Error('Bin expressions require prepared channel statistics.');
  }
  return options.interval || entry.type === 'date' || hasTimeScale(mark, channel)
    ? nativeSQL.binDate(source, [entry.min, entry.max], options)
    : nativeSQL.binHistogram(source, [entry.min, entry.max], options, nativeChannelScale(mark, channel));
}

export function resolveBins(expression, memo = new Map) {
  const replacements = new Map;
  nativeSQL.walk(expression, node => {
    const info = bins.get(node);
    if (info) {
      if (!memo.has(node)) memo.set(node, resolveBin(info));
      replacements.set(node, memo.get(node));
    }
  });
  return replacements.size ? nativeSQL.rewrite(expression, replacements) : expression;
}

function hasTimeScale(mark, channel) {
  const scale = mark.plot.getAttribute(`${channel}Scale`);
  return scale === 'utc' || scale === 'time';
}

class BinTransformNode extends ExprNode {
  constructor(column, mark, channel, options) {
    super('CUSTOM');
    this.column = column;
    this.mark = mark;
    this.channel = channel;
    this.options = options;
  }

  get stats() {
    return { column: this.column, stats: ['min', 'max'] };
  }

  /**
   * @param {SQLCodeGenerator} visitor
   */
  toString(visitor = duckDBCodeGenerator) {
    const { mark, channel, column, options } = this;
    const { type, min, max } = mark.channelField(channel);
    const isDate = options.interval
      || type === 'date'
      || hasTimeScale(mark, channel);
    const result = isDate
      ? binDate(column, [min, max], options)
      : binHistogram(column, [min, max], options, channelScale(mark, channel));
    return visitor.toString(result);
  }
}
