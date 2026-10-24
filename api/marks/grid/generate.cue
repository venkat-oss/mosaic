package gridmarks

import (
	basic "idl.uw.edu/mosaic/api/marks/basic/model:basicmodel"
	familyRender "idl.uw.edu/mosaic/api/marks/render:markrender"
)

declarationFiles: [
	{
		"basename": "Raster"
		"imports": [
			"ParamRef",
			"ChannelValueSpec",
			"MarkData",
			"MarkOptions",
		]
		"contracts": [
			"GridInterpolate",
			"Grid2DOptions",
			"RasterOptions",
			"Raster",
			"Heatmap",
			"RasterTile",
		]
	},
	{
		"basename": "Contour"
		"imports": [
			"ParamRef",
			"MarkData",
			"MarkOptions",
			"Grid2DOptions",
		]
		"contracts": [
			"ContourOptions",
			"Contour",
		]
	},
	{
		"basename": "DenseLine"
		"imports": [
			"ParamRef",
			"ChannelValue",
			"MarkData",
			"RasterOptions",
		]
		"contracts": [
			"DenseLineOptions",
			"DenseLine",
		]
	},
	{
		"basename": "Density"
		"imports": [
			"ParamRef",
			"MarkOptions",
			"DotOptions",
			"TextStyles",
			"Grid2DOptions",
			"MarkData",
		]
		"contracts": [
			"Density2DOptions",
			"Density",
		]
		"ownership": "sections"
		"sections": [
			{
				"contract": "Density2DOptions"
				"id":       "Density2DOptions-7"
			},
			{
				"contract": "Density"
				"id":       "Density-8"
			},
		]
	},
]

marks: [
	{
		"name":         "density"
		"contract":     "Density"
		"runtimeClass": "Density2DMark"
		"runtimeType":  "dot"
		"profile":      "implicit"
		"jsSection":    "density-38"
	},
	{
		"name":         "denseLine"
		"contract":     "DenseLine"
		"runtimeClass": "DenseLineMark"
		"runtimeType":  "image"
		"profile":      "implicit"
		"jsSection":    "denseLine-39"
	},
	{
		"name":         "contour"
		"contract":     "Contour"
		"runtimeClass": "ContourMark"
		"runtimeType":  "geo"
		"profile":      "implicit"
		"jsSection":    "contour-40"
	},
	{
		"name":         "heatmap"
		"contract":     "Heatmap"
		"runtimeClass": "HeatmapMark"
		"runtimeType":  "image"
		"profile":      "implicit"
		"jsSection":    "heatmap-41"
	},
	{
		"name":         "raster"
		"contract":     "Raster"
		"runtimeClass": "RasterMark"
		"runtimeType":  "image"
		"profile":      "implicit"
		"jsSection":    "raster-42"
	},
	{
		"name":         "rasterTile"
		"contract":     "RasterTile"
		"runtimeClass": "RasterTileMark"
		"runtimeType":  "image"
		"profile":      "implicit"
		"jsSection":    "rasterTile-43"
	},
]

referenceGroups: [
	{
		"title": "Density 2D"
		"names": [
			"density"
		]
		"sections": {
			"js":     "js-Density-2D-11"
			"python": "python-Density-2D-42"
		}
	},
	{
		"title": "Dense Line"
		"names": [
			"denseLine"
		]
		"sections": {
			"js":     "js-Dense-Line-12"
			"python": "python-Dense-Line-43"
		}
	},
	{
		"title": "Contour"
		"names": [
			"contour"
		]
		"sections": {
			"js":     "js-Contour-8"
			"python": "python-Contour-39"
		}
	},
	{
		"title": "Heatmap"
		"names": [
			"heatmap"
		]
		"sections": {
			"js":     "js-Heatmap-17"
			"python": "python-Heatmap-48"
		}
	},
	{
		"title": "Raster"
		"names": [
			"raster",
			"rasterTile",
		]
		"sections": {
			"js":     "js-Raster-24"
			"python": "python-Raster-55"
		}
	},
]

let Contracts = contracts
let Supports = supportContracts
let Expressions = typeExpressions
let DeclarationFiles = declarationFiles
let Marks = marks
let Groups = referenceGroups
projection: familyRender.#MarkFamilyProjection & {
	identity: {slug: "grid"}
	contracts:        Contracts
	supportContracts: Supports
	typeExpressions:  Expressions
	baseContracts:    basic.contracts
	baseExpressions:  basic.typeExpressions
	baseImports: [for File in basic.declarationFiles for Name in File.contracts if ([for Contract in basic.contracts if Contract.name == Name {Contract.exported}])[0] {name: Name, owner: "basic", source: "./\(File.basename).js"}]
	externalReferences: basic.externalReferences
	declarationFiles:   DeclarationFiles
	marks:              Marks
	referenceGroups:    Groups
	starters: [for Example in examples {{id: Example.id, mark: Example.mark, kind: "shared"}}, for Example in nativeExamples {{id: Example.id, mark: Example.mark, kind: "javascript"}}]
	starterFiles: templateFiles
	referenceNotes: [{marks: ["rasterTile"], text: runtimeLimitations.tileGrid.text}, {marks: ["density"], text: runtimeLimitations.cellDomain.text}, {marks: [for Mark in Marks {Mark.name}], text: runtimeLimitations.nullInterpolation.text}]
}
checks:      projection.checks
shapeChecks: projection.shapeChecks
files: {for Path, Source in projection.files {(Path): Source}, for Path, Source in nativeFiles {(Path): Source}}
sections:       projection.sections
schemaFragment: projection.schemaFragment
pythonSymbols:  projection.pythonSymbols
