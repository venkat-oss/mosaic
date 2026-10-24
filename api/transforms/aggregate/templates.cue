package aggregate

import (
	"encoding/json"
	"encoding/yaml"
	"list"
	"strings"
	"idl.uw.edu/mosaic/api/render"
)

#AggregateExample: {
	name!: string & !=""
	api!:  string & !=""
	mode:  *"grouped" | "distinct" | "windowed" | "count-all"
	arguments!: [...(string | number)]
}
aggregateExampleQuery: "SELECT category, x, x * 2 AS y, 'v' || x::VARCHAR AS label FROM (VALUES ('A',1),('A',2),('A',2),('A',3),('A',4),('A',5),('B',2),('B',3),('B',3),('B',4),('B',5),('B',6)) AS t(category,x)"
aggregateExamples: [...#AggregateExample] & [{name: "avg", api: "avg", arguments: ["x"]}]
exampleChecks: {
	uniqueNames: true & list.UniqueItems([for example in aggregateExamples {example.name}])

	values: [for example in aggregateExamples {
		let APIs = [for api in list.Concat([apis, jsOnlyAPIs]) if api.key == example.api {api}]
		true & (len(APIs) == 1)
		for api in APIs {
			if example.mode == "count-all" {true & (api.key == "count"), true & (len(example.arguments) == 0)}
			if example.mode != "count-all" {
				if api.signature == "binary" || api.signature == "quantile" {true & (len(example.arguments) == 2)}
				if api.signature == "unary" || api.signature == "count" {true & (len(example.arguments) == 1)}
			}
		}
	}]
}

#AggregateExampleProjection: {
	example!: #AggregateExample
	let Item = example
	api: [for candidate in list.Concat([apis, jsOnlyAPIs]) if candidate.key == Item.api {candidate}][0]
	let API = api
	textMark: list.Contains(["arrayAgg", "stringAgg"], API.key)
	wire:     API.targets.wire
	python:   API.targets.python
	windowed: Item.mode == "windowed"
	argumentAdmission: {
		values: Item.arguments
		if Item.mode == "count-all" {values: []}
		if Item.mode != "count-all" {
			if API.signature == "unary" || API.signature == "count" {values: [string]}
			if API.signature == "binary" {values: [string, string]}
			if API.signature == "quantile" {values: [string, string | number]}
		}
	}
	wireExpression: {
		(API.key): _
		if Item.mode == "count-all" {(API.key): null}
		if Item.mode != "count-all" {
			if len(Item.arguments) == 1 {(API.key): Item.arguments[0]}
			if len(Item.arguments) != 1 {(API.key): Item.arguments}
		}
		if Item.mode == "distinct" {distinct: true}
		if windowed {orderby: "x", partitionby: "category", rows: [1, 0]}
	}
	let Expression = wireExpression
	spec: {
		data: aggregate_data: {type: "table", query: aggregateExampleQuery}
		plot: [{
			data: from: "aggregate_data"
			if windowed {mark: "dot", x: "x", y: Expression, fill: "category"}
			if !windowed {mark: "barY", x: "category", y: Expression}
		}]
	}
	jsExpression: "vg.\(API.key)(\(strings.Join([for argumentValue in Item.arguments {(render.#TypeScriptLiteral & {value: argumentValue}).text}], ", ")))" + strings.Join([
		if Item.mode == "distinct" {".distinct()"},
		if windowed {".orderby('x').partitionby('category').frame(vg.frameRows([1, 0]))"},
	], "")
	pythonArguments: strings.Join([for value in Item.arguments {json.Marshal(value)}, if Item.mode == "count-all" {"cast(Any, None)"}], ", ")
	pythonOptions: strings.Join([if Item.mode == "distinct" {", distinct=True"}, if windowed {", orderby=\"x\", partitionby=\"category\", rows=[1, 0]"}], "")
	pythonExpression?: string
	if python {pythonExpression: "vg.\(API.python)(\(pythonArguments)\(pythonOptions))"}
	jsMark: string
	if textMark {jsMark: "vg.text(vg.from('aggregate_data'), {x: 'category', text: \(jsExpression)})"}
	if !textMark {
		if windowed {jsMark: "vg.dot(vg.from('aggregate_data'), {x: 'x', y: \(jsExpression), fill: 'category'})"}
		if !windowed {jsMark: "vg.barY(vg.from('aggregate_data'), {x: 'category', y: \(jsExpression)})"}
	}
	if python {
		pythonMark: string
		if windowed {pythonMark: "vg.dot(\"aggregate_data\", x=\"x\", y=\(pythonExpression), fill=\"category\")"}
		if !windowed {pythonMark: "vg.bar_y(\"aggregate_data\", x=\"category\", y=\(pythonExpression))"}
	}
}
exampleProjections: {for item in aggregateExamples {(item.name): #AggregateExampleProjection & {example: item}}}

_aggregateTemplateFiles: {
	for example in aggregateExamples {
		let Projection = exampleProjections[example.name]
		if Projection.wire {
			"\(example.name).json": json.Indent(json.Marshal(Projection.spec), "", "  ") + "\n"
			"\(example.name).yaml": yaml.Marshal(Projection.spec)
		}
		"\(example.name).js": """
			import * as vg from '@uwdata/vgplot';

			await vg.coordinator().exec(vg.createTable('aggregate_data', \((render.#TypeScriptLiteral & {value: aggregateExampleQuery}).text)));

			export default vg.plot(\(Projection.jsMark));

			"""
		if Projection.python {
			"\(example.name).py": """
				from __future__ import annotations

				\(strings.Join([if example.mode == "count-all" {"from typing import Any, cast\n\n"}], ""))import vgplot as vg

				view = vg.spec(
				    data={"aggregate_data": vg.table(\(json.Marshal(aggregateExampleQuery)))},
				    view=vg.plot(\(Projection.pythonMark)),
				)

				"""
		}
	}
}
templateFiles: {
	for name, content in _aggregateTemplateFiles {
		"templates/transforms/aggregate/\(name)": content
	}
}
