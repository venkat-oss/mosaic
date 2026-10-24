import * as vg from '@uwdata/vgplot';

export const setting = vg.Param.value("YlGnBu");
export default vg.plot(
  vg.dot([{"x":1,"y":2,"value":1,"category":"A"},{"x":2,"y":1,"value":2,"category":"B"},{"x":3,"y":3,"value":3,"category":"C"}], {"x": "x", "y": "y", "r": 5, "fill": "value"}),
  vg.width(320),
  vg.height(200),
  vg.colorScale("linear"),
  vg.colorScheme(setting)
);
