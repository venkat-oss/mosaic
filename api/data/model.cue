package data

import (
	"list"
	"strings"
	"idl.uw.edu/mosaic/api/model"
)

typeExpressions: [string]: model.#ShapeExpression
typeExpressions: {
	stringValue: {kind: "primitive", type: "string"}
	numberValue: {kind: "primitive", type: "number"}
	booleanValue: {kind: "primitive", type: "boolean"}
	anyValue: {kind: "primitive", type: "any"}
	objectValue: kind: "object"
	objectArray: {kind: "array", items: "objectValue"}
	stringArray: {kind: "array", items: "stringValue"}
	anyArray: {kind: "array", items: "anyValue"}
	whereValue: {kind: "union", members: ["stringValue", "stringArray"]}
	parquetFile: {
		kind: "template"
		parts: [{primitive: "string"}]
		suffix:        ".parquet"
		completion:    "plain"
		schemaAdapter: "open-string"
	}
	csvFile: {kind: "template", parts: [{primitive: "string"}], suffix: ".csv", completion: "plain", schemaAdapter: "open-string"}
	jsonFile: {kind: "template", parts: [{primitive: "string"}], suffix: ".json", completion: "plain", schemaAdapter: "open-string"}
	fileSuffix: {kind: "union", members: ["parquetFile", "csvFile", "jsonFile"], schemaAdapter: "unique-primitive-type-array"}
	tableKind: {kind: "literal", value: "table"}
	parquetKind: {kind: "literal", value: "parquet"}
	csvKind: {kind: "literal", value: "csv"}
	spatialKind: {kind: "literal", value: "spatial"}
	jsonKind: {kind: "literal", value: "json"}
	paramRef: {kind: "named", name: "ParamRef"}
	sourceName: {kind: "union", members: ["stringValue", "paramRef"]}
	DataQueryReference: {kind: "named", name: "DataQuery"}
	DataArrayReference: {kind: "named", name: "DataArray"}
	DataFileReference: {kind: "named", name: "DataFile"}
	DataTableReference: {kind: "named", name: "DataTable"}
	DataParquetReference: {kind: "named", name: "DataParquet"}
	DataCSVReference: {kind: "named", name: "DataCSV"}
	DataSpatialReference: {kind: "named", name: "DataSpatial"}
	DataJSONReference: {kind: "named", name: "DataJSON"}
	DataJSONObjectsReference: {kind: "named", name: "DataJSONObjects"}
	PlotDataInlineReference: {kind: "named", name: "PlotDataInline"}
	PlotFromReference: {kind: "named", name: "PlotFrom"}
	dataDefinition: {
		// CUE v0.17.1 otherwise keeps incomplete typed-file alternatives beside a complete bare file.
		nativeDefault: "DataFileReference"
		kind:          "union"
		members: [
			"DataQueryReference",
			"DataArrayReference",
			"DataFileReference",
			"DataTableReference",
			"DataParquetReference",
			"DataCSVReference",
			"DataSpatialReference",
			"DataJSONReference",
			"DataJSONObjectsReference",
		]
	}
	plotMarkData: {kind: "union", members: ["PlotDataInlineReference", "PlotFromReference"]}
}
contracts: [...model.#ShapeContract] & [
	{
		name:        "DataBaseOptions"
		description: "Options shared by table and file data definitions."
		wire:        false
		properties: [
			{
				name:        "select"
				description: "A list of column names to extract upon load. Any other columns are omitted."
				type:        "stringArray"
			},
			{
				name:        "where"
				description: "A filter (WHERE clause) to apply upon load. Only rows that pass the filter are included."
				type:        "whereValue"
			},
			{name: "view", description: "Flag (default `false`) to generate a view instead of a table.", type: "booleanValue"},
			{name: "temp", description: "Flag (default `true`) to generate a temporary view or table.", type: "booleanValue"},
			{
				name:        "replace"
				description: "Flag (default `true`) to replace an existing table of the same name. If `false`, creating a new table with an existing name raises an error."
				type:        "booleanValue"
			},
		]
		documentationAdapter: "reference-only"
	},
	{
		name:        "DataQuery"
		description: "A SQL query defining a new temporary database table."
		kind:        "alias"
		expression:  "stringValue"
	},
	{
		name:        "DataArray"
		description: "An inline array of data objects to treat as JSON data."
		kind:        "alias"
		expression:  "objectArray"
	},
	{
		name:        "DataFile"
		description: "A data definition that loads an external data file."
		extends: ["DataBaseOptions"]
		properties: [
			{
				name:        "file"
				description: "The data file to load. If no type option is provided, the file suffix must be one of `.csv`, `.json`, or `.parquet`."
				required:    true
				type:        "fileSuffix"
			}
		]
	},
	{
		name:        "DataTable"
		description: "A data definition that queries an existing table."
		extends: ["DataBaseOptions"]
		properties: [
			{
				name:        "type"
				description: "The data source type. One of:\n- `\"table\"`: Define a new table based on a SQL query.\n- `\"csv\"`: Load a comma-separated values (CSV) file.\n- `\"json\"`: Load JavaScript Object Notation (json) data.\n- `\"parquet\"`: Load a Parquet file.\n- `\"spatial\"`: Load a spatial data file format via `ST_Read`."
				required:    true
				type:        "tableKind"
			},
			{name: "query", description: "A SQL query string for the desired table data.", required: true, type: "stringValue"},
		]
	},
	{
		name:        "DataParquet"
		description: "A data definition that loads a parquet file."
		extends: ["DataBaseOptions"]
		properties: [
			{
				name:        "type"
				description: "The data source type. One of:\n- `\"table\"`: Define a new table based on a SQL query.\n- `\"csv\"`: Load a comma-separated values (CSV) file.\n- `\"json\"`: Load JavaScript Object Notation (json) data.\n- `\"parquet\"`: Load a Parquet file.\n- `\"spatial\"`: Load a spatial data file format via `ST_Read`."
				required:    true
				type:        "parquetKind"
			},
			{name: "file", description: "The file path for the dataset to load.", required: true, type: "stringValue"},
		]
	},
	{
		name:        "DataCSV"
		description: "A data definition that loads a csv file."
		extends: ["DataBaseOptions"]
		properties: [
			{
				name:        "type"
				description: "The data source type. One of:\n- `\"table\"`: Define a new table based on a SQL query.\n- `\"csv\"`: Load a comma-separated values (CSV) file.\n- `\"json\"`: Load JavaScript Object Notation (json) data.\n- `\"parquet\"`: Load a Parquet file.\n- `\"spatial\"`: Load a spatial data file format via `ST_Read`."
				required:    true
				type:        "csvKind"
			},
			{name: "file", description: "The file path for the dataset to load.", required: true, type: "stringValue"},
			{
				name:        "delimiter"
				description: "The column delimiter string. If not specified, DuckDB will try to infer the delimiter automatically."
				type:        "stringValue"
			},
			{
				name:        "sample_size"
				description: "The sample size, in table rows, to consult for type inference. Set to `-1` to process all rows in the dataset."
				type:        "numberValue"
			},
		]
	},
	{
		name:        "DataSpatial"
		description: "A data definition that loads a supported spatial data file format."
		extends: ["DataBaseOptions"]
		properties: [
			{
				name:        "type"
				description: "The data source type. One of:\n- `\"table\"`: Define a new table based on a SQL query.\n- `\"csv\"`: Load a comma-separated values (CSV) file.\n- `\"json\"`: Load JavaScript Object Notation (json) data.\n- `\"parquet\"`: Load a Parquet file.\n- `\"spatial\"`: Load a spatial data file format via `ST_Read`."
				required:    true
				type:        "spatialKind"
			},
			{
				name:        "file"
				description: "The file path for the spatial dataset to load. See the [DuckDB spatial documentation][1] for more information on supported file types.\n\n[1]: https://duckdb.org/docs/extensions/spatial.html#st_read--read-spatial-data-from-files"
				required:    true
				type:        "stringValue"
			},
			{
				name:        "layer"
				description: "The named layer to load from the file. For example, in a TopoJSON file the layer is the named object to extract. For Excel spreadsheet files, the layer is the name of the worksheet to extract."
				type:        "stringValue"
			},
		]
	},
	{
		name:        "DataJSON"
		description: "Load a JSON file into a database table."
		extends: ["DataBaseOptions"]
		properties: [
			{
				name:        "type"
				description: "The data source type. One of:\n- `\"table\"`: Define a new table based on a SQL query.\n- `\"csv\"`: Load a comma-separated values (CSV) file.\n- `\"json\"`: Load JavaScript Object Notation (json) data.\n- `\"parquet\"`: Load a Parquet file.\n- `\"spatial\"`: Load a spatial data file format via `ST_Read`."
				required:    true
				type:        "jsonKind"
			},
			{name: "file", description: "The file path for the dataset to load.", required: true, type: "stringValue"},
		]
		documentationAdapter: "reference-only"
	},
	{
		name:        "DataJSONObjects"
		description: "Load inline JSON objects into a database table."
		extends: ["DataBaseOptions"]
		properties: [
			{
				name:        "type"
				description: "The data source type. One of:\n- `\"table\"`: Define a new table based on a SQL query.\n- `\"csv\"`: Load a comma-separated values (CSV) file.\n- `\"json\"`: Load JavaScript Object Notation (json) data.\n- `\"parquet\"`: Load a Parquet file.\n- `\"spatial\"`: Load a spatial data file format via `ST_Read`."
				type:        "jsonKind"
			},
			{name: "data", description: "An array of inline objects in JSON-style format.", required: true, type: "objectArray"},
		]
		documentationAdapter: "reference-only"
	},
	{
		name:                 "DataDefinition"
		description:          "Supported definitions of a named database table."
		kind:                 "alias"
		expression:           "dataDefinition"
		documentationAdapter: "reference-only"
	},
	{
		name:        "PlotDataInline"
		description: "An array of inline data values to visualize. As this data does not come from a database, it can not be filtered by interactive selections."
		kind:        "alias"
		expression:  "anyArray"
	},
	{
		name:        "PlotFrom"
		description: "Input data specification for a plot mark."
		properties: [
			{name: "from", description: "The name of the backing data table.", required: true, type: "sourceName"},
			{name: "filterBy", description: "A selection that filters the mark data.", type: "paramRef"},
			{
				name:        "optimize"
				description: "A flag (default `true`) to enable any mark-specific query optimizations. If `false`, optimizations are disabled to aid testing and debugging."
				type:        "booleanValue"
			},
		]
	},
	{name: "PlotMarkData", description: "Input data for a marks", kind: "alias", expression: "plotMarkData"},
]
contractIndex: {for contract in contracts {(contract.name): contract}}
publicContracts: contracts
dataContracts:   contracts[:11]
sourceContracts: contracts[11:]

#DataFormat: {
	contract!:           "DataTable" | "DataParquet" | "DataCSV" | "DataJSON" | "DataSpatial"
	constant!:           "TABLE_DATA" | "PARQUET_DATA" | "CSV_DATA" | "JSON_DATA" | "SPATIAL_DATA"
	parser!:             "parseTableData" | "parseParquetData" | "parseCSVData" | "parseJSONData" | "parseSpatialData"
	loader!:             "createTable" | "loadParquet" | "loadCSV" | "loadJSON" | "loadSpatial"
	authoring!:          "table" | "file" | "json" | "spatial"
	fileExpression?:     "parquetFile" | "csvFile" | "jsonFile"
	defaultInference:    *false | bool
	extension?:          "spatial"
	pythonFileInference: *false | bool
	pythonOrder!:        int & >=0 & <5
	python!: {
		name!: "parquet" | "csv" | "spatial" | "table" | "json"
		parameters!: [...#PythonParameter]
		payloadOrder!: [...("file" | "select" | "where" | "layer" | "query" | "data")]
	}
}
#PythonParameter: {
	name!:       "file" | "select" | "where" | "kwargs" | "layer" | "query" | "data" | "named_defs" | "name" | "opts"
	annotation!: "str" | "Any" | "optional-string" | "DataDef"
	kind!:       "positional-or-keyword" | "keyword-variadic"
	default?:    "none"
	omitNone?:   true
}
formatRecords: [...#DataFormat] & [
	{contract: "DataTable", defaultInference: true, constant: "TABLE_DATA", parser: "parseTableData", loader: "createTable", authoring: "table", pythonOrder: 3, python: {name: "table", parameters: [{name: "query", annotation: "str", kind: "positional-or-keyword"}], payloadOrder: ["query"]}},
	{contract: "DataParquet", pythonFileInference: true, constant: "PARQUET_DATA", parser: "parseParquetData", loader: "loadParquet", authoring: "file", fileExpression: "parquetFile", pythonOrder: 0, python: {name: "parquet", parameters: [{name: "file", annotation: "str", kind: "positional-or-keyword"}, {name: "select", annotation: "Any", kind: "positional-or-keyword", default: "none", omitNone: true}, {name: "where", annotation: "Any", kind: "positional-or-keyword", default: "none", omitNone: true}, {name: "kwargs", annotation: "Any", kind: "keyword-variadic"}], payloadOrder: ["file", "select", "where"]}},
	{contract: "DataCSV", pythonFileInference: true, constant: "CSV_DATA", parser: "parseCSVData", loader: "loadCSV", authoring: "file", fileExpression: "csvFile", pythonOrder: 1, python: {name: "csv", parameters: [{name: "file", annotation: "str", kind: "positional-or-keyword"}, {name: "kwargs", annotation: "Any", kind: "keyword-variadic"}], payloadOrder: ["file"]}},
	{contract: "DataJSON", constant: "JSON_DATA", parser: "parseJSONData", loader: "loadJSON", authoring: "json", fileExpression: "jsonFile", pythonOrder: 4, python: {name: "json", parameters: [{name: "data", annotation: "Any", kind: "positional-or-keyword", default: "none", omitNone: true}, {name: "file", annotation: "optional-string", kind: "positional-or-keyword", default: "none", omitNone: true}, {name: "kwargs", annotation: "Any", kind: "keyword-variadic"}], payloadOrder: ["file", "data"]}},
	{contract: "DataSpatial", constant: "SPATIAL_DATA", parser: "parseSpatialData", loader: "loadSpatial", authoring: "spatial", extension: "spatial", pythonOrder: 2, python: {name: "spatial", parameters: [{name: "file", annotation: "str", kind: "positional-or-keyword"}, {name: "layer", annotation: "optional-string", kind: "positional-or-keyword", default: "none", omitNone: true}, {name: "kwargs", annotation: "Any", kind: "keyword-variadic"}], payloadOrder: ["file", "layer"]}},
]
dataFormats: [for item in formatRecords {
	type: typeExpressions[[for property in contractIndex[item.contract].properties if property.name == "type" {property.type}][0]].value
	for key, value in item {(key): value}
	if item.fileExpression != _|_ {suffix: strings.TrimPrefix(typeExpressions[item.fileExpression].suffix, ".")}
}]
pythonFactories: [for position in list.Range(0, len(dataFormats), 1) for format in dataFormats if format.pythonOrder == position {format}]
sourceFactory: {
	name:        "source"
	description: "Refer to a named table, retaining arbitrary source options after camelizing keys and omitting None."
	parameters: [...#PythonParameter] & [{name: "name", annotation: "str", kind: "positional-or-keyword"}, {name: "opts", annotation: "Any", kind: "keyword-variadic"}]
	runtimeClass: "FromRef"
}
sourceAdapters: [{
	name:        "unnest"
	description: "Native JavaScript and Python sources retain unnest options; the default declarative source schema does not admit this property."
}, {
	name:        "frames"
	description: "Python native frames keep their identity for registration and caller naming instead of becoming a wire data definition."
}]
checks: {
	formatTypes: true & list.UniqueItems([for format in dataFormats {format.type}])
	formatParsers: true & list.UniqueItems([for format in dataFormats {format.parser}])
	pythonOrders: true & list.UniqueItems([for format in dataFormats {format.pythonOrder}])
	pythonPayloadFields: [for format in dataFormats for field in format.python.payloadOrder {
		true & list.Contains([for parameter in format.python.parameters {parameter.name}], field)
	}]
}

namedDataFactory: {
	name: "data"
	parameters: [...#PythonParameter] & [{name: "named_defs", annotation: "DataDef", kind: "keyword-variadic"}]
	runtimeHook: "named_data"
	returns:     "named-definitions"
	description: "Serialize named objects with to_dict and retain all other values."
}

jsSourceFactory: {
	name: "from"
	parameters: [{name: "table", required: true}, {name: "options", required: false, default: "undefined"}]
}
jsExports: source: [jsSourceFactory.name]

defaultDataFormat: [for format in dataFormats if format.defaultInference {format.type}][0]
runtimeNames: [{name: "DATA", value: "data"}, {name: "FROM", value: jsSourceFactory.name}]
checks: defaultFormat: true & (len([for format in dataFormats if format.defaultInference {format.type}]) == 1)
