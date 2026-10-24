import * as vg from '@uwdata/vgplot';

export const range = vg.Param.value([2,14]);
export default vg.plot(
  vg.dot([{"x":1,"y":1,"radius":1,"magnitude":2},{"x":2,"y":2,"radius":4,"magnitude":5},{"x":3,"y":1,"radius":9,"magnitude":8}], {"x": "x", "y": "y", "r": "radius"}),
  vg.width(300),
  vg.height(180),
  vg.rScale("linear"),
  vg.rDomain([0,10]),
  vg.rRange(range)
);
