package statisticalmarks

import "idl.uw.edu/mosaic/api/model"

let FamilyFiles = files
let FamilySections = sections

contribution: {
	source:             "./api/marks/statistical"
	sharedTypeImports:  projection.sharedTypeImports
	markRuntimeClasses: projection.runtimeClasses
	native: {definitions: projection.admissionDefinitions, objects: projection.nativeObjects}
	id: "statistical-marks"

	files:    FamilyFiles
	sections: FamilySections
	nativeChecks: []
	referenceSections: []
	symbols: model.#Symbols & {marks: pythonSymbols, attributes: [], encodings: [], legends: []}
	schemas: [{owner: "statistical-marks", definitions: schemaFragment.definitions}]
}
