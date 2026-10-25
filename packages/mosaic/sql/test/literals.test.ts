import { DuckDB } from '@uwdata/mosaic-duckdb';
import { afterAll, describe, expect, it } from 'vitest';
import * as sql from '../src/index.js';

const db = new DuckDB(':memory:', {}, '');
const context = sql.createExecutionContext();
const execute = (query: sql.SqlRoot) => db.query(sql.compile([query], context)[0]);
afterAll(() => db.close());

describe('native literal data', () => {
  it('constructs list, typed-list and struct data without interpreting AST-shaped records', async () => {
    const record = { literal: { literal_type: 'number', value: '7' } };
    expect(await execute(sql.Query.select({
      record: sql.literal(record), values: sql.literal([1, null, 3]), typed: sql.literal(new Int32Array([1, 2]))
    }))).toEqual([{ record, values: [1, null, 3], typed: [1, 2] }]);
    await db.exec(sql.compile([sql.loadObjects('native_data_literals', [{ payload: record }])], context)[0]);
    expect(await execute(sql.Query.from('native_data_literals'))).toEqual([{ payload: record }]);
  });

  it('preserves binary byte ranges in canonical DuckDB BLOB literals', async () => {
    const bytes = new Uint8Array([9, 0, 65, 255, 9]);
    const values = [bytes.subarray(1, 4), new DataView(bytes.buffer, 1, 3), new Uint8Array([0, 65, 255]).buffer];
    for (const value of values) {
      const literal = sql.literal(value);
      expect(await execute(sql.Query.select({
        type: sql.native.call('typeof', [literal]), hex: sql.native.call('hex', [literal])
      }))).toEqual([{ type: 'BLOB', hex: '0041FF' }]);
    }
    expect(await execute(sql.Query.select({ empty: sql.native.call('hex', [sql.literal(new Uint8Array())]) })))
      .toEqual([{ empty: '' }]);
  });

  it('preserves explicit expression operands and resolves parameter data at submission', async () => {
    let value = { literal: { literal_type: 'number', value: '7' } };
    let reads = 0;
    const parameter = { get value() { ++reads; return value; }, addEventListener() {}, removeEventListener() {} };
    const field = sql.column('x');
    const values = sql.asLiteral([field, sql.literal(4)]);
    if (!('array' in values)) throw new Error('Expected a literal array.');
    expect(values.array.expressions[0]).toBe(field);
    const query = sql.Query.from(sql.Query.select({ x: 3 })).select({
      values, object: sql.asLiteral({ field, data: sql.asLiteral(parameter) }), again: sql.asLiteral(parameter)
    });
    expect(reads).toBe(0);
    const result = await execute(query);
    expect(reads).toBe(1);
    expect(result[0].values).toEqual([3, 4]);
    expect(result[0].object).toEqual({ field: 3, data: value });
    value = { literal: { literal_type: 'number', value: '8' } };
    expect((await execute(query))[0].object).toEqual({ field: 3, data: value });
    expect(reads).toBe(2);
    const cyclic: Record<string, unknown> = {};
    cyclic.self = cyclic;
    expect(() => sql.literal(cyclic)).toThrow(/cycles/);
    expect(() => sql.literal(new Map())).toThrow(/plain records/);
  });
});
