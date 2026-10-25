import { asNode, bin1d } from '@uwdata/mosaic-sql';
import { resolveBins } from '../../transforms/bin.js';
import { channelScale } from './channel-scale.js';

/**
 * Generates a SQL expression for 1D pixel-level binning.
 * Adjusts for scale transformations (log, sqrt, ...).
 * Returns a [binExpression, field] array, where field is the
 * input value being binned. Often the field is just a column
 * name. For time data, fields are mapped to millisecond timestamps.
 * @returns {[import('@uwdata/mosaic-sql').SqlExpression, import('@uwdata/mosaic-sql').SqlExpression]}
 */
export function binExpr(mark, channel, n, extent, pad = 1, expr) {
  const field = resolveBins(asNode(expr ?? mark.channelField(channel).field));
  const { type, apply, sqlApply } = channelScale(mark, channel);
  const { lo, hi, bins, reverse } = binOptions(mark, channel, n, extent, pad, apply);
  const value = sqlApply(field);
  return [bin1d(value, lo, hi, bins, reverse), type === 'time' || type === 'utc' ? value : field];
}

function binOptions(mark, channel, n, extent, pad, apply) {
  const [lo, hi] = extent.map(value => apply(value));
  return { lo, hi, bins: n - pad, reverse: !!mark.plot.getAttribute(`${channel}Reverse`) };
}
