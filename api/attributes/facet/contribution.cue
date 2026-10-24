package facetattributes

import "idl.uw.edu/mosaic/api/model"

let FamilyFiles = files
let FamilyNativeChecks = nativeChecks
let FamilySections = sections

contribution: {
	source:            "./api/attributes/facet"
	sharedTypeImports: projection.sharedTypeImports
	native: {definitions: projection.admissionDefinitions, attributes: {for name, item in projection.propertyProjections {(name): item.native}}}
	id: "facet-attributes"

	files:        FamilyFiles
	sections:     FamilySections
	nativeChecks: FamilyNativeChecks
	referenceSections: []
	symbols: model.#Symbols & {marks: [], attributes: pythonSymbols, encodings: [], legends: []}
	schemas: [schemaFragment & {owner: "facet-attributes"}]
}
