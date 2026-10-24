package basicmarks

import (
	canonical "idl.uw.edu/mosaic/api/marks/basic/model:basicmodel"
	familyRender "idl.uw.edu/mosaic/api/marks/render:markrender"
)

contracts:          canonical.contracts
typeExpressions:    canonical.typeExpressions
externalReferences: canonical.externalReferences
declarationFiles:   canonical.declarationFiles
marks:              canonical.marks
referenceGroups:    canonical.referenceGroups
contractIndex:      canonical.contractIndex
modelChecks:        canonical.modelChecks
modelAdmission:     canonical

let Contracts = contracts
let Expressions = typeExpressions
let External = externalReferences
let DeclarationFiles = declarationFiles
let Marks = marks
let Groups = referenceGroups
let StarterFiles = templateFiles
let Notes = compatibilityNotes
let Starters = [for Example in examples {{id: Example.id, mark: Example.mark, kind: "shared"}}, for Example in nativeExamples {{id: Example.id, mark: Example.mark, kind: "javascript"}}]
projection: familyRender.#MarkFamilyProjection & {
	identity: {slug: "basic"}
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
