package common

import "idl.uw.edu/mosaic/api/model"

let FamilyFiles = files
let FamilyNativeChecks = nativeChecks
let FamilySections = sections

contribution: {
	source: "./api/marks/common"
	native: {definitions: admissionDefinitions, objects: nativeObjects}
	id: "common-marks"

	files:        FamilyFiles
	sections:     FamilySections
	nativeChecks: FamilyNativeChecks
	referenceSections: []
	symbols: model.#Symbols & {marks: [], attributes: [], encodings: [], legends: []}
	schemas: [{owner: "common-marks", definitions: schemaFragment.definitions}]
}

contribution: publicAPI: {
	python: [for factory in pythonFactories {{name: factory.name, module: {mark: "plot", directive: "plot", channels: "encodings"}[factory.name]}}]
}
