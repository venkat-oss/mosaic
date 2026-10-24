import * as vg from '@uwdata/vgplot';

await vg.coordinator().exec(vg.createTable("density_data", "SELECT * FROM (VALUES (0,'A',1),(1,'A',2),(2,'A',3),(3,'A',2),(4,'A',1),(0,'B',2),(1,'B',1),(2,'B',2),(3,'B',1),(4,'B',2)) AS t(value,series,weight)"));

export default vg.plot(
  vg.densityY(vg.from("density_data"), {"x": "value", "fill": "series", "bins": 32, "normalize": false, "bandwidth": 8}),
  vg.xDomain([0,4]),
  vg.width(360),
  vg.height(220)
);
