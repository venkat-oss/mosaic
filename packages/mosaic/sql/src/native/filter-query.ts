import { bind, bindingOf, cloneExpression, copyBinding, rootExpression } from './bindings.js';
import { asNode, column, isQueryExpression, tableRef } from './expression.js';
import { parseExpression } from './ingress.js';
import { and } from './operators.js';
import { Query } from './query.js';
import { native } from './runtime.js';
import { columnParts, mapTree } from './tree.js';
import { walk } from './visitors.js';
import type { FilterInput } from './query.js';
import type { SqlExpression, SqlRoot } from './types.js';

type With = NonNullable<ReturnType<typeof native.select>['select']['with']>;
type Qualifiers = Map<string, readonly string[]>;

function tablePath(expression: SqlExpression): string[] | undefined {
  if ('table' in expression) return [expression.table.catalog, expression.table.schema, expression.table.name]
    .filter(value => value != null).map(value => value.name);
}

function withData(expression: SqlExpression): { with?: With | null } | undefined {
  if ('select' in expression) return expression.select;
  if ('union' in expression) return expression.union;
  if ('intersect' in expression) return expression.intersect;
  if ('except' in expression) return expression.except;
  if ('pivot' in expression) return expression.pivot;
}

function rewriteColumns(expression: SqlExpression, qualifiers: Qualifiers): SqlExpression {
  if (!qualifiers.size) return expression;
  const visible = new Map(qualifiers);
  const hideSource = (source: SqlExpression): void => {
    if ('table' in source) {
      const path = source.table.alias ? [source.table.alias.name] : tablePath(source);
      if (path) visible.delete(JSON.stringify(path));
    } else if ('joined_table' in source) {
      hideSource(source.joined_table.left);
      for (const join of source.joined_table.joins) hideSource(join.this);
    } else if ('subquery' in source && source.subquery.alias) {
      visible.delete(JSON.stringify([source.subquery.alias.name]));
    } else if ('table_sample' in source && source.table_sample.this) hideSource(source.table_sample.this);
  };
  if ('select' in expression) {
    for (const source of expression.select.from?.expressions ?? []) hideSource(source);
    for (const join of expression.select.joins) hideSource(join.this);
  } else if ('pivot' in expression) hideSource(expression.pivot.this);
  if (!visible.size) return expression;
  return mapTree(expression, node => {
    if ('subquery' in node) {
      const { this: query, ...options } = node.subquery;
      return native.subquery(rewriteColumns(query, visible), options);
    }
    if (node !== expression && isQueryExpression(node)) return rewriteColumns(node, visible);
    const binding = bindingOf(node);
    const replacement = binding?.kind === 'identifier' && binding.qualifier
      ? visible.get(JSON.stringify(binding.qualifier))
      : undefined;
    if (binding && replacement) return bind({
      ...binding,
      qualifier: replacement,
      resolve: read => rewriteColumns(rootExpression(binding.resolve(read)), visible),
      field: binding.field ? read => ({ ...binding.field!(read), table: replacement.join('.') }) : undefined
    });
    const parts = columnParts(node);
    const qualifier = parts && parts.length > 1 ? visible.get(JSON.stringify(parts.slice(0, -1))) : undefined;
    if (parts && qualifier) return column(parts[parts.length - 1], tableRef(qualifier));
  }, new Map(), false, copyBinding);
}

export function filterPushdown(query: SqlRoot, table: string | SqlRoot, filter: FilterInput): Query {
  const clone = cloneExpression(query);
  const target = typeof table === 'string' ? tableRef(table)! : rootExpression(table);
  const path = tablePath(target);
  if (!path) throw new TypeError('Filter pushdown requires a base table reference.');
  const predicates = (Array.isArray(filter) ? filter : [filter]).filter(value => value != null)
    .map(value => typeof value === 'string' ? parseExpression(value) : asNode(value));
  if (!predicates.length) return new Query(clone);
  const names = new Set<string>();
  walk(clone, node => {
    if ('table' in node) names.add(node.table.name.name);
    if ('cte' in node) names.add(node.cte.alias.name);
    for (const cte of withData(node)?.with?.ctes ?? []) names.add(cte.alias.name);
  });
  let filteredName = '_' + path[path.length - 1];
  while (names.has(filteredName)) filteredName = '_' + filteredName;
  const targetKey = JSON.stringify(path);
  let changed = false;
  const active = new Set<SqlExpression>();

  const rewriteSource = (source: SqlExpression, shadows: ReadonlySet<string>, qualifiers: Qualifiers): SqlExpression => {
    const sourcePath = tablePath(source);
    if (sourcePath && JSON.stringify(sourcePath) === targetKey
      && (sourcePath.length > 1 || !shadows.has(sourcePath[0])) && 'table' in source) {
      changed = true;
      const { name, ...options } = source.table;
      const visible = source.table.alias ?? name;
      if (!source.table.alias && sourcePath.length > 1) qualifiers.set(JSON.stringify(sourcePath), [visible.name]);
      return native.table(native.identifier(filteredName, true).identifier, {
        ...options, catalog: null, schema: null, alias: visible, alias_explicit_as: true
      });
    }
    if ('subquery' in source) {
      const { this: query, ...options } = source.subquery;
      return native.subquery(rewriteQuery(query, shadows), options);
    }
    if ('joined_table' in source) {
      const { left, joins, ...options } = source.joined_table;
      return native.joinedTable(
        rewriteSource(left, shadows, qualifiers),
        joins.map(join => ({ ...join, this: rewriteSource(join.this, shadows, qualifiers) })), options
      );
    }
    if ('table_sample' in source) {
      const { this: relation, sample, ...options } = source.table_sample;
      return relation && sample ? native.tableSample(rewriteSource(relation, shadows, qualifiers), sample, options) : source;
    }
    if (isQueryExpression(source)) return rewriteQuery(source, shadows);
    return source;
  };

  const rewriteQuery = (expression: SqlExpression, inherited: ReadonlySet<string>): SqlExpression => {
    if (active.has(expression)) throw new TypeError('Native SQL expressions must be acyclic.');
    active.add(expression);
    if ('subquery' in expression) {
      const { this: query, ...options } = expression.subquery;
      const result = native.subquery(rewriteQuery(query, inherited), options);
      active.delete(expression);
      return result;
    }
    let copy: SqlExpression = { ...expression };
    if ('select' in expression) copy = { select: { ...expression.select } };
    else if ('union' in expression) copy = { union: { ...expression.union } };
    else if ('intersect' in expression) copy = { intersect: { ...expression.intersect } };
    else if ('except' in expression) copy = { except: { ...expression.except } };
    else if ('pivot' in expression) copy = { pivot: { ...expression.pivot } };
    copyBinding(expression, copy);
    const statement = withData(copy);
    const shadows = new Set(inherited);
    const originalWith = statement?.with;
    if (originalWith) {
      const { ctes: originalCtes, ...options } = originalWith;
      if (originalWith.recursive) for (const cte of originalCtes) shadows.add(cte.alias.name);
      const ctes = originalCtes.map(cte => {
        const result = { ...cte, this: rewriteQuery(cte.this, shadows) };
        shadows.add(cte.alias.name);
        return result;
      });
      statement!.with = native.withClause(ctes, options).with;
    }
    const qualifiers: Qualifiers = new Map();
    if ('select' in copy) {
      if (copy.select.from) copy.select.from = native.from(copy.select.from.expressions
        .map(source => rewriteSource(source, shadows, qualifiers))).from;
      copy.select.joins = copy.select.joins.map(join => ({ ...join, this: rewriteSource(join.this, shadows, qualifiers) }));
    } else if ('union' in copy) {
      copy.union.left = rewriteQuery(copy.union.left, shadows);
      copy.union.right = rewriteQuery(copy.union.right, shadows);
    } else if ('intersect' in copy) {
      copy.intersect.left = rewriteQuery(copy.intersect.left, shadows);
      copy.intersect.right = rewriteQuery(copy.intersect.right, shadows);
    } else if ('except' in copy) {
      copy.except.left = rewriteQuery(copy.except.left, shadows);
      copy.except.right = rewriteQuery(copy.except.right, shadows);
    } else if ('pivot' in copy) copy.pivot.this = rewriteSource(copy.pivot.this, shadows, qualifiers);
    const result = rewriteColumns(copy, qualifiers);
    active.delete(expression);
    return result;
  };

  const result = rewriteQuery(clone, new Set());
  if (changed) {
    const statement = withData(result);
    if (!statement) throw new TypeError('Filter pushdown requires a native relational query.');
    const filtered = native.select([native.star()], {
      from: native.from([target]).from,
      where_clause: native.where(and(predicates)).where
    });
    const cte = native.cte(native.identifier(filteredName, true).identifier, filtered).cte;
    const { ctes: existing, ...options } = statement.with ?? { ctes: [] };
    statement.with = native.withClause([cte, ...existing], options).with;
  }
  return new Query(result);
}

export function filterQuery(query: SqlRoot, table: string | SqlRoot): (filter: FilterInput) => Query {
  return filter => filterPushdown(query, table, filter);
}
