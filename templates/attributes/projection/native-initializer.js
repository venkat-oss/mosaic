import * as vg from '@uwdata/vgplot';
import { geoMercator } from 'd3';

const projection = ({width, height}) => geoMercator().scale(50).translate([width / 2, height / 2]);
export default vg.plot(
  vg.dot([{"lon":-122.3,"lat":47.6},{"lon":-87.6,"lat":41.9},{"lon":-74,"lat":40.7}], {x:'lon', y:'lat', r:4}),
  vg.projectionType(projection), vg.width(300), vg.height(200)
);
