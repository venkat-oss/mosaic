import { ast, compileAst, Dialect as CompilerDialect, native } from '#polyglot';

export { ast, compileAst, native };
// VitePress's split SSR chunks lose an indirect enum re-export.
export import Dialect = CompilerDialect;
export type { CompileAstOptions, TranspileResult } from '#polyglot';

export interface SqlExecutionContext {
  readonly backend: string;
  readonly sourceDialect: Dialect;
  readonly targetDialect: Dialect;
  readonly generation: number;
}

export function createExecutionContext(
  options: Partial<SqlExecutionContext> = {}
): SqlExecutionContext {
  const {
    sourceDialect = Dialect.DuckDB,
    targetDialect = Dialect.DuckDB,
    backend = targetDialect,
    generation = 0
  } = options;
  if (!backend.trim()) {
    throw new TypeError('SQL execution context requires a backend identity.');
  }
  if (!Number.isSafeInteger(generation) || generation < 0) {
    throw new RangeError('SQL connection generation must be a non-negative safe integer.');
  }
  return Object.freeze({ backend, sourceDialect, targetDialect, generation });
}
