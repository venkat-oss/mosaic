package guidemarks

import (
	"list"
	familyRender "idl.uw.edu/mosaic/api/marks/render:markrender"
	basic "idl.uw.edu/mosaic/api/marks/basic/model:basicmodel"
	annotation "idl.uw.edu/mosaic/api/marks/annotation/model:annotationmodel"
)

let Contracts = contracts
let Support = supportContracts
let Expressions = typeExpressions
let Files = declarationFiles
let Marks = marks
let Groups = referenceGroups
let Notes = compatibilityNotes
let StarterFiles = templateFiles
let Starters = [for Example in examples {{id: Example.id, mark: Example.mark, kind: "shared"}}, for Example in nativeExamples {{id: Example.id, mark: Example.mark, kind: "javascript"}}]
projection: familyRender.#MarkFamilyProjection & {
	identity: {slug: "guides"}
	contracts:        Contracts
	supportContracts: Support
	typeExpressions:  Expressions
	baseContracts: list.Concat([basic.contracts, annotation.contracts, annotation.supportContracts])
	baseExpressions:    basic.typeExpressions & annotation.typeExpressions
	externalReferences: basic.externalReferences
	baseImports: [
		for File in basic.declarationFiles for Name in File.contracts if ([for Contract in basic.contracts if Contract.name == Name {Contract.exported}])[0] {name: Name, owner: "basic", source: "./\(File.basename).js"},
		for File in annotation.declarationFiles for Name in File.contracts if ([for Contract in list.Concat([annotation.contracts, annotation.supportContracts]) if Contract.name == Name {Contract.exported}])[0] {name: Name, owner: "annotation", source: "./\(File.basename).js"},
	]
	declarationFiles: Files
	marks:            Marks
	referenceGroups:  Groups
	referenceNotes:   Notes
	starters:         Starters
	starterFiles:     StarterFiles
}
checks:         projection.checks
shapeChecks:    projection.shapeChecks
files:          projection.files
sections:       projection.sections
schemaFragment: projection.schemaFragment
pythonSymbols:  projection.pythonSymbols
