import * as vg from '@uwdata/vgplot';

const container = document.createElement('section');
const binding = vg.Param.value(1);
export default vg.menu({element: container, as: binding, options: [1, 2], format: value => `Value ${value}`});
