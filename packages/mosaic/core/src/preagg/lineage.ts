import * as sql from '@uwdata/mosaic-sql';
import type { SqlExpression, SqlRoot } from '@uwdata/mosaic-sql';

// without catalog access we can't tell which schema a search path resolves
// a bare table name to, so this wrongly matches FROM t (resolved to s1.t)
// against a qualifier of s2.t
export function suffixEquals(a: string[], b: string[]): boolean {
  const n = Math.min(a.length, b.length);
  return a.slice(-n).every((v, i) => nameEquals(v, b[b.length - n + i]));
}

// DuckDB resolves identifiers case-insensitively, even when quoted
export function nameEquals(a: string, b: string): boolean {
  return a.toLowerCase() === b.toLowerCase();
}


export interface Binding {
  query: SqlExpression;
  scope: Scope;
  columns?: string[];
}

export type Scope = Map<string, Binding>;
export type TableRef = ReturnType<typeof sql.native.table>;

export function queryScope(input: SqlRoot, outer: Scope = new Map()): Scope {
  const query = sql.rootExpression(input);
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

export function setOperands(query: SqlExpression): SqlExpression[] | undefined {
  const set = 'union' in query ? query.union : 'intersect' in query ? query.intersect
    : 'except' in query ? query.except : undefined;
  return set && !set.by_name ? [set.left, set.right] : undefined;
}

export function tablePath(table: TableRef): string[] {
  return [table.table.catalog?.name, table.table.schema?.name, table.table.name.name]
    .filter((name): name is string => name !== undefined);
}

export function columnPath(expression: SqlExpression): string[] | undefined {
  if ('column' in expression) return [expression.column.table?.name, expression.column.name.name]
    .filter((name): name is string => name !== undefined);
  if ('dot' in expression) {
    const prefix = columnPath(expression.dot.this);
    return prefix && [...prefix, expression.dot.field.name];
  }
}

export function resolveRelation(node: SqlExpression, scope: Scope): TableRef | Binding | null {
  if ('table_sample' in node) return node.table_sample.this ? resolveRelation(node.table_sample.this, scope) : null;
  if ('subquery' in node) return {
    query: node.subquery.this, scope, columns: node.subquery.column_aliases.map(column => column.name)
  };
  if ('table' in node) {
    const path = tablePath(node);
    const binding = path.length === 1 ? scope.get(path[0].toLowerCase()) : undefined;
    if (binding && node.table.column_aliases.length) {
      const columns = node.table.column_aliases.map(column => column.name);
      return { ...binding, columns: columns.concat(binding.columns?.slice(columns.length) ?? []) };
    }
    return binding ?? node;
  }
  if ('select' in node || setOperands(node) || 'pivot' in node) return { query: node, scope };
  return null;
}

export function baseTable(input: SqlRoot, outer: Scope = new Map()): TableRef | null {
  const query = sql.rootExpression(input);
  const scope = queryScope(query, outer);
  if ('subquery' in query) return baseTable(query.subquery.this, scope);
  const relation = (node: SqlExpression): TableRef | null => {
    const resolved = resolveRelation(node, scope);
    return resolved && 'table' in resolved ? resolved : resolved ? baseTable(resolved.query, resolved.scope) : null;
  };
  const operands = setOperands(query);
  const tables = 'select' in query
    ? query.select.from?.expressions.length === 1 && !query.select.joins.length
      ? [relation(query.select.from.expressions[0])] : [null]
    : operands ? operands.map(operand => baseTable(operand, scope))
      : 'pivot' in query ? [relation(query.pivot.this)] : [null];
  const [table] = tables;
  return table && tables.every(candidate => candidate && tableEquals(table, candidate)) ? table : null;
}

export function tableEquals(a: TableRef, b: TableRef): boolean {
  const left = tablePath(a);
  const right = tablePath(b);
  return left.length === right.length && left.every((name, index) => nameEquals(name, right[index]));
}

export function isStar(expression: SqlExpression): boolean {
  return 'star' in expression || columnPath(expression)?.at(-1) === '*';
}

export function isWildcard(expression: SqlExpression): boolean {
  return sql.hasColumnExpansion(expression);
}

type StarReference = NonNullable<ReturnType<typeof sql.native.star>['star']['table']>;

function starPath(reference: StarReference): string[] | undefined {
  if ('name' in reference) return [reference.name];
  return 'table' in reference ? tablePath(reference) : columnPath(reference);
}

export function starExpression(
  input: SqlRoot,
  name: string,
  relations?: (string[] | undefined)[]
): SqlExpression | undefined {
  const query = sql.rootExpression(input);
  if (!('select' in query)) return;
  if (!relations) {
    const sources = query.select.from?.expressions;
    if (sources?.length !== 1 || query.select.joins.length) return;
    const source = sources[0];
    if (!resolveRelation(source, new Map())) return;
    relations = ['table' in source
      ? source.table.alias ? [source.table.alias.name] : tablePath(source)
      : 'subquery' in source && source.subquery.alias ? [source.subquery.alias.name] : undefined];
  }
  for (const projection of query.select.expressions) {
    const expression = 'alias' in projection ? projection.alias.this : projection;
    if (!isStar(expression)) continue;
    if (!('star' in expression)) {
      const path = columnPath(expression);
      const qualifier = path?.slice(0, -1);
      if (qualifier && relations.some(relation => !qualifier.length || relation && suffixEquals(qualifier, relation))) {
        return sql.column(name, qualifier);
      }
      continue;
    }
    const star = expression.star;
    const qualifier = star.table && starPath(star.table);
    if (star.table && !qualifier) continue;
    for (const relation of relations) {
      if (qualifier && (!relation || !suffixEquals(qualifier, relation))) continue;
      const applies = (reference: StarReference): boolean => {
        const path = starPath(reference);
        const binding = 'name' in reference ? undefined : sql.bindingOf(reference);
        const prefix = path?.slice(0, -1) ?? binding?.qualifier;
        return prefix === undefined ? !!binding : !prefix.length || !!relation && suffixEquals([...prefix], relation);
      };
      const replaced = star.replace?.find(alias => nameEquals(alias.alias.name, name));
      if (replaced) return replaced.this;
      const renamed = star.rename?.find(([, target]) => nameEquals(target.name, name));
      if (renamed) {
        if (!applies(renamed[0])) continue;
        return 'name' in renamed[0] ? sql.column(renamed[0].name) : renamed[0];
      }
      const removed = [...(star.except ?? []), ...(star.rename?.map(([source]) => source) ?? [])]
        .some(reference => applies(reference) && (!starPath(reference)
          || nameEquals(starPath(reference)!.at(-1)!, name)));
      if (!removed) return sql.column(name, qualifier ?? undefined);
    }
  }
}

export function baseExpression(
  input: SqlRoot,
  expression: SqlExpression,
  outer: Scope = new Map()
): SqlExpression | undefined {
  const query = sql.rootExpression(input);
  if (!('select' in query) || query.select.from?.expressions.length !== 1 || query.select.joins.length) return;
  const resolved = resolveRelation(query.select.from.expressions[0], queryScope(query, outer));
  if (!resolved) return;
  if ('table' in resolved) return expression;
  const replacements = new Map<SqlExpression, SqlExpression>();
  let supported = true;
  sql.walk(expression, node => {
    if ('subquery' in node) return 1;
    if ('columns' in node || columnPath(node)?.at(-1)?.match(/^#\d+$/)) {
      supported = false;
      return -1;
    }
    const path = columnPath(node);
    if (path) {
      const value = outputExpression(resolved, path[path.length - 1]);
      if (!value) { supported = false; return -1; }
      replacements.set(node, value);
      return 1;
    }
  });
  return supported ? sql.rewrite(expression, replacements) : undefined;
}

function outputExpression(binding: Binding, name: string): SqlExpression | undefined {
  const { query, scope, columns } = binding;
  if (columns?.length) {
    const names = outputNames(query);
    const index = names?.findIndex((column, index) => nameEquals(columns[index] ?? column, name)) ?? -1;
    return index < 0 ? undefined : positionalExpression(query, index, scope);
  }
  if ('select' in query) {
    const clause = sql.selectEntries(query).find(projection => projection.alias && nameEquals(projection.alias, name));
    return selectExpression(query, clause?.expr ?? starExpression(query, name), scope);
  }
  const names = outputNames(query);
  const index = names?.findIndex(column => nameEquals(column, name)) ?? -1;
  return index < 0 ? undefined : positionalExpression(query, index, scope);
}

function outputNames(query: SqlExpression): string[] | undefined {
  if ('subquery' in query) return outputNames(query.subquery.this)?.map((name, index) => query.subquery.column_aliases[index]?.name ?? name);
  if ('select' in query) {
    const projections = sql.selectEntries(query);
    return projections.some(({ alias, expr }) => alias === undefined || isWildcard(expr))
      ? undefined : projections.map(({ alias }) => alias!);
  }
  const operands = setOperands(query);
  return operands ? outputNames(operands[0]) : undefined;
}

function positionalExpression(query: SqlExpression, index: number, outer: Scope): SqlExpression | undefined {
  if ('subquery' in query) return positionalExpression(query.subquery.this, index, outer);
  if ('select' in query) {
    const projections = sql.selectEntries(query);
    if (projections.some(({ expr }) => isWildcard(expr))) return;
    return selectExpression(query, projections[index]?.expr, outer);
  }
  const operands = setOperands(query);
  if (!operands) return;
  const scope = queryScope(query, outer);
  const expressions = operands.map(operand => positionalExpression(operand, index, scope));
  const [expression] = expressions;
  const keys = new sql.StructuralKeyScope();
  return expression && expressions.every(candidate => candidate && keys.key(candidate) === keys.key(expression))
    ? expression : undefined;
}

function selectExpression(
  query: SqlExpression,
  expression: SqlExpression | undefined,
  outer: Scope
): SqlExpression | undefined {
  if (!expression || sql.isAggregateExpression(expression)) return;
  let window = false;
  sql.walk(expression, node => {
    if ('window_function' in node || 'window' in node || 'window_spec' in node) { window = true; return -1; }
  });
  return window ? undefined : baseExpression(query, expression, outer);
}
