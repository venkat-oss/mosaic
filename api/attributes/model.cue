package attributes

import "idl.uw.edu/mosaic/api/model"

#Attribute: {
	name!:        model.#Name
	type!:        model.#Name
	description!: string & !=""
	tsSection!:   string & !=""
	jsSection!:   string & !=""
	python!: {name!: model.#Name, default!: "required" | "true", kind!: "value" | "margins"}
	route!: {kind: "mapped", path!: string & !="", order!: int & >=0} | {kind: "absent" | "wrapper-only"}
	side?: {name!: model.#Name, jsOrder!: int & >=0, pythonOrder!: int & >=0}

	jsKind!: "simple" | "name" | "margin" | "margins" | "paired"
	targets?: [model.#Name, model.#Name]
	if jsKind == "paired" {
		targets!: [model.#Name, model.#Name]
		_targetsDistinct: true & (targets[0] != targets[1])
	}
	if jsKind != "paired" {targets?: _|_}
}
