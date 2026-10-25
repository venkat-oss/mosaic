import { inspectAggregate, isExpression, isExpressionHandle, rootExpression } from '@uwdata/mosaic-sql';
import { binInfo } from '../../transforms/bin.js';

function extractField(field) {
  if (isExpression(field) || isExpressionHandle(field)) {
    const expression = rootExpression(field);
    return binInfo(expression)?.source ?? inspectAggregate(expression)?.args[0] ?? expression;
  }
  return field;
}

export function getField(mark, channel) {
  return extractField(mark.channelField(channel)?.field);
}

export function getFields(mark, channels) {
  const fields = [];
  const as = [];
  channels.forEach(c => {
    const q = c === 'color' ? ['color', 'fill', 'stroke']
      : c === 'x' ? ['x', 'x1', 'x2']
      : c === 'y' ? ['y', 'y1', 'y2']
      : [c];
    for (let i = 0; i < q.length; ++i) {
      const f = mark.channelField(q[i], { exact: true });
      if (f) {
        fields.push(extractField(f.field));
        as.push(f.as);
        return;
      }
    }
    throw new Error(`Missing channel: ${c}`);
  });
  return { fields, as };
}
