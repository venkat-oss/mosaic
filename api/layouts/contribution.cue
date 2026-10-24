package layouts

import "idl.uw.edu/mosaic/api/model"

let FamilyFiles = files
let FamilyNativeChecks = nativeChecks
let FamilySections = sections

contribution: {
	source: "./api/layouts"
	native: {definitions: admissionDefinitions, objects: nativeObjects}
	id: "layouts"

	files:        FamilyFiles
	sections:     FamilySections
	nativeChecks: FamilyNativeChecks
	referenceSections: []
	symbols: model.#Symbols & {marks: [], attributes: [], encodings: [], legends: []}
	schemas: [{owner: "layouts", definitions: schemaFragment.definitions}]
}

contribution: publicAPI: {
	javascript: [for Name in jsExports.concat {{group: "concat", name: Name, source: "./layout/concat.js"}}, for Name in jsExports.space {{group: "space", name: Name, source: "./layout/space.js"}}]
	python: [for layout in layouts {{name: layout.name, module: "plot"}}]
	pythonViewKeys: [for layout in layouts {layout.name}]
}

contribution: publicAPI: constantExports: [{source: "./generated/layouts.js", names: [for layout in layouts {{name: layout.constant}}]}]
