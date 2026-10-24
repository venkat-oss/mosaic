package specmodel

import "idl.uw.edu/mosaic/api/model"

#Field: {name!: string & !="", required: *false | bool, description: *"" | string, type!: string & !=""}
#Contract: {name!: string & !="", kind: *"interface" | "interface" | "record", open: *false | bool, description!: string & !="", fields: *[] | [...#Field], extends: *[] | [...string], value?: string & !=""}
#Union: {name!: string & !="", description!: string & !="", members!: [...string & !=""], imports!: [...{source!: string, names!: [...string]}]}
contracts: [...#Contract] & [
	{
		name:        "Meta"
		open:        true
		description: "Specification metadata."
		fields: [
			{name: "title", description: "The specification title.", type: "text"},
			{name: "description", description: "A description of the specification content.", type: "text"},
			{name: "credit", description: "Credits or other acknowledgements.", type: "text"},
		]
	},
	{name: "Config", open: true, description: "Configuration options.", fields: [{name: "extensions", type: "extensions"}]},
	{name: "Data", kind: "record", description: "Top-level dataset definitions.", value: "DataDefinition"},
	{name: "Params", kind: "record", description: "Top-level Param and Selection definitions.", value: "ParamDefinition"},
	{
		name:        "SpecHead"
		description: "Top-level specification properties."
		fields: [
			{
				name:        "$schema"
				description: "A [JSON schema](http://json-schema.org/) URL for this specification, such as https://uwdata.github.io/mosaic/schema/latest.json. This property enables validation and autocomplete in editors with JSON schema support."
				type:        "schemaURI"
			},
			{name: "meta", description: "Specification metadata.", type: "Meta"},
			{name: "config", description: "Configuration options.", type: "Config"},
			{name: "data", description: "Dataset definitions.", type: "Data"},
			{name: "params", description: "Param and Selection definitions.", type: "Params"},
			{
				name:        "plotDefaults"
				description: "A default set of attributes to apply to all plot components."
				type:        "PlotAttributes"
			},
		]
	},
	{
		name:        "Plot"
		description: "A plot component."
		fields: [
			{
				name:        "plot"
				required:    true
				description: "An array of plot marks, interactors, or legends. Marks are graphical elements that make up plot layers. Unless otherwise configured, interactors will use the nearest previous mark as a basis for which data fields to select."
				type:        "plotLayers"
			}
		]
		extends: ["PlotAttributes"]
	},
]
unions: [...#Union] & [
	{
		name:        "SpecComponent"
		description: "A specification component such as a plot, input widget, or layout."
		members: [for Import in imports for Name in Import.names {Name}]
		imports: [
			{source: "./HConcat.js", names: ["HConcat"]},
			{source: "./VConcat.js", names: ["VConcat"]},
			{source: "./HSpace.js", names: ["HSpace"]},
			{source: "./VSpace.js", names: ["VSpace"]},
			{source: "./Input.js", names: ["Menu", "Search", "Slider", "Table"]},
			{source: "./Plot.js", names: ["Plot"]},
			{source: "./PlotLegend.js", names: ["Legend"]},
		]
	},
	{
		name:        "Component"
		description: "A plot component such as a plot, mark, input widget, or layout."
		members: ["SpecComponent", "PlotMark"]
		imports: []
	},
	{
		name:        "PlotMark"
		description: "A plot mark entry."
		members: [
			"Area",
			"AreaX",
			"AreaY",
			"Arrow",
			"AxisX",
			"AxisY",
			"AxisFx",
			"AxisFy",
			"GridX",
			"GridY",
			"GridFx",
			"GridFy",
			"BarX",
			"BarY",
			"Cell",
			"CellX",
			"CellY",
			"Contour",
			"DelaunayLink",
			"DelaunayMesh",
			"Hull",
			"Voronoi",
			"VoronoiMesh",
			"DenseLine",
			"Density",
			"DensityX",
			"DensityY",
			"Dot",
			"DotX",
			"DotY",
			"Circle",
			"Hexagon",
			"ErrorBarX",
			"ErrorBarY",
			"Frame",
			"Geo",
			"Graticule",
			"Sphere",
			"Hexbin",
			"Hexgrid",
			"Image",
			"Line",
			"LineX",
			"LineY",
			"Link",
			"Raster",
			"Heatmap",
			"RasterTile",
			"Rect",
			"RectX",
			"RectY",
			"RegressionY",
			"RuleX",
			"RuleY",
			"Text",
			"TextX",
			"TextY",
			"TickX",
			"TickY",
			"Vector",
			"VectorX",
			"VectorY",
			"Spike",
			"WaffleX",
			"WaffleY",
		]
		imports: [
			{source: "./marks/Area.js", names: ["Area", "AreaX", "AreaY"]},
			{source: "./marks/Arrow.js", names: ["Arrow"]},
			{source: "./marks/Axis.js", names: ["AxisFx", "AxisFy", "AxisX", "AxisY", "GridFx", "GridFy", "GridX", "GridY"]},
			{source: "./marks/Bar.js", names: ["BarX", "BarY"]},
			{source: "./marks/Cell.js", names: ["Cell", "CellX", "CellY"]},
			{source: "./marks/Contour.js", names: ["Contour"]},
			{source: "./marks/Delaunay.js", names: ["DelaunayLink", "DelaunayMesh", "Hull", "Voronoi", "VoronoiMesh"]},
			{source: "./marks/DenseLine.js", names: ["DenseLine"]},
			{source: "./marks/Density.js", names: ["Density", "DensityX", "DensityY"]},
			{source: "./marks/Dot.js", names: ["Circle", "Dot", "DotX", "DotY", "Hexagon"]},
			{source: "./marks/ErrorBar.js", names: ["ErrorBarX", "ErrorBarY"]},
			{source: "./marks/Frame.js", names: ["Frame"]},
			{source: "./marks/Geo.js", names: ["Geo", "Graticule", "Sphere"]},
			{source: "./marks/Hexbin.js", names: ["Hexbin"]},
			{source: "./marks/Hexgrid.js", names: ["Hexgrid"]},
			{source: "./marks/Image.js", names: ["Image"]},
			{source: "./marks/Line.js", names: ["Line", "LineX", "LineY"]},
			{source: "./marks/Link.js", names: ["Link"]},
			{source: "./marks/Raster.js", names: ["Heatmap", "Raster", "RasterTile"]},
			{source: "./marks/Rect.js", names: ["Rect", "RectX", "RectY"]},
			{source: "./marks/Regression.js", names: ["RegressionY"]},
			{source: "./marks/Rule.js", names: ["RuleX", "RuleY"]},
			{source: "./marks/Text.js", names: ["Text", "TextX", "TextY"]},
			{source: "./marks/Tick.js", names: ["TickX", "TickY"]},
			{source: "./marks/Vector.js", names: ["Spike", "Vector", "VectorX", "VectorY"]},
			{source: "./marks/Waffle.js", names: ["WaffleX", "WaffleY"]},
		]
	},
	{
		name:        "PlotInteractor"
		description: "A plot interactor entry."
		members: [
			"Highlight",
			"IntervalX",
			"IntervalY",
			"IntervalXY",
			"Nearest",
			"NearestX",
			"NearestY",
			"Pan",
			"PanX",
			"PanY",
			"PanZoom",
			"PanZoomX",
			"PanZoomY",
			"Region",
			"Toggle",
			"ToggleX",
			"ToggleY",
			"ToggleColor",
			"ToggleZ",
		]
		imports: [
			{source: "./interactors/Highlight.js", names: ["Highlight"]},
			{source: "./interactors/Interval1D.js", names: ["IntervalX", "IntervalY"]},
			{source: "./interactors/Interval2D.js", names: ["IntervalXY"]},
			{source: "./interactors/Nearest.js", names: ["Nearest", "NearestX", "NearestY"]},
			{source: "./interactors/PanZoom.js", names: ["Pan", "PanX", "PanY", "PanZoom", "PanZoomX", "PanZoomY"]},
			{source: "./interactors/Region.js", names: ["Region"]},
			{source: "./interactors/Toggle.js", names: ["Toggle", "ToggleColor", "ToggleX", "ToggleY", "ToggleZ"]},
		]
	},
	{
		name:        "ColumnTransform"
		description: "A data transform that maps one column value to another."
		members: ["Bin", "Column", "DateMonth", "DateMonthDay", "DateDay", "Centroid", "CentroidX", "CentroidY", "GeoJSON"]
		imports: []
	},
	{
		name:        "AggregateTransform"
		description: "An aggregate transform that combines multiple values."
		members: [
			"Argmax",
			"Argmin",
			"Avg",
			"Count",
			"Max",
			"Min",
			"First",
			"Last",
			"Median",
			"Mode",
			"Product",
			"Quantile",
			"Stddev",
			"StddevPop",
			"Sum",
			"Variance",
			"VarPop",
		]
		imports: []
	},
	{
		name:        "WindowTransform"
		description: "A window transform that operates over a sorted domain."
		members: [
			"RowNumber",
			"Rank",
			"DenseRank",
			"PercentRank",
			"CumeDist",
			"NTile",
			"Lag",
			"Lead",
			"FirstValue",
			"LastValue",
			"NthValue",
		]
		imports: []
	},
	{
		name:        "Transform"
		description: "A data transform."
		members: ["ColumnTransform", "AggregateTransform", "WindowTransform"]
		imports: []
	},
]
typeExpressions: {[string]: model.#ShapeExpression} & {
	text: {kind: "primitive", type: "string"}
	schemaURI: {kind: "primitive", type: "string"}
	textArray: {kind: "array", items: "text"}
	extensions: {kind: "union", members: ["text", "textArray"]}
	DataDefinition: {kind: "named", name: "DataDefinition"}
	ParamDefinition: {kind: "named", name: "ParamDefinition"}
	Meta: {kind: "named", name: "Meta"}
	Config: {kind: "named", name: "Config"}
	Data: {kind: "named", name: "Data"}
	Params: {kind: "named", name: "Params"}
	PlotAttributes: {kind: "named", name: "PlotAttributes"}
	PlotMark: {kind: "named", name: "PlotMark"}
	PlotInteractor: {kind: "named", name: "PlotInteractor"}
	PlotLegend: {kind: "named", name: "PlotLegend"}
	plotLayer: {kind: "union", members: ["PlotMark", "PlotInteractor", "PlotLegend"]}
	plotLayers: {kind: "array", items: "plotLayer"}
}
externalReferences: [...model.#ExternalReference] & [
	{name: "DataDefinition", owner: "spec", source: "./Data.js"},
	{name: "ParamDefinition", owner: "spec", source: "./Param.js"},
	{name: "Meta", owner: "spec", source: "./Meta.js"},
	{name: "Config", owner: "spec", source: "./Config.js"},
	{name: "Data", owner: "spec", source: "./Data.js"},
	{name: "Params", owner: "spec", source: "./Params.js"},
	{name: "PlotAttributes", owner: "spec", source: "./PlotAttributes.js"},
	{name: "PlotMark", owner: "spec", source: "./PlotMark.js"},
	{name: "PlotInteractor", owner: "spec", source: "./PlotInteractor.js"},
	{name: "PlotLegend", owner: "spec", source: "./PlotLegend.js"},
]
uriExpression:             "schemaURI"
specDescription:           "A declarative Mosaic specification."
plotAttributesDescription: "Plot attributes."
rootTypeModules: [
	"CSSStyles",
	"Data",
	"Expression",
	"HConcat",
	"HSpace",
	"Input",
	"Interval",
	"Param",
	"Plot",
	"PlotAttribute",
	"PlotFrom",
	"PlotInteractor",
	"PlotLegend",
	"PlotMark",
	"PlotTypes",
	"Spec",
	"Transform",
	"VConcat",
	"VSpace",
]
rootImports: {
	Spec: [
		{source: "./Data.js", names: ["DataDefinition"]},
		{source: "./Param.js", names: ["ParamDefinition", "ParamRef"]},
		for Import in unionIndex.SpecComponent.imports {Import},
		{source: "./PlotMark.js", names: ["PlotMark"]},
		{source: "./PlotAttribute.js", names: ["PlotAttributes"]},
	]
	Plot: [
		{source: "./PlotAttribute.js", names: ["PlotAttributes"]},
		{source: "./PlotInteractor.js", names: ["PlotInteractor"]},
		{source: "./PlotLegend.js", names: ["PlotLegend"]},
		{source: "./PlotMark.js", names: ["PlotMark"]},
	]
}

contractIndex: {for Contract in contracts {(Contract.name): Contract}}
unionIndex: {for Union in unions {(Union.name): Union}}
componentTypes: unionIndex.SpecComponent.members
markTypes:      unionIndex.PlotMark.members
