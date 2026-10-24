import * as vg from '@uwdata/vgplot';

await vg.coordinator().exec(vg.createTable('value_data', "SELECT * FROM (VALUES (1,2),(2,1),(3,3)) AS t(x,y)"));
export default vg.plot(vg.dotX(vg.from('value_data'), {x:'x', y:'y', interval:1}));
