package navigationinteractors

import "idl.uw.edu/mosaic/api/model"

let FamilyFiles = files
let FamilyNativeChecks = nativeChecks
let FamilySections = sections

contribution: {
	source: "./api/interactors/navigation"
	native: {definitions: projection.admissionDefinitions, objects: projection.nativeObjects}
	id:           "navigation-interactors"
	files:        FamilyFiles
	sections:     FamilySections
	nativeChecks: FamilyNativeChecks
	referenceSections: []
	symbols: model.#Symbols & {marks: [], attributes: [], encodings: [], legends: []}
	schemas: [{owner: "navigation-interactors", definitions: schemaFragment.definitions}]
	interactorRegistrations:  registrations
	interactorAliases:        aliases
	pythonInteractors:        pythonSymbols
	interactorRuntimeClasses: runtimeClasses
}
