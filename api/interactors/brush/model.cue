package brushinteractors

import (
	"idl.uw.edu/mosaic/api/model"
	interactorRender "idl.uw.edu/mosaic/api/interactors/render:interactorrender"
)

contracts: [...model.#ShapeContract] & [
	{
		name:        "BrushStyles"
		description: "Styles for rectangular selection brushes."
		properties: [
			{name: "opacity", description: "The overall opacity of the brush rectangle.", type: "number"},
			{name: "fillOpacity", description: "The fill opacity of the brush rectangle.", type: "number"},
			{name: "strokeOpacity", description: "The stroke opacity of the brush rectangle.", type: "number"},
			{name: "fill", description: "The fill color of the brush rectangle.", type: "string"},
			{name: "stroke", description: "The stroke color of the brush rectangle.", type: "string"},
			{name: "strokeDasharray", description: "The stroke dash array of the brush rectangle.", type: "string"},
		]
	},
	{
		name:        "Interval1DOptions"
		description: "Options for 1D interval interactors."
		wire:        false
		properties: [
			{
				name:        "as"
				description: "The output selection. A clause of the form `field BETWEEN lo AND hi` is added for the currently selected interval [lo, hi]."
				required:    true
				type:        "paramRef"
			},
			{
				name:        "field"
				description: "The name of the field (database column) over which the interval selection should be defined. If unspecified, the  channel field of the first valid prior mark definition is used."
				type:        "string"
			},
			{
				name:        "pixelSize"
				description: "The size of an interactive pixel (default `1`). Larger pixel sizes reduce the brush resolution, which can reduce the size of pre-aggregated materialized views."
				type:        "number"
			},
			{
				name:        "peers"
				description: "A flag indicating if peer (sibling) marks are excluded when cross-filtering (default `true`). If set, peer marks will not be filtered by this interactor's selection in cross-filtering setups."
				type:        "boolean"
			},
			{name: "brush", description: "CSS styles for the brush (SVG `rect`) element.", type: "brushStyles"},
		]
	},
	{
		name:        "IntervalX"
		description: "An intervalX interactor."
		extends: [{name: "Interval1DOptions", operator: "all"}]
		properties: [
			{
				name:        "select"
				description: "Select a continuous 1D interval selection over the `x` scale domain."
				required:    true
				type:        "intervalXSelect"
			}
		]
	},
	{
		name:        "IntervalY"
		description: "An intervalY interactor."
		extends: [{name: "Interval1DOptions", operator: "all"}]
		properties: [
			{
				name:        "select"
				description: "Select a continuous 1D interval selection over the `y` scale domain."
				required:    true
				type:        "intervalYSelect"
			}
		]
	},
	{
		name:        "Interval2DOptions"
		description: "Options for 2D interval interactors."
		wire:        false
		properties: [
			{
				name:        "as"
				description: "The output selection. A clause of the form `(xfield BETWEEN x1 AND x2) AND (yfield BETWEEN y1 AND y2)` is added for the currently selected intervals."
				required:    true
				type:        "paramRef"
			},
			{
				name:        "xfield"
				description: "The name of the field (database column) over which the `x`-component of the interval selection should be defined. If unspecified, the `x` channel field of the first valid prior mark definition is used."
				type:        "string"
			},
			{
				name:        "yfield"
				description: "The name of the field (database column) over which the `y`-component of the interval selection should be defined. If unspecified, the `y` channel field of the first valid prior mark definition is used."
				type:        "string"
			},
			{
				name:        "pixelSize"
				description: "The size of an interactive pixel (default `1`). Larger pixel sizes reduce the brush resolution, which can reduce the size of pre-aggregated materialized views."
				type:        "number"
			},
			{
				name:        "peers"
				description: "A flag indicating if peer (sibling) marks are excluded when cross-filtering (default `true`). If set, peer marks will not be filtered by this interactor's selection in cross-filtering setups."
				type:        "boolean"
			},
			{name: "brush", description: "CSS styles for the brush (SVG `rect`) element.", type: "brushStyles"},
		]
	},
	{
		name:        "IntervalXY"
		description: "An intervalXY interactor."
		extends: [{name: "Interval2DOptions", operator: "all"}]
		properties: [
			{
				name:        "select"
				description: "Select a continuous 2D interval selection over the `x` and `y` scale domains."
				required:    true
				type:        "intervalXYSelect"
			}
		]
	},
	{
		name:        "RegionOptions"
		description: "Options for region interactors."
		wire:        false
		properties: [
			{
				name:        "as"
				description: "The output selection. A clause of the form `(field = value1) OR (field = value2) ...` is added for the currently selected values."
				required:    true
				type:        "paramRef"
			},
			{
				name:        "channels"
				description: "The encoding channels over which to select values. For a selected mark, selection clauses will cover the backing data fields for each channel."
				required:    true
				type:        "strings"
			},
			{
				name:        "peers"
				description: "A flag indicating if peer (sibling) marks are excluded when cross-filtering (default `true`). If set, peer marks will not be filtered by this interactor's selection in cross-filtering setups."
				type:        "boolean"
			},
			{name: "brush", description: "CSS styles for the brush (SVG `rect`) element.", type: "brushStyles"},
		]
	},
	{
		name:        "Region"
		description: "A rectangular region interactor."
		extends: [{name: "RegionOptions", operator: "all"}]
		properties: [
			{
				name:        "select"
				description: "Select aspects of individual marks within a 2D range."
				required:    true
				type:        "regionSelect"
			}
		]
	},
]

typeExpressions: {[string]: model.#ShapeExpression} & {
	number: {kind: "primitive", type: "number"}
	string: {kind: "primitive", type: "string"}
	paramRef: {kind: "named", name: "ParamRef"}
	boolean: {kind: "primitive", type: "boolean"}
	brushStyles: {kind: "named", name: "BrushStyles"}
	intervalXSelect: {kind: "literal", value: "intervalX"}
	intervalYSelect: {kind: "literal", value: "intervalY"}
	intervalXYSelect: {kind: "literal", value: "intervalXY"}
	strings: {kind: "array", items: "string"}
	regionSelect: {kind: "literal", value: "region"}
}

declarationFiles: [...interactorRender.#DeclarationFile] & [
	{path: "packages/vgplot/spec/src/spec/interactors/BrushStyles.ts", imports: [], contracts: ["BrushStyles"]},
	{
		path: "packages/vgplot/spec/src/spec/interactors/Interval1D.ts"
		imports: [{source: "../Param.js", names: ["ParamRef"]}, {source: "./BrushStyles.js", names: ["BrushStyles"]}]
		contracts: ["Interval1DOptions", "IntervalX", "IntervalY"]
	},
	{
		path: "packages/vgplot/spec/src/spec/interactors/Interval2D.ts"
		imports: [{source: "../Param.js", names: ["ParamRef"]}, {source: "./BrushStyles.js", names: ["BrushStyles"]}]
		contracts: ["Interval2DOptions", "IntervalXY"]
	},
	{
		path: "packages/vgplot/spec/src/spec/interactors/Region.ts"
		imports: [{source: "../Param.js", names: ["ParamRef"]}, {source: "./BrushStyles.js", names: ["BrushStyles"]}]
		contracts: ["RegionOptions", "Region"]
	},
]

interactors: [...interactorRender.#Interactor] & [
	{
		contract:    "IntervalX"
		wrapperSlot: "intervalX-3"
		group:       "interval"
		javascript: {profile: "selection", runtimeClass: "Interval1D", forced: channel: "x"}
		python: {arguments: [{wire: "as"}, {wire: "field"}, {wire: "pixelSize"}, {wire: "peers"}, {wire: "brush"}], extras: false}
	},
	{
		contract:    "IntervalY"
		wrapperSlot: "intervalY-4"
		group:       "interval"
		javascript: {profile: "selection", runtimeClass: "Interval1D", forced: channel: "y"}
		python: {arguments: [{wire: "as"}, {wire: "field"}, {wire: "pixelSize"}, {wire: "peers"}, {wire: "brush"}], extras: false}
	},
	{
		contract:    "IntervalXY"
		wrapperSlot: "intervalXY-5"
		group:       "interval"
		javascript: {profile: "selection", runtimeClass: "Interval2D"}
		python: {
			arguments: [{wire: "as"}, {wire: "xfield"}, {wire: "yfield"}, {wire: "pixelSize"}, {wire: "peers"}, {wire: "brush"}]
			extras: false
		}
	},
	{
		contract:    "Region"
		wrapperSlot: "region-9"
		group:       "region"
		javascript: {profile: "selection", runtimeClass: "Region"}
		python: {arguments: [{wire: "as"}, {wire: "channels"}, {wire: "peers"}, {wire: "brush"}], extras: false}
	},
]
