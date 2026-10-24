package tableinput

import "idl.uw.edu/mosaic/api/model"

let FamilyFiles = files
let FamilyNativeChecks = nativeChecks
let FamilySections = sections
let FamilySharedTypeImports = sharedTypeImports

contribution: {
	source:            "./api/inputs/table"
	sharedTypeImports: FamilySharedTypeImports
	native: {definitions: admissionDefinitions, objects: nativeObjects}
	id: "table-input"

	files:        FamilyFiles
	sections:     FamilySections
	nativeChecks: FamilyNativeChecks
	referenceSections: []
	symbols: model.#Symbols & {marks: [], attributes: [], encodings: [], legends: []}
	schemas: [{owner: "table-input", definitions: schemaFragment.definitions}]
}

contribution: publicAPI: {
	javascript: [for Name in jsExports {{group: "inputs", name: Name, source: "./inputs.js"}}]
	inputNames: [api.name]
	python: [{name: pythonFactory.name, module: "plot"}]
}
