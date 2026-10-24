package connected

import "idl.uw.edu/mosaic/api/model"

let FamilyFiles = files
let FamilySections = sections

contribution: {
	source:             "./api/marks/connected"
	sharedTypeImports:  projection.sharedTypeImports
	markRuntimeClasses: projection.runtimeClasses
	native: {definitions: projection.admissionDefinitions, objects: projection.nativeObjects}
	id: "connected-marks"

	files:    FamilyFiles
	sections: FamilySections
	nativeChecks: []
	referenceSections: []
	symbols: model.#Symbols & {marks: pythonSymbols, attributes: [], encodings: [], legends: []}
	schemas: [{owner: "connected-marks", definitions: schemaFragment.definitions}]
}
