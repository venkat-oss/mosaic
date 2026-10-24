package plotattributes

import (
	"encoding/json"
	"encoding/yaml"
	"strings"
	"idl.uw.edu/mosaic/api/render"
)

attributeExamples: [{name: "margins", value: {top: 20, right: 12, bottom: 26, left: 34}}]
exampleRows: [{x: 1, y: 2}, {x: 2, y: 1}, {x: 3, y: 3}]
jsRows: json.Marshal(exampleRows)
runtimeLabelExample: {value: false}
exampleProjections: margins: {
	spec: {plot: [{mark: "dot", data: exampleRows, x: "x", y: "y", r: 4}], width: 280, height: 180, margins: attributeExamples[0].value}
}
_templateFiles: {
	"margins.json":     json.Indent(json.Marshal(exampleProjections.margins.spec), "", "  ") + "\n"
	"margins.yaml":     yaml.Marshal(exampleProjections.margins.spec)
	"margins.js":       """
import * as vg from '@uwdata/vgplot';

export default vg.plot(
  vg.dot(\(jsRows), {x:'x', y:'y', r:4}),
  vg.width(280), vg.height(180), vg.margins(\(json.Marshal(attributeExamples[0].value)))
);

"""
	"margins.py":       """
from __future__ import annotations

import json
import vgplot as vg

view = vg.spec(view=vg.plot(
    vg.dot(json.loads(\(json.Marshal(jsRows))), x='x', y='y', r=4),
    vg.width(280), vg.height(180), vg.margins(**json.loads(\(json.Marshal(json.Marshal(attributeExamples[0].value))))),
))

"""
	"runtime-label.js": """
		import * as vg from '@uwdata/vgplot';
		import { Plot } from '@uwdata/mosaic-plot';

		const plot = new Plot();
		vg.dot(\(jsRows), {x: 'x', y: 'y'})(plot);
		plot.setAttribute(\((render.#TypeScriptLiteral & {value: labelRoute.name}).text), \(json.Marshal(runtimeLabelExample.value)));
		await plot.render();
		export default plot.element;

		"""
}
templateFiles: {for Name, Source in _templateFiles {"templates/attributes/plot/\(Name)": Source}}
nativeChecks: [{files: {
	"contracts.cue": _typeFiles["packages/vgplot/spec/src/generated/plot-attributes.cue"]
	"examples.cue": "package plotattributeadmission\n\n" + strings.Join([for example in attributeExamples {"\(json.Marshal(example.name)): #PlotContainerAttributes & {\(json.Marshal(example.name)): \(json.Marshal(example.value))}\n"}], "\n")
}}]
