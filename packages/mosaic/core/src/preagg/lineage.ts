import * as nativeSQL from '@uwdata/mosaic-sql/native';
import type { SqlExpression, SqlRoot } from '@uwdata/mosaic-sql/native';
import { ColumnNameRefNode, ColumnsNode, FromClauseNode, isAggregateExpression, isColumnRef, isPivotQuery, isQuery, isSelectQuery, isSetOperation, isTableRef, PositionalRefNode, rewrite, ScalarSubqueryNode, StarNode, TableRefNode, walk, WindowNode, type ColumnRefNode, type ExprNode, type Query, type SelectQuery, type SQLNode } from '@uwdata/mosaic-sql';

/** A query paired with the scope of CTEs visible to it. */
export interface Binding {
  query: Query;
  scope: Scope;
}

/** A map from lowercased CTE names to their bound queries. */
export type Scope = Map<string, Binding>;

/**
 * Return the scope of CTEs visible within a query, extending an outer
 * scope with the query's own WITH clause. Each CTE is bound to the
 * scope defined by the CTEs that precede it.
 * @param query The query.
 * @param outer The scope visible outside the query.
 */
export function queryScope(query: Query, outer: Scope = new Map()): Scope {
  let scope = outer;
  for (const { name, query: cte } of query._with) {
    scope = new Map(scope).set(name.toLowerCase(), { query: cte, scope });
  }
  return scope;
}

/**
 * Resolve a relation (such as a FROM clause entry) to either a base
 * table reference or a bound query. Returns null for joins and other
 * relations, such as table functions or VALUES lists.
 * @param node The relation node.
 * @param scope The scope of visible CTEs.
 */
export function resolveRelation(node: SQLNode, scope: Scope): TableRefNode | Binding | null {
  if (node instanceof FromClauseNode) return resolveRelation(node.expr, scope);
  if (isQuery(node)) return { query: node, scope };
  if (isTableRef(node)) {
    return (node.table.length === 1 && scope.get(node.name.toLowerCase())) || node;
  }
  return null;
}

/**
 * Determine the single base table from which a query derives its rows.
 * Returns null if the query draws from multiple tables, joins, or other
 * unsupported relations.
 * @param query The query.
 * @param outer The scope visible outside the query.
 */
export function baseTable(query: Query, outer: Scope = new Map()): TableRefNode | null {
  const scope = queryScope(query, outer);
  const tables = isSelectQuery(query)
    ? (query._from.length === 1 ? [relationBase(query._from[0], scope)] : [null])
    : isSetOperation(query) ? query.queries.map(q => baseTable(q, scope))
    : isPivotQuery(query) ? [relationBase(query.source, scope)]
    : [null];
  const [table] = tables;
  return table && tables.every(t => t && tableEquals(t, table)) ? table : null;
}

function relationBase(node: SQLNode, scope: Scope): TableRefNode | null {
  const rel = resolveRelation(node, scope);
  if (rel instanceof TableRefNode) return rel;
  return rel ? baseTable(rel.query, rel.scope) : null;
}

/**
 * Rewrite an expression over the FROM relation of a select query into an
 * equivalent expression over base table columns. Returns undefined if a
 * column can not be resolved to a non-aggregate, non-window expression.
 * @param query The select query whose FROM relation the expression uses.
 * @param expr The expression to rewrite.
 * @param outer The scope visible outside the query.
 */
export function baseExpression(
  query: SelectQuery,
  expr: ExprNode,
  outer: Scope = new Map()
): ExprNode | undefined {
  if (query._from.length !== 1) return;
  const rel = resolveRelation(query._from[0], queryScope(query, outer));
  if (!rel) return;
  if (rel instanceof TableRefNode) return expr;
  if (hasNode(expr, ColumnsNode) || hasNode(expr, PositionalRefNode)) return;
  const map = new Map<ExprNode, ExprNode>();
  for (const col of columnRefs(expr)) {
    const e = outputExpression(rel.query, col.column, rel.scope);
    if (!e) return;
    map.set(col, e);
  }
  return rewrite(expr, map);
}

function outputExpression(query: Query, name: string, outer: Scope): ExprNode | undefined {
  if (isSelectQuery(query)) {
    const clause = query._select.find(c => nameEquals(c.alias, name));
    const expr = clause?.expr ?? starExpression(query, name);
    return selectExpression(query, expr, outer);
  }
  if (isSetOperation(query)) {
    const index = outputNames(query)?.findIndex(n => nameEquals(n, name)) ?? -1;
    if (index >= 0) return positionalExpression(query, index, outer);
  }
}

// set operation inputs after the first take output names by position
function positionalExpression(query: Query, index: number, outer: Scope): ExprNode | undefined {
  if (isSelectQuery(query)) {
    if (query._select.some(isWildcard)) return;
    return selectExpression(query, query._select[index]?.expr, outer);
  }
  if (isSetOperation(query)) {
    const scope = queryScope(query, outer);
    const exprs = query.queries.map(q => positionalExpression(q, index, scope));
    const [expr] = exprs;
    return expr && exprs.every(e => e && `${e}` === `${expr}`) ? expr : undefined;
  }
}

function selectExpression(query: SelectQuery, expr: ExprNode | undefined, outer: Scope): ExprNode | undefined {
  if (!expr || isAggregateExpression(expr) || hasNode(expr, WindowNode)) return;
  return baseExpression(query, expr, outer);
}

function outputNames(query: Query): string[] | undefined {
  if (isSelectQuery(query)) {
    return query._select.some(isWildcard) ? undefined : query._select.map(c => c.alias);
  }
  if (isSetOperation(query)) return outputNames(query.queries[0]);
}

function columnRefs(expr: ExprNode): ColumnRefNode[] {
  const refs: ColumnRefNode[] = [];
  walk(expr, node => {
    if (node instanceof ScalarSubqueryNode) return 1;
    if (isColumnRef(node)) refs.push(node);
  });
  return refs;
}

function hasNode(expr: SQLNode, type: new (...args: never[]) => SQLNode): boolean {
  let found = false;
  walk(expr, node => {
    if (node instanceof type) return (found = true, -1);
  });
  return found;
}

/**
 * Test if a select clause is an unqualified or qualified star (*).
 * @param node The select clause.
 */
export function isStar(node: { expr: SQLNode }): boolean {
  return node.expr instanceof ColumnNameRefNode && node.expr.name === '*';
}

/**
 * Test if a select clause may expand to multiple output columns, either
 * as a star (*) or by including a COLUMNS expression.
 * @param node The select clause.
 */
export function isWildcard(node: { expr: SQLNode }): boolean {
  return isStar(node) || hasNode(node.expr, ColumnsNode);
}

/**
 * Return the expression a select query's star clauses output for a
 * column name, or undefined if no star clause outputs the name.
 * @param query The select query.
 * @param name The output column name.
 * @param relations The table paths (or aliases) of the FROM relations
 *  that may provide the column. If specified, table-qualified stars and
 *  star modifiers apply only when they reference one of these relations,
 *  and the column is output if any one of these relations supplies it.
 *  Otherwise, all table qualifiers are assumed to reference the column's
 *  relation.
 */
export function starExpression(
  query: SelectQuery,
  name: string,
  relations?: (string[] | undefined)[]
): ExprNode | undefined {
  const matchers = relations
    ? relations.map(path => (ref: ColumnRefNode) =>
      !ref.table || !!path && suffixEquals(ref.table.table, path))
    : [() => true];
  for (const clause of query._select) {
    if (!isStar(clause)) continue;
    const expr = clause.expr as ColumnRefNode;
    for (const applies of matchers) {
      if (!applies(expr)) continue;
      if (!(expr instanceof StarNode)) return new ColumnNameRefNode(name);
      const replaced = expr.replace.find(c => nameEquals(c.alias, name));
      if (replaced) return replaced.expr;
      const renamed = expr.rename.find(c => nameEquals(c.alias, name));
      if (renamed) return new ColumnNameRefNode((renamed.expr as ColumnRefNode).column);
      const removed = expr.exclude.some(c => nameEquals(c.column, name) && applies(c))
        || expr.rename.some(c => {
          const from = c.expr as ColumnRefNode;
          return nameEquals(from.column, name) && applies(from);
        });
      if (!removed) return new ColumnNameRefNode(name);
    }
  }
}

// without catalog access we can't tell which schema a search path resolves
// a bare table name to, so this wrongly matches FROM t (resolved to s1.t)
// against a qualifier of s2.t
export function suffixEquals(a: string[], b: string[]): boolean {
  const n = Math.min(a.length, b.length);
  return a.slice(-n).every((v, i) => nameEquals(v, b[b.length - n + i]));
}

/**
 * Test if two table references refer to the same table.
 * @param a The first table reference.
 * @param b The second table reference.
 */
export function tableEquals(a: TableRefNode, b: TableRefNode): boolean {
  return a.table.length === b.table.length
    && a.table.every((v, i) => nameEquals(v, b.table[i]));
}

// DuckDB resolves identifiers case-insensitively, even when quoted
export function nameEquals(a: string, b: string): boolean {
  return a.toLowerCase() === b.toLowerCase();
}


export interface NativeBinding {
  query: SqlExpression;
  scope: NativeScope;
  columns?: string[];
}

export type NativeScope = Map<string, NativeBinding>;
export type NativeTable = ReturnType<typeof nativeSQL.native.table>;

export function nativeQueryScope(input: SqlRoot, outer: NativeScope = new Map()): NativeScope {
  const query = nativeSQL.rootExpression(input);
  const clause = 'select' in query ? query.select.with : 'union' in query ? query.union.with
    : 'intersect' in query ? query.intersect.with : 'except' in query ? query.except.with : null;
  let scope = outer;
  for (const cte of clause?.ctes ?? []) {
    scope = new Map(scope).set(cte.alias.name.toLowerCase(), {
      query: cte.this, scope, columns: cte.columns.map(column => column.name)
    });
  }
  return scope;
}

export function nativeSetOperands(query: SqlExpression): SqlExpression[] | undefined {
  const set = 'union' in query ? query.union : 'intersect' in query ? query.intersect
    : 'except' in query ? query.except : undefined;
  return set && !set.by_name ? [set.left, set.right] : undefined;
}

export function nativeTablePath(table: NativeTable): string[] {
  return [table.table.catalog?.name, table.table.schema?.name, table.table.name.name]
    .filter((name): name is string => name !== undefined);
}

export function nativeColumnPath(expression: SqlExpression): string[] | undefined {
  if ('column' in expression) return [expression.column.table?.name, expression.column.name.name]
    .filter((name): name is string => name !== undefined);
  if ('dot' in expression) {
    const prefix = nativeColumnPath(expression.dot.this);
    return prefix && [...prefix, expression.dot.field.name];
  }
}

export function nativeResolveRelation(node: SqlExpression, scope: NativeScope): NativeTable | NativeBinding | null {
  if ('table_sample' in node) return node.table_sample.this ? nativeResolveRelation(node.table_sample.this, scope) : null;
  if ('subquery' in node) return {
    query: node.subquery.this, scope, columns: node.subquery.column_aliases.map(column => column.name)
  };
  if ('table' in node) {
    const path = nativeTablePath(node);
    const binding = path.length === 1 ? scope.get(path[0].toLowerCase()) : undefined;
    if (binding && node.table.column_aliases.length) {
      const columns = node.table.column_aliases.map(column => column.name);
      return { ...binding, columns: columns.concat(binding.columns?.slice(columns.length) ?? []) };
    }
    return binding ?? node;
  }
  if ('select' in node || nativeSetOperands(node) || 'pivot' in node) return { query: node, scope };
  return null;
}

export function nativeBaseTable(input: SqlRoot, outer: NativeScope = new Map()): NativeTable | null {
  const query = nativeSQL.rootExpression(input);
  const scope = nativeQueryScope(query, outer);
  if ('subquery' in query) return nativeBaseTable(query.subquery.this, scope);
  const relation = (node: SqlExpression): NativeTable | null => {
    const resolved = nativeResolveRelation(node, scope);
    return resolved && 'table' in resolved ? resolved : resolved ? nativeBaseTable(resolved.query, resolved.scope) : null;
  };
  const operands = nativeSetOperands(query);
  const tables = 'select' in query
    ? query.select.from?.expressions.length === 1 && !query.select.joins.length
      ? [relation(query.select.from.expressions[0])] : [null]
    : operands ? operands.map(operand => nativeBaseTable(operand, scope))
      : 'pivot' in query ? [relation(query.pivot.this)] : [null];
  const [table] = tables;
  return table && tables.every(candidate => candidate && nativeTableEquals(table, candidate)) ? table : null;
}

export function nativeTableEquals(a: NativeTable, b: NativeTable): boolean {
  const left = nativeTablePath(a);
  const right = nativeTablePath(b);
  return left.length === right.length && left.every((name, index) => nameEquals(name, right[index]));
}

export function nativeIsStar(expression: SqlExpression): boolean {
  return 'star' in expression || nativeColumnPath(expression)?.at(-1) === '*';
}

export function nativeIsWildcard(expression: SqlExpression): boolean {
  return nativeSQL.hasColumnExpansion(expression);
}

type NativeStarReference = NonNullable<ReturnType<typeof nativeSQL.native.star>['star']['table']>;

function nativeStarPath(reference: NativeStarReference): string[] | undefined {
  if ('name' in reference) return [reference.name];
  return 'table' in reference ? nativeTablePath(reference) : nativeColumnPath(reference);
}

export function nativeStarExpression(
  input: SqlRoot,
  name: string,
  relations?: (string[] | undefined)[]
): SqlExpression | undefined {
  const query = nativeSQL.rootExpression(input);
  if (!('select' in query)) return;
  if (!relations) {
    const sources = query.select.from?.expressions;
    if (sources?.length !== 1 || query.select.joins.length) return;
    const source = sources[0];
    if (!nativeResolveRelation(source, new Map())) return;
    relations = ['table' in source
      ? source.table.alias ? [source.table.alias.name] : nativeTablePath(source)
      : 'subquery' in source && source.subquery.alias ? [source.subquery.alias.name] : undefined];
  }
  for (const projection of query.select.expressions) {
    const expression = 'alias' in projection ? projection.alias.this : projection;
    if (!nativeIsStar(expression)) continue;
    if (!('star' in expression)) {
      const path = nativeColumnPath(expression);
      const qualifier = path?.slice(0, -1);
      if (qualifier && relations.some(relation => !qualifier.length || relation && suffixEquals(qualifier, relation))) {
        return nativeSQL.column(name, qualifier);
      }
      continue;
    }
    const star = expression.star;
    const qualifier = star.table && nativeStarPath(star.table);
    if (star.table && !qualifier) continue;
    for (const relation of relations) {
      if (qualifier && (!relation || !suffixEquals(qualifier, relation))) continue;
      const applies = (reference: NativeStarReference): boolean => {
        const path = nativeStarPath(reference);
        const binding = 'name' in reference ? undefined : nativeSQL.bindingOf(reference);
        const prefix = path?.slice(0, -1) ?? binding?.qualifier;
        return prefix === undefined ? !!binding : !prefix.length || !!relation && suffixEquals([...prefix], relation);
      };
      const replaced = star.replace?.find(alias => nameEquals(alias.alias.name, name));
      if (replaced) return replaced.this;
      const renamed = star.rename?.find(([, target]) => nameEquals(target.name, name));
      if (renamed) {
        if (!applies(renamed[0])) continue;
        return 'name' in renamed[0] ? nativeSQL.column(renamed[0].name) : renamed[0];
      }
      const removed = [...(star.except ?? []), ...(star.rename?.map(([source]) => source) ?? [])]
        .some(reference => applies(reference) && (!nativeStarPath(reference)
          || nameEquals(nativeStarPath(reference)!.at(-1)!, name)));
      if (!removed) return nativeSQL.column(name, qualifier ?? undefined);
    }
  }
}

export function nativeBaseExpression(
  input: SqlRoot,
  expression: SqlExpression,
  outer: NativeScope = new Map()
): SqlExpression | undefined {
  const query = nativeSQL.rootExpression(input);
  if (!('select' in query) || query.select.from?.expressions.length !== 1 || query.select.joins.length) return;
  const resolved = nativeResolveRelation(query.select.from.expressions[0], nativeQueryScope(query, outer));
  if (!resolved) return;
  if ('table' in resolved) return expression;
  const replacements = new Map<SqlExpression, SqlExpression>();
  let supported = true;
  nativeSQL.walk(expression, node => {
    if ('subquery' in node) return 1;
    if ('columns' in node || nativeColumnPath(node)?.at(-1)?.match(/^#\d+$/)) {
      supported = false;
      return -1;
    }
    const path = nativeColumnPath(node);
    if (path) {
      const value = nativeOutputExpression(resolved, path[path.length - 1]);
      if (!value) { supported = false; return -1; }
      replacements.set(node, value);
      return 1;
    }
  });
  return supported ? nativeSQL.rewrite(expression, replacements) : undefined;
}

function nativeOutputExpression(binding: NativeBinding, name: string): SqlExpression | undefined {
  const { query, scope, columns } = binding;
  if (columns?.length) {
    const names = nativeOutputNames(query);
    const index = names?.findIndex((column, index) => nameEquals(columns[index] ?? column, name)) ?? -1;
    return index < 0 ? undefined : nativePositionalExpression(query, index, scope);
  }
  if ('select' in query) {
    const clause = nativeSQL.selectEntries(query).find(projection => projection.alias && nameEquals(projection.alias, name));
    return nativeSelectExpression(query, clause?.expr ?? nativeStarExpression(query, name), scope);
  }
  const names = nativeOutputNames(query);
  const index = names?.findIndex(column => nameEquals(column, name)) ?? -1;
  return index < 0 ? undefined : nativePositionalExpression(query, index, scope);
}

function nativeOutputNames(query: SqlExpression): string[] | undefined {
  if ('subquery' in query) return nativeOutputNames(query.subquery.this)?.map((name, index) => query.subquery.column_aliases[index]?.name ?? name);
  if ('select' in query) {
    const projections = nativeSQL.selectEntries(query);
    return projections.some(({ alias, expr }) => alias === undefined || nativeIsWildcard(expr))
      ? undefined : projections.map(({ alias }) => alias!);
  }
  const operands = nativeSetOperands(query);
  return operands ? nativeOutputNames(operands[0]) : undefined;
}

function nativePositionalExpression(query: SqlExpression, index: number, outer: NativeScope): SqlExpression | undefined {
  if ('subquery' in query) return nativePositionalExpression(query.subquery.this, index, outer);
  if ('select' in query) {
    const projections = nativeSQL.selectEntries(query);
    if (projections.some(({ expr }) => nativeIsWildcard(expr))) return;
    return nativeSelectExpression(query, projections[index]?.expr, outer);
  }
  const operands = nativeSetOperands(query);
  if (!operands) return;
  const scope = nativeQueryScope(query, outer);
  const expressions = operands.map(operand => nativePositionalExpression(operand, index, scope));
  const [expression] = expressions;
  const keys = new nativeSQL.StructuralKeyScope();
  return expression && expressions.every(candidate => candidate && keys.key(candidate) === keys.key(expression))
    ? expression : undefined;
}

function nativeSelectExpression(
  query: SqlExpression,
  expression: SqlExpression | undefined,
  outer: NativeScope
): SqlExpression | undefined {
  if (!expression || nativeSQL.isAggregateExpression(expression)) return;
  let window = false;
  nativeSQL.walk(expression, node => {
    if ('window_function' in node || 'window' in node || 'window_spec' in node) { window = true; return -1; }
  });
  return window ? undefined : nativeBaseExpression(query, expression, outer);
}
