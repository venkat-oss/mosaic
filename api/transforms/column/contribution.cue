package column

import "idl.uw.edu/mosaic/api/model"

let FamilyFiles = files
let FamilyNativeChecks = nativeChecks
let FamilyReferenceSections = referenceSections
let FamilySections = sections
let FamilySharedTypeImports = sharedTypeImports

contribution: {
	source:            "./api/transforms/column"
	sharedTypeImports: FamilySharedTypeImports
	native: {definitions: admissionDefinitions, objects: nativeObjects}
	id: "column"

	files:             FamilyFiles
	sections:          FamilySections
	nativeChecks:      FamilyNativeChecks
	referenceSections: FamilyReferenceSections
	symbols: model.#Symbols & {marks: [], attributes: [], encodings: pythonSymbols, legends: []}
	schemas: [{owner: "column", definitions: schemaFragment.definitions}]

	registrations: parserRegistrations
}

contribution: publicAPI: {
	javascript: [for item in javascriptExports {{group: "column", name: item.name, source: item.source}}]
	python: [for api in expressionAPIs if api.python != _|_ {{name: api.python, module: "encodings"}}]
}

contribution: publicAPI: constantExports: [{source: "./generated/column.js", names: [{name: "SQL_KEY", alias: "SQL"}]}]
