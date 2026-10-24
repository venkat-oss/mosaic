import * as vg from '@uwdata/vgplot';

await vg.coordinator().exec(vg.createTable('layout_data', "SELECT * FROM (VALUES (1, 2, 'A'), (2, 1, 'B'), (3, 3, 'A')) AS t(x, y, category)"));
const radius = vg.Param.value(4);
const chart = () => vg.plot(
  vg.dot(vg.from('layout_data'), {x: 'x', y: 'y', r: radius}),
  vg.width(180),
  vg.height(140)
);

export default vg.hconcat(chart(), vg.hspace(12), vg.vconcat(chart(), vg.vspace(8), chart()));
