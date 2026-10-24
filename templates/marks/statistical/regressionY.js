import * as vg from '@uwdata/vgplot';

await vg.coordinator().exec(vg.createTable("statistical_regressionY", "SELECT g, CAST(x AS DOUBLE) AS x, CAST(y AS DOUBLE) AS y FROM (VALUES ('A',1,1),('A',2,3),('A',3,2),('A',4,5),('A',5,4),('A',6,6.5)) AS t(g,x,y)"));

export default vg.plot(
  vg.regressionY(vg.from("statistical_regressionY"), {"x": "x", "y": "y", "stroke": "g"}),
  vg.width(320),
  vg.height(240),
  vg.margin(40),
  vg.axis(null),
  vg.xDomain([1,6]),
  vg.yDomain([0,8])
);
