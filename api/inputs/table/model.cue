package tableinput

import "idl.uw.edu/mosaic/api/model"

typeExpressions: [string]: model.#ShapeExpression
typeExpressions: {
	tableKind: {kind: "literal", value: "table"}
	paramReference: {kind: "named", name: "ParamRef"}
	stringValue: {kind: "primitive", type: "string"}
	fromValues: {kind: "union", members: ["stringValue", "paramReference"]}
	columnNames: {kind: "array", items: "stringValue"}
	alignmentValues: {kind: "enum", values: ["left", "right", "center", "justify"]}
	alignDictionary: {kind: "dictionary", values: "alignmentValues", keyName: "column"}
	numberValue: {kind: "primitive", type: "number"}
	widthDictionary: {kind: "dictionary", values: "numberValue", keyName: "column"}
	widthValues: {kind: "union", members: ["numberValue", "widthDictionary"]}
}
contracts: [...model.#ShapeContract] & [
	{
		name:        "Table"
		description: "A table grid view component."
		properties: [
			{name: "input", description: "A table grid widget.", required: true, type: "tableKind"},
			{
				name:        "as"
				description: "The output selection. A selection clause is added for each currently selected table row."
				type:        "paramReference"
			},
			{
				name:        "from"
				description: "The name of a database table to use as a data source for this widget."
				required:    true
				type:        "fromValues"
			},
			{
				name:        "columns"
				description: "A list of column names to include in the table grid. If unspecified, all table columns are included."
				type:        "columnNames"
			},
			{
				name:        "filterBy"
				description: "A selection to filter the database table indicated by the `from` property."
				type:        "paramReference"
			},
			{
				name:        "align"
				description: "An object of per-column alignment values. Column names should be object keys, which map to alignment values. Valid alignment values are: `\"left\"`, `\"right\"`, `\"center\"`, and `\"justify\"`. By default, numbers are right-aligned and other values are left-aligned."
				type:        "alignDictionary"
			},
			{
				name:        "width"
				description: "If a number, sets the total width of the table widget, in pixels. If an object, provides per-column pixel width values. Column names should be object keys, mapped to numeric width values."
				type:        "widthValues"
			},
			{name: "maxWidth", description: "The maximum width of the table widget, in pixels.", type: "numberValue"},
			{name: "height", description: "The height of the table widget, in pixels.", type: "numberValue"},
			{name: "rowBatch", description: "The number of rows load in a new batch upon table scroll.", type: "numberValue"},
		]
	}
]
contract: contracts[0]

api: {
	name:        typeExpressions.tableKind.value
	python:      "table_input"
	runtime:     contract.name
	description: "Create a serializable table widget view from a source name or parameter."
}
hostAdapters: [
	{description: "Native JavaScript tables accept an existing container element; declarative definitions do not serialize DOM nodes."},
	{description: "Native JavaScript tables accept per-column formatting functions returning text or DOM nodes. Hovering nested formatter elements selects their containing table row. Declarative definitions do not serialize callbacks."},
]
coordinatorBehavior: "Metadata, visible pages and look-ahead prefetch use the table's owning coordinator, including an explicitly scoped vgplot API context. Source and filter changes cancel obsolete requests and restart from the first page. Disconnection cancels pending table and prefetch requests."

#RuntimeDefaults: {
	columns!: [string, ...string]
	height!:   number
	rowBatch!: number
}
runtimeDefaults: #RuntimeDefaults & {columns: ["*"], height: 500, rowBatch: 100}
