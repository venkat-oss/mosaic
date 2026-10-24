package guidemarks

contracts: [
	{
		name:        "ScaleOptions"
		description: "The scale options used by axis and grid marks."
		wire:        false
		exported:    false
		properties: [
			{
				name:        "interval"
				description: "Enforces uniformity for data at regular intervals, such as integer values or daily samples. The interval may be one of:\n\n- a named time interval such as *day* (for date intervals)\n- a number (for number intervals), defining intervals at integer multiples of *n*\n\nThis option sets the internal transform to the given interval\u2019s\n*interval*.floor function. In addition, the default **domain** will align with interval boundaries."
				type:        "intervalOrParamRef"
			},
			{
				name:        "ticks"
				description: "The desired approximate number of axis ticks, or an explicit array of tick values, or an interval such as *day* or *month*."
				type:        "tickValues"
			},
			{
				name:        "tickSize"
				description: "The length of axis tick marks in pixels; negative values extend in the opposite direction. Defaults to 6 for *x* and *y* axes and *color* and\n*opacity* *ramp* legends, and 0 for *fx* and *fy* axes."
				type:        "numberOrParamRef"
			},
			{
				name:        "tickSpacing"
				description: "The desired approximate spacing between adjacent axis ticks, affecting the default **ticks**; defaults to 80 pixels for *x* and *fx*, and 35 pixels for *y* and *fy*."
				type:        "numberOrParamRef"
			},
			{
				name:        "tickPadding"
				description: "The distance between an axis tick mark and its associated text label (in pixels); often defaults to 3, but may be affected by **xTickSize** and\n**xTickRotate**."
				type:        "numberOrParamRef"
			},
			{
				name:        "tickFormat"
				description: "How to format inputs (abstract values) for axis tick labels; one of:\n\n- a [d3-format][1] string for numeric scales\n- a [d3-time-format][2] string for temporal scales\n\n[1]: https://d3js.org/d3-time [2]: https://d3js.org/d3-time-format"
				type:        "nullableStringOrParamRef"
			},
			{
				name:        "tickRotate"
				description: "The rotation angle of axis tick labels in degrees clocksize; defaults to 0."
				type:        "numberOrParamRef"
			},
			{
				name:        "label"
				description: "A textual label to show on the axis or legend; if null, show no label. By default the scale label is inferred from channel definitions, possibly with an arrow (\u2191, \u2192, \u2193, or \u2190) to indicate the direction of increasing value.\n\nFor axes and legends only."
				type:        "nullableStringOrParamRef"
			},
			{
				name:        "labelAnchor"
				description: "Where to place the axis **label** relative to the plot\u2019s frame. For vertical position scales (*y* and *fy*), may be *top*, *bottom*, or\n*center*; for horizontal position scales (*x* and *fx*), may be *left*,\n*right*, or *center*. Defaults to *center* for ordinal scales (including\n*fx* and *fy*), and otherwise *top* for *y*, and *right* for *x*."
				type:        "labelAnchor"
			},
			{
				name:        "labelOffset"
				description: "The axis **label** position offset (in pixels); default depends on margins and orientation."
				type:        "numberOrParamRef"
			},
			{
				name:        "labelArrow"
				description: "Whether to apply a directional arrow such as \u2192 or \u2191 to the scale label. If\n*auto* (the default), the presence of the arrow depends on whether the scale is ordinal."
				type:        "labelArrow"
			},
		]
	},
	{
		name:        "GridOptions"
		description: "Options for the grid marks."
		wire:        false
		extends: ["GridScaleOptions"]
		properties: [
			{
				name:        "anchor"
				description: "The side of the frame on which to place the axis: *top* or *bottom* for horizontal axes (axisX and axisFx) and their associated vertical grids (gridX and gridFx), or *left* or *right* for vertical axes (axisY and axisFY) and their associated horizontal grids (gridY and gridFy).\n\nThe default **anchor** depends on the associated scale:\n\n- *x* - *bottom*\n- *y* - *left*\n- *fx* - *top* if there is a *bottom* *x* axis, and otherwise *bottom*\n- *fy* - *right* if there is a *left* *y* axis, and otherwise *right*\n\nFor grids, the **anchor** also affects the extent of grid lines when the opposite dimension is specified (**x** for gridY and **y** for gridX)."
				type:        "axisAnchor"
			},
			{
				name:        "color"
				description: "A shorthand for setting both **fill** and **stroke**; affects the stroke of tick vectors and grid rules, and the fill of tick texts and axis label texts; defaults to *currentColor*."
				type:        "markStroke"
			},
			{
				name:        "opacity"
				description: "A shorthand for setting both **fillOpacity** and **strokeOpacity**; affects the stroke opacity of tick vectors and grid rules, and the fill opacity of tick texts and axis label texts; defaults to 1 for axes and 0.1 for grids."
				type:        "markOpacity"
			},
		]
	},
	{
		name:        "AxisOptions"
		description: "Options for the axis marks."
		wire:        false
		extends: ["GridOptions", "MarkOptions", "TextOptions", "AxisScaleOptions",
		]
		properties: [
			{
				name:        "textStroke"
				description: "The tick text **stroke**, say for a *white* outline to improve legibility; defaults to null."
				type:        "markStroke"
			},
			{
				name:        "textStrokeOpacity"
				description: "The tick text **strokeOpacity**; defaults to 1; has no effect unless **textStroke** is set."
				type:        "markStrokeOpacity"
			},
			{
				name:        "textStrokeWidth"
				description: "The tick text **strokeWidth**; defaults to 4; has no effect unless **textStroke** is set."
				type:        "markStrokeWidth"
			},
		]
	},
	{
		name:        "AxisXOptions"
		description: "Options for the axisX and axisFx marks."
		wire:        false
		extends: ["AxisOptions", {name: "TickXOptions", operator: "omit", keys: ["data"]}]
		properties: []
	},
	{
		name:        "AxisYOptions"
		description: "Options for the axisY and axisFy marks."
		wire:        false
		extends: ["AxisOptions", {name: "TickYOptions", operator: "omit", keys: ["data"]}]
		properties: []
	},
	{
		name:        "GridXOptions"
		description: "Options for the gridX and gridFx marks."
		wire:        false
		extends: ["GridOptions", {name: "RuleXOptions", operator: "omit", keys: ["data", "interval"]}]
		properties: []
	},
	{
		name:        "GridYOptions"
		description: "Options for the gridY and gridFy marks."
		wire:        false
		extends: ["GridOptions", {name: "RuleYOptions", operator: "omit", keys: ["data", "interval"]}]
		properties: []
	},
	{
		name:        "AxisX"
		description: "The axisX mark."
		extends: ["AxisXOptions"]
		properties: [
			{
				name:        "mark"
				description: "An axis mark to document the visual encoding of the horizontal position\n*x* scale, comprised of (up to) three marks: a vector for ticks, a text for tick labels, and another text for an axis label. The data defaults to tick values sampled from the *x* scale\u2019s domain; if desired, use one of the **ticks**, **tickSpacing**, or **interval** options.\n\nThe **facetAnchor** option defaults to *bottom-empty* if **anchor** is\n*bottom*, and *top-empty* if **anchor** is *top*. The default margins likewise depend on **anchor** as follows; in order of **marginTop**,\n**marginRight**, **marginBottom**, and **marginLeft**, in pixels:\n\n- *top* - 30, 20, 0, 20\n- *bottom* - 0, 20, 30, 20\n\nFor simplicity, and for consistent layout across plots, default axis margins are not affected by tick labels. If tick labels are too long, either increase the margin or shorten the labels: use the *k* SI-prefix tick format; use the\n**transform** *y*-scale option to show thousands or millions; or use the\n**textOverflow** and **lineWidth** options to clip."
				required:    true
				type:        "axisXKind"
			}
		]
	},
	{
		name:        "AxisFx"
		description: "The axisFx mark."
		extends: ["AxisXOptions"]
		properties: [
			{
				name:        "mark"
				description: "An axis mark to document the visual encoding of the horizontal facet position *fx* scale, comprised of (up to) three marks: a vector for ticks, a text for tick labels, and another text for an axis label. The data defaults to the *fx* scale\u2019s domain; if desired, use one of the **ticks**,\n**tickSpacing**, or **interval** options.\n\nThe **facetAnchor** and **frameAnchor** options defaults to **anchor**. The default margins likewise depend on **anchor** as follows; in order of\n**marginTop**, **marginRight**, **marginBottom**, and **marginLeft**, in pixels:\n\n- *top* - 30, 20, 0, 20\n- *bottom* - 0, 20, 30, 20\n\nFor simplicity, and for consistent layout across plots, default axis margins are not affected by tick labels. If tick labels are too long, either increase the margin or shorten the labels: use the *k* SI-prefix tick format; use the\n**transform** *y*-scale option to show thousands or millions; or use the\n**textOverflow** and **lineWidth** options to clip."
				required:    true
				type:        "axisFxKind"
			}
		]
	},
	{
		name:        "AxisY"
		description: "The axisY mark."
		extends: ["AxisYOptions"]
		properties: [
			{
				name:        "mark"
				description: "An axis mark to document the visual encoding of the vertical position *y* scale, comprised of (up to) three marks: a vector for ticks, a text for tick labels, and another text for an axis label. The data defaults to tick values sampled from the *y* scale\u2019s domain; if desired, use one of the\n**ticks**, **tickSpacing**, or **interval** options.\n\nThe **facetAnchor** option defaults to *right-empty* if **anchor** is\n*right*, and *left-empty* if **anchor** is *left*. The default margins likewise depend on **anchor** as follows; in order of **marginTop**,\n**marginRight**, **marginBottom**, and **marginLeft**, in pixels:\n\n- *right* - 20, 40, 20, 0\n- *left* - 20, 0, 20, 40\n\nFor simplicity, and for consistent layout across plots, default axis margins are not affected by tick labels. If tick labels are too long, either increase the margin or shorten the labels: use the *k* SI-prefix tick format; or use the **textOverflow** and **lineWidth** options to clip."
				required:    true
				type:        "axisYKind"
			}
		]
	},
	{
		name:        "AxisFy"
		description: "The axisFy mark."
		extends: ["AxisYOptions"]
		properties: [
			{
				name:        "mark"
				description: "An axis mark to document the visual encoding of the vertical facet position *fy* scale, comprised of (up to) three marks: a vector for ticks, a text for tick labels, and another text for an axis label. The data defaults to the *fy* scale\u2019s domain; if desired, use one of the **ticks**,\n**tickSpacing**, or **interval** options.\n\nThe **facetAnchor** option defaults to *right-empty* if **anchor** is\n*right*, and *left-empty* if **anchor** is *left*. The default margins likewise depend on **anchor** as follows; in order of **marginTop**,\n**marginRight**, **marginBottom**, and **marginLeft**, in pixels:\n\n- *right* - 20, 40, 20, 0\n- *left* - 20, 0, 20, 40\n\nFor simplicity, and for consistent layout across plots, default axis margins are not affected by tick labels. If tick labels are too long, either increase the margin or shorten the labels: use the *k* SI-prefix tick format; or use the **textOverflow** and **lineWidth** options to clip."
				required:    true
				type:        "axisFyKind"
			}
		]
	},
	{
		name:        "GridX"
		description: "The gridX mark."
		extends: ["GridXOptions"]
		properties: [
			{
				name:        "mark"
				description: "A horizontally-positioned ruleX mark (a vertical line, |) that renders a grid for the *x* scale. The data defaults to tick values sampled from the\n*x* scale\u2019s domain; if desired, use one of the **ticks**, **tickSpacing**, or **interval** options."
				required:    true
				type:        "gridXKind"
			}
		]
	},
	{
		name:        "GridFx"
		description: "The gridFx mark."
		extends: ["GridXOptions"]
		properties: [
			{
				name:        "mark"
				description: "A horizontally-positioned ruleX mark (a vertical line, |) that renders a grid for the *fx* scale. The data defaults to the *fx* scale\u2019s domain; if desired, use the **ticks** option."
				required:    true
				type:        "gridFxKind"
			}
		]
	},
	{
		name:        "GridY"
		description: "The gridY mark."
		extends: ["GridYOptions"]
		properties: [
			{
				name:        "mark"
				description: "A vertically-positioned ruleY mark (a horizontal line, \u2014) that renders a grid for the *y* scale. The data defaults to tick values sampled from the\n*y* scale\u2019s domain; if desired, use one of the **ticks**, **tickSpacing**, or **interval** options."
				required:    true
				type:        "gridYKind"
			}
		]
	},
	{
		name:        "GridFy"
		description: "The gridFy mark."
		extends: ["GridYOptions"]
		properties: [
			{
				name:        "mark"
				description: "A vertically-positioned ruleY mark (a horizontal line, \u2014) that renders a grid for the *fy* scale. The data defaults to the *fy* scale\u2019s domain; if desired, use the **ticks** option."
				required:    true
				type:        "gridFyKind"
			}
		]
	},
	{
		name:        "FrameOptions"
		description: "Options for the frame decoration mark."
		wire:        false
		extends: ["MarkOptions", "InsetOptions", "RectCornerOptions",
		]
		properties: [
			{
				name:        "anchor"
				description: "If null (default), the rectangular outline of the frame is drawn; otherwise the frame is drawn as a line only on the given side, and the\n**rx**, **ry**, **fill**, and **fillOpacity** options are ignored."
				type:        "nullableAxisAnchor"
			}
		]
	},
	{
		name:        "Frame"
		description: "The frame mark."
		extends: ["FrameOptions"]
		properties: [
			{
				name:        "mark"
				description: "Draws a rectangle around the plot\u2019s frame, or if an **anchor** is given, a line on the given side. Useful for visual separation of facets, or in conjunction with axes and grids to fill the frame\u2019s background."
				required:    true
				type:        "frameKind"
			}
		]
	},
	{
		name:        "HexgridOptions"
		description: "Options for the hexgrid mark."
		wire:        false
		extends: ["MarkOptions"]
		properties: [
			{
				name:        "binWidth"
				description: "The distance between centers of neighboring hexagons, in pixels; defaults to 20. Should match the **binWidth** of the hexbin mark."
				type:        "numberOrParamRef"
			}
		]
	},
	{
		name:        "Hexgrid"
		description: "The hexgrid mark."
		extends: ["HexgridOptions"]
		properties: [
			{
				name:        "mark"
				description: "The hexgrid decoration mark complements the hexbin mark, showing the outlines of all hexagons spanning the frame with a default **stroke** of\n*currentColor* and a default **strokeOpacity** of 0.1, similar to the default axis grids.\n\nNote that the **binWidth** option of the hexgrid mark should match that of the hexbin transform. The grid is clipped by the frame. This is a stroke-only mark, and **fill** is not supported; to fill the frame, use the frame mark."
				required:    true
				type:        "hexgridKind"
			}
		]
	},
]
supportContracts: [
	{
		name:        "GridScaleOptions"
		description: "The subset of scale options for grids."
		wire:        false
		exported:    false
		kind:        "alias"
		expression:  "tickPositionOptions"
	},
	{
		name:        "AxisScaleOptions"
		description: "The subset of scale options for axes."
		wire:        false
		exported:    false
		kind:        "alias"
		expression:  "axisLabelOptions"
	},
]
typeExpressions: {
	intervalOrParamRef: {kind: "union", members: ["intervalReference", "paramRefReference"]}
	anyArray: {kind: "array", items: "any"}
	tickValues: {kind: "union", members: ["number", "intervalReference", "anyArray", "paramRefReference"]}
	numberOrParamRef: {kind: "union", members: ["number", "paramRefReference"]}
	nullableStringOrParamRef: {kind: "union", members: ["string", "null", "paramRefReference"]}
	literalCenter: {kind: "literal", value: "center"}
	labelAnchor: {
		kind: "union"
		members: ["literalTop", "literalRight", "literalBottom", "literalLeft", "literalCenter", "paramRefReference"]
	}
	literalUp: {kind: "literal", value: "up"}
	literalDown: {kind: "literal", value: "down"}
	literalTrue: {kind: "literal", value: true}
	literalFalse: {kind: "literal", value: false}
	labelArrow: {
		kind: "union"
		members: [
			"literalAuto",
			"literalUp",
			"literalRight",
			"literalDown",
			"literalLeft",
			"literalNone",
			"literalTrue",
			"literalFalse",
			"null",
			"paramRefReference",
		]
	}
	tickPositionOptions: {kind: "interface-selection", contract: "ScaleOptions", operator: "pick", keys: ["interval", "ticks", "tickSpacing"]}
	axisLabelOptions: {
		kind:     "interface-selection"
		contract: "ScaleOptions"
		operator: "pick"
		keys: ["tickSize", "tickPadding", "tickFormat", "tickRotate", "label", "labelOffset", "labelAnchor", "labelArrow"]

	}
	axisAnchor: {kind: "union", members: ["literalTop", "literalRight", "literalBottom", "literalLeft", "paramRefReference"]}
	markStroke: {kind: "indexed-property", contract: "MarkOptions", property: "stroke", expression: "markOptionsFill"}
	markOpacity: {kind: "indexed-property", contract: "MarkOptions", property: "opacity", expression: "channelValueSpecReference"}
	markStrokeOpacity: {kind: "indexed-property", contract: "MarkOptions", property: "strokeOpacity", expression: "channelValueSpecReference"}
	markStrokeWidth: {kind: "indexed-property", contract: "MarkOptions", property: "strokeWidth", expression: "channelValueSpecReference"}
	axisXKind: {kind: "literal", value: "axisX"}
	axisFxKind: {kind: "literal", value: "axisFx"}
	axisYKind: {kind: "literal", value: "axisY"}
	axisFyKind: {kind: "literal", value: "axisFy"}
	gridXKind: {kind: "literal", value: "gridX"}
	gridFxKind: {kind: "literal", value: "gridFx"}
	gridYKind: {kind: "literal", value: "gridY"}
	gridFyKind: {kind: "literal", value: "gridFy"}
	nullableAxisAnchor: {kind: "union", members: ["literalTop", "literalRight", "literalBottom", "literalLeft", "null", "paramRefReference"]}
	frameKind: {kind: "literal", value: "frame"}
	hexgridKind: {kind: "literal", value: "hexgrid"}
}
declarationFiles: [
	{
		basename: "Axis"
		imports: ["ParamRef", "Interval", "MarkOptions", "RuleXOptions", "RuleYOptions", "TextOptions", "TickXOptions", "TickYOptions"]
		contracts: [
			"ScaleOptions",
			"GridScaleOptions",
			"AxisScaleOptions",
			"GridOptions",
			"AxisOptions",
			"AxisXOptions",
			"AxisYOptions",
			"GridXOptions",
			"GridYOptions",
			"AxisX",
			"AxisFx",
			"AxisY",
			"AxisFy",
			"GridX",
			"GridFx",
			"GridY",
			"GridFy",
		]
	},
	{
		basename: "Frame"
		imports: ["ParamRef", "InsetOptions", "MarkOptions", "RectCornerOptions"]
		contracts: ["FrameOptions", "Frame"]
	},
	{basename: "Hexgrid", imports: ["ParamRef", "MarkOptions"], contracts: ["HexgridOptions", "Hexgrid"]},
]
marks: [
	{name: "frame", contract: "Frame", jsSection: "frame-56", profile: "ordinary"},
	{name: "axisX", contract: "AxisX", jsSection: "axisX-57", profile: "ordinary"},
	{name: "axisY", contract: "AxisY", jsSection: "axisY-58", profile: "ordinary"},
	{name: "axisFx", contract: "AxisFx", jsSection: "axisFx-59", profile: "ordinary"},
	{name: "axisFy", contract: "AxisFy", jsSection: "axisFy-60", profile: "ordinary"},
	{name: "gridX", contract: "GridX", jsSection: "gridX-61", profile: "ordinary"},
	{name: "gridY", contract: "GridY", jsSection: "gridY-62", profile: "ordinary"},
	{name: "gridFx", contract: "GridFx", jsSection: "gridFx-63", profile: "ordinary"},
	{name: "gridFy", contract: "GridFy", jsSection: "gridFy-64", profile: "ordinary"},
	{name: "hexgrid", contract: "Hexgrid", jsSection: "hexgrid-45", profile: "ordinary"},
]
referenceGroups: [
	{title: "Frame", names: ["frame"], sections: {js: "js-Frame-14", python: "python-Frame-45"}},
	{title: "Axis", names: ["axisX", "axisY", "axisFx", "axisFy"], sections: {js: "js-Axis-5", python: "python-Axis-36"}},
	{title: "Grid", names: ["gridX", "gridY", "gridFx", "gridFy"], sections: {js: "js-Grid-16", python: "python-Grid-47"}},
	{title: "Hexgrid", names: ["hexgrid"], sections: {js: "js-Hexgrid-19", python: "python-Hexgrid-50"}},
]
