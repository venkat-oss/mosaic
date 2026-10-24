package cartesianattributes

import (
	"encoding/json"
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
	identity: {slug: "cartesian", helperName: "CartesianAttributes"}
	attributes:         Attributes
	typeExpressions:    Expressions
	contracts:          Contracts
	externalReferences: ExternalReferences
	nativeReferences: {
		ParamRef: paramFamily.nativeDefinitions.ParamRef
		for Name in ["PositionScaleType", "Fixed", "Interval", "LiteralTimeInterval", "TimeIntervalName"] {(Name): valueFamily.nativeDefinitions[Name]}
	}
	aliasSections: [{name: "LabelArrow", id: "LabelArrow-3"}]
	referenceGroups: [
		{id: "x", title: "x Scale Attributes", attributes: [for A in Attributes if A.name =~ "^x[A-Z]" {A.name}], sections: {js: "js-x-Scale-Attributes-24", python: "python-x-Scale-Attributes-38"}, trailing: "\n### Cartesian examples\n\n" + strings.Join([for Example in samples {"`\(Example.id)`: " + strings.Join([for Format in ["json", "yaml", "js", "py"] {if Format != "py" {"[\(Format)](/templates/attributes/cartesian/\(Example.id).\(Format))"}, if Format == "py" {"<a :href=\"withBase('/templates/attributes/cartesian/\(Example.id).py')\" download>Python</a>"}}], " · ") + ".\n"}], "\n")},
		{id: "xy", title: "Paired Scale Domains", attributes: ["xyDomain"], sections: {js: "js-x-Scale-Attributes-24", python: "python-x-Scale-Attributes-38"}},
		{id: "y", title: "y Scale Attributes", attributes: [for A in Attributes if A.name =~ "^y[A-Z]" {A.name}], sections: {js: "js-y-Scale-Attributes-25", python: "python-y-Scale-Attributes-39"}},
	]
	referenceNotes: [
		for Defect in knownDefects {{attributes: [Defect.attribute], text: "**Known limitation**: \(Defect.description)"}},
		{attributes: ["xTickFormat", "yTickFormat"], text: "JavaScript formatter functions are native execution adapters beyond the string/null/reference wire contract."},
		{attributes: ["xGrid", "yGrid"], text: "Native JavaScript and Python authoring can retain null, and JavaScript can execute numeric interval counts. The current wire Interval default is a string, so those native variants are not presented as JSON/YAML starters."},
	]
}
checks: projection.checks
files: {for Path, Content in projection.files {(Path): Content}, for Path, Content in templateFiles {(Path): Content}}
sections:          projection.sections
schemaFragment:    projection.schemaFragment
nativeDefinitions: projection.nativeDefinitions
pythonSymbols:     projection.pythonSymbols

nativeChecks: [{files: {
	"contracts.cue": projection.nativeSource
	"examples.cue": "package cartesianattributeadmission\n\n" + strings.Join([for i, Sample in samples {"sample_\(i): #CartesianAttributes & \(json.Marshal({for Key, Value in sampleProjections[Sample.id].attributes if Key != "width" && Key != "height" {(Key): Value}}))"}], "\n") + "\n"
}}]
