import * as vg from '@uwdata/vgplot';

export const selection = vg.Selection.intersect();
await vg.coordinator().exec(vg.createTable('point_rows', "SELECT * FROM (VALUES (1,2,'A','red'),(3,4,'B','blue'),(5,6,'A','red')) AS t(x,y,series,category)"));
export default vg.plot(
  vg.dot(vg.from('point_rows'), {x:'x', y:'y', z:'series', fill:'category'}),
  vg.toggle({as:selection, channels:['x'], peers:false}),
  vg.highlight({by:selection, opacity:0.15}),
  vg.width(420), vg.height(260)
);
