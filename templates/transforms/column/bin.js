import * as vg from '@uwdata/vgplot';

await vg.coordinator().exec(vg.createTable('column_data', "SELECT x, y, DATE '2024-01-01' + CAST(x AS INTEGER) AS time FROM (VALUES (1,2),(2,1),(3,3)) AS t(x,y)"));
export default vg.plot(vg.dot(vg.from('column_data'), {x:vg.bin("x", {"steps":4}), y:'y'}));
