package gridmarks

import ("list"
	"idl.uw.edu/mosaic/api/model")

contracts: [...model.#ShapeContract] & [
	{
		name:        "Grid2DOptions"
		description: "Options for grid2d marks."
		wire:        false
		properties: [
			{
				name:        "x"
				description: "The horizontal position channel, typically bound to the *x* scale. Domain values are binned into a grid with *width* horizontal bins."
				type:        "channelValueSpecReference"
			},
			{
				name:        "y"
				description: "The vertical position channel, typically bound to the *y* scale. Domain values are binned into a grid with *height* vertical bins."
				type:        "channelValueSpecReference"
			},
			{
				name:        "width"
				description: "The width (number of columns) of the grid, in actual pixels."
				type:        "numberOrParamRef"
			},
			{
				name:        "height"
				description: "The height (number of rows) of the grid, in actual pixels."
				type:        "numberOrParamRef"
			},
			{
				name:        "pixelSize"
				description: "The effective screen size of a raster pixel, used to determine the height and width of the raster from the frame’s dimensions; defaults to 1."
				type:        "numberOrParamRef"
			},
			{
				name:        "pad"
				description: "The bin padding, one of 1 (default) to include extra padding for the final bin, or 0 to make the bins flush with the maximum domain value."
				type:        "numberOrParamRef"
			},
			{
				name:        "bandwidth"
				description: "The kernel density bandwidth for smoothing, in pixels."
				type:        "numberOrParamRef"
			},
			{
				name:        "interpolate"
				description: "The spatial interpolation method; one of:\n\n- *none* - do not perform interpolation (the default), maps samples to single bins\n- *linear* - apply proportional linear interpolation across adjacent bins\n- *nearest* - assign each pixel to the closest sample’s value (Voronoi diagram)\n- *barycentric* - apply barycentric interpolation over the Delaunay triangulation\n- *random-walk* - apply a random walk from each pixel, stopping when near a sample"
				type:        "grid2DOptionsInterpolateType"
			},
		]

	},
	{
		name:        "RasterOptions"
		description: "Options for the raster mark."
		wire:        false
		extends: ["Grid2DOptions", {name: "MarkOptions", operator: "omit", keys: ["fill", "fillOpacity"]}]
		properties: [
			{
				name:        "imageRendering"
				description: "The [image-rendering attribute][1]; defaults to *auto* (bilinear). The option may be set to *pixelated* to disable bilinear interpolation for a sharper image; however, note that this is not supported in WebKit.\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/image-rendering"
				type:        "rasterOptionsImageRenderingType"
			},
			{
				name:        "fill"
				description: "The fill, typically bound to the *color* scale. Can be specified as a constant or a channel based on the input data.  Use the special value `\"density\"` to map computed density values to pixel colors. Use an aggregate expression to instead visualize an aggregate value per raster bin. If fill is set to a constant color or to a non-aggregate field, opacity will be used to convey densities. If a non-aggregate (group by) field is provided, multiple rasters are created with a unique categorical color per layer."
				type:        "rasterOptionsFillType"
			},
			{
				name:        "fillOpacity"
				description: "The opacity, typically bound to the *opacity* scale. Can be specified as a constant or a channel based on the input data. Use the special value `\"density\"` to map computed density values to opacity. Use an aggregate expression to instead visualize an aggregate value per raster bin."
				type:        "rasterOptionsFillOpacityType"
			},
		]

	},
	{
		name:        "Raster"
		description: "The raster mark."
		extends: ["MarkData", "RasterOptions"]
		properties: [
			{
				name:        "mark"
				description: "A raster mark which renders a raster image from spatial samples. It represents discrete samples in abstract coordinates **x** and **y**; the **fill** and **fillOpacity** channels specify further abstract values (_e.g._, height in a topographic map) to be spatially interpolated to produce an image.\n\nThe **x** and **y** data domains are binned into the cells (\"pixels\") of a raster grid, typically with an aggregate function evaluated over the binned data. The result can be optionally smoothed (blurred).\n\nTo create a smoothed density heatmap, use the heatmap mark, which is a raster mark with different default options."
				required:    true
				type:        "rasterMarkLiteral"
			}
		]

	},
	{
		name:        "Heatmap"
		description: "The heatmap mark."
		extends: ["MarkData", "RasterOptions"]
		properties: [
			{
				name:        "mark"
				description: "Like raster, but with default options for accurate density estimation via smoothing. The *bandwidth* (20), *interpolate* (\"linear\"), and\n*pixelSize* (2) options are set to produce smoothed density heatmaps."
				required:    true
				type:        "heatmapMarkLiteral"
			}
		]

	},
	{
		name:        "RasterTile"
		description: "The rasterTile mark."
		extends: ["MarkData", "RasterOptions"]
		properties: [
			{
				name:        "mark"
				description: "An experimental raster mark which performs tiling and prefetching to support more scalable rasters upon panning the domain. Uses a tile size that matches with current width and height, and prefetches data from neighboring tile segments."
				required:    true
				type:        "rasterTileMarkLiteral"
			},
			{
				name:        "origin"
				description: "The coordinates of the tile origin in the **x** and **y** data domains. Defaults to [0, 0]."
				type:        "rasterTileOriginType"
			},
		]

	},
	{
		name:                 "ContourOptions"
		description:          "The ContourOptions contract."
		documentationAdapter: "reference-only"
		wire:                 false
		extends: ["MarkOptions", "Grid2DOptions"]
		properties: [
			{
				name:        "thresholds"
				description: "The number of contour thresholds to subdivide the domain into discrete level sets; defaults to 10. One of:\n\n- a count representing the desired number of bins\n- an array of *n* threshold values for *n* - 1 bins"
				type:        "contourOptionsThresholdsType"
			}
		]

	},
	{
		name:        "Contour"
		description: "The contour mark."
		extends: ["MarkData", "ContourOptions"]
		properties: [
			{
				name:        "mark"
				description: "A contour mark that draws isolines to delineate regions above and below a particular continuous value. It is often used to convey densities as a height field. The special column name \"density\" can be used to map density values to the fill or stroke options."
				required:    true
				type:        "contourMarkLiteral"
			}
		]

	},
	{
		name:                 "DenseLineOptions"
		description:          "The DenseLineOptions contract."
		documentationAdapter: "reference-only"
		wire:                 false
		extends: ["RasterOptions"]
		properties: [
			{
				name:        "normalize"
				description: "Flag to perform approximate arc length normalization of line segments to prevent artifacts due to overcounting steep lines. Defaults to `true`."
				type:        "booleanOrParamRef"
			},
			{
				name:        "z"
				description: "A ordinal channel for grouping data into series to be drawn as separate lines."
				type:        "channelValueReference"
			},
		]

	},
	{
		name:        "DenseLine"
		description: "The denseLine mark."
		extends: ["MarkData", "DenseLineOptions"]
		properties: [
			{
				name:        "mark"
				description: "A denseLine mark that plots line densities rather than point densities. The mark forms a binned raster grid and \"draws\" straight lines into it. To avoid over-weighting steep lines, by default each drawn series is normalized on a per-column basis to approximate arc length normalization. The values for each series are aggregated to form the line density, which is then drawn as an image similar to the raster mark."
				required:    true
				type:        "denseLineMarkLiteral"
			}
		]

	},
	{
		name:                 "Density2DOptions"
		description:          "The Density2DOptions contract."
		documentationAdapter: "reference-only"
		wire:                 false
		extends: ["MarkOptions", {name: "DotOptions", operator: "omit", keys: ["x", "y"]}, "TextStyles", "Grid2DOptions"]
		properties: [
			{
				name:        "type"
				description: "The basic mark type to use to render 2D density values. Defaults to a dot mark; cell and text marks are also supported."
				type:        "density2DOptionsTypeType"
			}
		]

	},
	{
		name:        "Density"
		description: "The density mark for 2D densities."
		extends: ["MarkData", "Density2DOptions"]
		properties: [
			{
				name:        "mark"
				description: "A 2D density mark that shows smoothed point cloud densities along two dimensions. The mark bins the data, counts the number of records that fall into each bin, and smooths the resulting counts, then plots the smoothed distribution, by default using a circular dot mark. The density mark calculates density values that can be mapped to encoding channels such as fill or r using the special field name \"density\".\n\nSet the *type* property to use a different base mark type."
				required:    true
				type:        "densityMarkLiteral"
			}
		]

	},
]

supportContracts: [...model.#ShapeContract] & [
	{
		name:        "GridInterpolate"
		description: "A spatial interpolation method; one of:\n\n- *none* - do not perform interpolation (the default), maps samples to single bins\n- *linear* - apply proportional linear interpolation across adjacent bins\n- *nearest* - assign each pixel to the closest sample’s value (Voronoi diagram)\n- *barycentric* - apply barycentric interpolation over the Delaunay triangulation\n- *random-walk* - apply a random walk from each pixel, stopping when near a sample"
		wire:        true
		exported:    true
		kind:        "alias"
		expression:  "gridInterpolateType"
	}
]

typeExpressions: {[string]: model.#ShapeExpression} & {
	gridInterpolateType: {kind: "enum", values: ["none", "linear", "nearest", "barycentric", "random-walk"]}
	numberOrParamRef: {kind: "union", members: ["number", "paramRefReference"]}
	gridInterpolateReference: {kind: "reference", name: "GridInterpolate", expression: "gridInterpolateType"}
	grid2DOptionsInterpolateType: {kind: "union", members: ["gridInterpolateReference", "null", "paramRefReference"]}
	rasterOptionsImageRenderingType: {kind: "union", members: ["string", "paramRefReference"]}
	rasterOptionsFillType: {kind: "union", members: ["channelValueSpecReference", "paramRefReference"]}
	rasterOptionsFillOpacityType: {kind: "union", members: ["channelValueSpecReference", "paramRefReference"]}
	rasterMarkLiteral: {kind: "literal", value: "raster"}
	heatmapMarkLiteral: {kind: "literal", value: "heatmap"}
	rasterTileMarkLiteral: {kind: "literal", value: "rasterTile"}
	coordinatePair: {kind: "tuple", elements: [{type: "number"}, {type: "number"}]}
	rasterTileOriginType: {kind: "union", members: ["coordinatePair", "paramRefReference"]}
	numberArray: {kind: "array", items: "number"}
	contourOptionsThresholdsType: {kind: "union", members: ["number", "numberArray", "paramRefReference"]}
	contourMarkLiteral: {kind: "literal", value: "contour"}
	booleanOrParamRef: {kind: "union", members: ["boolean", "paramRefReference"]}
	denseLineMarkLiteral: {kind: "literal", value: "denseLine"}
	dotKind: {kind: "literal", value: "dot"}
	circleKind: {kind: "literal", value: "circle"}
	hexagonKind: {kind: "literal", value: "hexagon"}
	cellKind: {kind: "literal", value: "cell"}
	textKind: {kind: "literal", value: "text"}
	density2DOptionsTypeType: {
		kind: "union"
		members: [
			"dotKind",
			"circleKind",
			"hexagonKind",
			"cellKind",
			"textKind",
			"paramRefReference",
		]
	}
	densityMarkLiteral: {kind: "literal", value: "density"}
}

contractIndex: {for Contract in list.Concat([contracts, supportContracts]) {(Contract.name): Contract}}
