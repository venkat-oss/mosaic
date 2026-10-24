package projectionattributes

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
let ReferenceGroups = referenceGroups
let ReferenceNotes = referenceNotes
projection: attributeRender.#AttributeFamilyProjection & {
	identity: {slug: "projection", helperName: "ProjectionAttributes"}
	attributes:         Attributes
	typeExpressions:    Expressions
	contracts:          Contracts
	externalReferences: ExternalReferences
	nativeReferences: {ParamRef: paramFamily.nativeDefinitions.ParamRef, ProjectionName: valueFamily.nativeDefinitions.ProjectionName}
	referenceGroups: ReferenceGroups
	referenceNotes:  ReferenceNotes
}
shapeChecks:       projection.checks
schemaFragment:    projection.schemaFragment
nativeDefinitions: projection.nativeDefinitions
sections:          projection.sections
files:             projection.files & templateFiles
nativeChecks: [{files: {
	"contracts.cue": projection.nativeSource
	"examples.cue": "package projectionattributeadmission\n\n" + strings.Join([for sample in samples {"\(json.Marshal(sample.id)): #ProjectionAttributes & \(json.Marshal({for Key, Value in sampleProjections[sample.id].attributes if Key != "width" && Key != "height" {(Key): Value}}))\n"}], "\n")
}}]

pythonSymbols: projection.pythonSymbols
