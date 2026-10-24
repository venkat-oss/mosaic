import { Mark, ConnectedMark } from '@uwdata/mosaic-plot';
import { MARK_DECORATORS, CONNECTED_PREFIXES } from '../generated/mark-profiles.js';

export function mark(type, data, channels = {}) {
  if (arguments.length === 2 && !Array.isArray(data)) {
    channels = data;
    data = MARK_DECORATORS.has(type) ? null : [{}];
  }
  const MarkClass = CONNECTED_PREFIXES.some(prefix => type.startsWith(prefix))
    ? ConnectedMark
    : Mark;
  return explicitType(MarkClass, type, data, channels);
}

export function explicitType(MarkClass, type, data, channels) {
  return plot => {
    plot.addMark(MarkClass === Mark
      ? new MarkClass(type, data, channels, undefined, plot.sqlContext)
      : new MarkClass(type, data, channels, plot.sqlContext));
  };
}

export function implicitType(MarkClass, data, channels) {
  return plot => {
    plot.addMark(new MarkClass(data, channels, plot.sqlContext));
  };
}
