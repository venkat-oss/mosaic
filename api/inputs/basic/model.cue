package basicinputs

import "idl.uw.edu/mosaic/api/model"

_inputs: [
	{
		name:             "Menu"
		description:      "A menu input component."
		input:            "menu"
		inputDescription: "A menu input widget."
		properties: [
			{name: "as", type: "ParamRef", description: "The output selection. A selection clause is added for the currently selected menu option."},
			{name: "field", type: "string", description: "The database column name to use within generated selection clause predicates. Defaults to the `column` property."},
			{name: "from", type: "string", description: "The name of a database table to use as a data source for this widget. Used in conjunction with the `column` property."},
			{name: "column", type: "string", description: "The name of a database column from which to pull menu options. The unique column values are used as menu options. Used in conjunction with the `from` property."},
			{name: "listMatch", type: "ListMatch", description: "Required if the database column is an list, this property determines how to match the selected menu option against the list values."},
			{name: "filterBy", type: "ParamRef", description: "A selection to filter the database table indicated by the `from` property."},
			{name: "label", type: "string", description: "A text label for this input."},
			{name: "options", type: "MenuOptions", description: "An array of menu options, as literal values or option objects. Option objects have a `value` property and an optional `label` property. If no label is provided, the string-coerced value is used."},
			{name: "value", type: "any", description: "The initial selected menu value, including for a menu without a Param or Selection binding."},
		]
	},
	{
		name:             "Search"
		description:      "A case-insensitive text search input component."
		input:            "search"
		inputDescription: "A text search input widget."
		properties: [
			{name: "as", type: "ParamRef", description: "The output selection. A selection clause is added for the current text search query."},
			{name: "field", type: "string", description: "The database column name to use within generated selection clause predicates. Defaults to the `column` property."},
			{name: "type", type: "SearchType", description: "The type of text search query to perform. One of:\n- `\"contains\"` (default): the query string may appear anywhere in the text\n- `\"prefix\"`: the query string must appear at the start of the text\n- `\"suffix\"`: the query string must appear at the end of the text\n- `\"regexp\"`: the query string is a regular expression the text must match"},
			{name: "from", type: "string", description: "The name of a database table to use as an autocomplete data source for this widget. Used in conjunction with the `column` property."},
			{name: "column", type: "string", description: "The name of a database column from which to pull valid search results. The unique column values are used as search autocomplete values. Used in conjunction with the `from` property."},
			{name: "filterBy", type: "ParamRef", description: "A selection to filter the database table indicated by the `from` property."},
			{name: "label", type: "string", description: "A text label for this input."},
		]
	},
	{
		name:             "Slider"
		description:      "A slider input component."
		input:            "slider"
		inputDescription: "A slider input widget."
		properties: [
			{name: "as", type: "ParamRef", description: "The output selection. A selection clause is added for the currently selected slider option."},
			{name: "field", type: "string", description: "The database column name to use within generated selection clause predicates. Defaults to the `column` property."},
			{name: "select", type: "SliderSelection", description: "The type of selection clause predicate to generate if the **as** option is a Selection. If `'point'` (the default), the selection predicate is an equality check for the slider value. If `'interval'`, the predicate checks an interval from the minimum to the current slider value."},
			{name: "from", type: "string", description: "The name of a database table to use as a data source for this widget. Used in conjunction with the `column` property. The minimum and maximum values of the column determine the slider range."},
			{name: "column", type: "string", description: "The name of a database column whose values determine the slider range. Used in conjunction with the `from` property. The minimum and maximum values of the column determine the slider range."},
			{name: "filterBy", type: "ParamRef", description: "A selection to filter the database table indicated by the `from` property."},
			{name: "min", type: "number", description: "The minimum slider value."},
			{name: "max", type: "number", description: "The maximum slider value."},
			{name: "step", type: "number", description: "The slider step, the amount to increment between consecutive values."},
			{name: "label", type: "string", description: "A text label for this input."},
			{name: "value", type: "number", description: "The initial slider value."},
			{name: "width", type: "number", description: "The width of the slider in screen pixels."},
		]
	},
]

contracts: [...model.#ShapeContract] & [for Input in _inputs {
	name:        Input.name
	description: Input.description
	properties: [
		{name: "input", description: Input.inputDescription, required: true, type: Input.name + "Kind"},
		for Property in Input.properties {Property},
	]
}]

typeExpressions: [string]: model.#ShapeExpression
typeExpressions: {
	for Primitive in ["string", "number", "any"] {
		(Primitive): {kind: "primitive", type: Primitive}
	}
	for Input in _inputs {
		(Input.name + "Kind"): {kind: "literal", value: Input.input}
	}
	ParamRef: {kind: "named", name: "ParamRef"}
	ListMatch: {kind: "enum", values: ["any", "all"]}
	SearchType: {kind: "enum", values: ["contains", "prefix", "suffix", "regexp"]}
	SliderSelection: {kind: "enum", values: ["point", "interval"]}
	MenuOptions: {kind: "array", items: "MenuOption"}
	MenuOption: {kind: "union", members: ["any", "MenuOptionObject"]}
	MenuOptionObject: {kind: "record", properties: [
		{name: "value", description: "The option value.", documentationAdapter: "reference-only", required: true, type: "any"},
		{name: "label", description: "The displayed option label.", documentationAdapter: "reference-only", type: "string"},
	]}
}
contractIndex: {for contract in contracts {(contract.name): contract}}
publicContracts: contracts

sharedInputs: [for Input in _inputs {
	contract: Input.name
	name:     Input.input
	runtime:  Input.name
}]
inputIndex: {for input in sharedInputs {(input.name): input}}
inputAliases: [{python: "bind", wire: "as"}, {python: "source", wire: "from"}]
hostAdapters: [
	{description: "Native JavaScript clients accept an existing container DOM element; declarative input definitions do not serialize DOM nodes.", scope: ["Menu", "Search", "Slider"]},
	{description: "Native JavaScript menus accept a formatting callback; declarative menu definitions do not serialize callbacks.", scope: ["Menu"]},
]
