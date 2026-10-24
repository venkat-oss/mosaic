package pointinteractors

import (
	"encoding/json"
	"encoding/yaml"
)

exampleWidth:  420
exampleHeight: 260
exampleQuery:  "SELECT * FROM (VALUES (1,2,'A','red'),(3,4,'B','blue'),(5,6,'A','red')) AS t(x,y,series,category)"
examples: [{id: "toggle-filter-peers", interactor: "toggle", kind: "peers"}]
nativeExamples: []
exampleProjections: [{example: examples[0]
	specification: {data: point_rows: {type: "table", query: exampleQuery}, params: selection: {select: "intersect"}, plot: [{mark: "dot", data: {from: "point_rows"}, x: "x", y: "y", z: "series", fill: "category"}, {select: "toggle", as: "$selection", channels: ["x"], peers: false}, {select: "highlight", by: "$selection", opacity: 0.15}], width: exampleWidth, height: exampleHeight}
	javascript: """
import * as vg from '@uwdata/vgplot';

export const selection = vg.Selection.intersect();
await vg.coordinator().exec(vg.createTable('point_rows', \(json.Marshal(exampleQuery))));
export default vg.plot(
  vg.dot(vg.from('point_rows'), {x:'x', y:'y', z:'series', fill:'category'}),
  vg.toggle({as:selection, channels:['x'], peers:false}),
  vg.highlight({by:selection, opacity:0.15}),
  vg.width(\(exampleWidth)), vg.height(\(exampleHeight))
);

"""
	python:     """
from __future__ import annotations

import vgplot as vg

selection = vg.selection.intersect()
view = vg.spec(
    data={'point_rows':vg.table(\(json.Marshal(exampleQuery)))},
    params={'selection':selection},
    view=vg.plot(
        vg.dot(vg.source('point_rows'), x='x', y='y', z='series', fill='category'),
        vg.toggle(bind=selection, channels=['x'], peers=False),
        vg.highlight(by=selection, opacity=0.15),
        vg.width(\(exampleWidth)), vg.height(\(exampleHeight)),
    ),
)

"""
}]
templateFiles: {for P in exampleProjections {
	"templates/interactors/point/\(P.example.id).json": json.Indent(json.Marshal(P.specification), "", "  ") + "\n"
	"templates/interactors/point/\(P.example.id).yaml": yaml.Marshal(P.specification)
	"templates/interactors/point/\(P.example.id).js":   P.javascript
	"templates/interactors/point/\(P.example.id).py":   P.python
}}
