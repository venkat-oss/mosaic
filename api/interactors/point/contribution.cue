package pointinteractors

import "idl.uw.edu/mosaic/api/model"

let FamilyFiles = files
let FamilyNativeChecks = nativeChecks
let FamilySections = sections

contribution: {
	source: "./api/interactors/point"
	native: {definitions: projection.admissionDefinitions, objects: projection.nativeObjects}
	id:           "point-interactors"
	files:        FamilyFiles
	sections:     FamilySections
	nativeChecks: FamilyNativeChecks
	referenceSections: []
	symbols: model.#Symbols & {marks: [], attributes: [], encodings: [], legends: []}
	schemas: [{owner: "point-interactors", definitions: schemaFragment.definitions}]
	interactorRegistrations:  registrations
	interactorAliases:        aliases
	pythonInteractors:        pythonSymbols
	interactorRuntimeClasses: runtimeClasses
}
