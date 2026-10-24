import type { Table } from '../src/index.js';

export const tableContracts = {
  minimal: { input: 'table', from: 'rows' } satisfies Table,
  dictionaries: { input: 'table', from: '$source', as: '$brush', align: { 'column.with space': 'justify' }, width: { 'column.with space': -2.5 }, height: 0, rowBatch: 0 } satisfies Table,
  references: { input: 'table', from: 'ordinary-reference', filterBy: '$filter', columns: ['category', 'x'] } satisfies Table
};

// @ts-expect-error The declarative table source is required.
export const missingSource: Table = { input: 'table' };
// @ts-expect-error Output bindings retain the TypeScript parameter prefix.
export const ordinaryBinding: Table = { input: 'table', from: 'rows', as: 'brush' };
// @ts-expect-error Dictionary values retain their closed alignment choices.
export const invalidAlignment: Table = { input: 'table', from: 'rows', align: { x: 'start' } };
// @ts-expect-error Native format callbacks have no declarative representation.
export const callbackTable: Table = { input: 'table', from: 'rows', format: { x: (value: unknown) => String(value) } };
