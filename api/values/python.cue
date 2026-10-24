package values

import (
	"encoding/json"
	"list"
	"strings"
)

#PythonReference: "str" | "float" | "bool" | "Any" | "date" | "DataDef" | "_ParamBase" | "FromRef" | "IntoFrame"
#PythonType: {
	kind:  "ref"
	name!: #PythonReference
} | {
	kind: "none"
} | {
	kind: "union"
	members!: [#PythonType, #PythonType, ...#PythonType]
} | {
	kind:  "generic"
	name!: "dict"
	arguments!: [#PythonType, #PythonType]
} | {
	kind:  "generic"
	name!: "Sequence"
	arguments!: [#PythonType]
} | {
	kind: "tuple"
	items!: [#PythonType, ...#PythonType]
}

#PythonAliasName: "ChannelValue" | "AttrValue" | "MarkData" | "TransformArg" | "MimeBundle"
#PythonAlias: {
	name!:         #PythonAliasName
	description!:  string & !=""
	explicitAlias: *false | bool
	type!:         #PythonType
}

#RenderPythonType: {
	type!: #PythonType
	let T = type
	if T.kind == "ref" {text: T.name}
	if T.kind == "none" {text: "None"}
	if T.kind == "union" {
		text: strings.Join([for member in T.members {( #RenderPythonType & {type: member}).text}], " | ")
	}
	if T.kind == "generic" {
		text: "\(T.name)[\(strings.Join([for argument in T.arguments {( #RenderPythonType & {type: argument}).text}], ", "))]"
	}
	if T.kind == "tuple" {
		text: "tuple[\(strings.Join([for item in T.items {( #RenderPythonType & {type: item}).text}], ", "))]"
	}
}

_channelValue: #PythonType & {
	kind: "union"
	members: [
		{kind: "ref", name: "str"},
		{kind: "ref", name: "float"},
		{kind: "ref", name: "bool"},
		{kind: "ref", name: "date"},
		{kind: "generic", name: "dict", arguments: [{kind: "ref", name: "str"}, {kind: "ref", name: "Any"}]},
		{kind: "generic", name: "Sequence", arguments: [{kind: "ref", name: "Any"}]},
		{kind: "ref", name: "_ParamBase"},
		{kind: "none"},
	]
}

pythonAliases: [
	#PythonAlias & {name: "ChannelValue", description: "Values for mark channels, including native dates and parameter objects.", type: _channelValue},
	#PythonAlias & {name: "AttrValue", description: "Values for plot attributes, preserving explicit None and native date objects.", type: _channelValue},
	#PythonAlias & {
		name:          "MarkData"
		description:   "Named sources, source helpers, native frames, or inline values used as mark data."
		explicitAlias: true
		type: {
			kind: "union"
			members: [
				{kind: "ref", name: "str"},
				{kind: "ref", name: "FromRef"},
				{kind: "ref", name: "DataDef"},
				{kind: "ref", name: "IntoFrame"},
				{kind: "generic", name: "dict", arguments: [{kind: "ref", name: "str"}, {kind: "ref", name: "Any"}]},
				{kind: "generic", name: "Sequence", arguments: [{kind: "ref", name: "Any"}]},
				{kind: "ref", name: "_ParamBase"},
				{kind: "none"},
			]
		}
	},
	#PythonAlias & {
		name:        "TransformArg"
		description: "Scalar, expression, or parameter arguments accepted by Python transform helpers."
		type: {
			kind: "union"
			members: [
				{kind: "ref", name: "str"},
				{kind: "ref", name: "float"},
				{kind: "ref", name: "bool"},
				{kind: "generic", name: "dict", arguments: [{kind: "ref", name: "str"}, {kind: "ref", name: "Any"}]},
				{kind: "ref", name: "_ParamBase"},
			]
		}
	},
	#PythonAlias & {
		name:          "MimeBundle"
		description:   "A display MIME mapping, an accompanying metadata pair, or no bundle."
		explicitAlias: true
		type: {
			kind: "union"
			members: [
				{kind: "generic", name: "dict", arguments: [{kind: "ref", name: "str"}, {kind: "ref", name: "str"}]},
				{kind: "tuple", items: [
					{kind: "generic", name: "dict", arguments: [{kind: "ref", name: "str"}, {kind: "ref", name: "Any"}]},
					{kind: "generic", name: "dict", arguments: [{kind: "ref", name: "str"}, {kind: "ref", name: "Any"}]},
				]},
				{kind: "none"},
			]
		}
	},
]

pythonAdapters: [
	{reference: "date", description: "Dates stay native in channels and attributes; date parameters serialize as ISO date values."},
	{reference: "IntoFrame", description: "Native dataframes remain host objects and use caller variable names as table references."},
	{reference: "_ParamBase", description: "Runtime parameter objects resolve to named references through object identity."},
	{reference: "DataDef/FromRef", description: "Data definitions and source helpers retain their runtime classes and resolve named data references."},
	{reference: "UNSET", description: "The existing vgplot._types sentinel stays a singleton; omitted channels remain distinct from explicit None."},
	{reference: "unsupported", description: "Python value aliases exclude callback objects; native JavaScript callbacks use their separate target adapter."},
]

_pythonAliasLines: [for alias in pythonAliases {
	let Expression = (#RenderPythonType & {type: alias.type}).text
	let Description = json.Marshal(alias.description)
	if alias.explicitAlias {"\(alias.name): TypeAlias = \(Expression)\n\(Description)"}
	if !alias.explicitAlias {"\(alias.name) = \(Expression)\n\(Description)"}
}]

#PythonImportName: "Sequence" | "date" | "Any" | "TypeAlias" | "IntoFrame" | "DataDef" | "_ParamBase" | "FromRef"
#PythonImport: {
	module!: "collections.abc" | "datetime" | "typing" | "narwhals.typing" | ".data" | ".params" | ".plot"
	names!: [#PythonImportName, ...#PythonImportName]
}

pythonImports: [
	#PythonImport & {module: "collections.abc", names: ["Sequence"]},
	#PythonImport & {module: "datetime", names: ["date"]},
	#PythonImport & {module: "typing", names: ["Any", "TypeAlias"]},
	#PythonImport & {module: "narwhals.typing", names: ["IntoFrame"]},
	#PythonImport & {module: ".data", names: ["DataDef"]},
	#PythonImport & {module: ".params", names: ["_ParamBase"]},
	#PythonImport & {module: ".plot", names: ["FromRef"]},
]

_pythonExportNames: list.Concat([
	[for alias in pythonAliases {alias.name}],
	list.Concat([for item in pythonImports {item.names}]),
])

checks: {
	pythonAliasNames: true & list.UniqueItems([for alias in pythonAliases {alias.name}])
	pythonExportNames: true & list.UniqueItems(_pythonExportNames)
}

_pythonAdapterTemplate: """
	from __future__ import annotations

	from datetime import date

	import pyarrow as pa
	import vgplot as vg
	from vgplot._types import (
	    UNSET,
	    AttrValue,
	    ChannelValue,
	    MarkData,
	    MimeBundle,
	    TransformArg,
	)

	source: MarkData = pa.table({"value": [1, 2]})
	channel: ChannelValue = vg.param(date(2020, 1, 2))
	attribute: AttrValue = None
	transform: TransformArg = "value"
	mime: MimeBundle = {"text/plain": "Python native value adapters"}

	view = vg.spec(
	    view=vg.plot(
	        vg.dot(source, x=transform, y=channel, stroke=UNSET),
	        vg.color_label(attribute),
	    )
	)
	"""

pythonFiles: {
	"packages/vgplot/vgplot-python/vgplot/_type_contracts.py": """
		# Generated by pnpm generate:api from api/values. DO NOT EDIT.
		from __future__ import annotations

		\(strings.Join([for item in pythonImports {"from \(item.module) import \(strings.Join(item.names, ", "))"}], "\n"))


		\(strings.Join(_pythonAliasLines, "\n\n"))

		__all__ = \(json.Marshal(_pythonExportNames))

		"""
	"templates/values/python-adapters.py":                     _pythonAdapterTemplate
}
