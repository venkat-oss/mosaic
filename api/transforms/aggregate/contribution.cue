package aggregate

import "idl.uw.edu/mosaic/api/model"

let FamilyFiles = files
let FamilyNativeChecks = nativeChecks
let FamilyReferenceSections = referenceSections
let FamilySections = sections
let FamilySharedTypeImports = sharedTypeImports

contribution: {
	source:            "./api/transforms/aggregate"
	sharedTypeImports: FamilySharedTypeImports
	native: {definitions: admissionDefinitions, objects: nativeObjects}
	id: "aggregate"

	files:             FamilyFiles
	sections:          FamilySections
	nativeChecks:      FamilyNativeChecks
	referenceSections: FamilyReferenceSections
	symbols: model.#Symbols & {marks: [], attributes: [], encodings: pythonSymbols, legends: []}
	schemas: [{owner: "aggregate", definitions: schemaFragment.definitions}]

	registrations: parserRegistrations
}

contribution: publicAPI: {
	javascript: [for item in javascriptExports {{group: "aggregate", name: item.name, source: item.source}}]
}
