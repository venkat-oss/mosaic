package legends

import (
	"strings"
	"idl.uw.edu/mosaic/api/model"
)

#Name: model.#Name
#Option: {
	name!:        #Name
	kind!:        "string" | "number" | "ParamRef"
	description!: string & strings.MinRunes(1)
	scope:        *"shared" | "standalone"
	python!:      #Name
	pythonOrder:  *-1 | (int & >=0)
}
#API: {
	channel!:  "color" | "opacity" | "symbol"
	js!:       #Name
	python!:   #Name
	encoding!: "fill" | "opacity" | "symbol"
	field!:    "category" | "alpha"
}

apis: [...#API] & [
	{channel: "color", js: "colorLegend", python: "color_legend", encoding: "fill", field: "category"},
	{channel: "opacity", js: "opacityLegend", python: "opacity_legend", encoding: "opacity", field: "alpha"},
	{channel: "symbol", js: "symbolLegend", python: "symbol_legend", encoding: "symbol", field: "category"},
]

options: [...#Option] & [
	{
		name:        "as", kind: "ParamRef", python: "bind", pythonOrder: 1
		description: "The output selection. If specified, the legend is interactive, using a toggle interaction for discrete legends or an intervalX interaction for continuous legends."
	},
	{
		name:        "field", kind: "string", python: "field"
		description: "The data field over which to generate output selection clauses. If unspecified, a matching field is retrieved from existing plot marks."
	},
	{name: "label", kind: "string", python: "label", pythonOrder: 2, description: "The legend label."},
	{
		name:        "tickSize", kind: "number", python: "tick_size"
		description: "The size of legend ticks in a continuous legend, in pixels."
	},
	{
		name:        "marginTop", kind: "number", python: "margin_top"
		description: "The top margin of the legend component, in pixels."
	},
	{
		name:        "marginRight", kind: "number", python: "margin_right"
		description: "The right margin of the legend component, in pixels."
	},
	{
		name:        "marginBottom", kind: "number", python: "margin_bottom"
		description: "The bottom margin of the legend component, in pixels."
	},
	{
		name:        "marginLeft", kind: "number", python: "margin_left"
		description: "The left margin of the legend component, in pixels."
	},
	{name: "width", kind: "number", python: "width", description: "The width of a continuous legend, in pixels."},
	{name: "height", kind: "number", python: "height", description: "The height of a continuous legend, in pixels."},
	{
		name:        "columns", kind: "number", python: "columns", pythonOrder: 3
		description: "The number of columns to use to layout a discrete legend."
	},
	{
		name:        "for", kind: "string", python: "plot", pythonOrder: 0, scope: "standalone"
		description: "The name of the plot this legend applies to. A plot must include a name attribute to be referenced."
	},
]

pythonNames: {for option in options {"\(option.name)": option.python}}

docs: {
	title:                 "Legends"
	inlineDescription:     "A legend defined as an entry within a plot."
	standaloneDescription: "A legend defined as a top-level spec component."
	channelDescription:    "A legend of the given type."
	intro: """
		Legends visualize color, opacity, and symbol scales to aid chart interpretation.
		Legends can also serve as [interactors](./interactors) that filter or highlight plot content.
		"""
	interaction: """
		Discrete legends update selections with a toggle interaction. Continuous color and opacity legends use an interval brush when their scales support it.
		Continuous legends using threshold, quantize, or quantile scales do not support selection interactions.
		"""
	forwarding: "Additional options are passed to the [Observable Plot legend method](https://observablehq.com/plot/features/legends#legend-options)."
	js: """
		Use a legend as a directive inside `plot(...)` to include it in the plot.
		For a standalone legend, pass `for` with the plot name or its plot element; the function returns a Web element containing the legend.
		"""
	python: """
		Use a legend inside `vg.plot(...)` to include it in the plot.
		For a standalone legend, pass `\(pythonNames["for"])` with the plot name (`for_` is also accepted).
		Use `\(pythonNames["as"])` for the output selection (`as_` is also accepted). Other keyword options use snake_case names.
		Omitted values and explicit `None` are omitted from the specification. Extra keyword options override named arguments after conversion to specification names.
		"""
}

let String = string
let Number = number
#Types: {
	string:   String
	number:   Number
	ParamRef: String
}
#PlotLegend: {
	legend!: or([for api in apis {api.channel}])
	for option in options if option.scope == "shared" {
		"\(option.name)"?: #Types[option.kind]
	}
}
