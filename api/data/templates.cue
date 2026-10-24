package data

import (
	"encoding/json"
	"encoding/yaml"
)

exampleQuery: "SELECT * FROM (VALUES (39.1,181),(39.5,186),(40.3,195)) AS t(bill_length,flipper_length)"
dataExamples: [{name: "source-filtered", contract: "PlotFrom", kind: "source", source: "filtered", definition: {type: "table", query: exampleQuery}}]
exampleProjections: "source-filtered": {
	markData: {from: "data_rows", filterBy: "$brush"}
	spec: {data: {data_rows: dataExamples[0].definition}, params: brush: {select: "intersect", empty: false}, plot: [{mark: "dot", data: markData, x: "bill_length", y: "flipper_length"}]}
}
_dataTemplates: {
	let P = exampleProjections["source-filtered"]
	"source-filtered.json": json.Indent(json.Marshal(P.spec), "", "  ") + "\n"
	"source-filtered.yaml": yaml.Marshal(P.spec)
	"source-filtered.js":   """
import * as vg from '@uwdata/vgplot';

await vg.coordinator().exec(vg.createTable('data_rows', \(json.Marshal(exampleQuery))));
const brush = vg.Selection.intersect({empty:false});
export default vg.plot(vg.dot(vg.from('data_rows', {filterBy:brush}), {x:'bill_length', y:'flipper_length'}));

"""
	"source-filtered.py":   """
from __future__ import annotations

import vgplot as vg

brush = vg.selection.intersect(empty=False)
view = vg.spec(
    data={'data_rows':vg.table(\(json.Marshal(exampleQuery)))},
    params={'brush':brush},
    view=vg.plot(vg.dot(vg.source('data_rows', filter_by=brush), x='bill_length', y='flipper_length')),
)

"""
	"unnest.js": """
		import * as vg from '@uwdata/vgplot';

		await vg.coordinator().exec(vg.createTable('nested_rows', "SELECT [1,2,3] AS items, 1 AS y"));
		export default vg.plot(vg.dot(vg.from('nested_rows', {unnest:['items']}), {x:'items', y:'y'}));

		"""
	"unnest.py": """
		from __future__ import annotations

		import vgplot as vg

		view = vg.Spec(data={"nested_rows":vg.table("SELECT [1,2,3] AS items, 1 AS y")}, view=vg.plot(vg.dot(vg.source("nested_rows", unnest=["items"]), x="items", y="y")))

		"""
	"frames.py": """
		from __future__ import annotations

		import pyarrow as pa
		import vgplot as vg

		frame = pa.table({"bill_length":[39.1,39.5],"flipper_length":[181,186]})
		view = vg.plot(vg.dot(frame,x="bill_length",y="flipper_length"))

		"""
}
templateFiles: {for Name, Source in _dataTemplates {"templates/data/\(Name)": Source}}
