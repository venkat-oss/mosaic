package density1d

import "idl.uw.edu/mosaic/api/model"

let FamilyFiles = files
let FamilySections = sections

contribution: {
	source:             "./api/marks/density1d"
	sharedTypeImports:  projection.sharedTypeImports
	markRuntimeClasses: projection.runtimeClasses
	native: {definitions: projection.admissionDefinitions, objects: projection.nativeObjects}
	id: "density1d-marks"

	files:    FamilyFiles
	sections: FamilySections
	nativeChecks: []
	referenceSections: []
	symbols: model.#Symbols & {marks: pythonSymbols, attributes: [], encodings: [], legends: []}
	schemas: [{owner: "density1d-marks", definitions: schemaFragment.definitions}]
}
