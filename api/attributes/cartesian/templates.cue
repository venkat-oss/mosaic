package cartesianattributes

import starter "idl.uw.edu/mosaic/api/marks/render:markrender"

knownDefects: [
	for Attribute in ["xRange", "yRange"] {{attribute: Attribute, description: "Fixed is admitted and serializes for ranges, but the renderer only implements Fixed domain inference. Use an explicit range array."}},
	for Attribute in ["xScale", "yScale"] {{attribute: Attribute, description: "Null is admitted and serializes, but scale creation rejects it with unknown scale type: null."}},
	for Attribute in ["xLabelAnchor", "yLabelAnchor"] {{attribute: Attribute, description: "The renderer accepts left/right/center for horizontal label anchors and top/bottom/center for vertical label anchors."}},
]
sampleProjections: {"xDomain-parameter": starter.#PlotStarter & {name: "xDomain-parameter", rows: exampleRows, marks: [{name: "dot", data: "inline", options: {x: "x", y: "y", r: 4}}], attributes: {width: 300, height: 200, xDomain: "$domain"}, parameters: {domain: samples[0].value}}}
templateFiles: {for Name, Source in sampleProjections["xDomain-parameter"].files {"templates/attributes/cartesian/\(Name)": Source}}
