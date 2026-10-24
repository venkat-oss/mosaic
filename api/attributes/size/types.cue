package sizeattributes

typeExpressions: {
	anyValue: {kind: "primitive", type: "any"}
	numberValue: {kind: "primitive", type: "number"}
	booleanValue: {kind: "primitive", type: "boolean"}
	stringValue: {kind: "primitive", type: "string"}
	nullValue: {kind: "primitive", type: "null"}
	for Name in ["ContinuousScaleType", "Fixed", "Interval", "ParamRef"] {
		(Name): {kind: "named", name: Name}
	}
	arrayValue: {kind: "array", items: "anyValue"}
	numberReference: {kind: "union", members: ["numberValue", "ParamRef"]}
	booleanReference: {kind: "union", members: ["booleanValue", "ParamRef"]}
	scaleValue: {kind: "union", members: ["ContinuousScaleType", "nullValue", "ParamRef"]}
	domainValue: {kind: "union", members: ["arrayValue", "Fixed", "ParamRef"]}
	niceValue: {kind: "union", members: ["booleanValue", "numberValue", "Interval", "ParamRef"]}
	labelValue: {kind: "union", members: ["stringValue", "nullValue", "ParamRef"]}
}
externalReferences: [
	for Name in ["ContinuousScaleType", "Fixed", "Interval"] {{name: Name, owner: "values", source: "./PlotTypes.js"}},
	{name: "ParamRef", owner: "params", source: "./Param.js"},
]
contracts: [{
	name:        "SizeAttributes"
	description: "Radius and length scale attributes."
	wire:        false
	kind:        "interface"
	extends: []
	properties: [for attribute in attributes {{name: attribute.name, description: attribute.description, required: false, type: attribute.type}}]
}]
