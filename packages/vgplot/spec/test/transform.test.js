import { expect, it } from 'vitest';
import { isAggregateExpression, sql, sum, compile, createExecutionContext } from '@uwdata/mosaic-sql';
import { parseSpec } from '../src/index.js';

it('instantiates nested transforms and SQL expressions', () => {
  const ast = parseSpec({
    plot: [{
      mark: 'lineY',
      data: { from: 'sales' },
      x: 'day',
      y: { sum: { sum: { sql: 'amount' } }, orderby: 'day' },
    }],
  });
  const actual = ast.root.children[0].options.instantiate({ api: { sql, sum } }).y;
  expect(isAggregateExpression(actual)).toBe(true);
  expect(compile([actual], createExecutionContext()).join(';\n')).toBe(compile([sum(sum(sql`amount`)).orderby('day')], createExecutionContext()).join(';\n'));
});
