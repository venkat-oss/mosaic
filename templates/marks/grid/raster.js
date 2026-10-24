import * as vg from '@uwdata/vgplot';

await vg.coordinator().exec(vg.createTable("grid_data", "SELECT * FROM (VALUES (0,0,'A',1),(1,1,'A',2),(2,2,'A',3),(3,3,'A',4),(4,4,'A',5),(0,4,'B',2),(1,3,'B',3),(2,2,'B',4),(3,1,'B',5),(4,0,'B',6)) AS t(x,y,series,value)"));

export default vg.plot(
  vg.raster(vg.from("grid_data"), {"x": "x", "y": "y", "fill": "density", "width": 5, "height": 5, "bandwidth": 8}),
  vg.xDomain([0,4]),
  vg.yDomain([0,4]),
  vg.width(180),
  vg.height(160)
);
