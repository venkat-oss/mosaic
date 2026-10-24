package legends

import "idl.uw.edu/mosaic/api/model"

let FamilyFiles = files

contribution: {
	source: "./api/legends"
	native: {definitions: nativeDefinitions, objects: nativeObjects}
	id: "legends"

	files: FamilyFiles
	sections: []
	nativeChecks: []
	referenceSections: []
	symbols: model.#Symbols & {
		marks: []
		attributes: []
		encodings: []
		legends: [for api in apis {{key: api.channel, name: api.python, module: "legends"}}]
	}
	schemas: [{owner: "legends", definitions: schemaFragment.definitions}]
}
