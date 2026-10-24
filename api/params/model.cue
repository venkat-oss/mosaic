package params

import (
	"list"
	"strings"
	"idl.uw.edu/mosaic/api/model"
)

#FactoryRecord: {
	name!:             model.#Name
	description!:      string & !=""
	schemaOrder!:      int & >=0
	parserOrder!:      int & >=0
	pythonOrder!:      int & >=0
	defaultSelection!: bool
}
_factoryRecords: [...#FactoryRecord] & [
	{
		name:             "crossfilter"
		defaultSelection: false
		description:      "Create a cross-filtered intersection selection."
		schemaOrder:      0
		parserOrder:      1
		pythonOrder:      1
	},
	{
		name:             "intersect"
		defaultSelection: true
		description:      "Create a selection that intersects clauses."
		schemaOrder:      1
		parserOrder:      2
		pythonOrder:      0
	},
	{
		name:             "single"
		defaultSelection: false
		description:      "Create a selection that retains a single clause."
		schemaOrder:      2
		parserOrder:      0
		pythonOrder:      3
	},
	{
		name:             "union"
		defaultSelection: false
		description:      "Create a selection that unions clauses."
		schemaOrder:      3
		parserOrder:      3
		pythonOrder:      2
	},
]

typeExpressions: [string]: model.#ShapeExpression
typeExpressions: {
	paramReference: {kind: "template", parts: [{literal: "$"}, {primitive: "string"}], completion: "plain", schemaAdapter: "open-string"}
	valueKind: {kind: "literal", value: "value"}
	nullValue: {kind: "primitive", type: "null"}
	stringValue: {kind: "primitive", type: "string"}
	numberValue: {kind: "primitive", type: "number"}
	booleanValue: {kind: "primitive", type: "boolean"}
	literalValues: {
		kind: "union"
		members: ["nullValue", "stringValue", "numberValue", "booleanValue"]
		schemaAdapter: "primitive-type-array"
	}
	literalReference: {kind: "named", name: "ParamLiteral"}
	referenceReference: {kind: "named", name: "ParamRef"}
	literalOrReference: {kind: "union", members: ["literalReference", "referenceReference"]}
	valueArray: {kind: "array", items: "literalOrReference"}
	paramValues: {kind: "union", members: ["literalReference", "valueArray"]}
	valueReference: {kind: "named", name: "ParamValue"}
	referenceArray: {kind: "array", items: "referenceReference"}
	includedReferences: {kind: "union", members: ["referenceReference", "referenceArray"]}
	paramReferenceContract: {kind: "named", name: "Param"}
	dateReferenceContract: {kind: "named", name: "ParamDate"}
	selectionReference: {kind: "named", name: "Selection"}
	paramDefinitions: {kind: "union", members: ["valueReference", "paramReferenceContract", "dateReferenceContract", "selectionReference"]}
}
typeExpressions: selectionKinds: {

	kind: "enum"
	values: [for position in list.Range(0, len(_factoryRecords), 1) for factory in _factoryRecords if factory.schemaOrder == position {factory.name}]
}
contracts: [...model.#ShapeContract] & [
	{
		name:        "ParamRef"
		description: "A parameter reference written as a dollar sign followed by its name."
		kind:        "alias"
		expression:  "paramReference"
	},
	{
		name:        "ParamBase"
		description: "Base properties shared by Param definitions."
		wire:        false
		properties: [
			{
				name:        "select"
				description: "The type of reactive parameter. One of:\n- `\"value\"` (default) for a standard `Param`\n- `\"intersect\"` for a `Selection` that intersects clauses (logical \"and\")\n- `\"union\"` for a `Selection` that unions clauses (logical \"or\")\n- `\"single\"` for a `Selection` that retains a single clause only\n- `\"crossfilter\"` for a cross-filtered intersection `Selection`"
				type:        "valueKind"
			}
		]
	},
	{
		name:        "Param"
		description: "A Param definition."
		extends: ["ParamBase"]
		properties: [{name: "value", description: "The initial parameter value.", required: true, type: "valueReference"}]
	},
	{
		name:        "ParamDate"
		description: "A Date-valued Param definition."
		extends: ["ParamBase"]
		properties: [
			{
				name:        "date"
				description: "The initial parameter value as an ISO date/time string to be parsed to a Date object."
				required:    true
				type:        "stringValue"
			}
		]
	},
	{name: "ParamLiteral", description: "Literal Param values.", kind: "alias", expression: "literalValues"},
	{name: "ParamValue", description: "Valid Param values.", kind: "alias", expression: "paramValues"},
	{
		name:        "Selection"
		description: "A Selection definition."
		properties: [
			{
				name:        "select"
				description: "The type of reactive parameter. One of:\n- `\"value\"` (default) for a standard `Param`\n- `\"intersect\"` for a `Selection` that intersects clauses (logical \"and\")\n- `\"union\"` for a `Selection` that unions clauses (logical \"or\")\n- `\"single\"` for a `Selection` that retains a single clause only\n- `\"crossfilter\"` for a cross-filtered intersection `Selection`"
				required:    true
				type:        "selectionKinds"
			},
			{
				name:        "cross"
				description: "A flag for cross-filtering, where selections made in a plot filter others but not oneself (default `false`, except for `crossfilter` selections)."
				type:        "booleanValue"
			},
			{
				name:        "empty"
				description: "A flag for setting an initial empty selection state. If true, a selection with no clauses corresponds to an empty selection with no records. If false, a selection with no clauses selects all values."
				type:        "booleanValue"
			},
			{
				name:        "include"
				description: "Upstream selections whose clauses should be included as part of this selection. Any clauses or activations published to the upstream selections will be relayed to this selection."
				type:        "includedReferences"
			},
		]
	},
	{
		name:        "ParamDefinition"
		description: "A Param or Selection definition."
		kind:        "alias"
		expression:  "paramDefinitions"
	},
]
contractIndex: {for contract in contracts {(contract.name): contract}}
publicContracts: contracts
selectionFactories: [for position in list.Range(0, len(_factoryRecords), 1) for factory in _factoryRecords if factory.pythonOrder == position {
	name:        factory.name
	wire:        factory.name
	description: factory.description
	options: [for property in contractIndex.Selection.properties if property.name != "select" {property}]
}]
parserKinds: [paramDefault, for position in list.Range(0, len(_factoryRecords), 1) for factory in _factoryRecords if factory.parserOrder == position {factory.name}]
paramDefault: typeExpressions.valueKind.value
selectionDefaultName: [for factory in _factoryRecords if factory.defaultSelection {factory.name}][0]
coreExports: ["Param", "Selection"]
runtimeNames: [...{name!: model.#Name, value!: model.#Name}] & [
	{name: "SELECTION", value: "selection"},
	{name: "PARAMREF", value: "paramref"},
	{name: "COLUMPARAMREF", value: "columnparamref"},
	{name: "PARAM", value: "param"},
	{name: "INCLUDE", value: "include"},
	{name: "SELECT", value: "select"},
	{name: "VALUE", value: paramDefault},
	for factory in _factoryRecords {{name: model.#Name & "\(strings.ToUpper(factory.name))", value: factory.name}},
]
checks: {
	factoryDefault: true & (len([for factory in _factoryRecords if factory.defaultSelection {factory.name}]) == 1)
	factoryNames: true & list.UniqueItems([for factory in _factoryRecords {factory.name}])
	for target in ["schemaOrder", "parserOrder", "pythonOrder"] {
		(target): true & list.UniqueItems([for factory in _factoryRecords {factory[target]}])
		for factory in _factoryRecords {"\(target)_\(factory.name)": int & >=0 & <len(_factoryRecords) & factory[target]}
	}
}
