import { bin1d } from '@uwdata/mosaic-sql';
import { asNode, bin1d as nativeBin1d } from '@uwdata/mosaic-sql/native';
import { resolveBins } from '../../transforms/bin.js';
import { channelScale, nativeChannelScale } from './channel-scale.js';

/**
 * Generates a SQL expression for 1D pixel-level binning.
 * Adjusts for scale transformations (log, sqrt, ...).
 * Returns a [binExpression, field] array, where field is the
 * input value being binned. Often the field is just a column
 * name. For time data, fields are mapped to millisecond timestamps.
 */
export function binExpr(mark, channel, n, extent, pad = 1, expr) {
  // get base expression, the channel field unless otherwise given
  const { field } = mark.channelField(channel);
  expr = expr ?? field;

  // extract scale information
  const { type, apply, sqlApply } = channelScale(mark, channel);
  const { lo, hi, bins, reverse } = binOptions(mark, channel, n, extent, pad, apply);

  // return expressions for (unrounded) bin index and field
  const v = sqlApply(expr);
  const f = type === 'time' || type === 'utc' ? v : expr;
  return [bin1d(v, lo, hi, bins, reverse), f];
}

/** @returns {[import('@uwdata/mosaic-sql/native').SqlExpression, import('@uwdata/mosaic-sql/native').SqlExpression]} */
export function nativeBinExpr(mark, channel, n, extent, pad = 1, expr) {
  const field = resolveBins(asNode(expr ?? mark.channelField(channel).field));
  const { type, apply, sqlApply } = nativeChannelScale(mark, channel);
  const { lo, hi, bins, reverse } = binOptions(mark, channel, n, extent, pad, apply);
  const value = sqlApply(field);
  return [nativeBin1d(value, lo, hi, bins, reverse), type === 'time' || type === 'utc' ? value : field];
}

function binOptions(mark, channel, n, extent, pad, apply) {
  const [lo, hi] = extent.map(value => apply(value));
  return { lo, hi, bins: n - pad, reverse: !!mark.plot.getAttribute(`${channel}Reverse`) };
}
