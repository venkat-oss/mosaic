package brushinteractors

import (
	"encoding/json"
	"encoding/yaml"
)

exampleWidth:  360
exampleHeight: 260
exampleQuery:  "SELECT * FROM (VALUES (1,2,'A','U'),(3,4,'B','V'),(5,6,'A','U')) AS t(x,y,category,bucket)"
examples: [{id: "crossed-facets", interactor: "intervalX", kind: "facets"}]
nativeExamples: []
exampleProjections: [{example: examples[0]
	firstView: {plot: [{mark: "dot", data: {from: "brush_rows", filterBy: "$selection"}, x: "x", y: "y", z: "category", fill: "category", fx: "category", fy: "bucket"}, {select: "intervalX", as: "$selection"}], width: exampleWidth, height: exampleHeight}
	secondView: {plot: [{mark: "dot", data: {from: "brush_rows", filterBy: "$selection"}, x: "x", y: "y", fill: "category"}], width: exampleWidth, height: exampleHeight}
	specification: {data: brush_rows: {type: "table", query: exampleQuery}, params: selection: {select: "crossfilter"}, hconcat: [firstView, secondView]}
	javascript: """
import * as vg from '@uwdata/vgplot';

export const selection = vg.Selection.crossfilter();
await vg.coordinator().exec(vg.createTable('brush_rows', \(json.Marshal(exampleQuery))));
export default vg.hconcat(
  vg.plot(
    vg.dot(vg.from('brush_rows', {filterBy:selection}), {x:'x', y:'y', z:'category', fill:'category', fx:'category', fy:'bucket'}),
    vg.intervalX({as:selection}), vg.width(\(exampleWidth)), vg.height(\(exampleHeight))
  ),
  vg.plot(vg.dot(vg.from('brush_rows', {filterBy:selection}), {x:'x', y:'y', fill:'category'}), vg.width(\(exampleWidth)), vg.height(\(exampleHeight)))
);

"""
	python:     """
from __future__ import annotations

import vgplot as vg

selection = vg.selection.crossfilter()
view = vg.spec(
    data={'brush_rows':vg.table(\(json.Marshal(exampleQuery)))},
    params={'selection':selection},
    view=vg.hconcat(
        vg.plot(
            vg.dot(vg.source('brush_rows', filter_by=selection), x='x', y='y', z='category', fill='category', fx='category', fy='bucket'),
            vg.interval_x(bind=selection), vg.width(\(exampleWidth)), vg.height(\(exampleHeight)),
        ),
        vg.plot(vg.dot(vg.source('brush_rows', filter_by=selection), x='x', y='y', fill='category'), vg.width(\(exampleWidth)), vg.height(\(exampleHeight))),
    ),
)

"""
}]
templateFiles: {for P in exampleProjections {
	"templates/interactors/brush/\(P.example.id).json": json.Indent(json.Marshal(P.specification), "", "  ") + "\n"
	"templates/interactors/brush/\(P.example.id).yaml": yaml.Marshal(P.specification)
	"templates/interactors/brush/\(P.example.id).js":   P.javascript
	"templates/interactors/brush/\(P.example.id).py":   P.python
}}
