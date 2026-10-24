import { scaleLinear } from 'd3';
import { Fixed, Transient } from '../../symbols.js';
import { BetweenOpNode, walk } from '@uwdata/mosaic-sql';
import * as nativeSQL from '@uwdata/mosaic-sql/native';

export const xext = { x: ['min', 'max'] };
export const yext = { y: ['min', 'max'] };
export const xyext = { ...xext, ...yext };

export function plotExtent(mark, filter, channel, domainAttr, niceAttr) {
  const { plot } = mark;
  const domain = plot.getAttribute(domainAttr);
  const nice = plot.getAttribute(niceAttr);

  if (Array.isArray(domain) && !domain[Transient]) {
    return domain;
  } else {
    const { column, min, max } = mark.channelField(channel);
    const dom = filteredExtent(filter, column) || (nice
      ? scaleLinear().domain([min, max]).nice().domain()
      : [min, max]);
    if (domain !== Fixed) dom[Transient] = true;
    plot.setAttribute(domainAttr, dom, { silent: true });
    return dom;
  }
}

export function extentX(mark, filter) {
  return plotExtent(mark, filter, 'x', 'xDomain', 'xNice');
}

export function extentY(mark, filter) {
  return plotExtent(mark, filter, 'y', 'yDomain', 'yNice');
}

export function filteredExtent(filter, column) {
  if (!filter) return;
  if (nativeSQL.isExpression(column) || nativeSQL.isExpressionHandle(column)) return nativeFilteredExtent(filter, column);

  let lo;
  let hi;
  const field = `${column}`;

  [filter].flat().forEach(p => walk(p, (node) => {
    if (node instanceof BetweenOpNode && `${node.expr}` === field) {
      // @ts-ignore
      const extent = (node.extent ?? []).map(v => v?.value ?? v);
      if (lo == null || extent[0] < lo) lo = extent[0];
      if (hi == null || extent[1] > hi) hi = extent[1];
    }
  }));

  return lo != null && hi != null && lo !== hi ? [lo, hi] : undefined;
}

function nativeFilteredExtent(filter, field) {
  const keys = new nativeSQL.StructuralKeyScope;
  const key = keys.key(field);
  let lo;
  let hi;
  const lower = value => { if (value != null && (lo == null || value < lo)) lo = value; };
  const upper = value => { if (value != null && (hi == null || value > hi)) hi = value; };
  for (const predicate of [filter].flat()) {
    if (!nativeSQL.isExpression(predicate) && !nativeSQL.isExpressionHandle(predicate)) continue;
    nativeSQL.walk(predicate, node => {
      if ('subquery' in node || 'not' in node) return 1;
      if ('between' in node) {
        const value = node.between;
        if (!value.not && !value.symmetric && keys.key(value.this) === key) {
          lower(boundValue(value.low));
          upper(boundValue(value.high));
        }
      } else {
        const low = 'gte' in node ? node.gte : 'gt' in node ? node.gt : null;
        const high = 'lte' in node ? node.lte : 'lt' in node ? node.lt : null;
        const value = low ?? high;
        if (value) {
          if (keys.key(value.left) === key) (low ? lower : upper)(boundValue(value.right));
          else if (keys.key(value.right) === key) (low ? upper : lower)(boundValue(value.left));
        }
      }
    });
  }
  return lo != null && hi != null && +lo !== +hi ? [lo, hi] : undefined;
}

function boundValue(expression) {
  if (!('literal' in expression)) return;
  const { literal_type: type, value } = expression.literal;
  if (type === 'number') {
    const number = Number(value);
    return Number.isFinite(number) ? number : undefined;
  }
  if (type === 'date' && /^\d{4}-\d\d-\d\d$/.test(value)) return new Date(value + 'T00:00:00Z');
  if (type === 'timestamp' && /^\d{4}-\d\d-\d\d \d\d:\d\d:\d\d(?:\.\d+)?$/.test(value)) return new Date(value.replace(' ', 'T') + 'Z');
}
