package params

import "idl.uw.edu/mosaic/api/model"

let FamilyFiles = files
let FamilyNativeChecks = nativeChecks
let FamilySections = sections

contribution: {
	source: "./api/params"
	native: {definitions: admissionDefinitions, objects: nativeObjects}
	id: "params"

	files:        FamilyFiles
	sections:     FamilySections
	nativeChecks: FamilyNativeChecks
	referenceSections: []
	symbols: model.#Symbols & {marks: [], attributes: [], encodings: [], legends: []}
	schemas: [{owner: "params", definitions: schemaFragment.definitions}]
}

contribution: publicAPI: {
	javascript: [for Name in coreExports {{group: "core", name: Name, source: "@uwdata/mosaic-core"}}]
	python: [{name: pythonFactory.name, module: "params"}, {name: pythonSelectionNamespace.name, module: "params"}]
}

contribution: publicAPI: constantExports: [{source: "./generated/params.js", names: [for item in runtimeNames {{name: item.name}}]}]
