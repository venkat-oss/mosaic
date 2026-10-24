package facetattributes

typeExpressions: {
	numberReference: {kind: "union", members: ["numberValue", "ParamRef"]}
	numberValue: {kind: "primitive", type: "number"}
	ParamRef: {kind: "named", name: "ParamRef"}
	gridValue: {kind: "union", members: ["booleanValue", "stringValue", "Interval", "arrayValue", "ParamRef"]}
	booleanValue: {kind: "primitive", type: "boolean"}
	stringValue: {kind: "primitive", type: "string"}
	Interval: {kind: "named", name: "Interval"}
	arrayValue: {kind: "array", items: "anyValue"}
	anyValue: {kind: "primitive", type: "any"}
	nullableString: {kind: "union", members: ["stringValue", "nullValue", "ParamRef"]}
	nullValue: {kind: "primitive", type: "null"}
	domainValue: {kind: "union", members: ["arrayValue", "Fixed", "ParamRef"]}
	Fixed: {kind: "named", name: "Fixed"}
	booleanReference: {kind: "union", members: ["booleanValue", "ParamRef"]}
	xAxisValue: {kind: "union", members: ["top", "bottom", "both", "booleanValue", "nullValue", "ParamRef"]}
	top: {kind: "literal", value: "top"}
	bottom: {kind: "literal", value: "bottom"}
	both: {kind: "literal", value: "both"}
	ticksValue: {kind: "union", members: ["numberValue", "Interval", "arrayValue", "ParamRef"]}
	anchorValue: {kind: "union", members: ["top", "right", "bottom", "left", "center", "ParamRef"]}
	right: {kind: "literal", value: "right"}
	left: {kind: "literal", value: "left"}
	center: {kind: "literal", value: "center"}
	stringReference: {kind: "union", members: ["stringValue", "ParamRef"]}
	yAxisValue: {kind: "union", members: ["left", "right", "both", "booleanValue", "nullValue", "ParamRef"]}
}
externalReferences: [{name: "Fixed", owner: "values", source: "./PlotTypes.js"}, {name: "Interval", owner: "values", source: "./PlotTypes.js"}, {name: "ParamRef", owner: "params", source: "./Param.js"}]
contracts: [{name: "FacetAttributes", description: "Facet scale and axis attributes.", wire: false, exported: false, kind: "interface", extends: [], properties: [for Attribute in attributes {{name: Attribute.name, description: Attribute.description, required: false, type: Attribute.type}}]}]
