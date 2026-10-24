import * as nativeSQL from '@uwdata/mosaic-sql/native';
import type { SqlExpression, SqlRoot } from '@uwdata/mosaic-sql/native';
import { nativeColumnPath, nativeIsStar, nativeIsWildcard, nativeQueryScope, nativeResolveRelation, nativeSetOperands, nativeStarExpression, nativeTableEquals, nativeTablePath, type NativeScope, type NativeTable } from './lineage.js';
import { ColumnNameRefNode, FromClauseNode, JoinNode, SelectClauseNode, TableRefNode, isAggregateExpression, isPivotQuery, isSelectQuery, isSetOperation, literal, type ExprNode, type PivotQuery, type Query, type SelectQuery, type SQLNode, type SetOperation, isTableRef } from '@uwdata/mosaic-sql';
import { isStar, isWildcard, nameEquals, queryScope, resolveRelation, starExpression, suffixEquals, tableEquals, type Scope } from './lineage.js';

/**
 * Push selected columns down to subqueries, ensuring they are included as
 * group by dimensions for aggregate expressions. This method mutates
 * the input query, modifying query SELECT and GROUP BY clauses.
 * @param query The query to push down to.
 * @param source The source relation (base table) containing the selected columns
 * @param cols The column names to push down.
 * @returns False if the columns could not be pushed down, in which case
 *  the query may be left in an invalid state.
 */
export function subqueryPushdown(query: Query, source: TableRefNode, cols: string[]): boolean {
  const memo = new Map<Query, boolean>();
  let supported = true;

  const visitQuery = (q: Query, outer: Scope, append?: string[]): boolean => {
    if (memo.has(q)) return memo.get(q)!;
    memo.set(q, false);
    const scope = queryScope(q, outer);
    let result = false;
    if (isSelectQuery(q)) {
      result = visitSelect(q, scope, append);
    } else if (isSetOperation(q)) {
      result = visitSetOperation(q, scope, append);
    } else if (isPivotQuery(q)) {
      result = visitPivot(q, scope);
    }
    memo.set(q, result);
    return result;
  };

  const visitRelation = (node: SQLNode, scope: Scope): boolean => {
    const rel = resolveRelation(node, scope);
    if (isTableRef(rel)) return tableEquals(rel, source);
    return rel ? visitQuery(rel.query, rel.scope) : false;
  };

  const visitFrom = (node: SQLNode, scope: Scope, relations: Relation[]): void => {
    if (node instanceof JoinNode) {
      visitFrom(node.left, scope, relations);
      visitFrom(node.right, scope, relations);
    } else {
      relations.push({ path: relationPath(node), source: visitRelation(node, scope) });
    }
  };

  const fromRelations = (q: SelectQuery, scope: Scope): Relation[] => {
    const relations: Relation[] = [];
    q._from.forEach(node => visitFrom(node, scope, relations));
    return relations;
  };

  const sourcePaths = (relations: Relation[]) =>
    relations.filter(r => r.source).map(r => r.path);

  const visitSelect = (q: SelectQuery, scope: Scope, append?: string[]): boolean => {
    const relations = fromRelations(q, scope);
    const paths = sourcePaths(relations);
    if (!paths.length) return false;
    const path = relations.length > 1 && paths.length === 1 ? paths[0] : undefined;
    const ref = (c: string) => new ColumnNameRefNode(c, path && new TableRefNode(path));
    const ambiguous = paths.length > 1;
    const select = (names: string[]) => {
      if (ambiguous && names.length) supported = false;
      appendSelect(q, names.map(c => [c, ref(c)]));
    };
    if (!append) {
      select(missingSelect(q, paths));
    } else if (!q._select.some(isWildcard)) {
      select(append);
    } else if (append.length) {
      supported = false;
    }
    if (isAggregateQuery(q)) {
      const group = cols.map(ref).filter(c => !hasColumn(q._groupby, c));
      if (ambiguous && group.length) supported = false;
      q.groupby(group);
    }
    return true;
  };

  // set operation inputs take output names from the first input by
  // position, so all inputs must append the same columns in the same order
  const visitSetOperation = (q: SetOperation, scope: Scope, append = missing(q.queries[0], scope)): boolean => {
    const found = q.queries.map(sub => visitQuery(sub, scope, append));
    if (!found.some(x => x)) return false;
    q.queries.forEach((sub, i) => { if (!found[i]) padNull(sub, append); });
    return true;
  };

  const visitPivot = (q: PivotQuery, scope: Scope): boolean => {
    if (!visitRelation(q.source, scope)) return false;
    // a pivot without GROUP BY implicitly groups by all remaining columns
    if (q._groupby.length) {
      q.groupby(cols.filter(c => !hasColumn(q._groupby, new ColumnNameRefNode(c))));
    }
    return true;
  };

  const padNull = (q: Query, append: string[]): void => {
    if (isSelectQuery(q)) {
      if (append.length && q._select.some(isWildcard)) supported = false;
      appendSelect(q, append.map(c => [c, literal(null)]));
    } else if (isSetOperation(q)) {
      q.queries.forEach(sub => padNull(sub, append));
    }
  };

  const missing = (q: Query, outer: Scope): string[] => {
    const scope = queryScope(q, outer);
    if (isSelectQuery(q)) {
      const relations = fromRelations(q, scope);
      const paths = sourcePaths(relations);
      return missingSelect(q, paths.length ? paths : relations.map(r => r.path));
    }
    return isSetOperation(q) ? missing(q.queries[0], scope) : [];
  };

  const missingSelect = (q: SelectQuery, relations: (string[] | undefined)[]): string[] => {
    const result = cols.filter(c => !q._select.some(x => nameEquals(x.alias, c))
      && !starExpression(q, c, relations));
    if (!q._select.some(c => isWildcard(c) && !isStar(c))) return result;
    if (result.length && q !== query) supported = false;
    return [];
  };

  visitQuery(query, new Map());
  return supported;
}

interface Relation {
  path?: string[];
  source: boolean;
}

/**
 * Test if a query performs aggregation.
 * @param query Select query to test.
 * @returns True if query performs aggregation.
 */
function isAggregateQuery(query: SelectQuery): boolean {
  return query._groupby.length > 0
    || query._select.some(node => isAggregateExpression(node));
}

/**
 * Append select clauses without replacing existing clauses that share an
 * alias, as set operation inputs may reuse names that are positionally
 * assigned to different output columns.
 * @param query The select query to modify.
 * @param clauses The [alias, expression] pairs to append.
 */
function appendSelect(query: SelectQuery, clauses: [string, ExprNode][]): void {
  query._select.push(...clauses.map(([alias, expr]) => new SelectClauseNode(expr, alias)));
}

function relationPath(node: SQLNode): string[] | undefined {
  if (node instanceof FromClauseNode) {
    const { expr, alias, columnNames } = node;
    const implicit = isTableRef(expr) && !!alias && nameEquals(expr.name, alias) && !columnNames?.length;
    return alias && !implicit ? [alias] : relationPath(expr);
  }
  return isTableRef(node) ? node.table : undefined;
}

function hasColumn(list: SQLNode[], ref: ColumnNameRefNode): boolean {
  return list.some(x => x instanceof ColumnNameRefNode && nameEquals(x.name, ref.name)
    && (!x.table || !ref.table || suffixEquals(x.table.table, ref.table.table)));
}


export function nativeSubqueryPushdown(input: SqlRoot, source: NativeTable, columns: string[]): boolean {
  const root = nativeSQL.rootExpression(input);
  const memo = new Map<SqlExpression, Map<NativeScope, boolean>>();
  let supported = true;
  const visitQuery = (query: SqlExpression, outer: NativeScope, append?: string[]): boolean => {
    let scopes = memo.get(query);
    if (scopes?.has(outer)) return scopes.get(outer)!;
    if (!scopes) { scopes = new Map(); memo.set(query, scopes); }
    scopes.set(outer, false);
    const scope = nativeQueryScope(query, outer);
    let result = false;
    if ('subquery' in query) result = visitQuery(query.subquery.this, scope, append);
    else if ('select' in query) result = visitSelect(query, scope, append);
    else {
      const operands = nativeSetOperands(query);
      if (operands) {
        const names = append ?? missing(operands[0], scope);
        const found = operands.map(operand => visitQuery(operand, scope, names));
        result = found.some(Boolean);
        if (result && names.length && !('union' in query && query.union.all)) supported = false;
        if (result) operands.forEach((operand, index) => { if (!found[index]) padNull(operand, names); });
      } else if ('pivot' in query && visitRelation(query.pivot.this, scope)) {
        const grouping = query.pivot.group;
        if (grouping && 'group' in grouping && grouping.group.expressions.length) {
          grouping.group.expressions.push(...columns.map(name => nativeSQL.column(name))
            .filter(column => !hasNativeColumn(grouping.group.expressions, column)));
        }
        result = true;
      }
    }
    scopes.set(outer, result);
    return result;
  };
  const visitRelation = (node: SqlExpression, scope: NativeScope): boolean => {
    const relation = nativeResolveRelation(node, scope);
    return relation && 'table' in relation ? nativeTableEquals(relation, source)
      : relation ? visitQuery(relation.query, relation.scope) : false;
  };
  const visitFrom = (node: SqlExpression, scope: NativeScope, relations: Relation[]): void => {
    if ('joined_table' in node) {
      visitFrom(node.joined_table.left, scope, relations);
      node.joined_table.joins.forEach(join => visitFrom(join.this, scope, relations));
    } else relations.push({ path: nativeRelationPath(node), source: visitRelation(node, scope) });
  };
  const fromRelations = (query: SqlExpression, scope: NativeScope): Relation[] => {
    const relations: Relation[] = [];
    if ('select' in query) {
      query.select.from?.expressions.forEach(node => visitFrom(node, scope, relations));
      query.select.joins.forEach(join => visitFrom(join.this, scope, relations));
    }
    return relations;
  };
  const visitSelect = (query: SqlExpression, scope: NativeScope, append?: string[]): boolean => {
    if (!('select' in query)) return false;
    const relations = fromRelations(query, scope);
    const paths = relations.filter(relation => relation.source).map(relation => relation.path);
    if (!paths.length) return false;
    const grouped = !!query.select.group_by?.expressions.length;
    const aggregated = query.select.expressions.some(nativeSQL.isAggregateExpression);
    const changesGrouping = columns.some(name => !hasNativeColumn(query.select.group_by?.expressions ?? [], nativeSQL.column(name)));
    if (query !== root && (query.select.having || query.select.qualify || query.select.windows?.length
      || query.select.limit || query.select.offset || query.select.fetch || query.select.distinct_on?.length
      || query.select.expressions.some(hasNativeWindow) || aggregated && (!grouped || changesGrouping && !nativePartitionable(root, query)))) {
      supported = false;
      return true;
    }
    const path = relations.length > 1 && paths.length === 1 ? paths[0] : undefined;
    const reference = (name: string) => nativeSQL.column(name, path && nativeSQL.tableRef(path));
    const select = (names: string[]) => {
      if (names.length && (paths.length > 1 || query !== root && query.select.distinct)) supported = false;
      appendNativeSelect(query, names.map(name => [name, reference(name)]));
    };
    if (!append) select(missingSelect(query, paths));
    else if (!query.select.expressions.some(nativeIsWildcard)) select(append);
    else if (append.length) supported = false;
    if (query.select.group_by?.expressions.length || query.select.expressions.some(nativeSQL.isAggregateExpression)) {
      const group = columns.map(reference).filter(column => !hasNativeColumn(query.select.group_by?.expressions ?? [], column));
      if (paths.length > 1 && group.length) supported = false;
      const dimensions = [...(query.select.group_by?.expressions ?? []), ...group];
      query.select.group_by = dimensions.length ? nativeSQL.native.groupBy(dimensions).group_by : null;
    }
    return true;
  };
  const padNull = (query: SqlExpression, append: string[]): void => {
    if ('subquery' in query) padNull(query.subquery.this, append);
    else if ('select' in query) {
      if (append.length && query.select.expressions.some(nativeIsWildcard)) supported = false;
      appendNativeSelect(query, append.map(name => [name, nativeSQL.literal(null)]));
    } else nativeSetOperands(query)?.forEach(operand => padNull(operand, append));
  };
  const missing = (query: SqlExpression, outer: NativeScope): string[] => {
    const scope = nativeQueryScope(query, outer);
    if ('subquery' in query) return missing(query.subquery.this, scope);
    if ('select' in query) {
      const relations = fromRelations(query, scope);
      const paths = relations.filter(relation => relation.source).map(relation => relation.path);
      return missingSelect(query, paths.length ? paths : relations.map(relation => relation.path));
    }
    const operands = nativeSetOperands(query);
    return operands ? missing(operands[0], scope) : [];
  };
  const missingSelect = (query: SqlExpression, relations: (string[] | undefined)[]): string[] => {
    const projections = nativeSQL.selectEntries(query);
    const missing = columns.filter(name => {
      const projection = projections.find(({ alias }) => alias && nameEquals(alias, name));
      const expression = projection?.expr ?? nativeStarExpression(query, name, relations);
      if (expression && query !== root) {
        const path = nativeColumnPath(expression);
        if (!path || !nameEquals(path[path.length - 1], name)
          || path.length > 1 && !relations.some(relation => relation && suffixEquals(path.slice(0, -1), relation))) supported = false;
      }
      return !expression;
    });
    if (!projections.some(({ expr }) => nativeIsWildcard(expr) && !nativeIsStar(expr))) return missing;
    if (missing.length && query !== root) supported = false;
    return [];
  };
  visitQuery(root, new Map());
  return supported;
}

function appendNativeSelect(query: SqlExpression, entries: [string, SqlExpression][]): void {
  if ('select' in query) query.select.expressions.push(...entries.map(([name, expression]) =>
    nativeSQL.native.alias(expression, nativeSQL.native.identifier(name, true).identifier)));
}

function nativeRelationPath(node: SqlExpression): string[] | undefined {
  if ('table_sample' in node) return node.table_sample.this ? nativeRelationPath(node.table_sample.this) : undefined;
  if ('subquery' in node) return node.subquery.alias ? [node.subquery.alias.name] : undefined;
  if ('table' in node) {
    const table = node.table;
    const implicit = table.alias && nameEquals(table.alias.name, table.name.name) && !table.column_aliases.length;
    return table.alias && !implicit ? [table.alias.name] : nativeTablePath(node);
  }
}

function hasNativeColumn(expressions: SqlExpression[], reference: SqlExpression): boolean {
  const path = nativeColumnPath(reference);
  return !!path && expressions.some(expression => {
    const other = nativeColumnPath(expression);
    return other && nameEquals(path[path.length - 1], other[other.length - 1])
      && (path.length === 1 || other.length === 1 || suffixEquals(path.slice(0, -1), other.slice(0, -1)));
  });
}


function hasNativeWindow(expression: SqlExpression): boolean {
  let window = false;
  nativeSQL.walk(expression, node => {
    if ('subquery' in node) return 1;
    if ('window_function' in node) { window = true; return -1; }
  });
  return window;
}

function nativePartitionable(root: SqlExpression, boundary: SqlExpression): boolean {
  const aggregates = nativeSQL.collectAggregates(root);
  return aggregates.length > 0 && aggregates.every(node => {
    const aggregate = nativeSQL.inspectAggregate(node);
    if (!aggregate || aggregate.distinct || aggregate.filter || aggregate.order_by.length || aggregate.args.length !== 1) return false;
    const sum = aggregate.name === 'sum';
    const commute = ['min', 'max', 'product', 'bit_and', 'bit_or', 'bit_xor', 'bool_and', 'bool_or'].includes(aggregate.name);
    return (sum || commute) && nativePartitionValue(aggregate.args[0], root, new Map(), boundary,
      sum ? ['sum', 'count', 'count_star'] : [aggregate.name], sum);
  });
}

function nativePartitionValue(
  expression: SqlExpression,
  query: SqlExpression,
  outer: NativeScope,
  boundary: SqlExpression,
  allowed: string[],
  linear: boolean
): boolean {
  const aggregate = nativeSQL.inspectAggregate(expression);
  if (aggregate) return query === boundary && allowed.includes(aggregate.name) && !aggregate.distinct && !aggregate.order_by.length;
  const path = nativeColumnPath(expression);
  if (path) {
    if (!('select' in query) || query.select.from?.expressions.length !== 1 || query.select.joins.length) return false;
    const relation = nativeResolveRelation(query.select.from.expressions[0], nativeQueryScope(query, outer));
    if (!relation || 'table' in relation) return false;
    let source = relation.query;
    while ('subquery' in source) source = source.subquery.this;
    if (!('select' in source)) return false;
    const projections = nativeSQL.selectEntries(source);
    const name = path[path.length - 1];
    const projection = relation.columns?.length
      ? projections.find((projection, index) => nameEquals(relation.columns![index] ?? projection.alias ?? '', name))
      : projections.find(projection => projection.alias && nameEquals(projection.alias, name));
    const value = projection?.expr ?? nativeStarExpression(source, name);
    return !!value && nativePartitionValue(value, source, relation.scope, boundary, allowed, linear);
  }
  if (!linear) return false;
  if ('mul' in expression) return nativeScalarFactor(expression.mul.left)
    ? nativePartitionValue(expression.mul.right, query, outer, boundary, allowed, linear)
    : nativeScalarFactor(expression.mul.right) && nativePartitionValue(expression.mul.left, query, outer, boundary, allowed, linear);
  if ('div' in expression) return nativeScalarFactor(expression.div.right, true)
    && nativePartitionValue(expression.div.left, query, outer, boundary, allowed, linear);
  return false;
}

function nativeScalarFactor(expression: SqlExpression, nonzero = false): boolean {
  if (!('literal' in expression) || expression.literal.literal_type !== 'number') return false;
  const value = Number(expression.literal.value);
  return Number.isFinite(value) && (!nonzero || value !== 0);
}
