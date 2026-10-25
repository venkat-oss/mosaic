import { compile, createExecutionContext } from '@uwdata/mosaic-sql';
import { QueryType } from '../types.js';

function asError(value: unknown) {
  return value instanceof Error
    ? value
    : new Error(`${value}`);
}

export class QueryError extends Error {
  #sql: string;

  get sql() {
    return this.#sql;
  }

  constructor(err: unknown, query: QueryType) {
    const cause = asError(err)
    let sql: string;
    try {
      sql = typeof query === 'string' ? query : compile([query], createExecutionContext()).join(';\n');
    } catch {
      sql = '[SQL query could not be compiled]';
    }
    const msg = `${cause.message}\n\nSQL Query: ${sql}`;
    super(msg, { cause });
    this.#sql = sql;
  }
}
