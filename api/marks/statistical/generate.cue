package statisticalmarks

import (
	"list"
	familyRender "idl.uw.edu/mosaic/api/marks/render:markrender"
	basic "idl.uw.edu/mosaic/api/marks/basic/model:basicmodel"
)

let Contracts = contracts
let Expressions = typeExpressions
let Files = declarationFiles
let Marks = marks
let Groups = referenceGroups
let Notes = compatibilityNotes
let TemplateFiles = templateFiles
let Starters = [for Example in examples {{id: Example.id, mark: Example.mark, kind: "shared"}}]
projection: familyRender.#MarkFamilyProjection & {
	identity: {slug: "statistical"}
	contracts:          Contracts
	typeExpressions:    Expressions
	baseContracts:      basic.contracts
	baseExpressions:    basic.typeExpressions
	externalReferences: basic.externalReferences
	baseImports: [for File in basic.declarationFiles for Name in File.contracts if ([for Contract in basic.contracts if Contract.name == Name {Contract.exported}])[0] {name: Name, owner: "basic", source: "./\(File.basename).js"}]
	declarationFiles: Files
	marks:            Marks
	referenceGroups:  Groups
	referenceNotes:   Notes
	starters:         Starters
	starterFiles:     TemplateFiles
}
checks:      projection.checks
shapeChecks: projection.shapeChecks
files:       projection.files
sections:    projection.sections
schemaFragment: definitions: {
	for name, definition in projection.schemaFragment.definitions {
		(name): {
			for key, value in definition if key != "required" {(key): value}
			if definition.required != _|_ {required: list.Sort(definition.required, list.Ascending)}
		}
	}
}
pythonSymbols: projection.pythonSymbols
