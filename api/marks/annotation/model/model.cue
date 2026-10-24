package annotationmodel

import (
	"list"
	"idl.uw.edu/mosaic/api/model"
)

contracts: [...model.#ShapeContract] & [
	{
		name:        "TextOptions"
		description: "Options for the text mark."
		wire:        false
		extends: ["MarkOptions", "TextStyles"]
		properties: [
			{
				name:        "x"
				description: "The horizontal position channel specifying the text’s anchor point, typically bound to the *x* scale."
				type:        "channelValueSpecReference"
			},
			{
				name:        "y"
				description: "The vertical position channel specifying the text’s anchor point, typically bound to the *y* scale."
				type:        "channelValueSpecReference"
			},
			{name: "z", description: "An optional ordinal channel for grouping data into series.", type: "channelValueReference"},
			{
				name:        "text"
				description: "The text contents channel, possibly with line breaks (\\n, \\r\\n, or \\r). If not specified, defaults to the zero-based index [0, 1, 2, …]."
				type:        "channelValueReference"
			},
			{
				name:        "frameAnchor"
				description: "The frame anchor specifies defaults for **x** and **y**, along with\n**textAnchor** and **lineAnchor**, based on the plot’s frame; it may be one of the four sides (*top*, *right*, *bottom*, *left*), one of the four corners (*top-left*, *top-right*, *bottom-right*, *bottom-left*), or the\n*middle* of the frame."
				type:        "textOptionsFrameAnchorType"
			},
			{
				name:        "lineAnchor"
				description: "The line anchor controls how text is aligned (typically vertically) relative to its anchor point; it is one of *top*, *bottom*, or *middle*. If the frame anchor is *top*, *top-left*, or *top-right*, the default line anchor is *top*; if the frame anchor is *bottom*, *bottom-right*, or\n*bottom-left*, the default is *bottom*; otherwise it is *middle*."
				type:        "textOptionsLineAnchorType"
			},
			{
				name:        "rotate"
				description: "The rotation angle in degrees clockwise; a constant or a channel; defaults to 0°. When a number, it is interpreted as a constant; otherwise it is interpreted as a channel."
				type:        "textOptionsRotateType"
			},
		]

	},
	{
		name:        "TextXOptions"
		description: "Options for the textX mark."
		wire:        false
		extends: [{name: "TextOptions", operator: "omit", keys: ["y"]}]
		properties: [
			{
				name:        "y"
				description: "The vertical position of the text’s anchor point, typically bound to the\n*y* scale."
				type:        "channelValueIntervalSpecReference"
			},
			{
				name:        "interval"
				description: "An interval (such as *day* or a number), to transform **y** values to the middle of the interval."
				type:        "textXOptionsIntervalType"
			},
		]

	},
	{
		name:        "TextYOptions"
		description: "Options for the textY mark."
		wire:        false
		extends: [{name: "TextOptions", operator: "omit", keys: ["x"]}]
		properties: [
			{
				name:        "x"
				description: "The horizontal position of the text’s anchor point, typically bound to the\n*x* scale."
				type:        "channelValueIntervalSpecReference"
			},
			{
				name:        "interval"
				description: "An interval (such as *day* or a number), to transform **x** values to the middle of the interval."
				type:        "intervalReference"
			},
		]

	},
	{
		name:        "Text"
		description: "The text mark."
		extends: ["MarkDataOptional", "TextOptions"]
		properties: [
			{
				name:        "mark"
				description: "A text mark. The **text** channel specifies the textual contents of the mark, which may be preformatted with line breaks (\\n, \\r\\n, or \\r), or wrapped or clipped using the **lineWidth** and **textOverflow** options.\n\nIf **text** contains numbers or dates, a default formatter will be applied, and the **fontVariant** will default to *tabular-nums* instead of *normal*. If **text** is not specified, it defaults to the identity function for primitive data (such as numbers, dates, and strings), and to the zero-based index [0, 1, 2, …] for objects (so that something identifying is visible by default).\n\nIf either **x** or **y** is not specified, the default is determined by the **frameAnchor** option."
				required:    true
				type:        "textMarkLiteral"
			}
		]

	},
	{
		name:        "TextX"
		description: "The textX mark."
		extends: ["MarkDataOptional", "TextXOptions"]
		properties: [
			{
				name:        "mark"
				description: "Like text, but **x** defaults to the identity function, assuming that\n*data* = [*x₀*, *x₁*, *x₂*, …]. If an **interval** is specified, such as\n*day*, **y** is transformed to the middle of the interval."
				required:    true
				type:        "textXMarkLiteral"
			}
		]

	},
	{
		name:        "TextY"
		description: "The textY mark."
		extends: ["MarkDataOptional", "TextYOptions"]
		properties: [
			{
				name:        "mark"
				description: "Like text, but **y** defaults to the identity function, assuming that\n*data* = [*y₀*, *y₁*, *y₂*, …]. If an **interval** is specified, such as\n*day*, **x** is transformed to the middle of the interval."
				required:    true
				type:        "textYMarkLiteral"
			}
		]

	},
	{
		name:        "ImageOptions"
		description: "Options for the image mark."
		wire:        false
		extends: ["MarkOptions"]
		properties: [
			{
				name:        "x"
				description: "The horizontal position channel specifying the image’s center; typically bound to the *x* scale."
				type:        "channelValueSpecReference"
			},
			{
				name:        "y"
				description: "The vertical position channel specifying the image’s center; typically bound to the *y* scale."
				type:        "channelValueSpecReference"
			},
			{
				name:        "width"
				description: "The image width in pixels. When a number, it is interpreted as a constant radius in pixels; otherwise it is interpreted as a channel. Also sets the default **height**; if neither are set, defaults to 16. Images with a nonpositive width are not drawn."
				type:        "imageOptionsWidthType"
			},
			{
				name:        "height"
				description: "The image height in pixels. When a number, it is interpreted as a constant radius in pixels; otherwise it is interpreted as a channel. Also sets the default **height**; if neither are set, defaults to 16. Images with a nonpositive height are not drawn."
				type:        "imageOptionsHeightType"
			},
			{
				name:        "r"
				description: "The image clip radius, for circular images. If null (default), images are not clipped; when a number, it is interpreted as a constant in pixels; otherwise it is interpreted as a channel, typically bound to the *r* scale. Also defaults **height** and **width** to twice its value."
				type:        "imageOptionsRType"
			},
			{
				name:        "rotate"
				description: "The rotation angle, in degrees clockwise. When a number, it is interpreted as a constant; otherwise it is interpreted as a channel."
				type:        "imageOptionsRotateType"
			},
			{
				name:        "src"
				description: "The required image URL (or relative path). If a string that starts with a dot, slash, or URL protocol (*e.g.*, “https:”) it is assumed to be a constant; otherwise it is interpreted as a channel."
				type:        "imageOptionsSrcType"
			},
			{
				name:        "preserveAspectRatio"
				description: "The image [aspect ratio][1]; defaults to *xMidYMid meet*. To crop the image instead of scaling it to fit, use *xMidYMid slice*.\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/preserveAspectRatio"
				type:        "imageOptionsPreserveAspectRatioType"
			},
			{
				name:        "crossOrigin"
				description: "The [cross-origin][1] behavior. See the [Plot.image notebook][2] for details.\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/crossorigin [2]: https://observablehq.com/@observablehq/plot-image"
				type:        "imageOptionsCrossOriginType"
			},
			{
				name:        "frameAnchor"
				description: "The frame anchor specifies defaults for **x** and **y** based on the plot’s frame; it may be one of the four sides (*top*, *right*, *bottom*, *left*), one of the four corners (*top-left*, *top-right*, *bottom-right*,\n*bottom-left*), or the *middle* of the frame."
				type:        "imageOptionsFrameAnchorType"
			},
			{
				name:        "imageRendering"
				description: "The [image-rendering attribute][1]; defaults to *auto* (bilinear). The option may be set to *pixelated* to disable bilinear interpolation for a sharper image; however, note that this is not supported in WebKit.\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/image-rendering"
				type:        "imageOptionsImageRenderingType"
			},
		]

	},
	{
		name:        "Image"
		description: "The image mark."
		extends: ["MarkData", "ImageOptions"]
		properties: [
			{
				name:        "mark"
				description: "An image mark that draws images as in a scatterplot.\n\nIf either **x** or **y** is not specified, the default is determined by the **frameAnchor** option. If none of **x**, **y**, and **frameAnchor** are specified, *data* is assumed to be an array of pairs [[*x₀*, *y₀*], [*x₁*, *y₁*], [*x₂*, *y₂*], …] such that **x** = [*x₀*, *x₁*, *x₂*, …] and **y** = [*y₀*, *y₁*, *y₂*, …]."
				required:    true
				type:        "imageMarkLiteral"
			}
		]
		documentationAdapter: "reference-only"
	},
	{
		name:        "VectorOptions"
		description: "Options for the vector mark."
		wire:        false
		extends: ["MarkOptions"]
		properties: [
			{
				name:        "x"
				description: "The horizontal position of the vector’s anchor point; an optional channel bound to the *x* scale. Default depends on the **frameAnchor**."
				type:        "channelValueSpecReference"
			},
			{
				name:        "y"
				description: "The vertical position of the vector’s anchor point; an optional channel bound to the *y* scale. Default depends on the **frameAnchor**."
				type:        "channelValueSpecReference"
			},
			{
				name:        "r"
				description: "The vector shape’s radius, such as half the width of the *arrow*’s head or the *spike*’s base; a constant number in pixels. Defaults to 3.5 pixels."
				type:        "numberOrParamRef"
			},
			{
				name:        "length"
				description: "The vector’s length; either an optional channel bound to the *length* scale or a constant number in pixels. Defaults to 12 pixels."
				type:        "channelValueSpecReference"
			},
			{
				name:        "rotate"
				description: "The vector’s orientation (rotation angle); either a constant number in degrees clockwise, or an optional channel (with no associated scale). Defaults to 0 degrees with the vector pointing up."
				type:        "channelValueReference"
			},
			{
				name:        "shape"
				description: "The shape of the vector; a constant. Defaults to *arrow*."
				type:        "vectorOptionsShapeType"
			},
			{
				name:        "anchor"
				description: "The vector’s position along its orientation relative to its anchor point; a constant. Assuming a default **rotate** angle of 0°, one of:\n\n- *start* - from [*x*, *y*] to [*x*, *y* - *l*]\n- *middle* (default) - from [*x*, *y* + *l* / 2] to [*x*, *y* - *l* / 2]\n- *end* - from [*x*, *y* + *l*] to [*x*, *y*]\n\nwhere [*x*, *y*] is the vector’s anchor point and *l* is the vector’s (possibly scaled) length in pixels."
				type:        "vectorOptionsAnchorType"
			},
			{
				name:        "frameAnchor"
				description: "The vector’s frame anchor, to default **x** and **y** relative to the frame; a constant representing one of the frame corners (*top-left*,\n*top-right*, *bottom-right*, *bottom-left*), sides (*top*, *right*,\n*bottom*, *left*), or *middle* (default). Has no effect if both **x** and **y** are specified."
				type:        "vectorOptionsFrameAnchorType"
			},
		]

	},
	{
		name:        "Vector"
		description: "The vector mark."
		extends: ["MarkData", "VectorOptions"]
		properties: [
			{
				name:        "mark"
				description: "A vector mark.\n\nIf none of **frameAnchor**, **x**, and **y** are specified, then **x** and\n**y** default to accessors assuming that *data* contains tuples [[*x₀*,\n*y₀*], [*x₁*, *y₁*], [*x₂*, *y₂*], …]"
				required:    true
				type:        "vectorMarkLiteral"
			}
		]

	},
	{
		name:        "VectorX"
		description: "The vectorX mark."
		extends: ["MarkData", "VectorOptions"]
		properties: [
			{
				name:        "mark"
				description: "Like vector, but **x** instead defaults to the identity function and **y** defaults to null, assuming that *data* is an array of numbers [*x₀*, *x₁*,\n*x₂*, …]."
				required:    true
				type:        "vectorXMarkLiteral"
			}
		]

	},
	{
		name:        "VectorY"
		description: "The vectorY mark."
		extends: ["MarkData", "VectorOptions"]
		properties: [
			{
				name:        "mark"
				description: "Like vector, but **y** instead defaults to the identity function and **x** defaults to null, assuming that *data* is an array of numbers [*y₀*, *y₁*,\n*y₂*, …]."
				required:    true
				type:        "vectorYMarkLiteral"
			}
		]

	},
	{
		name:        "Spike"
		description: "The spike mark."
		extends: ["MarkData", "VectorOptions"]
		properties: [
			{
				name:        "mark"
				description: "Like vector, but with default *options* suitable for drawing a spike map."
				required:    true
				type:        "spikeMarkLiteral"
			}
		]

	},
	{
		name:        "WaffleOptions"
		description: "Options for the waffleX and waffleY mark."
		wire:        false
		properties: [
			{
				name:        "multiple"
				description: "The number of cells per row or column; defaults to undefined for automatic."
				type:        "numberOrParamRef"
			},
			{name: "unit", description: "The quantity each cell represents; defaults to 1.", type: "numberOrParamRef"},
			{name: "gap", description: "The gap in pixels between cells; defaults to 1.", type: "numberOrParamRef"},
			{name: "round", description: "If true, round to integers to avoid partial cells.", type: "booleanOrParamRef"},
		]

	},
	{
		name:        "WaffleX"
		description: "The waffleX mark."
		extends: ["MarkData", "BarXOptions", "WaffleOptions"]
		properties: [
			{
				name:        "mark"
				description: "A horizontal waffle mark. The required *x* values should be quantitative, and the optional *y* values should be ordinal.\n\nIf neither **x1** nor **x2** nor **interval** is specified, an implicit stackX transform is applied and **x** defaults to the identity function, assuming that *data* = [*x₀*, *x₁*, *x₂*, …]. Otherwise if an **interval** is specified, then **x1** and **x2** are derived from **x**, representing the lower and upper bound of the containing interval, respectively. Otherwise, if only one of **x1** or **x2** is specified, the other defaults to **x**, which defaults to zero.\n\nThe optional **y** ordinal channel specifies the vertical position; it is typically bound to the *y* scale, which must be a *band* scale. If the\n**y** channel is not specified, the bar will span the vertical extent of the plot’s frame. Because a waffle represents a discrete number of square cells, it may not use all of the available bandwidth."
				required:    true
				type:        "waffleXMarkLiteral"
			}
		]

	},
	{
		name:        "WaffleY"
		description: "The waffleY mark."
		extends: ["MarkData", "BarYOptions", "WaffleOptions"]
		properties: [
			{
				name:        "mark"
				description: "A vertical waffle mark. The required *y* values should be quantitative, and the optional *x* values should be ordinal.\n\nIf neither **y1** nor **y2** nor **interval** is specified, an implicit stackY transform is applied and **y** defaults to the identity function, assuming that *data* = [*y₀*, *y₁*, *y₂*, …]. Otherwise if an **interval** is specified, then **y1** and **y2** are derived from **y**, representing the lower and upper bound of the containing interval, respectively. Otherwise, if only one of **y1** or **y2** is specified, the other defaults to **y**, which defaults to zero.\n\nThe optional **x** ordinal channel specifies the horizontal position; it is typically bound to the *x* scale, which must be a *band* scale. If the\n**x** channel is not specified, the bar will span the horizontal extent of the plot’s frame. Because a waffle represents a discrete number of square cells, it may not use all of the available bandwidth."
				required:    true
				type:        "waffleYMarkLiteral"
			}
		]

	},
]

supportContracts: [...model.#ShapeContract] & [
	{
		name:        "VectorShapeName"
		description: "The built-in vector shape implementations; one of:\n\n- *arrow* - a straight line with an open arrowhead at the end (↑)\n- *spike* - an isosceles triangle with a flat base (▲)"
		wire:        true
		kind:        "alias"
		expression:  "vectorShapeNameType"
	},
	{
		name:        "VectorShape"
		description: "How to draw a vector: either a named shape or a custom implementation."
		wire:        true
		kind:        "alias"
		expression:  "vectorShapeNameReference"
	},
]

typeExpressions: {[string]: model.#ShapeExpression} & {
	textOptionsFrameAnchorType: {kind: "union", members: ["frameAnchorReference", "paramRefReference"]}
	textOptionsLineAnchorType: {
		kind: "union"
		members: [
			"literalTop",
			"literalMiddle",
			"literalBottom",
			"paramRefReference",
		]
	}
	textOptionsRotateType: {kind: "union", members: ["channelValueReference", "paramRefReference"]}
	channelValueIntervalSpecReference: {kind: "named", name: "ChannelValueIntervalSpec"}
	textXOptionsIntervalType: {kind: "union", members: ["intervalReference", "paramRefReference"]}
	textMarkLiteral: {kind: "literal", value: "text"}
	textXMarkLiteral: {kind: "literal", value: "textX"}
	textYMarkLiteral: {kind: "literal", value: "textY"}
	imageOptionsWidthType: {kind: "union", members: ["channelValueReference", "paramRefReference"]}
	imageOptionsHeightType: {kind: "union", members: ["channelValueReference", "paramRefReference"]}
	imageOptionsRType: {kind: "union", members: ["channelValueReference", "paramRefReference"]}
	imageOptionsRotateType: {kind: "union", members: ["channelValueReference", "paramRefReference"]}
	imageOptionsSrcType: {kind: "union", members: ["channelValueReference", "paramRefReference"]}
	imageOptionsPreserveAspectRatioType: {kind: "union", members: ["string", "paramRefReference"]}
	imageOptionsCrossOriginType: {kind: "union", members: ["string", "paramRefReference"]}
	imageOptionsFrameAnchorType: {kind: "union", members: ["frameAnchorReference", "paramRefReference"]}
	imageOptionsImageRenderingType: {kind: "union", members: ["string", "paramRefReference"]}
	imageMarkLiteral: {kind: "literal", value: "image"}
	literalArrow: {kind: "literal", value: "arrow"}
	literalSpike: {kind: "literal", value: "spike"}
	vectorShapeNameType: {kind: "enum", values: ["arrow", "spike"]}
	vectorShapeNameReference: {kind: "named", name: "VectorShapeName"}
	numberOrParamRef: {kind: "union", members: ["number", "paramRefReference"]}
	vectorShapeReference: {kind: "named", name: "VectorShape"}
	vectorOptionsShapeType: {kind: "union", members: ["vectorShapeReference", "paramRefReference"]}
	vectorOptionsAnchorType: {
		kind: "union"
		members: [
			"literalStart",
			"literalMiddle",
			"literalEnd",
			"paramRefReference",
		]
	}
	vectorOptionsFrameAnchorType: {kind: "union", members: ["frameAnchorReference", "paramRefReference"]}
	vectorMarkLiteral: {kind: "literal", value: "vector"}
	vectorXMarkLiteral: {kind: "literal", value: "vectorX"}
	vectorYMarkLiteral: {kind: "literal", value: "vectorY"}
	spikeMarkLiteral: {kind: "literal", value: "spike"}
	booleanOrParamRef: {kind: "union", members: ["boolean", "paramRefReference"]}
	waffleXMarkLiteral: {kind: "literal", value: "waffleX"}
	waffleYMarkLiteral: {kind: "literal", value: "waffleY"}
}

contractIndex: {for contract in list.Concat([contracts, supportContracts]) {(contract.name): contract}}
modelChecks: names: true & list.UniqueItems([for contract in list.Concat([contracts, supportContracts]) {contract.name}])

declarationFiles: [
	{
		basename: "Text"
		imports: [
			"ParamRef",
			"FrameAnchor",
			"Interval",
			"ChannelValue",
			"ChannelValueIntervalSpec",
			"ChannelValueSpec",
			"MarkDataOptional",
			"MarkOptions",
			"TextStyles",
		]
		contracts: ["TextOptions", "TextXOptions", "TextYOptions", "Text", "TextX", "TextY"]
	},
	{
		basename: "Image"
		imports: ["ParamRef", "FrameAnchor", "ChannelValue", "ChannelValueSpec", "MarkData", "MarkOptions"]
		contracts: ["ImageOptions", "Image"]
	},
	{
		basename: "Vector"
		imports: ["ParamRef", "FrameAnchor", "ChannelValue", "ChannelValueSpec", "MarkData", "MarkOptions"]
		contracts: ["VectorShapeName", "VectorShape", "VectorOptions", "Vector", "VectorX", "VectorY", "Spike"]
	},
	{
		basename: "Waffle"
		imports: ["ParamRef", "BarXOptions", "BarYOptions", "MarkData"]
		contracts: ["WaffleOptions", "WaffleX", "WaffleY"]
	},
]
