import { describe, it, expect } from 'vitest';
import { tableFromArrays } from '@uwdata/flechette';
import { toDataColumns } from '../src/index.js';

describe('toDataColumns', () => {
  it('retains prototype-named object columns as own properties', () => {
    const data = [Object.fromEntries([['__proto__', 1], ['constructor', 'a']]), Object.fromEntries([['__proto__', 2], ['constructor', 'b']])];
    const result = toDataColumns(data);
    if (!('columns' in result)) throw new Error('Expected named columns.');
    expect(result.columns).toEqual(Object.fromEntries([['__proto__', [1, 2]], ['constructor', ['a', 'b']]]));
    expect(Object.hasOwn(result.columns, '__proto__')).toBe(true);
    expect(Object.getPrototypeOf(result.columns)).toBe(Object.prototype);
  });

  it('retains prototype-named Arrow columns, including their empty schema', () => {
    const tables = [tableFromArrays({ value: [1, 2] }), tableFromArrays({ value: new Int32Array() })];
    for (const table of tables.map(data => data.selectAt([0], ['__proto__']))) {
      const result = toDataColumns(table);
      if (!('columns' in result)) throw new Error('Expected named columns.');
      expect(Object.hasOwn(result.columns, '__proto__')).toBe(true);
      expect(Object.getPrototypeOf(result.columns)).toBe(Object.prototype);
      expect(Array.from(result.columns['__proto__'])).toEqual(table.numRows ? [1, 2] : []);
    }
  });

  it('extracts columns from an apache-arrow table', () => {
    const columns: Record<string, unknown[]> = { a: [1, 2], b: ['x', 'y'] };
    const children = Object.values(columns);
    const data = {
      numRows: 2,
      schema: { fields: Object.keys(columns).map(name => ({ name })) },
      getChild: () => null,
      getChildAt: (i: number) => ({ toArray: () => children[i] })
    };
    expect(toDataColumns(data)).toEqual({ numRows: 2, columns });
  });
});
