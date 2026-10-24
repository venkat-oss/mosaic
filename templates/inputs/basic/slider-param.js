import * as vg from '@uwdata/vgplot';

await vg.coordinator().exec(vg.createTable('input_data', "SELECT * FROM (VALUES (1, 'Alpha', ['Alpha','Beta']), (2, 'Beta', ['Beta']), (3, 'Gamma', ['Gamma'])) AS t(x, category, items)"));
const binding = vg.Param.value(2);

export default vg.slider({"as": binding, "label": "Value", "field": "x", "from": "input_data", "column": "x", "step": 1, "value": 2});
