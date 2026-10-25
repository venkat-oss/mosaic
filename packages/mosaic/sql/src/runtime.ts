import { ast, compileAst, Dialect as CompilerDialect, native as factories } from '#polyglot';
import type { Schema } from '#polyglot';
import { compile } from './compile.js';

export { ast, compileAst };

const expressionPrototype = Object.create(Object.prototype, {
  toString: {
    value(this: ast.Expression, ...args: unknown[]): string {
      if (args.length) throw new TypeError('SQL renderer visitors are unsupported. Use compile() with an execution context.');
      return compile([this], createExecutionContext())[0];
    }
  }
});

export function withSqlCoercion<T>(value: T): T {
  if (ast.isExpressionValue(value)) Object.setPrototypeOf(value, expressionPrototype);
  return value;
}

export const native: typeof factories = Object.fromEntries(
  Object.entries(factories).map(([name, factory]) => [name,
    typeof factory === 'function'
      ? (...args: unknown[]) => withSqlCoercion(Reflect.apply(factory, factories, args))
      : factory
  ])
) as typeof factories;
// VitePress's split SSR chunks lose an indirect enum re-export.
export import Dialect = CompilerDialect;
export type { CompileAstOptions, TranspileResult } from '#polyglot';
export type SqlSourceSchema = Schema;

export interface SqlExecutionContext {
  readonly backend: string;
  readonly sourceDialect: Dialect;
  readonly targetDialect: Dialect;
  readonly generation: number;
  readonly sourceSchema?: SqlSourceSchema;
}

export function createExecutionContext(
  options: Partial<SqlExecutionContext> = {}
): SqlExecutionContext {
  const {
    sourceDialect = Dialect.DuckDB,
    targetDialect = Dialect.DuckDB,
    backend = targetDialect,
    generation = 0,
    sourceSchema
  } = options;
  if (!backend.trim()) {
    throw new TypeError('SQL execution context requires a backend identity.');
  }
  if (!Number.isSafeInteger(generation) || generation < 0) {
    throw new RangeError('SQL connection generation must be a non-negative safe integer.');
  }
  return Object.freeze({
    backend, sourceDialect, targetDialect, generation,
    ...(sourceSchema === undefined ? {} : { sourceSchema: freezeSchema(structuredClone(sourceSchema)) })
  });
}

function freezeSchema<T>(value: T): T {
  if (value !== null && typeof value === 'object' && !Object.isFrozen(value)) {
    Object.freeze(value);
    for (const child of Object.values(value)) freezeSchema(child);
  }
  return value;
}
