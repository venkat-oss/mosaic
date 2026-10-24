import * as vg from '@uwdata/vgplot';

await vg.coordinator().exec(vg.createTable('window_data', 'SELECT id, x, y, category, TIMESTAMP \'2024-01-01\' + id * INTERVAL 1 MICROSECOND AS time FROM (VALUES (1, 1, 10, \'A\'), (2, 2, 20, \'A\'), (3, 2, 30, \'A\'), (4, 3, 40, \'A\')) AS t(id, x, y, category)'));
const frame = vg.Param.value([1, 0]);

export default vg.plot(
  vg.dot(vg.from('window_data'), {x: 'id', y: vg.sum('y').orderby('id').partitionby('category').frame(vg.frameRows(frame)), r: 4})
);
