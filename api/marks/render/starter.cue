package markrender

import (
	"encoding/json"
	"encoding/yaml"
	"strings"
	pythonLanguage "idl.uw.edu/mosaic/api/languages/python"
)

#StarterValue: {
	value!: _
	parameters!: {...}
	reference: false | true
	if (value & string) != _|_ {reference: strings.HasPrefix(value, "$")}
	if (value & string) == _|_ {reference: false}
	if reference {key: strings.TrimPrefix(value, "$"), javascript: key, python: key}
	if !reference {javascript: json.Marshal(value), python: "json.loads(" + json.Marshal(json.Marshal(value)) + ")"}
}

#PlotStarter: {
	name!:  string
	table?: string
	query?: string
	rows?: [...]
	marks!: [...{name!: string, data!: "table" | "inline" | "none", options!: {...}}]
	attributes!: {...}
	parameters: *{} | {...}
	let Parameters = parameters
	let SourceQuery = query
	spec: {
		if query != _|_ {data: (table): {type: "table", query: SourceQuery}}
		if len(Parameters) > 0 {params: Parameters}
		plot: [for Mark in marks {{mark: Mark.name, if Mark.data == "table" {data: {from: table}}, if Mark.data == "inline" {data: rows}, for Key, Value in Mark.options {(Key): Value}}}]
		for Key, Value in attributes {(Key): Value}
	}
	jsDirectives: [
		for Mark in marks {"vg." + Mark.name + "(" + strings.Join([if Mark.data == "table" {"vg.from(" + json.Marshal(table) + "), "}, if Mark.data == "inline" {json.Marshal(rows) + ", "}], "") + "{" + strings.Join([for Key, Value in Mark.options {json.Marshal(Key) + ": " + (#StarterValue & {value: Value, parameters: Parameters}).javascript}], ", ") + "}" + ")"},
		for Key, Value in attributes {"vg." + Key + "(" + (#StarterValue & {value: Value, parameters: Parameters}).javascript + ")"},
	]
	pythonDirectives: [
		for Mark in marks {"vg." + (pythonLanguage.#Identifier & {wire: Mark.name}).name + "(" + strings.Join([if Mark.data == "table" {"vg.source(" + json.Marshal(table) + "), "}, if Mark.data == "inline" {"json.loads(" + json.Marshal(json.Marshal(rows)) + "), "}], "") + strings.Join([for Key, Value in Mark.options {(pythonLanguage.#Identifier & {wire: Key}).name + "=" + (#StarterValue & {value: Value, parameters: Parameters}).python}], ", ") + ")"},
		for Key, Value in attributes {"vg." + (pythonLanguage.#Identifier & {wire: Key}).name + "(" + (#StarterValue & {value: Value, parameters: Parameters}).python + ")"},
	]
	files: {
		"\(name).json": json.Indent(json.Marshal(spec), "", "  ") + "\n"
		"\(name).yaml": yaml.Marshal(spec)
		"\(name).js": "import * as vg from '@uwdata/vgplot';\n\n" + strings.Join([if query != _|_ {"await vg.coordinator().exec(vg.createTable(" + json.Marshal(table) + ", " + json.Marshal(query) + "));\n\n"}], "") + strings.Join([for Key, Value in Parameters {"export const " + Key + " = vg.Param.value(" + json.Marshal(Value) + ");\n"}], "") + "export default vg.plot(\n  " + strings.Join(jsDirectives, ",\n  ") + "\n);\n"
		"\(name).py": "from __future__ import annotations\n\nimport json\n\nimport vgplot as vg\n\n" + strings.Join([for Key, Value in Parameters {Key + " = vg.param(json.loads(" + json.Marshal(json.Marshal(Value)) + "))\n"}], "") + "view = vg.spec(\n    " + strings.Join([if len(Parameters) > 0 {"params={" + strings.Join([for Key, _ in Parameters {json.Marshal(Key) + ": " + Key}], ", ") + "},\n    "}], "") + strings.Join([if query != _|_ {"data={" + json.Marshal(table) + ": vg.table(" + json.Marshal(query) + ")},\n    "}], "") + "view=vg.plot(\n        " + strings.Join(pythonDirectives, ",\n        ") + ",\n    ),\n)\n"
	}
}
