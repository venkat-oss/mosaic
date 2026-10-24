package column

import (
	"list"
	"idl.uw.edu/mosaic/api/model"
)

#ColumnAPI: {
	name!:       model.#Name
	key!:        model.#Name
	python!:     model.#Name
	description: string & !="" & contractIndex[name].properties[0].description
	argument!: {name!: model.#Name, type!: "TransformArg", required!: true}
	argumentExpression!: model.#Name
	parserAdapter!:      "bin-options" | "standard"
	origin!:             "@uwdata/mosaic-plot" | "@uwdata/mosaic-sql"
	parserOrder!:        int & >=0
	extension?:          "spatial"
}
apis: [...#ColumnAPI] & [
	{
		name:          "Bin"
		key:           "bin"
		parserAdapter: "bin-options"
		python:        "bin"
		argument: {name: "col", type: "TransformArg", required: true}
		argumentExpression: "unaryField"
		origin:             "@uwdata/mosaic-plot"
		parserOrder:        3
	},
	{
		name:          "Column"
		key:           "column"
		parserAdapter: "standard"
		python:        "column"
		argument: {name: "col", type: "TransformArg", required: true}
		argumentExpression: "unaryColumn"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        7
	},
	{
		name:          "DateMonth"
		key:           "dateMonth"
		parserAdapter: "standard"
		python:        "date_month"
		argument: {name: "col", type: "TransformArg", required: true}
		argumentExpression: "unaryDate"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        11
	},
	{
		name:          "DateMonthDay"
		key:           "dateMonthDay"
		parserAdapter: "standard"
		python:        "date_month_day"
		argument: {name: "col", type: "TransformArg", required: true}
		argumentExpression: "unaryDate"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        12
	},
	{
		name:          "DateDay"
		key:           "dateDay"
		parserAdapter: "standard"
		python:        "date_day"
		argument: {name: "col", type: "TransformArg", required: true}
		argumentExpression: "unaryDate"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        13
	},
	{
		name:          "Centroid"
		key:           "centroid"
		parserAdapter: "standard"
		python:        "centroid"
		argument: {name: "col", type: "TransformArg", required: true}
		argumentExpression: "unaryField"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        4

		extension: "spatial"
	},
	{
		name:          "CentroidX"
		key:           "centroidX"
		parserAdapter: "standard"
		python:        "centroid_x"
		argument: {name: "col", type: "TransformArg", required: true}
		argumentExpression: "unaryField"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        5

		extension: "spatial"
	},
	{
		name:          "CentroidY"
		key:           "centroidY"
		parserAdapter: "standard"
		python:        "centroid_y"
		argument: {name: "col", type: "TransformArg", required: true}
		argumentExpression: "unaryField"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        6

		extension: "spatial"
	},
	{
		name:          "GeoJSON"
		key:           "geojson"
		parserAdapter: "standard"
		python:        "geojson"
		argument: {name: "col", type: "TransformArg", required: true}
		argumentExpression: "unaryField"
		origin:             "@uwdata/mosaic-sql"
		parserOrder:        16

		extension: "spatial"
	},
]
contracts: [...model.#ShapeContract] & [
	{
		name:        "Expression"
		description: "A custom scalar or aggregate SQL expression."
		wire:        false
		kind:        "alias"
		expression:  "expressions"
	},
	{
		name:        "SQLExpression"
		description: "A custom SQL expression."
		properties: [
			{
				name:        "sql"
				description: "A SQL expression string to derive a new column value. Embedded Param references, such as `$param + 1`, are supported. For expressions with aggregate functions, use *agg* instead."
				required:    true
				type:        "stringValue"
			},
			{name: "label", description: "A label for this expression, for example to label a plot axis.", type: "stringValue"},
		]
	},
	{
		name:        "AggregateExpression"
		description: "A custom SQL aggregate expression."
		properties: [
			{
				name:        "agg"
				description: "A SQL expression string to calculate an aggregate value. Embedded Param references, such as `SUM($param + 1)`, are supported. For expressions without aggregate functions, use *sql* instead."
				required:    true
				type:        "stringValue"
			},
			{name: "label", description: "A label for this expression, for example to label a plot axis.", type: "stringValue"},
		]
	},
	{name: "TransformField", description: "A field argument to a data transform.", kind: "alias", expression: "fieldValues"},
	{
		name:        "FrameExclude"
		description: "Window frame exclusion modes."
		wire:        false
		kind:        "alias"
		expression:  "frameExcludeValues"
	},
	{
		name:                 "FrameValue"
		description:          "A numeric, temporal interval, or unbounded window frame bound."
		kind:                 "alias"
		expression:           "frameValues"
		documentationAdapter: "reference-only"
	},
	{
		name:        "WindowOptions"
		description: "Window transform options."
		wire:        false
		properties: [
			{
				name:                 "orderby"
				description:          "Expressions used to order a window partition."
				documentationAdapter: "reference-only"
				type:                 "fieldOrArray"
			},
			{
				name:                 "partitionby"
				description:          "Expressions used to partition a window."
				documentationAdapter: "reference-only"
				type:                 "fieldOrArray"
			},
			{
				name:                 "rows"
				description:          "The rows window frame bounds, or a parameter reference."
				documentationAdapter: "reference-only"
				type:                 "frameOrRef"
			},
			{
				name:                 "range"
				description:          "The range window frame bounds, or a parameter reference."
				documentationAdapter: "reference-only"
				type:                 "frameOrRef"
			},
			{
				name:                 "groups"
				description:          "The groups window frame bounds, or a parameter reference."
				documentationAdapter: "reference-only"
				type:                 "frameOrRef"
			},
			{
				name:                 "exclude"
				description:          "Rows excluded from the window frame."
				documentationAdapter: "reference-only"
				type:                 "excludeValues"
			},
		]
	},
	{name: "BinInterval", description: "Binning interval names.", kind: "alias", expression: "binIntervals"},
	{
		name:        "Bin"
		description: "A bin transform."
		properties: [
			{
				name:        "bin"
				description: "Bin a continuous variable into discrete intervals. The bin argument specifies a data column or expression to bin. Both numerical and temporal (date/time) values are supported."
				required:    true
				type:        "unaryField"
			},
			{
				name:        "interval"
				description: "The interval bin unit to use, typically used to indicate a date/time unit for binning temporal values, such as `hour`, `day`, or `month`. If `date`, the extent of data values is used to automatically select an interval for temporal data. The value `number` enforces normal numerical binning, even over temporal data. If unspecified, defaults to `number` for numerical data and `date` for temporal data."
				type:        "binIntervalRef"
			},
			{
				name:        "step"
				description: "The step size to use between bins. When binning numerical values (or interval type `number`), this setting specifies the numerical step size. For data/time intervals, this indicates the number of steps of that unit, such as hours, days, or years."
				type:        "numberValue"
			},
			{
				name:        "steps"
				description: "The target number of binning steps to use. To accommodate human-friendly (\"nice\") bin boundaries, the actual number of bins may diverge from this exact value. This option is ignored when **step** is specified."
				type:        "numberValue"
			},
			{
				name:        "minstep"
				description: "The minimum allowed bin step size (default `0`) when performing numerical binning. For example, a setting of `1` prevents step sizes less than 1. This option is ignored when **step** is specified."
				type:        "numberValue"
			},
			{
				name:        "nice"
				description: "A flag (default `true`) requesting \"nice\" human-friendly end points and step sizes when performing numerical binning. When **step** is specified, this option affects the binning end points (e.g., origin) only."
				type:        "booleanValue"
			},
			{
				name:        "offset"
				description: "Offset for computed bins (default `0`). For example, a value of `1` will result in using the next consecutive bin boundary."
				type:        "numberValue"
			},
		]
	},
	{
		name:        "Column"
		description: "A column transform."
		properties: [
			{
				name:        "column"
				description: "Interpret a string or param-value as a column reference."
				required:    true
				type:        "unaryColumn"
			}
		]
	},
	{
		name:        "DateMonth"
		description: "A dateMonth transform."
		properties: [
			{
				name:        "dateMonth"
				description: "Transform a Date value to a month boundary for cyclic comparison. Year values are collapsed to enable comparison over months only."
				required:    true
				type:        "unaryDate"
			}
		]
	},
	{
		name:        "DateMonthDay"
		description: "A dateMonthDay transform."
		properties: [
			{
				name:        "dateMonthDay"
				description: "Transform a Date value to a month and day boundary for cyclic comparison. Year values are collapsed to enable comparison over months and days only."
				required:    true
				type:        "unaryDate"
			}
		]
	},
	{
		name:        "DateDay"
		description: "A dateDay transform."
		properties: [
			{
				name:        "dateDay"
				description: "Transform a Date value to a day of the month for cyclic comparison. Year and month values are collapsed to enable comparison over days only."
				required:    true
				type:        "unaryDate"
			}
		]
	},
	{
		name:        "Centroid"
		description: "A centroid transform."
		properties: [
			{
				name:        "centroid"
				description: "Compute the 2D centroid of geometry-typed data. This transform requires the DuckDB `spatial` extension."
				required:    true
				type:        "unaryField"
			}
		]
	},
	{
		name:        "CentroidX"
		description: "A centroidX transform."
		properties: [
			{
				name:        "centroidX"
				description: "Compute the centroid x-coordinate of geometry-typed data. This transform requires the DuckDB `spatial` extension."
				required:    true
				type:        "unaryField"
			}
		]
	},
	{
		name:        "CentroidY"
		description: "A centroidY transform."
		properties: [
			{
				name:        "centroidY"
				description: "Compute the centroid y-coordinate of geometry-typed data. This transform requires the DuckDB `spatial` extension."
				required:    true
				type:        "unaryField"
			}
		]
	},
	{
		name:        "GeoJSON"
		description: "A geojson transform."
		properties: [
			{
				name:        "geojson"
				description: "Compute a GeoJSON-formatted string from geometry-typed data. This transform requires the DuckDB `spatial` extension."
				required:    true
				type:        "unaryField"
			}
		]
	},
]
typeExpressions: [string]: model.#ShapeExpression
typeExpressions: {
	stringValue: {kind: "primitive", type: "string"}
	numberValue: {kind: "primitive", type: "number"}
	booleanValue: {kind: "primitive", type: "boolean"}
	nullValue: {kind: "primitive", type: "null"}
	paramRef: {kind: "named", name: "ParamRef"}
	sqlRef: {kind: "named", name: "SQLExpression"}
	aggRef: {kind: "named", name: "AggregateExpression"}
	transformRef: {kind: "named", name: "Transform"}
	fieldRef: {kind: "named", name: "TransformField"}
	intervalRef: {kind: "named", name: "IntervalTransform"}
	frameValueRef: {kind: "named", name: "FrameValue"}
	binIntervalRef: {kind: "named", name: "BinInterval"}
	expressions: {kind: "union", members: ["sqlRef", "aggRef"], schemaAdapter: "any-of"}
	fieldValues: {kind: "union", members: ["stringValue", "paramRef", "sqlRef", "transformRef"], schemaAdapter: "any-of"}
	frameValues: {kind: "union", members: ["numberValue", "intervalRef", "nullValue"], schemaAdapter: "any-of"}
	frameExcludeValues: {kind: "enum", values: ["CURRENT ROW", "GROUP", "TIES", "NO OTHERS"]}
	uppercaseExclude: {kind: "case-transform", reference: "frameExcludeValues", transform: "uppercase", typeName: "FrameExclude"}
	lowercaseExclude: {kind: "case-transform", reference: "frameExcludeValues", transform: "lowercase", typeName: "FrameExclude"}
	excludeValues: {kind: "union", members: ["uppercaseExclude", "lowercaseExclude"], schemaAdapter: "unique-enum"}
	fieldArray: {kind: "array", items: "fieldRef"}
	fieldOrArray: {kind: "union", members: ["fieldRef", "fieldArray"], schemaAdapter: "any-of"}
	frameTuple: {kind: "tuple", elements: [{type: "frameValueRef"}, {type: "frameValueRef"}]}
	frameOrRef: {kind: "union", members: ["frameTuple", "paramRef"], schemaAdapter: "any-of"}
	binIntervals: {kind: "enum", values: ["date", "number", "millisecond", "second", "minute", "hour", "day", "month", "year"]}
	dateValue: {kind: "host", adapter: "date-time"}
	fieldOrDate: {kind: "union", members: ["fieldRef", "dateValue"], schemaAdapter: "any-of"}
	stringOrParam: {kind: "union", members: ["stringValue", "paramRef"], schemaAdapter: "any-of"}
	unaryField: {kind: "application", shape: "Unary", argument: "fieldRef"}
	unaryDate: {kind: "application", shape: "Unary", argument: "fieldOrDate"}
	unaryColumn: {kind: "application", shape: "Unary", argument: "stringOrParam"}
}
argumentShapes: [...model.#ArgumentShape] & [
	{name: "Nullary", description: "A zero argument transform signature.", scalar: false, nullable: true, tupleSize: 0},
	{
		name:        "Unary"
		description: "A single argument transform signature."
		parameter:   "T"
		scalar:      true
		nullable:    false
		tupleSize:   1
	},
	{
		name:        "Binary"
		description: "A two argument transform signature; both arguments are required."
		parameter:   "T"
		scalar:      false
		nullable:    false
		tupleSize:   2
	},
]
externalReferences: [...model.#ExternalReference] & [
	{name: "ParamRef", owner: "params", source: "./Param.js"},
	{name: "IntervalTransform", owner: "window", source: "./Interval.js"},
	{name: "Transform", owner: "spec", source: "./Transform.js"},
]
contractIndex: {for contract in contracts {(contract.name): contract}}
publicContracts: contracts
standaloneContracts: ["Expression", "SQLExpression", "AggregateExpression", "FrameExclude", "BinInterval", "Column"]
#ExpressionAPI: {
	name!:        model.#Name
	key!:         model.#Name
	description!: string & !=""
	origin?:      "@uwdata/mosaic-sql"
	python?:      "sql"
}
expressionAPIs: [...#ExpressionAPI] & [
	{name: "SQLExpression", key: "sql", python: "sql", description: contractIndex.SQLExpression.description, origin: "@uwdata/mosaic-sql"},
	{name: "AggregateExpression", key: "agg", description: contractIndex.AggregateExpression.description},
]
parserRegistrations: [for api in apis {{key: api.key, order: api.parserOrder}}]
pythonSymbols: [for api in apis {{key: api.key, name: api.python, module: "column"}}]
checks: {
	names: true & list.UniqueItems([for api in apis {api.name}])
	keys: true & list.UniqueItems([for api in apis {api.key}])
	python: true & list.UniqueItems([for api in apis {api.python}])
	parserOrder: true & list.UniqueItems([for api in apis {api.parserOrder}])
	references: [for api in apis {
		true & (contractIndex[api.name].properties[0].name == api.key)
		true & (contractIndex[api.name].properties[0].type == api.argumentExpression)
	}]
}
