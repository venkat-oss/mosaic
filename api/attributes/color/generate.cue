package colorattributes

import (
	"strings"
	attributeRender "idl.uw.edu/mosaic/api/attributes/render:attributerender"
	paramFamily "idl.uw.edu/mosaic/api/params"
	valueFamily "idl.uw.edu/mosaic/api/values"
)

let Attributes = attributes
let Expressions = typeExpressions
let Contracts = contracts
let ExternalReferences = externalReferences
projection: attributeRender.#AttributeFamilyProjection & {
	identity: {slug: "color", helperName: "ColorAttributes"}
	attributes:         Attributes
	typeExpressions:    Expressions
	contracts:          Contracts
	externalReferences: ExternalReferences
	nativeReferences: {
		ParamRef: paramFamily.nativeDefinitions.ParamRef
		for Name in ["ColorScaleType", "ContinuousScaleType", "DiscreteScaleType", "Fixed", "Interval", "ColorScheme", "ColorSchemeCase", "Interpolate", "LiteralTimeInterval", "TimeIntervalName"] {(Name): valueFamily.nativeDefinitions[Name]}
	}
	referenceGroups: [
		{id: "color", title: "Color Scale Attributes", attributes: [for A in Attributes if A.name =~ "^color" {A.name}], sections: {js: "js-color-Scale-Attributes-26", python: "python-color-Scale-Attributes-40"}, trailing: "\n### Color examples\n\n" + strings.Join([for Example in attributeExamples {"`\(Example.name)`: " + strings.Join([for Format in ["json", "yaml", "js", "py"] {if Format != "py" {"[\(Format)](/templates/attributes/color/\(Example.name).\(Format))"}, if Format == "py" {"<a :href=\"withBase('/templates/attributes/color/\(Example.name).py')\" download>Python</a>"}}], " · ") + ".\n"}], "\n")},
		{id: "symbol", title: "Symbol Scale Attributes", attributes: [for A in Attributes if A.name =~ "^symbol" {A.name}], sections: {js: "js-color-Scale-Attributes-26", python: "python-color-Scale-Attributes-40"}},
		{id: "opacity", title: "Opacity Scale Attributes", attributes: [for A in Attributes if A.name =~ "^opacity" {A.name}], sections: {js: "js-opacity-Scale-Attributes-27", python: "python-opacity-Scale-Attributes-41"}},
	]
	referenceNotes: [
		for D in knownDefects {{attributes: D.attributes, text: D.description}},
		for H in hostAdapters {{attributes: H.attributes, text: H.description}},
	]
}
checks:            projection.checks
schemaFragment:    projection.schemaFragment
nativeDefinitions: projection.nativeDefinitions
sections:          projection.sections
pythonSymbols:     projection.pythonSymbols
files:             projection.files & templateFiles
