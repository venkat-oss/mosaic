package connectedmodel

import (
	"list"
	"idl.uw.edu/mosaic/api/model"
	common "idl.uw.edu/mosaic/api/marks/common/model:commonmodel"
)

contracts: [...model.#ShapeContract] & [
	{
		name:        "AreaOptions"
		description: "Options for the area, areaX, and areaY marks."
		wire:        false
		extends: ["MarkOptions", "StackOptions", "CurveOptions"]
		properties: [
			{
				name:        "x1"
				description: "The required primary (starting, often left) horizontal position channel, representing the area’s baseline, typically bound to the *x* scale. For areaX, setting this option disables the implicit stackX transform."
				type:        "channelValueSpecReference"
			},
			{
				name:        "x2"
				description: "The optional secondary (ending, often right) horizontal position channel, representing the area’s topline, typically bound to the *x* scale; if not specified, **x1** is used. For areaX, setting this option disables the implicit stackX transform."
				type:        "channelValueSpecReference"
			},
			{
				name:        "y1"
				description: "The required primary (starting, often bottom) vertical position channel, representing the area’s baseline, typically bound to the *y* scale. For areaY, setting this option disables the implicit stackY transform."
				type:        "channelValueSpecReference"
			},
			{
				name:        "y2"
				description: "The optional secondary (ending, often top) vertical position channel, representing the area’s topline, typically bound to the *y* scale; if not specified, **y1** is used. For areaY, setting this option disables the implicit stackY transform."
				type:        "channelValueSpecReference"
			},
			{
				name:        "z"
				description: "An optional ordinal channel for grouping data into (possibly stacked) series to be drawn as separate areas; defaults to **fill** if a channel, or\n**stroke** if a channel."
				type:        "channelValueReference"
				override:    true
			},
		]

	},
	{
		name:        "AreaXOptions"
		description: "Options for the areaX mark."
		wire:        false
		extends: [{name: "AreaOptions", operator: "omit", keys: ["y1", "y2"]}]
		properties: [
			{
				name:        "x"
				description: "The horizontal position (or length) channel, typically bound to the *x* scale.\n\nIf neither **x1** nor **x2** is specified, an implicit stackX transform is applied and **x** defaults to the identity function, assuming that *data* = [*x₀*, *x₁*, *x₂*, …]. Otherwise, if only one of **x1** or **x2** is specified, the other defaults to **x**, which defaults to zero."
				type:        "channelValueSpecReference"
			},
			{
				name:        "y"
				description: "The vertical position channel, typically bound to the *y* scale; defaults to the zero-based index of the data [0, 1, 2, …]."
				type:        "channelValueSpecReference"
			},
		]

	},
	{
		name:        "AreaYOptions"
		description: "Options for the areaY mark."
		wire:        false
		extends: [{name: "AreaOptions", operator: "omit", keys: ["x1", "x2"]}]
		properties: [
			{
				name:        "x"
				description: "The horizontal position channel, typically bound to the *x* scale; defaults to the zero-based index of the data [0, 1, 2, …]."
				type:        "channelValueSpecReference"
			},
			{
				name:        "y"
				description: "The vertical position (or length) channel, typically bound to the *y* scale.\n\nIf neither **y1** nor **y2** is specified, an implicit stackY transform is applied and **y** defaults to the identity function, assuming that *data* = [*y₀*, *y₁*, *y₂*, …]. Otherwise, if only one of **y1** or **y2** is specified, the other defaults to **y**, which defaults to zero."
				type:        "channelValueSpecReference"
			},
		]

	},
	{
		name:        "Area"
		description: "The area mark."
		extends: ["MarkData", "AreaOptions"]
		properties: [
			{
				name:        "mark"
				description: "An area mark. The area mark is rarely used directly; it is only needed when the baseline and topline have neither *x* nor *y* values in common. Use areaY for a horizontal orientation where the baseline and topline share *x* values, or areaX for a vertical orientation where the baseline and topline share *y* values."
				required:    true
				type:        "areaMarkLiteral"
			}
		]

	},
	{
		name:        "AreaX"
		description: "The areaX mark."
		extends: ["MarkData", "AreaXOptions"]
		properties: [
			{
				name:        "mark"
				description: "A vertically-oriented area mark, where the baseline and topline share\n**y** values, as in a time-series area chart where time goes up↑.\n\nIf neither **x1** nor **x2** is specified, an implicit stackX transform is applied and **x** defaults to the identity function, assuming that *data* = [*x₀*, *x₁*, *x₂*, …]. Otherwise, if only one of **x1** or **x2** is specified, the other defaults to **x**, which defaults to zero.\n\nIf an **interval** is specified, **y** values are binned accordingly, allowing zeroes for empty bins instead of interpolating across gaps. This is recommended to “regularize” sampled data; for example, if your data represents timestamped observations and you expect one observation per day, use *day* as the **interval**.\n\nVariable aesthetic channels are supported: if the **fill** is defined as a channel, the area will be broken into contiguous overlapping sections when the fill color changes; the fill color will apply to the interval spanning the current data point and the following data point. This behavior also applies to the **fillOpacity**, **stroke**, **strokeOpacity**,\n**strokeWidth**, **opacity**, **href**, **title**, and **ariaLabel** channels. When any of these channels are used, setting an explicit **z** channel (possibly to null) is strongly recommended."
				required:    true
				type:        "areaXMarkLiteral"
			}
		]

	},
	{
		name:        "AreaY"
		description: "The areaY mark."
		extends: ["MarkData", "AreaYOptions"]
		properties: [
			{
				name:        "mark"
				description: "A horizontally-oriented area mark, where the baseline and topline share\n**x** values, as in a time-series area chart where time goes right→.\n\nIf neither **y1** nor **y2** is specified, an implicit stackY transform is applied and **y** defaults to the identity function, assuming that *data* = [*y₀*, *y₁*, *y₂*, …]. Otherwise, if only one of **y1** or **y2** is specified, the other defaults to **y**, which defaults to zero.\n\nIf an **interval** is specified, **x** values are binned accordingly, allowing zeroes for empty bins instead of interpolating across gaps. This is recommended to “regularize” sampled data; for example, if your data represents timestamped observations and you expect one observation per day, use *day* as the **interval**.\n\nVariable aesthetic channels are supported: if the **fill** is defined as a channel, the area will be broken into contiguous overlapping sections when the fill color changes; the fill color will apply to the interval spanning the current data point and the following data point. This behavior also applies to the **fillOpacity**, **stroke**, **strokeOpacity**,\n**strokeWidth**, **opacity**, **href**, **title**, and **ariaLabel** channels. When any of these channels are used, setting an explicit **z** channel (possibly to null) is strongly recommended."
				required:    true
				type:        "areaYMarkLiteral"
			}
		]

	},
	{
		name:        "LineOptions"
		description: "Options for the line mark."
		wire:        false
		extends: ["MarkOptions", "MarkerOptions", "CurveAutoOptions"]
		properties: [
			{
				name:        "x"
				description: "The required horizontal position channel, typically bound to the *x* scale."
				type:        "channelValueSpecReference"
			},
			{
				name:        "y"
				description: "The required vertical position channel, typically bound to the *y* scale."
				type:        "channelValueSpecReference"
			},
			{
				name:        "z"
				description: "An optional ordinal channel for grouping data into (possibly stacked) series to be drawn as separate lines. If not specified, it defaults to\n**fill** if a channel, or **stroke** if a channel."
				type:        "channelValueReference"
			},
		]

	},
	{
		name:        "LineXOptions"
		description: "Options for the lineX mark."
		wire:        false
		extends: ["LineOptions"]
		properties: [
			{
				name:        "y"
				description: "The vertical position channel, typically bound to the *y* scale; defaults to the zero-based index of the data [0, 1, 2, …]."
				type:        "channelValueSpecReference"
				override:    true
			}
		]

	},
	{
		name:        "LineYOptions"
		description: "Options for the lineY mark."
		wire:        false
		extends: ["LineOptions"]
		properties: [
			{
				name:        "x"
				description: "The horizontal position channel, typically bound to the *x* scale; defaults to the zero-based index of the data [0, 1, 2, …]."
				type:        "channelValueSpecReference"
				override:    true
			}
		]

	},
	{
		name:        "Line"
		description: "The line mark."
		extends: ["MarkData", "LineOptions"]
		properties: [
			{
				name:        "mark"
				description: "A line mark that connects control points.\n\nPoints along the line are connected in input order. If there are multiple series via the **z**, **fill**, or **stroke** channel, series are drawn in input order such that the last series is drawn on top. Typically *data* is already in sorted order, such as chronological for time series; if needed, consider a **sort** transform.\n\nIf any **x** or **y** values are invalid (undefined, null, or NaN), the line will be interrupted, resulting in a break that divides the line shape into multiple segments. If a line segment consists of only a single point, it may appear invisible unless rendered with rounded or square line caps. In addition, some curves such as *cardinal-open* only render a visible segment if it contains multiple points.\n\nVariable aesthetic channels are supported: if the **stroke** is defined as a channel, the line will be broken into contiguous overlapping segments when the stroke color changes; the stroke color will apply to the interval spanning the current data point and the following data point. This behavior also applies to the **fill**, **fillOpacity**, **strokeOpacity**,\n**strokeWidth**, **opacity**, **href**, **title**, and **ariaLabel** channels. When any of these channels are used, setting an explicit **z** channel (possibly to null) is strongly recommended."
				required:    true
				type:        "lineMarkLiteral"
			}
		]

	},
	{
		name:        "LineX"
		description: "The lineX mark."
		extends: ["MarkData", "LineXOptions"]
		properties: [
			{
				name:        "mark"
				description: "Like line, except that **x** defaults to the identity function assuming that *data* = [*x₀*, *x₁*, *x₂*, …] and **y** defaults to the zero-based index [0, 1, 2, …]."
				required:    true
				type:        "lineXMarkLiteral"
			}
		]

	},
	{
		name:        "LineY"
		description: "The lineY mark."
		extends: ["MarkData", "LineYOptions"]
		properties: [
			{
				name:        "mark"
				description: "Like line, except **y** defaults to the identity function and assumes that *data* = [*y₀*, *y₁*, *y₂*, …] and **x** defaults to the zero-based index [0, 1, 2, …]."
				required:    true
				type:        "lineYMarkLiteral"
			}
		]

	},
	{
		name:        "ArrowOptions"
		description: "Options for the arrow mark."
		wire:        false
		extends: ["MarkOptions"]
		properties: [
			{
				name:        "x"
				description: "The horizontal position, for vertical arrows; typically bound to the *x* scale; shorthand for setting defaults for both **x1** and **x2**."
				type:        "channelValueSpecReference"
			},
			{
				name:        "y"
				description: "The vertical position, for horizontal arrows; typically bound to the *y* scale; shorthand for setting defaults for both **y1** and **y2**."
				type:        "channelValueSpecReference"
			},
			{
				name:        "x1"
				description: "The starting horizontal position; typically bound to the *x* scale; also sets a default for **x2**."
				type:        "channelValueSpecReference"
			},
			{
				name:        "y1"
				description: "The starting vertical position; typically bound to the *y* scale; also sets a default for **y2**."
				type:        "channelValueSpecReference"
			},
			{
				name:        "x2"
				description: "The ending horizontal position; typically bound to the *x* scale; also sets a default for **x1**."
				type:        "channelValueSpecReference"
			},
			{
				name:        "y2"
				description: "The ending vertical position; typically bound to the *y* scale; also sets a default for **y1**."
				type:        "channelValueSpecReference"
			},
			{
				name:        "bend"
				description: "The angle, a constant in degrees, between the straight line intersecting the arrow’s two control points and the outgoing tangent direction of the arrow from the start point. The angle must be within ±90°; a positive angle will produce a clockwise curve, while a negative angle will produce a counterclockwise curve; zero (the default) will produce a straight line. Use true for 22.5°."
				type:        "arrowOptionsBendType"
			},
			{
				name:        "headAngle"
				description: "How pointy the arrowhead is, in degrees; a constant typically between 0° and 180°, and defaults to 60°."
				type:        "numberOrParamRef"
			},
			{
				name:        "headLength"
				description: "The size of the arrowhead relative to the **strokeWidth**; a constant. Assuming the default of stroke width 1.5px, this is the length of the arrowhead’s side in pixels."
				type:        "numberOrParamRef"
			},
			{
				name:        "inset"
				description: "Shorthand to set the same default for **insetStart** and **insetEnd**."
				type:        "numberOrParamRef"
			},
			{
				name:        "insetStart"
				description: "The starting inset, a constant in pixels; defaults to 0. A positive inset shortens the arrow by moving the starting point towards the endpoint point, while a negative inset extends it by moving the starting point in the opposite direction. A positive starting inset may be useful if the arrow emerges from a dot."
				type:        "numberOrParamRef"
			},
			{
				name:        "insetEnd"
				description: "The ending inset, a constant in pixels; defaults to 0. A positive inset shortens the arrow by moving the ending point towards the starting point, while a negative inset extends it by moving the ending point in the opposite direction. A positive ending inset may be useful if the arrow points to a dot."
				type:        "numberOrParamRef"
			},
			{
				name:        "sweep"
				description: "The sweep order; defaults to 1 indicating a positive (clockwise) bend angle; -1 indicates a negative (anticlockwise) bend angle; 0 effectively clears the bend angle. If set to *-x*, the bend angle is flipped when the ending point is to the left of the starting point — ensuring all arrows bulge up (down if bend is negative); if set to *-y*, the bend angle is flipped when the ending point is above the starting point — ensuring all arrows bulge right (left if bend is negative); the sign is negated for\n*+x* and *+y*."
				type:        "arrowOptionsSweepType"
			},
		]

	},
	{
		name:        "Arrow"
		description: "The arrow mark."
		extends: ["MarkData", "ArrowOptions"]
		properties: [
			{
				name:        "mark"
				description: "An arrow mark, drawing (possibly swoopy) arrows connecting pairs of points."
				required:    true
				type:        "arrowMarkLiteral"
			}
		]

	},
	{
		name:        "LinkOptions"
		description: "Options for the link mark."
		wire:        false
		extends: ["MarkOptions", "MarkerOptions", "CurveAutoOptions"]
		properties: [
			{
				name:        "x"
				description: "The horizontal position, for vertical links; typically bound to the *x* scale; shorthand for setting defaults for both **x1** and **x2**."
				type:        "channelValueSpecReference"
			},
			{
				name:        "y"
				description: "The vertical position, for horizontal links; typically bound to the *y* scale; shorthand for setting defaults for both **y1** and **y2**."
				type:        "channelValueSpecReference"
			},
			{
				name:        "x1"
				description: "The starting horizontal position; typically bound to the *x* scale; also sets a default for **x2**."
				type:        "channelValueSpecReference"
			},
			{
				name:        "y1"
				description: "The starting vertical position; typically bound to the *y* scale; also sets a default for **y2**."
				type:        "channelValueSpecReference"
			},
			{
				name:        "x2"
				description: "The ending horizontal position; typically bound to the *x* scale; also sets a default for **x1**."
				type:        "channelValueSpecReference"
			},
			{
				name:        "y2"
				description: "The ending vertical position; typically bound to the *y* scale; also sets a default for **y1**."
				type:        "channelValueSpecReference"
			},
			{
				name:        "curve"
				description: "The curve (interpolation) method for connecting adjacent points.\n\nSince a link has exactly two points, only the following curves (or a custom curve) are recommended: *linear*, *step*, *step-after*, *step-before*,\n*bump-x*, or *bump-y*. Note that the *linear* curve is incapable of showing a fill since a straight line has zero area. For a curved link, use an arrow mark with the **bend** option.\n\nIf the plot uses a spherical **projection**, the default *auto* **curve** will render links as geodesics; to draw a straight line instead, use the\n*linear* **curve**."
				type:        "linkOptionsCurveType"
				override:    true
			},
		]

	},
	{
		name:        "Link"
		description: "The link mark."
		extends: ["MarkData", "LinkOptions"]
		properties: [
			{
				name:        "mark"
				description: "A link mark, drawing line segments (curves) connecting pairs of points.\n\nIf the plot uses a spherical **projection**, the default *auto* **curve** will render links as geodesics; to draw a straight line instead, use the\n*linear* **curve**."
				required:    true
				type:        "linkMarkLiteral"
			}
		]

	},
]

typeExpressions: {[string]: model.#ShapeExpression} & {
	areaMarkLiteral: {kind: "literal", value: "area"}
	areaXMarkLiteral: {kind: "literal", value: "areaX"}
	areaYMarkLiteral: {kind: "literal", value: "areaY"}
	lineMarkLiteral: {kind: "literal", value: "line"}
	lineXMarkLiteral: {kind: "literal", value: "lineX"}
	lineYMarkLiteral: {kind: "literal", value: "lineY"}
	arrowOptionsBendType: {kind: "union", members: ["number", "boolean", "paramRefReference"]}
	numberOrParamRef: {kind: "union", members: ["number", "paramRefReference"]}
	sweepPositiveX: {kind: "literal", value: "+x"}
	sweepNegativeX: {kind: "literal", value: "-x"}
	sweepPositiveY: {kind: "literal", value: "+y"}
	sweepNegativeY: {kind: "literal", value: "-y"}
	arrowOptionsSweepType: {
		kind: "union"
		members: [
			"number",
			"sweepPositiveX",
			"sweepNegativeX",
			"sweepPositiveY",
			"sweepNegativeY",
			"paramRefReference",
		]
	}
	arrowMarkLiteral: {kind: "literal", value: "arrow"}
	curveAutoProperty: {kind: "indexed-property", property: "curve", contract: "CurveAutoOptions"}
	linkOptionsCurveType: {kind: "union", members: ["curveAutoProperty", "paramRefReference"]}
	linkMarkLiteral: {kind: "literal", value: "link"}
}

typeExpressions: curveAutoProperty: expression: ([for property in common.contractIndex.CurveAutoOptions.properties if property.name == "curve" {property.type}])[0]

contractIndex: {for contract in contracts {(contract.name): contract}}
modelChecks: names: true & list.UniqueItems([for contract in contracts {contract.name}])

referenceNotes: [{marks: ["arrow"], text: "Directional sweep strings (`+x`, `-x`, `+y`, `-y`) are admitted by the specification, but the current SQL-backed runtime interprets them as column names. A missing matching column produces a Binder Error. Use numeric `sweep` values for SQL-backed arrows; the bent-arrow starter uses `1`."}]

declarationFiles: [
	{
		basename: "Area"
		imports: ["ChannelValue", "ChannelValueSpec", "CurveOptions", "MarkData", "MarkOptions", "StackOptions"]
		contracts: ["AreaOptions", "AreaXOptions", "AreaYOptions", "Area", "AreaX", "AreaY"]
	},
	{
		basename: "Line"
		imports: ["ChannelValue", "ChannelValueSpec", "CurveAutoOptions", "MarkData", "MarkOptions", "MarkerOptions"]
		contracts: ["LineOptions", "LineXOptions", "LineYOptions", "Line", "LineX", "LineY"]
	},
	{
		basename: "Arrow"
		imports: ["ParamRef", "ChannelValueSpec", "MarkData", "MarkOptions"]
		contracts: ["ArrowOptions", "Arrow"]
	},
	{
		basename: "Link"
		imports: ["ParamRef", "ChannelValueSpec", "CurveAutoOptions", "MarkData", "MarkOptions", "MarkerOptions"]
		contracts: ["LinkOptions", "Link"]
	},
]

externalReferences: []
