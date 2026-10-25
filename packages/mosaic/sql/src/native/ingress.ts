import { parse, parseDataType, Dialect } from '#polyglot';
import type { ast } from '#polyglot';
import { columnParts } from './tree.js';
import { markSourceDialect } from './bindings.js';
import type { SqlExpression } from './types.js';

export interface SqlIngressOptions {
  readonly sourceDialect?: Dialect;
}

const types = new Map<string, ast.DataType>();

export function parseExpression(source: string, sourceDialect = Dialect.DuckDB): SqlExpression {
  const result = parse(source, sourceDialect);
  if (!result.success || result.ast.length !== 1) {
    throw new SyntaxError(result.error ?? 'Expected one SQL expression.');
  }
  const expression = result.ast[0];
  markSourceDialect(expression, sourceDialect);
  return expression;
}

export function parseColumnRef(source: string, sourceDialect = Dialect.DuckDB): SqlExpression {
  const expression = parseExpression(source, sourceDialect);
  if (!columnParts(expression)) throw new SyntaxError('Expected one SQL column reference.');
  return expression;
}

export function parseTableRef(source: string, sourceDialect = Dialect.DuckDB): { table: ast.TableRef } {
  const query = parseExpression(`SELECT * FROM ${source}`, sourceDialect);
  const table = 'select' in query && query.select.from?.expressions.length === 1 && !query.select.joins.length
    ? query.select.from.expressions[0] : undefined;
  if (!table || !('table' in table) || table.table.alias || table.table.column_aliases.length) {
    throw new SyntaxError('Expected one SQL table reference.');
  }
  markSourceDialect(table, sourceDialect);
  return table;
}

export function dataType(source: string, sourceDialect = Dialect.DuckDB): ast.DataType {
  const key = `${sourceDialect}:${source}`;
  let type = types.get(key);
  if (!type) {
    const result = parseDataType(source, sourceDialect);
    if (!result.success || !result.dataType) {
      throw new SyntaxError(result.error ?? `Invalid SQL type: ${source}`);
    }
    type = result.dataType;
    types.set(key, type);
  }
  return type;
}
