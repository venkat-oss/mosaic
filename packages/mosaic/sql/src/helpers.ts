import { bindingOf, fields, params, rootExpression } from './bindings.js';
import { asLiteral, column, isExpression, isExpressionHandle, tableRef } from './expression.js';
import { From, from } from './relational.js';
import { columnParts } from './tree.js';
import { verbatim } from './template.js';
import type { SqlExpression, SqlRoot } from './types.js';
import type { TableArg } from './relational.js';

export function asTableRef(value: string | readonly string[] | SqlRoot): SqlExpression;
export function asTableRef(value?: string | readonly string[] | SqlRoot): SqlExpression | undefined;
export function asTableRef(value?: string | readonly string[] | SqlRoot): SqlExpression | undefined {
  return value === undefined ? undefined
    : typeof value === 'string' || Array.isArray(value) ? tableRef(value)
    : rootExpression(value as SqlRoot);
}

export function asFrom(value: TableArg): From {
  return value instanceof From ? value : from(value);
}

export function asVerbatim(value: unknown): SqlRoot {
  return typeof value === 'string' ? verbatim(value) : asLiteral(value);
}

export function isColumnRef(value: unknown): value is SqlRoot {
  if (!isExpression(value) && !isExpressionHandle(value)) return false;
  const expression = rootExpression(value);
  return !!columnParts(expression) || bindingOf(expression)?.kind === 'identifier';
}

export function isTableRef(value: unknown): value is SqlRoot {
  return (isExpression(value) || isExpressionHandle(value)) && 'table' in rootExpression(value);
}

export function collectColumns(input: SqlRoot): SqlExpression[] {
  const columns = new Map<string, SqlExpression>();
  for (const field of fields(input)) {
    const parts = columnParts(field.node);
    const binding = bindingOf(field.node);
    const reference = parts?.at(-1) === field.column;
    const key = JSON.stringify(reference ? parts : [...(binding?.qualifier ?? []), field.column]);
    if (!columns.has(key)) columns.set(key, reference || binding?.field ? field.node : column(field.column));
  }
  return [...columns.values()];
}

export const collectParams = params;
