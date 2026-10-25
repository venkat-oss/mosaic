import type { Connector } from './connectors/Connector.js';
import { Dialect, compileBatch, createExecutionContext, StructuralKeyScope } from '@uwdata/mosaic-sql';
import type { SqlExecutionContext, SqlRoot } from '@uwdata/mosaic-sql';

export class SqlContext {
  private _execution: SqlExecutionContext;
  private readonly keys = new StructuralKeyScope();
  private _owner?: object;
  private _invalidate?: () => void;

  constructor(execution: Partial<SqlExecutionContext> = {}) {
    this._execution = createExecutionContext(execution);
  }

  get execution(): SqlExecutionContext {
    return this._execution;
  }

  attach(owner: object, invalidate: () => void): void {
    if (this._owner && this._owner !== owner) throw new TypeError('SQL context is already attached to another query manager.');
    this._owner = owner;
    this._invalidate = invalidate;
  }

  detach(owner: object): void {
    if (this._owner !== owner) return;
    this._owner = undefined;
    this._invalidate = undefined;
  }

  replace(execution: Partial<SqlExecutionContext> = {}): void {
    this._execution = createExecutionContext({
      ...this._execution, ...execution, generation: this._execution.generation + 1
    });
    this._invalidate?.();
  }

  compileBatch(inputs: readonly (SqlRoot | string)[], execution = this._execution): string[] {
    return compileBatch(inputs, execution);
  }

  structuralKey(input: SqlRoot): string {
    return this.keys.key(input);
  }

  cacheKey(sql: string, execution = this._execution): string {
    return JSON.stringify([execution.backend, execution.sourceDialect, execution.targetDialect, execution.generation, sql]);
  }
}

export function backendExecution({ dialect }: Pick<Connector, 'dialect'>): Partial<SqlExecutionContext> {
  return dialect ? {
    backend: dialect,
    targetDialect: dialect === 'postgres' ? Dialect.PostgreSQL : Dialect.DuckDB
  } : {};
}
