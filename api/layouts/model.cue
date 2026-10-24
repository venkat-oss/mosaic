package layouts

import (
	"list"
	"idl.uw.edu/mosaic/api/model"
)

#Layout: {
	name!:                model.#Name
	type!:                model.#Name
	constant!:            model.#Name
	description!:         string & !=""
	propertyDescription!: string & !=""
	parserOrder!:         int & >=0 & <4
	codegenOrder!:        int & >=0 & <4
	docOrder!:            int & >=0 & <4
	pythonModule:         "vgplot.plot"
} & ({
	kind:          "concat"
	direction!:    "horizontal" | "vertical"
	jsFlatten:     1
	pythonFlatten: 0
} | {
	kind:               "space"
	dimension!:         "width" | "height"
	jsDefault:          10
	pythonArgumentType: "int | str"
})

layouts: [...#Layout] & [
	{name: "hconcat", type: "HConcat", constant: "HCONCAT", kind: "concat", direction: "horizontal", parserOrder: 0, codegenOrder: 1, docOrder: 1, description: "An hconcat component.", propertyDescription: "Horizontally concatenate components in a row layout."},
	{name: "vconcat", type: "VConcat", constant: "VCONCAT", kind: "concat", direction: "vertical", parserOrder: 1, codegenOrder: 0, docOrder: 0, description: "A vconcat component.", propertyDescription: "Vertically concatenate components in a column layout."},
	{name: "hspace", type: "HSpace", constant: "HSPACE", kind: "space", dimension: "width", parserOrder: 2, codegenOrder: 3, docOrder: 3, description: "An hspace component.", propertyDescription: "Horizontal space to place between components.\nNumber values indicate screen pixels.\nString values may use CSS units (em, pt, px, etc)."},
	{name: "vspace", type: "VSpace", constant: "VSPACE", kind: "space", dimension: "height", parserOrder: 3, codegenOrder: 2, docOrder: 2, description: "A vspace component.", propertyDescription: "Vertical space to place between components.\nNumber values indicate screen pixels.\nString values may use CSS units (em, pt, px, etc)."},
]
layoutIndex: {for layout in layouts {(layout.name): layout}}
parserLayouts: [for position in list.Range(0, len(layouts), 1) for layout in layouts if layout.parserOrder == position {layout}]
codegenLayouts: [for position in list.Range(0, len(layouts), 1) for layout in layouts if layout.codegenOrder == position {layout}]
docLayouts: [for position in list.Range(0, len(layouts), 1) for layout in layouts if layout.docOrder == position {layout}]
externalReferences: [{name: "Component", owner: "spec", source: "./Spec.js"}]
typeExpressions: {
	component: {kind: "named", name: "Component"}
	components: {kind: "array", items: "component"}
	spacingNumber: {kind: "primitive", type: "number"}
	spacingString: {kind: "primitive", type: "string"}
	spacing: {kind: "union", members: ["spacingNumber", "spacingString"], schemaAdapter: "primitive-type-array"}
}
contracts: [for layout in layouts {
	name:        layout.type
	description: layout.description
	wire:        true
	kind:        "interface"
	extends: []
	properties: [{
		name:        layout.name
		description: layout.propertyDescription
		required:    true
		if layout.kind == "concat" {type: "components"}
		if layout.kind == "space" {type: "spacing"}
	}]
}]
jsExports: {
	concat: [for layout in layouts if layout.kind == "concat" {layout.name}]
	space: [for layout in layouts if layout.kind == "space" {layout.name}]
}
checks: {
	names: true & list.UniqueItems([for layout in layouts {layout.name}])
	types: true & list.UniqueItems([for layout in layouts {layout.type}])
	constants: true & list.UniqueItems([for layout in layouts {layout.constant}])
	for order in ["parserOrder", "codegenOrder", "docOrder"] {(order): true & list.UniqueItems([for layout in layouts {layout[order]}])}
}
