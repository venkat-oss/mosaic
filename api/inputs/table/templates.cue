package tableinput

import (
	"encoding/json"
	"encoding/yaml"
)

tableExamples: [{name: "filtered"}]
exampleQuery: "SELECT * FROM (VALUES (1,'A'),(2,'B'),(3,'A'),(4,'B'),(5,'A')) AS t(x,category)"
exampleProjections: filtered: {
	table: {input: api.name, from: "table_data", columns: ["x", "category"], filterBy: "$upstream", rowBatch: 2}
	spec: {data: table_data: {type: "table", query: exampleQuery}, params: upstream: {select: "intersect"}, vconcat: [{input: "menu", as: "$upstream", field: "category", options: ["A", "B"]}, table]}
}
_tableTemplates: {
	"filtered.json":    json.Indent(json.Marshal(exampleProjections.filtered.spec), "", "  ") + "\n"
	"filtered.yaml":    yaml.Marshal(exampleProjections.filtered.spec)
	"filtered.js":      """
import * as vg from '@uwdata/vgplot';

await vg.coordinator().exec(vg.createTable('table_data', \(json.Marshal(exampleQuery))));
const upstream = vg.Selection.intersect();
export default vg.vconcat(
  vg.menu({as:upstream,field:'category',options:['A','B']}),
  vg.table({from:'table_data',columns:['x','category'],filterBy:upstream,rowBatch:2})
);

"""
	"filtered.py":      """
from __future__ import annotations

import vgplot as vg

upstream = vg.selection.intersect()
view = vg.Spec(
    data={'table_data':vg.table(\(json.Marshal(exampleQuery)))},
    params={'upstream':upstream},
    view=vg.vconcat(
        vg.menu(bind=upstream,field='category',options=['A','B']),
        vg.\(api.python)(source='table_data',columns=['x','category'],filter_by=upstream,row_batch=2),
    ),
)

"""
	"native-format.js": """
  import * as vg from '@uwdata/vgplot';

  await vg.coordinator().exec(vg.createTable('table_data', \(json.Marshal(exampleQuery))));
  const element = document.createElement('section');
  export default vg.table({from:'table_data', columns:['x','category'], element, format:{x:value => `Value ${value}`, category:value => {const strong=document.createElement('strong');strong.textContent=value;return strong;}}});

  """
}
templateFiles: {for Name, Source in _tableTemplates {"templates/inputs/table/\(Name)": Source}}
