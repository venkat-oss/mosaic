import * as vg from '@uwdata/vgplot';

export default vg.plot(
  vg.dot([{"x":1,"y":1,"column":1,"row":10},{"x":2,"y":3,"column":2,"row":10},{"x":3,"y":2,"column":1,"row":20},{"x":4,"y":4,"column":2,"row":20}], {"x": "x", "y": "y", "r": 4, "fx": "column", "fy": "row"}),
  vg.width(480),
  vg.height(360),
  vg.fxDomain([2,1,3]),
  vg.fyDomain([20,10])
);
