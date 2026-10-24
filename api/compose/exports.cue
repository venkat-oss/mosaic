package compose

import (
	"strings"
	"list"
	"idl.uw.edu/mosaic/api/model"
)

#Export: {
	source!: string & !=""
	all:     *false | bool
	names!: [...model.#Name]
}
#JavaScriptExports: {
	contributions!: [...#PublicContribution]
	let Entries = list.Concat([for contribution in contributions {contribution.javascript}])
	exports: [...#Export] & [
		{
			"source": "@uwdata/mosaic-core"
			"names": list.Concat([[for item in Entries if item.group == "core" {item.name}], ["coordinator"]])
		},
		{
			"source": "@uwdata/mosaic-plot"
			"names": [
				"Fixed",
				for item in Entries if item.group == "column" if item.source == "@uwdata/mosaic-plot" {item.name},

			]
		},
		{
			"source": "@uwdata/mosaic-sql"
			"names": [
				"Query",
				for item in Entries if item.group == "column" if item.source == "@uwdata/mosaic-sql" {item.name},

				"literal",
				"cast",
				"float32",
				"float64",
				"int32",
				for item in Entries if item.group == "aggregate" {item.name},
				for item in Entries if item.group == "window" {item.name},
				"and",
				"or",
				"not",
				"eq",
				"neq",
				"gt",
				"gte",
				"lt",
				"lte",
				"isBetween",
				"isNotBetween",
				"isDistinct",
				"isNotDistinct",
				"isNull",
				"isNotNull",

				"createTable",
				"createSchema",
				"loadExtension",
				"loadCSV",
				"loadJSON",
				"loadObjects",
				"loadParquet",
				"loadSpatial",
			]
		},
		{
			"source": "./inputs.js"
			"names": [for item in Entries if item.group == "inputs" {item.name}]
		},
		{
			"source": "./layout/concat.js"
			"names": [for item in Entries if item.group == "concat" {item.name}]
		},
		{
			"source": "./layout/space.js"
			"names": [for item in Entries if item.group == "space" {item.name}]
		},
		{
			"source": "./plot/attributes.js"
			"all":    true
			"names": []
		},
		{
			"source": "./plot/data.js"
			"names": [for item in Entries if item.group == "data" {item.name}]
		},
		{
			"source": "./plot/marks.js"
			"all":    true
			"names": []
		},
		{
			"source": "./plot/interactors.js"
			"all":    true
			"names": []
		},
		{
			"source": "./plot/legends.js"
			"all":    true
			"names": []
		},
		{
			"source": "./plot/plot.js"
			"names": [
				"plot"
			]
		},
	]

	checks: names: true & list.UniqueItems(list.Concat([for entry in exports if !entry.all {entry.names}]))

	files: {
		"packages/vgplot/vgplot/src/api.js": strings.Join([for entry in exports {
			if entry.all {"export * from '\(entry.source)';"}
			if !entry.all {"export {\n\(strings.Join([for name in entry.names {"  \(name)"}], ",\n"))\n} from '\(entry.source)';"}
		}], "\n\n") + "\n"
	}

}
