package specmodel

import (
	"list"
)

componentParsers: [
	{key: "plot", constant: "PLOT", parser: "parsePlot", source: "../ast/PlotNode.js", pythonView: true},
	{key: "mark", constant: "MARK", parser: "parseTopLevelMark", source: "../ast/PlotNode.js", pythonView: false},
	{key: "legend", constant: "LEGEND", parser: "parseLegend", source: "../ast/PlotLegendNode.js", pythonView: false},
	{key: "input", constant: "INPUT", parser: "parseInput", source: "../ast/InputNode.js", pythonView: true},
]

pythonRootExports: [{name: "Spec", module: "spec"}, {name: "View", module: "spec"}, {name: "spec", module: "spec"}, {name: "plot", module: "plot"}]

#RuntimeParameter: {
	name!:      string & =~"^_?[A-Za-z][A-Za-z0-9_]*$"
	kind!:      "POSITIONAL_OR_KEYWORD" | "KEYWORD_ONLY" | "VAR_POSITIONAL" | "VAR_KEYWORD"
	annotation: *"" | string
	default:    *"required" | "required" | "None"
	if kind == "VAR_POSITIONAL" || kind == "VAR_KEYWORD" {default: "required"}
}
#RuntimeAPI: {
	name!:        "plot" | "spec" | "Spec" | "View" | "View.to_dict" | "View.to_json" | "View.show"
	module!:      "vgplot.plot" | "vgplot.spec"
	description!: string & !=""
	parameters!: [...#RuntimeParameter]
	returns!:     string & !=""
	callerScope!: bool
	checks: unique: true & list.UniqueItems([for p in parameters {p.name}])
}
pythonRuntimeAPIs: [...#RuntimeAPI] & [
	{name: "plot", module: "vgplot.plot", description: "Create a plot view from marks and directives.", callerScope: false, parameters: [
			{name: "items", kind: "VAR_POSITIONAL", annotation: "Mark | Directive | Mapping[str, Any]"},
			{name: "param_names", kind: "KEYWORD_ONLY", annotation: "dict[int, str] | None", default: "None"},
			{name: "kwargs", kind: "VAR_KEYWORD", annotation: "Any"},
	], returns: "View"
	},
	{name: "spec", module: "vgplot.spec", description: "Assemble a specification from a view, data sources, and parameters discovered in the caller scope.", callerScope: true, parameters: [
			{name: "args", kind: "VAR_POSITIONAL", annotation: "Any"},
			{name: "data", kind: "KEYWORD_ONLY", annotation: "dict[str, Any] | None", default: "None"},
			{name: "params", kind: "KEYWORD_ONLY", annotation: "dict[str, Any] | None", default: "None"},
			{name: "plotDefaults", kind: "KEYWORD_ONLY", annotation: "dict[str, Any] | None", default: "None"},
			{name: "plot_defaults", kind: "KEYWORD_ONLY", annotation: "dict[str, Any] | None", default: "None"},
			{name: "config", kind: "KEYWORD_ONLY", annotation: "dict[str, Any] | None", default: "None"},
			{name: "view", kind: "KEYWORD_ONLY", annotation: "dict[str, Any] | View | None", default: "None"},
			{name: "extra", kind: "VAR_KEYWORD", annotation: "Any"},
	], returns: "Spec"
	},
	{name: "Spec", module: "vgplot.spec", description: "A serializable specification with explicit data and parameter definitions.", callerScope: false, parameters: [
			{name: "data", kind: "KEYWORD_ONLY", annotation: "dict[str, Any] | None", default: "None"},
			{name: "data_names", kind: "KEYWORD_ONLY", annotation: "dict[int, str] | None", default: "None"},
			{name: "params", kind: "KEYWORD_ONLY", annotation: "dict[str, Any] | None", default: "None"},
			{name: "plotDefaults", kind: "KEYWORD_ONLY", annotation: "dict[str, Any] | None", default: "None"},
			{name: "plot_defaults", kind: "KEYWORD_ONLY", annotation: "dict[str, Any] | None", default: "None"},
			{name: "config", kind: "KEYWORD_ONLY", annotation: "dict[str, Any] | None", default: "None"},
			{name: "view", kind: "KEYWORD_ONLY", annotation: "dict[str, Any] | View | None", default: "None"},
			{name: "extra", kind: "VAR_KEYWORD", annotation: "Any"},
	], returns: "None"
	},
	{name: "View", module: "vgplot.spec", description: "A composable view that discovers data and parameters from its caller when serialized or displayed.", callerScope: false, parameters: [
			{name: "view", kind: "POSITIONAL_OR_KEYWORD", annotation: "dict[str, Any]"},
			{name: "data", kind: "KEYWORD_ONLY", annotation: "dict[str, Any] | None", default: "None"},
			{name: "plotDefaults", kind: "KEYWORD_ONLY", annotation: "dict[str, Any] | None", default: "None"},
			{name: "plot_defaults", kind: "KEYWORD_ONLY", annotation: "dict[str, Any] | None", default: "None"},
			{name: "config", kind: "KEYWORD_ONLY", annotation: "dict[str, Any] | None", default: "None"},
			{name: "extra", kind: "VAR_KEYWORD", annotation: "Any"},
	], returns: "None"
	},
	{name: "View.to_dict", module: "vgplot.spec", description: "Serialize a view using the explicit context or caller scope.", callerScope: true, parameters: [
			{name: "self", kind: "POSITIONAL_OR_KEYWORD"},
			{name: "_context", kind: "POSITIONAL_OR_KEYWORD", annotation: "dict[str, Any] | None", default: "None"},
	], returns: "dict[str, Any]"
	},
	{name: "View.to_json", module: "vgplot.spec", description: "Serialize a view as JSON using the explicit context or caller scope.", callerScope: true, parameters: [
			{name: "self", kind: "POSITIONAL_OR_KEYWORD"},
			{name: "_context", kind: "POSITIONAL_OR_KEYWORD", annotation: "dict[str, Any] | None", default: "None"},
			{name: "kwargs", kind: "VAR_KEYWORD", annotation: "Any"},
	], returns: "str"
	},
	{name: "View.show", module: "vgplot.spec", description: "Display a view after resolving data and parameters from its caller.", callerScope: true, parameters: [
			{name: "self", kind: "POSITIONAL_OR_KEYWORD"},
			{name: "con", kind: "POSITIONAL_OR_KEYWORD", annotation: "Any", default: "None"},
			{name: "data", kind: "POSITIONAL_OR_KEYWORD", annotation: "Any", default: "None"},
	], returns: "None"
	},
]

astKinds: [
	{constant: "SPEC", key: "spec"}, {constant: "LITERAL", key: "literal"}, {constant: "DATAREF", key: "dataref"}, {constant: "OPTIONS", key: "options"},
	{constant: "EXPRESSION", key: "expression"},
	for item in componentParsers {{constant: item.constant, key: item.key}},
	{constant: "ATTRIBUTE", key: "attribute"}, {constant: "TRANSFORM", key: "transform"}, {constant: "WINDOW_FRAME", key: "windowframe"}, {constant: "INTERACTOR", key: "interactor"}, {constant: "FIXED", key: "Fixed"},
]

publicChecks: {
	parserKeys: true & list.UniqueItems([for item in componentParsers {item.key}])
	astConstants: true & list.UniqueItems([for item in astKinds {item.constant}])
	runtimeAPIs: true & list.UniqueItems([for item in pythonRuntimeAPIs {item.name}])
	plotBinding: true & (componentParsers[0].key == contractIndex.Plot.fields[0].name)
}
