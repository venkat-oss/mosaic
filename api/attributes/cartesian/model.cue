package cartesianattributes

import (
	"list"
	attributeModel "idl.uw.edu/mosaic/api/attributes"
)

attributes: [...attributeModel.#Attribute] & [
	{
		name:        "xScale"
		type:        "scaleValue"
		description: "The *x* scale type, affecting how the scale encodes abstract data, say by\napplying a mathematical transformation. If null, the scale is disabled.\n\nFor quantitative data (numbers), defaults to *linear*; for temporal data\n(dates), defaults to *utc*; for ordinal data (strings or booleans),\ndefaults to *point* for position scales, *categorical* for color scales,\nand otherwise *ordinal*. However, the radius scale defaults to *sqrt*, and\nthe length and opacity scales default to *linear*; these scales are\nintended for quantitative data. The plot\u2019s marks may also impose a scale\ntype; for example, the barY mark requires that *x* is a *band* scale."
		tsSection:   "xScale-24"
		jsSection:   "xScale-26"
		jsKind:      "simple"
		python: {name: "x_scale", default: "required", kind: "value"}
		route: {kind: "mapped", path: "x.type", order: 15}
	},
	{
		name:        "xDomain"
		type:        "domainValue"
		description: "The extent of the scale\u2019s inputs (abstract values). By default inferred\nfrom channel values. For continuous data (numbers and dates), it is\ntypically [*min*, *max*]; it can be [*max*, *min*] to reverse the scale.\nFor ordinal data (strings or booleans), it is an array (or iterable) of\nvalues is the desired order, defaulting to natural ascending order.\n\nLinear scales have a default domain of [0, 1]. Log scales have a default\ndomain of [1, 10] and cannot include zero. Radius scales have a default\ndomain from 0 to the median first quartile of associated channels. Length\nhave a default domain from 0 to the median median of associated channels.\nOpacity scales have a default domain from 0 to the maximum value of\nassociated channels."
		tsSection:   "xDomain-25"
		jsSection:   "xDomain-27"
		jsKind:      "simple"
		python: {name: "x_domain", default: "required", kind: "value"}
		route: {kind: "mapped", path: "x.domain", order: 16}
	},
	{
		name:        "xRange"
		type:        "domainValue"
		description: "The extent of the scale\u2019s outputs (visual values). By default inferred from\nthe scale\u2019s **type** and **domain**, and for position scales, the plot\u2019s\ndimensions. For continuous data (numbers and dates), and for ordinal\nposition scales (*point* and *band*), it is typically [*min*, *max*]; it\ncan be [*max*, *min*] to reverse the scale."
		tsSection:   "xRange-26"
		jsSection:   "xRange-28"
		jsKind:      "simple"
		python: {name: "x_range", default: "required", kind: "value"}
		route: {kind: "mapped", path: "x.range", order: 17}
	},
	{
		name:        "xNice"
		type:        "niceValue"
		description: "If true, or a tick count or interval, extend the domain to nice round\nvalues. Defaults to 1, 2 or 5 times a power of 10 for *linear* scales, and\nnice time intervals for *utc* and *time* scales. Pass an interval such as\n*minute*, *wednesday* or *month* to specify what constitutes a nice\ninterval.\n\nFor continuous scales only."
		tsSection:   "xNice-27"
		jsSection:   "xNice-29"
		jsKind:      "simple"
		python: {name: "x_nice", default: "true", kind: "value"}
		route: {kind: "mapped", path: "x.nice", order: 18}
	},
	{
		name:        "xInset"
		type:        "numberReference"
		description: "Shorthand to set the same default for all four insets: **insetTop**,\n**insetRight**, **insetBottom**, and **insetLeft**. All insets typically\ndefault to zero, though not always (say when using bin transform). A\npositive inset reduces effective area, while a negative inset increases it."
		tsSection:   "xInset-28"
		jsSection:   "xInset-30"
		jsKind:      "simple"
		python: {name: "x_inset", default: "required", kind: "value"}
		route: {kind: "mapped", path: "x.inset", order: 19}
	},
	{
		name:        "xInsetRight"
		type:        "numberReference"
		description: "Insets the right edge by the specified number of pixels. A positive value\ninsets towards the left edge (reducing effective area), while a negative\nvalue insets away from the left edge (increasing it)."
		tsSection:   "xInsetRight-29"
		jsSection:   "xInsetRight-32"
		jsKind:      "simple"
		python: {name: "x_inset_right", default: "required", kind: "value"}
		route: {kind: "mapped", path: "x.insetRight", order: 21}
	},
	{
		name:        "xInsetLeft"
		type:        "numberReference"
		description: "Insets the left edge by the specified number of pixels. A positive value\ninsets towards the right edge (reducing effective area), while a negative\nvalue insets away from the right edge (increasing it)."
		tsSection:   "xInsetLeft-30"
		jsSection:   "xInsetLeft-31"
		jsKind:      "simple"
		python: {name: "x_inset_left", default: "required", kind: "value"}
		route: {kind: "mapped", path: "x.insetLeft", order: 20}
	},
	{
		name:        "xClamp"
		type:        "booleanReference"
		description: "If true, values below the domain minimum are treated as the domain minimum,\nand values above the domain maximum are treated as the domain maximum.\n\nClamping is useful for focusing on a subset of the data while ensuring that\nextreme values remain visible, but use caution: clamped values may need an\nannotation to avoid misinterpretation. Clamping typically requires setting\nan explicit **domain** since if the domain is inferred, no values will be\noutside the domain.\n\nFor continuous scales only."
		tsSection:   "xClamp-31"
		jsSection:   "xClamp-33"
		jsKind:      "simple"
		python: {name: "x_clamp", default: "true", kind: "value"}
		route: {kind: "mapped", path: "x.clamp", order: 22}
	},
	{
		name:        "xRound"
		type:        "booleanReference"
		description: "If true, round the output value to the nearest integer (pixel); useful for\ncrisp edges when rendering.\n\nFor position scales only."
		tsSection:   "xRound-32"
		jsSection:   "xRound-34"
		jsKind:      "simple"
		python: {name: "x_round", default: "true", kind: "value"}
		route: {kind: "mapped", path: "x.round", order: 23}
	},
	{
		name:        "xAlign"
		type:        "numberReference"
		description: "How to distribute unused space in the **range** for *point* and *band*\nscales. A number in [0, 1], such as:\n\n- 0 - use the start of the range, putting unused space at the end\n- 0.5 (default) - use the middle, distributing unused space evenly\n- 1 use the end, putting unused space at the start\n\nFor ordinal position scales only."
		tsSection:   "xAlign-33"
		jsSection:   "xAlign-35"
		jsKind:      "simple"
		python: {name: "x_align", default: "required", kind: "value"}
		route: {kind: "mapped", path: "x.align", order: 24}
	},
	{
		name:        "xPadding"
		type:        "numberReference"
		description: "For *band* scales, how much of the **range** to reserve to separate\nadjacent bands; defaults to 0.1 (10%). For *point* scales, the amount of\ninset for the first and last value as a proportion of the bandwidth;\ndefaults to 0.5 (50%).\n\nFor ordinal position scales only."
		tsSection:   "xPadding-34"
		jsSection:   "xPadding-36"
		jsKind:      "simple"
		python: {name: "x_padding", default: "required", kind: "value"}
		route: {kind: "mapped", path: "x.padding", order: 25}
	},
	{
		name:        "xPaddingInner"
		type:        "numberReference"
		description: "For a *band* scale, how much of the range to reserve to separate\nadjacent bands."
		tsSection:   "xPaddingInner-35"
		jsSection:   "xPaddingInner-37"
		jsKind:      "simple"
		python: {name: "x_padding_inner", default: "required", kind: "value"}
		route: {kind: "mapped", path: "x.paddingInner", order: 26}
	},
	{
		name:        "xPaddingOuter"
		type:        "numberReference"
		description: "For a *band* scale, how much of the range to reserve to inset first and\nlast bands."
		tsSection:   "xPaddingOuter-36"
		jsSection:   "xPaddingOuter-38"
		jsKind:      "simple"
		python: {name: "x_padding_outer", default: "required", kind: "value"}
		route: {kind: "mapped", path: "x.paddingOuter", order: 27}
	},
	{
		name:        "xAxis"
		type:        "xAxisValue"
		description: "The side of the frame on which to place the implicit axis: *top* or\n*bottom* for *x*. Defaults to *bottom* for an *x* scale.\n\nIf *both*, an implicit axis will be rendered on both sides of the plot\n(*top* and *bottom* for *x*). If null, the implicit axis is suppressed."
		tsSection:   "xAxis-37"
		jsSection:   "xAxis-39"
		jsKind:      "simple"
		python: {name: "x_axis", default: "true", kind: "value"}
		route: {kind: "mapped", path: "x.axis", order: 28}
	},
	{
		name:        "xTicks"
		type:        "ticksValue"
		description: "The desired approximate number of axis ticks, or an explicit array of tick\nvalues, or an interval such as *day* or *month*."
		tsSection:   "xTicks-38"
		jsSection:   "xTicks-40"
		jsKind:      "simple"
		python: {name: "x_ticks", default: "required", kind: "value"}
		route: {kind: "mapped", path: "x.ticks", order: 29}
	},
	{
		name:        "xTickSize"
		type:        "numberReference"
		description: "The length of axis tick marks in pixels; negative values extend in the\nopposite direction. Defaults to 6 for *x* and *y* axes and *color* and\n*opacity* *ramp* legends, and 0 for *fx* and *fy* axes."
		tsSection:   "xTickSize-39"
		jsSection:   "xTickSize-41"
		jsKind:      "simple"
		python: {name: "x_tick_size", default: "required", kind: "value"}
		route: {kind: "mapped", path: "x.tickSize", order: 30}
	},
	{
		name:        "xTickSpacing"
		type:        "numberReference"
		description: "The desired approximate spacing between adjacent axis ticks, affecting the\ndefault **ticks**; defaults to 80 pixels for *x* and *fx*, and 35 pixels\nfor *y* and *fy*."
		tsSection:   "xTickSpacing-40"
		jsSection:   "xTickSpacing-42"
		jsKind:      "simple"
		python: {name: "x_tick_spacing", default: "required", kind: "value"}
		route: {kind: "mapped", path: "x.tickSpacing", order: 31}
	},
	{
		name:        "xTickPadding"
		type:        "numberReference"
		description: "The distance between an axis tick mark and its associated text label (in\npixels); often defaults to 3, but may be affected by **xTickSize** and\n**xTickRotate**."
		tsSection:   "xTickPadding-41"
		jsSection:   "xTickPadding-43"
		jsKind:      "simple"
		python: {name: "x_tick_padding", default: "required", kind: "value"}
		route: {kind: "mapped", path: "x.tickPadding", order: 32}
	},
	{
		name:        "xTickFormat"
		type:        "nullableString"
		description: "How to format inputs (abstract values) for axis tick labels; one of:\n\n- a [d3-format][1] string for numeric scales\n- a [d3-time-format][2] string for temporal scales\n\n[1]: https://d3js.org/d3-time\n[2]: https://d3js.org/d3-time-format"
		tsSection:   "xTickFormat-42"
		jsSection:   "xTickFormat-44"
		jsKind:      "simple"
		python: {name: "x_tick_format", default: "required", kind: "value"}
		route: {kind: "mapped", path: "x.tickFormat", order: 33}
	},
	{
		name:        "xTickRotate"
		type:        "numberReference"
		description: "The rotation angle of axis tick labels in degrees clocksize; defaults to 0."
		tsSection:   "xTickRotate-43"
		jsSection:   "xTickRotate-45"
		jsKind:      "simple"
		python: {name: "x_tick_rotate", default: "required", kind: "value"}
		route: {kind: "mapped", path: "x.tickRotate", order: 34}
	},
	{
		name:        "xGrid"
		type:        "gridValue"
		description: "Whether to show a grid aligned with the scale\u2019s ticks. If true, show a grid\nwith the currentColor stroke; if a string, show a grid with the specified\nstroke color; if an approximate number of ticks, an interval, or an array\nof tick values, show corresponding grid lines. See also the grid mark.\n\nFor axes only."
		tsSection:   "xGrid-44"
		jsSection:   "xGrid-46"
		jsKind:      "simple"
		python: {name: "x_grid", default: "true", kind: "value"}
		route: {kind: "mapped", path: "x.grid", order: 35}
	},
	{
		name:        "xLine"
		type:        "booleanReference"
		description: "If true, draw a line along the axis; if false (default), do not."
		tsSection:   "xLine-45"
		jsSection:   "xLine-47"
		jsKind:      "simple"
		python: {name: "x_line", default: "true", kind: "value"}
		route: {kind: "mapped", path: "x.line", order: 36}
	},
	{
		name:        "xLabel"
		type:        "nullableString"
		description: "A textual label to show on the axis or legend; if null, show no label. By\ndefault the scale label is inferred from channel definitions, possibly with\nan arrow (\u2191, \u2192, \u2193, or \u2190) to indicate the direction of increasing value.\n\nFor axes and legends only."
		tsSection:   "xLabel-46"
		jsSection:   "xLabel-48"
		jsKind:      "simple"
		python: {name: "x_label", default: "required", kind: "value"}
		route: {kind: "mapped", path: "x.label", order: 37}
	},
	{
		name:        "xLabelAnchor"
		type:        "anchorValue"
		description: "Where to place the axis **label** relative to the plot\u2019s frame. For\nvertical position scales (*y* and *fy*), may be *top*, *bottom*, or\n*center*; for horizontal position scales (*x* and *fx*), may be *left*,\n*right*, or *center*. Defaults to *center* for ordinal scales (including\n*fx* and *fy*), and otherwise *top* for *y*, and *right* for *x*."
		tsSection:   "xLabelAnchor-47"
		jsSection:   "xLabelAnchor-49"
		jsKind:      "simple"
		python: {name: "x_label_anchor", default: "required", kind: "value"}
		route: {kind: "mapped", path: "x.labelAnchor", order: 38}
	},
	{
		name:        "xLabelArrow"
		type:        "arrowValue"
		description: "Whether to apply a directional arrow such as \u2192 or \u2191 to the x-axis scale\nlabel. If *auto* (the default), the presence of the arrow depends on\nwhether the scale is ordinal."
		tsSection:   "xLabelArrow-48"
		jsSection:   "xLabelArrow-50"
		jsKind:      "simple"
		python: {name: "x_label_arrow", default: "required", kind: "value"}
		route: {kind: "mapped", path: "x.labelArrow", order: 39}
	},
	{
		name:        "xLabelOffset"
		type:        "numberReference"
		description: "The axis **label** position offset (in pixels); default depends on margins\nand orientation."
		tsSection:   "xLabelOffset-49"
		jsSection:   "xLabelOffset-51"
		jsKind:      "simple"
		python: {name: "x_label_offset", default: "required", kind: "value"}
		route: {kind: "mapped", path: "x.labelOffset", order: 40}
	},
	{
		name:        "xFontVariant"
		type:        "stringReference"
		description: "The font-variant attribute for axis ticks; defaults to *tabular-nums* for\nquantitative axes."
		tsSection:   "xFontVariant-50"
		jsSection:   "xFontVariant-52"
		jsKind:      "simple"
		python: {name: "x_font_variant", default: "required", kind: "value"}
		route: {kind: "mapped", path: "x.fontVariant", order: 41}
	},
	{
		name:        "xAriaLabel"
		type:        "stringReference"
		description: "A short label representing the axis in the accessibility tree."
		tsSection:   "xAriaLabel-51"
		jsSection:   "xAriaLabel-53"
		jsKind:      "simple"
		python: {name: "x_aria_label", default: "required", kind: "value"}
		route: {kind: "mapped", path: "x.ariaLabel", order: 42}
	},
	{
		name:        "xAriaDescription"
		type:        "stringReference"
		description: "A textual description for the axis in the accessibility tree."
		tsSection:   "xAriaDescription-52"
		jsSection:   "xAriaDescription-54"
		jsKind:      "simple"
		python: {name: "x_aria_description", default: "required", kind: "value"}
		route: {kind: "mapped", path: "x.ariaDescription", order: 43}
	},
	{
		name:        "xPercent"
		type:        "booleanReference"
		description: "If true, shorthand for a transform suitable for percentages, mapping\nproportions in [0, 1] to [0, 100]."
		tsSection:   "xPercent-53"
		jsSection:   "xPercent-55"
		jsKind:      "simple"
		python: {name: "x_percent", default: "true", kind: "value"}
		route: {kind: "mapped", path: "x.percent", order: 44}
	},
	{
		name:        "xReverse"
		type:        "booleanReference"
		description: "Whether to reverse the scale\u2019s encoding; equivalent to reversing either the\n**domain** or **range**."
		tsSection:   "xReverse-54"
		jsSection:   "xReverse-56"
		jsKind:      "simple"
		python: {name: "x_reverse", default: "true", kind: "value"}
		route: {kind: "mapped", path: "x.reverse", order: 45}
	},
	{
		name:        "xZero"
		type:        "booleanReference"
		description: "Whether the **domain** must include zero. If the domain minimum is\npositive, it will be set to zero; otherwise if the domain maximum is\nnegative, it will be set to zero.\n\nFor quantitative scales only."
		tsSection:   "xZero-55"
		jsSection:   "xZero-57"
		jsKind:      "simple"
		python: {name: "x_zero", default: "true", kind: "value"}
		route: {kind: "mapped", path: "x.zero", order: 46}
	},
	{
		name:        "xExponent"
		type:        "numberReference"
		description: "A power scale\u2019s exponent (*e.g.*, 0.5 for sqrt); defaults to 1 for a\nlinear scale. For *pow* scales only."
		tsSection:   "xExponent-56"
		jsSection:   "xExponent-59"
		jsKind:      "simple"
		python: {name: "x_exponent", default: "required", kind: "value"}
		route: {kind: "mapped", path: "x.exponent", order: 48}
	},
	{
		name:        "xBase"
		type:        "numberReference"
		description: "A log scale\u2019s base; defaults to 10. Does not affect the scale\u2019s encoding,\nbut rather the default ticks. For *log* scales only."
		tsSection:   "xBase-57"
		jsSection:   "xBase-58"
		jsKind:      "simple"
		python: {name: "x_base", default: "required", kind: "value"}
		route: {kind: "mapped", path: "x.base", order: 47}
	},
	{
		name:        "xConstant"
		type:        "numberReference"
		description: "A symlog scale\u2019s constant, expressing the magnitude of the linear region\naround the origin; defaults to 1. For *symlog* scales only."
		tsSection:   "xConstant-58"
		jsSection:   "xConstant-60"
		jsKind:      "simple"
		python: {name: "x_constant", default: "required", kind: "value"}
		route: {kind: "mapped", path: "x.constant", order: 49}
	},
	{
		name:        "yScale"
		type:        "scaleValue"
		description: "The *y* scale type, affecting how the scale encodes abstract data, say by\napplying a mathematical transformation. If null, the scale is disabled.\n\nFor quantitative data (numbers), defaults to *linear*; for temporal data\n(dates), defaults to *utc*; for ordinal data (strings or booleans),\ndefaults to *point* for position scales,  The plot\u2019s marks may also impose\na scale type; for example, the barY mark requires that *x* is a *band*\nscale."
		tsSection:   "yScale-59"
		jsSection:   "yScale-61"
		jsKind:      "simple"
		python: {name: "y_scale", default: "required", kind: "value"}
		route: {kind: "mapped", path: "y.type", order: 50}
	},
	{
		name:        "yDomain"
		type:        "domainValue"
		description: "The extent of the scale\u2019s inputs (abstract values). By default inferred\nfrom channel values. For continuous data (numbers and dates), it is\ntypically [*min*, *max*]; it can be [*max*, *min*] to reverse the scale.\nFor ordinal data (strings or booleans), it is an array (or iterable) of\nvalues is the desired order, defaulting to natural ascending order.\n\nLinear scales have a default domain of [0, 1]. Log scales have a default\ndomain of [1, 10] and cannot include zero."
		tsSection:   "yDomain-60"
		jsSection:   "yDomain-62"
		jsKind:      "simple"
		python: {name: "y_domain", default: "required", kind: "value"}
		route: {kind: "mapped", path: "y.domain", order: 51}
	},
	{
		name:        "yRange"
		type:        "domainValue"
		description: "The extent of the scale\u2019s outputs (visual values). By default inferred\nfrom the scale\u2019s **type** and **domain**, and for position scales, the\nplot\u2019s dimensions. For continuous data (numbers and dates), and for\nordinal position scales (*point* and *band*), it is typically [*min*,\n*max*]; it can be [*max*, *min*] to reverse the scale."
		tsSection:   "yRange-61"
		jsSection:   "yRange-63"
		jsKind:      "simple"
		python: {name: "y_range", default: "required", kind: "value"}
		route: {kind: "mapped", path: "y.range", order: 52}
	},
	{
		name:        "yNice"
		type:        "niceValue"
		description: "If true, or a tick count or interval, extend the domain to nice round\nvalues. Defaults to 1, 2 or 5 times a power of 10 for *linear* scales, and\nnice time intervals for *utc* and *time* scales. Pass an interval such as\n*minute*, *wednesday* or *month* to specify what constitutes a nice\ninterval.\n\nFor continuous scales only."
		tsSection:   "yNice-62"
		jsSection:   "yNice-64"
		jsKind:      "simple"
		python: {name: "y_nice", default: "true", kind: "value"}
		route: {kind: "mapped", path: "y.nice", order: 53}
	},
	{
		name:        "yInset"
		type:        "numberReference"
		description: "Shorthand to set the same default for all four insets: **insetTop**,\n**insetRight**, **insetBottom**, and **insetLeft**. All insets typically\ndefault to zero, though not always (say when using bin transform). A\npositive inset reduces effective area, while a negative inset increases it."
		tsSection:   "yInset-63"
		jsSection:   "yInset-65"
		jsKind:      "simple"
		python: {name: "y_inset", default: "required", kind: "value"}
		route: {kind: "mapped", path: "y.inset", order: 54}
	},
	{
		name:        "yInsetTop"
		type:        "numberReference"
		description: "Insets the top edge by the specified number of pixels. A positive value\ninsets towards the bottom edge (reducing effective area), while a negative\nvalue insets away from the bottom edge (increasing it)."
		tsSection:   "yInsetTop-64"
		jsSection:   "yInsetTop-66"
		jsKind:      "simple"
		python: {name: "y_inset_top", default: "required", kind: "value"}
		route: {kind: "mapped", path: "y.insetTop", order: 55}
	},
	{
		name:        "yInsetBottom"
		type:        "numberReference"
		description: "Insets the bottom edge by the specified number of pixels. A positive value\ninsets towards the top edge (reducing effective area), while a negative\nvalue insets away from the top edge (increasing it)."
		tsSection:   "yInsetBottom-65"
		jsSection:   "yInsetBottom-67"
		jsKind:      "simple"
		python: {name: "y_inset_bottom", default: "required", kind: "value"}
		route: {kind: "mapped", path: "y.insetBottom", order: 56}
	},
	{
		name:        "yClamp"
		type:        "booleanReference"
		description: "If true, values below the domain minimum are treated as the domain minimum,\nand values above the domain maximum are treated as the domain maximum.\n\nClamping is useful for focusing on a subset of the data while ensuring that\nextreme values remain visible, but use caution: clamped values may need an\nannotation to avoid misinterpretation. Clamping typically requires setting\nan explicit **domain** since if the domain is inferred, no values will be\noutside the domain.\n\nFor continuous scales only."
		tsSection:   "yClamp-66"
		jsSection:   "yClamp-68"
		jsKind:      "simple"
		python: {name: "y_clamp", default: "true", kind: "value"}
		route: {kind: "mapped", path: "y.clamp", order: 57}
	},
	{
		name:        "yRound"
		type:        "booleanReference"
		description: "If true, round the output value to the nearest integer (pixel); useful for\ncrisp edges when rendering.\n\nFor position scales only."
		tsSection:   "yRound-67"
		jsSection:   "yRound-69"
		jsKind:      "simple"
		python: {name: "y_round", default: "true", kind: "value"}
		route: {kind: "mapped", path: "y.round", order: 58}
	},
	{
		name:        "yAlign"
		type:        "numberReference"
		description: "How to distribute unused space in the **range** for *point* and *band*\nscales. A number in [0, 1], such as:\n\n- 0 - use the start of the range, putting unused space at the end\n- 0.5 (default) - use the middle, distributing unused space evenly\n- 1 use the end, putting unused space at the start\n\nFor ordinal position scales only."
		tsSection:   "yAlign-68"
		jsSection:   "yAlign-70"
		jsKind:      "simple"
		python: {name: "y_align", default: "required", kind: "value"}
		route: {kind: "mapped", path: "y.align", order: 59}
	},
	{
		name:        "yPadding"
		type:        "numberReference"
		description: "For *band* scales, how much of the **range** to reserve to separate\nadjacent bands; defaults to 0.1 (10%). For *point* scales, the amount of\ninset for the first and last value as a proportion of the bandwidth;\ndefaults to 0.5 (50%).\n\nFor ordinal position scales only."
		tsSection:   "yPadding-69"
		jsSection:   "yPadding-71"
		jsKind:      "simple"
		python: {name: "y_padding", default: "required", kind: "value"}
		route: {kind: "mapped", path: "y.padding", order: 60}
	},
	{
		name:        "yPaddingInner"
		type:        "numberReference"
		description: "For a *band* scale, how much of the range to reserve to separate\nadjacent bands."
		tsSection:   "yPaddingInner-70"
		jsSection:   "yPaddingInner-72"
		jsKind:      "simple"
		python: {name: "y_padding_inner", default: "required", kind: "value"}
		route: {kind: "mapped", path: "y.paddingInner", order: 61}
	},
	{
		name:        "yPaddingOuter"
		type:        "numberReference"
		description: "For a *band* scale, how much of the range to reserve to inset first and\nlast bands."
		tsSection:   "yPaddingOuter-71"
		jsSection:   "yPaddingOuter-73"
		jsKind:      "simple"
		python: {name: "y_padding_outer", default: "required", kind: "value"}
		route: {kind: "mapped", path: "y.paddingOuter", order: 62}
	},
	{
		name:        "yAxis"
		type:        "yAxisValue"
		description: "The side of the frame on which to place the implicit axis: *left* or\n*right* for *y*. Defaults to *left* for a *y* scale.\n\nIf *both*, an implicit axis will be rendered on both sides of the plot\n(*left* and *right* for *y*). If null, the implicit axis is suppressed."
		tsSection:   "yAxis-72"
		jsSection:   "yAxis-74"
		jsKind:      "simple"
		python: {name: "y_axis", default: "true", kind: "value"}
		route: {kind: "mapped", path: "y.axis", order: 63}
	},
	{
		name:        "yTicks"
		type:        "ticksValue"
		description: "The desired approximate number of axis ticks, or an explicit array of tick\nvalues, or an interval such as *day* or *month*."
		tsSection:   "yTicks-73"
		jsSection:   "yTicks-75"
		jsKind:      "simple"
		python: {name: "y_ticks", default: "required", kind: "value"}
		route: {kind: "mapped", path: "y.ticks", order: 64}
	},
	{
		name:        "yTickSize"
		type:        "numberReference"
		description: "The length of axis tick marks in pixels; negative values extend in the\nopposite direction. Defaults to 6 for *x* and *y* axes and *color* and\n*opacity* *ramp* legends, and 0 for *fx* and *fy* axes."
		tsSection:   "yTickSize-74"
		jsSection:   "yTickSize-76"
		jsKind:      "simple"
		python: {name: "y_tick_size", default: "required", kind: "value"}
		route: {kind: "mapped", path: "y.tickSize", order: 65}
	},
	{
		name:        "yTickSpacing"
		type:        "numberReference"
		description: "The desired approximate spacing between adjacent axis ticks, affecting the\ndefault **ticks**; defaults to 80 pixels for *x* and *fx*, and 35 pixels\nfor *y* and *fy*."
		tsSection:   "yTickSpacing-75"
		jsSection:   "yTickSpacing-77"
		jsKind:      "simple"
		python: {name: "y_tick_spacing", default: "required", kind: "value"}
		route: {kind: "mapped", path: "y.tickSpacing", order: 66}
	},
	{
		name:        "yTickPadding"
		type:        "numberReference"
		description: "The distance between an axis tick mark and its associated text label (in\npixels); often defaults to 3, but may be affected by **yTickSize** and\n**yTickRotate**."
		tsSection:   "yTickPadding-76"
		jsSection:   "yTickPadding-78"
		jsKind:      "simple"
		python: {name: "y_tick_padding", default: "required", kind: "value"}
		route: {kind: "mapped", path: "y.tickPadding", order: 67}
	},
	{
		name:        "yTickFormat"
		type:        "nullableString"
		description: "How to format inputs (abstract values) for axis tick labels; one of:\n\n- a [d3-format][1] string for numeric scales\n- a [d3-time-format][2] string for temporal scales\n\n[1]: https://d3js.org/d3-time\n[2]: https://d3js.org/d3-time-format"
		tsSection:   "yTickFormat-77"
		jsSection:   "yTickFormat-79"
		jsKind:      "simple"
		python: {name: "y_tick_format", default: "required", kind: "value"}
		route: {kind: "mapped", path: "y.tickFormat", order: 68}
	},
	{
		name:        "yTickRotate"
		type:        "numberReference"
		description: "The rotation angle of axis tick labels in degrees clocksize; defaults to 0."
		tsSection:   "yTickRotate-78"
		jsSection:   "yTickRotate-80"
		jsKind:      "simple"
		python: {name: "y_tick_rotate", default: "required", kind: "value"}
		route: {kind: "mapped", path: "y.tickRotate", order: 69}
	},
	{
		name:        "yGrid"
		type:        "gridValue"
		description: "Whether to show a grid aligned with the scale\u2019s ticks. If true, show a grid\nwith the currentColor stroke; if a string, show a grid with the specified\nstroke color; if an approximate number of ticks, an interval, or an array\nof tick values, show corresponding grid lines. See also the grid mark.\n\nFor axes only."
		tsSection:   "yGrid-79"
		jsSection:   "yGrid-81"
		jsKind:      "simple"
		python: {name: "y_grid", default: "true", kind: "value"}
		route: {kind: "mapped", path: "y.grid", order: 70}
	},
	{
		name:        "yLine"
		type:        "booleanReference"
		description: "If true, draw a line along the axis; if false (default), do not."
		tsSection:   "yLine-80"
		jsSection:   "yLine-82"
		jsKind:      "simple"
		python: {name: "y_line", default: "true", kind: "value"}
		route: {kind: "mapped", path: "y.line", order: 71}
	},
	{
		name:        "yLabel"
		type:        "nullableString"
		description: "A textual label to show on the axis or legend; if null, show no label. By\ndefault the scale label is inferred from channel definitions, possibly with\nan arrow (\u2191, \u2192, \u2193, or \u2190) to indicate the direction of increasing value.\n\nFor axes and legends only."
		tsSection:   "yLabel-81"
		jsSection:   "yLabel-83"
		jsKind:      "simple"
		python: {name: "y_label", default: "required", kind: "value"}
		route: {kind: "mapped", path: "y.label", order: 72}
	},
	{
		name:        "yLabelAnchor"
		type:        "anchorValue"
		description: "Where to place the axis **label** relative to the plot\u2019s frame. For\nvertical position scales (*y* and *fy*), may be *top*, *bottom*, or\n*center*; for horizontal position scales (*x* and *fx*), may be *left*,\n*right*, or *center*. Defaults to *center* for ordinal scales (including\n*fx* and *fy*), and otherwise *top* for *y*, and *right* for *x*."
		tsSection:   "yLabelAnchor-82"
		jsSection:   "yLabelAnchor-84"
		jsKind:      "simple"
		python: {name: "y_label_anchor", default: "required", kind: "value"}
		route: {kind: "mapped", path: "y.labelAnchor", order: 73}
	},
	{
		name:        "yLabelArrow"
		type:        "arrowValue"
		description: "Whether to apply a directional arrow such as \u2192 or \u2191 to the x-axis scale\nlabel. If *auto* (the default), the presence of the arrow depends on\nwhether the scale is ordinal."
		tsSection:   "yLabelArrow-83"
		jsSection:   "yLabelArrow-85"
		jsKind:      "simple"
		python: {name: "y_label_arrow", default: "required", kind: "value"}
		route: {kind: "mapped", path: "y.labelArrow", order: 74}
	},
	{
		name:        "yLabelOffset"
		type:        "numberReference"
		description: "The axis **label** position offset (in pixels); default depends on margins\nand orientation."
		tsSection:   "yLabelOffset-84"
		jsSection:   "yLabelOffset-86"
		jsKind:      "simple"
		python: {name: "y_label_offset", default: "required", kind: "value"}
		route: {kind: "mapped", path: "y.labelOffset", order: 75}
	},
	{
		name:        "yFontVariant"
		type:        "stringReference"
		description: "The font-variant attribute for axis ticks; defaults to *tabular-nums* for\nquantitative axes."
		tsSection:   "yFontVariant-85"
		jsSection:   "yFontVariant-87"
		jsKind:      "simple"
		python: {name: "y_font_variant", default: "required", kind: "value"}
		route: {kind: "mapped", path: "y.fontVariant", order: 76}
	},
	{
		name:        "yAriaLabel"
		type:        "stringReference"
		description: "A short label representing the axis in the accessibility tree."
		tsSection:   "yAriaLabel-86"
		jsSection:   "yAriaLabel-88"
		jsKind:      "simple"
		python: {name: "y_aria_label", default: "required", kind: "value"}
		route: {kind: "mapped", path: "y.ariaLabel", order: 77}
	},
	{
		name:        "yAriaDescription"
		type:        "stringReference"
		description: "A textual description for the axis in the accessibility tree."
		tsSection:   "yAriaDescription-87"
		jsSection:   "yAriaDescription-89"
		jsKind:      "simple"
		python: {name: "y_aria_description", default: "required", kind: "value"}
		route: {kind: "mapped", path: "y.ariaDescription", order: 78}
	},
	{
		name:        "yPercent"
		type:        "booleanReference"
		description: "If true, shorthand for a transform suitable for percentages, mapping\nproportions in [0, 1] to [0, 100]."
		tsSection:   "yPercent-88"
		jsSection:   "yPercent-90"
		jsKind:      "simple"
		python: {name: "y_percent", default: "true", kind: "value"}
		route: {kind: "mapped", path: "y.percent", order: 79}
	},
	{
		name:        "yReverse"
		type:        "booleanReference"
		description: "Whether to reverse the scale\u2019s encoding; equivalent to reversing either the\n**domain** or **range**. Note that by default, when the *y* scale is\ncontinuous, the *max* value points to the top of the screen, whereas\nordinal values are ranked from top to bottom."
		tsSection:   "yReverse-89"
		jsSection:   "yReverse-91"
		jsKind:      "simple"
		python: {name: "y_reverse", default: "true", kind: "value"}
		route: {kind: "mapped", path: "y.reverse", order: 80}
	},
	{
		name:        "yZero"
		type:        "booleanReference"
		description: "Whether the **domain** must include zero. If the domain minimum is\npositive, it will be set to zero; otherwise if the domain maximum is\nnegative, it will be set to zero.\n\nFor quantitative scales only."
		tsSection:   "yZero-90"
		jsSection:   "yZero-92"
		jsKind:      "simple"
		python: {name: "y_zero", default: "true", kind: "value"}
		route: {kind: "mapped", path: "y.zero", order: 81}
	},
	{
		name:        "yExponent"
		type:        "numberReference"
		description: "A power scale\u2019s exponent (*e.g.*, 0.5 for sqrt); defaults to 1 for a\nlinear scale. For *pow* scales only."
		tsSection:   "yExponent-91"
		jsSection:   "yExponent-94"
		jsKind:      "simple"
		python: {name: "y_exponent", default: "required", kind: "value"}
		route: {kind: "mapped", path: "y.exponent", order: 83}
	},
	{
		name:        "yBase"
		type:        "numberReference"
		description: "A log scale\u2019s base; defaults to 10. Does not affect the scale\u2019s encoding,\nbut rather the default ticks. For *log* scales only."
		tsSection:   "yBase-92"
		jsSection:   "yBase-93"
		jsKind:      "simple"
		python: {name: "y_base", default: "required", kind: "value"}
		route: {kind: "mapped", path: "y.base", order: 82}
	},
	{
		name:        "yConstant"
		type:        "numberReference"
		description: "A symlog scale\u2019s constant, expressing the magnitude of the linear region\naround the origin; defaults to 1. For *symlog* scales only."
		tsSection:   "yConstant-93"
		jsSection:   "yConstant-95"
		jsKind:      "simple"
		python: {name: "y_constant", default: "required", kind: "value"}
		route: {kind: "mapped", path: "y.constant", order: 84}
	},
	{
		name:        "xyDomain"
		type:        "domainValue"
		description: "Set the *x* and *y* scale domains."
		tsSection:   "xyDomain-94"
		jsSection:   "xyDomain-8"
		jsKind:      "paired"
		python: {name: "xy_domain", default: "required", kind: "value"}
		route: kind: "wrapper-only"
		targets: ["xDomain", "yDomain"]
	},
]
attributeIndex: {for Attribute in attributes {(Attribute.name): Attribute}}
checks: {
	pythonDefaults: [for Attribute in attributes {
		if list.Contains(["xNice", "xClamp", "xRound", "xAxis", "xGrid", "xLine", "xPercent", "xReverse", "xZero", "yNice", "yClamp", "yRound", "yAxis", "yGrid", "yLine", "yPercent", "yReverse", "yZero"], Attribute.name) {true & (Attribute.python.default == "true")}
		if !list.Contains(["xNice", "xClamp", "xRound", "xAxis", "xGrid", "xLine", "xPercent", "xReverse", "xZero", "yNice", "yClamp", "yRound", "yAxis", "yGrid", "yLine", "yPercent", "yReverse", "yZero"], Attribute.name) {true & (Attribute.python.default == "required")}
	}]
	paired: [for Attribute in attributes if Attribute.name == "xyDomain" {Attribute & {jsKind: "paired", targets: ["xDomain", "yDomain"], route: kind: "wrapper-only"}}]
	ordinary: [for Attribute in attributes if Attribute.name != "xyDomain" {Attribute & {jsKind: "simple", route: kind: "mapped"}}]
}
