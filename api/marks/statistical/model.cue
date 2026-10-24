package statisticalmarks

contracts: [
	{
		name:        "HexbinOptions"
		description: "Options for the hexbin mark."
		wire:        false
		extends: ["DotOptions", "TextStyles"]
		properties: [
			{
				name:        "type"
				description: "The basic mark type to use for hex-binned values. Defaults to a hexagon mark; dot and text marks are also supported."
				type:        "hexbinMarkType"
			},
			{
				name:        "binWidth"
				description: "The distance between centers of neighboring hexagons, in pixels; defaults to 20. If also using a hexgrid mark, use matching **binWidth** values."
				type:        "numberOrParamRef"
			},
			{
				name:        "z"
				description: "How to subdivide bins. If not specified, defaults to the *fill* channel, if any, or the *stroke* channel, if any. If null, bins will not be subdivided."
				type:        "channelValueReference"
				override:    true
			},
		]
	},
	{
		name:        "Hexbin"
		description: "The hexbin mark."
		extends: ["MarkData", "HexbinOptions"]
		properties: [
			{
				name:        "mark"
				description: "A hexbin mark that bins **x** and **y** data into a hexagonal grid and visualizes aggregate functions per bin (e.g., count for binned density). Aggregate functions can be used for fill, stroke, or r (radius) options."
				required:    true
				type:        "hexbinKind"
			}
		]
	},
	{
		name:        "RegressionOptions"
		description: "Options for regression marks."
		wire:        false
		exported:    false
		extends: ["MarkOptions"]
		properties: [
			{
				name:        "ci"
				description: "The confidence interval in (0, 1), or 0 to hide bands; defaults to 0.95."
				type:        "numberOrParamRef"
			},
			{
				name:        "precision"
				description: "The distance in pixels between samples of the confidence band; defaults to 4."
				type:        "numberOrParamRef"
			},
			{
				name:        "z"
				description: "An optional ordinal channel for grouping data into (possibly stacked) series, producing an independent regression for each group. If not specified, it defaults to **fill** if a channel, or **stroke** if a channel."
				type:        "channelValueReference"
			},
		]
	},
	{
		name:        "RegressionYOptions"
		description: "Options for the regressionY mark."
		wire:        false
		extends: ["RegressionOptions"]
		properties: [
			{
				name:        "x"
				description: "The independent variable horizontal position channel, typically bound to the *x* scale; defaults to the zero-based index of the data [0, 1, 2, \u2026]."
				type:        "channelValueSpecReference"
			},
			{
				name:        "y"
				description: "The dependent variable vertical position channel, typically bound to the\n*y* scale; defaults to identity, assuming that *data* = [*y\u2080*, *y\u2081*, *y\u2082*, \u2026]."
				type:        "channelValueSpecReference"
			},
		]
	},
	{
		name:        "RegressionY"
		description: "The regressionY mark."
		extends: ["MarkData", "RegressionYOptions"]
		properties: [
			{
				name:        "mark"
				description: "A mark that draws [linear regression][1] lines with confidence bands, representing the estimated relation of a dependent variable (*y*) on an independent variable (*x*).\n\nThe linear regression line is fit using the [least squares][2] approach. See Torben Jansen\u2019s [\u201cLinear regression with confidence bands\u201d][3] and [this StatExchange question][4] for details on the confidence interval calculation.\n\nMultiple regressions can be produced by specifying a **z**, **fill**, or\n**stroke** channel.\n\n[1]: https://en.wikipedia.org/wiki/Linear_regression [2]: https://en.wikipedia.org/wiki/Least_squares [3]: https://observablehq.com/@toja/linear-regression-with-confidence-bands [4]: https://stats.stackexchange.com/questions/101318/understanding-shape-and-calculation-of-confidence-bands-in-linear-regression"
				required:    true
				type:        "regressionYKind"
			}
		]
	},
	{
		name:        "ErrorBarOptions"
		description: "Options for errorbar marks."
		wire:        false
		exported:    false
		extends: ["MarkOptions", "MarkerOptions"]
		properties: [
			{name: "ci", description: "The confidence interval in (0, 1); defaults to 0.95.", type: "numberOrParamRef"},
			{
				name:        "z"
				description: "An optional ordinal channel for grouping data, producing an independent error bar for each group. If not specified, it defaults to **stroke** if a channel."
				type:        "channelValueReference"
			},
		]
	},
	{
		name:        "ErrorBarXOptions"
		description: "Options for the errorbarX mark."
		wire:        false
		extends: ["ErrorBarOptions"]
		properties: [
			{
				name:        "x"
				description: "The dependent variable horizontal position channel, typically bound to the\n*x* scale."
				required:    true
				type:        "channelValueSpecReference"
			},
			{
				name:        "y"
				description: "The independent variable vertical position channel, typically bound to the *y* scale; defaults to the zero-based index of the data [0, 1, 2, \u2026]."
				type:        "channelValueSpecReference"
			},
		]
	},
	{
		name:        "ErrorBarX"
		description: "The errorbarX mark."
		extends: ["MarkData", "ErrorBarXOptions"]
		properties: [
			{
				name:        "mark"
				description: "A mark that draws error bars for a calculated parametric confidence interval for a dependent variable (*x*), potentially grouped by an independent variable (*y*).\n\nThis mark aggregates raw values to produce a [parametric confidence interval][1] of the mean, assuming a normal distribution. To instead visualize pre-computed interval values or custom aggregations, use a **ruleY** mark with specified **x1** and **x2** channels.\n\nMultiple error bars can be produced by specifying a **z** or **stroke** channel. Set the **marker** option to `'tick'` to add small perpendicular lines at the start and end of the error interval.\n\n[1]: https://en.wikipedia.org/wiki/Normal_distribution#Confidence_intervals"
				required:    true
				type:        "errorbarXKind"
			}
		]
	},
	{
		name:        "ErrorBarYOptions"
		description: "Options for the errorbarY mark."
		wire:        false
		extends: ["ErrorBarOptions"]
		properties: [
			{
				name:        "x"
				description: "The independent variable horizontal position channel, typically bound to the *x* scale; defaults to the zero-based index of the data [0, 1, 2, \u2026]."
				type:        "channelValueSpecReference"
			},
			{
				name:        "y"
				description: "The dependent variable vertical position channel, typically bound to the\n*y* scale."
				required:    true
				type:        "channelValueSpecReference"
			},
		]
	},
	{
		name:        "ErrorBarY"
		description: "The errorbarY mark."
		extends: ["MarkData", "ErrorBarYOptions"]
		properties: [
			{
				name:        "mark"
				description: "A mark that draws error bars for a calculated parametric confidence interval for a dependent variable (*y*), potentially grouped by an independent variable (*x*).\n\nThis mark aggregates raw values to produce a [parametric confidence interval][1] of the mean, assuming a normal distribution. To instead visualize pre-computed interval values or custom aggregations, use a **ruleX** mark with specified **y1** and **y2** channels.\n\nMultiple error bars can be produced by specifying a **z** or **stroke** channel. Set the **marker** option to `'tick'` to add small perpendicular lines at the start and end of the error interval.\n\n[1]: https://en.wikipedia.org/wiki/Normal_distribution#Confidence_intervals"
				required:    true
				type:        "errorbarYKind"
			}
		]
	},
]
typeExpressions: {
	dotKind: {kind: "literal", value: "dot"}
	circleKind: {kind: "literal", value: "circle"}
	hexagonKind: {kind: "literal", value: "hexagon"}
	textKind: {kind: "literal", value: "text"}
	hexbinMarkType: {
		kind: "union"
		members: ["dotKind", "circleKind", "hexagonKind", "textKind", "paramRefReference"]
	}
	numberOrParamRef: {kind: "union", members: ["number", "paramRefReference"]}
	hexbinKind: {kind: "literal", value: "hexbin"}
	regressionYKind: {kind: "literal", value: "regressionY"}
	errorbarXKind: {kind: "literal", value: "errorbarX"}
	errorbarYKind: {kind: "literal", value: "errorbarY"}
}
declarationFiles: [
	{
		basename: "Hexbin"
		imports: ["ParamRef", "DotOptions", "ChannelValue", "MarkData", "TextStyles"]
		contracts: ["HexbinOptions", "Hexbin"]
	},
	{
		basename: "Regression"
		imports: ["ParamRef", "ChannelValue", "ChannelValueSpec", "MarkData", "MarkOptions"]
		contracts: ["RegressionOptions", "RegressionYOptions", "RegressionY"]
	},
	{
		basename: "ErrorBar"
		imports: ["ParamRef", "ChannelValue", "ChannelValueSpec", "MarkData", "MarkOptions", "MarkerOptions"]
		contracts: ["ErrorBarOptions", "ErrorBarXOptions", "ErrorBarX", "ErrorBarYOptions", "ErrorBarY"]
	},
]
marks: [
	{name: "hexbin", contract: "Hexbin", jsSection: "hexbin-44", profile: "implicit", runtimeClass: "HexbinMark"},
	{
		name:         "regressionY"
		contract:     "RegressionY"
		jsSection:    "regressionY-46"
		profile:      "implicit"
		runtimeClass: "RegressionMark"
	},
	{
		name:         "errorbarX"
		contract:     "ErrorBarX"
		jsSection:    "errorbarX-47"
		profile:      "explicit"
		runtimeClass: "ErrorBarMark"
		runtimeType:  "ruleY"
	},
	{
		name:         "errorbarY"
		contract:     "ErrorBarY"
		jsSection:    "errorbarY-48"
		profile:      "explicit"
		runtimeClass: "ErrorBarMark"
		runtimeType:  "ruleX"
	},
]
referenceGroups: [
	{title: "Hexbin", names: ["hexbin"], sections: {js: "js-Hexbin-18", python: "python-Hexbin-49"}},
	{title: "Regression", names: ["regressionY"], sections: {js: "js-Regression-22", python: "python-Regression-53"}},
	{title: "Error Bar", names: ["errorbarX", "errorbarY"], sections: {js: "js-ErrorBar", python: "python-ErrorBar"}},
]
