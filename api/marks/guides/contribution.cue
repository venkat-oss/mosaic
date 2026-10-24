package guidemarks

import "idl.uw.edu/mosaic/api/model"

let FamilyFiles = files
let FamilySections = sections

contribution: {
	source:             "./api/marks/guides"
	sharedTypeImports:  projection.sharedTypeImports
	markRuntimeClasses: projection.runtimeClasses
	native: {definitions: projection.admissionDefinitions, objects: projection.nativeObjects}
	id: "guide-marks"

	files:    FamilyFiles
	sections: FamilySections
	nativeChecks: []
	referenceSections: []
	symbols: model.#Symbols & {marks: pythonSymbols, attributes: [], encodings: [], legends: []}
	schemas: [{owner: "guide-marks", definitions: schemaFragment.definitions}]
}
