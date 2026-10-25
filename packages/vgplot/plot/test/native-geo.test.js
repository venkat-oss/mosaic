import { expect, it } from 'vitest';
import { fields, isExpression } from '@uwdata/mosaic-sql';
import { GeoMark } from '../src/marks/GeoMark.js';

it('selects native geometry conversion without changing shared encoding objects', () => {
  const encodings = { fill: 'steelblue' };
  const mark = new GeoMark({ table: 'states' }, encodings);
  const geometry = mark.channelField('geometry').field;
  expect(isExpression(geometry)).toBe(true);
  expect(fields(geometry).map(({ column, table }) => ({ column, table }))).toEqual([{ column: 'geom', table: undefined }]);
  expect(encodings).toEqual({ fill: 'steelblue' });
});
