package values

import "idl.uw.edu/mosaic/api/model"

let FamilyFiles = files
let FamilyNativeChecks = nativeChecks
let FamilySections = sections

contribution: {
	source: "./api/values"
	native: {definitions: nativeDefinitions}
	id: "values"

	files:        FamilyFiles
	sections:     FamilySections
	nativeChecks: FamilyNativeChecks
	referenceSections: []
	symbols: model.#Symbols & {marks: [], attributes: [], encodings: [], legends: []}
	schemas: [{owner: "values", definitions: schemaFragment.definitions}]
}
