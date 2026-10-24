package plotattributes

typeExpressions: {
	stringValue: {kind: "primitive", type: "string"}
	numberValue: {kind: "primitive", type: "number"}
	booleanValue: {kind: "primitive", type: "boolean"}
	nullValue: {kind: "primitive", type: "null"}
	parameterReference: {kind: "named", name: "ParamRef"}
	cssStyles: {kind: "named", name: "CSSStyles"}
	marginOptions: {kind: "named", name: "MarginOptions"}
	numberReference: {kind: "union", members: ["numberValue", "parameterReference"]}
	aspectValue: {kind: "union", members: ["numberValue", "booleanValue", "nullValue", "parameterReference"]}
	styleValue: {kind: "union", members: ["stringValue", "cssStyles", "nullValue", "parameterReference"]}
	nullableString: {kind: "union", members: ["stringValue", "nullValue"], schemaAdapter: "primitive-type-array"}
	gridValue: {kind: "union", members: ["booleanValue", "stringValue", "parameterReference"]}
	for Literal in ["top", "right", "bottom", "left", "both", "frame", "sphere"] {
		(Literal): {kind: "literal", value: Literal}
	}
	axisValue: {kind: "union", members: ["top", "right", "bottom", "left", "both", "booleanValue", "nullValue", "parameterReference"]}
	clipValue: {kind: "union", members: ["frame", "sphere", "booleanValue", "nullValue", "parameterReference"]}
}
externalReferences: [
	{name: "ParamRef", owner: "params", source: "./Param.js"},
	{name: "CSSStyles", owner: "values", source: "./CSSStyles.js"},
]
contracts: [{
	name:        "MarginOptions"
	description: "Options for setting individual plot margins."
	wire:        false
	kind:        "interface"
	extends: []
	properties: [for attribute in pythonSides {{name: attribute.side.name, description: attribute.description, required: false, type: attribute.type}}]
}, {
	name:        "PlotContainerAttributes"
	description: "Plot and container attributes."
	wire:        false
	kind:        "interface"
	extends: []
	properties: [for attribute in attributes {{name: attribute.name, description: attribute.description, required: false, type: attribute.type}}]
}]
