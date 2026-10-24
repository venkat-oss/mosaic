import type { SqlExpression } from './expression.js';
import type { CompileAstOptions, SqlExecutionContext, TranspileResult } from './runtime.js';
import { compileAst } from './runtime.js';

export type SqlCompileOptions = Omit<
  CompileAstOptions,
  'sourceDialect' | 'targetDialect' | 'unsupportedLevel'
>;

export class SqlCompilationError extends Error {
  readonly context: SqlExecutionContext;
  readonly diagnostic: Readonly<TranspileResult>;

  constructor(context: SqlExecutionContext, diagnostic: TranspileResult) {
    super(`SQL compilation to ${context.targetDialect} failed: ${diagnostic.error ?? 'compiler returned no SQL'}`);
    this.name = 'SqlCompilationError';
    this.context = context;
    this.diagnostic = diagnostic;
  }
}

export function compile(
  expressions: readonly SqlExpression[],
  context: SqlExecutionContext,
  options: SqlCompileOptions = {}
): string[] {
  const result = compileAst(expressions, {
    ...options,
    sourceDialect: context.sourceDialect,
    targetDialect: context.targetDialect,
    unsupportedLevel: 'raise'
  });
  if (!result.success || !result.sql) {
    throw new SqlCompilationError(context, result);
  }
  return result.sql;
}
