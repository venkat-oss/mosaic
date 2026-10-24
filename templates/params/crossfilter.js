import * as vg from '@uwdata/vgplot';

await vg.coordinator().exec(vg.createTable('param_data', "SELECT * FROM (VALUES (1,2,'A'),(2,1,'B'),(3,3,'A')) AS t(x,y,category)"));
const upstream = vg.Selection.single();
const brush = vg.Selection.crossfilter({empty:false, include:[upstream]});
const chart = interactive => vg.plot(
  vg.dot(vg.from('param_data', {filterBy:brush}), {x:'x', y:'y'}),
  ...(interactive ? [vg.toggleX({as:brush})] : [])
);
export default vg.vconcat(chart(true), chart(false));
