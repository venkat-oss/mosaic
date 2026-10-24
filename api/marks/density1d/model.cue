package density1d

import (
	"list"
	"idl.uw.edu/mosaic/api/model"
)

contracts: [...model.#ShapeContract] & [
	{
		name:                 "Density1DOptions"
		description:          "The Density1DOptions contract."
		documentationAdapter: "reference-only"
		wire:                 false
		properties: [
			{
				name:        "bandwidth"
				description: "The kernel density bandwidth for smoothing, in pixels. Defaults to 20."
				type:        "numberOrParamRef"
			},
			{
				name:        "bins"
				description: "The number of bins over which to discretize the data prior to smoothing. Defaults to 1024."
				type:        "numberOrParamRef"
			},
			{
				name:        "normalize"
				description: "Normalization method for density estimates. If `false` or `'none'` (the default), the density estimates are smoothed weighted counts. If `true` or `'sum'`, density estimates are divided by the sum of the total point mass. If `'max'`, estimates are divided by the maximum smoothed value."
				type:        "density1DOptionsNormalizeType"
			},
		]

	},
	{
		name:                 "DensityAreaXOptions"
		description:          "The DensityAreaXOptions contract."
		documentationAdapter: "reference-only"
		wire:                 false
		extends: [{name: "AreaXOptions", operator: "omit", keys: ["x", "x1", "x2"]}]
		properties: [
			{
				name:        "type"
				description: "The basic mark type to use to render 1D density values. Defaults to an areaX mark; lineX, dotX, and textX marks are also supported."
				required:    true
				type:        "densityAreaXOptionsTypeLiteral"
			},
			{
				name:        "stack"
				description: "Flag indicating if densities should be stacked. Defaults to false."
				type:        "booleanOrParamRef"
			},
		]

	},
	{
		name:                 "DensityAreaYOptions"
		description:          "The DensityAreaYOptions contract."
		documentationAdapter: "reference-only"
		wire:                 false
		extends: [{name: "AreaYOptions", operator: "omit", keys: ["y", "y1", "y2"]}]
		properties: [
			{
				name:        "type"
				description: "The basic mark type to use to render 1D density values. Defaults to an areaY mark; lineY, dot, and text marks are also supported."
				type:        "densityAreaYOptionsTypeLiteral"
			},
			{
				name:        "stack"
				description: "Flag indicating if densities should be stacked. Defaults to false."
				type:        "booleanOrParamRef"
			},
		]

	},
	{
		name:                 "DensityLineXOptions"
		description:          "The DensityLineXOptions contract."
		documentationAdapter: "reference-only"
		wire:                 false
		extends: [{name: "LineXOptions", operator: "omit", keys: ["x", "x1", "x2"]}]
		properties: [
			{
				name:        "type"
				description: "The basic mark type to use to render 1D density values. Defaults to an areaX mark; lineX, dotX, and textX marks are also supported."
				required:    true
				type:        "densityLineXOptionsTypeLiteral"
			}
		]

	},
	{
		name:                 "DensityLineYOptions"
		description:          "The DensityLineYOptions contract."
		documentationAdapter: "reference-only"
		wire:                 false
		extends: [{name: "LineYOptions", operator: "omit", keys: ["y", "y1", "y2"]}]
		properties: [
			{
				name:        "type"
				description: "The basic mark type to use to render 1D density values. Defaults to an areaY mark; lineY, dot, and text marks are also supported."
				required:    true
				type:        "densityLineYOptionsTypeLiteral"
			}
		]

	},
	{
		name:                 "DensityDotXOptions"
		description:          "The DensityDotXOptions contract."
		documentationAdapter: "reference-only"
		wire:                 false
		extends: [{name: "DotOptions", operator: "omit", keys: ["x"]}]
		properties: [
			{
				name:        "type"
				description: "The basic mark type to use to render 1D density values. Defaults to an areaX mark; lineX, dotX, and textX marks are also supported."
				required:    true
				type:        "densityDotXOptionsTypeLiteral"
			}
		]

	},
	{
		name:                 "DensityDotYOptions"
		description:          "The DensityDotYOptions contract."
		documentationAdapter: "reference-only"
		wire:                 false
		extends: [{name: "DotOptions", operator: "omit", keys: ["y"]}]
		properties: [
			{
				name:        "type"
				description: "The basic mark type to use to render 1D density values. Defaults to an areaY mark; lineY, dot, and text marks are also supported."
				required:    true
				type:        "densityDotYOptionsTypeType"
			}
		]

	},
	{
		name:                 "DensityTextXOptions"
		description:          "The DensityTextXOptions contract."
		documentationAdapter: "reference-only"
		wire:                 false
		extends: [{name: "TextOptions", operator: "omit", keys: ["x"]}]
		properties: [
			{
				name:        "type"
				description: "The basic mark type to use to render 1D density values. Defaults to an areaX mark; lineX, dotX, and textX marks are also supported."
				required:    true
				type:        "densityTextXOptionsTypeLiteral"
			}
		]

	},
	{
		name:                 "DensityTextYOptions"
		description:          "The DensityTextYOptions contract."
		documentationAdapter: "reference-only"
		wire:                 false
		extends: [{name: "TextOptions", operator: "omit", keys: ["y"]}]
		properties: [
			{
				name:        "type"
				description: "The basic mark type to use to render 1D density values. Defaults to an areaY mark; lineY, dot, and text marks are also supported."
				required:    true
				type:        "densityTextYOptionsTypeType"
			}
		]

	},
	{
		name:                 "DensityXBase"
		description:          "The DensityXBase contract."
		documentationAdapter: "reference-only"
		wire:                 false
		extends: ["MarkData", "Density1DOptions"]
		properties: [
			{
				name:        "mark"
				description: "A densityX mark that visualizes smoothed point cloud densities along the\n**x** dimension. The mark bins the data, counts the number of records that fall into each bin, smooths the resulting counts, and then plots the smoothed distribution, by default using an areaX mark.\n\nSet the *type* property to use a different base mark type."
				required:    true
				type:        "densityXBaseMarkLiteral"
			}
		]

	},
	{
		name:                 "DensityYBase"
		description:          "The DensityYBase contract."
		documentationAdapter: "reference-only"
		wire:                 false
		extends: ["MarkData", "Density1DOptions"]
		properties: [
			{
				name:        "mark"
				description: "A densityY mark that visualizes smoothed point cloud densities along the\n**y** dimension. The mark bins the data, counts the number of records that fall into each bin, smooths the resulting counts, and then plots the smoothed distribution, by default using an areaY mark.\n\nSet the *type* property to use a different base mark type."
				required:    true
				type:        "densityYBaseMarkLiteral"
			}
		]

	},
]

supportContracts: [...model.#ShapeContract] & [
	{name: "DensityX", description: "The densityX mark.", wire: true, kind: "alias", expression: "densityXType"},
	{name: "DensityY", description: "The densityY mark.", wire: true, kind: "alias", expression: "densityYType"},
]

typeExpressions: {[string]: model.#ShapeExpression} & {
	numberOrParamRef: {kind: "union", members: ["number", "paramRefReference"]}
	literalMax: {kind: "literal", value: "max"}
	literalSum: {kind: "literal", value: "sum"}
	density1DOptionsNormalizeType: {
		kind: "union"
		members: [
			"boolean",
			"literalMax",
			"literalSum",
			"literalNone",
			"paramRefReference",
		]
	}
	densityAreaXOptionsTypeLiteral: {kind: "literal", value: "areaX"}
	booleanOrParamRef: {kind: "union", members: ["boolean", "paramRefReference"]}
	densityAreaYOptionsTypeLiteral: {kind: "literal", value: "areaY"}
	densityLineXOptionsTypeLiteral: {kind: "literal", value: "lineX"}
	densityLineYOptionsTypeLiteral: {kind: "literal", value: "lineY"}
	densityDotXOptionsTypeLiteral: {kind: "literal", value: "dotX"}
	densityDotYOptionsTypeType: {kind: "enum", values: ["dot", "dotY", "circle", "hexagon"]}
	densityTextXOptionsTypeLiteral: {kind: "literal", value: "textX"}
	densityTextYOptionsTypeType: {kind: "enum", values: ["text", "textY"]}
	densityXBaseMarkLiteral: {kind: "literal", value: "densityX"}
	densityYBaseMarkLiteral: {kind: "literal", value: "densityY"}
	densityXType: {
		kind: "interface-union"
		base: "DensityXBase"
		alternatives: ["DensityAreaXOptions", "DensityLineXOptions", "DensityDotXOptions", "DensityTextXOptions"]
	}
	densityYType: {
		kind: "interface-union"
		base: "DensityYBase"
		alternatives: ["DensityAreaYOptions", "DensityLineYOptions", "DensityDotYOptions", "DensityTextYOptions"]
	}
}

contractIndex: {for Contract in list.Concat([contracts, supportContracts]) {(Contract.name): Contract}}
modelChecks: uniqueNames: true & list.UniqueItems([for Contract in list.Concat([contracts, supportContracts]) {Contract.name}])
