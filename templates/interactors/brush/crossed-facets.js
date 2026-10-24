import * as vg from '@uwdata/vgplot';

export const selection = vg.Selection.crossfilter();
await vg.coordinator().exec(vg.createTable('brush_rows', "SELECT * FROM (VALUES (1,2,'A','U'),(3,4,'B','V'),(5,6,'A','U')) AS t(x,y,category,bucket)"));
export default vg.hconcat(
  vg.plot(
    vg.dot(vg.from('brush_rows', {filterBy:selection}), {x:'x', y:'y', z:'category', fill:'category', fx:'category', fy:'bucket'}),
    vg.intervalX({as:selection}), vg.width(360), vg.height(260)
  ),
  vg.plot(vg.dot(vg.from('brush_rows', {filterBy:selection}), {x:'x', y:'y', fill:'category'}), vg.width(360), vg.height(260))
);
