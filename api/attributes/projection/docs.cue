package projectionattributes

import "strings"

referenceNotes: [
	{attributes: ["projectionType"], text: "Native JavaScript initializer functions may return a D3 projection; they receive the available inner frame dimensions and routed projection options. A direct D3 projection passed through this attribute fails with projection.stream is not a function, and a plain projection object fails with unknown projection type: [object Object]. These forms are outside the declared name union. Install d3 alongside @uwdata/vgplot for the examples that import geoMercator."},
	{attributes: ["projectionRotate"], text: "TypeScript and native JavaScript permit a two-angle rotation, but the existing wire schema requires exactly three items. Use three angles in declarative specifications."},
	{attributes: ["projectionClip"], text: "Python defaults to True; JavaScript omitted values remain undefined. False and null disable clipping, while a number requests angular clipping in degrees."},
]
let Attributes = attributes
referenceGroups: [{
	id:    "projection"
	title: "Projection Attributes"
	attributes: [for attribute in Attributes {attribute.name}]
	sections: {js: "js-Projection-Attributes-33", python: "python-Projection-Attributes-47"}
	trailing: "\n### Projection examples\n\n" + strings.Join([for Example in samples {"`\(Example.id)`: " + strings.Join([for Format in ["json", "yaml", "js", "py"] {if Format != "py" {"[\(Format)](/templates/attributes/projection/\(Example.id).\(Format))"}, if Format == "py" {"<a :href=\"withBase('/templates/attributes/projection/\(Example.id).py')\" download>Python</a>"}}], " · ") + ".\n"}], "\n") + "\n" + strings.Join([for Example in nativeSamples {"JavaScript-only [`\(Example.id)`](/templates/attributes/projection/\(Example.id).js).\n"}], "\n")
}]
