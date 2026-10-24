package basicinputs

import (
	"encoding/json"
	"list"
	"strings"
)

#PythonParameter: {
	name!:      "label" | "bind" | "min" | "max" | "step" | "value" | "options" | "multiple" | "source" | "column" | "filter_by" | "type" | "opts"
	annotation: *"Any" | "str" | "bool"
	kind:       *"positional-or-keyword" | "keyword-variadic"
	default:    *"none" | "required" | "false"
	if kind == "keyword-variadic" {name: "opts", annotation: "Any", default: "required"}
}
#PythonFactory: {
	name!:          "slider" | "select" | "checkbox" | "menu" | "search"
	contract!:      null | "Slider" | "Menu" | "Search"
	applicability!: "shared" | "python-extension"
	description!:   string & !=""
	parameters!: [...#PythonParameter]
	_parameterNames: true & list.UniqueItems([for parameter in parameters {parameter.name}])
	_parameterOrder: [for index, Parameter in parameters {
		if Parameter.kind == "keyword-variadic" {true & (index == len(parameters)-1)}
		if Parameter.kind == "positional-or-keyword" {
			true & (len([for previousIndex, Previous in parameters if previousIndex < index if Previous.kind == "keyword-variadic" {Previous.name}]) == 0)
			if Parameter.default == "required" {true & (len([for previousIndex, Previous in parameters if previousIndex < index if Previous.default != "required" {Previous.name}]) == 0)}
		}
	}]
	if applicability == "shared" {contract: !=null}
	if applicability == "python-extension" {contract: null, name: "select" | "checkbox"}
}

pythonFactories: [...#PythonFactory] & [
	{
		name:          "slider"
		contract:      "Slider"
		applicability: "shared"
		description:   "Create a slider view with required Python label and binding arguments."
		parameters: [
			{name: "label", annotation: "str", default: "required"},
			{name: "bind", default: "required"},
			{name: "min"},
			{name: "max"},
			{name: "step"},
			{name: "value"},
			{name: "opts", kind: "keyword-variadic"},
		]
	},
	{
		name:          "select"
		contract:      null
		applicability: "python-extension"
		description:   "Create a Python authoring extension view for a select input."
		parameters: [
			{name: "label", annotation: "str", default: "required"},
			{name: "bind", default: "required"},
			{name: "options", default: "required"},
			{name: "multiple", annotation: "bool", default: "false"},
			{name: "value"},
			{name: "opts", kind: "keyword-variadic"},
		]
	},
	{
		name:          "checkbox"
		contract:      null
		applicability: "python-extension"
		description:   "Create a Python authoring extension view for a checkbox input."
		parameters: [
			{name: "label", annotation: "str", default: "required"},
			{name: "bind", default: "required"},
			{name: "value", annotation: "bool", default: "false"},
			{name: "opts", kind: "keyword-variadic"},
		]
	},
	{
		name:          "menu"
		contract:      "Menu"
		applicability: "shared"
		description:   "Create a menu view from literal options or a backing table."
		parameters: [
			{name: "label"},
			{name: "bind"},
			{name: "options"},
			{name: "value"},
			{name: "source"},
			{name: "column"},
			{name: "filter_by"},
			{name: "opts", kind: "keyword-variadic"},
		]
	},
	{
		name:          "search"
		contract:      "Search"
		applicability: "shared"
		description:   "Create a text search view with an optional autocomplete source."
		parameters: [
			{name: "label"},
			{name: "bind"},
			{name: "source"},
			{name: "column"},
			{name: "filter_by"},
			{name: "type"},
			{name: "opts", kind: "keyword-variadic"},
		]
	},
]

pythonHelpers: {
	generic: {name: "input", description: "Create a view for any input kind without registering a parser extension.", kindAnnotation: "str", optionsAnnotation: "Any", returns: "View"}
	option: {name: "option", description: "Create a label/value option; an omitted value uses its label, while explicit None remains None.", annotation: "Any", default: "runtime-missing-sentinel", returns: "dict[str, Any]"}
}
checks: {
	pythonNames: true & list.UniqueItems([for factory in pythonFactories {factory.name}])
	aliasPython: true & list.UniqueItems([for alias in inputAliases {alias.python}])
	aliasWire: true & list.UniqueItems([for alias in inputAliases {alias.wire}])
	for factory in pythonFactories {
		"pythonParameters_\(factory.name)": true & list.UniqueItems([for parameter in factory.parameters {parameter.name}])
		if factory.applicability == "shared" {"pythonTarget_\(factory.name)": true & (inputIndex[factory.name].contract == factory.contract)}
	}
}
#PythonParameterProjection: {
	parameter!: #PythonParameter
	let P = parameter
	text: strings.Join([if P.kind == "keyword-variadic" {"**"}], "") + P.name + ": " + P.annotation + strings.Join([if P.default == "none" {" = None"}, if P.default == "false" {" = False"}], "")
}
_pythonFunctions: [for factory in pythonFactories {
	let Parameters = factory.parameters
	"def \(factory.name)(\(strings.Join([for Parameter in Parameters {(#PythonParameterProjection & {parameter: Parameter}).text}], ", "))) -> View:\n    return input(\(json.Marshal(factory.name)), " + strings.Join([for parameter in Parameters if parameter.kind == "positional-or-keyword" {"\(parameter.name)=\(parameter.name)"}, for parameter in Parameters if parameter.kind == "keyword-variadic" {"**\(parameter.name)"}], ", ") + ")\n"
}]
pythonFiles: {
	"packages/vgplot/vgplot-python/vgplot/_input_api.py": """
 # Generated by pnpm generate:api from api/inputs/basic. DO NOT EDIT.
 from __future__ import annotations

 from typing import TYPE_CHECKING, Any

 from . import _input_runtime

 if TYPE_CHECKING:
     from .spec import View

 _MISSING = _input_runtime._MISSING
 _INPUT_ALIASES = {\(strings.Join([for alias in inputAliases {"\(json.Marshal(alias.python)): \(json.Marshal(alias.wire))"}], ", "))}


 def \(pythonHelpers.generic.name)(kind: \(pythonHelpers.generic.kindAnnotation), **opts: \(pythonHelpers.generic.optionsAnnotation)) -> \(pythonHelpers.generic.returns):
     return _input_runtime.input_view(kind, opts, _INPUT_ALIASES)


 def \(pythonHelpers.option.name)(label: \(pythonHelpers.option.annotation), value: \(pythonHelpers.option.annotation) = _MISSING) -> \(pythonHelpers.option.returns):
     return {"label": label, "value": label if value is _MISSING else value}


 \(strings.Join(_pythonFunctions, "\n\n"))

 \(strings.Join([for name in [pythonHelpers.generic.name, pythonHelpers.option.name, for factory in pythonFactories {factory.name}] {"\(name).__module__ = \(json.Marshal("vgplot.plot"))"}], "\n"))
 """
}
