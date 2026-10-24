package brushinteractors

import "idl.uw.edu/mosaic/api/model"

let FamilyFiles = files
let FamilyNativeChecks = nativeChecks
let FamilySections = sections

contribution: {
	source: "./api/interactors/brush"
	native: {definitions: projection.admissionDefinitions, objects: projection.nativeObjects}
	id:           "brush-interactors"
	files:        FamilyFiles
	sections:     FamilySections
	nativeChecks: FamilyNativeChecks
	referenceSections: []
	symbols: model.#Symbols & {marks: [], attributes: [], encodings: [], legends: []}
	schemas: [{owner: "brush-interactors", definitions: schemaFragment.definitions}]
	interactorRegistrations:  registrations
	interactorAliases:        aliases
	pythonInteractors:        pythonSymbols
	interactorRuntimeClasses: runtimeClasses
}
