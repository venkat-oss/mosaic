import assert from 'node:assert/strict';
import test from 'node:test';
import { ConnectedMark } from '@uwdata/mosaic-plot';
import { compile, createExecutionContext, isBetween, column } from '@uwdata/mosaic-sql';
import { DuckDB } from '../../packages/server/duckdb/src/DuckDB.js';

const database = new DuckDB(':memory:', {}, '');
const execution = createExecutionContext();
const sql = query => compile([query], execution)[0];
await database.exec(`CREATE TABLE connected_data(t DOUBLE, v DOUBLE, series VARCHAR); INSERT INTO connected_data VALUES
  (3,9,'a'),(2,0,'a'),(0,2,'a'),(5,1,'a'),(1,-5,'a'),(4,4,'a'),
  (3,109,'b'),(2,100,'b'),(0,102,'b'),(5,101,'b'),(1,95,'b'),(4,104,'b')`);

function connected(type, optimize, count = 12, valueType = 'number') {
  const dim = type.endsWith('X') ? 'y' : 'x';
  const ortho = dim === 'x' ? 'y' : 'x';
  const source = { table: 'connected_data', options: { optimize } };
  const mark = new ConnectedMark(type, source, { [dim]: 't', [ortho]: 'v', z: 'series' });
  Object.assign(mark.channelField(dim), { type: valueType, min: 0, max: 5, count });
  mark.plot = {
    innerWidth: () => 2,
    innerHeight: () => 2,
    getAttribute: () => undefined
  };
  return mark;
}
function times(rows, group) {
  return rows.filter(row => row.series === group).map(row => row.t);
}

for (const type of ['lineX', 'lineY', 'areaX', 'areaY']) {
  test(`${type} preserves grouped endpoints and extrema with actual M4 queries`, async () => {
    const mark = connected(type, true);
    const query = mark.query();
    assert.match(sql(query), /ARG_MIN/);
    const rows = await database.query(sql(query));
    assert.deepEqual(times(rows, 'a'), [0, 1, 3, 4, 5]);
    assert.deepEqual(times(rows, 'b'), [0, 1, 3, 4, 5]);
    assert.deepEqual(rows.filter(row => row.series === 'a').map(row => row.v), [2, -5, 9, 4, 1]);
  });
}

test('explicit optimization false retains every row in dimension order', async () => {
  const mark = connected('lineY', false);
  const query = mark.query();
  assert.doesNotMatch(sql(query), /ARG_MIN/);
  const rows = await database.query(sql(query));
  assert.deepEqual(times(rows, 'a'), [0, 1, 2, 3, 4, 5]);
  assert.deepEqual(times(rows, 'b'), [0, 1, 2, 3, 4, 5]);
});

test('automatic M4 keeps the existing strict ten-records-per-pixel threshold', () => {
  assert.doesNotMatch(sql(connected('lineY', undefined, 20).query()), /ARG_MIN/);
  assert.match(sql(connected('lineY', undefined, 21).query()), /ARG_MIN/);
  assert.doesNotMatch(sql(connected('lineY', true, 100, 'string').query()), /ARG_MIN/);
});

test('M4 retains active SQL filters and its filtered bin extent', async () => {
  const mark = connected('lineY', true);
  const query = mark.query([isBetween(column('t'), [1, 4])]);
  const rows = await database.query(sql(query));
  assert.deepEqual(times(rows, 'a'), [1, 3, 4]);
  assert.deepEqual(times(rows, 'b'), [1, 3, 4]);
  assert.match(sql(query), /WHERE "t" >= 1 AND "t" <= 4/);
});

test.after(() => database.close());
