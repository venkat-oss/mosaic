import * as vg from '@uwdata/vgplot';

await vg.coordinator().exec(vg.createTable('input_data', "SELECT * FROM (VALUES (1, 'Alpha', ['Alpha','Beta']), (2, 'Beta', ['Beta']), (3, 'Gamma', ['Gamma'])) AS t(x, category, items)"));
const binding = vg.Selection.crossfilter();

export default vg.menu({"as": binding, "label": "Category", "field": "category", "from": "input_data", "column": "category"});
