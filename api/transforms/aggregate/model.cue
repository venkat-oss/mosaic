package aggregate

import (
	"list"
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
		name:        "AggregateOptions"
		description: "Aggregate transform options."
		properties: [
			{
				name:                 "distinct"
				description:          "Whether to aggregate distinct values."
				type:                 "booleanValue"
				documentationAdapter: "reference-only"
			}
		]
		wire: false
	},
	{
		name:        "Argmax"
		description: "An argmax aggregate transform."
		properties: [
			{
				name:        "argmax"
				description: "Find a value of the first column that maximizes the second column."
				type:        "binaryField"
				required:    true
			}
		]
		extends: ["AggregateOptions", "WindowOptions"]
	},
	{
		name:        "Argmin"
		description: "An argmin aggregate transform."
		properties: [
			{
				name:        "argmin"
				description: "Find a value of the first column that minimizes the second column."
				type:        "binaryField"
				required:    true
			}
		]
		extends: ["AggregateOptions", "WindowOptions"]
	},
	{
		name:        "Avg"
		description: "An avg (average, or mean) aggregate transform."
		properties: [
			{name: "avg", description: "Compute the average (mean) value of the given column.", type: "unaryField", required: true}
		]
		extends: ["AggregateOptions", "WindowOptions"]
	},
	{
		name:        "Count"
		description: "A count aggregate transform."
		properties: [
			{name: "count", description: "Compute the count of records in an aggregation group.", type: "countArgs", required: true}
		]
		extends: ["AggregateOptions", "WindowOptions"]
	},
	{
		name:        "Covariance"
		description: "A sample covariance aggregate transform."
		properties: [
			{
				name:        "covariance"
				description: "Compute the sample covariance of between the given columns."
				type:        "binaryField"
				required:    true
			}
		]
		extends: ["AggregateOptions", "WindowOptions"]
		wire: false
	},
	{
		name:        "CovarPop"
		description: "A population covariance aggregate transform."
		properties: [
			{
				name:        "covarPop"
				description: "Compute the population covariance of between the given columns."
				type:        "binaryField"
				required:    true
			}
		]
		extends: ["AggregateOptions", "WindowOptions"]
		wire: false
	},
	{
		name:        "First"
		description: "A first aggregate transform."
		properties: [
			{
				name:        "first"
				description: "Return the first column value found in an aggregation group."
				type:        "unaryField"
				required:    true
			}
		]
		extends: ["AggregateOptions", "WindowOptions"]
	},
	{
		name:        "Geomean"
		description: "A geometric mean aggregate transform."
		properties: [
			{
				name:        "geomean"
				description: "Compute the geometric mean value of the given column."
				type:        "unaryField"
				required:    true
			}
		]
		extends: ["AggregateOptions", "WindowOptions"]
		wire: false
	},
	{
		name:        "Last"
		description: "A last aggregate transform."
		properties: [
			{
				name:        "last"
				description: "Return the last column value found in an aggregation group."
				type:        "unaryField"
				required:    true
			}
		]
		extends: ["AggregateOptions", "WindowOptions"]
	},
	{
		name:        "Max"
		description: "A max aggregate transform."
		properties: [{name: "max", description: "Compute the maximum value of the given column.", type: "unaryField", required: true}]
		extends: ["AggregateOptions", "WindowOptions"]
	},
	{
		name:        "Min"
		description: "A min aggregate transform."
		properties: [{name: "min", description: "Compute the minimum value of the given column.", type: "unaryField", required: true}]
		extends: ["AggregateOptions", "WindowOptions"]
	},
	{
		name:        "Median"
		description: "A median aggregate transform."
		properties: [{name: "median", description: "Compute the median value of the given column.", type: "unaryField", required: true}]
		extends: ["AggregateOptions", "WindowOptions"]
	},
	{
		name:        "Mode"
		description: "A mode aggregate transform."
		properties: [{name: "mode", description: "Compute the mode value of the given column.", type: "unaryField", required: true}]
		extends: ["AggregateOptions", "WindowOptions"]
	},
	{
		name:        "Product"
		description: "A product aggregate transform."
		properties: [{name: "product", description: "Compute the product of the given column.", type: "unaryField", required: true}]
		extends: ["AggregateOptions", "WindowOptions"]
	},
	{
		name:        "Quantile"
		description: "A quantile aggregate transform."
		properties: [
			{
				name:        "quantile"
				description: "Compute the quantile value of the given column at the provided probability threshold. For example, 0.5 is the median."
				type:        "quantileArgs"
				required:    true
			}
		]
		extends: ["AggregateOptions", "WindowOptions"]
	},
	{
		name:        "Stddev"
		description: "A sample standard deviation aggregate transform."
		properties: [{name: "stddev", description: "Compute the sum of the given column.", type: "unaryField", required: true}]
		extends: ["AggregateOptions", "WindowOptions"]
	},
	{
		name:        "StddevPop"
		description: "A population standard deviation aggregate transform."
		properties: [{name: "stddevPop", description: "Compute the sum of the given column.", type: "unaryField", required: true}]
		extends: ["AggregateOptions", "WindowOptions"]
	},
	{
		name:        "Sum"
		description: "A sum aggregate transform."
		properties: [{name: "sum", description: "Compute the sum of the given column.", type: "unaryField", required: true}]
		extends: ["AggregateOptions", "WindowOptions"]
	},
	{
		name:        "Variance"
		description: "A sample variance aggregate transform."
		properties: [
			{name: "variance", description: "Compute the sample variance of the given column.", type: "unaryField", required: true}
		]
		extends: ["AggregateOptions", "WindowOptions"]
	},
	{
		name:        "VarPop"
		description: "A population variance aggregate transform."
		properties: [
			{
				name:        "varPop"
				description: "Compute the population variance of the given column."
				type:        "unaryField"
				required:    true
			}
		]
		extends: ["AggregateOptions", "WindowOptions"]
	},
]
apis: [...#TransformAPI] & [
	{
		name:   "Argmax"
		key:    "argmax"
		python: "argmax"
		arguments: [{name: "col", type: "TransformArg", required: true}, {name: "by", type: "TransformArg", required: true}]
		argumentExpression: "binaryField"
		signature:          "binary"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        1
		parserAdapter:      "standard"
		pythonEmpty:        "transform-empty-string"
		targets: {wire: true, python: true}
	},
	{
		name:   "Argmin"
		key:    "argmin"
		python: "argmin"
		arguments: [{name: "col", type: "TransformArg", required: true}, {name: "by", type: "TransformArg", required: true}]
		argumentExpression: "binaryField"
		signature:          "binary"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        0
		parserAdapter:      "standard"
		pythonEmpty:        "transform-empty-string"
		targets: {wire: true, python: true}
	},
	{
		name:   "Avg"
		key:    "avg"
		python: "avg"
		arguments: [{name: "col", type: "TransformArg", required: true}]
		argumentExpression: "unaryField"
		signature:          "unary"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        2
		parserAdapter:      "standard"
		pythonEmpty:        "transform-empty-string"
		targets: {wire: true, python: true}
	},
	{
		name:   "Count"
		key:    "count"
		python: "count"
		arguments: [{name: "col", type: "TransformArg", required: false, default: "UNSET"}]
		argumentExpression: "countArgs"
		signature:          "count"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        8
		parserAdapter:      "falsy-empty"
		pythonEmpty:        "transform-empty-string"
		targets: {wire: true, python: true}
	},
	{
		name: "Covariance"
		key:  "covariance"
		arguments: [{name: "col", type: "TransformArg", required: true}, {name: "by", type: "TransformArg", required: true}]
		argumentExpression: "binaryField"
		signature:          "binary"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        9
		parserAdapter:      "standard"
		pythonEmpty:        "transform-empty-string"
		targets: {wire: false, python: false}
	},
	{
		name: "CovarPop"
		key:  "covarPop"
		arguments: [{name: "col", type: "TransformArg", required: true}, {name: "by", type: "TransformArg", required: true}]
		argumentExpression: "binaryField"
		signature:          "binary"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        10
		parserAdapter:      "standard"
		pythonEmpty:        "transform-empty-string"
		targets: {wire: false, python: false}
	},
	{
		name:   "First"
		key:    "first"
		python: "first"
		arguments: [{name: "col", type: "TransformArg", required: true}]
		argumentExpression: "unaryField"
		signature:          "unary"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        14
		parserAdapter:      "standard"
		pythonEmpty:        "transform-empty-string"
		targets: {wire: true, python: true}
	},
	{
		name: "Geomean"
		key:  "geomean"
		arguments: [{name: "col", type: "TransformArg", required: true}]
		argumentExpression: "unaryField"
		signature:          "unary"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        15
		parserAdapter:      "standard"
		pythonEmpty:        "transform-empty-string"
		targets: {wire: false, python: false}
	},
	{
		name:   "Last"
		key:    "last"
		python: "last"
		arguments: [{name: "col", type: "TransformArg", required: true}]
		argumentExpression: "unaryField"
		signature:          "unary"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        17
		parserAdapter:      "standard"
		pythonEmpty:        "transform-empty-string"
		targets: {wire: true, python: true}
	},
	{
		name:   "Max"
		key:    "max"
		python: "max"
		arguments: [{name: "col", type: "TransformArg", required: true}]
		argumentExpression: "unaryField"
		signature:          "unary"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        18
		parserAdapter:      "standard"
		pythonEmpty:        "transform-empty-string"
		targets: {wire: true, python: true}
	},
	{
		name:   "Min"
		key:    "min"
		python: "min"
		arguments: [{name: "col", type: "TransformArg", required: true}]
		argumentExpression: "unaryField"
		signature:          "unary"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        20
		parserAdapter:      "standard"
		pythonEmpty:        "transform-empty-string"
		targets: {wire: true, python: true}
	},
	{
		name:   "Median"
		key:    "median"
		python: "median"
		arguments: [{name: "col", type: "TransformArg", required: true}]
		argumentExpression: "unaryField"
		signature:          "unary"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        19
		parserAdapter:      "standard"
		pythonEmpty:        "transform-empty-string"
		targets: {wire: true, python: true}
	},
	{
		name:   "Mode"
		key:    "mode"
		python: "mode"
		arguments: [{name: "col", type: "TransformArg", required: true}]
		argumentExpression: "unaryField"
		signature:          "unary"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        21
		parserAdapter:      "standard"
		pythonEmpty:        "transform-empty-string"
		targets: {wire: true, python: true}
	},
	{
		name:   "Product"
		key:    "product"
		python: "product"
		arguments: [{name: "col", type: "TransformArg", required: true}]
		argumentExpression: "unaryField"
		signature:          "unary"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        22
		parserAdapter:      "standard"
		pythonEmpty:        "transform-empty-string"
		targets: {wire: true, python: true}
	},
	{
		name:   "Quantile"
		key:    "quantile"
		python: "quantile"
		arguments: [{name: "col", type: "TransformArg", required: true}, {name: "p", type: "TransformArg", required: true}]
		argumentExpression: "quantileArgs"
		signature:          "quantile"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        23
		parserAdapter:      "standard"
		pythonEmpty:        "transform-empty-string"
		targets: {wire: true, python: true}
	},
	{
		name:   "Stddev"
		key:    "stddev"
		python: "stddev"
		arguments: [{name: "col", type: "TransformArg", required: true}]
		argumentExpression: "unaryField"
		signature:          "unary"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        24
		parserAdapter:      "standard"
		pythonEmpty:        "transform-empty-string"
		targets: {wire: true, python: true}
	},
	{
		name:   "StddevPop"
		key:    "stddevPop"
		python: "stddev_pop"
		arguments: [{name: "col", type: "TransformArg", required: true}]
		argumentExpression: "unaryField"
		signature:          "unary"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        25
		parserAdapter:      "standard"
		pythonEmpty:        "transform-empty-string"
		targets: {wire: true, python: true}
	},
	{
		name:   "Sum"
		key:    "sum"
		python: "sum"
		arguments: [{name: "col", type: "TransformArg", required: true}]
		argumentExpression: "unaryField"
		signature:          "unary"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        26
		parserAdapter:      "standard"
		pythonEmpty:        "transform-empty-string"
		targets: {wire: true, python: true}
	},
	{
		name:   "Variance"
		key:    "variance"
		python: "variance"
		arguments: [{name: "col", type: "TransformArg", required: true}]
		argumentExpression: "unaryField"
		signature:          "unary"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        27
		parserAdapter:      "standard"
		pythonEmpty:        "transform-empty-string"
		targets: {wire: true, python: true}
	},
	{
		name:   "VarPop"
		key:    "varPop"
		python: "var_pop"
		arguments: [{name: "col", type: "TransformArg", required: true}]
		argumentExpression: "unaryField"
		signature:          "unary"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        28
		parserAdapter:      "standard"
		pythonEmpty:        "transform-empty-string"
		targets: {wire: true, python: true}
	},
]
typeExpressions: columnFamily.sharedFrameExpressions & {
	booleanValue: {kind: "primitive", type: "boolean"}
	binaryField: {kind: "application", shape: "Binary", argument: "fieldRef"}
	nullary: {kind: "application", shape: "Nullary"}
	countArgs: {kind: "union", members: ["nullary", "unaryField"]}
	numberOrField: {kind: "union", members: ["fieldRef", "numberValue"]}
	quantileArgs: {
		kind: "tuple"
		elements: [{type: "fieldRef", label: "expr"}, {type: "numberOrField", label: "p"}]
		schemaAdapter: "positional-items"
	}
}
baseContracts:  columnFamily.sharedFrameContracts
argumentShapes: columnFamily.sharedArguments
contractIndex: {for contract in contracts {(contract.name): contract}}
publicContracts: contracts
externalReferences: [...model.#ExternalReference] & [
	{name: "ParamRef", owner: "params", source: "./Param.js"},
	{name: "TransformField", owner: "column", source: "./Transform.js"},
	{name: "IntervalTransform", owner: "window", source: "./Interval.js"},
]
#JavaScriptAggregateAPI: {
	key!:         model.#Name
	name:         key
	signature:    string
	description!: string & !=""
	origin!:      "@uwdata/mosaic-sql"
	arguments!: [{name!: model.#Name, type!: "ExprValue", required!: true}, ...{name!: model.#Name, type!: "ExprValue", required!: true}]
	if len(arguments) == 1 {signature: "unary"}
	if len(arguments) == 2 {signature: "binary"}

}
jsOnlyAPIs: [...#JavaScriptAggregateAPI] & [
	{
		key:         "arrayAgg"
		description: "Compute an array aggregation."
		origin:      "@uwdata/mosaic-sql"
		arguments: [{name: "expr", type: "ExprValue", required: true}]

	},
	{
		key:         "corr"
		description: "Compute a correlation aggregate."
		origin:      "@uwdata/mosaic-sql"
		arguments: [{name: "x", type: "ExprValue", required: true}, {name: "y", type: "ExprValue", required: true}]

	},
	{
		key:         "entropy"
		description: "Compute an entropy aggregate."
		origin:      "@uwdata/mosaic-sql"
		arguments: [{name: "expr", type: "ExprValue", required: true}]

	},
	{
		key:         "kurtosis"
		description: "Compute a sample kurtosis aggregate."
		origin:      "@uwdata/mosaic-sql"
		arguments: [{name: "expr", type: "ExprValue", required: true}]

	},
	{
		key:         "mad"
		description: "Compute a median absolute deviation (MAD) aggregate."
		origin:      "@uwdata/mosaic-sql"
		arguments: [{name: "expr", type: "ExprValue", required: true}]

	},
	{
		key:         "skewness"
		description: "Compute a skewness aggregate."
		origin:      "@uwdata/mosaic-sql"
		arguments: [{name: "expr", type: "ExprValue", required: true}]

	},
	{
		key:         "stringAgg"
		description: "Compute a string aggregation."
		origin:      "@uwdata/mosaic-sql"
		arguments: [{name: "expr", type: "ExprValue", required: true}]

	},
]
apiChecks: {
	references: [for api in apis {true & (contractIndex[api.name].properties[0].name == api.key), true & (contractIndex[api.name].properties[0].type == api.argumentExpression), true & (contractIndex[api.name].wire == api.targets.wire)}]
	parserOrder: true & list.UniqueItems([for api in apis {api.parserOrder}])
	names: true & list.UniqueItems([for api in apis {api.name}]), keys: true & list.UniqueItems([for api in apis {api.key}]), arguments: [for api in apis {true & list.UniqueItems([for argument in api.arguments {argument.name}])}]}
