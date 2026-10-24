package facetattributes

import starter "idl.uw.edu/mosaic/api/marks/render:markrender"

knownDefects: [
	for Attribute in ["fxRange", "fyRange"] {{attribute: Attribute, description: "Fixed is admitted and serializes for facet ranges, but the renderer only implements Fixed domain inference. Use an explicit range array."}},
	for Attribute in ["fxLabelAnchor", "fyLabelAnchor"] {{attribute: Attribute, description: "The renderer accepts left/right/center for horizontal facet label anchors and top/bottom/center for vertical facet label anchors."}},
	{attribute: "fyInset", description: "The retained route is spelled fy,inset with a comma, so this directive does not change the facet scale range. Use fyInsetTop or fyInsetBottom."},
]
sampleProjections: {"fxDomain": starter.#PlotStarter & {name: "fxDomain", rows: exampleRows, marks: [{name: "dot", data: "inline", options: {x: "x", y: "y", r: 4, fx: "column", fy: "row"}}], attributes: {width: 480, height: 360, fxDomain: samples[0].value, fyDomain: samples[0].setup.fyDomain}, parameters: {}}}
templateFiles: {for Name, Source in sampleProjections["fxDomain"].files {"templates/attributes/facet/\(Name)": Source}}
