package basicinputs

import "idl.uw.edu/mosaic/api/model"

let FamilyFiles = files
let FamilyNativeChecks = nativeChecks
let FamilySections = sections
let FamilySharedTypeImports = sharedTypeImports

contribution: {
	source:            "./api/inputs/basic"
	sharedTypeImports: FamilySharedTypeImports
	native: {definitions: admissionDefinitions, objects: nativeObjects}
	id: "basic-inputs"

	files:        FamilyFiles
	sections:     FamilySections
	nativeChecks: FamilyNativeChecks
	referenceSections: []
	symbols: model.#Symbols & {marks: [], attributes: [], encodings: [], legends: []}
	schemas: [{owner: "basic-inputs", definitions: schemaFragment.definitions}]
}

contribution: publicAPI: {
	javascript: [for Name in jsExports {{group: "inputs", name: Name, source: "./inputs.js"}}]
	inputNames: parserInputs
	python: [for factory in pythonFactories {{name: factory.name, module: "plot"}}, for _, helper in pythonHelpers {{name: helper.name, module: "plot"}}]
}
