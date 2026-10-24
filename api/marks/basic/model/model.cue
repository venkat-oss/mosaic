package basicmodel

import (
	"list"
	"idl.uw.edu/mosaic/api/model"
)

contracts: [...model.#ShapeContract] & [
	{
		name:        "BarOptions"
		description: "Options for the barX and barY marks."
		wire:        false
		exported:    false
		extends: ["MarkOptions", "InsetOptions", "RectCornerOptions", "StackOptions",
		]
		properties: [
			{
				name:        "interval"
				description: "How to convert a continuous value (**x** for barX, or **y** for barY) into an interval (**x1** and **x2** for barX, or **y1** and **y2** for barY); one of:\n\n- a named time interval such as *day* (for date intervals)\n- a number (for number intervals), defining intervals at integer multiples of *n*\n\nSetting this option disables the implicit stack transform (stackX for barX, or stackY for barY)."
				type:        "intervalOrParamRef"
			}
		]
	},
	{
		name:        "BarXOptions"
		description: "Options for the barX mark."
		wire:        false
		extends: ["BarOptions"]
		properties: [
			{
				name:        "x"
				description: "The horizontal position (or length/width) channel, typically bound to the\n*x* scale.\n\nIf neither **x1** nor **x2** nor **interval** is specified, an implicit stackX transform is applied and **x** defaults to the identity function, assuming that *data* = [*x\u2080*, *x\u2081*, *x\u2082*, \u2026]. Otherwise if an **interval** is specified, then **x1** and **x2** are derived from **x**, representing the lower and upper bound of the containing interval, respectively. Otherwise, if only one of **x1** or **x2** is specified, the other defaults to **x**, which defaults to zero."
				type:        "channelValueIntervalSpecReference"
			},
			{
				name:        "x1"
				description: "The required primary (starting, often left) horizontal position channel, typically bound to the *x* scale. Setting this option disables the implicit stackX transform.\n\nIf *x* represents ordinal values, use a cell mark instead."
				type:        "channelValueSpecReference"
			},
			{
				name:        "x2"
				description: "The required secondary (ending, often right) horizontal position channel, typically bound to the *x* scale. Setting this option disables the implicit stackX transform.\n\nIf *x* represents ordinal values, use a cell mark instead."
				type:        "channelValueSpecReference"
			},
			{
				name:        "y"
				description: "The optional vertical position of the bar; a ordinal channel typically bound to the *y* scale. If not specified, the bar spans the vertical extent of the frame; otherwise the *y* scale must be a *band* scale.\n\nIf *y* represents quantitative or temporal values, use a rectX mark instead."
				type:        "channelValueSpecReference"
			},
		]
	},
	{
		name:        "BarYOptions"
		description: "Options for the barY mark."
		wire:        false
		extends: ["BarOptions"]
		properties: [
			{
				name:        "y"
				description: "The vertical position (or length/height) channel, typically bound to the\n*y* scale.\n\nIf neither **y1** nor **y2** nor **interval** is specified, an implicit stackY transform is applied and **y** defaults to the identity function, assuming that *data* = [*y\u2080*, *y\u2081*, *y\u2082*, \u2026]. Otherwise if an **interval** is specified, then **y1** and **y2** are derived from **y**, representing the lower and upper bound of the containing interval, respectively. Otherwise, if only one of **y1** or **y2** is specified, the other defaults to **y**, which defaults to zero."
				type:        "channelValueIntervalSpecReference"
			},
			{
				name:        "y1"
				description: "The required primary (starting, often bottom) vertical position channel, typically bound to the *y* scale. Setting this option disables the implicit stackY transform.\n\nIf *y* represents ordinal values, use a cell mark instead."
				type:        "channelValueSpecReference"
			},
			{
				name:        "y2"
				description: "The required secondary (ending, often top) horizontal position channel, typically bound to the *y* scale. Setting this option disables the implicit stackY transform.\n\nIf *y* represents ordinal values, use a cell mark instead."
				type:        "channelValueSpecReference"
			},
			{
				name:        "x"
				description: "The optional horizontal position of the bar; a ordinal channel typically bound to the *x* scale. If not specified, the bar spans the horizontal extent of the frame; otherwise the *x* scale must be a *band* scale.\n\nIf *x* represents quantitative or temporal values, use a rectY mark instead."
				type:        "channelValueSpecReference"
			},
		]
	},
	{
		name:        "BarX"
		description: "The barX mark."
		extends: ["MarkData", "BarXOptions"]
		properties: [
			{
				name:        "mark"
				description: "A horizontal bar mark. The required *x* values should be quantitative or temporal, and the optional *y* values should be ordinal.\n\nIf neither **x1** nor **x2** nor **interval** is specified, an implicit stackX transform is applied and **x** defaults to the identity function, assuming that *data* = [*x\u2080*, *x\u2081*, *x\u2082*, \u2026]. Otherwise if an **interval** is specified, then **x1** and **x2** are derived from **x**, representing the lower and upper bound of the containing interval, respectively. Otherwise, if only one of **x1** or **x2** is specified, the other defaults to **x**, which defaults to zero.\n\nThe optional **y** ordinal channel specifies the vertical position; it is typically bound to the *y* scale, which must be a *band* scale. If the\n**y** channel is not specified, the bar will span the vertical extent of the plot\u2019s frame.\n\nIf *y* is quantitative, use the rectX mark instead. If *x* is ordinal, use the cell mark instead."
				required:    true
				type:        "barXKind"
			}
		]
	},
	{
		name:        "BarY"
		description: "The barY mark."
		extends: ["MarkData", "BarYOptions"]
		properties: [
			{
				name:        "mark"
				description: "A vertical bar mark. The required *y* values should be quantitative or temporal, and the optional *x* values should be ordinal.\n\nIf neither **y1** nor **y2** nor **interval** is specified, an implicit stackY transform is applied and **y** defaults to the identity function, assuming that *data* = [*y\u2080*, *y\u2081*, *y\u2082*, \u2026]. Otherwise if an **interval** is specified, then **y1** and **y2** are derived from **y**, representing the lower and upper bound of the containing interval, respectively. Otherwise, if only one of **y1** or **y2** is specified, the other defaults to **y**, which defaults to zero.\n\nThe optional **x** ordinal channel specifies the horizontal position; it is typically bound to the *x* scale, which must be a *band* scale. If the\n**x** channel is not specified, the bar will span the horizontal extent of the plot\u2019s frame.\n\nIf *x* is quantitative, use the rectY mark instead. If *y* is ordinal, use the cell mark instead."
				required:    true
				type:        "barYKind"
			}
		]
	},
	{
		name:        "CellOptions"
		description: "Options for the cell mark."
		wire:        false
		extends: ["MarkOptions", "InsetOptions", "RectCornerOptions",
		]
		properties: [
			{
				name:        "x"
				description: "The horizontal position of the cell; an optional ordinal channel typically bound to the *x* scale. If not specified, the cell spans the horizontal extent of the frame; otherwise the *x* scale must be a *band* scale.\n\nIf *x* represents quantitative or temporal values, use a barX mark instead; if *y* is also quantitative or temporal, use a rect mark."
				type:        "channelValueSpecReference"
			},
			{
				name:        "y"
				description: "The vertical position of the cell; an optional ordinal channel typically bound to the *y* scale. If not specified, the cell spans the vertical extent of the frame; otherwise the *y* scale must be a *band* scale.\n\nIf *y* represents quantitative or temporal values, use a barY mark instead; if *x* is also quantitative or temporal, use a rect mark."
				type:        "channelValueSpecReference"
			},
		]
	},
	{
		name:        "Cell"
		description: "The cell mark."
		extends: ["MarkData", "CellOptions"]
		properties: [
			{
				name:        "mark"
				description: "A rectangular cell mark. Along with **x** and/or **y**, a **fill** channel is typically specified to encode value as color.\n\nIf neither **x** nor **y** are specified, *data* is assumed to be an array of pairs [[*x\u2080*, *y\u2080*], [*x\u2081*, *y\u2081*], [*x\u2082*, *y\u2082*], \u2026] such that **x** = [*x\u2080*,\n*x\u2081*, *x\u2082*, \u2026] and **y** = [*y\u2080*, *y\u2081*, *y\u2082*, \u2026].\n\nBoth **x** and **y** should be ordinal; if only **x** is quantitative (or temporal), use a barX mark; if only **y** is quantitative, use a barY mark; if both are quantitative, use a rect mark."
				required:    true
				type:        "cellKind"
			}
		]
	},
	{
		name:        "CellX"
		description: "The cellX mark."
		extends: ["MarkData", "CellOptions"]
		properties: [
			{
				name:        "mark"
				description: "Like cell, but **x** defaults to the zero-based index [0, 1, 2, \u2026], and if\n**stroke** is not a channel, **fill** defaults to the identity function, assuming that *data* = [*x\u2080*, *x\u2081*, *x\u2082*, \u2026]."
				required:    true
				type:        "cellXKind"
			}
		]
	},
	{
		name:        "CellY"
		description: "The cellY mark."
		extends: ["MarkData", "CellOptions"]
		properties: [
			{
				name:        "mark"
				description: "Like cell, but **y** defaults to the zero-based index [0, 1, 2, \u2026], and if\n**stroke** is not a channel, **fill** defaults to the identity function, assuming that *data* = [*y\u2080*, *y\u2081*, *y\u2082*, \u2026]."
				required:    true
				type:        "cellYKind"
			}
		]
	},
	{
		name:        "DotOptions"
		description: "Options for the dot mark."
		wire:        false
		extends: ["MarkOptions"]
		properties: [
			{
				name:        "x"
				description: "The horizontal position channel specifying the dot\u2019s center, typically bound to the *x* scale."
				type:        "channelValueSpecReference"
			},
			{
				name:        "y"
				description: "The vertical position channel specifying the dot\u2019s center, typically bound to the *y* scale."
				type:        "channelValueSpecReference"
			},
			{name: "z", description: "An optional ordinal channel for grouping data into series.", type: "channelValueReference"},
			{
				name:        "r"
				description: "The radius of dots; either a channel or constant. When a number, it is interpreted as a constant radius in pixels. Otherwise it is interpreted as a channel, typically bound to the *r* channel, which defaults to the *sqrt* type for proportional symbols. The radius defaults to 4.5 pixels when using the **symbol** channel, and otherwise 3 pixels. Dots with a nonpositive radius are not drawn."
				type:        "channelSpecOrNumberOrParamRef"
			},
			{
				name:        "rotate"
				description: "The rotation angle of dots in degrees clockwise; either a channel or a constant. When a number, it is interpreted as a constant; otherwise it is interpreted as a channel. Defaults to 0\u00b0, pointing up."
				type:        "channelOrNumberOrParamRef"
			},
			{
				name:        "symbol"
				description: "The categorical symbol; either a channel or a constant. A constant symbol can be specified by a valid symbol name such as *star*, or a symbol object (implementing the draw method); otherwise it is interpreted as a channel. Defaults to *circle* for the **dot** mark, and *hexagon* for the\n**hexagon** mark.\n\nIf the **symbol** channel\u2019s values are all symbols, symbol names, or nullish, the channel is unscaled (values are interpreted literally); otherwise, the channel is bound to the *symbol* scale."
				type:        "channelSpecOrSymbolOrParamRef"
			},
			{
				name:        "frameAnchor"
				description: "The frame anchor specifies defaults for **x** and **y** based on the plot\u2019s frame; it may be one of the four sides (*top*, *right*, *bottom*, *left*), one of the four corners (*top-left*, *top-right*, *bottom-right*,\n*bottom-left*), or the *middle* of the frame. For example, for dots distributed horizontally at the top of the frame:\n\n```js Plot.dot(data, {x: \"date\", frameAnchor: \"top\"}) ```"
				type:        "frameAnchorOrParamRef"
			},
		]
	},
	{
		name:        "DotXOptions"
		description: "Options for the dotX mark."
		wire:        false
		extends: [{name: "DotOptions", operator: "omit", keys: ["y"]}]
		properties: [
			{
				name:        "y"
				description: "The vertical position of the dot\u2019s center, typically bound to the *y* scale."
				type:        "channelValueIntervalSpecReference"
			},
			{
				name:        "interval"
				description: "An interval (such as *day* or a number), to transform **y** values to the middle of the interval."
				type:        "intervalOrParamRef"
			},
		]
	},
	{
		name:        "DotYOptions"
		description: "Options for the dotY mark."
		wire:        false
		extends: [{name: "DotOptions", operator: "omit", keys: ["x"]}]
		properties: [
			{
				name:        "x"
				description: "The horizontal position of the dot\u2019s center, typically bound to the *x* scale."
				type:        "channelValueIntervalSpecReference"
			},
			{
				name:        "interval"
				description: "An interval (such as *day* or a number), to transform **x** values to the middle of the interval."
				type:        "intervalOrParamRef"
			},
		]
	},
	{
		name:        "Dot"
		description: "The dot mark."
		extends: ["MarkData", "DotOptions"]
		properties: [
			{
				name:        "mark"
				description: "A dot mark that draws circles, or other symbols, as in a scatterplot.\n\nIf either **x** or **y** is not specified, the default is determined by the\n**frameAnchor** option. If none of **x**, **y**, and **frameAnchor** are specified, *data* is assumed to be an array of pairs [[*x\u2080*, *y\u2080*], [*x\u2081*,\n*y\u2081*], [*x\u2082*, *y\u2082*], \u2026] such that **x** = [*x\u2080*, *x\u2081*, *x\u2082*, \u2026] and **y** = [*y\u2080*, *y\u2081*, *y\u2082*, \u2026].\n\nDots are sorted by descending radius **r** by default to mitigate overplotting; set the **sort** option to null to draw them in input order."
				required:    true
				type:        "dotKind"
			}
		]
	},
	{
		name:        "DotX"
		description: "The dotX mark."
		extends: ["MarkData", "DotXOptions"]
		properties: [
			{
				name:        "mark"
				description: "Like dot, except that **x** defaults to the identity function, assuming that\n*data* = [*x\u2080*, *x\u2081*, *x\u2082*, \u2026].\n\nIf an **interval** is specified, such as *day*, **y** is transformed to the middle of the interval."
				required:    true
				type:        "dotXKind"
			}
		]
	},
	{
		name:        "DotY"
		description: "The dotY mark."
		extends: ["MarkData", "DotYOptions"]
		properties: [
			{
				name:        "mark"
				description: "Like dot, except that **y** defaults to the identity function, assuming that\n*data* = [*y\u2080*, *y\u2081*, *y\u2082*, \u2026].\n\nIf an **interval** is specified, such as *day*, **x** is transformed to the middle of the interval."
				required:    true
				type:        "dotYKind"
			}
		]
	},
	{
		name:        "Circle"
		description: "The circle mark."
		extends: ["MarkData", {name: "DotOptions", operator: "exclude", keys: ["symbol"]}]
		properties: [
			{
				name:        "mark"
				description: "Like dot, except that the **symbol** option is set to *circle*."
				required:    true
				type:        "circleKind"
			}
		]
	},
	{
		name:        "Hexagon"
		description: "The hexagon mark."
		extends: ["MarkData", {name: "DotOptions", operator: "exclude", keys: ["symbol"]}]
		properties: [
			{
				name:        "mark"
				description: "Like dot, except that the **symbol** option is set to *hexagon*."
				required:    true
				type:        "hexagonKind"
			}
		]
	},
	{
		name:        "RectCornerOptions"
		description: "Options for marks that render rectangles, including bar, cell, and rect."
		wire:        false
		properties: [
			{
				name:        "rx"
				description: "The rounded corner [*x*-radius][1], either in pixels or as a percentage of the rect width. If **rx** is not specified, it defaults to **ry** if present, and otherwise draws square corners.\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/rx"
				type:        "numberOrStringOrParamRef"
			},
			{
				name:        "ry"
				description: "The rounded corner [*y*-radius][1], either in pixels or as a percentage of the rect height. If **ry** is not specified, it defaults to **rx** if present, and otherwise draws square corners.\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/ry"
				type:        "numberOrStringOrParamRef"
			},
		]
	},
	{
		name:        "RectOptions"
		description: "Options for the rect mark."
		wire:        false
		extends: ["MarkOptions", "InsetOptions", "RectCornerOptions", "StackOptions",
		]
		properties: [
			{
				name:        "x"
				description: "The horizontal position (or length/width) channel, typically bound to the\n*x* scale.\n\nIf an **interval** is specified, then **x1** and **x2** are derived from\n**x**, representing the lower and upper bound of the containing interval, respectively. For example, for a vertical bar chart of items sold by day:\n\n```js Plot.rectY(sales, {x: \"date\", interval: \"day\", y2: \"items\"}) ```\n\nIf *x* represents ordinal values, use a bar or cell mark instead."
				type:        "channelValueIntervalSpecReference"
			},
			{
				name:        "x1"
				description: "The required primary (starting, often left) horizontal position channel, typically bound to the *x* scale. Setting this option disables the rectX mark\u2019s implicit stackX transform.\n\nIf *x* represents ordinal values, use a bar or cell mark instead."
				type:        "channelValueSpecReference"
			},
			{
				name:        "x2"
				description: "The required secondary (ending, often right) horizontal position channel, typically bound to the *x* scale. Setting this option disables the rectX mark\u2019s implicit stackX transform.\n\nIf *x* represents ordinal values, use a bar or cell mark instead."
				type:        "channelValueSpecReference"
			},
			{
				name:        "y"
				description: "The vertical position (or length/height) channel, typically bound to the\n*y* scale.\n\nIf an **interval** is specified, then **y1** and **y2** are derived from\n**y**, representing the lower and upper bound of the containing interval, respectively. For example, for a horizontal bar chart of items sold by day:\n\n```js Plot.rectX(sales, {y: \"date\", interval: \"day\", x2: \"items\"}) ```\n\nIf *y* represents ordinal values, use a bar or cell mark instead."
				type:        "channelValueIntervalSpecReference"
			},
			{
				name:        "y1"
				description: "The required primary (starting, often bottom) vertical position channel, typically bound to the *y* scale. Setting this option disables the rectY mark\u2019s implicit stackY transform.\n\nIf *y* represents ordinal values, use a bar or cell mark instead."
				type:        "channelValueSpecReference"
			},
			{
				name:        "y2"
				description: "The required secondary (ending, often top) vertical position channel, typically bound to the *y* scale. Setting this option disables the rectY mark\u2019s implicit stackY transform.\n\nIf *y* represents ordinal values, use a bar or cell mark instead."
				type:        "channelValueSpecReference"
			},
			{
				name:        "interval"
				description: "How to convert a continuous value (**x** for rectY, **y** for rectX, or both for rect) into an interval (**x1** and **x2** for rectY, or **y1** and\n**y2** for rectX, or both for rect); one of:\n\n- a named time interval such as *day* (for date intervals)\n- a number (for number intervals), defining intervals at integer multiples of *n*\n\nSetting this option disables the implicit stack transform (stackX for rectX, or stackY for rectY)."
				type:        "intervalOrParamRef"
			},
		]
	},
	{
		name:        "RectXOptions"
		description: "Options for the rectX mark."
		wire:        false
		extends: ["RectOptions"]
		properties: [
			{
				name:        "x"
				description: "The horizontal position (or length/width) channel, typically bound to the\n*x* scale.\n\nIf neither **x1** nor **x2** is specified, an implicit stackX transform is applied and **x** defaults to the identity function, assuming that *data* = [*x\u2080*, *x\u2081*, *x\u2082*, \u2026]. Otherwise, if only one of **x1** or **x2** is specified, the other defaults to **x**, which defaults to zero."
				type:        "channelValueSpecReference"
				override:    true
			}
		]
	},
	{
		name:        "RectYOptions"
		description: "Options for the rectY mark."
		wire:        false
		extends: ["RectOptions"]
		properties: [
			{
				name:        "y"
				description: "The vertical position (or length/height) channel, typically bound to the\n*y* scale.\n\nIf neither **y1** nor **y2** is specified, an implicit stackY transform is applied and **y** defaults to the identity function, assuming that *data* = [*y\u2080*, *y\u2081*, *y\u2082*, \u2026]. Otherwise, if only one of **y1** or **y2** is specified, the other defaults to **y**, which defaults to zero."
				type:        "channelValueSpecReference"
				override:    true
			}
		]
	},
	{
		name:        "Rect"
		description: "The rect mark."
		extends: ["MarkData", "RectOptions"]
		properties: [
			{
				name:        "mark"
				description: "A rect mark. The rectangle extends horizontally from **x1** to **x2**, and vertically from **y1** to **y2**. The position channels are often derived with a transform.\n\nWhen **y** extends from zero, for example for a histogram where the height of each rect reflects a count of values, use the rectY mark for an implicit stackY transform; similarly, if **x** extends from zero, use the rectX mark for an implicit stackX transform.\n\nIf an **interval** is specified, then **x1** and **x2** are derived from\n**x**, and **y1** and **y2** are derived from **y**, each representing the lower and upper bound of the containing interval, respectively.\n\nBoth *x* and *y* should be quantitative or temporal; otherwise, use a bar or cell mark."
				required:    true
				type:        "rectKind"
			}
		]
	},
	{
		name:        "RectX"
		description: "The rectX mark."
		extends: ["MarkData", "RectXOptions"]
		properties: [
			{
				name:        "mark"
				description: "Like rect, but if neither **x1** nor **x2** is specified, an implicit stackX transform is applied to **x**, and if **x** is not specified, it defaults to the identity function, assuming that *data* is an array of numbers [*x\u2080*, *x\u2081*, *x\u2082*, \u2026]."
				required:    true
				type:        "rectXKind"
			}
		]
	},
	{
		name:        "RectY"
		description: "The rectY mark."
		extends: ["MarkData", "RectYOptions"]
		properties: [
			{
				name:        "mark"
				description: "Like rect, but if neither **y1** nor **y2** is specified, apply an implicit stackY transform is applied to **y**, and if **y** is not specified, it defaults to the identity function, assuming that *data* is an array of numbers [*y\u2080*, *y\u2081*, *y\u2082*, \u2026]."
				required:    true
				type:        "rectYKind"
			}
		]
	},
	{
		name:        "RuleOptions"
		description: "Options for the ruleX and ruleY marks."
		wire:        false
		exported:    false
		extends: ["MarkOptions", "MarkerOptions"]
		properties: [
			{
				name:        "interval"
				description: "How to convert a continuous value (**y** for ruleX, or **x** for ruleY) into an interval (**y1** and **y2** for ruleX, or **x1** and **x2** for ruleY); one of:\n\n- a named time interval such as *day* (for date intervals)\n- a number (for number intervals), defining intervals at integer multiples of *n*"
				type:        "intervalOrParamRef"
			}
		]
	},
	{
		name:        "RuleXOptions"
		description: "Options for the ruleX mark."
		wire:        false
		extends: ["RuleOptions",
			{name: "InsetOptions", operator: "omit", keys: ["insetLeft", "insetRight"]},
		]
		properties: [
			{
				name:        "x"
				description: "The horizontal position of the tick; an optional channel bound to the *x* scale. If not specified, the rule will be horizontally centered in the plot\u2019s frame."
				type:        "channelValueSpecReference"
			},
			{
				name:        "y"
				description: "Shorthand for specifying both the primary and secondary vertical position of the tick as the bounds of the containing interval; can only be used in conjunction with the **interval** option."
				type:        "channelValueIntervalSpecReference"
			},
			{
				name:        "y1"
				description: "The primary (starting, often bottom) vertical position of the tick; a channel bound to the *y* scale.\n\nIf *y* represents ordinal values, use a tickX mark instead."
				type:        "channelValueSpecReference"
			},
			{
				name:        "y2"
				description: "The secondary (ending, often top) vertical position of the tick; a channel bound to the *y* scale.\n\nIf *y* represents ordinal values, use a tickX mark instead."
				type:        "channelValueSpecReference"
			},
		]
	},
	{
		name:        "RuleYOptions"
		description: "Options for the ruleY mark."
		wire:        false
		extends: ["RuleOptions",
			{name: "InsetOptions", operator: "omit", keys: ["insetTop", "insetBottom"]},
		]
		properties: [
			{
				name:        "x"
				description: "Shorthand for specifying both the primary and secondary horizontal position of the tick as the bounds of the containing interval; can only be used in conjunction with the **interval** option."
				type:        "channelValueIntervalSpecReference"
			},
			{
				name:        "x1"
				description: "The primary (starting, often left) horizontal position of the tick; a channel bound to the *x* scale.\n\nIf *x* represents ordinal values, use a tickY mark instead."
				type:        "channelValueSpecReference"
			},
			{
				name:        "x2"
				description: "The secondary (ending, often right) horizontal position of the tick; a channel bound to the *x* scale.\n\nIf *x* represents ordinal values, use a tickY mark instead."
				type:        "channelValueSpecReference"
			},
			{
				name:        "y"
				description: "The vertical position of the tick; an optional channel bound to the *y* scale. If not specified, the rule will be vertically centered in the plot\u2019s frame."
				type:        "channelValueSpecReference"
			},
		]
	},
	{
		name:        "RuleX"
		description: "The ruleX mark."
		extends: ["MarkDataOptional", "RuleXOptions"]
		properties: [
			{
				name:        "mark"
				description: "A horizontally-positioned ruleX mark (a vertical line, |). The **x** channel specifies the rule\u2019s horizontal position and defaults to identity, assuming that *data* = [*x\u2080*, *x\u2081*, *x\u2082*, \u2026]; the optional **y1** and\n**y2** channels specify its vertical extent.\n\nThe ruleX mark is often used to highlight specific *x* values. If *y* represents ordinal values, use a tickX mark instead."
				required:    true
				type:        "ruleXKind"
			}
		]
	},
	{
		name:        "RuleY"
		description: "The ruleY mark."
		extends: ["MarkDataOptional", "RuleXOptions"]
		properties: [
			{
				name:        "mark"
				description: "A vertically-positioned ruleY mark (a horizontal line, \u2014). The **y** channel specifies the rule's vertical position and defaults to identity, assuming that *data* = [*y\u2080*, *y\u2081*, *y\u2082*, \u2026]; the optional **x1** and\n**x2** channels specify its horizontal extent.\n\nThe ruleY mark is often used to highlight specific *y* values. If *x* represents ordinal values, use a tickY mark instead."
				required:    true
				type:        "ruleYKind"
			}
		]
	},
	{
		name:        "TickXOptions"
		description: "Options for the tickX mark."
		wire:        false
		extends: ["MarkOptions", "MarkerOptions"
			{name: "InsetOptions", operator: "omit", keys: ["insetLeft", "insetRight"]}
		]
		properties: [
			{
				name:        "x"
				description: "The required horizontal position of the tick; a channel typically bound to the *x* scale."
				type:        "channelValueSpecReference"
			},
			{
				name:        "y"
				description: "The optional vertical position of the tick; an ordinal channel typically bound to the *y* scale. If not specified, the tick spans the vertical extent of the frame; otherwise the *y* scale must be a *band* scale.\n\nIf *y* represents quantitative or temporal values, use a ruleX mark instead."
				type:        "channelValueSpecReference"
			},
		]
	},
	{
		name:        "TickYOptions"
		description: "Options for the tickY mark."
		wire:        false
		extends: ["MarkOptions", "MarkerOptions"
			{name: "InsetOptions", operator: "omit", keys: ["insetTop", "insetBottom"]}
		]
		properties: [
			{
				name:        "y"
				description: "The required vertical position of the tick; a channel typically bound to the *y* scale."
				type:        "channelValueSpecReference"
			},
			{
				name:        "x"
				description: "The optional horizontal position of the tick; an ordinal channel typically bound to the *x* scale. If not specified, the tick spans the horizontal extent of the frame; otherwise the *x* scale must be a *band* scale.\n\nIf *x* represents quantitative or temporal values, use a ruleY mark instead."
				type:        "channelValueSpecReference"
			},
		]
	},
	{
		name:        "TickX"
		description: "The tickX mark."
		extends: ["MarkData", "TickXOptions"]
		properties: [
			{
				name:        "mark"
				description: "A horizontally-positioned tickX mark (a vertical line, |). The **x** channel specifies the tick\u2019s horizontal position and defaults to identity, assuming that *data* = [*x\u2080*, *x\u2081*, *x\u2082*, \u2026]; the optional **y** ordinal channel specifies its vertical position.\n\nIf *y* represents quantitative or temporal values, use a ruleX mark instead."
				required:    true
				type:        "tickXKind"
			}
		]
	},
	{
		name:        "TickY"
		description: "The tickY mark."
		extends: ["MarkData", "TickYOptions"]
		properties: [
			{
				name:        "mark"
				description: "A vertically-positioned tickY mark (a horizontal line, \u2014). The **y** channel specifies the tick's vertical position and defaults to identity, assuming that *data* = [*y\u2080*, *y\u2081*, *y\u2082*, \u2026]; the optional **x** ordinal channel specifies its horizontal position.\n\nIf *x* represents quantitative or temporal values, use a ruleY mark instead."
				required:    true
				type:        "tickYKind"
			}
		]
	},
]
typeExpressions: {[string]: model.#ShapeExpression} & {
	intervalOrParamRef: {kind: "union", members: ["intervalReference", "paramRefReference"]}
	channelValueIntervalSpecReference: {kind: "named", name: "ChannelValueIntervalSpec"}
	barXKind: {kind: "literal", value: "barX"}
	barYKind: {kind: "literal", value: "barY"}
	cellKind: {kind: "literal", value: "cell"}
	cellXKind: {kind: "literal", value: "cellX"}
	cellYKind: {kind: "literal", value: "cellY"}
	channelSpecOrNumberOrParamRef: {kind: "union", members: ["channelValueSpecReference", "number", "paramRefReference"]}
	channelOrNumberOrParamRef: {kind: "union", members: ["channelValueReference", "number", "paramRefReference"]}
	symbolTypeReference: {kind: "named", name: "SymbolType"}
	channelSpecOrSymbolOrParamRef: {kind: "union", members: ["channelValueSpecReference", "symbolTypeReference", "paramRefReference"]}
	frameAnchorOrParamRef: {kind: "union", members: ["frameAnchorReference", "paramRefReference"]}
	dotKind: {kind: "literal", value: "dot"}
	dotXKind: {kind: "literal", value: "dotX"}
	dotYKind: {kind: "literal", value: "dotY"}
	circleKind: {kind: "literal", value: "circle"}
	hexagonKind: {kind: "literal", value: "hexagon"}
	numberOrStringOrParamRef: {kind: "union", members: ["number", "string", "paramRefReference"]}
	rectKind: {kind: "literal", value: "rect"}
	rectXKind: {kind: "literal", value: "rectX"}
	rectYKind: {kind: "literal", value: "rectY"}
	ruleXKind: {kind: "literal", value: "ruleX"}
	ruleYKind: {kind: "literal", value: "ruleY"}
	tickXKind: {kind: "literal", value: "tickX"}
	tickYKind: {kind: "literal", value: "tickY"}
}
externalReferences: [...model.#ExternalReference] & [{name: "SymbolType", owner: "values", source: "../PlotTypes.js"}]
declarationFiles: [
	{
		basename: "Bar"
		imports: [
			"ParamRef",
			"Interval",
			"ChannelValueIntervalSpec",
			"ChannelValueSpec",
			"InsetOptions",
			"MarkData",
			"MarkOptions",
			"StackOptions",
			"RectCornerOptions",
		]
		contracts: ["BarOptions", "BarXOptions", "BarYOptions", "BarX", "BarY"]
	},
	{
		basename: "Cell"
		imports: ["ChannelValueSpec", "InsetOptions", "MarkData", "MarkOptions", "RectCornerOptions"]
		contracts: ["CellOptions", "Cell", "CellX", "CellY"]
	},
	{
		basename: "Dot"
		imports: [
			"ParamRef",
			"FrameAnchor",
			"Interval",
			"SymbolType",
			"ChannelValue",
			"ChannelValueIntervalSpec",
			"ChannelValueSpec",
			"MarkData",
			"MarkOptions",
		]
		contracts: ["DotOptions", "DotXOptions", "DotYOptions", "Dot", "DotX", "DotY", "Circle", "Hexagon"]
	},
	{
		basename: "Rect"
		imports: [
			"ParamRef",
			"Interval",
			"ChannelValueIntervalSpec",
			"ChannelValueSpec",
			"InsetOptions",
			"MarkData",
			"MarkOptions",
			"StackOptions",
		]
		contracts: ["RectCornerOptions", "RectOptions", "RectXOptions", "RectYOptions", "Rect", "RectX", "RectY"]
	},
	{
		basename: "Rule"
		imports: [
			"ParamRef",
			"Interval",
			"ChannelValueIntervalSpec",
			"ChannelValueSpec",
			"InsetOptions",
			"MarkDataOptional",
			"MarkOptions",
			"MarkerOptions",
		]
		contracts: ["RuleOptions", "RuleXOptions", "RuleYOptions", "RuleX", "RuleY"]
	},
	{
		basename: "Tick"
		imports: ["ChannelValueSpec", "InsetOptions", "MarkData", "MarkOptions", "MarkerOptions"]
		contracts: ["TickXOptions", "TickYOptions", "TickX", "TickY"]
	},
]
marks: [
	{name: "barX", contract: "BarX", jsSection: "barX-11", profile: "ordinary"},
	{name: "barY", contract: "BarY", jsSection: "barY-12", profile: "ordinary"},
	{name: "cell", contract: "Cell", jsSection: "cell-13", profile: "ordinary"},
	{name: "cellX", contract: "CellX", jsSection: "cellX-14", profile: "ordinary"},
	{name: "cellY", contract: "CellY", jsSection: "cellY-15", profile: "ordinary"},
	{name: "rect", contract: "Rect", jsSection: "rect-16", profile: "ordinary"},
	{name: "rectX", contract: "RectX", jsSection: "rectX-17", profile: "ordinary"},
	{name: "rectY", contract: "RectY", jsSection: "rectY-18", profile: "ordinary"},
	{name: "dot", contract: "Dot", jsSection: "dot-19", profile: "ordinary"},
	{name: "dotX", contract: "DotX", jsSection: "dotX-20", profile: "ordinary"},
	{name: "dotY", contract: "DotY", jsSection: "dotY-21", profile: "ordinary"},
	{name: "circle", contract: "Circle", jsSection: "circle-22", profile: "ordinary"},
	{name: "hexagon", contract: "Hexagon", jsSection: "hexagon-23", profile: "ordinary"},
	{name: "ruleX", contract: "RuleX", jsSection: "ruleX-27", profile: "ordinary"},
	{name: "ruleY", contract: "RuleY", jsSection: "ruleY-28", profile: "ordinary"},
	{name: "tickX", contract: "TickX", jsSection: "tickX-29", profile: "ordinary"},
	{name: "tickY", contract: "TickY", jsSection: "tickY-30", profile: "ordinary"},
]
referenceGroups: [
	{title: "Bar", names: ["barX", "barY"], sections: {js: "js-Bar-6", python: "python-Bar-37"}},
	{title: "Cell", names: ["cell", "cellX", "cellY"], sections: {js: "js-Cell-7", python: "python-Cell-38"}},
	{
		title: "Dot"
		names: ["dot", "dotX", "dotY", "circle", "hexagon"]
		sections: {js: "js-Dot-13", python: "python-Dot-44"}
	},
	{title: "Rect", names: ["rect", "rectX", "rectY"], sections: {js: "js-Rect-25", python: "python-Rect-56"}},
	{title: "Rule", names: ["ruleX", "ruleY"], sections: {js: "js-Rule-26", python: "python-Rule-57"}},
	{title: "Tick", names: ["tickX", "tickY"], sections: {js: "js-Tick-28", python: "python-Tick-59"}},
]

contractIndex: {for Contract in contracts {(Contract.name): Contract}}
modelChecks: names: true & list.UniqueItems([for Contract in contracts {Contract.name}])
