import * as sql from '@uwdata/mosaic-sql';
import type { SqlExpression, SqlRoot } from '@uwdata/mosaic-sql';
import { columnPath, isStar, isWildcard, queryScope, resolveRelation, setOperands, starExpression, tableEquals, tablePath, nameEquals, suffixEquals, type Scope, type TableRef } from './lineage.js';

interface Relation {
  path?: string[];
  source: boolean;
}

export function subqueryPushdown(input: SqlRoot, source: TableRef, columns: string[]): boolean {
  const root = sql.rootExpression(input);
  const memo = new Map<SqlExpression, Map<Scope, boolean>>();
  let supported = true;
  const visitQuery = (query: SqlExpression, outer: Scope, append?: string[]): boolean => {
    let scopes = memo.get(query);
    if (scopes?.has(outer)) return scopes.get(outer)!;
    if (!scopes) { scopes = new Map(); memo.set(query, scopes); }
    scopes.set(outer, false);
    const scope = queryScope(query, outer);
    let result = false;
    if ('subquery' in query) result = visitQuery(query.subquery.this, scope, append);
    else if ('select' in query) result = visitSelect(query, scope, append);
    else {
      const operands = setOperands(query);
      if (operands) {
        const names = append ?? missing(operands[0], scope);
        const found = operands.map(operand => visitQuery(operand, scope, names));
        result = found.some(Boolean);
        if (result && names.length && !('union' in query && query.union.all)) supported = false;
        if (result) operands.forEach((operand, index) => { if (!found[index]) padNull(operand, names); });
      } else if ('pivot' in query && visitRelation(query.pivot.this, scope)) {
        const grouping = query.pivot.group;
        if (grouping && 'group' in grouping && grouping.group.expressions.length) {
          grouping.group.expressions.push(...columns.map(name => sql.column(name))
            .filter(column => !hasColumn(grouping.group.expressions, column)));
        }
        result = true;
      }
    }
    scopes.set(outer, result);
    return result;
  };
  const visitRelation = (node: SqlExpression, scope: Scope): boolean => {
    const relation = resolveRelation(node, scope);
    return relation && 'table' in relation ? tableEquals(relation, source)
      : relation ? visitQuery(relation.query, relation.scope) : false;
  };
  const visitFrom = (node: SqlExpression, scope: Scope, relations: Relation[]): void => {
    if ('joined_table' in node) {
      visitFrom(node.joined_table.left, scope, relations);
      node.joined_table.joins.forEach(join => visitFrom(join.this, scope, relations));
    } else relations.push({ path: relationPath(node), source: visitRelation(node, scope) });
  };
  const fromRelations = (query: SqlExpression, scope: Scope): Relation[] => {
    const relations: Relation[] = [];
    if ('select' in query) {
      query.select.from?.expressions.forEach(node => visitFrom(node, scope, relations));
      query.select.joins.forEach(join => visitFrom(join.this, scope, relations));
    }
    return relations;
  };
  const visitSelect = (query: SqlExpression, scope: Scope, append?: string[]): boolean => {
    if (!('select' in query)) return false;
    const relations = fromRelations(query, scope);
    const paths = relations.filter(relation => relation.source).map(relation => relation.path);
    if (!paths.length) return false;
    const grouped = !!query.select.group_by?.expressions.length;
    const aggregated = query.select.expressions.some(sql.isAggregateExpression);
    const changesGrouping = columns.some(name => !hasColumn(query.select.group_by?.expressions ?? [], sql.column(name)));
    if (query !== root && (query.select.having || query.select.qualify || query.select.windows?.length
      || query.select.limit || query.select.offset || query.select.fetch || query.select.distinct_on?.length
      || query.select.expressions.some(hasWindow) || aggregated && (!grouped || changesGrouping && !partitionable(root, query)))) {
      supported = false;
      return true;
    }
    const path = relations.length > 1 && paths.length === 1 ? paths[0] : undefined;
    const reference = (name: string) => sql.column(name, path && sql.tableRef(path));
    const select = (names: string[]) => {
      if (names.length && (paths.length > 1 || query !== root && query.select.distinct)) supported = false;
      appendSelect(query, names.map(name => [name, reference(name)]));
    };
    if (!append) select(missingSelect(query, paths));
    else if (!query.select.expressions.some(isWildcard)) select(append);
    else if (append.length) supported = false;
    if (query.select.group_by?.expressions.length || query.select.expressions.some(sql.isAggregateExpression)) {
      const group = columns.map(reference).filter(column => !hasColumn(query.select.group_by?.expressions ?? [], column));
      if (paths.length > 1 && group.length) supported = false;
      const dimensions = [...(query.select.group_by?.expressions ?? []), ...group];
      query.select.group_by = dimensions.length ? sql.native.groupBy(dimensions).group_by : null;
    }
    return true;
  };
  const padNull = (query: SqlExpression, append: string[]): void => {
    if ('subquery' in query) padNull(query.subquery.this, append);
    else if ('select' in query) {
      if (append.length && query.select.expressions.some(isWildcard)) supported = false;
      appendSelect(query, append.map(name => [name, sql.literal(null)]));
    } else setOperands(query)?.forEach(operand => padNull(operand, append));
  };
  const missing = (query: SqlExpression, outer: Scope): string[] => {
    const scope = queryScope(query, outer);
    if ('subquery' in query) return missing(query.subquery.this, scope);
    if ('select' in query) {
      const relations = fromRelations(query, scope);
      const paths = relations.filter(relation => relation.source).map(relation => relation.path);
      return missingSelect(query, paths.length ? paths : relations.map(relation => relation.path));
    }
    const operands = setOperands(query);
    return operands ? missing(operands[0], scope) : [];
  };
  const missingSelect = (query: SqlExpression, relations: (string[] | undefined)[]): string[] => {
    const projections = sql.selectEntries(query);
    const missing = columns.filter(name => {
      const projection = projections.find(({ alias }) => alias && nameEquals(alias, name));
      const expression = projection?.expr ?? starExpression(query, name, relations);
      if (expression && query !== root) {
        const path = columnPath(expression);
        if (!path || !nameEquals(path[path.length - 1], name)
          || path.length > 1 && !relations.some(relation => relation && suffixEquals(path.slice(0, -1), relation))) supported = false;
      }
      return !expression;
    });
    if (!projections.some(({ expr }) => isWildcard(expr) && !isStar(expr))) return missing;
    if (missing.length && query !== root) supported = false;
    return [];
  };
  visitQuery(root, new Map());
  return supported;
}

function appendSelect(query: SqlExpression, entries: [string, SqlExpression][]): void {
  if ('select' in query) query.select.expressions.push(...entries.map(([name, expression]) =>
    sql.native.alias(expression, sql.native.identifier(name, true).identifier)));
}

function relationPath(node: SqlExpression): string[] | undefined {
  if ('table_sample' in node) return node.table_sample.this ? relationPath(node.table_sample.this) : undefined;
  if ('subquery' in node) return node.subquery.alias ? [node.subquery.alias.name] : undefined;
  if ('table' in node) {
    const table = node.table;
    const implicit = table.alias && nameEquals(table.alias.name, table.name.name) && !table.column_aliases.length;
    return table.alias && !implicit ? [table.alias.name] : tablePath(node);
  }
}

function hasColumn(expressions: SqlExpression[], reference: SqlExpression): boolean {
  const path = columnPath(reference);
  return !!path && expressions.some(expression => {
    const other = columnPath(expression);
    return other && nameEquals(path[path.length - 1], other[other.length - 1])
      && (path.length === 1 || other.length === 1 || suffixEquals(path.slice(0, -1), other.slice(0, -1)));
  });
}


function hasWindow(expression: SqlExpression): boolean {
  let window = false;
  sql.walk(expression, node => {
    if ('subquery' in node) return 1;
    if ('window_function' in node) { window = true; return -1; }
  });
  return window;
}

function partitionable(root: SqlExpression, boundary: SqlExpression): boolean {
  const aggregates = sql.collectAggregates(root);
  return aggregates.length > 0 && aggregates.every(node => {
    const aggregate = sql.inspectAggregate(node);
    if (!aggregate || aggregate.distinct || aggregate.filter || aggregate.order_by.length || aggregate.args.length !== 1) return false;
    const sum = aggregate.name === 'sum';
    const commute = ['min', 'max', 'product', 'bit_and', 'bit_or', 'bit_xor', 'bool_and', 'bool_or'].includes(aggregate.name);
    return (sum || commute) && partitionValue(aggregate.args[0], root, new Map(), boundary,
      sum ? ['sum', 'count', 'count_star'] : [aggregate.name], sum);
  });
}

function partitionValue(
  expression: SqlExpression,
  query: SqlExpression,
  outer: Scope,
  boundary: SqlExpression,
  allowed: string[],
  linear: boolean
): boolean {
  const aggregate = sql.inspectAggregate(expression);
  if (aggregate) return query === boundary && allowed.includes(aggregate.name) && !aggregate.distinct && !aggregate.order_by.length;
  const path = columnPath(expression);
  if (path) {
    if (!('select' in query) || query.select.from?.expressions.length !== 1 || query.select.joins.length) return false;
    const relation = resolveRelation(query.select.from.expressions[0], queryScope(query, outer));
    if (!relation || 'table' in relation) return false;
    let source = relation.query;
    while ('subquery' in source) source = source.subquery.this;
    if (!('select' in source)) return false;
    const projections = sql.selectEntries(source);
    const name = path[path.length - 1];
    const projection = relation.columns?.length
      ? projections.find((projection, index) => nameEquals(relation.columns![index] ?? projection.alias ?? '', name))
      : projections.find(projection => projection.alias && nameEquals(projection.alias, name));
    const value = projection?.expr ?? starExpression(source, name);
    return !!value && partitionValue(value, source, relation.scope, boundary, allowed, linear);
  }
  if (!linear) return false;
  if ('mul' in expression) return scalarFactor(expression.mul.left)
    ? partitionValue(expression.mul.right, query, outer, boundary, allowed, linear)
    : scalarFactor(expression.mul.right) && partitionValue(expression.mul.left, query, outer, boundary, allowed, linear);
  if ('div' in expression) return scalarFactor(expression.div.right, true)
    && partitionValue(expression.div.left, query, outer, boundary, allowed, linear);
  return false;
}

function scalarFactor(expression: SqlExpression, nonzero = false): boolean {
  if (!('literal' in expression) || expression.literal.literal_type !== 'number') return false;
  const value = Number(expression.literal.value);
  return Number.isFinite(value) && (!nonzero || value !== 0);
}
