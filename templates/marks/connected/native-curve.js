import * as vg from '@uwdata/vgplot';
import { curveBasis } from 'd3';

await vg.coordinator().exec(vg.createTable('connected_data', "SELECT * FROM (VALUES (0,2,1,3,'A'),(1,4,2,1,'A'),(2,1,3,4,'A'),(0,3,1,2,'B'),(1,1,2,4,'B'),(2,4,3,1,'B')) AS t(x,y,u,v,series)"));

export default vg.plot(
  vg.line(vg.from('connected_data'), {x: 'x', y: 'y', z: 'series', curve: curveBasis}),
  vg.width(360), vg.height(220)
);
