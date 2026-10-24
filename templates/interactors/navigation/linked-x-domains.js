import * as vg from '@uwdata/vgplot';

export const x = vg.Selection.intersect();
const chart = () => vg.plot(
  vg.dot([{"x":1,"y":2},{"x":3,"y":4},{"x":5,"y":6},{"x":7,"y":3},{"x":9,"y":8}], {x:'x', y:'y'}), vg.panZoomX({x}),
  vg.xDomain([0,10]), vg.yDomain([0,10]), vg.width(360), vg.height(260)
);
export default vg.hconcat(chart(), chart());
