import { count, max, sum } from './aggregate.js';
import { int32 } from './cast.js';
import { abs, floor, greatest, round, sign } from './numeric.js';
import { add, asc, div, gt, isNull, lt, lte, mul, or, sub } from './operators.js';
import { Query } from './query.js';
import { subquery } from './relational.js';
import { native } from './runtime.js';
import { lead, over } from './window.js';
import type { ExprValue } from './types.js';

export function lineDensity(
  query: Query,
  x: ExprValue,
  y: ExprValue,
  series: string[],
  width: number,
  height: number,
  groups: string[] = [],
  normalize = true
): Query {
  query.select({ x: int32(floor(x)), y: int32(floor(y)) });
  const dimensions = groups.concat(series);
  const pairs = Query.from(query).select(dimensions, {
    x0: 'x', y0: 'y', dx: sub(lead('x').over('sw'), 'x'), dy: sub(lead('y').over('sw'), 'y')
  }).window({ sw: over().partitionby(dimensions).orderby(asc('x')) }).qualify([
    or(lt('x0', width), lt(add('x0', 'dx'), width)),
    or(lt('y0', height), lt(add('y0', 'dy'), height)),
    or(gt('x0', 0), gt(add('x0', 'dx'), 0)),
    or(gt('y0', 0), gt(add('y0', 'dy'), 0))
  ]);
  const size = Query.select({ x: greatest(max(abs('dx')), max(abs('dy'))) }).from('pairs');
  const indices = Query.select({ i: int32(native.unnest(native.range(subquery(size)))) });
  const raster = Query.unionAll(
    Query.select(dimensions, {
      x: add('x0', 'i'), y: add('y0', int32(round(div(mul('i', 'dy'), 'dx'))))
    }).from('pairs', 'indices').where([lte(abs('dy'), abs('dx')), lt('i', abs('dx'))]),
    Query.select(dimensions, {
      x: add('x0', int32(round(div(mul(mul(sign('dy'), 'i'), 'dx'), 'dy')))),
      y: add('y0', mul(sign('dy'), 'i'))
    }).from('pairs', 'indices').where([gt(abs('dy'), abs('dx')), lt('i', abs('dy'))]),
    Query.select(dimensions, { x: 'x0', y: 'y0' }).from('pairs').where(isNull('dx'))
  );
  const points = Query.from('raster').select(dimensions, 'x', 'y', normalize
    ? { w: div(1, count().partitionby(['x'].concat(dimensions))) } : []).where([
    lte(0, 'x'), lt('x', width), lte(0, 'y'), lt('y', height)
  ]);
  return Query.with({ pairs, indices, raster, points }).from('points').select(groups, {
    index: add('x', mul('y', int32(width))), density: normalize ? sum('w') : count()
  }).groupby('index', groups);
}
