package density1d

import (
	"list"
	familyRender "idl.uw.edu/mosaic/api/marks/render:markrender"
	basic "idl.uw.edu/mosaic/api/marks/basic/model:basicmodel"
	connected "idl.uw.edu/mosaic/api/marks/connected/model:connectedmodel"
	annotation "idl.uw.edu/mosaic/api/marks/annotation/model:annotationmodel"
)

declarationFiles: [
	{
		"basename":  "Density"
		"ownership": "sections"
		"imports": [
			"ParamRef",
			"AreaXOptions",
			"AreaYOptions",
			"DotOptions",
			"LineXOptions",
			"LineYOptions",
			"MarkData",
			"TextOptions",
		]
		"contracts": [
			"Density1DOptions",
			"DensityAreaXOptions",
			"DensityAreaYOptions",
			"DensityLineXOptions",
			"DensityLineYOptions",
			"DensityDotXOptions",
			"DensityDotYOptions",
			"DensityTextXOptions",
			"DensityTextYOptions",
			"DensityXBase",
			"DensityYBase",
			"DensityX",
			"DensityY",
		]
		"sections": [
			{
				"contract": "Density1DOptions"
				"id":       "Density1DOptions-9"
			},
			{
				"contract": "DensityAreaXOptions"
				"id":       "DensityAreaXOptions-10"
			},
			{
				"contract": "DensityAreaYOptions"
				"id":       "DensityAreaYOptions-11"
			},
			{
				"contract": "DensityLineXOptions"
				"id":       "DensityLineXOptions-12"
			},
			{
				"contract": "DensityLineYOptions"
				"id":       "DensityLineYOptions-13"
			},
			{
				"contract": "DensityDotXOptions"
				"id":       "DensityDotXOptions-14"
			},
			{
				"contract": "DensityDotYOptions"
				"id":       "DensityDotYOptions-15"
			},
			{
				"contract": "DensityTextXOptions"
				"id":       "DensityTextXOptions-16"
			},
			{
				"contract": "DensityTextYOptions"
				"id":       "DensityTextYOptions-17"
			},
			{
				"contract": "DensityXBase"
				"id":       "DensityXBase-18"
			},
			{
				"contract": "DensityYBase"
				"id":       "DensityYBase-19"
			},
			{
				"contract": "DensityX"
				"id":       "DensityX-20"
			},
			{
				"contract": "DensityY"
				"id":       "DensityY-21"
			},
		]
	}
]

marks: [
	{
		"name":         "densityX"
		"contract":     "DensityX"
		"profile":      "explicit"
		"runtimeClass": "Density1DMark"
		"runtimeType":  "areaX"
		"branchKey":    "type"
		"jsSection":    "densityX-36"
	},
	{
		"name":         "densityY"
		"contract":     "DensityY"
		"profile":      "explicit"
		"runtimeClass": "Density1DMark"
		"runtimeType":  "areaY"
		"branchKey":    "type"
		"jsSection":    "densityY-37"
	},
]

referenceGroups: [
	{
		"title": "Density 1D"
		"names": [
			"densityX",
			"densityY",
		]
		"sections": {
			"js":     "js-Density-1D-10"
			"python": "python-Density-1D-41"
		}
	}
]

let Contracts = contracts
let Supports = supportContracts
let Expressions = typeExpressions
let DeclarationFiles = declarationFiles
let Marks = marks
let Groups = referenceGroups
_baseFamilies: [
	{owner: "basic", contracts: basic.contracts, declarationFiles: basic.declarationFiles},
	{owner: "connected", contracts: connected.contracts, declarationFiles: connected.declarationFiles},
	{owner: "annotation", contracts: list.Concat([annotation.contracts, annotation.supportContracts]), declarationFiles: annotation.declarationFiles},
]
projection: familyRender.#MarkFamilyProjection & {
	identity: {slug: "density1d"}
	contracts:        Contracts
	supportContracts: Supports
	typeExpressions:  Expressions
	baseContracts: list.Concat([for Family in _baseFamilies {Family.contracts}])
	baseExpressions: basic.typeExpressions & connected.typeExpressions & annotation.typeExpressions
	baseImports: [for Family in _baseFamilies for File in Family.declarationFiles for Name in File.contracts if ([for Contract in Family.contracts if Contract.name == Name {Contract.exported}])[0] {name: Name, owner: Family.owner, source: "./\(File.basename).js"}]
	externalReferences: basic.externalReferences
	declarationFiles:   DeclarationFiles
	marks:              Marks
	referenceGroups:    Groups
	starters: [for Example in examples {{id: Example.id, mark: Example.mark, kind: "shared"}}, for Example in nativeExamples {{id: Example.id, mark: Example.mark, kind: "javascript"}}]
	starterFiles: templateFiles
	referenceNotes: [
		{marks: ["densityX", "densityY"], text: "Density wrappers always construct areaX or areaY. An explicit type is interpreted as a queried column, causing a missing-column error. Use densityY without type for the supported declarative form; native densityX must also omit type."},
		{marks: ["densityX", "densityY"], text: "Density rendering requires a SQL-backed data source. Inline arrays remain admitted by the general declarative data type, but the retained density query engine rejects them. Native weight channels retain separate authoring applicability."},

	]
}
checks:         projection.checks
shapeChecks:    projection.shapeChecks
files:          projection.files
sections:       projection.sections
schemaFragment: projection.schemaFragment
pythonSymbols:  projection.pythonSymbols
