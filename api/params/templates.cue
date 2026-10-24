package params

import (
	"encoding/json"
	"encoding/yaml"
)

paramExamples: [{name: "crossfilter", kind: "selection", contract: "Selection", factory: "crossfilter", value: {select: "crossfilter", empty: false, include: ["$upstream"]}}]
paramExampleQuery: "SELECT * FROM (VALUES (1,2,'A'),(2,1,'B'),(3,3,'A')) AS t(x,y,category)"
exampleProjections: crossfilter: {
	spec: {
		data: param_data: {type: "table", query: paramExampleQuery}
		params: {upstream: {select: "single"}, brush: paramExamples[0].value}
		vconcat: [for Index in [0, 1] {{plot: [{mark: "dot", data: {from: "param_data", filterBy: "$brush"}, x: "x", y: "y"}, if Index == 0 {{select: "toggleX", as: "$brush"}}]}}]
	}
	javascript: """
import * as vg from '@uwdata/vgplot';

await vg.coordinator().exec(vg.createTable('param_data', \(json.Marshal(paramExampleQuery))));
const upstream = vg.Selection.single();
const brush = vg.Selection.crossfilter({empty:false, include:[upstream]});
const chart = interactive => vg.plot(
  vg.dot(vg.from('param_data', {filterBy:brush}), {x:'x', y:'y'}),
  ...(interactive ? [vg.toggleX({as:brush})] : [])
);
export default vg.vconcat(chart(true), chart(false));

"""
	python:     """
from __future__ import annotations

import vgplot as vg

upstream = vg.selection.single()
brush = vg.selection.crossfilter(empty=False, include=[upstream])
view = vg.spec(
    data={'param_data':vg.table(\(json.Marshal(paramExampleQuery)))},
    params={'upstream':upstream, 'brush':brush},
    view=vg.vconcat(
        vg.plot(vg.dot(vg.source('param_data', filter_by=brush), x='x', y='y'), vg.toggle_x(bind=brush)),
        vg.plot(vg.dot(vg.source('param_data', filter_by=brush), x='x', y='y')),
    ),
)

"""
}
templateFiles: {
	let P = exampleProjections.crossfilter
	"templates/params/crossfilter.json": json.Indent(json.Marshal(P.spec), "", "  ") + "\n"
	"templates/params/crossfilter.yaml": yaml.Marshal(P.spec)
	"templates/params/crossfilter.js":   P.javascript
	"templates/params/crossfilter.py":   P.python
	"templates/params/anonymous.py":     """
from __future__ import annotations

import vgplot as vg

view = vg.Spec(
    data={'param_data':vg.table(\(json.Marshal(paramExampleQuery)))},
    view=vg.plot(vg.dot('param_data', x='x', y='y', r=vg.param(5))),
)

"""
}
