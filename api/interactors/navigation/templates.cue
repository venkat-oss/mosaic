package navigationinteractors

import (
	"encoding/json"
	"encoding/yaml"
)

exampleWidth:  360
exampleHeight: 260
exampleRows: [{x: 1, y: 2}, {x: 3, y: 4}, {x: 5, y: 6}, {x: 7, y: 3}, {x: 9, y: 8}]
examples: [{id: "linked-x-domains", interactor: "panZoomX", kind: "linked"}]
nativeExamples: []
exampleProjections: [{example: examples[0]
	view: {plot: [{mark: "dot", data: exampleRows, x: "x", y: "y"}, {select: "panZoomX", x: "$x"}], xDomain: [0, 10], yDomain: [0, 10], width: exampleWidth, height: exampleHeight}
	specification: {params: x: {select: "intersect"}, hconcat: [view, view]}
	javascript: """
import * as vg from '@uwdata/vgplot';

export const x = vg.Selection.intersect();
const chart = () => vg.plot(
  vg.dot(\(json.Marshal(exampleRows)), {x:'x', y:'y'}), vg.panZoomX({x}),
  vg.xDomain([0,10]), vg.yDomain([0,10]), vg.width(\(exampleWidth)), vg.height(\(exampleHeight))
);
export default vg.hconcat(chart(), chart());

"""
	python:     """
from __future__ import annotations

import json
import vgplot as vg

x = vg.selection.intersect()

def chart() -> vg.View:
    return vg.plot(
        vg.dot(json.loads(\(json.Marshal(json.Marshal([{x: 1, y: 2}, {x: 3, y: 4}, {x: 5, y: 6}, {x: 7, y: 3}, {x: 9, y: 8}])))), x='x', y='y'),
        vg.pan_zoom_x(x=x), vg.x_domain([0,10]), vg.y_domain([0,10]), vg.width(\(exampleWidth)), vg.height(\(exampleHeight)),
    )

view = vg.spec(params={'x':x}, view=vg.hconcat(chart(), chart()))

"""
}]
templateFiles: {for P in exampleProjections {
	"templates/interactors/navigation/\(P.example.id).json": json.Indent(json.Marshal(P.specification), "", "  ") + "\n"
	"templates/interactors/navigation/\(P.example.id).yaml": yaml.Marshal(P.specification)
	"templates/interactors/navigation/\(P.example.id).js":   P.javascript
	"templates/interactors/navigation/\(P.example.id).py":   P.python
}}
