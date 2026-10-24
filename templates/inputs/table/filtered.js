import * as vg from '@uwdata/vgplot';

await vg.coordinator().exec(vg.createTable('table_data', "SELECT * FROM (VALUES (1,'A'),(2,'B'),(3,'A'),(4,'B'),(5,'A')) AS t(x,category)"));
const upstream = vg.Selection.intersect();
export default vg.vconcat(
  vg.menu({as:upstream,field:'category',options:['A','B']}),
  vg.table({from:'table_data',columns:['x','category'],filterBy:upstream,rowBatch:2})
);
