package commonmodel

import (
	"list"
	"idl.uw.edu/mosaic/api/model"
	valueFamily "idl.uw.edu/mosaic/api/values"
)

contracts: [...model.#ShapeContract] & [
	{
		name:        "ChannelName"
		description: "The set of known channel names."
		kind:        "alias"
		expression:  "channelNameType"
	},
	{
		name:                 "ChannelScale"
		description:          "The ChannelScale contract."
		wire:                 false
		exported:             false
		documentationAdapter: "reference-only"
		kind:                 "alias"
		expression:           "channelScaleType"
	},
	{
		name:        "ChannelValue"
		description: "A channel\u2019s values may be expressed as:\n\n- a field name, to extract the corresponding value for each datum\n- an iterable of values, typically of the same length as the data\n- a channel transform or SQL expression\n- a constant number or boolean\n- null to represent no value"
		kind:        "alias"
		expression:  "channelValueType"
	},
	{
		name:        "ChannelValueSpec"
		description: "When specifying a mark channel\u2019s value, you can provide a {value, scale} object to override the scale that would normally be associated with the channel."
		kind:        "alias"
		expression:  "channelValueSpecType"
	},
	{
		name:        "ChannelValueIntervalSpec"
		description: "In some contexts, when specifying a mark channel\u2019s value, you can provide a {value, interval} object to specify an associated interval."
		kind:        "alias"
		expression:  "channelValueIntervalSpecType"
	},
	{
		name:        "ChannelDomainName"
		description: "A channel name, or an implied one for domain sorting."
		wire:        false
		exported:    false
		kind:        "alias"
		expression:  "channelDomainNameType"
	},
	{
		name:        "ChannelDomainValue"
		description: "The available inputs for imputing scale domains. In addition to a named channel, an input may be specified as:\n\n- *data* - impute from mark data\n- *width* - impute from |*x2* - *x1*|\n- *height* - impute from |*y2* - *y1*|\n- null - impute from input order\n\nIf the *x* channel is not defined, the *x2* channel will be used instead if available, and similarly for *y* and *y2*; this is useful for marks that implicitly stack. The *data* input is typically used in conjunction with a custom **reduce** function, as when the built-in single-channel reducers are insufficient."
		kind:        "alias"
		expression:  "channelDomainValueType"
	},
	{
		name:        "ChannelDomainOptions"
		description: "Options for imputing scale domains from channel values."
		wire:        false
		properties: [
			{
				name:        "reduce"
				description: "How to produce a singular value (for subsequent sorting) from aggregated channel values; one of:\n\n- true (default) - alias for *max*\n- false or null - disabled; don\u2019t impute the scale domain\n- a named reducer implementation such as *count* or *sum*\n- a function that takes an array of values and returns the reduced value\n- an object that implements the *reduceIndex* method"
				type:        "channelDomainOptionsReduce"
			},
			{name: "order", description: "How to order reduced values.", type: "channelDomainOptionsOrder"},
			{name: "reverse", description: "If true, reverse the order after sorting.", type: "boolean"},
			{
				name:        "limit"
				description: "If a positive number, limit the domain to the first *n* sorted values. If a negative number, limit the domain to the last *-n* sorted values. Hence, a positive **limit** with **reverse** true will return the top *n* values in descending order.\n\nIf an array [*lo*, *hi*], slices the sorted domain from *lo* (inclusive) to\n*hi* (exclusive). As with [*array*.slice][1], if either *lo* or *hi* are negative, it indicates an offset from the end of the array; if *lo* is undefined it defaults to 0, and if *hi* is undefined it defaults to Infinity.\n\nNote: limiting the imputed domain of one scale, say *x*, does not affect the imputed domain of another scale, say *y*; each scale domain is imputed independently.\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/slice"
				type:        "channelDomainOptionsLimit"
			},
		]
	},
	{
		name:        "ChannelDomainValueSpec"
		description: "How to derive a scale\u2019s domain from a channel\u2019s values."
		kind:        "alias"
		expression:  "channelDomainValueSpecType"
	},
	{
		name:        "ChannelDomainSort"
		description: "How to impute scale domains from channel values."
		kind:        "alias"
		expression:  "channelDomainSortType"
	},
	{
		name:        "ChannelReducers"
		description: "Output channels for aggregating transforms, such as bin and group. Each\ndeclared output channel has an associated reducer, and typically a\ncorresponding input channel in *options*. Non-grouping channels declared in\n*options* but not *outputs* are computed on reduced data after grouping,\nwhich defaults to the array of data for the current group.\n\nIf **title** is in *options* but not *outputs*, the reducer defaults to\nsummarizing the most common values. If **href** is in *options* but not\n*outputs*, the reducer defaults to *first*. When **x1** or **x2** is in\n*outputs*, reads the input channel **x** if **x1** or **x2** is not in\n*options*; likewise for **y1** or **y2**, reads the input channel **y** if\n**y1** or **y2** is not in *options*."
		wire:        false
		parameters: [{name: "T", default: "reducerReference"}]
		kind:       "alias"
		expression: "channelReducersType"
	},
	{
		name:        "ChannelStates"
		description: "Abstract (unscaled) values, and associated scale, per channel."
		wire:        false
		kind:        "alias"
		expression:  "channelStatesType"
	},
	{
		name:        "ChannelValues"
		description: "Possibly-scaled values for each channel."
		wire:        false
		kind:        "alias"
		expression:  "channelValuesType"
	},
	{
		name:        "SortOrder"
		description: "How to order values; one of:\n\n- a function for comparing data, returning a signed number\n- a channel value definition for sorting given values in ascending order\n- a {value, order} object for sorting given values\n- a {channel, order} object for sorting the named channel\u2019s values"
		kind:        "alias"
		expression:  "sortOrderType"
	},
	{
		name:        "TipPointer"
		description: "The pointer mode for the tip; corresponds to pointerX, pointerY, and pointer."
		kind:        "alias"
		expression:  "tipPointerType"
	},
	{
		name:        "SelectFilter"
		description: "Selection filters to apply internally to mark data."
		kind:        "alias"
		expression:  "selectFilterType"
	},
	{
		name:                 "MarkData"
		description:          "The MarkData contract."
		wire:                 false
		documentationAdapter: "reference-only"
		properties: [{name: "data", description: "The data source for the mark.", required: true, type: "plotMarkDataReference"}]
	},
	{
		name:                 "MarkDataOptional"
		description:          "The MarkDataOptional contract."
		wire:                 false
		documentationAdapter: "reference-only"
		properties: [{name: "data", description: "The data source for the mark.", type: "plotMarkDataReference"}]
	},
	{
		name:        "MarkOptions"
		description: "Shared options for all marks."
		wire:        false
		properties: [
			{
				name:        "filter"
				description: "Applies a transform to filter the mark\u2019s index according to the given channel values; only truthy values are retained.\n\nNote that filtering only affects the rendered mark index, not the associated channel values, and has no effect on imputed scale domains."
				type:        "channelValueReference"
			},
			{
				name:        "select"
				description: "Applies a filter transform after data is loaded to highlight selected values only. For example, `first` and `last` select the first or last values of series only (using the *z* channel to separate series). Meanwhile, `nearestX` and `nearestY` select the point nearest to the pointer along the *x* or *y* channel dimension. Unlike Mosaic selections, a mark level *select* is internal to the mark only, and does not populate a param or selection value to be shared across clients.\n\nNote that filtering only affects the rendered mark index, not the associated channel values, and has no effect on imputed scale domains."
				type:        "selectFilterReference"
			},
			{
				name:        "reverse"
				description: "Applies a transform to reverse the order of the mark\u2019s index, say for reverse input order."
				type:        "booleanOrParamRef"
			},
			{
				name:        "sort"
				description: "Either applies a transform to sort the mark\u2019s index by the specified channel values, or imputes ordinal scale domains from this mark\u2019s channels.\n\nWhen imputing ordinal scale domains from channel values, the **sort** option is an object whose keys are ordinal scale names such as *x* or *fx*, and whose values are channel names such as *y*, *y1*, or *y2*. For example, to impute the *y* scale\u2019s domain from the associated *x* channel values in ascending order:\n\n```js sort: {y: \"x\"} ```\n\nFor different sort options for different scales, replace the channel name with a *value* object and per-scale options:\n\n```js sort: {y: {value: \"-x\"}} ```\n\nWhen sorting the mark\u2019s index, the **sort** option is instead one of:\n\n- a channel value definition for sorting given values in ascending order\n- a {value, order} object for sorting given values\n- a {channel, order} object for sorting the named channel\u2019s values"
				type:        "markOptionsSort"
			},
			{
				name:        "fx"
				description: "The horizontal facet position channel, for mark-level faceting, bound to the *fx* scale."
				type:        "channelValueReference"
			},
			{
				name:        "fy"
				description: "The vertical facet position channel, for mark-level faceting, bound to the\n*fy* scale."
				type:        "channelValueReference"
			},
			{
				name:        "facet"
				description: "Whether to enable or disable faceting; one of:\n\n- *auto* (default) - automatically determine if this mark should be faceted\n- *include* (or true) - draw the subset of the mark\u2019s data in the current facet\n- *exclude* - draw the subset of the mark\u2019s data *not* in the current facet\n- *super* - draw this mark in a single frame that covers all facets\n- null (or false) - repeat this mark\u2019s data across all facets (*i.e.*, no faceting)\n\nWhen a mark uses *super* faceting, it is not allowed to use position scales (*x*, *y*, *fx*, or *fy*); *super* faceting is intended for decorations, such as labels and legends.\n\nWhen top-level faceting is used, the default *auto* setting is equivalent to *include* when the mark data is strictly equal to the top-level facet data; otherwise it is equivalent to null. When the *include* or *exclude* facet mode is chosen, the mark data must be parallel to the top-level facet data: the data must have the same length and order. If the data are not parallel, then the wrong data may be shown in each facet. The default\n*auto* therefore requires strict equality (`===`) for safety, and using the facet data as mark data is recommended when using the *exclude* facet mode. (To construct parallel data safely, consider using [*array*.map][1] on the facet data.)\n\nWhen mark-level faceting is used, the default *auto* setting is equivalent to *include*: the mark will be faceted if either the **fx** or **fy** channel option (or both) is specified. The null or false option will disable faceting, while *exclude* draws the subset of the mark\u2019s data *not* in the current facet.\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/map"
				type:        "markOptionsFacet"
			},
			{
				name:        "facetAnchor"
				description: "How to place the mark with respect to facets; one of:\n\n- null (default for most marks) - display the mark in each non-empty facet\n- *top*, *right*, *bottom*, or *left* - display the mark only in facets on   the given side\n- *top-empty*, *right-empty*, *bottom-empty*, or *left-empty* (default for   axis marks) - display the mark only in facets that have empty space on   the given side: either the margin, or an empty facet\n- *empty* - display the mark in empty facets only"
				type:        "markOptionsFacetAnchor"
			},
			{
				name:        "margin"
				description: "Shorthand to set the same default for all four mark margins: **marginTop**,\n**marginRight**, **marginBottom**, and **marginLeft**; typically defaults to 0, except for axis marks."
				type:        "numberOrParamRef"
			},
			{
				name:        "marginTop"
				description: "The mark\u2019s top margin; the minimum distance in pixels between the top edges of the inner and outer plot area."
				type:        "numberOrParamRef"
			},
			{
				name:        "marginRight"
				description: "The mark\u2019s right margin; the minimum distance in pixels between the right edges of the mark\u2019s inner and outer plot area."
				type:        "numberOrParamRef"
			},
			{
				name:        "marginBottom"
				description: "The mark\u2019s bottom margin; the minimum distance in pixels between the bottom edges of the inner and outer plot area."
				type:        "numberOrParamRef"
			},
			{
				name:        "marginLeft"
				description: "The mark\u2019s left margin; the minimum distance in pixels between the left edges of the inner and outer plot area."
				type:        "numberOrParamRef"
			},
			{
				name:        "ariaDescription"
				description: "The [aria-description][1]; a constant textual description.\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Attributes/aria-description"
				type:        "markOptionsAriaDescription"
			},
			{
				name:        "ariaHidden"
				description: "The [aria-hidden][1] state; a constant indicating whether the element is exposed to an accessibility API.\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Attributes/aria-hidden"
				type:        "markOptionsAriaDescription"
			},
			{
				name:        "ariaLabel"
				description: "The [aria-label][1]; a channel specifying short textual labels representing the value in the accessibility tree.\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Attributes/aria-label"
				type:        "channelValueReference"
			},
			{
				name:        "pointerEvents"
				description: "The [pointer-events][1] property; a constant string such as *none*.\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/CSS/pointer-events"
				type:        "markOptionsAriaDescription"
			},
			{
				name:        "title"
				description: "The title; a channel specifying accessible, short textual descriptions as strings (possibly with newlines). If the tip option is specified, the title will be displayed with an interactive tooltip instead of using the SVG [title element][1].\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/SVG/Element/title"
				type:        "channelValueReference"
			},
			{name: "tip", description: "Whether to generate a tooltip for this mark, and any tip options.", type: "markOptionsTip"},
			{
				name:        "channels"
				description: "Additional named channels, for example to include in a tooltip. Consists of (channel name, data field name) key-value pairs."
				type:        "markOptionsChannels"
			},
			{
				name:        "clip"
				description: "How to clip the mark; one of:\n\n- *frame* or true - clip to the plot\u2019s frame (inner area)\n- *sphere* - clip to the projected sphere (*e.g.*, front hemisphere)\n- null or false - do not clip\n\nThe *sphere* clip option requires a geographic projection."
				type:        "markOptionsClip"
			},
			{
				name:        "dx"
				description: "The horizontal offset in pixels; a constant option. On low-density screens, an additional 0.5px offset may be applied for crisp edges."
				type:        "numberOrParamRef"
			},
			{
				name:        "dy"
				description: "The vertical offset in pixels; a constant option. On low-density screens, an additional 0.5px offset may be applied for crisp edges."
				type:        "numberOrParamRef"
			},
			{
				name:        "fill"
				description: "The [fill][1]; a constant CSS color string, or a channel typically bound to the *color* scale. If all channel values are valid CSS colors, by default the channel will not be bound to the *color* scale, interpreting the colors literally.\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/fill"
				type:        "markOptionsFill"
			},
			{
				name:        "fillOpacity"
				description: "The [fill-opacity][1]; a constant number between 0 and 1, or a channel typically bound to the *opacity* scale. If all channel values are numbers in [0, 1], by default the channel will not be bound to the *opacity* scale, interpreting the opacities literally.\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/fill-opacity"
				type:        "markOptionsFill"
			},
			{
				name:        "stroke"
				description: "The [stroke][1]; a constant CSS color string, or a channel typically bound to the *color* scale. If all channel values are valid CSS colors, by default the channel will not be bound to the *color* scale, interpreting the colors literally.\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/stroke"
				type:        "markOptionsFill"
			},
			{
				name:        "strokeDasharray"
				description: "The [stroke-dasharray][1]; a constant number indicating the length in pixels of alternating dashes and gaps, or a constant string of numbers separated by spaces or commas (_e.g._, *10 2* for dashes of 10 pixels separated by gaps of 2 pixels), or *none* (the default) for no dashing\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/stroke-dasharray"
				type:        "markOptionsStrokeDasharray"
			},
			{
				name:        "strokeDashoffset"
				description: "The [stroke-dashoffset][1]; a constant indicating the offset in pixels of the first dash along the stroke; defaults to zero.\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/stroke-dashoffset"
				type:        "markOptionsStrokeDasharray"
			},
			{
				name:        "strokeLinecap"
				description: "The [stroke-linecap][1]; a constant specifying how to cap stroked paths, such as *butt*, *round*, or *square*.\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/stroke-linecap"
				type:        "markOptionsAriaDescription"
			},
			{
				name:        "strokeLinejoin"
				description: "The [stroke-linejoin][1]; a constant specifying how to join stroked paths, such as *bevel*, *miter*, *miter-clip*, or *round*.\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/stroke-linejoin"
				type:        "markOptionsAriaDescription"
			},
			{
				name:        "strokeMiterlimit"
				description: "The [stroke-miterlimit][1]; a constant number specifying how to limit the length of *miter* joins on stroked paths.\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/stroke-miterlimit"
				type:        "numberOrParamRef"
			},
			{
				name:        "strokeOpacity"
				description: "The [stroke-opacity][1]; a constant between 0 and 1, or a channel typically bound to the *opacity* scale. If all channel values are numbers in [0, 1], by default the channel will not be bound to the *opacity* scale, interpreting the opacities literally.\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/stroke-opacity"
				type:        "channelValueSpecReference"
			},
			{
				name:        "strokeWidth"
				description: "The [stroke-width][1]; a constant number in pixels, or a channel.\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/stroke-width"
				type:        "channelValueSpecReference"
			},
			{
				name:        "opacity"
				description: "The [opacity][1]; a constant between 0 and 1, or a channel typically bound to the *opacity* scale. If all channel values are numbers in [0, 1], by default the channel will not be bound to the *opacity* scale, interpreting the opacities literally. For faster rendering, prefer the **strokeOpacity** or **fillOpacity** option.\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/opacity"
				type:        "channelValueSpecReference"
			},
			{
				name:        "mixBlendMode"
				description: "The [mix-blend-mode][1]; a constant string specifying how to blend content such as *multiply*.\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/CSS/mix-blend-mode"
				type:        "markOptionsAriaDescription"
			},
			{
				name:        "imageFilter"
				description: "A CSS [filter][1]; a constant string used to adjust the rendering of images, such as *blur(5px)*.\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/CSS/filter"
				type:        "markOptionsAriaDescription"
			},
			{
				name:        "paintOrder"
				description: "The [paint-order][1]; a constant string specifying the order in which the\n**fill**, **stroke**, and any markers are drawn; defaults to *normal*, which draws the fill, then stroke, then markers; defaults to *stroke* for the text mark to create a \u201chalo\u201d around text to improve legibility.\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/CSS/paint-order"
				type:        "markOptionsAriaDescription"
			},
			{
				name:        "shapeRendering"
				description: "The [shape-rendering][1]; a constant string such as *crispEdges*.\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/shape-rendering"
				type:        "markOptionsAriaDescription"
			},
			{
				name:        "href"
				description: "The [href][1]; a channel specifying URLs for clickable links. May be used in conjunction with the **target** option to open links in another window.\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/href"
				type:        "channelValueReference"
			},
			{
				name:        "target"
				description: "The [target][1]; a constant string specifying the target window (_e.g._,\n*_blank*) for clickable links; used in conjunction with the **href** option.\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/target"
				type:        "markOptionsAriaDescription"
			},
		]
	},
	{
		name:        "InsetOptions"
		description: "Options for insetting rectangular shapes."
		wire:        false
		properties: [
			{
				name:        "inset"
				description: "Shorthand to set the same default for all four insets: **insetTop**,\n**insetRight**, **insetBottom**, and **insetLeft**. All insets typically default to zero, though not always (say when using bin transform). A positive inset reduces effective area, while a negative inset increases it."
				type:        "numberOrParamRef"
			},
			{
				name:        "insetTop"
				description: "Insets the top edge by the specified number of pixels. A positive value insets towards the bottom edge (reducing effective area), while a negative value insets away from the bottom edge (increasing it)."
				type:        "numberOrParamRef"
			},
			{
				name:        "insetRight"
				description: "Insets the right edge by the specified number of pixels. A positive value insets towards the left edge (reducing effective area), while a negative value insets away from the left edge (increasing it)."
				type:        "numberOrParamRef"
			},
			{
				name:        "insetBottom"
				description: "Insets the bottom edge by the specified number of pixels. A positive value insets towards the top edge (reducing effective area), while a negative value insets away from the top edge (increasing it)."
				type:        "numberOrParamRef"
			},
			{
				name:        "insetLeft"
				description: "Insets the left edge by the specified number of pixels. A positive value insets towards the right edge (reducing effective area), while a negative value insets away from the right edge (increasing it)."
				type:        "numberOrParamRef"
			},
		]
	},
	{
		name:        "TextStyles"
		description: "Options for styling text (independent of anchor position)."
		wire:        false
		properties: [
			{
				name:        "textAnchor"
				description: "The [text anchor][1] controls how text is aligned (typically horizontally) relative to its anchor point; it is one of *start*, *end*, or *middle*. If the frame anchor is *left*, *top-left*, or *bottom-left*, the default text anchor is *start*; if the frame anchor is *right*, *top-right*, or\n*bottom-right*, the default is *end*; otherwise it is *middle*.\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/text-anchor"
				type:        "textStylesTextAnchor"
			},
			{
				name:        "lineHeight"
				description: "The line height in ems; defaults to 1. The line height affects the (typically vertical) separation between adjacent baselines of text, as well as the separation between the text and its anchor point."
				type:        "numberOrParamRef"
			},
			{
				name:        "lineWidth"
				description: "The line width in ems (e.g., 10 for about 20 characters); defaults to infinity, disabling wrapping and clipping.\n\nIf **textOverflow** is null, lines will be wrapped at the specified length. If a line is split at a soft hyphen (\\xad), a hyphen (-) will be displayed at the end of the line. If **textOverflow** is not null, lines will be clipped according to the given strategy."
				type:        "numberOrParamRef"
			},
			{
				name:        "textOverflow"
				description: "How truncate (or wrap) lines of text longer than the given **lineWidth**; one of:\n\n- null (default) - preserve overflowing characters (and wrap if needed)\n- *clip* or *clip-end* - remove characters from the end\n- *clip-start* - remove characters from the start\n- *ellipsis* or *ellipsis-end* - replace characters from the end with an ellipsis (\u2026)\n- *ellipsis-start* - replace characters from the start with an ellipsis (\u2026)\n- *ellipsis-middle* - replace characters from the middle with an ellipsis (\u2026)\n\nIf no **title** was specified, if text requires truncation, a title containing the non-truncated text will be implicitly added."
				type:        "textStylesTextOverflow"
			},
			{
				name:        "monospace"
				description: "If true, changes the default **fontFamily** to *monospace*, and uses simplified monospaced text metrics calculations."
				type:        "booleanOrParamRef"
			},
			{
				name:        "fontFamily"
				description: "The [font-family][1]; a constant; defaults to the plot\u2019s font family, which is typically [*system-ui*][2].\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/CSS/font-family [2]: https://drafts.csswg.org/css-fonts-4/#valdef-font-family-system-ui"
				type:        "markOptionsAriaDescription"
			},
			{
				name:        "fontSize"
				description: "The [font size][1] in pixels; either a constant or a channel; defaults to the plot\u2019s font size, which is typically 10. When a number, it is interpreted as a constant; otherwise it is interpreted as a channel.\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/CSS/font-size"
				type:        "textStylesFontSize"
			},
			{
				name:        "fontStyle"
				description: "The [font style][1]; a constant; defaults to the plot\u2019s font style, which is typically *normal*.\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/CSS/font-style"
				type:        "markOptionsAriaDescription"
			},
			{
				name:        "fontVariant"
				description: "The [font variant][1]; a constant; if the **text** channel contains numbers or dates, defaults to *tabular-nums* to facilitate comparing numbers; otherwise defaults to the plot\u2019s font style, which is typically *normal*.\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/CSS/font-variant"
				type:        "markOptionsAriaDescription"
			},
			{
				name:        "fontWeight"
				description: "The [font weight][1]; a constant; defaults to the plot\u2019s font weight, which is typically *normal*.\n\n[1]: https://developer.mozilla.org/en-US/docs/Web/CSS/font-weight"
				type:        "markOptionsStrokeDasharray"
			},
		]
	},
	{
		name:        "TipOptions"
		description: "Options for the tip mark."
		wire:        false
		extends: ["MarkOptions", "TextStyles"]
		properties: [
			{
				name:        "x"
				description: "The horizontal position channel specifying the tip\u2019s anchor, typically bound to the *x* scale."
				type:        "channelValueSpecReference"
			},
			{
				name:        "x1"
				description: "The starting horizontal position channel specifying the tip\u2019s anchor, typically bound to the *x* scale."
				type:        "channelValueSpecReference"
			},
			{
				name:        "x2"
				description: "The ending horizontal position channel specifying the tip\u2019s anchor, typically bound to the *x* scale."
				type:        "channelValueSpecReference"
			},
			{
				name:        "y"
				description: "The vertical position channel specifying the tip\u2019s anchor, typically bound to the *y* scale."
				type:        "channelValueSpecReference"
			},
			{
				name:        "y1"
				description: "The starting vertical position channel specifying the tip\u2019s anchor, typically bound to the *y* scale."
				type:        "channelValueSpecReference"
			},
			{
				name:        "y2"
				description: "The ending vertical position channel specifying the tip\u2019s anchor, typically bound to the *y* scale."
				type:        "channelValueSpecReference"
			},
			{
				name:        "frameAnchor"
				description: "The frame anchor specifies defaults for **x** and **y** based on the plot\u2019s frame; it may be one of the four sides (*top*, *right*, *bottom*, *left*), one of the four corners (*top-left*, *top-right*, *bottom-right*,\n*bottom-left*), or the *middle* of the frame. For example, for tips distributed horizontally at the top of the frame:\n\n```js Plot.tip(data, {x: \"date\", frameAnchor: \"top\"}) ```"
				type:        "frameAnchorOrParamRef"
			},
			{
				name:        "anchor"
				description: "The tip anchor specifies how to orient the tip box relative to its anchor position; it refers to the part of the tip box that is attached to the anchor point. For example, the *top-left* anchor places the top-left corner of tip box near the anchor position, hence placing the tip box below and to the right of the anchor position."
				type:        "frameAnchorOrParamRef"
			},
			{
				name:        "preferredAnchor"
				description: "If an explicit tip anchor is not specified, an anchor is chosen automatically such that the tip fits within the plot\u2019s frame; if the preferred anchor fits, it is chosen."
				type:        "tipOptionsPreferredAnchor"
			},
			{
				name:        "format"
				description: "How channel values are formatted for display. If a format is a string, it is interpreted as a (UTC) time format for temporal channels, and otherwise a number format."
				type:        "tipOptionsFormat"
			},
			{
				name:        "pathFilter"
				description: "The image filter for the tip\u2019s box; defaults to a drop shadow."
				type:        "markOptionsAriaDescription"
			},
			{
				name:        "pointerSize"
				description: "The size of the tip\u2019s pointer in pixels; defaults to 12."
				type:        "numberOrParamRef"
			},
			{name: "textPadding", description: "The padding around the text in pixels; defaults to 8.", type: "numberOrParamRef"},
		]
	},
	{
		name:        "Curve"
		description: "How to interpolate between control points."
		kind:        "alias"
		expression:  "curveNameReference"
	},
	{
		name:        "CurveOptions"
		description: "Options for marks that support curves, such as lines and areas."
		wire:        false
		extends: ["CurveAutoOptions"]
		properties: [
			{
				name:        "curve"
				description: "The curve (interpolation) method for connecting adjacent points. One of:\n\n- *basis* - a cubic basis spline (repeating the end points)\n- *basis-open* - an open cubic basis spline\n- *basis-closed* - a closed cubic basis spline\n- *bump-x* - a B\u00e9zier curve with horizontal tangents\n- *bump-y* - a B\u00e9zier curve with vertical tangents\n- *bundle* - a straightened cubic basis spline (suitable for lines only, not areas)\n- *cardinal* - a cubic cardinal spline (with one-sided differences at the ends)\n- *cardinal-open* - an open cubic cardinal spline\n- *cardinal-closed* - an closed cubic cardinal spline\n- *catmull-rom* - a cubic Catmull\u2013Rom spline (with one-sided differences at the ends)\n- *catmull-rom-open* - an open cubic Catmull\u2013Rom spline\n- *catmull-rom-closed* - a closed cubic Catmull\u2013Rom spline\n- *linear* - a piecewise linear curve (*i.e.*, straight line segments)\n- *linear-closed* - a closed piecewise linear curve (*i.e.*, straight line segments)\n- *monotone-x* - a cubic spline that preserves monotonicity in *x*\n- *monotone-y* - a cubic spline that preserves monotonicity in *y*\n- *natural* - a natural cubic spline\n- *step* - a piecewise constant function where *y* changes at the midpoint of *x*\n- *step-after* - a piecewise constant function where *y* changes after *x*\n- *step-before* - a piecewise constant function where *x* changes after *y*"
				type:        "curveOptionsCurve"
				override:    true
			}
		]
	},
	{
		name:        "CurveAutoOptions"
		description: "Options for marks that support possibly-projected curves."
		wire:        false
		properties: [
			{
				name:        "curve"
				description: "The curve (interpolation) method for connecting adjacent points. One of:\n\n- *basis* - a cubic basis spline (repeating the end points)\n- *basis-open* - an open cubic basis spline\n- *basis-closed* - a closed cubic basis spline\n- *bump-x* - a B\u00e9zier curve with horizontal tangents\n- *bump-y* - a B\u00e9zier curve with vertical tangents\n- *bundle* - a straightened cubic basis spline (suitable for lines only, not areas)\n- *cardinal* - a cubic cardinal spline (with one-sided differences at the ends)\n- *cardinal-open* - an open cubic cardinal spline\n- *cardinal-closed* - an closed cubic cardinal spline\n- *catmull-rom* - a cubic Catmull\u2013Rom spline (with one-sided differences at the ends)\n- *catmull-rom-open* - an open cubic Catmull\u2013Rom spline\n- *catmull-rom-closed* - a closed cubic Catmull\u2013Rom spline\n- *linear* - a piecewise linear curve (*i.e.*, straight line segments)\n- *linear-closed* - a closed piecewise linear curve (*i.e.*, straight line segments)\n- *monotone-x* - a cubic spline that preserves monotonicity in *x*\n- *monotone-y* - a cubic spline that preserves monotonicity in *y*\n- *natural* - a natural cubic spline\n- *step* - a piecewise constant function where *y* changes at the midpoint of *x*\n- *step-after* - a piecewise constant function where *y* changes after *x*\n- *step-before* - a piecewise constant function where *x* changes after *y*\n- *auto* (default) - like *linear*, but use the (possibly spherical) projection, if any\n\nThe *auto* curve is typically used in conjunction with a spherical projection to interpolate along geodesics."
				type:        "curveAutoOptionsCurve"
			},
			{
				name:        "tension"
				description: "The tension option only has an effect on bundle, cardinal and Catmull\u2013Rom splines (*bundle*, *cardinal*, *cardinal-open*, *cardinal-closed*,\n*catmull-rom*, *catmull-rom-open*, and *catmull-rom-closed*). For bundle splines, it corresponds to [beta][1]; for cardinal splines, [tension][2]; for Catmull\u2013Rom splines, [alpha][3].\n\n[1]: https://d3js.org/d3-shape/curve#curveBundle_beta [2]: https://d3js.org/d3-shape/curve#curveCardinal_tension [3]: https://d3js.org/d3-shape/curve#curveCatmullRom_alpha"
				type:        "numberOrParamRef"
			},
		]
	},
	{
		name:        "StackOffsetName"
		description: "A built-in stack offset method; one of:\n\n- *normalize* - rescale each stack to fill [0, 1]\n- *center* - align the centers of all stacks\n- *wiggle* - translate stacks to minimize apparent movement\n\nIf a given stack has zero total value, the *normalize* offset will not adjust the stack\u2019s position. Both the *center* and *wiggle* offsets ensure that the lowest element across stacks starts at zero for better default axes. The\n*wiggle* offset is recommended for streamgraphs in conjunction with the\n*inside-out* order. For more, see [Byron & Wattenberg][1].\n\n[1]: https://leebyron.com/streamgraph/"
		kind:        "alias"
		expression:  "stackOffsetNameType"
	},
	{
		name:        "StackOffset"
		description: "A stack offset method; one of:\n\n- *normalize* - rescale each stack to fill [0, 1]\n- *center* - align the centers of all stacks\n- *wiggle* - translate stacks to minimize apparent movement\n\nIf a given stack has zero total value, the *normalize* offset will not adjust the stack\u2019s position. Both the *center* and *wiggle* offsets ensure that the lowest element across stacks starts at zero for better default axes. The\n*wiggle* offset is recommended for streamgraphs in conjunction with the\n*inside-out* order. For more, see [Byron & Wattenberg][1].\n\n[1]: https://leebyron.com/streamgraph/"
		kind:        "alias"
		expression:  "stackOffsetNameReference"
	},
	{
		name:        "StackOrderName"
		description: "The built-in stack order methods; one of:\n\n- *x* - alias of *value*; for stackX only\n- *y* - alias of *value*; for stackY only\n- *value* - ascending value (or descending with **reverse**)\n- *sum* - total value per series\n- *appearance* - position of maximum value per series\n- *inside-out* (default with *wiggle*) - order the earliest-appearing series on the inside\n\nThe *inside-out* order is recommended for streamgraphs in conjunction with the *wiggle* offset. For more, see [Byron & Wattenberg][1].\n\n[1]: https://leebyron.com/streamgraph/"
		kind:        "alias"
		expression:  "stackOrderNameType"
	},
	{
		name:        "StackOrder"
		description: "How to order layers prior to stacking; one of:\n\n- a named stack order method such as *inside-out* or *sum*\n- a field name, for natural order of the corresponding values\n- an array of explicit **z** values in the desired order"
		kind:        "alias"
		expression:  "stackOrderType"
	},
	{
		name:        "StackOptions"
		description: "Options for the stack transform."
		wire:        false
		properties: [
			{
				name:        "offset"
				description: "After stacking, an optional **offset** can be applied to translate and scale stacks, say to produce a streamgraph; defaults to null for a zero baseline (**y** = 0 for stackY, and **x** = 0 for stackX). If the *wiggle* offset is used, the default **order** changes to *inside-out*."
				type:        "stackOptionsOffset"
			},
			{
				name:        "order"
				description: "The order in which stacks are layered; one of:\n\n- null (default) for input order\n- a named stack order method such as *inside-out* or *sum*\n- a field name, for natural order of the corresponding values\n- a function of data, for natural order of the corresponding values\n- an array of explicit **z** values in the desired order\n\nIf the *wiggle* **offset** is used, as for a streamgraph, the default changes to *inside-out*."
				type:        "stackOptionsOrder"
			},
			{name: "reverse", description: "If true, reverse the effective order of the stacks.", type: "booleanOrParamRef"},
			{
				name:        "z"
				description: "The **z** channel defines the series of each value in the stack. Used when the **order** is *sum*, *appearance*, *inside-out*, or an explicit array of\n**z** values."
				type:        "channelValueReference"
			},
		]
	},
	{
		name:        "MarkerName"
		description: "The built-in marker implementations; one of:\n\n- *arrow* - an arrowhead with *auto* orientation\n- *arrow-reverse* - an arrowhead with *auto-start-reverse* orientation\n- *dot* - a filled *circle* with no stroke and 2.5px radius\n- *circle-fill* - a filled circle with a white stroke and 3px radius\n- *circle-stroke* - a stroked circle with a white fill and 3px radius\n- *circle* - alias for *circle-fill*\n- *tick* - a small opposing line\n- *tick-x* - a small horizontal line\n- *tick-y* - a small vertical line"
		kind:        "alias"
		expression:  "markerNameType"
	},
	{
		name:        "MarkerOptions"
		description: "Options for marks that support markers, such as lines and links."
		wire:        false
		properties: [
			{
				name:        "marker"
				description: "Shorthand to set the same default for markerStart, markerMid, and markerEnd; one of:\n\n- a marker name such as *arrow* or *circle*\n- *none* (default) - no marker\n* true - alias for *circle-fill*\n* false or null - alias for *none*"
				type:        "markerOptionsMarker"
			},
			{
				name:        "markerStart"
				description: "The marker for the starting point of a line segment; one of:\n\n- a marker name such as *arrow* or *circle*\n* *none* (default) - no marker\n* true - alias for *circle-fill*\n* false or null - alias for *none*"
				type:        "markerOptionsMarker"
			},
			{
				name:        "markerMid"
				description: "The marker for any middle (interior) points of a line segment. If the line segment only has a start and end point, this option has no effect. One of:\n\n- a marker name such as *arrow* or *circle*\n* *none* (default) - no marker\n* true - alias for *circle-fill*\n* false or null - alias for *none*\n* a function - a custom marker function; see below"
				type:        "markerOptionsMarker"
			},
			{
				name:        "markerEnd"
				description: "The marker for the ending point of a line segment; one of:\n\n- a marker name such as *arrow* or *circle*\n* *none* (default) - no marker\n* true - alias for *circle-fill*\n* false or null - alias for *none*"
				type:        "markerOptionsMarker"
			},
		]
	},
]

typeExpressions: {[string]: model.#ShapeExpression} & {
	literalHeight: {kind: "literal", value: "height"}
	literalWidth: {kind: "literal", value: "width"}
	channelNameType: {
		kind: "enum"
		values: [
			"ariaLabel",
			"fill",
			"fillOpacity",
			"fontSize",
			"fx",
			"fy",
			"geometry",
			"height",
			"href",
			"length",
			"opacity",
			"path",
			"r",
			"rotate",
			"src",
			"stroke",
			"strokeOpacity",
			"strokeWidth",
			"symbol",
			"text",
			"title",
			"weight",
			"width",
			"x",
			"x1",
			"x2",
			"y",
			"y1",
			"y2",
			"z",
		]
	}
	scaleNameReference: {kind: "named", name: "ScaleName"}
	literalAuto: {kind: "literal", value: "auto"}
	boolean: {kind: "primitive", type: "boolean"}
	null: {kind: "primitive", type: "null"}
	channelScaleType: {kind: "union", members: ["scaleNameReference", "literalAuto", "boolean", "null"], schemaAdapter: "any-of"}
	any: {kind: "primitive", type: "any"}
	anyArray: {kind: "array", items: "any"}
	completionString: kind: "completion-string"
	number: {kind: "primitive", type: "number"}
	transformReference: {kind: "named", name: "Transform"}
	sQLExpressionReference: {kind: "named", name: "SQLExpression"}
	aggregateExpressionReference: {kind: "named", name: "AggregateExpression"}
	channelValueType: {
		kind: "union"
		members: [
			"anyArray",
			"completionString",
			"number",
			"boolean",
			"null",
			"transformReference",
			"sQLExpressionReference",
			"aggregateExpressionReference",
		]
		schemaAdapter: "any-of"
	}
	channelValueReference: {kind: "named", name: "ChannelValue"}
	string: {kind: "primitive", type: "string"}
	channelValueOptions: {
		kind: "record"
		properties: [
			{
				name:                 "value"
				description:          "The value value."
				documentationAdapter: "reference-only"
				required:             true
				type:                 "channelValueReference"
			},
			{name: "label", description: "The label value.", documentationAdapter: "reference-only", type: "string"},
			{name: "scale", description: "The scale value.", documentationAdapter: "reference-only", type: "channelScaleType"},
		]
	}
	channelValueSpecType: {kind: "union", members: ["channelValueReference", "channelValueOptions"], schemaAdapter: "any-of"}
	channelValueSpecReference: {kind: "named", name: "ChannelValueSpec"}
	intervalReference: {kind: "named", name: "Interval"}
	channelIntervalValue: {
		kind: "record"
		properties: [
			{
				name:                 "value"
				description:          "The value value."
				documentationAdapter: "reference-only"
				required:             true
				type:                 "channelValueReference"
			},
			{
				name:                 "interval"
				description:          "The interval value."
				documentationAdapter: "reference-only"
				required:             true
				type:                 "intervalReference"
			},
		]
	}
	channelValueIntervalSpecType: {kind: "union", members: ["channelValueSpecReference", "channelIntervalValue"], schemaAdapter: "any-of"}
	channelNameFinite: {kind: "reference", name: "ChannelName", expression: "channelNameType", schemaAdapter: "reference"}
	literalData: {kind: "literal", value: "data"}
	channelDomainNameType: {kind: "union", members: ["channelNameFinite", "literalData", "literalWidth", "literalHeight"], schemaAdapter: "any-of"}
	channelDomainNameFinite: {kind: "reference", name: "ChannelDomainName", expression: "channelDomainNameType", schemaAdapter: "inline"}
	descendingDomainName: {kind: "finite-template", reference: "channelDomainNameFinite", prefix: "-"}
	channelDomainValueType: {
		kind: "union"
		members: ["channelDomainNameFinite", "descendingDomainName", "null"]
		schemaAdapter: "template-union"
	}
	reducerReference: {kind: "named", name: "Reducer"}
	channelDomainOptionsReduce: {kind: "union", members: ["reducerReference", "boolean", "null"], schemaAdapter: "any-of"}
	literalAscending: {kind: "literal", value: "ascending"}
	literalDescending: {kind: "literal", value: "descending"}
	literalNull: {kind: "literal", value: null}
	channelDomainOptionsOrder: {kind: "union", members: ["literalAscending", "literalDescending", "literalNull"], schemaAdapter: "literal-enum"}
	domainLimitRange: {
		kind: "tuple"
		elements: [{type: "number", label: "lo", required: false}, {type: "number", label: "hi", required: false}]
		wireArity:     "all-elements"
		schemaAdapter: "positional-items"
	}
	channelDomainOptionsLimit: {kind: "union", members: ["number", "domainLimitRange"], schemaAdapter: "any-of"}
	channelDomainValueReference: {kind: "named", name: "ChannelDomainValue"}
	domainValueRecord: {
		kind: "record"
		properties: [
			{
				name:                 "value"
				description:          "The value value."
				documentationAdapter: "reference-only"
				required:             true
				type:                 "channelDomainValueReference"
			}
		]
	}
	inlineChannelDomainOptions: {kind: "inline-interface", name: "ChannelDomainOptions", elideBases: []}
	domainValueOptions: {
		kind: "intersection"
		members: ["domainValueRecord", "inlineChannelDomainOptions"]
		objectClosure: "closed"
	}
	channelDomainValueSpecType: {kind: "union", members: ["channelDomainValueReference", "domainValueOptions"], schemaAdapter: "any-of"}
	scaleNameFinite: {kind: "reference", name: "ScaleName", expression: "scaleNameValues", schemaAdapter: "reference"}
	channelDomainValueSpecReference: {kind: "named", name: "ChannelDomainValueSpec"}
	scaleDomainValues: {kind: "mapped", keys: "scaleNameFinite", values: "channelDomainValueSpecReference", keyName: "key", required: false}
	channelDomainSortType: {kind: "intersection", members: ["scaleDomainValues", "inlineChannelDomainOptions"], objectClosure: "closed"}
	parameterT: {kind: "parameter", name: "T", default: "reducerReference"}
	channelScaleReference: {kind: "named", name: "ChannelScale"}
	reducerOptions: {
		kind: "record"
		properties: [
			{
				name:                 "reduce"
				description:          "The reduce value."
				documentationAdapter: "reference-only"
				required:             true
				type:                 "parameterT"
			},
			{name: "scale", description: "The scale value.", documentationAdapter: "reference-only", type: "channelScaleReference"},
		]
	}
	channelReducersTypeValues: {kind: "union", members: ["parameterT", "reducerOptions", "null"], schemaAdapter: "any-of"}
	channelReducersType: {kind: "mapped", keys: "channelNameFinite", values: "channelReducersTypeValues", keyName: "key", required: false}
	channelStatesTypeValuesScale: {kind: "union", members: ["scaleNameReference", "null"], schemaAdapter: "any-of"}
	channelStatesTypeValues: {
		kind: "record"
		properties: [
			{
				name:                 "value"
				description:          "The value value."
				documentationAdapter: "reference-only"
				required:             true
				type:                 "anyArray"
			},
			{
				name:                 "scale"
				description:          "The scale value."
				documentationAdapter: "reference-only"
				required:             true
				type:                 "channelStatesTypeValuesScale"
			},
		]
	}
	channelStatesType: {kind: "mapped", keys: "channelNameFinite", values: "channelStatesTypeValues", keyName: "key", required: false}
	channelArrays: {kind: "mapped", keys: "channelNameFinite", values: "anyArray", keyName: "key", required: false}
	channelStatesReference: {kind: "named", name: "ChannelStates"}
	channelStateRecord: {
		kind: "record"
		properties: [
			{
				name:                 "channels"
				description:          "The channels value."
				documentationAdapter: "reference-only"
				required:             true
				type:                 "channelStatesReference"
			}
		]
	}
	channelValuesType: {kind: "intersection", members: ["channelArrays", "channelStateRecord"], objectClosure: "closed"}
	sortDirection: {kind: "enum", values: ["ascending", "descending"]}
	sortValueOptions: {
		kind: "record"
		properties: [
			{name: "value", description: "The value value.", documentationAdapter: "reference-only", type: "channelValueReference"},
			{
				name:                 "order"
				description:          "The order value."
				documentationAdapter: "reference-only"
				type:                 "sortDirection"
			},
		]
	}
	descendingChannelName: {kind: "finite-template", reference: "channelNameFinite", prefix: "-"}
	sortChannelName: {kind: "union", members: ["channelNameFinite", "descendingChannelName"], schemaAdapter: "template-union"}
	sortChannelOptions: {
		kind: "record"
		properties: [
			{
				name:                 "channel"
				description:          "The channel value."
				documentationAdapter: "reference-only"
				type:                 "sortChannelName"
			},
			{
				name:                 "order"
				description:          "The order value."
				documentationAdapter: "reference-only"
				type:                 "sortDirection"
			},
		]
	}
	sortOrderType: {
		kind: "union"
		members: ["channelValueReference", "sortValueOptions", "sortChannelOptions"]
		schemaAdapter: "any-of"
	}
	tipPointerType: {kind: "enum", values: ["x", "y", "xy"]}
	selectFilterType: {kind: "enum", values: ["first", "last", "maxX", "maxY", "minX", "minY", "nearest", "nearestX", "nearestY"]}
	plotMarkDataReference: {kind: "named", name: "PlotMarkData"}
	selectFilterReference: {kind: "named", name: "SelectFilter"}
	paramRefReference: {kind: "named", name: "ParamRef"}
	booleanOrParamRef: {kind: "union", members: ["boolean", "paramRefReference"], schemaAdapter: "any-of"}
	sortOrderReference: {kind: "named", name: "SortOrder"}
	channelDomainSortReference: {kind: "named", name: "ChannelDomainSort"}
	markOptionsSort: {kind: "union", members: ["sortOrderReference", "channelDomainSortReference"], schemaAdapter: "any-of"}
	literalInclude: {kind: "literal", value: "include"}
	literalExclude: {kind: "literal", value: "exclude"}
	literalSuper: {kind: "literal", value: "super"}
	markOptionsFacet: {
		kind: "union"
		members: ["literalAuto", "literalInclude", "literalExclude", "literalSuper", "boolean", "null", "paramRefReference"]
		schemaAdapter: "any-of"
	}
	literalTop: {kind: "literal", value: "top"}
	literalRight: {kind: "literal", value: "right"}
	literalBottom: {kind: "literal", value: "bottom"}
	literalLeft: {kind: "literal", value: "left"}
	literalTopLeft: {kind: "literal", value: "top-left"}
	literalTopRight: {kind: "literal", value: "top-right"}
	literalBottomLeft: {kind: "literal", value: "bottom-left"}
	literalBottomRight: {kind: "literal", value: "bottom-right"}
	literalTopEmpty: {kind: "literal", value: "top-empty"}
	literalRightEmpty: {kind: "literal", value: "right-empty"}
	literalBottomEmpty: {kind: "literal", value: "bottom-empty"}
	literalLeftEmpty: {kind: "literal", value: "left-empty"}
	literalEmpty: {kind: "literal", value: "empty"}
	markOptionsFacetAnchor: {
		kind: "union"
		members: [
			"literalTop",
			"literalRight",
			"literalBottom",
			"literalLeft",
			"literalTopLeft",
			"literalTopRight",
			"literalBottomLeft",
			"literalBottomRight",
			"literalTopEmpty",
			"literalRightEmpty",
			"literalBottomEmpty",
			"literalLeftEmpty",
			"literalEmpty",
			"null",
			"paramRefReference",
		]
		schemaAdapter: "any-of"
	}
	numberOrParamRef: {kind: "union", members: ["number", "paramRefReference"], schemaAdapter: "any-of"}
	markOptionsAriaDescription: {kind: "union", members: ["string", "paramRefReference"], schemaAdapter: "any-of"}
	tipPointerReference: {kind: "named", name: "TipPointer"}
	frameAnchorReference: {kind: "named", name: "FrameAnchor"}
	frameAnchorOrParamRef: {kind: "union", members: ["frameAnchorReference", "paramRefReference"], schemaAdapter: "any-of"}
	tipOptionsPreferredAnchor: {kind: "union", members: ["frameAnchorReference", "null", "paramRefReference"], schemaAdapter: "any-of"}
	tipOptionsFormatValues: {kind: "union", members: ["boolean", "string", "paramRefReference"], schemaAdapter: "any-of"}
	tipOptionsFormat: {kind: "mapped", keys: "channelNameFinite", values: "tipOptionsFormatValues", keyName: "name", required: false}
	literalStart: {kind: "literal", value: "start"}
	literalMiddle: {kind: "literal", value: "middle"}
	literalEnd: {kind: "literal", value: "end"}
	textStylesTextAnchor: {kind: "union", members: ["literalStart", "literalMiddle", "literalEnd", "paramRefReference"], schemaAdapter: "any-of"}
	literalClip: {kind: "literal", value: "clip"}
	literalEllipsis: {kind: "literal", value: "ellipsis"}
	literalClipStart: {kind: "literal", value: "clip-start"}
	literalClipEnd: {kind: "literal", value: "clip-end"}
	literalEllipsisStart: {kind: "literal", value: "ellipsis-start"}
	literalEllipsisMiddle: {kind: "literal", value: "ellipsis-middle"}
	literalEllipsisEnd: {kind: "literal", value: "ellipsis-end"}
	textStylesTextOverflow: {
		kind: "union"
		members: [
			"null",
			"literalClip",
			"literalEllipsis",
			"literalClipStart",
			"literalClipEnd",
			"literalEllipsisStart",
			"literalEllipsisMiddle",
			"literalEllipsisEnd",
			"paramRefReference",
		]
		schemaAdapter: "any-of"
	}
	textStylesFontSize: {kind: "union", members: ["channelValueReference", "paramRefReference"], schemaAdapter: "any-of"}
	markOptionsStrokeDasharray: {kind: "union", members: ["string", "number", "paramRefReference"], schemaAdapter: "any-of"}
	inlineTipOptions: {kind: "inline-interface", name: "TipOptions", elideBases: ["MarkOptions"]}
	tipPointerOptions: {
		kind: "record"
		properties: [
			{
				name:                 "pointer"
				description:          "The pointer value."
				documentationAdapter: "reference-only"
				type:                 "tipPointerReference"
			}
		]
	}
	tipOptions: {
		kind: "intersection"
		members: ["inlineTipOptions", "tipPointerOptions"]
		objectClosure: "unspecified"
	}
	markOptionsTip: {
		kind: "union"
		members: ["boolean", "tipPointerReference", "tipOptions", "paramRefReference"]
		schemaAdapter: "any-of"
	}
	markOptionsChannels: {kind: "dictionary", values: "string", keyName: "key"}
	literalFrame: {kind: "literal", value: "frame"}
	literalSphere: {kind: "literal", value: "sphere"}
	markOptionsClip: {
		kind: "union"
		members: ["literalFrame", "literalSphere", "boolean", "null", "paramRefReference"]
		schemaAdapter: "any-of"
	}
	markOptionsFill: {kind: "union", members: ["channelValueSpecReference", "paramRefReference"], schemaAdapter: "any-of"}
	curveNameReference: {kind: "named", name: "CurveName"}
	curveReference: {kind: "named", name: "Curve"}
	curveOptionsCurve: {kind: "union", members: ["curveReference", "paramRefReference"], schemaAdapter: "any-of"}
	curveAutoOptionsCurve: {kind: "union", members: ["curveReference", "literalAuto", "paramRefReference"], schemaAdapter: "any-of"}
	stackOffsetNameType: {kind: "enum", values: ["center", "normalize", "wiggle"]}
	stackOffsetNameReference: {kind: "named", name: "StackOffsetName"}
	stackOrderNameType: {kind: "enum", values: ["value", "x", "y", "z", "sum", "appearance", "inside-out"]}
	stackOrderNameReference: {kind: "named", name: "StackOrderName"}
	stackOrderNameFinite: {kind: "reference", name: "StackOrderName", expression: "stackOrderNameType", schemaAdapter: "reference"}
	descendingStackOrder: {kind: "finite-template", reference: "stackOrderNameFinite", prefix: "-"}
	stackOrderType: {
		kind: "union"
		members: ["stackOrderNameReference", "descendingStackOrder", "completionString", "anyArray"]
		schemaAdapter: "template-union"
	}
	stackOffsetReference: {kind: "named", name: "StackOffset"}
	stackOptionsOffset: {kind: "union", members: ["stackOffsetReference", "null", "paramRefReference"], schemaAdapter: "any-of"}
	stackOrderReference: {kind: "named", name: "StackOrder"}
	stackOptionsOrder: {kind: "union", members: ["stackOrderReference", "null", "paramRefReference"], schemaAdapter: "any-of"}
	markerNameType: {
		kind: "enum"
		values: ["arrow", "arrow-reverse", "dot", "circle", "circle-fill", "circle-stroke", "tick", "tick-x", "tick-y"]
	}
	markerNameReference: {kind: "named", name: "MarkerName"}
	literalNone: {kind: "literal", value: "none"}
	markerOptionsMarker: {
		kind: "union"
		members: ["markerNameReference", "literalNone", "boolean", "null", "paramRefReference"]
		schemaAdapter: "any-of"
	}
}

externalReferences: [...model.#ExternalReference] & [
	{name: "AggregateExpression", owner: "column", source: "../Expression.js"},
	{name: "SQLExpression", owner: "column", source: "../Expression.js"},
	{name: "ParamRef", owner: "params", source: "../Param.js"},
	{name: "PlotMarkData", owner: "data", source: "../PlotFrom.js"},
	{name: "CurveName", owner: "values", source: "../PlotTypes.js"},
	{name: "FrameAnchor", owner: "values", source: "../PlotTypes.js"},
	{name: "Interval", owner: "values", source: "../PlotTypes.js"},
	{name: "Reducer", owner: "values", source: "../PlotTypes.js"},
	{name: "ScaleName", owner: "values", source: "../PlotTypes.js", finiteExpression: "scaleNameValues"},
	{name: "Transform", owner: "spec", source: "../Transform.js"},
]

typeExpressions: {for reference in externalReferences if reference.finiteExpression != _|_ {(reference.finiteExpression): {kind: "enum", values: valueFamily.contractIndex[reference.name].values}}}
contractIndex: {for contract in contracts {(contract.name): contract}}
modelChecks: {
	names: true & list.UniqueItems([for contract in contracts {contract.name}])
	finiteProviders: [for reference in externalReferences if reference.finiteExpression != _|_ {true & (reference.owner == "values" && reference.source == "../PlotTypes.js")}]
}
