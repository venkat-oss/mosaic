package plotattributes

import "idl.uw.edu/mosaic/api/model"

let FamilyFiles = files
let FamilyNativeChecks = nativeChecks
let FamilySections = sections
let FamilySharedTypeImports = sharedTypeImports

contribution: {
	source:            "./api/attributes/plot"
	sharedTypeImports: FamilySharedTypeImports
	native: {definitions: admissionDefinitions, attributes: {for name, item in propertyProjections {(name): item.native}}}
	id: "plot-attributes"

	files:        FamilyFiles
	sections:     FamilySections
	nativeChecks: FamilyNativeChecks
	referenceSections: []
	symbols: model.#Symbols & {marks: [], attributes: pythonSymbols, encodings: [], legends: []}
	schemas: [schemaFragment & {owner: "plot-attributes"}]
}

contribution: publicAPI: {
	python: [for attribute in attributes if attribute.python.kind == "margins" {{name: attribute.python.name, module: "plot"}}]
}
