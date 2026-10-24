import * as vg from '@uwdata/vgplot';

export default vg.plot(
  vg.dot([{"x":1,"y":2},{"x":2,"y":1},{"x":3,"y":3}], {x:'x', y:'y', r:4}),
  vg.width(280), vg.height(180), vg.margins({"top":20,"right":12,"bottom":26,"left":34})
);
