import * as vg from '@uwdata/vgplot';
import { geoMercator } from 'd3';

const projection = ({width, height}) => geoMercator().scale(50).translate([width / 2, height / 2]);
export default vg.plot(
  vg.geo([{"geometry":{"type":"Point","coordinates":[-20,0]},"name":"West","radius":3},{"geometry":{"type":"Point","coordinates":[0,10]},"name":"North","radius":0},{"geometry":{"type":"Point","coordinates":[20,-5]},"name":"East","radius":-1}], {geometry:'geometry', r:4, stroke:'steelblue'}),
  vg.projectionType(projection), vg.width(420), vg.height(260)
);
