package navigationinteractors

import "list"

import interactorRender "idl.uw.edu/mosaic/api/interactors/render:interactorrender"

let Contracts = contracts
let Expressions = typeExpressions
let DeclarationFiles = declarationFiles
let Interactors = interactors
projection: interactorRender.#InteractorFamilyProjection & {
	identity: {slug: "navigation"}
	contracts:        Contracts
	typeExpressions:  Expressions
	declarationFiles: DeclarationFiles
	interactors:      Interactors
	externalReferences: [{name: "ParamRef", owner: "params", source: "api/params/model.cue"}]
}
checks:      projection.checks
shapeChecks: projection.shapeChecks
files:       projection.files & templateFiles
sections: list.Concat([projection.sections, docSections, [{path: "packages/vgplot/vgplot/src/plot/interactors.js", id: "zoom-15", owner: "navigation", text: ""}]])
schemaFragment: projection.schemaFragment
registrations:  projection.registrations
aliases:        projection.aliases
pythonSymbols:  projection.pythonSymbols
runtimeClasses: projection.runtimeClasses
nativeChecks:   projection.nativeChecks
