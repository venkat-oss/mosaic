import * as vg from '@uwdata/vgplot';

export const domain = vg.Param.value([0,4]);
export default vg.plot(
  vg.dot([{"x":1,"y":2,"category":"A"},{"x":2,"y":1,"category":"B"},{"x":3,"y":3,"category":"C"}], {"x": "x", "y": "y", "r": 4}),
  vg.width(300),
  vg.height(200),
  vg.xDomain(domain)
);
