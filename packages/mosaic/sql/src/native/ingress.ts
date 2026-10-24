import { parse, parseDataType, Dialect } from '#polyglot';
import type { ast } from '#polyglot';

const types = new Map<string, ast.DataType>();

export function parseExpression(source: string) {
  const result = parse(source, Dialect.DuckDB);
  if (!result.success || result.ast.length !== 1) {
    throw new SyntaxError(result.error ?? 'Expected one SQL expression.');
  }
  return result.ast[0];
}

export function dataType(source: string): ast.DataType {
  let type = types.get(source);
  if (!type) {
    const result = parseDataType(source, Dialect.DuckDB);
    if (!result.success || !result.dataType) {
      throw new SyntaxError(result.error ?? `Invalid SQL type: ${source}`);
    }
    type = result.dataType;
    types.set(source, type);
  }
  return type;
}
