import { argmax, argmin, max, min } from './aggregate.js';
import { bindingOf, rootExpression } from './bindings.js';
import { int32 } from './cast.js';
import { asNode, column, deferred, isQueryExpression } from './expression.js';
import { floor } from './numeric.js';
import { Query } from './query.js';
import { cte, from } from './relational.js';
import { rewrite, walk } from './visitors.js';
import type { TableArg } from './relational.js';
import type { ExprValue, SqlExpression, SqlRoot } from './types.js';

function outputColumn(field: SqlRoot): SqlExpression {
  const expression = rootExpression(field);
  const binding = bindingOf(expression);
  if (binding?.field) return deferred(read => column(binding.field!(read).column), binding.parameters);
  if ('column' in expression) return column(expression.column.name.name);
  if ('dot' in expression) return column(expression.dot.field.name);
  throw new TypeError('M4 groups require column references.');
}

function outputExpression(value: ExprValue): SqlExpression {
  const expression = asNode(value);
  const replacements = new Map<SqlExpression, SqlExpression>();
  walk(expression, node => {
    if (isQueryExpression(node) || 'subquery' in node) return 1;
    if (bindingOf(node)?.field || 'column' in node || 'dot' in node) {
      replacements.set(node, outputColumn(node));
      return 1;
    }
  });
  return rewrite(expression, replacements);
}

export function m4(input: TableArg, bin: ExprValue, x: string, y: string, groups: SqlRoot[] = []): Query {
  const useCTE = typeof input !== 'string' && !Array.isArray(input) && isQueryExpression(rootExpression(input as SqlRoot));
  const pixel = int32(floor(useCTE ? outputExpression(bin) : bin));
  const source = useCTE ? 'input' : input;
  const outputGroups = groups.map(outputColumn);
  const dimensions = useCTE ? outputGroups : groups;
  const branch = (projection: Record<string, ExprValue>) => Query.from(from(source)).select(projection, dimensions).groupby(pixel, dimensions);
  const branches = [
    branch({ [x]: min(x), [y]: argmin(y, x) }),
    branch({ [x]: max(x), [y]: argmax(y, x) }),
    branch({ [x]: argmin(x, y), [y]: min(y) }),
    branch({ [x]: argmax(x, y), [y]: max(y) })
  ];
  const query = useCTE
    ? Query.with(cte('input', input as SqlRoot, true)).union(branches)
    : Query.union(branches);
  return query.orderby(outputGroups, x);
}
