package window

import "idl.uw.edu/mosaic/api/model"

let FamilyFiles = files
let FamilyNativeChecks = nativeChecks
let FamilyReferenceSections = referenceSections
let FamilySections = sections
let FamilySharedTypeImports = sharedTypeImports

contribution: {
	source:            "./api/transforms/window"
	sharedTypeImports: FamilySharedTypeImports
	native: {definitions: admissionDefinitions, objects: nativeObjects}
	id: "window"

	files:             FamilyFiles
	sections:          FamilySections
	nativeChecks:      FamilyNativeChecks
	referenceSections: FamilyReferenceSections
	symbols: model.#Symbols & {marks: [], attributes: [], encodings: pythonSymbols, legends: []}
	schemas: [{owner: "window", definitions: schemaFragment.definitions}]

	registrations: parserRegistrations
}

contribution: publicAPI: {
	javascript: [for item in javascriptExports {{group: "window", name: item.name, source: item.source}}]
}
