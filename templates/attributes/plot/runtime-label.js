import * as vg from '@uwdata/vgplot';
import { Plot } from '@uwdata/mosaic-plot';

const plot = new Plot();
vg.dot([{"x":1,"y":2},{"x":2,"y":1},{"x":3,"y":3}], {x: 'x', y: 'y'})(plot);
plot.setAttribute('label', false);
await plot.render();
export default plot.element;
