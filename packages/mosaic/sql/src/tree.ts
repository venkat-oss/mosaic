import { ast, withSqlCoercion } from './runtime.js';
import type { SqlExpression } from './types.js';

export type CloneMemo = Map<object, unknown>;

export function columnParts(expression: SqlExpression): string[] | undefined {
  if ('column' in expression) return expression.column.table
    ? [expression.column.table.name, expression.column.name.name]
    : [expression.column.name.name];
  if ('star' in expression) {
    const qualifier = expression.star.table;
    if (!qualifier) return ['*'];
    if ('name' in qualifier) return [qualifier.name, '*'];
    if ('table' in qualifier) return [qualifier.table.catalog, qualifier.table.schema, qualifier.table.name]
      .filter(value => value != null).map(value => value.name).concat('*');
    return columnParts(qualifier)?.concat('*');
  }
  if ('dot' in expression) {
    const parts = columnParts(expression.dot.this);
    return parts && [...parts, expression.dot.field.name];
  }
}

export function mapTree(
  root: SqlExpression,
  replace: (node: SqlExpression) => SqlExpression | undefined,
  memo: CloneMemo = new Map(),
  clone = false,
  copied?: (source: SqlExpression, target: SqlExpression) => void
): SqlExpression {
  const pending: { value: object; visited: boolean }[] = [{ value: root, visited: false }];
  const active = new Set<object>();
  while (pending.length) {
    const { value, visited } = pending.pop()!;
    if (memo.has(value)) continue;
    if (!visited) {
      if (ast.isExpressionValue(value)) {
        const replacement = replace(value);
        if (replacement !== undefined) {
          memo.set(value, replacement);
          continue;
        }
      }
      if (active.has(value)) throw new TypeError('Native SQL expressions must be acyclic.');
      active.add(value);
      pending.push({ value, visited: true });
      const children = Object.values(value);
      for (let i = children.length - 1; i >= 0; --i) {
        const child = children[i];
        if (child && typeof child === 'object' && !memo.has(child)) {
          pending.push({ value: child, visited: false });
        }
      }
    } else {
      active.delete(value);
      let changed = clone;
      const entries = Object.entries(value).map(([key, child]) => {
        const next = child && typeof child === 'object' ? memo.get(child) : child;
        changed ||= next !== child;
        return [key, next];
      });
      const result = changed
        ? Array.isArray(value) ? entries.map(([, child]) => child) : Object.fromEntries(entries)
        : value;
      memo.set(value, result);
      if (result !== value && ast.isExpressionValue(value) && ast.isExpressionValue(result)) {
        withSqlCoercion(result);
        copied?.(value, result);
      }
    }
  }
  return memo.get(root) as SqlExpression;
}

export function* walk(root: SqlExpression): Generator<SqlExpression> {
  const pending: unknown[] = [root];
  const visited = new Set<object>();
  while (pending.length) {
    const value = pending.pop();
    if (!value || typeof value !== 'object' || visited.has(value)) continue;
    visited.add(value);
    if (ast.isExpressionValue(value)) yield value;
    const children = Object.values(value);
    for (let i = children.length - 1; i >= 0; --i) pending.push(children[i]);
  }
}
