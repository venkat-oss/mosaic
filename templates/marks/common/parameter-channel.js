import * as vg from '@uwdata/vgplot';

await vg.coordinator().exec(vg.createTable('common_data', "SELECT * FROM (VALUES (1, 2, 'A', DATE '2024-01-01'), (1, 1, 'B', DATE '2024-01-01'), (2, 1, 'A', DATE '2024-01-02'), (2, 2, 'B', DATE '2024-01-02'), (3, 3, 'A', DATE '2024-01-03'), (3, 1, 'B', DATE '2024-01-03')) AS t(x, y, category, time)"));
const fill = vg.Param.value('steelblue');
export default vg.plot(
  vg.dot(vg.from('common_data'), {x:'x', y:'y', fill}),
  vg.width(360)
);
