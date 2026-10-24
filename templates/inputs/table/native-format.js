import * as vg from '@uwdata/vgplot';

await vg.coordinator().exec(vg.createTable('table_data', "SELECT * FROM (VALUES (1,'A'),(2,'B'),(3,'A'),(4,'B'),(5,'A')) AS t(x,category)"));
const element = document.createElement('section');
export default vg.table({from:'table_data', columns:['x','category'], element, format:{x:value => `Value ${value}`, category:value => {const strong=document.createElement('strong');strong.textContent=value;return strong;}}});
