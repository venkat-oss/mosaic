package sizeattributes

import (
	"strings"
)

referenceNotes: [
	{attributes: ["rClamp", "lengthClamp"], text: "The declared value is unrestricted. Python requires an explicit argument; it does not infer a default from the clamp option's purpose."},
	for defect in knownDefects {
		{attributes: [defect.attribute], text: "**Known limitation**: " + defect.description + " The JavaScript error is " + defect.error + "."}
	},
	{attributes: ["rDomain", "lengthDomain"], text: "Fixed domains are inferred from actual scale channels once and cached across later mark updates. Scalar radius/length constants bypass scale inference; field or array channels establish a scale."},
]
let Attributes = attributes
referenceGroups: [
	for group in [{id: "r", title: "Radius Scale Attributes", js: "js-r-Scale-Attributes-28", python: "python-r-Scale-Attributes-42"}, {id: "length", title: "Length Scale Attributes", js: "js-length-Scale-Attributes-29", python: "python-length-Scale-Attributes-43"}] {
		{
			id:    group.id
			title: group.title
			attributes: [for attribute in Attributes if strings.HasPrefix(attribute.name, group.id) {attribute.name}]
			sections: {js: group.js, python: group.python}
			trailing: "\n### Size examples\n\n" + strings.Join([for Example in samples {"`\(Example.id)`: " + strings.Join([for Format in ["json", "yaml", "js", "py"] {if Format != "py" {"[\(Format)](/templates/attributes/size/\(Example.id).\(Format))"}, if Format == "py" {"<a :href=\"withBase('/templates/attributes/size/\(Example.id).py')\" download>Python</a>"}}], " · ") + ".\n"}], "\n")
		}
	},
]
