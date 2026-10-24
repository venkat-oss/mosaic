package sizeattributes

import starter "idl.uw.edu/mosaic/api/marks/render:markrender"

knownDefects: [
	for Attribute in ["rRange", "lengthRange"] {{attribute: Attribute, error: "Unsupported fixed attribute: \(Attribute)", description: "Fixed is admitted and serializes, but only Fixed domain inference is implemented. Use an explicit range array."}},
	for Attribute in ["rScale", "lengthScale"] {{attribute: Attribute, error: "unknown scale type: null", description: "Null is admitted and serializes, but scale creation rejects it."}},
]
sampleProjections: {"radius-range-parameter": starter.#PlotStarter & {name: "radius-range-parameter", rows: sampleRows, marks: [{name: "dot", data: "inline", options: {x: "x", y: "y", r: "radius"}}], attributes: {width: 300, height: 180, rScale: "linear", rDomain: [0, 10], rRange: "$range"}, parameters: {range: samples[0].value}}}
templateFiles: {for Name, Source in sampleProjections["radius-range-parameter"].files {"templates/attributes/size/\(Name)": Source}}
