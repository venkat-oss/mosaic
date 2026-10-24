package values

import (
	"list"
	"idl.uw.edu/mosaic/api/model"
)

contracts: [...model.#ValueContract] & [
	{
		name:        "OmittedProperties"
		description: ""
		exported:    false
		file:        "CSSStyles.ts"
		kind:        "enum"
		values: ["parentRule", "getPropertyPriority", "getPropertyValue", "item", "removeProperty", "setProperty"]
	},
	{
		name:        "CSSStyles"
		description: "CSS style properties for a plot. TypeScript adapts CSSStyleDeclaration; the wire contract admits string properties and a numeric length."
		exported:    true
		file:        "CSSStyles.ts"
		kind:        "host"
		adapter:     "dom-css"
		host:        "CSSStyleDeclaration"
		omit:        "OmittedProperties"
		stringProperties: [
			"accentColor",
			"alignContent",
			"alignItems",
			"alignSelf",
			"alignmentBaseline",
			"all",
			"anchorName",
			"anchorScope",
			"animation",
			"animationComposition",
			"animationDelay",
			"animationDirection",
			"animationDuration",
			"animationFillMode",
			"animationIterationCount",
			"animationName",
			"animationPlayState",
			"animationRange",
			"animationRangeEnd",
			"animationRangeStart",
			"animationTimeline",
			"animationTimingFunction",
			"appearance",
			"aspectRatio",
			"backdropFilter",
			"backfaceVisibility",
			"background",
			"backgroundAttachment",
			"backgroundBlendMode",
			"backgroundClip",
			"backgroundColor",
			"backgroundImage",
			"backgroundOrigin",
			"backgroundPosition",
			"backgroundPositionX",
			"backgroundPositionY",
			"backgroundRepeat",
			"backgroundSize",
			"baselineShift",
			"baselineSource",
			"blockSize",
			"border",
			"borderBlock",
			"borderBlockColor",
			"borderBlockEnd",
			"borderBlockEndColor",
			"borderBlockEndStyle",
			"borderBlockEndWidth",
			"borderBlockStart",
			"borderBlockStartColor",
			"borderBlockStartStyle",
			"borderBlockStartWidth",
			"borderBlockStyle",
			"borderBlockWidth",
			"borderBottom",
			"borderBottomColor",
			"borderBottomLeftRadius",
			"borderBottomRightRadius",
			"borderBottomStyle",
			"borderBottomWidth",
			"borderCollapse",
			"borderColor",
			"borderEndEndRadius",
			"borderEndStartRadius",
			"borderImage",
			"borderImageOutset",
			"borderImageRepeat",
			"borderImageSlice",
			"borderImageSource",
			"borderImageWidth",
			"borderInline",
			"borderInlineColor",
			"borderInlineEnd",
			"borderInlineEndColor",
			"borderInlineEndStyle",
			"borderInlineEndWidth",
			"borderInlineStart",
			"borderInlineStartColor",
			"borderInlineStartStyle",
			"borderInlineStartWidth",
			"borderInlineStyle",
			"borderInlineWidth",
			"borderLeft",
			"borderLeftColor",
			"borderLeftStyle",
			"borderLeftWidth",
			"borderRadius",
			"borderRight",
			"borderRightColor",
			"borderRightStyle",
			"borderRightWidth",
			"borderSpacing",
			"borderStartEndRadius",
			"borderStartStartRadius",
			"borderStyle",
			"borderTop",
			"borderTopColor",
			"borderTopLeftRadius",
			"borderTopRightRadius",
			"borderTopStyle",
			"borderTopWidth",
			"borderWidth",
			"bottom",
			"boxDecorationBreak",
			"boxShadow",
			"boxSizing",
			"breakAfter",
			"breakBefore",
			"breakInside",
			"captionSide",
			"caretColor",
			"clear",
			"clip",
			"clipPath",
			"clipRule",
			"color",
			"colorInterpolation",
			"colorInterpolationFilters",
			"colorScheme",
			"columnCount",
			"columnFill",
			"columnGap",
			"columnRule",
			"columnRuleColor",
			"columnRuleStyle",
			"columnRuleWidth",
			"columnSpan",
			"columnWidth",
			"columns",
			"contain",
			"containIntrinsicBlockSize",
			"containIntrinsicHeight",
			"containIntrinsicInlineSize",
			"containIntrinsicSize",
			"containIntrinsicWidth",
			"container",
			"containerName",
			"containerType",
			"content",
			"contentVisibility",
			"counterIncrement",
			"counterReset",
			"counterSet",
			"cssFloat",
			"cssText",
			"cursor",
			"cx",
			"cy",
			"d",
			"direction",
			"display",
			"dominantBaseline",
			"dynamicRangeLimit",
			"emptyCells",
			"fieldSizing",
			"fill",
			"fillOpacity",
			"fillRule",
			"filter",
			"flex",
			"flexBasis",
			"flexDirection",
			"flexFlow",
			"flexGrow",
			"flexShrink",
			"flexWrap",
			"float",
			"floodColor",
			"floodOpacity",
			"font",
			"fontFamily",
			"fontFeatureSettings",
			"fontKerning",
			"fontLanguageOverride",
			"fontOpticalSizing",
			"fontPalette",
			"fontSize",
			"fontSizeAdjust",
			"fontStretch",
			"fontStyle",
			"fontSynthesis",
			"fontSynthesisSmallCaps",
			"fontSynthesisStyle",
			"fontSynthesisWeight",
			"fontVariant",
			"fontVariantAlternates",
			"fontVariantCaps",
			"fontVariantEastAsian",
			"fontVariantEmoji",
			"fontVariantLigatures",
			"fontVariantNumeric",
			"fontVariantPosition",
			"fontVariationSettings",
			"fontWeight",
			"forcedColorAdjust",
			"gap",
			"grid",
			"gridArea",
			"gridAutoColumns",
			"gridAutoFlow",
			"gridAutoRows",
			"gridColumn",
			"gridColumnEnd",
			"gridColumnGap",
			"gridColumnStart",
			"gridGap",
			"gridRow",
			"gridRowEnd",
			"gridRowGap",
			"gridRowStart",
			"gridTemplate",
			"gridTemplateAreas",
			"gridTemplateColumns",
			"gridTemplateRows",
			"height",
			"hyphenateCharacter",
			"hyphenateLimitChars",
			"hyphens",
			"imageOrientation",
			"imageRendering",
			"inlineSize",
			"inset",
			"insetBlock",
			"insetBlockEnd",
			"insetBlockStart",
			"insetInline",
			"insetInlineEnd",
			"insetInlineStart",
			"isolation",
			"justifyContent",
			"justifyItems",
			"justifySelf",
			"left",
			"letterSpacing",
			"lightingColor",
			"lineBreak",
			"lineHeight",
			"listStyle",
			"listStyleImage",
			"listStylePosition",
			"listStyleType",
			"margin",
			"marginBlock",
			"marginBlockEnd",
			"marginBlockStart",
			"marginBottom",
			"marginInline",
			"marginInlineEnd",
			"marginInlineStart",
			"marginLeft",
			"marginRight",
			"marginTop",
			"marker",
			"markerEnd",
			"markerMid",
			"markerStart",
			"mask",
			"maskClip",
			"maskComposite",
			"maskImage",
			"maskMode",
			"maskOrigin",
			"maskPosition",
			"maskRepeat",
			"maskSize",
			"maskType",
			"mathDepth",
			"mathShift",
			"mathStyle",
			"maxBlockSize",
			"maxHeight",
			"maxInlineSize",
			"maxWidth",
			"minBlockSize",
			"minHeight",
			"minInlineSize",
			"minWidth",
			"mixBlendMode",
			"objectFit",
			"objectPosition",
			"offset",
			"offsetAnchor",
			"offsetDistance",
			"offsetPath",
			"offsetPosition",
			"offsetRotate",
			"opacity",
			"order",
			"orphans",
			"outline",
			"outlineColor",
			"outlineOffset",
			"outlineStyle",
			"outlineWidth",
			"overflow",
			"overflowAnchor",
			"overflowBlock",
			"overflowClipMargin",
			"overflowInline",
			"overflowWrap",
			"overflowX",
			"overflowY",
			"overscrollBehavior",
			"overscrollBehaviorBlock",
			"overscrollBehaviorInline",
			"overscrollBehaviorX",
			"overscrollBehaviorY",
			"padding",
			"paddingBlock",
			"paddingBlockEnd",
			"paddingBlockStart",
			"paddingBottom",
			"paddingInline",
			"paddingInlineEnd",
			"paddingInlineStart",
			"paddingLeft",
			"paddingRight",
			"paddingTop",
			"page",
			"pageBreakAfter",
			"pageBreakBefore",
			"pageBreakInside",
			"paintOrder",
			"perspective",
			"perspectiveOrigin",
			"placeContent",
			"placeItems",
			"placeSelf",
			"pointerEvents",
			"position",
			"positionAnchor",
			"positionArea",
			"positionTry",
			"positionTryFallbacks",
			"positionTryOrder",
			"positionVisibility",
			"printColorAdjust",
			"quotes",
			"r",
			"resize",
			"right",
			"rotate",
			"rowGap",
			"rubyAlign",
			"rubyPosition",
			"rx",
			"ry",
			"scale",
			"scrollBehavior",
			"scrollMargin",
			"scrollMarginBlock",
			"scrollMarginBlockEnd",
			"scrollMarginBlockStart",
			"scrollMarginBottom",
			"scrollMarginInline",
			"scrollMarginInlineEnd",
			"scrollMarginInlineStart",
			"scrollMarginLeft",
			"scrollMarginRight",
			"scrollMarginTop",
			"scrollPadding",
			"scrollPaddingBlock",
			"scrollPaddingBlockEnd",
			"scrollPaddingBlockStart",
			"scrollPaddingBottom",
			"scrollPaddingInline",
			"scrollPaddingInlineEnd",
			"scrollPaddingInlineStart",
			"scrollPaddingLeft",
			"scrollPaddingRight",
			"scrollPaddingTop",
			"scrollSnapAlign",
			"scrollSnapStop",
			"scrollSnapType",
			"scrollTimeline",
			"scrollTimelineAxis",
			"scrollTimelineName",
			"scrollbarColor",
			"scrollbarGutter",
			"scrollbarWidth",
			"shapeImageThreshold",
			"shapeMargin",
			"shapeOutside",
			"shapeRendering",
			"stopColor",
			"stopOpacity",
			"stroke",
			"strokeDasharray",
			"strokeDashoffset",
			"strokeLinecap",
			"strokeLinejoin",
			"strokeMiterlimit",
			"strokeOpacity",
			"strokeWidth",
			"tabSize",
			"tableLayout",
			"textAlign",
			"textAlignLast",
			"textAnchor",
			"textAutospace",
			"textBox",
			"textBoxEdge",
			"textBoxTrim",
			"textCombineUpright",
			"textDecoration",
			"textDecorationColor",
			"textDecorationLine",
			"textDecorationSkipInk",
			"textDecorationStyle",
			"textDecorationThickness",
			"textEmphasis",
			"textEmphasisColor",
			"textEmphasisPosition",
			"textEmphasisStyle",
			"textIndent",
			"textJustify",
			"textOrientation",
			"textOverflow",
			"textRendering",
			"textShadow",
			"textTransform",
			"textUnderlineOffset",
			"textUnderlinePosition",
			"textWrap",
			"textWrapMode",
			"textWrapStyle",
			"timelineScope",
			"top",
			"touchAction",
			"transform",
			"transformBox",
			"transformOrigin",
			"transformStyle",
			"transition",
			"transitionBehavior",
			"transitionDelay",
			"transitionDuration",
			"transitionProperty",
			"transitionTimingFunction",
			"translate",
			"unicodeBidi",
			"userSelect",
			"vectorEffect",
			"verticalAlign",
			"viewTimeline",
			"viewTimelineAxis",
			"viewTimelineInset",
			"viewTimelineName",
			"viewTransitionClass",
			"viewTransitionName",
			"visibility",
			"webkitAlignContent",
			"webkitAlignItems",
			"webkitAlignSelf",
			"webkitAnimation",
			"webkitAnimationDelay",
			"webkitAnimationDirection",
			"webkitAnimationDuration",
			"webkitAnimationFillMode",
			"webkitAnimationIterationCount",
			"webkitAnimationName",
			"webkitAnimationPlayState",
			"webkitAnimationTimingFunction",
			"webkitAppearance",
			"webkitBackfaceVisibility",
			"webkitBackgroundClip",
			"webkitBackgroundOrigin",
			"webkitBackgroundSize",
			"webkitBorderBottomLeftRadius",
			"webkitBorderBottomRightRadius",
			"webkitBorderRadius",
			"webkitBorderTopLeftRadius",
			"webkitBorderTopRightRadius",
			"webkitBoxAlign",
			"webkitBoxFlex",
			"webkitBoxOrdinalGroup",
			"webkitBoxOrient",
			"webkitBoxPack",
			"webkitBoxShadow",
			"webkitBoxSizing",
			"webkitFilter",
			"webkitFlex",
			"webkitFlexBasis",
			"webkitFlexDirection",
			"webkitFlexFlow",
			"webkitFlexGrow",
			"webkitFlexShrink",
			"webkitFlexWrap",
			"webkitJustifyContent",
			"webkitLineClamp",
			"webkitMask",
			"webkitMaskBoxImage",
			"webkitMaskBoxImageOutset",
			"webkitMaskBoxImageRepeat",
			"webkitMaskBoxImageSlice",
			"webkitMaskBoxImageSource",
			"webkitMaskBoxImageWidth",
			"webkitMaskClip",
			"webkitMaskComposite",
			"webkitMaskImage",
			"webkitMaskOrigin",
			"webkitMaskPosition",
			"webkitMaskRepeat",
			"webkitMaskSize",
			"webkitOrder",
			"webkitPerspective",
			"webkitPerspectiveOrigin",
			"webkitTextFillColor",
			"webkitTextSizeAdjust",
			"webkitTextStroke",
			"webkitTextStrokeColor",
			"webkitTextStrokeWidth",
			"webkitTransform",
			"webkitTransformOrigin",
			"webkitTransformStyle",
			"webkitTransition",
			"webkitTransitionDelay",
			"webkitTransitionDuration",
			"webkitTransitionProperty",
			"webkitTransitionTimingFunction",
			"webkitUserSelect",
			"whiteSpace",
			"whiteSpaceCollapse",
			"widows",
			"width",
			"willChange",
			"wordBreak",
			"wordSpacing",
			"wordWrap",
			"writingMode",
			"x",
			"y",
			"zIndex",
			"zoom",
		]
		numberProperties: ["length"]
		additionalProperties: "string"
	},
	{
		name:        "Fixed"
		description: "A symbol indicating a fixed scale domain. A fixed domain is initially determined from data as usual, but subsequently \"fixed\" so that it does not change over subsequent interactive filtering, ensring stable comparisons."
		exported:    true
		file:        "PlotTypes.ts"
		kind:        "literal"
		value:       "Fixed"
	},
	{
		name:        "LiteralTimeInterval"
		description: "A named, plural, or numeric time interval string. TypeScript constrains its template forms; the current wire definition admits any string."
		exported:    true
		file:        "PlotTypes.ts"
		kind:        "union"
		members: [
			{kind: "literal", value: "3 months"},
			{kind: "literal", value: "10 years"},
			{kind: "reference", name: "TimeIntervalName"},
			{
				kind: "template"
				parts: [{reference: "TimeIntervalName"}, {literal: "s"}]
				completion:    "empty-record"
				schemaAdapter: "enumerate"
			},
			{
				kind: "template"
				parts: [{primitive: "number"}, {literal: " "}, {reference: "TimeIntervalName"}]
				completion:    "empty-record"
				schemaAdapter: "open-string"
			},
			{
				kind: "template"
				parts: [{primitive: "number"}, {literal: " "}, {reference: "TimeIntervalName"}]
				completion:    "empty-record"
				schemaAdapter: "open-string"
				suffix:        "s"
			},
		]
	},
	{
		name:        "TimeIntervalName"
		description: "The built-in time intervals; UTC or local time, depending on context. The\n*week* interval is an alias for *sunday*. The *quarter* interval is every three months, and the *half* interval is every six months, aligned at the start of the year."
		exported:    true
		file:        "PlotTypes.ts"
		kind:        "enum"
		values: [
			"second",
			"minute",
			"hour",
			"day",
			"week",
			"month",
			"quarter",
			"half",
			"year",
			"monday",
			"tuesday",
			"wednesday",
			"thursday",
			"friday",
			"saturday",
			"sunday",
		]
	},
	{
		name:        "Interval"
		description: "How to partition a continuous range into discrete intervals; one of:\n\n- a named time interval such as *day* (for date intervals)\n- a number (for number intervals), defining intervals at integer multiples of *n*"
		exported:    true
		file:        "PlotTypes.ts"
		kind:        "conditional"
		parameter: {name: "T", default: "any"}
		branches: [
			{when: "Date", value: {kind: "reference", name: "LiteralTimeInterval"}},
			{when: "number", value: {kind: "primitive", type: "number"}},
		]
		fallback:      "never"
		schemaAdapter: "default-first-branch"
	},
	{
		name:        "ScaleName"
		description: "The built-in scale names; one of:\n\n- *x* - horizontal position\n- *y* - vertical position\n- *fx* - horizontal facet position\n- *fy* - vertical facet position\n- *r* - radius (for dots and point geos)\n- *color* - color\n- *opacity* - opacity\n- *symbol* - categorical symbol (for dots)\n- *length* - length (for vectors)\n\nPosition scales may have associated axes. Color, opacity, and symbol scales may have an associated legend."
		exported:    true
		file:        "PlotTypes.ts"
		kind:        "enum"
		values: ["x", "y", "fx", "fy", "r", "color", "opacity", "symbol", "length"]
	},
	{
		name:        "PositionScaleType"
		description: "The supported scale types for *x* and *y* position encodings.\n\nFor quantitative data, one of:\n\n- *linear* (default) - linear transform (translate and scale)\n- *pow* - power (exponential) transform\n- *sqrt* - square-root transform; *pow* with *exponent* = 0.5\n- *log* - logarithmic transform\n- *symlog* - bi-symmetric logarithmic transform per Webber et al.\n\nFor temporal data, one of:\n\n- *utc* (default, recommended) - UTC time\n- *time* - local time\n\nFor ordinal data, one of:\n\n- *point* (for position only) - divide a continuous range into discrete points\n- *band* (for position only) - divide a continuous range into discrete points\n\nOther scale types:\n\n- *identity* - do not transform values when encoding"
		exported:    true
		file:        "PlotTypes.ts"
		kind:        "enum"
		values: [
			"linear",
			"pow",
			"sqrt",
			"log",
			"symlog",
			"utc",
			"time",
			"point",
			"band",
			"threshold",
			"quantile",
			"quantize",
			"identity",
		]
	},
	{
		name:        "ColorScaleType"
		description: "The supported scale types for *color* encodings.\n\nFor quantitative data, one of:\n\n- *linear* (default) - linear transform (translate and scale)\n- *pow* - power (exponential) transform\n- *sqrt* - square-root transform; *pow* with *exponent* = 0.5\n- *log* - logarithmic transform\n- *symlog* - bi-symmetric logarithmic transform per Webber et al.\n\nFor temporal data, one of:\n\n- *utc* (default, recommended) - UTC time\n- *time* - local time\n\nFor ordinal data, one of:\n\n- *ordinal* - from discrete inputs to discrete outputs\n\nFor color, one of:\n\n- *categorical* - equivalent to *ordinal*; defaults to *observable10*\n- *sequential* - equivalent to *linear*; defaults to *turbo*\n- *cyclical* - equivalent to *linear*; defaults to *rainbow*\n- *threshold* - encodes using discrete thresholds; defaults to *rdylbu*\n- *quantile* - encodes using quantile thresholds; defaults to *rdylbu*\n- *quantize* - uniformly quantizes a continuous domain; defaults to *rdylbu*\n- *diverging* - *linear*, but with a pivot; defaults to *rdbu*\n- *diverging-log* - *log*, but with a pivot; defaults to *rdbu*\n- *diverging-pow* - *pow*, but with a pivot; defaults to *rdbu*\n- *diverging-sqrt* - *sqrt*, but with a pivot; defaults to *rdbu*\n- *diverging-symlog* - *symlog*, but with a pivot; defaults to *rdbu*\n\nOther scale types:\n\n- *identity* - do not transform values when encoding"
		exported:    true
		file:        "PlotTypes.ts"
		kind:        "enum"
		values: [
			"linear",
			"pow",
			"sqrt",
			"log",
			"symlog",
			"utc",
			"time",
			"point",
			"band",
			"ordinal",
			"sequential",
			"cyclical",
			"diverging",
			"diverging-log",
			"diverging-pow",
			"diverging-sqrt",
			"diverging-symlog",
			"categorical",
			"threshold",
			"quantile",
			"quantize",
			"identity",
		]
	},
	{
		name:        "ContinuousScaleType"
		description: "The supported scale types for continuous encoding channels.\n\nFor quantitative data, one of:\n\n- *linear* (default) - linear transform (translate and scale)\n- *pow* - power (exponential) transform\n- *sqrt* - square-root transform; *pow* with *exponent* = 0.5\n- *log* - logarithmic transform\n- *symlog* - bi-symmetric logarithmic transform per Webber et al.\n\nFor temporal data, one of:\n\n- *utc* (default, recommended) - UTC time\n- *time* - local time\n\nOther scale types:\n\n- *identity* - do not transform values when encoding"
		exported:    true
		file:        "PlotTypes.ts"
		kind:        "enum"
		values: ["linear", "pow", "sqrt", "log", "symlog", "utc", "time", "identity"]
	},
	{
		name:        "DiscreteScaleType"
		description: "The supported scale types for discrete encoding channels. One of:\n\n- *ordinal* - from discrete inputs to discrete outputs\n- *identity* - do not transform values when encoding"
		exported:    true
		file:        "PlotTypes.ts"
		kind:        "enum"
		values: ["ordinal", "identity"]
	},
	{
		name:        "ProjectionName"
		description: "The built-in projection implementations; one of:\n\n- *albers-usa* - a U.S.-centric composite projection with insets for Alaska and Hawaii\n- *albers* - a U.S.-centric *conic-equal-area* projection\n- *azimuthal-equal-area* - the azimuthal equal-area projection\n- *azimuthal-equidistant* - the azimuthal equidistant projection\n- *conic-conformal* - the conic conformal projection\n- *conic-equal-area* - the conic equal-area projection\n- *conic-equidistant* - the conic equidistant projection\n- *equal-earth* - the Equal Earth projection Šavrič et al., 2018\n- *equirectangular* - the equirectangular (plate carrée) projection\n- *gnomonic* - the gnomonic projection\n- *identity* - the identity projection\n- *reflect-y* - the identity projection, but flipping *y*\n- *mercator* - the spherical Mercator projection\n- *orthographic* - the orthographic projection\n- *stereographic* - the stereographic projection\n- *transverse-mercator* - the transverse spherical Mercator projection"
		exported:    true
		file:        "PlotTypes.ts"
		kind:        "enum"
		values: [
			"albers-usa",
			"albers",
			"azimuthal-equal-area",
			"azimuthal-equidistant",
			"conic-conformal",
			"conic-equal-area",
			"conic-equidistant",
			"equal-earth",
			"equirectangular",
			"gnomonic",
			"identity",
			"reflect-y",
			"mercator",
			"orthographic",
			"stereographic",
			"transverse-mercator",
		]
	},
	{
		name:        "Interpolate"
		description: "How to interpolate range (output) values for continuous scales; one of:\n\n- *number* - linear numeric interpolation\n- *rgb* - red, green, blue (sRGB)\n- *hsl* - hue, saturation, lightness (HSL; cylindrical sRGB)\n- *hcl* - hue, chroma, perceptual lightness (CIELCh_ab; cylindrical CIELAB)\n- *lab* - perceptual lightness and opponent colors (L\\*a\\*b\\*, CIELAB)"
		exported:    true
		file:        "PlotTypes.ts"
		kind:        "enum"
		values: ["number", "rgb", "hsl", "hcl", "lab"]
	},
	{
		name:        "ColorSchemeCase"
		description: "The built-in color schemes, cased."
		exported:    false
		file:        "PlotTypes.ts"
		kind:        "enum"
		values: [
			"Accent",
			"Category10",
			"Dark2",
			"Observable10",
			"Paired",
			"Pastel1",
			"Pastel2",
			"Set1",
			"Set2",
			"Set3",
			"Tableau10",
			"BrBG",
			"PRGn",
			"PiYG",
			"PuOr",
			"RdBu",
			"RdGy",
			"RdYlBu",
			"RdYlGn",
			"Spectral",
			"BuRd",
			"BuYlRd",
			"Blues",
			"Greens",
			"Greys",
			"Oranges",
			"Purples",
			"Reds",
			"Turbo",
			"Viridis",
			"Magma",
			"Inferno",
			"Plasma",
			"Cividis",
			"Cubehelix",
			"Warm",
			"Cool",
			"BuGn",
			"BuPu",
			"GnBu",
			"OrRd",
			"PuBu",
			"PuBuGn",
			"PuRd",
			"RdPu",
			"YlGn",
			"YlGnBu",
			"YlOrBr",
			"YlOrRd",
			"Rainbow",
			"Sinebow",
		]
	},
	{
		name:        "ColorScheme"
		description: "The built-in color schemes. For categorical data, one of:\n\n- *Accent* - eight colors\n- *Category10* - ten colors\n- *Dark2* - eight colors\n- *Observable10* (default) - ten colors\n- *Paired* - twelve paired colors\n- *Pastel1* - nine colors\n- *Pastel2* - eight colors\n- *Set1* - nine colors\n- *Set2* - eight colors\n- *Set3* - twelve colors\n- *Tableau10* - ten colors\n\nFor diverging data, one of:\n\n- *BrBG* - from brown to white to blue-green\n- *PRGn* - from purple to white to green\n- *PiYG* - from pink to white to yellow-green\n- *PuOr* - from purple to white to orange\n- *RdBu* (default) - from red to white to blue\n- *RdGy* - from red to white to gray\n- *RdYlBu* - from red to yellow to blue\n- *RdYlGn* - from red to yellow to green\n- *Spectral* - from red to blue, through the spectrum\n- *BuRd* - from blue to white to red\n- *BuYlRd* - from blue to yellow to red\n\nFor sequential data, one of:\n\n- *Blues* - from white to blue\n- *Greens* - from white to green\n- *Greys* - from white to gray\n- *Oranges* - from white to orange\n- *Purples* - from white to purple\n- *Reds* - from white to red\n- *Turbo* (default) - from blue to red, through the spectrum\n- *Viridis* - from blue to green to yellow\n- *Magma* - from purple to orange to yellow\n- *Inferno* - from purple to orange to yellow\n- *Plasma* - from purple to orange to yellow\n- *Cividis* - from blue to yellow\n- *Cubehelix* - from black to white, rotating hue\n- *Warm* - from purple to green, through warm hues\n- *Cool* - from green to to purple, through cool hues\n- *BuGn* - from light blue to dark green\n- *BuPu* - from light blue to dark purple\n- *GnBu* - from light green to dark blue\n- *OrRd* - from light orange to dark red\n- *PuBu* - from light purple to dark blue\n- *PuBuGn* - from light purple to blue to dark green\n- *PuRd* - from light purple to dark red\n- *RdPu* - from light red to dark purple\n- *YlGn* - from light yellow to dark green\n- *YlGnBu* - from light yellow to green to dark blue\n- *YlOrBr* - from light yellow to orange to dark brown\n- *YlOrRd* - from light yellow to orange to dark red\n\nFor cyclical data, one of:\n\n- *Rainbow* (default) - the less-angry rainbow color scheme\n- *Sinebow* - Bumgardner and Loyd’s “sinebow” scheme"
		exported:    true
		file:        "PlotTypes.ts"
		kind:        "union"
		members: [
			{kind: "reference", name: "ColorSchemeCase"},
			{
				kind:          "casefold"
				reference:     "ColorSchemeCase"
				transform:     "lowercase"
				completion:    "empty-record"
				schemaAdapter: "empty-object-per-member"
			},
		]
	},
	{
		name:        "SymbolType"
		description: "The built-in symbol implementations. For fill, one of:\n\n- *circle* - a circle\n- *cross* - a Greek cross with arms of equal length\n- *diamond* - a rhombus\n- *square* - a square\n- *star* - a pentagonal star (pentagram)\n- *triangle* - an up-pointing triangle\n- *wye* - a Y with arms of equal length\n\nFor stroke (based on [Heman Robinson’s research][symbol-research]), one of:\n\n- *circle* - a circle\n- *plus* - a plus sign\n- *times* - an X with arms of equal length\n- *triangle2* - an (alternate) up-pointing triangle\n- *asterisk* - an asterisk\n- *square2* - a (alternate) square\n- *diamond2* - a rotated square\n\nThe *hexagon* symbol is also supported.\n\n[symbol-research]: https://www.tandfonline.com/doi/abs/10.1080/10618600.2019.1637746"
		exported:    true
		file:        "PlotTypes.ts"
		kind:        "enum"
		values: [
			"asterisk",
			"circle",
			"cross",
			"diamond",
			"diamond2",
			"hexagon",
			"plus",
			"square",
			"square2",
			"star",
			"times",
			"triangle",
			"triangle2",
			"wye",
		]
	},
	{
		name:        "FrameAnchor"
		description: "How to anchor a mark relative to the plot’s frame; one of:\n\n- *middle* - centered in the middle\n- in the middle of one of the edges: *top*, *right*, *bottom*, *left*\n- in one of the corners: *top-left*, *top-right*, *bottom-right*, *bottom-left*"
		exported:    true
		file:        "PlotTypes.ts"
		kind:        "enum"
		values: ["middle", "top-left", "top", "top-right", "right", "bottom-right", "bottom", "bottom-left", "left"]
	},
	{
		name:        "Digit"
		description: ""
		exported:    false
		file:        "PlotTypes.ts"
		kind:        "enum"
		values: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
	},
	{
		name:        "ReducerPercentile"
		description: "A percentile reducer from p00 through p99, with common percentile names retained as TypeScript completion hints."
		exported:    true
		file:        "PlotTypes.ts"
		kind:        "union"
		members: [
			{
				kind: "template"
				parts: [{literal: "p"}, {reference: "Digit"}, {reference: "Digit"}]
				completion:    "empty-record"
				schemaAdapter: "enumerate"
			},
			{kind: "literal", value: "p25"},
			{kind: "literal", value: "p50"},
			{kind: "literal", value: "p75"},
		]
		schemaAdapter: "unique-enum"
	},
	{
		name:        "Reducer"
		description: "How to reduce aggregated (binned or grouped) values; one of:\n\n- *first* - the first value, in input order\n- *last* - the last value, in input order\n- *count* - the number of elements (frequency)\n- *distinct* - the number of distinct values\n- *sum* - the sum of values\n- *proportion* - the sum proportional to the overall total (weighted frequency)\n- *proportion-facet* - the sum proportional to the facet total\n- *deviation* - the standard deviation\n- *min* - the minimum value\n- *min-index* - the zero-based index of the minimum value\n- *max* - the maximum value\n- *max-index* - the zero-based index of the maximum value\n- *mean* - the mean value (average)\n- *median* - the median value\n- *variance* - the variance per [Welford’s algorithm][welford]\n- *mode* - the value with the most occurrences\n- *pXX* - the percentile value, where XX is a number in [00,99]\n- *identity* - the array of values\n\n[welford]: https://en.wikipedia.org/wiki/Algorithms_for_calculating_variance#Welford's_online_algorithm"
		exported:    true
		file:        "PlotTypes.ts"
		kind:        "union"
		members: [
			{kind: "literal", value: "first"},
			{kind: "literal", value: "last"},
			{kind: "literal", value: "identity"},
			{kind: "literal", value: "count"},
			{kind: "literal", value: "distinct"},
			{kind: "literal", value: "sum"},
			{kind: "literal", value: "proportion"},
			{kind: "literal", value: "proportion-facet"},
			{kind: "literal", value: "deviation"},
			{kind: "literal", value: "min"},
			{kind: "literal", value: "min-index"},
			{kind: "literal", value: "max"},
			{kind: "literal", value: "max-index"},
			{kind: "literal", value: "mean"},
			{kind: "literal", value: "median"},
			{kind: "literal", value: "variance"},
			{kind: "literal", value: "mode"},
			{kind: "reference", name: "ReducerPercentile"},
		]
	},
	{
		name:        "CurveName"
		description: "The built-in curve implementations."
		exported:    true
		file:        "PlotTypes.ts"
		kind:        "enum"
		values: [
			"basis",
			"basis-closed",
			"basis-open",
			"bundle",
			"bump-x",
			"bump-y",
			"cardinal",
			"cardinal-closed",
			"cardinal-open",
			"catmull-rom",
			"catmull-rom-closed",
			"catmull-rom-open",
			"linear",
			"linear-closed",
			"monotone-x",
			"monotone-y",
			"natural",
			"step",
			"step-after",
			"step-before",
		]
	},
]

contractIndex: {for contract in contracts {(contract.name): contract}}
publicContracts: [for contract in contracts if contract.exported {contract}]
cssKnownProperties:   contractIndex.CSSStyles.stringProperties
cssOmittedProperties: contractIndex.OmittedProperties.values
checks: {
	names: true & list.UniqueItems([for contract in contracts {contract.name}])
	cssProperties: true & list.UniqueItems(cssKnownProperties)
}
