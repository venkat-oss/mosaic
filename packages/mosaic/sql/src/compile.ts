import type { SqlExpression, SqlRoot } from './types.js';
import type { CompileAstOptions, SqlExecutionContext, TranspileResult } from './runtime.js';
import { compileAst } from './runtime.js';
import { assertResolved, assertSourceDialect, snapshotAll } from './bindings.js';

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

export function compileResolved(
  expressions: readonly SqlExpression[],
  context: SqlExecutionContext,
  options: SqlCompileOptions = {}
): string[] {
  expressions.forEach(assertResolved);
  expressions.forEach(expression => assertSourceDialect(expression, context.sourceDialect));
  const result = compileAst(expressions, {
    ...options,
    sourceDialect: context.sourceDialect,
    targetDialect: context.targetDialect,
    unsupportedLevel: 'raise'
  });
  if (!result.success || !result.sql) throw new SqlCompilationError(context, result);
  return result.sql;
}

export function compile(
  inputs: readonly SqlRoot[],
  context: SqlExecutionContext,
  options: SqlCompileOptions = {}
): string[] {
  inputs.forEach(input => assertSourceDialect(input, context.sourceDialect));
  return compileResolved(snapshotAll(inputs), context, options);
}

export function compileBatch(
  inputs: readonly (SqlRoot | string | null | undefined)[],
  context: SqlExecutionContext,
  options: SqlCompileOptions = {}
): string[] {
  if (context.sourceDialect !== context.targetDialect && inputs.some(value => typeof value === 'string')) {
    throw new TypeError('Raw exec SQL requires matching source and target dialects.');
  }
  const roots = inputs.filter((value): value is SqlRoot => value != null && typeof value !== 'string');
  roots.forEach(input => assertSourceDialect(input, context.sourceDialect));
  const expressions = snapshotAll(roots);
  const statements: string[] = [];
  let position = 0;
  let pending: SqlExpression[] = [];
  const flush = () => {
    if (pending.length) statements.push(...compileResolved(pending, context, options));
    pending = [];
  };
  for (const input of inputs) {
    if (input == null) continue;
    if (typeof input === 'string') {
      flush();
      statements.push(input);
    } else {
      pending.push(expressions[position++]);
    }
  }
  flush();
  return statements;
}
