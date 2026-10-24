import * as vg from '@uwdata/vgplot';

export default vg.plot(
  vg.dot([{"x":2,"y":3,"facet":"a","row":"c"},{"x":7,"y":8,"facet":"b","row":"d"}], {x:'x', y:'y'}),
  vg.axisX({ticks:[0,5,10], tickFormat:value=>"v="+value}),
  vg.axis(null), vg.xDomain([0,10]), vg.yDomain([0,10]),
  vg.width(320), vg.height(240), vg.margin(40)
);
