package facetattributes

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
	identity: {slug: "facet", helperName: "FacetAttributes"}
	attributes:         Attributes
	typeExpressions:    Expressions
	contracts:          Contracts
	externalReferences: ExternalReferences
	nativeReferences: {
		ParamRef: paramFamily.nativeDefinitions.ParamRef
		for Name in ["Fixed", "Interval", "LiteralTimeInterval", "TimeIntervalName"] {(Name): valueFamily.nativeDefinitions[Name]}
	}
	referenceGroups: [
		{id: "fx", title: "fx Scale Attributes", attributes: [for Attribute in Attributes if Attribute.name =~ "^fx" {Attribute.name}], sections: {js: "js-fx-Scale-Attributes-30", python: "python-fx-Scale-Attributes-44"}, trailing: "\n### Facet examples\n\n" + strings.Join([for Example in samples {"`\(Example.id)`: " + strings.Join([for Format in ["json", "yaml", "js", "py"] {if Format != "py" {"[\(Format)](/templates/attributes/facet/\(Example.id).\(Format))"}, if Format == "py" {"<a :href=\"withBase('/templates/attributes/facet/\(Example.id).py')\" download>Python</a>"}}], " · ") + ".\n"}], "\n")},
		{id: "fy", title: "fy Scale Attributes", attributes: [for Attribute in Attributes if Attribute.name =~ "^fy" {Attribute.name}], sections: {js: "js-fy-Scale-Attributes-31", python: "python-fy-Scale-Attributes-45"}},
		{id: "facet", title: "Facet Attributes", attributes: [for Attribute in Attributes if Attribute.name =~ "^facet" {Attribute.name}], sections: {js: "js-Facet-Attributes-32", python: "python-Facet-Attributes-46"}},
	]
	referenceNotes: [
		{attributes: ["fxTickFormat", "fyTickFormat"], text: "JavaScript formatter callbacks are native execution adapters beyond the string/null/reference wire contract."},
		for Defect in knownDefects {{attributes: [Defect.attribute], text: "**Known limitation**: \(Defect.description)"}},
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
	"examples.cue": "package facetattributeadmission\n\n" + strings.Join([for i, Sample in samples {"sample_\(i): #FacetAttributes & \(json.Marshal({for Key, Value in sampleProjections[Sample.id].attributes if Key != "width" && Key != "height" {(Key): Value}}))"}], "\n") + "\n"
}}]
