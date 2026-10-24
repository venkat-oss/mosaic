package colorattributes

typeExpressions: {
	anyValue: {kind: "primitive", type: "any"}
	numberValue: {kind: "primitive", type: "number"}
	booleanValue: {kind: "primitive", type: "boolean"}
	stringValue: {kind: "primitive", type: "string"}
	nullValue: {kind: "primitive", type: "null"}
	ColorScaleType: {kind: "named", name: "ColorScaleType"}
	ContinuousScaleType: {kind: "named", name: "ContinuousScaleType"}
	DiscreteScaleType: {kind: "named", name: "DiscreteScaleType"}
	Fixed: {kind: "named", name: "Fixed"}
	Interval: {kind: "named", name: "Interval"}
	ColorScheme: {kind: "named", name: "ColorScheme"}
	Interpolate: {kind: "named", name: "Interpolate"}
	ParamRef: {kind: "named", name: "ParamRef"}
	arrayValue: {kind: "array", items: "anyValue"}
	numberReference: {kind: "union", members: ["numberValue", "ParamRef"]}
	booleanReference: {kind: "union", members: ["booleanValue", "ParamRef"]}
	colorScaleValue: {kind: "union", members: ["ColorScaleType", "nullValue", "ParamRef"]}
	opacityScaleValue: {kind: "union", members: ["ContinuousScaleType", "nullValue", "ParamRef"]}
	symbolScaleValue: {kind: "union", members: ["DiscreteScaleType", "nullValue", "ParamRef"]}
	domainValue: {kind: "union", members: ["arrayValue", "Fixed", "ParamRef"]}
	niceValue: {kind: "union", members: ["booleanValue", "numberValue", "Interval", "ParamRef"]}
	schemeValue: {kind: "union", members: ["ColorScheme", "ParamRef"]}
	interpolateValue: {kind: "union", members: ["Interpolate", "ParamRef"]}
	pivotValue: {kind: "union", members: ["anyValue", "ParamRef"]}
	labelValue: {kind: "union", members: ["stringValue", "nullValue", "ParamRef"]}
}
externalReferences: [
	{name: "ColorScaleType", owner: "values", source: "./PlotTypes.js"},
	{name: "ContinuousScaleType", owner: "values", source: "./PlotTypes.js"},
	{name: "DiscreteScaleType", owner: "values", source: "./PlotTypes.js"},
	{name: "Fixed", owner: "values", source: "./PlotTypes.js"},
	{name: "Interval", owner: "values", source: "./PlotTypes.js"},
	{name: "ColorScheme", owner: "values", source: "./PlotTypes.js"},
	{name: "Interpolate", owner: "values", source: "./PlotTypes.js"},
	{name: "ParamRef", owner: "params", source: "./Param.js"},
]
contracts: [{
	name:        "ColorAttributes"
	description: "Color, opacity and symbol scale attributes."
	wire:        false
	kind:        "interface"
	extends: []
	properties: [for A in attributes {{name: A.name, description: A.description, required: false, type: A.type}}]
}]
