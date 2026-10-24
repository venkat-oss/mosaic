package colorattributes

import (
	"list"
	attributeModel "idl.uw.edu/mosaic/api/attributes"
)

#ColorAttribute: attributeModel.#Attribute & {
	name:   =~"^(color|opacity|symbol)[A-Z]"
	jsKind: "simple"
	python: kind: "value"
	route: kind:  "mapped"
}

attributes: [...#ColorAttribute] & [
	{
		name:        "colorScale"
		type:        "colorScaleValue"
		description: "The *color* scale type, affecting how the scale encodes abstract data, say by applying a mathematical transformation. If null, the scale is disabled.\n\nFor quantitative data (numbers), defaults to *linear*; for temporal data (dates), defaults to *utc*; for ordinal data (strings or booleans), defaults to *point* for position scales, *categorical* for color scales, and otherwise *ordinal*."
		tsSection:   "colorScale-154"
		jsSection:   "colorScale-155"
		jsKind:      "simple"
		python: {name: "color_scale", default: "required", kind: "value"}
		route: {kind: "mapped", path: "color.type", order: 144}
	},
	{
		name:        "colorDomain"
		type:        "domainValue"
		description: "The extent of the scale’s inputs (abstract values). By default inferred from channel values. For continuous data (numbers and dates), it is typically [*min*, *max*]; it can be [*max*, *min*] to reverse the scale. For ordinal data (strings or booleans), it is an array (or iterable) of values is the desired order, defaulting to natural ascending order."
		tsSection:   "colorDomain-155"
		jsSection:   "colorDomain-156"
		jsKind:      "simple"
		python: {name: "color_domain", default: "required", kind: "value"}
		route: {kind: "mapped", path: "color.domain", order: 145}
	},
	{
		name:        "colorRange"
		type:        "domainValue"
		description: "The extent of the scale’s outputs (visual values). By default inferred from the scale’s **type** and **domain**. For other ordinal data, it is an array (or iterable) of output values in the same order as the **domain**."
		tsSection:   "colorRange-156"
		jsSection:   "colorRange-157"
		jsKind:      "simple"
		python: {name: "color_range", default: "required", kind: "value"}
		route: {kind: "mapped", path: "color.range", order: 146}
	},
	{
		name:        "colorClamp"
		type:        "booleanReference"
		description: "If true, values below the domain minimum are treated as the domain minimum, and values above the domain maximum are treated as the domain maximum.\n\nClamping is useful for focusing on a subset of the data while ensuring that extreme values remain visible, but use caution: clamped values may need an annotation to avoid misinterpretation. Clamping typically requires setting an explicit **domain** since if the domain is inferred, no values will be outside the domain.\n\nFor continuous scales only."
		tsSection:   "colorClamp-157"
		jsSection:   "colorClamp-158"
		jsKind:      "simple"
		python: {name: "color_clamp", default: "true", kind: "value"}
		route: {kind: "mapped", path: "color.clamp", order: 147}
	},
	{
		name:        "colorN"
		type:        "numberReference"
		description: "For a *quantile* scale, the number of quantiles (creates *n* - 1 thresholds); for a *quantize* scale, the approximate number of thresholds; defaults to 5."
		tsSection:   "colorN-158"
		jsSection:   "colorN-159"
		jsKind:      "simple"
		python: {name: "color_n", default: "required", kind: "value"}
		route: {kind: "mapped", path: "color.n", order: 148}
	},
	{
		name:        "colorNice"
		type:        "niceValue"
		description: "If true, or a tick count or interval, extend the domain to nice round values. Defaults to 1, 2 or 5 times a power of 10 for *linear* scales, and nice time intervals for *utc* and *time* scales. Pass an interval such as\n*minute*, *wednesday* or *month* to specify what constitutes a nice interval.\n\nFor continuous scales only."
		tsSection:   "colorNice-159"
		jsSection:   "colorNice-160"
		jsKind:      "simple"
		python: {name: "color_nice", default: "true", kind: "value"}
		route: {kind: "mapped", path: "color.nice", order: 149}
	},
	{
		name:        "colorScheme"
		type:        "schemeValue"
		description: "If specified, shorthand for setting the **colorRange** or **colorInterpolate** option of a *color* scale."
		tsSection:   "colorScheme-160"
		jsSection:   "colorScheme-161"
		jsKind:      "simple"
		python: {name: "color_scheme", default: "required", kind: "value"}
		route: {kind: "mapped", path: "color.scheme", order: 150}
	},
	{
		name:        "colorInterpolate"
		type:        "interpolateValue"
		description: "How to interpolate color range values. For quantitative scales only. This attribute can be used to specify a color space for interpolating colors specified in the **colorRange**."
		tsSection:   "colorInterpolate-161"
		jsSection:   "colorInterpolate-162"
		jsKind:      "simple"
		python: {name: "color_interpolate", default: "required", kind: "value"}
		route: {kind: "mapped", path: "color.interpolate", order: 151}
	},
	{
		name:        "colorPivot"
		type:        "pivotValue"
		description: "For a diverging color scale, the input value (abstract value) that divides the domain into two parts; defaults to 0 for *diverging* scales, dividing the domain into negative and positive parts; defaults to 1 for\n*diverging-log* scales. By default, diverging scales are symmetric around the pivot; see the **symmetric** option."
		tsSection:   "colorPivot-162"
		jsSection:   "colorPivot-163"
		jsKind:      "simple"
		python: {name: "color_pivot", default: "required", kind: "value"}
		route: {kind: "mapped", path: "color.pivot", order: 152}
	},
	{
		name:        "colorSymmetric"
		type:        "booleanReference"
		description: "For a diverging color scale, if true (the default), extend the domain to ensure that the lower part of the domain (below the **pivot**) is commensurate with the upper part of the domain (above the **pivot**).\n\nA symmetric diverging color scale may not use all of its output **range**; this reduces contrast but ensures that deviations both below and above the\n**pivot** are represented proportionally. Otherwise if false, the full output **range** will be used; this increases contrast but values on opposite sides of the **pivot** may not be meaningfully compared."
		tsSection:   "colorSymmetric-163"
		jsSection:   "colorSymmetric-164"
		jsKind:      "simple"
		python: {name: "color_symmetric", default: "true", kind: "value"}
		route: {kind: "mapped", path: "color.symmetric", order: 153}
	},
	{
		name:        "colorLabel"
		type:        "labelValue"
		description: "A textual label to show on the axis or legend; if null, show no label. By default the scale label is inferred from channel definitions, possibly with an arrow (↑, →, ↓, or ←) to indicate the direction of increasing value.\n\nFor axes and legends only."
		tsSection:   "colorLabel-164"
		jsSection:   "colorLabel-165"
		jsKind:      "simple"
		python: {name: "color_label", default: "required", kind: "value"}
		route: {kind: "mapped", path: "color.label", order: 154}
	},
	{
		name:        "colorPercent"
		type:        "booleanReference"
		description: "If true, shorthand for a transform suitable for percentages, mapping proportions in [0, 1] to [0, 100]."
		tsSection:   "colorPercent-165"
		jsSection:   "colorPercent-166"
		jsKind:      "simple"
		python: {name: "color_percent", default: "true", kind: "value"}
		route: {kind: "mapped", path: "color.percent", order: 155}
	},
	{
		name:        "colorReverse"
		type:        "booleanReference"
		description: "Whether to reverse the scale’s encoding; equivalent to reversing either the\n**domain** or **range**."
		tsSection:   "colorReverse-166"
		jsSection:   "colorReverse-167"
		jsKind:      "simple"
		python: {name: "color_reverse", default: "true", kind: "value"}
		route: {kind: "mapped", path: "color.reverse", order: 156}
	},
	{
		name:        "colorZero"
		type:        "booleanReference"
		description: "Whether the **domain** must include zero. If the domain minimum is positive, it will be set to zero; otherwise if the domain maximum is negative, it will be set to zero.\n\nFor quantitative scales only."
		tsSection:   "colorZero-167"
		jsSection:   "colorZero-168"
		jsKind:      "simple"
		python: {name: "color_zero", default: "true", kind: "value"}
		route: {kind: "mapped", path: "color.zero", order: 157}
	},
	{
		name:        "colorTickFormat"
		type:        "labelValue"
		description: "How to format inputs (abstract values) for axis tick labels; one of:\n\n- a [d3-format][1] string for numeric scales\n- a [d3-time-format][2] string for temporal scales\n\n[1]: https://d3js.org/d3-time [2]: https://d3js.org/d3-time-format"
		tsSection:   "colorTickFormat-168"
		jsSection:   "colorTickFormat-169"
		jsKind:      "simple"
		python: {name: "color_tick_format", default: "required", kind: "value"}
		route: {kind: "mapped", path: "color.tickFormat", order: 158}
	},
	{
		name:        "colorExponent"
		type:        "numberReference"
		description: "A power scale’s exponent (*e.g.*, 0.5 for sqrt); defaults to 1 for a linear scale. For *pow* and *diverging-pow* scales only."
		tsSection:   "colorExponent-169"
		jsSection:   "colorExponent-171"
		jsKind:      "simple"
		python: {name: "color_exponent", default: "required", kind: "value"}
		route: {kind: "mapped", path: "color.exponent", order: 160}
	},
	{
		name:        "colorBase"
		type:        "numberReference"
		description: "A log scale’s base; defaults to 10. Does not affect the scale’s encoding, but rather the default ticks. For *log* and *diverging-log* scales only."
		tsSection:   "colorBase-170"
		jsSection:   "colorBase-170"
		jsKind:      "simple"
		python: {name: "color_base", default: "required", kind: "value"}
		route: {kind: "mapped", path: "color.base", order: 159}
	},
	{
		name:        "colorConstant"
		type:        "numberReference"
		description: "A symlog scale’s constant, expressing the magnitude of the linear region around the origin; defaults to 1. For *symlog* and *diverging-symlog* scales only."
		tsSection:   "colorConstant-171"
		jsSection:   "colorConstant-172"
		jsKind:      "simple"
		python: {name: "color_constant", default: "required", kind: "value"}
		route: {kind: "mapped", path: "color.constant", order: 161}
	},
	{
		name:        "opacityScale"
		type:        "opacityScaleValue"
		description: "The *opacity* scale type, affecting how the scale encodes abstract data, say by applying a mathematical transformation. If null, the scale is disabled. The opacity scale defaults to *linear*; this scales is intended for quantitative data."
		tsSection:   "opacityScale-172"
		jsSection:   "opacityScale-173"
		jsKind:      "simple"
		python: {name: "opacity_scale", default: "required", kind: "value"}
		route: {kind: "mapped", path: "opacity.type", order: 162}
	},
	{
		name:        "opacityDomain"
		type:        "domainValue"
		description: "The extent of the scale’s inputs (abstract values). By default inferred from channel values. For continuous data (numbers and dates), it is typically [*min*, *max*]; it can be [*max*, *min*] to reverse the scale. For ordinal data (strings or booleans), it is an array (or iterable) of values is the desired order, defaulting to natural ascending order.\n\nOpacity scales have a default domain from 0 to the maximum value of associated channels."
		tsSection:   "opacityDomain-173"
		jsSection:   "opacityDomain-174"
		jsKind:      "simple"
		python: {name: "opacity_domain", default: "required", kind: "value"}
		route: {kind: "mapped", path: "opacity.domain", order: 163}
	},
	{
		name:        "opacityRange"
		type:        "domainValue"
		description: "The extent of the scale’s outputs (visual values).\n\nOpacity scales have a default range of [0, 1]."
		tsSection:   "opacityRange-174"
		jsSection:   "opacityRange-175"
		jsKind:      "simple"
		python: {name: "opacity_range", default: "required", kind: "value"}
		route: {kind: "mapped", path: "opacity.range", order: 164}
	},
	{
		name:        "opacityClamp"
		type:        "booleanReference"
		description: "If true, values below the domain minimum are treated as the domain minimum, and values above the domain maximum are treated as the domain maximum.\n\nClamping is useful for focusing on a subset of the data while ensuring that extreme values remain visible, but use caution: clamped values may need an annotation to avoid misinterpretation. Clamping typically requires setting an explicit **domain** since if the domain is inferred, no values will be outside the domain.\n\nFor continuous scales only."
		tsSection:   "opacityClamp-175"
		jsSection:   "opacityClamp-176"
		jsKind:      "simple"
		python: {name: "opacity_clamp", default: "true", kind: "value"}
		route: {kind: "mapped", path: "opacity.clamp", order: 165}
	},
	{
		name:        "opacityNice"
		type:        "niceValue"
		description: "If true, or a tick count or interval, extend the domain to nice round values. Defaults to 1, 2 or 5 times a power of 10 for *linear* scales, and nice time intervals for *utc* and *time* scales. Pass an interval such as\n*minute*, *wednesday* or *month* to specify what constitutes a nice interval.\n\nFor continuous scales only."
		tsSection:   "opacityNice-176"
		jsSection:   "opacityNice-177"
		jsKind:      "simple"
		python: {name: "opacity_nice", default: "true", kind: "value"}
		route: {kind: "mapped", path: "opacity.nice", order: 166}
	},
	{
		name:        "opacityLabel"
		type:        "labelValue"
		description: "A textual label to show on the axis or legend; if null, show no label. By default the scale label is inferred from channel definitions, possibly with an arrow (↑, →, ↓, or ←) to indicate the direction of increasing value.\n\nFor axes and legends only."
		tsSection:   "opacityLabel-177"
		jsSection:   "opacityLabel-178"
		jsKind:      "simple"
		python: {name: "opacity_label", default: "required", kind: "value"}
		route: {kind: "mapped", path: "opacity.label", order: 167}
	},
	{
		name:        "opacityPercent"
		type:        "booleanReference"
		description: "If true, shorthand for a transform suitable for percentages, mapping proportions in [0, 1] to [0, 100]."
		tsSection:   "opacityPercent-178"
		jsSection:   "opacityPercent-179"
		jsKind:      "simple"
		python: {name: "opacity_percent", default: "true", kind: "value"}
		route: {kind: "mapped", path: "opacity.percent", order: 168}
	},
	{
		name:        "opacityReverse"
		type:        "booleanReference"
		description: "Whether to reverse the scale’s encoding; equivalent to reversing either the\n**domain** or **range**."
		tsSection:   "opacityReverse-179"
		jsSection:   "opacityReverse-180"
		jsKind:      "simple"
		python: {name: "opacity_reverse", default: "true", kind: "value"}
		route: {kind: "mapped", path: "opacity.reverse", order: 169}
	},
	{
		name:        "opacityZero"
		type:        "booleanReference"
		description: "Whether the **domain** must include zero. If the domain minimum is positive, it will be set to zero; otherwise if the domain maximum is negative, it will be set to zero.\n\nFor quantitative scales only."
		tsSection:   "opacityZero-180"
		jsSection:   "opacityZero-181"
		jsKind:      "simple"
		python: {name: "opacity_zero", default: "true", kind: "value"}
		route: {kind: "mapped", path: "opacity.zero", order: 170}
	},
	{
		name:        "opacityTickFormat"
		type:        "labelValue"
		description: "How to format inputs (abstract values) for axis tick labels; one of:\n\n- a [d3-format][1] string for numeric scales\n- a [d3-time-format][2] string for temporal scales\n\n[1]: https://d3js.org/d3-time [2]: https://d3js.org/d3-time-format"
		tsSection:   "opacityTickFormat-181"
		jsSection:   "opacityTickFormat-182"
		jsKind:      "simple"
		python: {name: "opacity_tick_format", default: "required", kind: "value"}
		route: {kind: "mapped", path: "opacity.tickFormat", order: 171}
	},
	{
		name:        "opacityExponent"
		type:        "numberReference"
		description: "A power scale’s exponent (*e.g.*, 0.5 for sqrt); defaults to 1 for a linear scale. For *pow* scales only."
		tsSection:   "opacityExponent-182"
		jsSection:   "opacityExponent-184"
		jsKind:      "simple"
		python: {name: "opacity_exponent", default: "required", kind: "value"}
		route: {kind: "mapped", path: "opacity.exponent", order: 173}
	},
	{
		name:        "opacityBase"
		type:        "numberReference"
		description: "A log scale’s base; defaults to 10. Does not affect the scale’s encoding, but rather the default ticks. For *log* scales only."
		tsSection:   "opacityBase-183"
		jsSection:   "opacityBase-183"
		jsKind:      "simple"
		python: {name: "opacity_base", default: "required", kind: "value"}
		route: {kind: "mapped", path: "opacity.base", order: 172}
	},
	{
		name:        "opacityConstant"
		type:        "numberReference"
		description: "A symlog scale’s constant, expressing the magnitude of the linear region around the origin; defaults to 1. For *symlog* scales only."
		tsSection:   "opacityConstant-184"
		jsSection:   "opacityConstant-185"
		jsKind:      "simple"
		python: {name: "opacity_constant", default: "required", kind: "value"}
		route: {kind: "mapped", path: "opacity.constant", order: 174}
	},
	{
		name:        "symbolScale"
		type:        "symbolScaleValue"
		description: "The *symbol* scale type, affecting how the scale encodes abstract data, say by applying a mathematical transformation. If null, the scale is disabled. Defaults to an *ordinal* scale type."
		tsSection:   "symbolScale-185"
		jsSection:   "symbolScale-186"
		jsKind:      "simple"
		python: {name: "symbol_scale", default: "required", kind: "value"}
		route: {kind: "mapped", path: "symbol.type", order: 175}
	},
	{
		name:        "symbolDomain"
		type:        "domainValue"
		description: "The extent of the scale’s inputs (abstract values). By default inferred from channel values. As symbol scales are discrete, the domain is an array (or iterable) of values is the desired order, defaulting to natural ascending order."
		tsSection:   "symbolDomain-186"
		jsSection:   "symbolDomain-187"
		jsKind:      "simple"
		python: {name: "symbol_domain", default: "required", kind: "value"}
		route: {kind: "mapped", path: "symbol.domain", order: 176}
	},
	{
		name:        "symbolRange"
		type:        "domainValue"
		description: "The extent of the scale’s outputs (visual values). By default inferred from the scale’s **type** and **domain**, and for position scales, the plot’s dimensions. For continuous data (numbers and dates), and for ordinal position scales (*point* and *band*), it is typically [*min*, *max*]; it can be [*max*, *min*] to reverse the scale. For other ordinal data, such as for a *color* scale, it is an array (or iterable) of output values in the same order as the **domain**.\n\nSymbol scales have a default range of categorical symbols; the choice of symbols depends on whether the associated dot mark is filled or stroked."
		tsSection:   "symbolRange-187"
		jsSection:   "symbolRange-188"
		jsKind:      "simple"
		python: {name: "symbol_range", default: "required", kind: "value"}
		route: {kind: "mapped", path: "symbol.range", order: 177}
	},
]

attributeIndex: {for A in attributes {(A.name): A}}
checks: booleanDefaults: true & (list.Sort([for A in attributes if A.python.default == "true" {A.name}], list.Ascending) == list.Sort(["colorClamp", "colorNice", "colorSymmetric", "colorPercent", "colorReverse", "colorZero", "opacityClamp", "opacityNice", "opacityPercent", "opacityReverse", "opacityZero"], list.Ascending))
