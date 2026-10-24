package colorattributes

import (
	"encoding/json"
	starter "idl.uw.edu/mosaic/api/marks/render:markrender"
)

attributeExamples: [{name: "colorScheme", attribute: "colorScheme", value: "YlGnBu", reactive: true}]
exampleRows: [{x: 1, y: 2, value: 1, category: "A"}, {x: 2, y: 1, value: 2, category: "B"}, {x: 3, y: 3, value: 3, category: "C"}]
exampleProjections: colorScheme: starter.#PlotStarter & {
	name: "colorScheme"
	rows: exampleRows
	marks: [{name: "dot", data: "inline", options: {x: "x", y: "y", r: 5, fill: "value"}}]
	attributes: {width: 320, height: 200, colorScale: "linear", colorScheme: "$setting"}
	parameters: {setting: attributeExamples[0].value}
}
templateFiles: {for Name, Source in exampleProjections.colorScheme.files {"templates/attributes/color/\(Name)": Source}}
_attributeNativeChecks: [{files: {
	"contracts.cue": projection.nativeSource
	"examples.cue":  "package colorattributeadmission\n\nscheme: #ColorAttributes & {colorScheme:" + json.Marshal(attributeExamples[0].value) + "}\n"
}}]
