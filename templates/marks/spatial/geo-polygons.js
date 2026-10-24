import * as vg from '@uwdata/vgplot';

export default vg.plot(
  vg.geo([{"geometry":{"type":"Polygon","coordinates":[[[-25,-10],[-25,10],[-5,10],[-5,-10],[-25,-10]]]},"name":"West"},{"geometry":{"type":"Polygon","coordinates":[[[5,-10],[5,10],[25,10],[25,-10],[5,-10]]]},"name":"East"}], {"stroke": "steelblue", "geometry": "geometry", "r": 4}),
  vg.width(420),
  vg.height(260),
  vg.projectionType("equirectangular"),
  vg.projectionDomain({"type":"Sphere"})
);
