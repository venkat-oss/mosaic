package basicinputs

import (
	"encoding/json"
	"encoding/yaml"
	"list"
	"strings"
)

#InputExample: {
	name!:    string & =~"^[a-z][a-z0-9-]*$"
	input!:   "menu" | "search" | "slider"
	variant!: "scalar-options" | "object-options" | "table" | "list-any" | "list-all" | "contains" | "prefix" | "suffix" | "regexp" | "param" | "point" | "interval" | "filtered"
	if input == "menu" {variant: "scalar-options" | "object-options" | "table" | "list-any" | "list-all"}
	if input == "search" {variant: or(typeExpressions.SearchType.values)}
	if input == "slider" {variant: "param" | "filtered" | or(typeExpressions.SliderSelection.values)}
}
inputExamples: [...#InputExample] & [{name: "menu-table", input: "menu", variant: "table"}, {name: "slider-param", input: "slider", variant: "param"}, {name: "slider-filtered", input: "slider", variant: "filtered"}]
exampleQuery: "SELECT * FROM (VALUES (1, 'Alpha', ['Alpha','Beta']), (2, 'Beta', ['Beta']), (3, 'Gamma', ['Gamma'])) AS t(x, category, items)"
#ScalarLiteral: {
	value!: string | number | bool | null
	text:   string
	if value == null {text: "None"}
	if value == true {text: "True"}
	if value == false {text: "False"}
	if value != null && value != true && value != false {text: json.Marshal(value)}
}
#InputExampleProjection: {
	example!: #InputExample
	let Item = example
	contract: inputIndex[Item.input].contract
	options: {
		as:    "$binding"
		label: string
		field: string
		if Item.input == "menu" {
			label: "Category"
			if Item.variant != "list-any" && Item.variant != "list-all" {field: "category"}
			if Item.variant == "scalar-options" {options: ["Alpha", "Beta", "Gamma"]}
			if Item.variant == "object-options" {options: [{label: "First", value: "Alpha"}, {label: "Second", value: "Beta"}, {label: "Unset", value: null}]}
			if Item.variant == "table" {from: "input_data", column: "category"}
			if Item.variant == "list-any" || Item.variant == "list-all" {
				from: "input_data", column: "items", field: "items"
				if Item.variant == "list-any" {listMatch: "any"}
				if Item.variant == "list-all" {listMatch: "all"}
			}
		}
		if Item.input == "search" {
			label: "Search category", field: "category", from: "input_data", column: "category", type: Item.variant
		}
		if Item.input == "slider" {
			label: "Value", field: "x", from: "input_data", column: "x", step: 1, value: 2
			if Item.variant == "point" || Item.variant == "interval" {select: Item.variant}
			if Item.variant == "filtered" {select: typeExpressions.SliderSelection.values[0], filterBy: "$upstream"}
		}
	}
	let Options = options
	spec: {
		data: input_data: {type: "table", query: exampleQuery}
		params: binding: _
		if Item.variant == "param" {params: binding: 2}
		if Item.variant != "param" {params: binding: {select: "crossfilter"}}
		if Item.variant == "filtered" {
			params: upstream: {select: "intersect"}
			vconcat: [
				{input: "menu", as: "$upstream", field: "category", options: ["Alpha", "Beta", "Gamma"]},
				{input: Item.input, for key, value in Options {(key): value}},
			]
		}
		if Item.variant != "filtered" {
			for key, value in Options {(key): value}
			input: Item.input
		}
	}
	jsOptions: "{" + strings.Join([for key, value in Options {"\(json.Marshal(key)): " + strings.Join([if key == "as" {"binding"}, if key == "filterBy" {"upstream"}, if key != "as" && key != "filterBy" {json.Marshal(value)}], "")}], ", ") + "}"
	pythonOptions: strings.Join([for key, Value in Options {
		let PythonKey = {"as": "bind", "from": "source", "listMatch": "list_match", "filterBy": "filter_by"}
		let Name = strings.Join([if PythonKey[key] != _|_ {PythonKey[key]}, if PythonKey[key] == _|_ {key}], "")
		"\(Name)=" + strings.Join([
			if key == "as" {"binding"},
			if key == "filterBy" {"upstream"},
			if key == "options" {
				"[" + strings.Join([for Option in Value {
					if (Option & string) != _|_ {(#ScalarLiteral & {value: Option}).text}
					if (Option & {label: string, value: _}) != _|_ {"vg.option(\(json.Marshal(Option.label)), value=\((#ScalarLiteral & {value: Option.value}).text))"}
				}], ", ") + "]"
			},
			if key != "as" && key != "options" && key != "filterBy" {(#ScalarLiteral & {value: Value}).text},
		], "")
	}], ", ")
}
_exampleProjections: {for Example in inputExamples {(Example.name): #InputExampleProjection & {example: Example}}}
exampleProjections: json.Unmarshal(json.Marshal(_exampleProjections))
exampleChecks: {
	names: true & list.UniqueItems([for example in inputExamples {example.name}])
}
_inputTemplateFiles: {
	for example in inputExamples {
		let Projection = exampleProjections[example.name]
		"\(example.name).json": json.Indent(json.Marshal(Projection.spec), "", "  ") + "\n"
		"\(example.name).yaml": yaml.Marshal(Projection.spec)
		"\(example.name).js":   """
   import * as vg from '@uwdata/vgplot';

   await vg.coordinator().exec(vg.createTable('input_data', \(json.Marshal(exampleQuery))));
   const binding = \(strings.Join([if example.variant == "param" {"vg.Param.value(2)"}, if example.variant != "param" {"vg.Selection.crossfilter()"}], ""));

   \(strings.Join([if example.variant == "filtered" {"const upstream = vg.Selection.intersect();\n\nexport default vg.vconcat(\n  vg.menu({as: upstream, field: 'category', options: ['Alpha', 'Beta', 'Gamma']}),\n  vg.slider(" + Projection.jsOptions + ")\n);"}, if example.variant != "filtered" {"export default vg." + example.input + "(" + Projection.jsOptions + ");"}], ""))

   """
		"\(example.name).py":   """
   from __future__ import annotations

   import vgplot as vg

   \(strings.Join([if example.variant == "filtered" {"upstream = vg.selection.intersect()\n\n"}], ""))binding = \(strings.Join([if example.variant == "param" {"vg.param(2)"}, if example.variant != "param" {"vg.selection.crossfilter()"}], ""))
   view = vg.Spec(
       data={"input_data": vg.table(\(json.Marshal(exampleQuery)))},
       params={"binding": binding\(strings.Join([if example.variant == "filtered" {", \"upstream\": upstream"}], ""))},
       view=\(strings.Join([if example.variant == "filtered" {"vg.vconcat(vg.menu(bind=upstream, field='category', options=['Alpha', 'Beta', 'Gamma']), vg.slider(" + Projection.pythonOptions + "))"}, if example.variant != "filtered" {"vg." + example.input + "(" + Projection.pythonOptions + ")"}], "")),
   )

   """
	}
	"native-menu.js": """
		import * as vg from '@uwdata/vgplot';

		const container = document.createElement('section');
		const binding = vg.Param.value(1);
		export default vg.menu({element: container, as: binding, options: [1, 2], format: value => `Value ${value}`});

		"""
	"python-extensions.py": """
		from __future__ import annotations

		import vgplot as vg

		choice = vg.param("Alpha")
		enabled = vg.param(False)
		views = {
		    "select": vg.Spec(params={"choice": choice}, view=vg.select("Category", choice, ["Alpha", vg.option("Second", "Beta")], multiple=True)),
		    "checkbox": vg.Spec(params={"enabled": enabled}, view=vg.checkbox("Enabled", enabled)),
		    "generic": vg.Spec(params={"choice": choice}, view=vg.input("custom", label="Custom", bind=choice)),
		    "option": vg.Spec(params={"choice": choice}, view=vg.menu(options=[vg.option("Unset", None)], bind=choice)),
		}

		"""
}
templateFiles: {
	for name, content in _inputTemplateFiles {
		"templates/inputs/basic/\(name)": content
	}
}
