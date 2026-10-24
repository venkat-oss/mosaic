import assert from 'node:assert/strict';
import test from 'node:test';
import * as vg from '../../packages/vgplot/vgplot/src/index.js';
import { DuckDB } from '../../packages/server/duckdb/src/DuckDB.js';

const database = new DuckDB(':memory:', {}, '');
await database.exec("CREATE TABLE statistics(g VARCHAR,x DOUBLE,y DOUBLE);INSERT INTO statistics VALUES ('A',0,1),('A',1,3),('A',2,5),('B',0,2),('B',1,4),('B',2,6)");
await database.exec('CREATE TABLE hex_points(x DOUBLE,y DOUBLE);INSERT INTO hex_points VALUES (0.1,0.1),(0.1,0.1),(0.1,0.1),(0.9,0.9),(NULL,0.5)');
function construct(name, options, table = 'statistics') {
  let result;
  const source = { table, options: {} };
  vg[name](source, options)({ addMark: mark => { result = mark; } });
  assert.equal(result.source, source);
  return result;
}
for (const [name, constructor, type] of [
  ['hexbin', 'HexbinMark', 'hexagon'], ['regressionY', 'RegressionMark', 'line'],
  ['errorbarX', 'ErrorBarMark', 'ruleY'], ['errorbarY', 'ErrorBarMark', 'ruleX']
]) test(name + ' retains its actual constructor and runtime orientation', () => {
  const mark = construct(name, { x: 'x', y: 'y' });
  assert.equal(mark.constructor.name, constructor);
  assert.equal(mark.type, type);
  if (name === 'hexbin') {
    assert.equal(mark.binWidth, 20);
    assert.equal(mark.channel('r').value, 10);
    assert.equal(mark.channel('clip').value, true);
  } else {
    assert.equal(mark.ci, 0.95);
    if (name === 'regressionY') assert.equal(mark.precision, 4);
    else assert.equal(mark.dim, name === 'errorbarX' ? 'x' : 'y');
  }
});
for (const name of ['hexbin', 'regressionY', 'errorbarX', 'errorbarY']) test(name + ' preserves its required native options argument', () => {
  assert.throws(() => vg[name]({ x: 'x', y: 'y' })({ addMark() {} }), TypeError);
});
for (const [name, dim] of [['errorbarX', 'x'], ['errorbarY', 'y']]) test(name + ' computes grouped confidence bounds from actual DuckDB aggregates', async () => {
  const options = dim === 'x' ? { x: 'y', y: 'g' } : { x: 'g', y: 'y' };
  const mark = construct(name, options);
  const rows = (await database.query(String(mark.query()))).sort((a, b) => a.g.localeCompare(b.g));
  assert.deepEqual(rows.map(row => [row.g, row.__avg__]), [['A', 3], ['B', 4]]);
  for (const row of rows) assert.ok(Math.abs(row.__se__ - 2 / Math.sqrt(3)) < 1e-10);
  mark.queryResult(rows);
  const [spec] = mark.plotSpecs();
  assert.equal(spec.type, dim === 'x' ? 'ruleY' : 'ruleX');
  const halfWidth = 1.959963984540054 * 2 / Math.sqrt(3);
  for (let i = 0; i < rows.length; i++) {
    assert.ok(Math.abs(spec.options[dim + '1'][i] - (rows[i].__avg__ - halfWidth)) < 1e-6);
    assert.ok(Math.abs(spec.options[dim + '2'][i] - (rows[i].__avg__ + halfWidth)) < 1e-6);
  }
});
for (const ci of [0, 0.95]) test('regressionY preserves grouped exact fits with ci=' + ci, async () => {
  const mark = construct('regressionY', { x: 'x', y: 'y', stroke: 'g', ci });
  mark.plot = { innerWidth: () => 200 };
  const rows = (await database.query(String(mark.query()))).sort((a, b) => a.g.localeCompare(b.g));
  assert.deepEqual(rows.map(row => [row.g, row.intercept, row.slope, Number(row.n)]), [['A', 1, 2, 3], ['B', 2, 2, 3]]);
  mark.queryResult(rows);
  assert.deepEqual(mark.lineData.columns.x, [0, 0, 2, 2]);
  assert.deepEqual(mark.lineData.columns.y, [1, 2, 5, 6]);
  assert.deepEqual(mark.plotSpecs().map(spec => spec.type), ci ? ['areaY', 'line'] : ['line']);
  if (ci) for (let i = 0; i < mark.areaData.numRows; i++) assert.ok(Math.abs(mark.areaData.columns.y1[i] - mark.areaData.columns.y2[i]) < 1e-10);
});
test('hexbin executes screen-space binning and excludes null positions in DuckDB', async () => {
  const mark = construct('hexbin', { x: 'x', y: 'y', fill: vg.count() }, 'hex_points');
  const attrs = { xDomain: [0, 1], yDomain: [0, 1], marginLeft: 0, marginTop: 0 };
  mark.plot = { innerWidth: () => 200, innerHeight: () => 200, getAttribute: key => attrs[key] };
  const rows = await database.query(String(mark.query()));
  assert.deepEqual(rows.map(row => Number(row[mark.channelField('fill').as])).sort(), [1, 3]);
  for (const row of rows) assert.ok(Number.isFinite(row.x) && Number.isFinite(row.y));
});
test.after(() => database.close());
