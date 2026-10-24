import * as vg from '@uwdata/vgplot';

export default vg.plot(
  vg.dot([{"t":1,"u":2,"v":3,"w":4,"category":"A","row":"first","keep":true,"radius":3},{"t":3,"u":4,"v":5,"w":6,"category":"B","row":"first","keep":false,"radius":0},{"t":5,"u":6,"v":2,"w":3,"category":"A","row":"second","keep":true,"radius":-1},{"t":7,"u":8,"v":4,"w":5,"category":"B","row":"second","keep":false,"radius":4}], {"x": "t", "y": "v", "r": 4}),
  vg.width(420),
  vg.height(260)
);
