package cartesianattributes

typeExpressions: {
	numberValue: {kind: "primitive", type: "number"}
	stringValue: {kind: "primitive", type: "string"}
	booleanValue: {kind: "primitive", type: "boolean"}
	nullValue: {kind: "primitive", type: "null"}
	anyValue: {kind: "primitive", type: "any"}
	PositionScaleType: {kind: "named", name: "PositionScaleType"}
	Fixed: {kind: "named", name: "Fixed"}
	Interval: {kind: "named", name: "Interval"}
	ParamRef: {kind: "named", name: "ParamRef"}
	LabelArrow: {kind: "named", name: "LabelArrow"}
	top: {kind: "literal", value: "top"}
	right: {kind: "literal", value: "right"}
	bottom: {kind: "literal", value: "bottom"}
	left: {kind: "literal", value: "left"}
	both: {kind: "literal", value: "both"}
	center: {kind: "literal", value: "center"}
	auto: {kind: "literal", value: "auto"}
	up: {kind: "literal", value: "up"}
	down: {kind: "literal", value: "down"}
	none: {kind: "literal", value: "none"}
	literalTrue: {kind: "literal", value: true}
	literalFalse: {kind: "literal", value: false}
	literalNull: {kind: "literal", value: null}
	arrayValue: {kind: "array", items: "anyValue"}
	numberReference: {kind: "union", members: ["numberValue", "ParamRef"]}
	stringReference: {kind: "union", members: ["stringValue", "ParamRef"]}
	booleanReference: {kind: "union", members: ["booleanValue", "ParamRef"]}
	scaleValue: {kind: "union", members: ["PositionScaleType", "nullValue", "ParamRef"]}
	domainValue: {kind: "union", members: ["arrayValue", "Fixed", "ParamRef"]}
	niceValue: {kind: "union", members: ["booleanValue", "numberValue", "Interval", "ParamRef"]}
	xAxisValue: {kind: "union", members: ["top", "bottom", "both", "booleanValue", "nullValue", "ParamRef"]}
	yAxisValue: {kind: "union", members: ["left", "right", "both", "booleanValue", "nullValue", "ParamRef"]}
	ticksValue: {kind: "union", members: ["numberValue", "Interval", "arrayValue", "ParamRef"]}
	nullableString: {kind: "union", members: ["stringValue", "nullValue", "ParamRef"]}
	gridValue: {kind: "union", members: ["booleanValue", "stringValue", "Interval", "arrayValue", "ParamRef"]}
	anchorValue: {kind: "union", members: ["top", "right", "bottom", "left", "center", "ParamRef"]}
	arrowValue: {kind: "union", members: ["LabelArrow", "ParamRef"]}
	labelArrowEnum: {
		kind: "union"
		members: ["auto", "up", "right", "down", "left", "none", "literalTrue", "literalFalse", "literalNull"]
		schemaAdapter: "literal-enum"
	}
}
externalReferences: [
	{name: "PositionScaleType", owner: "values", source: "./PlotTypes.js"},
	{name: "Fixed", owner: "values", source: "./PlotTypes.js"},
	{name: "Interval", owner: "values", source: "./PlotTypes.js"},
	{name: "ParamRef", owner: "params", source: "./Param.js"},
]
contracts: [
	{name: "LabelArrow", description: "Direction of a scale label arrow.", documentationAdapter: "reference-only", wire: true, kind: "alias", expression: "labelArrowEnum"},
	{name: "CartesianAttributes", description: "Cartesian scale and axis attributes.", wire: false, exported: false, kind: "interface", extends: [], properties: [for Attribute in attributes {{name: Attribute.name, description: Attribute.description, required: false, type: Attribute.type}}]},
]
