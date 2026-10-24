import * as vg from '@uwdata/vgplot';

await vg.coordinator().exec(vg.createTable('data_rows', "SELECT * FROM (VALUES (39.1,181),(39.5,186),(40.3,195)) AS t(bill_length,flipper_length)"));
const brush = vg.Selection.intersect({empty:false});
export default vg.plot(vg.dot(vg.from('data_rows', {filterBy:brush}), {x:'bill_length', y:'flipper_length'}));
