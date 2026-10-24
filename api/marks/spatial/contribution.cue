package spatialmarks

import "idl.uw.edu/mosaic/api/model"

let FamilyFiles = files
let FamilySections = sections

contribution: {
	source:             "./api/marks/spatial"
	sharedTypeImports:  projection.sharedTypeImports
	markRuntimeClasses: projection.runtimeClasses
	native: {definitions: projection.admissionDefinitions, objects: projection.nativeObjects}
	id: "spatial-marks"

	files:    FamilyFiles
	sections: FamilySections
	nativeChecks: []
	referenceSections: []
	symbols: model.#Symbols & {marks: pythonSymbols, attributes: [], encodings: [], legends: []}
	schemas: [{owner: "spatial-marks", definitions: schemaFragment.definitions}]
}
