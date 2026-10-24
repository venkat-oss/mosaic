package data

import "idl.uw.edu/mosaic/api/model"

let FamilyFiles = files
let FamilyNativeChecks = nativeChecks
let FamilySections = sections

contribution: {
	source: "./api/data"
	native: {definitions: admissionDefinitions, objects: nativeObjects}
	id: "data"

	files:        FamilyFiles
	sections:     FamilySections
	nativeChecks: FamilyNativeChecks
	referenceSections: []
	symbols: model.#Symbols & {marks: [], attributes: [], encodings: [], legends: []}
	schemas: [{owner: "data", definitions: schemaFragment.definitions}]
}

contribution: publicAPI: {
	javascript: [for Name in jsExports.source {{group: "data", name: Name, source: "./plot/data.js"}}]
	python: [for factory in pythonFactories {{name: factory.python.name, module: "data"}}, {name: namedDataFactory.name, module: "data"}, {name: sourceFactory.name, module: "plot"}]
}

contribution: publicAPI: constantExports: [{source: "./generated/data.js", names: [for item in runtimeNames {{name: item.name}}]}]
