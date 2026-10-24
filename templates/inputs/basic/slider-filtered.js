import * as vg from '@uwdata/vgplot';

await vg.coordinator().exec(vg.createTable('input_data', "SELECT * FROM (VALUES (1, 'Alpha', ['Alpha','Beta']), (2, 'Beta', ['Beta']), (3, 'Gamma', ['Gamma'])) AS t(x, category, items)"));
const binding = vg.Selection.crossfilter();

const upstream = vg.Selection.intersect();

export default vg.vconcat(
  vg.menu({as: upstream, field: 'category', options: ['Alpha', 'Beta', 'Gamma']}),
  vg.slider({"as": binding, "label": "Value", "field": "x", "from": "input_data", "column": "x", "step": 1, "value": 2, "select": "point", "filterBy": upstream})
);
