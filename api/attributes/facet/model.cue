package facetattributes

import (
	"list"
	attributeModel "idl.uw.edu/mosaic/api/attributes"
)

#FacetAttribute: attributeModel.#Attribute & {
	name:   =~"^(facet|fx|fy)[A-Z]"
	jsKind: "simple"
	python: kind: "value"
	route: kind:  "mapped"
}
attributes: [...#FacetAttribute] & [
	{
		name:        "facetMargin"
		type:        "numberReference"
		description: "Shorthand to set the same default for all four facet margins: marginTop, marginRight, marginBottom, and marginLeft."
		tsSection:   "facetMargin-95"
		jsSection:   "facetMargin-96"
		jsKind:      "simple"
		python: {name: "facet_margin", default: "required", kind: "value"}
		route: {kind: "mapped", path: "facet.margin", order: 85}
	},
	{
		name:        "facetMarginTop"
		type:        "numberReference"
		description: "The top facet margin; the (minimum) distance in pixels between the top edges of the inner and outer plot area."
		tsSection:   "facetMarginTop-96"
		jsSection:   "facetMarginTop-97"
		jsKind:      "simple"
		python: {name: "facet_margin_top", default: "required", kind: "value"}
		route: {kind: "mapped", path: "facet.marginTop", order: 86}
	},
	{
		name:        "facetMarginBottom"
		type:        "numberReference"
		description: "The bottom facet margin; the (minimum) distance in pixels between the bottom edges of the inner and outer plot area."
		tsSection:   "facetMarginBottom-97"
		jsSection:   "facetMarginBottom-98"
		jsKind:      "simple"
		python: {name: "facet_margin_bottom", default: "required", kind: "value"}
		route: {kind: "mapped", path: "facet.marginBottom", order: 87}
	},
	{
		name:        "facetMarginLeft"
		type:        "numberReference"
		description: "The left facet margin; the (minimum) distance in pixels between the left edges of the inner and outer plot area."
		tsSection:   "facetMarginLeft-98"
		jsSection:   "facetMarginLeft-99"
		jsKind:      "simple"
		python: {name: "facet_margin_left", default: "required", kind: "value"}
		route: {kind: "mapped", path: "facet.marginLeft", order: 88}
	},
	{
		name:        "facetMarginRight"
		type:        "numberReference"
		description: "The right facet margin; the (minimum) distance in pixels between the right edges of the inner and outer plot area."
		tsSection:   "facetMarginRight-99"
		jsSection:   "facetMarginRight-100"
		jsKind:      "simple"
		python: {name: "facet_margin_right", default: "required", kind: "value"}
		route: {kind: "mapped", path: "facet.marginRight", order: 89}
	},
	{
		name:        "facetGrid"
		type:        "gridValue"
		description: "Default axis grid for fx and fy scales; typically set to true to enable."
		tsSection:   "facetGrid-100"
		jsSection:   "facetGrid-101"
		jsKind:      "simple"
		python: {name: "facet_grid", default: "true", kind: "value"}
		route: {kind: "mapped", path: "facet.grid", order: 90}
	},
	{
		name:        "facetLabel"
		type:        "nullableString"
		description: "Default axis label for fx and fy scales; typically set to null to disable."
		tsSection:   "facetLabel-101"
		jsSection:   "facetLabel-102"
		jsKind:      "simple"
		python: {name: "facet_label", default: "required", kind: "value"}
		route: {kind: "mapped", path: "facet.label", order: 91}
	},
	{
		name:        "fxDomain"
		type:        "domainValue"
		description: "The extent of the scale’s inputs (abstract values). By default inferred from channel values. For ordinal data (strings or booleans), it is an array (or iterable) of values is the desired order, defaulting to natural ascending order."
		tsSection:   "fxDomain-102"
		jsSection:   "fxDomain-103"
		jsKind:      "simple"
		python: {name: "fx_domain", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fx.domain", order: 92}
	},
	{
		name:        "fxRange"
		type:        "domainValue"
		description: "The extent of the scale’s outputs (visual values). By default inferred from the scale’s **type** and **domain**, and the plot’s dimensions. For ordinal position scales (*point* and *band*), it is typically [*min*, *max*]; it can be [*max*, *min*] to reverse the scale."
		tsSection:   "fxRange-103"
		jsSection:   "fxRange-104"
		jsKind:      "simple"
		python: {name: "fx_range", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fx.range", order: 93}
	},
	{
		name:        "fxInset"
		type:        "numberReference"
		description: "Shorthand to set the same default for all four insets: **insetTop**,\n**insetRight**, **insetBottom**, and **insetLeft**. All insets typically default to zero, though not always (say when using bin transform). A positive inset reduces effective area, while a negative inset increases it."
		tsSection:   "fxInset-104"
		jsSection:   "fxInset-105"
		jsKind:      "simple"
		python: {name: "fx_inset", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fx.inset", order: 94}
	},
	{
		name:        "fxInsetRight"
		type:        "numberReference"
		description: "Insets the right edge by the specified number of pixels. A positive value insets towards the left edge (reducing effective area), while a negative value insets away from the left edge (increasing it)."
		tsSection:   "fxInsetRight-105"
		jsSection:   "fxInsetRight-107"
		jsKind:      "simple"
		python: {name: "fx_inset_right", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fx.insetRight", order: 96}
	},
	{
		name:        "fxInsetLeft"
		type:        "numberReference"
		description: "Insets the left edge by the specified number of pixels. A positive value insets towards the right edge (reducing effective area), while a negative value insets away from the right edge (increasing it)."
		tsSection:   "fxInsetLeft-106"
		jsSection:   "fxInsetLeft-106"
		jsKind:      "simple"
		python: {name: "fx_inset_left", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fx.insetLeft", order: 95}
	},
	{
		name:        "fxRound"
		type:        "booleanReference"
		description: "If true, round the output value to the nearest integer (pixel); useful for crisp edges when rendering.\n\nFor position scales only."
		tsSection:   "fxRound-107"
		jsSection:   "fxRound-108"
		jsKind:      "simple"
		python: {name: "fx_round", default: "true", kind: "value"}
		route: {kind: "mapped", path: "fx.round", order: 97}
	},
	{
		name:        "fxAlign"
		type:        "numberReference"
		description: "How to distribute unused space in the **range** for *point* and *band* scales. A number in [0, 1], such as:\n\n- 0 - use the start of the range, putting unused space at the end\n- 0.5 (default) - use the middle, distributing unused space evenly\n- 1 use the end, putting unused space at the start\n\nFor ordinal position scales only."
		tsSection:   "fxAlign-108"
		jsSection:   "fxAlign-109"
		jsKind:      "simple"
		python: {name: "fx_align", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fx.align", order: 98}
	},
	{
		name:        "fxPadding"
		type:        "numberReference"
		description: "For *band* scales, how much of the **range** to reserve to separate adjacent bands; defaults to 0.1 (10%). For *point* scales, the amount of inset for the first and last value as a proportion of the bandwidth; defaults to 0.5 (50%).\n\nFor ordinal position scales only."
		tsSection:   "fxPadding-109"
		jsSection:   "fxPadding-110"
		jsKind:      "simple"
		python: {name: "fx_padding", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fx.padding", order: 99}
	},
	{
		name:        "fxPaddingInner"
		type:        "numberReference"
		description: "For a *band* scale, how much of the range to reserve to separate adjacent bands."
		tsSection:   "fxPaddingInner-110"
		jsSection:   "fxPaddingInner-111"
		jsKind:      "simple"
		python: {name: "fx_padding_inner", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fx.paddingInner", order: 100}
	},
	{
		name:        "fxPaddingOuter"
		type:        "numberReference"
		description: "For a *band* scale, how much of the range to reserve to inset first and last bands."
		tsSection:   "fxPaddingOuter-111"
		jsSection:   "fxPaddingOuter-112"
		jsKind:      "simple"
		python: {name: "fx_padding_outer", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fx.paddingOuter", order: 101}
	},
	{
		name:        "fxAxis"
		type:        "xAxisValue"
		description: "The side of the frame on which to place the implicit axis: *top* or\n*bottom* for *fx*. Defaults to *top* if there is a *bottom* *x* axis, and otherwise *bottom*.\n\nIf *both*, an implicit axis will be rendered on both sides of the plot (*top* and *bottom* for *fx*). If null, the implicit axis is suppressed."
		tsSection:   "fxAxis-112"
		jsSection:   "fxAxis-113"
		jsKind:      "simple"
		python: {name: "fx_axis", default: "true", kind: "value"}
		route: {kind: "mapped", path: "fx.axis", order: 102}
	},
	{
		name:        "fxTicks"
		type:        "ticksValue"
		description: "The desired approximate number of axis ticks, or an explicit array of tick values, or an interval such as *day* or *month*."
		tsSection:   "fxTicks-113"
		jsSection:   "fxTicks-114"
		jsKind:      "simple"
		python: {name: "fx_ticks", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fx.ticks", order: 103}
	},
	{
		name:        "fxTickSize"
		type:        "numberReference"
		description: "The length of axis tick marks in pixels; negative values extend in the opposite direction. Defaults to 6 for *x* and *y* axes and *color* and\n*opacity* *ramp* legends, and 0 for *fx* and *fy* axes."
		tsSection:   "fxTickSize-114"
		jsSection:   "fxTickSize-115"
		jsKind:      "simple"
		python: {name: "fx_tick_size", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fx.tickSize", order: 104}
	},
	{
		name:        "fxTickSpacing"
		type:        "numberReference"
		description: "The desired approximate spacing between adjacent axis ticks, affecting the default **ticks**; defaults to 80 pixels for *x* and *fx*, and 35 pixels for *y* and *fy*."
		tsSection:   "fxTickSpacing-115"
		jsSection:   "fxTickSpacing-116"
		jsKind:      "simple"
		python: {name: "fx_tick_spacing", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fx.tickSpacing", order: 105}
	},
	{
		name:        "fxTickPadding"
		type:        "numberReference"
		description: "The distance between an axis tick mark and its associated text label (in pixels); often defaults to 3, but may be affected by **fxTickSize** and\n**fxTickRotate**."
		tsSection:   "fxTickPadding-116"
		jsSection:   "fxTickPadding-117"
		jsKind:      "simple"
		python: {name: "fx_tick_padding", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fx.tickPadding", order: 106}
	},
	{
		name:        "fxTickFormat"
		type:        "nullableString"
		description: "How to format inputs (abstract values) for axis tick labels; one of:\n\n- a [d3-format][1] string for numeric scales\n- a [d3-time-format][2] string for temporal scales\n\n[1]: https://d3js.org/d3-time [2]: https://d3js.org/d3-time-format"
		tsSection:   "fxTickFormat-117"
		jsSection:   "fxTickFormat-118"
		jsKind:      "simple"
		python: {name: "fx_tick_format", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fx.tickFormat", order: 107}
	},
	{
		name:        "fxTickRotate"
		type:        "numberReference"
		description: "The rotation angle of axis tick labels in degrees clocksize; defaults to 0."
		tsSection:   "fxTickRotate-118"
		jsSection:   "fxTickRotate-119"
		jsKind:      "simple"
		python: {name: "fx_tick_rotate", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fx.tickRotate", order: 108}
	},
	{
		name:        "fxGrid"
		type:        "gridValue"
		description: "Whether to show a grid aligned with the scale’s ticks. If true, show a grid with the currentColor stroke; if a string, show a grid with the specified stroke color; if an approximate number of ticks, an interval, or an array of tick values, show corresponding grid lines. See also the grid mark.\n\nFor axes only."
		tsSection:   "fxGrid-119"
		jsSection:   "fxGrid-120"
		jsKind:      "simple"
		python: {name: "fx_grid", default: "true", kind: "value"}
		route: {kind: "mapped", path: "fx.grid", order: 109}
	},
	{
		name:        "fxLine"
		type:        "booleanReference"
		description: "If true, draw a line along the axis; if false (default), do not."
		tsSection:   "fxLine-120"
		jsSection:   "fxLine-121"
		jsKind:      "simple"
		python: {name: "fx_line", default: "true", kind: "value"}
		route: {kind: "mapped", path: "fx.line", order: 110}
	},
	{
		name:        "fxLabel"
		type:        "nullableString"
		description: "A textual label to show on the axis or legend; if null, show no label. By default the scale label is inferred from channel definitions, possibly with an arrow (↑, →, ↓, or ←) to indicate the direction of increasing value.\n\nFor axes and legends only."
		tsSection:   "fxLabel-121"
		jsSection:   "fxLabel-122"
		jsKind:      "simple"
		python: {name: "fx_label", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fx.label", order: 111}
	},
	{
		name:        "fxLabelAnchor"
		type:        "anchorValue"
		description: "Where to place the axis **label** relative to the plot’s frame. For vertical position scales (*y* and *fy*), may be *top*, *bottom*, or\n*center*; for horizontal position scales (*x* and *fx*), may be *left*,\n*right*, or *center*. Defaults to *center* for ordinal scales (including\n*fx* and *fy*), and otherwise *top* for *y*, and *right* for *x*."
		tsSection:   "fxLabelAnchor-122"
		jsSection:   "fxLabelAnchor-123"
		jsKind:      "simple"
		python: {name: "fx_label_anchor", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fx.labelAnchor", order: 112}
	},
	{
		name:        "fxLabelOffset"
		type:        "numberReference"
		description: "The axis **label** position offset (in pixels); default depends on margins and orientation."
		tsSection:   "fxLabelOffset-123"
		jsSection:   "fxLabelOffset-124"
		jsKind:      "simple"
		python: {name: "fx_label_offset", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fx.labelOffset", order: 113}
	},
	{
		name:        "fxFontVariant"
		type:        "stringReference"
		description: "The font-variant attribute for axis ticks; defaults to *tabular-nums* for quantitative axes."
		tsSection:   "fxFontVariant-124"
		jsSection:   "fxFontVariant-125"
		jsKind:      "simple"
		python: {name: "fx_font_variant", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fx.fontVariant", order: 114}
	},
	{
		name:        "fxAriaLabel"
		type:        "stringReference"
		description: "A short label representing the axis in the accessibility tree."
		tsSection:   "fxAriaLabel-125"
		jsSection:   "fxAriaLabel-126"
		jsKind:      "simple"
		python: {name: "fx_aria_label", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fx.ariaLabel", order: 115}
	},
	{
		name:        "fxAriaDescription"
		type:        "stringReference"
		description: "A textual description for the axis in the accessibility tree."
		tsSection:   "fxAriaDescription-126"
		jsSection:   "fxAriaDescription-127"
		jsKind:      "simple"
		python: {name: "fx_aria_description", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fx.ariaDescription", order: 116}
	},
	{
		name:        "fxReverse"
		type:        "booleanReference"
		description: "Whether to reverse the scale’s encoding; equivalent to reversing either the\n**domain** or **range**."
		tsSection:   "fxReverse-127"
		jsSection:   "fxReverse-128"
		jsKind:      "simple"
		python: {name: "fx_reverse", default: "true", kind: "value"}
		route: {kind: "mapped", path: "fx.reverse", order: 117}
	},
	{
		name:        "fyDomain"
		type:        "domainValue"
		description: "The extent of the scale’s inputs (abstract values). By default inferred from channel values. For ordinal data (strings or booleans), it is an array (or iterable) of values is the desired order, defaulting to natural ascending order."
		tsSection:   "fyDomain-128"
		jsSection:   "fyDomain-129"
		jsKind:      "simple"
		python: {name: "fy_domain", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fy.domain", order: 118}
	},
	{
		name:        "fyRange"
		type:        "domainValue"
		description: "The extent of the scale’s outputs (visual values). By default inferred from the scale’s **type** and **domain**, and the plot’s dimensions. For ordinal position scales (*point* and *band*), it is typically [*min*, *max*]; it can be [*max*, *min*] to reverse the scale."
		tsSection:   "fyRange-129"
		jsSection:   "fyRange-130"
		jsKind:      "simple"
		python: {name: "fy_range", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fy.range", order: 119}
	},
	{
		name:        "fyInset"
		type:        "numberReference"
		description: "Shorthand to set the same default for all four insets: **insetTop**,\n**insetRight**, **insetBottom**, and **insetLeft**. All insets typically default to zero, though not always (say when using bin transform). A positive inset reduces effective area, while a negative inset increases it."
		tsSection:   "fyInset-130"
		jsSection:   "fyInset-131"
		jsKind:      "simple"
		python: {name: "fy_inset", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fy,inset", order: 120}
	},
	{
		name:        "fyInsetTop"
		type:        "numberReference"
		description: "Insets the top edge by the specified number of pixels. A positive value insets towards the bottom edge (reducing effective area), while a negative value insets away from the bottom edge (increasing it)."
		tsSection:   "fyInsetTop-131"
		jsSection:   "fyInsetTop-132"
		jsKind:      "simple"
		python: {name: "fy_inset_top", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fy.insetTop", order: 121}
	},
	{
		name:        "fyInsetBottom"
		type:        "numberReference"
		description: "Insets the bottom edge by the specified number of pixels. A positive value insets towards the top edge (reducing effective area), while a negative value insets away from the top edge (increasing it)."
		tsSection:   "fyInsetBottom-132"
		jsSection:   "fyInsetBottom-133"
		jsKind:      "simple"
		python: {name: "fy_inset_bottom", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fy.insetBottom", order: 122}
	},
	{
		name:        "fyRound"
		type:        "booleanReference"
		description: "If true, round the output value to the nearest integer (pixel); useful for crisp edges when rendering.\n\nFor position scales only."
		tsSection:   "fyRound-133"
		jsSection:   "fyRound-134"
		jsKind:      "simple"
		python: {name: "fy_round", default: "true", kind: "value"}
		route: {kind: "mapped", path: "fy.round", order: 123}
	},
	{
		name:        "fyAlign"
		type:        "numberReference"
		description: "How to distribute unused space in the **range** for *point* and *band* scales. A number in [0, 1], such as:\n\n- 0 - use the start of the range, putting unused space at the end\n- 0.5 (default) - use the middle, distributing unused space evenly\n- 1 use the end, putting unused space at the start\n\nFor ordinal position scales only."
		tsSection:   "fyAlign-134"
		jsSection:   "fyAlign-135"
		jsKind:      "simple"
		python: {name: "fy_align", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fy.align", order: 124}
	},
	{
		name:        "fyPadding"
		type:        "numberReference"
		description: "For *band* scales, how much of the **range** to reserve to separate adjacent bands; defaults to 0.1 (10%). For *point* scales, the amount of inset for the first and last value as a proportion of the bandwidth; defaults to 0.5 (50%).\n\nFor ordinal position scales only."
		tsSection:   "fyPadding-135"
		jsSection:   "fyPadding-136"
		jsKind:      "simple"
		python: {name: "fy_padding", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fy.padding", order: 125}
	},
	{
		name:        "fyPaddingInner"
		type:        "numberReference"
		description: "For a *band* scale, how much of the range to reserve to separate adjacent bands."
		tsSection:   "fyPaddingInner-136"
		jsSection:   "fyPaddingInner-137"
		jsKind:      "simple"
		python: {name: "fy_padding_inner", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fy.paddingInner", order: 126}
	},
	{
		name:        "fyPaddingOuter"
		type:        "numberReference"
		description: "For a *band* scale, how much of the range to reserve to inset first and last bands."
		tsSection:   "fyPaddingOuter-137"
		jsSection:   "fyPaddingOuter-138"
		jsKind:      "simple"
		python: {name: "fy_padding_outer", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fy.paddingOuter", order: 127}
	},
	{
		name:        "fyAxis"
		type:        "yAxisValue"
		description: "The side of the frame on which to place the implicit axis: *left* or\n*right* for *fy*. Defaults to *left* for an *fy* scale.\n\nIf *both*, an implicit axis will be rendered on both sides of the plot (*left* and *right* for *fy*). If null, the implicit axis is suppressed."
		tsSection:   "fyAxis-138"
		jsSection:   "fyAxis-139"
		jsKind:      "simple"
		python: {name: "fy_axis", default: "true", kind: "value"}
		route: {kind: "mapped", path: "fy.axis", order: 128}
	},
	{
		name:        "fyTicks"
		type:        "ticksValue"
		description: "The desired approximate number of axis ticks, or an explicit array of tick values, or an interval such as *day* or *month*."
		tsSection:   "fyTicks-139"
		jsSection:   "fyTicks-140"
		jsKind:      "simple"
		python: {name: "fy_ticks", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fy.ticks", order: 129}
	},
	{
		name:        "fyTickSize"
		type:        "numberReference"
		description: "The length of axis tick marks in pixels; negative values extend in the opposite direction. Defaults to 6 for *x* and *y* axes and *color* and\n*opacity* *ramp* legends, and 0 for *fx* and *fy* axes."
		tsSection:   "fyTickSize-140"
		jsSection:   "fyTickSize-141"
		jsKind:      "simple"
		python: {name: "fy_tick_size", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fy.tickSize", order: 130}
	},
	{
		name:        "fyTickSpacing"
		type:        "numberReference"
		description: "The desired approximate spacing between adjacent axis ticks, affecting the default **ticks**; defaults to 80 pixels for *x* and *fx*, and 35 pixels for *y* and *fy*."
		tsSection:   "fyTickSpacing-141"
		jsSection:   "fyTickSpacing-142"
		jsKind:      "simple"
		python: {name: "fy_tick_spacing", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fy.tickSpacing", order: 131}
	},
	{
		name:        "fyTickPadding"
		type:        "numberReference"
		description: "The distance between an axis tick mark and its associated text label (in pixels); often defaults to 3, but may be affected by **fyTickSize** and\n**fyTickRotate**."
		tsSection:   "fyTickPadding-142"
		jsSection:   "fyTickPadding-143"
		jsKind:      "simple"
		python: {name: "fy_tick_padding", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fy.tickPadding", order: 132}
	},
	{
		name:        "fyTickFormat"
		type:        "nullableString"
		description: "How to format inputs (abstract values) for axis tick labels; one of:\n\n- a [d3-format][1] string for numeric scales\n- a [d3-time-format][2] string for temporal scales\n\n[1]: https://d3js.org/d3-time [2]: https://d3js.org/d3-time-format"
		tsSection:   "fyTickFormat-143"
		jsSection:   "fyTickFormat-144"
		jsKind:      "simple"
		python: {name: "fy_tick_format", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fy.tickFormat", order: 133}
	},
	{
		name:        "fyTickRotate"
		type:        "numberReference"
		description: "The rotation angle of axis tick labels in degrees clocksize; defaults to 0."
		tsSection:   "fyTickRotate-144"
		jsSection:   "fyTickRotate-145"
		jsKind:      "simple"
		python: {name: "fy_tick_rotate", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fy.tickRotate", order: 134}
	},
	{
		name:        "fyGrid"
		type:        "gridValue"
		description: "Whether to show a grid aligned with the scale’s ticks. If true, show a grid with the currentColor stroke; if a string, show a grid with the specified stroke color; if an approximate number of ticks, an interval, or an array of tick values, show corresponding grid lines. See also the grid mark.\n\nFor axes only."
		tsSection:   "fyGrid-145"
		jsSection:   "fyGrid-146"
		jsKind:      "simple"
		python: {name: "fy_grid", default: "true", kind: "value"}
		route: {kind: "mapped", path: "fy.grid", order: 135}
	},
	{
		name:        "fyLine"
		type:        "booleanReference"
		description: "If true, draw a line along the axis; if false (default), do not."
		tsSection:   "fyLine-146"
		jsSection:   "fyLine-147"
		jsKind:      "simple"
		python: {name: "fy_line", default: "true", kind: "value"}
		route: {kind: "mapped", path: "fy.line", order: 136}
	},
	{
		name:        "fyLabel"
		type:        "nullableString"
		description: "A textual label to show on the axis or legend; if null, show no label. By default the scale label is inferred from channel definitions, possibly with an arrow (↑, →, ↓, or ←) to indicate the direction of increasing value.\n\nFor axes and legends only."
		tsSection:   "fyLabel-147"
		jsSection:   "fyLabel-148"
		jsKind:      "simple"
		python: {name: "fy_label", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fy.label", order: 137}
	},
	{
		name:        "fyLabelAnchor"
		type:        "anchorValue"
		description: "Where to place the axis **label** relative to the plot’s frame. For vertical position scales (*y* and *fy*), may be *top*, *bottom*, or\n*center*; for horizontal position scales (*x* and *fx*), may be *left*,\n*right*, or *center*. Defaults to *center* for ordinal scales (including\n*fx* and *fy*), and otherwise *top* for *y*, and *right* for *x*."
		tsSection:   "fyLabelAnchor-148"
		jsSection:   "fyLabelAnchor-149"
		jsKind:      "simple"
		python: {name: "fy_label_anchor", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fy.labelAnchor", order: 138}
	},
	{
		name:        "fyLabelOffset"
		type:        "numberReference"
		description: "The axis **label** position offset (in pixels); default depends on margins and orientation."
		tsSection:   "fyLabelOffset-149"
		jsSection:   "fyLabelOffset-150"
		jsKind:      "simple"
		python: {name: "fy_label_offset", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fy.labelOffset", order: 139}
	},
	{
		name:        "fyFontVariant"
		type:        "stringReference"
		description: "The font-variant attribute for axis ticks; defaults to *tabular-nums* for quantitative axes."
		tsSection:   "fyFontVariant-150"
		jsSection:   "fyFontVariant-151"
		jsKind:      "simple"
		python: {name: "fy_font_variant", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fy.fontVariant", order: 140}
	},
	{
		name:        "fyAriaLabel"
		type:        "stringReference"
		description: "A short label representing the axis in the accessibility tree."
		tsSection:   "fyAriaLabel-151"
		jsSection:   "fyAriaLabel-152"
		jsKind:      "simple"
		python: {name: "fy_aria_label", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fy.ariaLabel", order: 141}
	},
	{
		name:        "fyAriaDescription"
		type:        "stringReference"
		description: "A textual description for the axis in the accessibility tree."
		tsSection:   "fyAriaDescription-152"
		jsSection:   "fyAriaDescription-153"
		jsKind:      "simple"
		python: {name: "fy_aria_description", default: "required", kind: "value"}
		route: {kind: "mapped", path: "fy.ariaDescription", order: 142}
	},
	{
		name:        "fyReverse"
		type:        "booleanReference"
		description: "Whether to reverse the scale’s encoding; equivalent to reversing either the\n**domain** or **range**."
		tsSection:   "fyReverse-153"
		jsSection:   "fyReverse-154"
		jsKind:      "simple"
		python: {name: "fy_reverse", default: "true", kind: "value"}
		route: {kind: "mapped", path: "fy.reverse", order: 143}
	},
]
attributeIndex: {for Attribute in attributes {(Attribute.name): Attribute}}
checks: {
	names: true & list.UniqueItems([for Attribute in attributes {Attribute.name}])
	commaRoute: attributeIndex.fyInset.route & {path: "fy,inset", order: 120}
}
