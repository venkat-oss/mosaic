import * as vg from '@uwdata/vgplot';

await vg.coordinator().exec(vg.createTable('nested_rows', "SELECT [1,2,3] AS items, 1 AS y"));
export default vg.plot(vg.dot(vg.from('nested_rows', {unnest:['items']}), {x:'items', y:'y'}));
