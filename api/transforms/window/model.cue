package window

import (
	"list"
	"strings"
	"idl.uw.edu/mosaic/api/model"
	columnFamily "idl.uw.edu/mosaic/api/transforms/column"
)

#TransformAPI: {
	name!:       model.#Name
	key!:        model.#Name & contractIndex[name].properties[0].name
	python?:     model.#Name
	description: string & !="" & contractIndex[name].properties[0].description
	arguments!: [...{name!: model.#Name, type!: "TransformArg", required!: bool, default?: "UNSET"}]
	argumentExpression!: model.#Name & contractIndex[name].properties[0].type
	signature!:          "unary" | "binary" | "count" | "quantile" | "nullary" | "lag-lead" | "nth-value"
	origin!:             "@uwdata/mosaic-sql"
	parserOrder!:        int & >=0
	parserAdapter!:      "standard" | "falsy-empty"
	pythonEmpty!:        "none" | "transform-empty-string"
	targets!: {wire!: bool & contractIndex[name].wire, python!: bool & targets.wire}
	if signature == "unary" {argumentExpression: "unaryField"}
	if signature == "binary" {argumentExpression: "binaryField"}
	if signature == "count" {argumentExpression: "countArgs"}
	if signature == "quantile" {argumentExpression: "quantileArgs"}
	if signature == "nullary" {argumentExpression: "nullary"}
	if signature == "lag-lead" {argumentExpression: "lagArgs"}
	if signature == "nth-value" {argumentExpression: "nthArgs"}
	if signature == "unary" {arguments: [{required: true}]}
	if signature == "binary" || signature == "quantile" || signature == "nth-value" {arguments: [{required: true}, {required: true}]}
	if signature == "count" {arguments: [{required: false, default: "UNSET"}], parserAdapter: "falsy-empty"}
	if signature != "count" {parserAdapter: "standard"}
	if signature == "nullary" {arguments: [], pythonEmpty: "none"}
	if signature != "nullary" {pythonEmpty: "transform-empty-string"}
	if signature == "lag-lead" {arguments: [{required: true}, {required: false, default: "UNSET"}, {required: false, default: "UNSET"}]}
	if targets.python {python!: model.#Name}
	if !targets.python {python?: _|_}
}
contracts: [...model.#ShapeContract] & [
	{
		kind:                 "alias"
		name:                 "ArgLagLead"
		description:          "Lag and lead argument signatures."
		wire:                 false
		exported:             false
		documentationAdapter: "reference-only"
		expression:           "lagArgs"
	},
	{
		name:        "RowNumber"
		description: "A row_number window transform."
		properties: [
			{
				name:        "row_number"
				description: "Compute the 1-based row number over an ordered window partition."
				type:        "nullary"
				required:    true
			}
		]
		extends: ["WindowOptions"]
	},
	{
		name:        "Rank"
		description: "A rank window transform."
		properties: [
			{
				name:        "rank"
				description: "Compute the row rank over an ordered window partition. Sorting ties result in gaps in the rank numbers ([1, 1, 3, ...])."
				type:        "nullary"
				required:    true
			}
		]
		extends: ["WindowOptions"]
	},
	{
		name:        "DenseRank"
		description: "A dense_rank window transform."
		properties: [
			{
				name:        "dense_rank"
				description: "Compute the dense row rank (no gaps) over an ordered window partition. Sorting ties do not result in gaps in the rank numbers ([1, 1, 2, ...])."
				type:        "nullary"
				required:    true
			}
		]
		extends: ["WindowOptions"]
	},
	{
		name:        "PercentRank"
		description: "A percent_rank window transform."
		properties: [
			{
				name:        "percent_rank"
				description: "Compute the percentage rank over an ordered window partition."
				type:        "nullary"
				required:    true
			}
		]
		extends: ["WindowOptions"]
	},
	{
		name:        "CumeDist"
		description: "A cume_dist window transform."
		properties: [
			{
				name:        "cume_dist"
				description: "Compute the cumulative distribution value over an ordered window partition. Equals the number of partition rows preceding or peer with the current row, divided by the total number of partition rows."
				type:        "nullary"
				required:    true
			}
		]
		extends: ["WindowOptions"]
	},
	{
		name:        "NTile"
		description: "An ntile window transform."
		properties: [
			{
				name:        "ntile"
				description: "Compute an n-tile integer ranging from 1 to the provided argument (num_buckets), dividing the partition as equally as possible."
				type:        "unaryField"
				required:    true
			}
		]
		extends: ["WindowOptions"]
	},
	{
		name:        "Lag"
		description: "A lag window transform."
		properties: [
			{
				name:            "lag"
				description:     "Compute lagging values in a column. Returns the value at the row that is `offset` (second argument, default `1`) rows before the current row within the window frame. If there is no such row, instead return `default` (third argument, default `null`). Both offset and default are evaluated with respect to the current row."
				type:            "lagArgs"
				required:        true
				typescriptAlias: "ArgLagLead"
			}
		]
		extends: ["WindowOptions"]
	},
	{
		name:        "Lead"
		description: "A lead window transform."
		properties: [
			{
				name:            "lead"
				description:     "Compute leading values in a column. Returns the value at the row that is `offset` (second argument, default `1`) rows after the current row within the window frame. If there is no such row, instead return `default` (third argument, default `null`). Both offset and default are evaluated with respect to the current row."
				type:            "lagArgs"
				required:        true
				typescriptAlias: "ArgLagLead"
			}
		]
		extends: ["WindowOptions"]
	},
	{
		name:        "FirstValue"
		description: "A first_value window transform."
		properties: [
			{
				name:        "first_value"
				description: "Get the first value of the given column in the current window frame."
				type:        "unaryField"
				required:    true
			}
		]
		extends: ["WindowOptions"]
	},
	{
		name:        "LastValue"
		description: "A last_value window transform."
		properties: [
			{
				name:        "last_value"
				description: "Get the last value of the given column in the current window frame."
				type:        "unaryField"
				required:    true
			}
		]
		extends: ["WindowOptions"]
	},
	{
		name:        "NthValue"
		description: "An nth_value window transform."
		properties: [
			{
				name:        "nth_value"
				description: "Get the nth value of the given column in the current window frame, counting from one. The second argument is the offset for the nth row."
				type:        "nthArgs"
				required:    true
			}
		]
		extends: ["WindowOptions"]
	},
	{kind: "alias", name: "IntervalTransform", description: "Date/time interval.", expression: "intervalUnion"},
	{
		let Description = "A date/time interval in units of years."
		name:        "Years"
		description: Description
		properties: [
			{
				name:        "years"
				description: Description
				type:        "numberValue"
				required:    true
			}
		]
	},
	{
		let Description = "A date/time interval in units of months."
		name:        "Months"
		description: Description
		properties: [
			{
				name:        "months"
				description: Description
				type:        "numberValue"
				required:    true
			}
		]
	},
	{
		let Description = "A date/time interval in units of days."
		name:        "Days"
		description: Description
		properties: [
			{
				name:        "days"
				description: Description
				type:        "numberValue"
				required:    true
			}
		]
	},
	{
		let Description = "A date/time interval in units of hours."
		name:        "Hours"
		description: Description
		properties: [
			{
				name:        "hours"
				description: Description
				type:        "numberValue"
				required:    true
			}
		]
	},
	{
		let Description = "A date/time interval in units of minutes."
		name:        "Minutes"
		description: Description
		properties: [
			{
				name:        "minutes"
				description: Description
				type:        "numberValue"
				required:    true
			}
		]
	},
	{
		let Description = "A date/time interval in units of seconds."
		name:        "Seconds"
		description: Description
		properties: [
			{
				name:        "seconds"
				description: Description
				type:        "numberValue"
				required:    true
			}
		]
	},
	{
		let Description = "A date/time interval in units of milliseconds."
		name:        "Milliseconds"
		description: Description
		properties: [
			{
				name:        "milliseconds"
				description: Description
				type:        "numberValue"
				required:    true
			}
		]
	},
	{
		let Description = "A date/time interval in units of microseconds."
		name:        "Microseconds"
		description: Description
		properties: [
			{
				name:        "microseconds"
				description: Description
				type:        "numberValue"
				required:    true
			}
		]
	},
]
apis: [...#TransformAPI] & [
	{
		name:   "RowNumber"
		key:    "row_number"
		python: "row_number"
		arguments: []
		argumentExpression: "nullary"
		signature:          "nullary"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        29
		parserAdapter:      "standard"
		pythonEmpty:        "none"
		targets: {wire: true, python: true}
	},
	{
		name:   "Rank"
		key:    "rank"
		python: "rank"
		arguments: []
		argumentExpression: "nullary"
		signature:          "nullary"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        30
		parserAdapter:      "standard"
		pythonEmpty:        "none"
		targets: {wire: true, python: true}
	},
	{
		name:   "DenseRank"
		key:    "dense_rank"
		python: "dense_rank"
		arguments: []
		argumentExpression: "nullary"
		signature:          "nullary"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        31
		parserAdapter:      "standard"
		pythonEmpty:        "none"
		targets: {wire: true, python: true}
	},
	{
		name:   "PercentRank"
		key:    "percent_rank"
		python: "percent_rank"
		arguments: []
		argumentExpression: "nullary"
		signature:          "nullary"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        32
		parserAdapter:      "standard"
		pythonEmpty:        "none"
		targets: {wire: true, python: true}
	},
	{
		name:   "CumeDist"
		key:    "cume_dist"
		python: "cume_dist"
		arguments: []
		argumentExpression: "nullary"
		signature:          "nullary"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        33
		parserAdapter:      "standard"
		pythonEmpty:        "none"
		targets: {wire: true, python: true}
	},
	{
		name:   "NTile"
		key:    "ntile"
		python: "ntile"
		arguments: [{name: "buckets", type: "TransformArg", required: true}]
		argumentExpression: "unaryField"
		signature:          "unary"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        34
		parserAdapter:      "standard"
		pythonEmpty:        "transform-empty-string"
		targets: {wire: true, python: true}
	},
	{
		name:   "Lag"
		key:    "lag"
		python: "lag"
		arguments: [
			{name: "col", type: "TransformArg", required: true},
			{name: "offset", type: "TransformArg", required: false, default: "UNSET"},
			{name: "default", type: "TransformArg", required: false, default: "UNSET"},
		]
		argumentExpression: "lagArgs"
		signature:          "lag-lead"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        35
		parserAdapter:      "standard"
		pythonEmpty:        "transform-empty-string"
		targets: {wire: true, python: true}
	},
	{
		name:   "Lead"
		key:    "lead"
		python: "lead"
		arguments: [
			{name: "col", type: "TransformArg", required: true},
			{name: "offset", type: "TransformArg", required: false, default: "UNSET"},
			{name: "default", type: "TransformArg", required: false, default: "UNSET"},
		]
		argumentExpression: "lagArgs"
		signature:          "lag-lead"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        36
		parserAdapter:      "standard"
		pythonEmpty:        "transform-empty-string"
		targets: {wire: true, python: true}
	},
	{
		name:   "FirstValue"
		key:    "first_value"
		python: "first_value"
		arguments: [{name: "col", type: "TransformArg", required: true}]
		argumentExpression: "unaryField"
		signature:          "unary"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        37
		parserAdapter:      "standard"
		pythonEmpty:        "transform-empty-string"
		targets: {wire: true, python: true}
	},
	{
		name:   "LastValue"
		key:    "last_value"
		python: "last_value"
		arguments: [{name: "col", type: "TransformArg", required: true}]
		argumentExpression: "unaryField"
		signature:          "unary"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        38
		parserAdapter:      "standard"
		pythonEmpty:        "transform-empty-string"
		targets: {wire: true, python: true}
	},
	{
		name:   "NthValue"
		key:    "nth_value"
		python: "nth_value"
		arguments: [{name: "col", type: "TransformArg", required: true}, {name: "offset", type: "TransformArg", required: true}]
		argumentExpression: "nthArgs"
		signature:          "nth-value"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        39
		parserAdapter:      "standard"
		pythonEmpty:        "transform-empty-string"
		targets: {wire: true, python: true}
	},
]
typeExpressions: columnFamily.sharedFrameExpressions & {
	booleanValue: {kind: "primitive", type: "boolean"}
	dateValue: {kind: "host", adapter: "date-time"}
	nullary: {kind: "application", shape: "Nullary"}
	numberOrField: {kind: "union", members: ["fieldRef", "numberValue"]}
	defaultValue: {kind: "union", members: ["fieldRef", "numberValue", "booleanValue", "dateValue", "nullValue"]}
	lagTuple: {
		kind: "tuple"
		elements: [
			{type: "fieldRef", label: "expr"},
			{type: "numberOrField", label: "offset", required: false},
			{type: "defaultValue", label: "defaultValue", required: false},
		]
		schemaAdapter: "positional-items"
		wireArity:     "all-elements"
	}
	lagArgs: {kind: "union", members: ["fieldRef", "lagTuple"]}
	nthArgs: {
		kind: "tuple"
		elements: [{type: "fieldRef", label: "expr"}, {type: "numberOrField", label: "nth"}]
		schemaAdapter: "positional-items"
	}
	yearsRef: {kind: "named", name: "Years"}
	monthsRef: {kind: "named", name: "Months"}
	daysRef: {kind: "named", name: "Days"}
	hoursRef: {kind: "named", name: "Hours"}
	minutesRef: {kind: "named", name: "Minutes"}
	secondsRef: {kind: "named", name: "Seconds"}
	millisecondsRef: {kind: "named", name: "Milliseconds"}
	microsecondsRef: {kind: "named", name: "Microseconds"}
	intervalUnion: {
		kind: "union"
		members: ["yearsRef", "monthsRef", "daysRef", "hoursRef", "minutesRef", "secondsRef", "millisecondsRef", "microsecondsRef"]
	}
}
baseContracts:  columnFamily.sharedFrameContracts
argumentShapes: columnFamily.sharedArguments
contractIndex: {for contract in contracts {(contract.name): contract}}
publicContracts: contracts
externalReferences: [...model.#ExternalReference] & [
	{name: "ParamRef", owner: "params", source: "./Param.js"},
	{name: "TransformField", owner: "column", source: "./Transform.js"},
]
#IntervalAPI: {
	name!:        model.#Name
	key!:         model.#Name & contractIndex[name].properties[0].name
	description:  contractIndex[name].properties[0].description
	origin!:      "@uwdata/mosaic-sql"
	parserOrder!: int & >=0
}
intervalAPIs: [...#IntervalAPI] & [
	{
		name:        "Years"
		key:         "years"
		origin:      "@uwdata/mosaic-sql"
		parserOrder: 40
	},
	{
		name:        "Months"
		key:         "months"
		origin:      "@uwdata/mosaic-sql"
		parserOrder: 41
	},
	{
		name:        "Days"
		key:         "days"
		origin:      "@uwdata/mosaic-sql"
		parserOrder: 42
	},
	{
		name:        "Hours"
		key:         "hours"
		origin:      "@uwdata/mosaic-sql"
		parserOrder: 43
	},
	{
		name:        "Minutes"
		key:         "minutes"
		origin:      "@uwdata/mosaic-sql"
		parserOrder: 44
	},
	{
		name:        "Seconds"
		key:         "seconds"
		origin:      "@uwdata/mosaic-sql"
		parserOrder: 45
	},
	{
		name:        "Milliseconds"
		key:         "milliseconds"
		origin:      "@uwdata/mosaic-sql"
		parserOrder: 46
	},
	{
		name:        "Microseconds"
		key:         "microseconds"
		origin:      "@uwdata/mosaic-sql"
		parserOrder: 47
	},
]
_frameHostNames: {rows: "Rows", range: "Range", groups: "Groups"}
#FrameKind: {
	key!: or([for key, _ in _frameHostNames {key}])
	type:        strings.ToUpper(key)
	javascript:  "frame" + _frameHostNames[key]
	precedence!: int & >=0 & <=2
}
frameKindContracts: [...#FrameKind] & [{key: "rows", precedence: 0}, {key: "range", precedence: 1}, {key: "groups", precedence: 2}]
frameKindChecks: {
	keys: true & list.UniqueItems([for frame in frameKindContracts {frame.key}])
	precedence: true & list.UniqueItems([for frame in frameKindContracts {frame.precedence}])
}
frameKinds: list.Sort(frameKindContracts, {x: _, y: _, less: x.precedence < y.precedence})
apiChecks: {
	references: [for api in apis {true & (contractIndex[api.name].properties[0].name == api.key), true & (contractIndex[api.name].properties[0].type == api.argumentExpression), true & (contractIndex[api.name].wire == api.targets.wire)}]
	parserOrder: true & list.UniqueItems([for api in apis {api.parserOrder}])
	names: true & list.UniqueItems([for api in apis {api.name}]), keys: true & list.UniqueItems([for api in apis {api.key}]), arguments: [for api in apis {true & list.UniqueItems([for argument in api.arguments {argument.name}])}]}
