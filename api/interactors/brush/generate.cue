package brushinteractors

import "list"

import interactorRender "idl.uw.edu/mosaic/api/interactors/render:interactorrender"

let Contracts = contracts
let Expressions = typeExpressions
let DeclarationFiles = declarationFiles
let Interactors = interactors
optionHelpers: [...interactorRender.#PythonOptionHelper] & [{name: "brush", contract: "BrushStyles", policy: "camelize-omit-none"}, {name: "sort", policy: "omit-none"}]
let Helpers = optionHelpers
projection: interactorRender.#InteractorFamilyProjection & {
	identity: {slug: "brush"}
	contracts:        Contracts
	typeExpressions:  Expressions
	declarationFiles: DeclarationFiles
	interactors:      Interactors
	optionHelpers:    Helpers
	externalReferences: [{name: "ParamRef", owner: "params", source: "api/params/model.cue"}]
}
checks:      projection.checks
shapeChecks: projection.shapeChecks
files:       projection.files & templateFiles
sections: list.Concat([projection.sections, docSections])
schemaFragment: projection.schemaFragment
registrations:  projection.registrations
aliases:        projection.aliases
pythonSymbols:  projection.pythonSymbols
runtimeClasses: projection.runtimeClasses
nativeChecks:   projection.nativeChecks

checks:

	checks: references: referenceChecks
