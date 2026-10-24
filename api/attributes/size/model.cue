package sizeattributes

import (
	"list"
	attributeModel "idl.uw.edu/mosaic/api/attributes"
)

#SizeAttribute: attributeModel.#Attribute & {
	type!:  string
	name:   =~"^(r|length)[A-Z]"
	jsKind: "simple"
	python: kind: "value"
	route: kind:  "mapped"
	if type == "booleanReference" || type == "niceValue" {python: default: "true"}
	if type != "booleanReference" && type != "niceValue" {python: default: "required"}
}

attributes: [...#SizeAttribute] & [
	{
		name:        "rScale"
		type:        "scaleValue"
		description: "The *r* (radius) scale type, affecting how the scale encodes abstract\ndata, say by applying a mathematical transformation. If null, the scale\nis disabled. The radius scale defaults to *sqrt*; this scale is intended\nfor quantitative data."
		tsSection:   "rScale-188"
		jsSection:   "rScale-189"
		jsKind:      "simple"
		python: {name: "r_scale", default: "required", kind: "value"}
		route: {kind: "mapped", path: "r.type", order: 0}
	},
	{
		name:        "rDomain"
		type:        "domainValue"
		description: "The extent of the scale’s inputs (abstract values). By default inferred\nfrom channel values. For continuous data (numbers and dates), it is\ntypically [*min*, *max*]; it can be [*max*, *min*] to reverse the scale.\nFor ordinal data (strings or booleans), it is an array (or iterable) of\nvalues is the desired order, defaulting to natural ascending order.\n\nRadius scales have a default domain from 0 to the median first quartile\nof associated channels."
		tsSection:   "rDomain-189"
		jsSection:   "rDomain-190"
		jsKind:      "simple"
		python: {name: "r_domain", default: "required", kind: "value"}
		route: {kind: "mapped", path: "r.domain", order: 1}
	},
	{
		name:        "rRange"
		type:        "domainValue"
		description: "The extent of the scale’s outputs (visual values). By default inferred from\nthe scale’s **type** and **domain**, and for position scales, the plot’s\ndimensions. For continuous data (numbers and dates), and for ordinal\nposition scales (*point* and *band*), it is typically [*min*, *max*]; it\ncan be [*max*, *min*] to reverse the scale. For other ordinal data, such as\nfor a *color* scale, it is an array (or iterable) of output values in the\nsame order as the **domain**.\n\nRadius scales have a default range of [0, 3]."
		tsSection:   "rRange-190"
		jsSection:   "rRange-191"
		jsKind:      "simple"
		python: {name: "r_range", default: "required", kind: "value"}
		route: {kind: "mapped", path: "r.range", order: 2}
	},
	{
		name:        "rClamp"
		type:        "anyValue"
		description: "If true, values below the domain minimum are treated as the domain minimum,\nand values above the domain maximum are treated as the domain maximum.\n\nClamping is useful for focusing on a subset of the data while ensuring that\nextreme values remain visible, but use caution: clamped values may need an\nannotation to avoid misinterpretation. Clamping typically requires setting\nan explicit **domain** since if the domain is inferred, no values will be\noutside the domain.\n\nFor continuous scales only."
		tsSection:   "rClamp-191"
		jsSection:   "rClamp-192"
		jsKind:      "simple"
		python: {name: "r_clamp", default: "required", kind: "value"}
		route: {kind: "mapped", path: "r.clamp", order: 3}
	},
	{
		name:        "rNice"
		type:        "niceValue"
		description: "If true, or a tick count or interval, extend the domain to nice round\nvalues. Defaults to 1, 2 or 5 times a power of 10 for *linear* scales, and\nnice time intervals for *utc* and *time* scales. Pass an interval such as\n*minute*, *wednesday* or *month* to specify what constitutes a nice\ninterval.\n\nFor continuous scales only."
		tsSection:   "rNice-192"
		jsSection:   "rNice-193"
		jsKind:      "simple"
		python: {name: "r_nice", default: "true", kind: "value"}
		route: {kind: "mapped", path: "r.nice", order: 4}
	},
	{
		name:        "rLabel"
		type:        "labelValue"
		description: "A textual label to show on the axis or legend; if null, show no label. By\ndefault the scale label is inferred from channel definitions, possibly with\nan arrow (↑, →, ↓, or ←) to indicate the direction of increasing value."
		tsSection:   "rLabel-193"
		jsSection:   "rLabel-194"
		jsKind:      "simple"
		python: {name: "r_label", default: "required", kind: "value"}
		route: {kind: "mapped", path: "r.label", order: 5}
	},
	{
		name:        "rPercent"
		type:        "booleanReference"
		description: "If true, shorthand for a transform suitable for percentages, mapping\nproportions in [0, 1] to [0, 100]."
		tsSection:   "rPercent-194"
		jsSection:   "rPercent-195"
		jsKind:      "simple"
		python: {name: "r_percent", default: "true", kind: "value"}
		route: {kind: "mapped", path: "r.percent", order: 6}
	},
	{
		name:        "rZero"
		type:        "booleanReference"
		description: "Whether the **domain** must include zero. If the domain minimum is\npositive, it will be set to zero; otherwise if the domain maximum is\nnegative, it will be set to zero.\n\nFor quantitative scales only."
		tsSection:   "rZero-195"
		jsSection:   "rZero-196"
		jsKind:      "simple"
		python: {name: "r_zero", default: "true", kind: "value"}
		route: {kind: "mapped", path: "r.zero", order: 7}
	},
	{
		name:        "rExponent"
		type:        "numberReference"
		description: "A power scale’s exponent (*e.g.*, 0.5 for sqrt); defaults to 1 for a\nlinear scale. For *pow* scales only."
		tsSection:   "rExponent-196"
		jsSection:   "rExponent-198"
		jsKind:      "simple"
		python: {name: "r_exponent", default: "required", kind: "value"}
		route: {kind: "mapped", path: "r.exponent", order: 9}
	},
	{
		name:        "rBase"
		type:        "numberReference"
		description: "A log scale’s base; defaults to 10. Does not affect the scale’s encoding,\nbut rather the default ticks. For *log* scales only."
		tsSection:   "rBase-197"
		jsSection:   "rBase-197"
		jsKind:      "simple"
		python: {name: "r_base", default: "required", kind: "value"}
		route: {kind: "mapped", path: "r.base", order: 8}
	},
	{
		name:        "rConstant"
		type:        "numberReference"
		description: "A symlog scale’s constant, expressing the magnitude of the linear region\naround the origin; defaults to 1. For *symlog* scales only."
		tsSection:   "rConstant-198"
		jsSection:   "rConstant-199"
		jsKind:      "simple"
		python: {name: "r_constant", default: "required", kind: "value"}
		route: {kind: "mapped", path: "r.constant", order: 10}
	},
	{
		name:        "lengthScale"
		type:        "scaleValue"
		description: "The *length* scale type, affecting how the scale encodes abstract data,\nsay by applying a mathematical transformation. If null, the scale is\ndisabled. The length scale defaults to *linear*, as this scale is intended\nfor quantitative data."
		tsSection:   "lengthScale-199"
		jsSection:   "lengthScale-200"
		jsKind:      "simple"
		python: {name: "length_scale", default: "required", kind: "value"}
		route: {kind: "mapped", path: "length.type", order: 11}
	},
	{
		name:        "lengthDomain"
		type:        "domainValue"
		description: "The extent of the scale’s inputs (abstract values). By default inferred\nfrom channel values. For continuous data (numbers and dates), it is\ntypically [*min*, *max*]; it can be [*max*, *min*] to reverse the scale.\nFor ordinal data (strings or booleans), it is an array (or iterable) of\nvalues is the desired order, defaulting to natural ascending order.\n\nLinear scales have a default domain of [0, 1]. Log scales have a default\ndomain of [1, 10] and cannot include zero. Radius scales have a default\ndomain from 0 to the median first quartile of associated channels. Length\nhave a default domain from 0 to the median median of associated channels.\nOpacity scales have a default domain from 0 to the maximum value of\nassociated channels."
		tsSection:   "lengthDomain-200"
		jsSection:   "lengthDomain-201"
		jsKind:      "simple"
		python: {name: "length_domain", default: "required", kind: "value"}
		route: {kind: "mapped", path: "length.domain", order: 12}
	},
	{
		name:        "lengthRange"
		type:        "domainValue"
		description: "The extent of the scale’s outputs (visual values). By default inferred from\nthe scale’s **type** and **domain**, and for position scales, the plot’s\ndimensions. For continuous data (numbers and dates), and for ordinal\nposition scales (*point* and *band*), it is typically [*min*, *max*]; it\ncan be [*max*, *min*] to reverse the scale. For other ordinal data, such as\nfor a *color* scale, it is an array (or iterable) of output values in the\nsame order as the **domain**.\n\nLength scales have a default range of [0, 12]."
		tsSection:   "lengthRange-201"
		jsSection:   "lengthRange-202"
		jsKind:      "simple"
		python: {name: "length_range", default: "required", kind: "value"}
		route: {kind: "mapped", path: "length.range", order: 13}
	},
	{
		name:        "lengthClamp"
		type:        "anyValue"
		description: "If true, values below the domain minimum are treated as the domain minimum,\nand values above the domain maximum are treated as the domain maximum.\n\nClamping is useful for focusing on a subset of the data while ensuring that\nextreme values remain visible, but use caution: clamped values may need an\nannotation to avoid misinterpretation. Clamping typically requires setting\nan explicit **domain** since if the domain is inferred, no values will be\noutside the domain.\n\nFor continuous scales only."
		tsSection:   "lengthClamp-202"
		jsSection:   "lengthClamp-203"
		jsKind:      "simple"
		python: {name: "length_clamp", default: "required", kind: "value"}
		route: {kind: "mapped", path: "length.clamp", order: 14}
	},
	{
		name:        "lengthNice"
		type:        "niceValue"
		description: "If true, or a tick count or interval, extend the domain to nice round\nvalues. Defaults to 1, 2 or 5 times a power of 10 for *linear* scales, and\nnice time intervals for *utc* and *time* scales. Pass an interval such as\n*minute*, *wednesday* or *month* to specify what constitutes a nice\ninterval.\n\nFor continuous scales only."
		tsSection:   "lengthNice-203"
		jsSection:   "lengthNice-204"
		jsKind:      "simple"
		python: {name: "length_nice", default: "true", kind: "value"}
		route: {kind: "mapped", path: "length.nice", order: 15}
	},
	{
		name:        "lengthPercent"
		type:        "booleanReference"
		description: "If true, shorthand for a transform suitable for percentages, mapping\nproportions in [0, 1] to [0, 100]."
		tsSection:   "lengthPercent-204"
		jsSection:   "lengthPercent-205"
		jsKind:      "simple"
		python: {name: "length_percent", default: "true", kind: "value"}
		route: {kind: "mapped", path: "length.percent", order: 16}
	},
	{
		name:        "lengthZero"
		type:        "booleanReference"
		description: "Whether the **domain** must include zero. If the domain minimum is\npositive, it will be set to zero; otherwise if the domain maximum is\nnegative, it will be set to zero.\n\nFor quantitative scales only."
		tsSection:   "lengthZero-205"
		jsSection:   "lengthZero-206"
		jsKind:      "simple"
		python: {name: "length_zero", default: "true", kind: "value"}
		route: {kind: "mapped", path: "length.zero", order: 17}
	},
	{
		name:        "lengthExponent"
		type:        "numberReference"
		description: "A power scale’s exponent (*e.g.*, 0.5 for sqrt); defaults to 1 for a\nlinear scale. For *pow* scales only."
		tsSection:   "lengthExponent-206"
		jsSection:   "lengthExponent-208"
		jsKind:      "simple"
		python: {name: "length_exponent", default: "required", kind: "value"}
		route: {kind: "mapped", path: "length.exponent", order: 19}
	},
	{
		name:        "lengthBase"
		type:        "numberReference"
		description: "A log scale’s base; defaults to 10. Does not affect the scale’s encoding,\nbut rather the default ticks. For *log* scales only."
		tsSection:   "lengthBase-207"
		jsSection:   "lengthBase-207"
		jsKind:      "simple"
		python: {name: "length_base", default: "required", kind: "value"}
		route: {kind: "mapped", path: "length.base", order: 18}
	},
	{
		name:        "lengthConstant"
		type:        "numberReference"
		description: "A symlog scale’s constant, expressing the magnitude of the linear region\naround the origin; defaults to 1. For *symlog* scales only."
		tsSection:   "lengthConstant-208"
		jsSection:   "lengthConstant-209"
		jsKind:      "simple"
		python: {name: "length_constant", default: "required", kind: "value"}
		route: {kind: "mapped", path: "length.constant", order: 20}
	},
]

attributeIndex: {for attribute in attributes {(attribute.name): attribute}}
checks: {
	names: true & list.UniqueItems([for attribute in attributes {attribute.name}])
	pythonNames: true & list.UniqueItems([for attribute in attributes {attribute.python.name}])
	tsSections: true & list.UniqueItems([for attribute in attributes {attribute.tsSection}])
	jsSections: true & list.UniqueItems([for attribute in attributes {attribute.jsSection}])
	routes: true & list.UniqueItems([for attribute in attributes {attribute.route.path}])
}
