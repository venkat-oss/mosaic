import * as vg from '@uwdata/vgplot';
import { interpolateBlues } from 'd3';

export default vg.plot(
  vg.dot([{"x":1,"y":2,"value":1,"category":"A"},{"x":2,"y":1,"value":2,"category":"B"},{"x":3,"y":3,"value":3,"category":"C"}], {x:'x', y:'y', fill:'value', r:5}),
  vg.colorScale('linear'), vg.colorDomain([0,3]), vg.colorInterpolate(interpolateBlues)
);
