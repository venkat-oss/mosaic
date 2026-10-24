package spatialmarks

import familyRender "idl.uw.edu/mosaic/api/marks/render:markrender"

let Contracts = contracts
let Expressions = typeExpressions
let External = externalReferences
let DeclarationFiles = declarationFiles
let Marks = marks
let Groups = referenceGroups
let Notes = compatibilityNotes
let StarterFiles = templateFiles
let Starters = [for Example in examples {{id: Example.id, mark: Example.mark, kind: "shared"}}, for Example in nativeExamples {{id: Example.id, mark: Example.mark, kind: "javascript"}}]
projection: familyRender.#MarkFamilyProjection & {
	identity: {slug: "spatial"}
	contracts:          Contracts
	typeExpressions:    Expressions
	externalReferences: External
	declarationFiles:   DeclarationFiles
	marks:              Marks
	referenceGroups:    Groups
	referenceNotes:     Notes
	starters:           Starters
	starterFiles:       StarterFiles
}
checks:         projection.checks
shapeChecks:    projection.shapeChecks
files:          projection.files
sections:       projection.sections
schemaFragment: projection.schemaFragment
pythonSymbols:  projection.pythonSymbols
