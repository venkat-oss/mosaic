package projectionattributes

typeExpressions: {
	numberValue: {kind: "primitive", type: "number"}
	booleanValue: {kind: "primitive", type: "boolean"}
	nullValue: {kind: "primitive", type: "null"}
	frameValue: {kind: "literal", value: "frame"}
	objectValue: kind: "object"
	for Name in ["ProjectionName", "ParamRef"] {
		(Name): {kind: "named", name: Name}
	}
	numberReference: {kind: "union", members: ["numberValue", "ParamRef"]}
	projectionValue: {kind: "union", members: ["ProjectionName", "nullValue", "ParamRef"]}
	domainValue: {kind: "union", members: ["objectValue", "ParamRef"]}
	rotationTuple: {kind: "tuple", elements: [{type: "numberReference", label: "x"}, {type: "numberReference", label: "y"}, {type: "numberReference", label: "z", required: false}], wireArity: "all-elements", schemaAdapter: "positional-items"}
	parallelsTuple: {kind: "tuple", elements: [{type: "numberReference", label: "y1"}, {type: "numberReference", label: "y2"}], schemaAdapter: "positional-items"}
	rotationValue: {kind: "union", members: ["rotationTuple", "ParamRef"]}
	parallelsValue: {kind: "union", members: ["parallelsTuple", "ParamRef"]}
	clipValue: {kind: "union", members: ["booleanValue", "numberValue", "frameValue", "nullValue", "ParamRef"]}
}
externalReferences: [
	{name: "ProjectionName", owner: "values", source: "./PlotTypes.js"},
	{name: "ParamRef", owner: "params", source: "./Param.js"},
]
contracts: [{
	name:        "ProjectionAttributes"
	description: "Geographic projection attributes."
	wire:        false
	kind:        "interface"
	extends: []
	properties: [for attribute in attributes {{name: attribute.name, description: attribute.description, required: false, type: attribute.type}}]
}]
