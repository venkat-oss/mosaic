import * as sql from '@uwdata/mosaic-sql';
import { Transform } from '../symbols.js';
import { channelScale } from '../marks/util/channel-scale.js';

const EXTENT = new Set([
  'rectY-x', 'rectX-y', 'rect-x', 'rect-y', 'ruleY-x', 'ruleX-y'
]);
const bins = new WeakMap;

/** @typedef {import('@uwdata/mosaic-sql').SqlExpression} BinExpression */
/** @typedef {Record<string, BinExpression>} BinChannels */

export function hasExtent(mark, channel) {
  return EXTENT.has(`${mark.type}-${channel}`);
}

export function bin(field, options = {}) {
  /** @returns {BinChannels} */
  const fn = (mark, channel) => {
    const source = sql.asNode(field);
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
  const info = { mark, channel, source: column, options };
  const expression = sql.deferred(() => resolveBin(info), sql.params(column));
  bins.set(expression, info);
  return expression;
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
    ? sql.binDate(source, [entry.min, entry.max], options)
    : sql.binHistogram(source, [entry.min, entry.max], options, channelScale(mark, channel));
}

export function resolveBins(expression, memo = new Map) {
  const replacements = new Map;
  sql.walk(expression, node => {
    const info = bins.get(node);
    if (info) {
      if (!memo.has(node)) memo.set(node, resolveBin(info));
      replacements.set(node, memo.get(node));
    }
  });
  return replacements.size ? sql.rewrite(expression, replacements) : expression;
}

function hasTimeScale(mark, channel) {
  const scale = mark.plot.getAttribute(`${channel}Scale`);
  return scale === 'utc' || scale === 'time';
}
