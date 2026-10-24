import { ast, native } from './runtime.js';
import { cloneExpression, copyBinding, rootExpression } from './bindings.js';
import { mapTree } from './tree.js';
import { isQueryExpression } from './expression.js';
import type { SelectProjection } from './query.js';
import type { SqlExpression, SqlRoot } from './types.js';

export type VisitorResult = boolean | number | null | undefined | void;
export type VisitorCallback = (node: SqlExpression, parent?: SqlExpression) => VisitorResult;

export function walk(input: SqlRoot, visit: VisitorCallback): void {
  const pending: { value: unknown; parent?: SqlExpression }[] = [{ value: rootExpression(input) }];
  const visited = new Set<object>();
  while (pending.length) {
    const { value, parent } = pending.pop()!;
    if (!value || typeof value !== 'object' || visited.has(value)) continue;
    visited.add(value);
    let ancestor = parent;
    if (ast.isExpressionValue(value)) {
      const result = visit(value, parent);
      if (typeof result === 'number' && result < 0) return;
      if (result) continue;
      ancestor = value;
    }
    const children = Object.values(value);
    for (let i = children.length - 1; i >= 0; --i) {
      pending.push({ value: children[i], parent: ancestor });
    }
  }
}

export function collect(input: SqlRoot, test: (node: SqlExpression) => boolean): SqlExpression[] {
  const result: SqlExpression[] = [];
  walk(input, node => { if (test(node)) result.push(node); });
  return result;
}

export function rewrite(input: SqlRoot, replacements: ReadonlyMap<SqlExpression, SqlRoot>): SqlExpression {
  return mapTree(rootExpression(input), node => {
    const replacement = replacements.get(node);
    return replacement === undefined ? undefined : rootExpression(replacement);
  }, new Map(), false, copyBinding);
}

export const deepClone = cloneExpression;

export function hasColumnExpansion(input: SqlRoot): boolean {
  const expression = rootExpression(input);
  let result = false;
  walk(expression, node => {
    if ('subquery' in node || node !== expression && isQueryExpression(node)) return 1;
    if ('star' in node || 'columns' in node
      || 'column' in node && !node.column.name.quoted && /^#\d+$/.test(node.column.name.name)) {
      result = true;
      return -1;
    }
  });
  return result;
}

export function isAggregateExpression(input: SqlRoot): boolean {
  const active = new Set<SqlExpression>();
  const prepare = (expression: SqlExpression): SqlExpression => {
    if (active.has(expression)) throw new TypeError('Native SQL expressions must be acyclic.');
    active.add(expression);
    const result = mapTree(expression, node => {
      if ('subquery' in node || node !== expression && isQueryExpression(node)) return native.literal(0);
      if ('window_function' in node) return native.tuple([
        ...windowInputs(node.window_function.this),
        ...expressionChildren(node.window_function.over)
      ].map(prepare));
    });
    active.delete(expression);
    return result;
  };
  return ast.hasAggregates(prepare(rootExpression(input)));
}

function windowInputs(expression: SqlExpression): SqlExpression[] {
  if ('filter' in expression) return [...windowInputs(expression.filter.this), expression.filter.expression];
  if ('within_group' in expression) return [
    ...windowInputs(expression.within_group.this), ...expression.within_group.order_by.map(order => order.this)
  ];
  return expressionChildren(expression);
}

function expressionChildren(value: object): SqlExpression[] {
  const result: SqlExpression[] = [];
  const pending: unknown[] = Object.values(value).reverse();
  const visited = new Set<object>();
  while (pending.length) {
    const value = pending.pop();
    if (!value || typeof value !== 'object' || visited.has(value)) continue;
    visited.add(value);
    if (ast.isExpressionValue(value)) result.push(value);
    else pending.push(...Object.values(value).reverse());
  }
  return result;
}

export function resolvePositional(
  input: SqlRoot,
  select: readonly SelectProjection[]
): SelectProjection | undefined {
  const expression = rootExpression(input);
  const value = 'literal' in expression && expression.literal.literal_type === 'number'
    ? Number(expression.literal.value)
    : 'column' in expression && !expression.column.name.quoted && /^#\d+$/.test(expression.column.name.name)
      ? Number(expression.column.name.name.slice(1))
      : NaN;
  return Number.isSafeInteger(value) && value > 0 ? select[value - 1] : undefined;
}
