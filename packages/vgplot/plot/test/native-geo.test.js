import { expect, it } from 'vitest';
import { NativeSqlContext } from '@uwdata/mosaic-core';
import { fields, isExpression } from '@uwdata/mosaic-sql/native';
import { GeoMark } from '../src/marks/GeoMark.js';

it('selects native geometry conversion without changing shared encoding objects', () => {
  const context = new NativeSqlContext();
  const encodings = { fill: 'steelblue' };
  const mark = new GeoMark({ table: 'states' }, encodings, context);
  const geometry = mark.channelField('geometry').field;
  expect(mark.sqlOwner).toBe(context);
  expect(isExpression(geometry)).toBe(true);
  expect(fields(geometry).map(({ column, table }) => ({ column, table }))).toEqual([{ column: 'geom', table: undefined }]);
  expect(encodings).toEqual({ fill: 'steelblue' });
  expect(new GeoMark(null, encodings).sqlOwner).toBeNull();
});
