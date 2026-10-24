package plotattributes

import (
	"list"
	"idl.uw.edu/mosaic/api/model"
	attributeModel "idl.uw.edu/mosaic/api/attributes"
)

attributes: [...attributeModel.#Attribute] & [
	{
		name:        "name"
		type:        "stringValue"
		description: "A unique name for the plot. The name is used by standalone legend\ncomponents to to lookup the plot and access scale mappings."
		tsSection:   "name-5"
		jsSection:   "name-2"
		jsKind:      "name"
		python: {name: "name", default: "required", kind: "value"}
		route: kind: "wrapper-only"
	},
	{
		name:        "width"
		type:        "numberReference"
		description: "The outer width of the plot in pixels, including margins. Defaults to 640.\nOn Observable, this can be set to the built-in [width][1] for full-width\nresponsive plots. Note: the default style has a max-width of 100%; the plot\nwill automatically shrink to fit even when a fixed width is specified.\n\n[1]: https://github.com/observablehq/stdlib/blob/main/README.md#width"
		tsSection:   "width-6"
		jsSection:   "width-11"
		jsKind:      "simple"
		python: {name: "width", default: "required", kind: "value"}
		route: {kind: "mapped", path: "width", order: 1}
	},
	{
		name:        "height"
		type:        "numberReference"
		description: "The outer height of the plot in pixels, including margins. The default\ndepends on the plot’s scales, and the plot’s width if an aspectRatio is\nspecified. For example, if the *y* scale is linear and there is no *fy*\nscale, it might be 396."
		tsSection:   "height-7"
		jsSection:   "height-12"
		jsKind:      "simple"
		python: {name: "height", default: "required", kind: "value"}
		route: {kind: "mapped", path: "height", order: 2}
	},
	{
		name:        "aspectRatio"
		type:        "aspectValue"
		description: "The desired aspect ratio of the *x* and *y* scales, affecting the default\nheight. Given an aspect ratio of *dx* / *dy*, and assuming that the *x* and\n*y* scales represent equivalent units (say, degrees Celsius or meters),\ncomputes a default height such that *dx* pixels along *x* represents the\nsame variation as *dy* pixels along *y*. Note: when faceting, set the *fx*\nand *fy* scales’ **round** option to false for an exact aspect ratio."
		tsSection:   "aspectRatio-8"
		jsSection:   "aspectRatio-18"
		jsKind:      "simple"
		python: {name: "aspect_ratio", default: "true", kind: "value"}
		route: {kind: "mapped", path: "aspectRatio", order: 9}
	},
	{
		name:        "margin"
		type:        "numberReference"
		description: "Shorthand to set the same default for all four margins: **marginTop**,\n**marginRight**, **marginBottom**, and **marginLeft**. Otherwise, the\ndefault margins depend on the maximum margins of the plot’s marks. While\nmost marks default to zero margins (because they are drawn inside the chart\narea), Plot’s axis marks have non-zero default margins."
		tsSection:   "margin-9"
		jsSection:   "margin-7"
		jsKind:      "margin"
		python: {name: "margin", default: "required", kind: "value"}
		route: {kind: "mapped", path: "margin", order: 3}
	},
	{
		name:        "marginTop"
		type:        "numberReference"
		description: "The top margin; the distance in pixels between the top edges of the inner\nand outer plot area. Defaults to the maximum top margin of the plot’s\nmarks."
		tsSection:   "marginTop-10"
		jsSection:   "marginTop-15"
		jsKind:      "simple"
		python: {name: "margin_top", default: "required", kind: "value"}
		route: {kind: "mapped", path: "marginTop", order: 6}
		side: {name: "top", jsOrder: 0, pythonOrder: 0}
	},
	{
		name:        "marginRight"
		type:        "numberReference"
		description: "The right margin; the distance in pixels between the right edges of the\ninner and outer plot area. Defaults to the maximum right margin of the\nplot’s marks."
		tsSection:   "marginRight-11"
		jsSection:   "marginRight-14"
		jsKind:      "simple"
		python: {name: "margin_right", default: "required", kind: "value"}
		route: {kind: "mapped", path: "marginRight", order: 5}
		side: {name: "right", jsOrder: 3, pythonOrder: 1}
	},
	{
		name:        "marginBottom"
		type:        "numberReference"
		description: "The bottom margin; the distance in pixels between the bottom edges of the\ninner and outer plot area. Defaults to the maximum bottom margin of the\nplot’s marks."
		tsSection:   "marginBottom-12"
		jsSection:   "marginBottom-16"
		jsKind:      "simple"
		python: {name: "margin_bottom", default: "required", kind: "value"}
		route: {kind: "mapped", path: "marginBottom", order: 7}
		side: {name: "bottom", jsOrder: 1, pythonOrder: 2}
	},
	{
		name:        "marginLeft"
		type:        "numberReference"
		description: "The left margin; the distance in pixels between the left edges of the inner\nand outer plot area. Defaults to the maximum left margin of the plot’s\nmarks."
		tsSection:   "marginLeft-13"
		jsSection:   "marginLeft-13"
		jsKind:      "simple"
		python: {name: "margin_left", default: "required", kind: "value"}
		route: {kind: "mapped", path: "marginLeft", order: 4}
		side: {name: "left", jsOrder: 2, pythonOrder: 3}
	},
	{
		name:        "margins"
		type:        "marginOptions"
		description: "A shorthand object notation for setting multiple margin values.\nThe object keys are margin names (top, right, etc)."
		tsSection:   "margins-14"
		jsSection:   "margins-6"
		jsKind:      "margins"
		python: {name: "margins", default: "required", kind: "margins"}
		route: kind: "wrapper-only"
	},
	{
		name:        "inset"
		type:        "numberReference"
		description: "Shorthand to set the same default for all four insets: **insetTop**,\n**insetRight**, **insetBottom**, and **insetLeft**. All insets typically\ndefault to zero, though not always (say when using bin transform). A\npositive inset reduces effective area, while a negative inset increases it."
		tsSection:   "inset-15"
		jsSection:   "inset-20"
		jsKind:      "simple"
		python: {name: "inset", default: "required", kind: "value"}
		route: {kind: "mapped", path: "inset", order: 11}
	},
	{
		name:        "style"
		type:        "styleValue"
		description: "Custom styles to override Plot’s defaults. Styles may be specified either\nas a string of inline styles (*e.g.*, `\"color: red;\"`, in the same fashion\nas assigning [*element*.style][1]) or an object of properties (*e.g.*,\n`{color: \"red\"}`, in the same fashion as assigning [*element*.style\nproperties][2]). Note that unitless numbers ([quirky lengths][3]) such as\n`{padding: 20}` may not supported by some browsers; you should instead\nspecify a string with units such as `{padding: \"20px\"}`. By default, the\nreturned plot has a max-width of 100%, and the system-ui font. Plot’s marks\nand axes default to [currentColor][4], meaning that they will inherit the\nsurrounding content’s color.\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/style\n[2]: https://developer.mozilla.org/en-US/docs/Web/API/CSSStyleDeclaration\n[3]: https://www.w3.org/TR/css-values-4/#deprecated-quirky-length\n[4]: https://developer.mozilla.org/en-US/docs/Web/CSS/color_value#currentcolor_keyword"
		tsSection:   "style-16"
		jsSection:   "style-10"
		jsKind:      "simple"
		python: {name: "style", default: "required", kind: "value"}
		route: {kind: "mapped", path: "style", order: 0}
	},
	{
		name:        "align"
		type:        "numberReference"
		description: "How to distribute unused space in the **range** for *point* and *band*\nscales. A number in [0, 1], such as:\n\n- 0 - use the start of the range, putting unused space at the end\n- 0.5 (default) - use the middle, distributing unused space evenly\n- 1 use the end, putting unused space at the start\n\nFor ordinal position scales only."
		tsSection:   "align-17"
		jsSection:   "align-17"
		jsKind:      "simple"
		python: {name: "align", default: "required", kind: "value"}
		route: {kind: "mapped", path: "align", order: 8}
	},
	{
		name:        "padding"
		type:        "numberReference"
		description: "For *band* scales, how much of the **range** to reserve to separate\nadjacent bands; defaults to 0.1 (10%). For *point* scales, the amount of\ninset for the first and last value as a proportion of the bandwidth;\ndefaults to 0.5 (50%).\n\nFor ordinal position scales only."
		tsSection:   "padding-18"
		jsSection:   "padding-23"
		jsKind:      "simple"
		python: {name: "padding", default: "required", kind: "value"}
		route: {kind: "mapped", path: "padding", order: 14}
	},
	{
		name:        "axis"
		type:        "axisValue"
		description: "The side of the frame on which to place the implicit axis: *top* or\n*bottom* for *x* or *fx*, or *left* or *right* for *y* or *fy*. The default\ndepends on the scale:\n\n- *x* - *bottom*\n- *y* - *left*\n- *fx* - *top* if there is a *bottom* *x* axis, and otherwise *bottom*\n- *fy* - *right* if there is a *left* *y* axis, and otherwise *right*\n\nIf *both*, an implicit axis will be rendered on both sides of the plot\n(*top* and *bottom* for *x* or *fx*, or *left* and *right* for *y* or\n*fy*). If null, the implicit axis is suppressed.\n\nFor position axes only."
		tsSection:   "axis-19"
		jsSection:   "axis-19"
		jsKind:      "simple"
		python: {name: "axis", default: "true", kind: "value"}
		route: {kind: "mapped", path: "axis", order: 10}
	},
	{
		name:        "grid"
		type:        "gridValue"
		description: "Whether to show a grid aligned with the scale’s ticks. If true, show a grid\nwith the currentColor stroke; if a string, show a grid with the specified\nstroke color; if an approximate number of ticks, an interval, or an array\nof tick values, show corresponding grid lines. See also the grid mark.\n\nFor axes only."
		tsSection:   "grid-20"
		jsSection:   "grid-21"
		jsKind:      "simple"
		python: {name: "grid", default: "true", kind: "value"}
		route: {kind: "mapped", path: "grid", order: 12}
	},
	{
		name:        "ariaLabel"
		type:        "nullableString"
		description: "The [aria-label attribute][1] on the SVG root.\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Attributes/aria-label"
		tsSection:   "ariaLabel-21"
		jsSection:   "ariaLabel-24"
		jsKind:      "simple"
		python: {name: "aria_label", default: "required", kind: "value"}
		route: kind: "absent"
	},
	{
		name:        "ariaDescription"
		type:        "nullableString"
		description: "The [aria-description attribute][1] on the SVG root.\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Attributes/aria-description"
		tsSection:   "ariaDescription-22"
		jsSection:   "ariaDescription-25"
		jsKind:      "simple"
		python: {name: "aria_description", default: "required", kind: "value"}
		route: kind: "absent"
	},
	{
		name:        "clip"
		type:        "clipValue"
		description: "The default clip for all marks."
		tsSection:   "clip-23"
		jsSection:   "clip-22"
		jsKind:      "simple"
		python: {name: "clip", default: "true", kind: "value"}
		route: kind: "absent"
	},
]

attributeIndex: {for attribute in attributes {(attribute.name): attribute}}
sideAttributes: [for attribute in attributes if attribute.side != _|_ {attribute}]
jsSides: [for position in list.Range(0, len(sideAttributes), 1) for attribute in sideAttributes if attribute.side.jsOrder == position {attribute}]
pythonSides: [for position in list.Range(0, len(sideAttributes), 1) for attribute in sideAttributes if attribute.side.pythonOrder == position {attribute}]
routeRecords: [...{key!: model.#Name, path!: string & !=""}] & [for position in list.Range(0, len([for attribute in attributes if attribute.route.kind == "mapped" {attribute}])+1, 1) {
	for attribute in attributes if attribute.route.kind == "mapped" if attribute.route.order == position {{key: attribute.name, path: attribute.route.path}}
	if position == labelRoute.order {{key: labelRoute.name, path: labelRoute.path}}
}]
labelRoute: {name: "label", path: "label", order: 13, scope: "runtime-only", description: "Set a global axis-label setting through the retained Plot.setAttribute runtime API; no public label directive is exported."}
pythonSymbols: [for attribute in attributes if attribute.python.kind == "value" {{key: attribute.name, name: attribute.python.name, module: "plot_attributes"}}]
checks: {
	names: true & list.UniqueItems([for attribute in attributes {attribute.name}])
	pythonNames: true & list.UniqueItems([for attribute in attributes {attribute.python.name}])
	sectionIds: true & list.UniqueItems([for attribute in attributes {attribute.tsSection}])
	routes: true & list.UniqueItems([for route in routeRecords {route.key}])
	routeOrders: true & list.UniqueItems(list.Concat([[for attribute in attributes if attribute.route.kind == "mapped" {attribute.route.order}], [labelRoute.order]]))
	for attribute in attributes if attribute.route.kind == "mapped" {"route_\(attribute.name)": int & <len(routeRecords) & attribute.route.order}
	sides: true & list.UniqueItems([for attribute in sideAttributes {attribute.side.name}])
}
