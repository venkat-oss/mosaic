package specadmission

import ("time"
	"net")

#PlotAttributes: {"name"?: string, "width"?: (number | #ParamRef), "height"?: (number | #ParamRef), "aspectRatio"?: (number | bool | null | #ParamRef), "margin"?: (number | #ParamRef), "marginTop"?: (number | #ParamRef), "marginRight"?: (number | #ParamRef), "marginBottom"?: (number | #ParamRef), "marginLeft"?: (number | #ParamRef), "margins"?: {
		"top"?:                         (number | #ParamRef)
		"right"?:                       (number | #ParamRef)
		"bottom"?:                      (number | #ParamRef)
		"left"?:                        (number | #ParamRef)
}, "inset"?: (number | #ParamRef), "style"?: (string | #CSSStyles | null | #ParamRef), "align"?: (number | #ParamRef), "padding"?: (number | #ParamRef), "axis"?: ("top" | "right" | "bottom" | "left" | "both" | bool | null | #ParamRef), "grid"?: (bool | string | #ParamRef), "ariaLabel"?: (string | null), "ariaDescription"?: (string | null), "clip"?: ("frame" | "sphere" | bool | null | #ParamRef), "xScale"?: (#PositionScaleType | null | #ParamRef), "xDomain"?: ([...] | #Fixed | #ParamRef), "xRange"?: ([...] | #Fixed | #ParamRef), "xNice"?: (bool | number | #Interval | #ParamRef), "xInset"?: (number | #ParamRef), "xInsetRight"?: (number | #ParamRef), "xInsetLeft"?: (number | #ParamRef), "xClamp"?: (bool | #ParamRef), "xRound"?: (bool | #ParamRef), "xAlign"?: (number | #ParamRef), "xPadding"?: (number | #ParamRef), "xPaddingInner"?: (number | #ParamRef), "xPaddingOuter"?: (number | #ParamRef), "xAxis"?: ("top" | "bottom" | "both" | bool | null | #ParamRef), "xTicks"?: (number | #Interval | [...] | #ParamRef), "xTickSize"?: (number | #ParamRef), "xTickSpacing"?: (number | #ParamRef), "xTickPadding"?: (number | #ParamRef), "xTickFormat"?: (string | null | #ParamRef), "xTickRotate"?: (number | #ParamRef), "xGrid"?: (bool | string | #Interval | [...] | #ParamRef), "xLine"?: (bool | #ParamRef), "xLabel"?: (string | null | #ParamRef), "xLabelAnchor"?: ("top" | "right" | "bottom" | "left" | "center" | #ParamRef), "xLabelArrow"?: (#LabelArrow | #ParamRef), "xLabelOffset"?: (number | #ParamRef), "xFontVariant"?: (string | #ParamRef), "xAriaLabel"?: (string | #ParamRef), "xAriaDescription"?: (string | #ParamRef), "xPercent"?: (bool | #ParamRef), "xReverse"?: (bool | #ParamRef), "xZero"?: (bool | #ParamRef), "xExponent"?: (number | #ParamRef), "xBase"?: (number | #ParamRef), "xConstant"?: (number | #ParamRef), "yScale"?: (#PositionScaleType | null | #ParamRef), "yDomain"?: ([...] | #Fixed | #ParamRef), "yRange"?: ([...] | #Fixed | #ParamRef), "yNice"?: (bool | number | #Interval | #ParamRef), "yInset"?: (number | #ParamRef), "yInsetTop"?: (number | #ParamRef), "yInsetBottom"?: (number | #ParamRef), "yClamp"?: (bool | #ParamRef), "yRound"?: (bool | #ParamRef), "yAlign"?: (number | #ParamRef), "yPadding"?: (number | #ParamRef), "yPaddingInner"?: (number | #ParamRef), "yPaddingOuter"?: (number | #ParamRef), "yAxis"?: ("left" | "right" | "both" | bool | null | #ParamRef), "yTicks"?: (number | #Interval | [...] | #ParamRef), "yTickSize"?: (number | #ParamRef), "yTickSpacing"?: (number | #ParamRef), "yTickPadding"?: (number | #ParamRef), "yTickFormat"?: (string | null | #ParamRef), "yTickRotate"?: (number | #ParamRef), "yGrid"?: (bool | string | #Interval | [...] | #ParamRef), "yLine"?: (bool | #ParamRef), "yLabel"?: (string | null | #ParamRef), "yLabelAnchor"?: ("top" | "right" | "bottom" | "left" | "center" | #ParamRef), "yLabelArrow"?: (#LabelArrow | #ParamRef), "yLabelOffset"?: (number | #ParamRef), "yFontVariant"?: (string | #ParamRef), "yAriaLabel"?: (string | #ParamRef), "yAriaDescription"?: (string | #ParamRef), "yPercent"?: (bool | #ParamRef), "yReverse"?: (bool | #ParamRef), "yZero"?: (bool | #ParamRef), "yExponent"?: (number | #ParamRef), "yBase"?: (number | #ParamRef), "yConstant"?: (number | #ParamRef), "xyDomain"?: ([...] | #Fixed | #ParamRef), "colorScale"?: (#ColorScaleType | null | #ParamRef), "colorDomain"?: ([...] | #Fixed | #ParamRef), "colorRange"?: ([...] | #Fixed | #ParamRef), "colorClamp"?: (bool | #ParamRef), "colorN"?: (number | #ParamRef), "colorNice"?: (bool | number | #Interval | #ParamRef), "colorScheme"?: (#ColorScheme | #ParamRef), "colorInterpolate"?: (#Interpolate | #ParamRef), "colorPivot"?: (_ | #ParamRef), "colorSymmetric"?: (bool | #ParamRef), "colorLabel"?: (string | null | #ParamRef), "colorPercent"?: (bool | #ParamRef), "colorReverse"?: (bool | #ParamRef), "colorZero"?: (bool | #ParamRef), "colorTickFormat"?: (string | null | #ParamRef), "colorExponent"?: (number | #ParamRef), "colorBase"?: (number | #ParamRef), "colorConstant"?: (number | #ParamRef), "opacityScale"?: (#ContinuousScaleType | null | #ParamRef), "opacityDomain"?: ([...] | #Fixed | #ParamRef), "opacityRange"?: ([...] | #Fixed | #ParamRef), "opacityClamp"?: (bool | #ParamRef), "opacityNice"?: (bool | number | #Interval | #ParamRef), "opacityLabel"?: (string | null | #ParamRef), "opacityPercent"?: (bool | #ParamRef), "opacityReverse"?: (bool | #ParamRef), "opacityZero"?: (bool | #ParamRef), "opacityTickFormat"?: (string | null | #ParamRef), "opacityExponent"?: (number | #ParamRef), "opacityBase"?: (number | #ParamRef), "opacityConstant"?: (number | #ParamRef), "symbolScale"?: (#DiscreteScaleType | null | #ParamRef), "symbolDomain"?: ([...] | #Fixed | #ParamRef), "symbolRange"?: ([...] | #Fixed | #ParamRef), "rScale"?: (#ContinuousScaleType | null | #ParamRef), "rDomain"?: ([...] | #Fixed | #ParamRef), "rRange"?: ([...] | #Fixed | #ParamRef), "rClamp"?: _, "rNice"?: (bool | number | #Interval | #ParamRef), "rLabel"?: (string | null | #ParamRef), "rPercent"?: (bool | #ParamRef), "rZero"?: (bool | #ParamRef), "rExponent"?: (number | #ParamRef), "rBase"?: (number | #ParamRef), "rConstant"?: (number | #ParamRef), "lengthScale"?: (#ContinuousScaleType | null | #ParamRef), "lengthDomain"?: ([...] | #Fixed | #ParamRef), "lengthRange"?: ([...] | #Fixed | #ParamRef), "lengthClamp"?: _, "lengthNice"?: (bool | number | #Interval | #ParamRef), "lengthPercent"?: (bool | #ParamRef), "lengthZero"?: (bool | #ParamRef), "lengthExponent"?: (number | #ParamRef), "lengthBase"?: (number | #ParamRef), "lengthConstant"?: (number | #ParamRef), "projectionType"?: (#ProjectionName | null | #ParamRef), "projectionDomain"?: ({...} | #ParamRef), "projectionRotate"?: ([(number | #ParamRef), (number | #ParamRef), (number | #ParamRef)] | #ParamRef), "projectionParallels"?: ([(number | #ParamRef), (number | #ParamRef)] | #ParamRef), "projectionPrecision"?: (number | #ParamRef), "projectionClip"?: (bool | number | "frame" | null | #ParamRef), "projectionInset"?: (number | #ParamRef), "projectionInsetTop"?: (number | #ParamRef), "projectionInsetRight"?: (number | #ParamRef), "projectionInsetBottom"?: (number | #ParamRef), "projectionInsetLeft"?: (number | #ParamRef), "facetMargin"?: (number | #ParamRef), "facetMarginTop"?: (number | #ParamRef), "facetMarginBottom"?: (number | #ParamRef), "facetMarginLeft"?: (number | #ParamRef), "facetMarginRight"?: (number | #ParamRef), "facetGrid"?: (bool | string | #Interval | [...] | #ParamRef), "facetLabel"?: (string | null | #ParamRef), "fxDomain"?: ([...] | #Fixed | #ParamRef), "fxRange"?: ([...] | #Fixed | #ParamRef), "fxInset"?: (number | #ParamRef), "fxInsetRight"?: (number | #ParamRef), "fxInsetLeft"?: (number | #ParamRef), "fxRound"?: (bool | #ParamRef), "fxAlign"?: (number | #ParamRef), "fxPadding"?: (number | #ParamRef), "fxPaddingInner"?: (number | #ParamRef), "fxPaddingOuter"?: (number | #ParamRef), "fxAxis"?: ("top" | "bottom" | "both" | bool | null | #ParamRef), "fxTicks"?: (number | #Interval | [...] | #ParamRef), "fxTickSize"?: (number | #ParamRef), "fxTickSpacing"?: (number | #ParamRef), "fxTickPadding"?: (number | #ParamRef), "fxTickFormat"?: (string | null | #ParamRef), "fxTickRotate"?: (number | #ParamRef), "fxGrid"?: (bool | string | #Interval | [...] | #ParamRef), "fxLine"?: (bool | #ParamRef), "fxLabel"?: (string | null | #ParamRef), "fxLabelAnchor"?: ("top" | "right" | "bottom" | "left" | "center" | #ParamRef), "fxLabelOffset"?: (number | #ParamRef), "fxFontVariant"?: (string | #ParamRef), "fxAriaLabel"?: (string | #ParamRef), "fxAriaDescription"?: (string | #ParamRef), "fxReverse"?: (bool | #ParamRef), "fyDomain"?: ([...] | #Fixed | #ParamRef), "fyRange"?: ([...] | #Fixed | #ParamRef), "fyInset"?: (number | #ParamRef), "fyInsetTop"?: (number | #ParamRef), "fyInsetBottom"?: (number | #ParamRef), "fyRound"?: (bool | #ParamRef), "fyAlign"?: (number | #ParamRef), "fyPadding"?: (number | #ParamRef), "fyPaddingInner"?: (number | #ParamRef), "fyPaddingOuter"?: (number | #ParamRef), "fyAxis"?: ("left" | "right" | "both" | bool | null | #ParamRef), "fyTicks"?: (number | #Interval | [...] | #ParamRef), "fyTickSize"?: (number | #ParamRef), "fyTickSpacing"?: (number | #ParamRef), "fyTickPadding"?: (number | #ParamRef), "fyTickFormat"?: (string | null | #ParamRef), "fyTickRotate"?: (number | #ParamRef), "fyGrid"?: (bool | string | #Interval | [...] | #ParamRef), "fyLine"?: (bool | #ParamRef), "fyLabel"?: (string | null | #ParamRef), "fyLabelAnchor"?: ("top" | "right" | "bottom" | "left" | "center" | #ParamRef), "fyLabelOffset"?: (number | #ParamRef), "fyFontVariant"?: (string | #ParamRef), "fyAriaLabel"?: (string | #ParamRef), "fyAriaDescription"?: (string | #ParamRef), "fyReverse"?: (bool | #ParamRef)
}

#Spec: matchN(>=1, [#Admission_Spec_0, #Admission_Spec_1, #Admission_Spec_2, #Admission_Spec_3, #Admission_Spec_4, #Admission_Spec_5, #Admission_Spec_6, #Admission_Spec_7, #Admission_Spec_8, #Admission_Spec_9])

#SpecComponent: matchN(>=1, [#HConcat, #VConcat, #HSpace, #VSpace, #Menu, #Search, #Slider, #Table, #Plot, #Legend])

#Component: matchN(>=1, [#SpecComponent, #PlotMark])

#PlotMark: matchN(>=1, [#Area, #AreaX, #AreaY, #Arrow, #AxisX, #AxisY, #AxisFx, #AxisFy, #GridX, #GridY, #GridFx, #GridFy, #BarX, #BarY, #Cell, #CellX, #CellY, #Contour, #DelaunayLink, #DelaunayMesh, #Hull, #Voronoi, #VoronoiMesh, #DenseLine, #Density, #DensityX, #DensityY, #Dot, #DotX, #DotY, #Circle, #Hexagon, #ErrorBarX, #ErrorBarY, #Frame, #Geo, #Graticule, #Sphere, #Hexbin, #Hexgrid, #Image, #Line, #LineX, #LineY, #Link, #Raster, #Heatmap, #RasterTile, #Rect, #RectX, #RectY, #RegressionY, #RuleX, #RuleY, #Text, #TextX, #TextY, #TickX, #TickY, #Vector, #VectorX, #VectorY, #Spike, #WaffleX, #WaffleY])

#PlotInteractor: matchN(>=1, [#Highlight, #IntervalX, #IntervalY, #IntervalXY, #Nearest, #NearestX, #NearestY, #Pan, #PanX, #PanY, #PanZoom, #PanZoomX, #PanZoomY, #Region, #Toggle, #ToggleX, #ToggleY, #ToggleColor, #ToggleZ])

#ColumnTransform: matchN(>=1, [#Bin, #Column, #DateMonth, #DateMonthDay, #DateDay, #Centroid, #CentroidX, #CentroidY, #GeoJSON])

#AggregateTransform: matchN(>=1, [#Argmax, #Argmin, #Avg, #Count, #Max, #Min, #First, #Last, #Median, #Mode, #Product, #Quantile, #Stddev, #StddevPop, #Sum, #Variance, #VarPop])

#WindowTransform: matchN(>=1, [#RowNumber, #Rank, #DenseRank, #PercentRank, #CumeDist, #NTile, #Lag, #Lead, #FirstValue, #LastValue, #NthValue])

#Transform: matchN(>=1, [#ColumnTransform, #AggregateTransform, #WindowTransform])

#Admission_Spec_0: {"hconcat"!: [...#Component], "$schema"?: net.AbsURL, "meta"?: #Meta, "config"?: #Config, "data"?: #Data, "params"?: #Params, "plotDefaults"?: #PlotAttributes}

#Admission_Spec_1: {"vconcat"!: [...#Component], "$schema"?: net.AbsURL, "meta"?: #Meta, "config"?: #Config, "data"?: #Data, "params"?: #Params, "plotDefaults"?: #PlotAttributes}

#Admission_Spec_2: {"hspace"!: (number | string), "$schema"?: net.AbsURL, "meta"?: #Meta, "config"?: #Config, "data"?: #Data, "params"?: #Params, "plotDefaults"?: #PlotAttributes}

#Admission_Spec_3: {"vspace"!: (number | string), "$schema"?: net.AbsURL, "meta"?: #Meta, "config"?: #Config, "data"?: #Data, "params"?: #Params, "plotDefaults"?: #PlotAttributes}

#Admission_Spec_4: {"input"!: "menu", "as"?: #ParamRef, "field"?: string, "from"?: string, "column"?: string, "listMatch"?: "any" | "all", "filterBy"?: #ParamRef, "label"?: string, "options"?: [...(_ | {"value"!: _, "label"?: string})], "value"?: _, "$schema"?: net.AbsURL, "meta"?: #Meta, "config"?: #Config, "data"?: #Data, "params"?: #Params, "plotDefaults"?: #PlotAttributes}

#Admission_Spec_5: {"input"!: "search", "as"?: #ParamRef, "field"?: string, "type"?: "contains" | "prefix" | "suffix" | "regexp", "from"?: string, "column"?: string, "filterBy"?: #ParamRef, "label"?: string, "$schema"?: net.AbsURL, "meta"?: #Meta, "config"?: #Config, "data"?: #Data, "params"?: #Params, "plotDefaults"?: #PlotAttributes}

#Admission_Spec_6: {"input"!: "slider", "as"?: #ParamRef, "field"?: string, "select"?: "point" | "interval", "from"?: string, "column"?: string, "filterBy"?: #ParamRef, "min"?: number, "max"?: number, "step"?: number, "label"?: string, "value"?: number, "width"?: number, "$schema"?: net.AbsURL, "meta"?: #Meta, "config"?: #Config, "data"?: #Data, "params"?: #Params, "plotDefaults"?: #PlotAttributes}

#Admission_Spec_7: {"input"!: "table", "as"?: #ParamRef, "from"!: (string | #ParamRef), "columns"?: [...string], "filterBy"?: #ParamRef, "align"?: {[string]: "left" | "right" | "center" | "justify"}, "width"?: (number | {[string]: number}), "maxWidth"?: number, "height"?: number, "rowBatch"?: number, "$schema"?: net.AbsURL, "meta"?: #Meta, "config"?: #Config, "data"?: #Data, "params"?: #Params, "plotDefaults"?: #PlotAttributes}

#Admission_Spec_8: {"name"?: string, "width"?: (number | #ParamRef), "height"?: (number | #ParamRef), "aspectRatio"?: (number | bool | null | #ParamRef), "margin"?: (number | #ParamRef), "marginTop"?: (number | #ParamRef), "marginRight"?: (number | #ParamRef), "marginBottom"?: (number | #ParamRef), "marginLeft"?: (number | #ParamRef), "margins"?: {
		"top"?:                         (number | #ParamRef)
		"right"?:                       (number | #ParamRef)
		"bottom"?:                      (number | #ParamRef)
		"left"?:                        (number | #ParamRef)
}, "inset"?: (number | #ParamRef), "style"?: (string | #CSSStyles | null | #ParamRef), "align"?: (number | #ParamRef), "padding"?: (number | #ParamRef), "axis"?: ("top" | "right" | "bottom" | "left" | "both" | bool | null | #ParamRef), "grid"?: (bool | string | #ParamRef), "ariaLabel"?: (string | null), "ariaDescription"?: (string | null), "clip"?: ("frame" | "sphere" | bool | null | #ParamRef), "xScale"?: (#PositionScaleType | null | #ParamRef), "xDomain"?: ([...] | #Fixed | #ParamRef), "xRange"?: ([...] | #Fixed | #ParamRef), "xNice"?: (bool | number | #Interval | #ParamRef), "xInset"?: (number | #ParamRef), "xInsetRight"?: (number | #ParamRef), "xInsetLeft"?: (number | #ParamRef), "xClamp"?: (bool | #ParamRef), "xRound"?: (bool | #ParamRef), "xAlign"?: (number | #ParamRef), "xPadding"?: (number | #ParamRef), "xPaddingInner"?: (number | #ParamRef), "xPaddingOuter"?: (number | #ParamRef), "xAxis"?: ("top" | "bottom" | "both" | bool | null | #ParamRef), "xTicks"?: (number | #Interval | [...] | #ParamRef), "xTickSize"?: (number | #ParamRef), "xTickSpacing"?: (number | #ParamRef), "xTickPadding"?: (number | #ParamRef), "xTickFormat"?: (string | null | #ParamRef), "xTickRotate"?: (number | #ParamRef), "xGrid"?: (bool | string | #Interval | [...] | #ParamRef), "xLine"?: (bool | #ParamRef), "xLabel"?: (string | null | #ParamRef), "xLabelAnchor"?: ("top" | "right" | "bottom" | "left" | "center" | #ParamRef), "xLabelArrow"?: (#LabelArrow | #ParamRef), "xLabelOffset"?: (number | #ParamRef), "xFontVariant"?: (string | #ParamRef), "xAriaLabel"?: (string | #ParamRef), "xAriaDescription"?: (string | #ParamRef), "xPercent"?: (bool | #ParamRef), "xReverse"?: (bool | #ParamRef), "xZero"?: (bool | #ParamRef), "xExponent"?: (number | #ParamRef), "xBase"?: (number | #ParamRef), "xConstant"?: (number | #ParamRef), "yScale"?: (#PositionScaleType | null | #ParamRef), "yDomain"?: ([...] | #Fixed | #ParamRef), "yRange"?: ([...] | #Fixed | #ParamRef), "yNice"?: (bool | number | #Interval | #ParamRef), "yInset"?: (number | #ParamRef), "yInsetTop"?: (number | #ParamRef), "yInsetBottom"?: (number | #ParamRef), "yClamp"?: (bool | #ParamRef), "yRound"?: (bool | #ParamRef), "yAlign"?: (number | #ParamRef), "yPadding"?: (number | #ParamRef), "yPaddingInner"?: (number | #ParamRef), "yPaddingOuter"?: (number | #ParamRef), "yAxis"?: ("left" | "right" | "both" | bool | null | #ParamRef), "yTicks"?: (number | #Interval | [...] | #ParamRef), "yTickSize"?: (number | #ParamRef), "yTickSpacing"?: (number | #ParamRef), "yTickPadding"?: (number | #ParamRef), "yTickFormat"?: (string | null | #ParamRef), "yTickRotate"?: (number | #ParamRef), "yGrid"?: (bool | string | #Interval | [...] | #ParamRef), "yLine"?: (bool | #ParamRef), "yLabel"?: (string | null | #ParamRef), "yLabelAnchor"?: ("top" | "right" | "bottom" | "left" | "center" | #ParamRef), "yLabelArrow"?: (#LabelArrow | #ParamRef), "yLabelOffset"?: (number | #ParamRef), "yFontVariant"?: (string | #ParamRef), "yAriaLabel"?: (string | #ParamRef), "yAriaDescription"?: (string | #ParamRef), "yPercent"?: (bool | #ParamRef), "yReverse"?: (bool | #ParamRef), "yZero"?: (bool | #ParamRef), "yExponent"?: (number | #ParamRef), "yBase"?: (number | #ParamRef), "yConstant"?: (number | #ParamRef), "xyDomain"?: ([...] | #Fixed | #ParamRef), "colorScale"?: (#ColorScaleType | null | #ParamRef), "colorDomain"?: ([...] | #Fixed | #ParamRef), "colorRange"?: ([...] | #Fixed | #ParamRef), "colorClamp"?: (bool | #ParamRef), "colorN"?: (number | #ParamRef), "colorNice"?: (bool | number | #Interval | #ParamRef), "colorScheme"?: (#ColorScheme | #ParamRef), "colorInterpolate"?: (#Interpolate | #ParamRef), "colorPivot"?: (_ | #ParamRef), "colorSymmetric"?: (bool | #ParamRef), "colorLabel"?: (string | null | #ParamRef), "colorPercent"?: (bool | #ParamRef), "colorReverse"?: (bool | #ParamRef), "colorZero"?: (bool | #ParamRef), "colorTickFormat"?: (string | null | #ParamRef), "colorExponent"?: (number | #ParamRef), "colorBase"?: (number | #ParamRef), "colorConstant"?: (number | #ParamRef), "opacityScale"?: (#ContinuousScaleType | null | #ParamRef), "opacityDomain"?: ([...] | #Fixed | #ParamRef), "opacityRange"?: ([...] | #Fixed | #ParamRef), "opacityClamp"?: (bool | #ParamRef), "opacityNice"?: (bool | number | #Interval | #ParamRef), "opacityLabel"?: (string | null | #ParamRef), "opacityPercent"?: (bool | #ParamRef), "opacityReverse"?: (bool | #ParamRef), "opacityZero"?: (bool | #ParamRef), "opacityTickFormat"?: (string | null | #ParamRef), "opacityExponent"?: (number | #ParamRef), "opacityBase"?: (number | #ParamRef), "opacityConstant"?: (number | #ParamRef), "symbolScale"?: (#DiscreteScaleType | null | #ParamRef), "symbolDomain"?: ([...] | #Fixed | #ParamRef), "symbolRange"?: ([...] | #Fixed | #ParamRef), "rScale"?: (#ContinuousScaleType | null | #ParamRef), "rDomain"?: ([...] | #Fixed | #ParamRef), "rRange"?: ([...] | #Fixed | #ParamRef), "rClamp"?: _, "rNice"?: (bool | number | #Interval | #ParamRef), "rLabel"?: (string | null | #ParamRef), "rPercent"?: (bool | #ParamRef), "rZero"?: (bool | #ParamRef), "rExponent"?: (number | #ParamRef), "rBase"?: (number | #ParamRef), "rConstant"?: (number | #ParamRef), "lengthScale"?: (#ContinuousScaleType | null | #ParamRef), "lengthDomain"?: ([...] | #Fixed | #ParamRef), "lengthRange"?: ([...] | #Fixed | #ParamRef), "lengthClamp"?: _, "lengthNice"?: (bool | number | #Interval | #ParamRef), "lengthPercent"?: (bool | #ParamRef), "lengthZero"?: (bool | #ParamRef), "lengthExponent"?: (number | #ParamRef), "lengthBase"?: (number | #ParamRef), "lengthConstant"?: (number | #ParamRef), "projectionType"?: (#ProjectionName | null | #ParamRef), "projectionDomain"?: ({...} | #ParamRef), "projectionRotate"?: ([(number | #ParamRef), (number | #ParamRef), (number | #ParamRef)] | #ParamRef), "projectionParallels"?: ([(number | #ParamRef), (number | #ParamRef)] | #ParamRef), "projectionPrecision"?: (number | #ParamRef), "projectionClip"?: (bool | number | "frame" | null | #ParamRef), "projectionInset"?: (number | #ParamRef), "projectionInsetTop"?: (number | #ParamRef), "projectionInsetRight"?: (number | #ParamRef), "projectionInsetBottom"?: (number | #ParamRef), "projectionInsetLeft"?: (number | #ParamRef), "facetMargin"?: (number | #ParamRef), "facetMarginTop"?: (number | #ParamRef), "facetMarginBottom"?: (number | #ParamRef), "facetMarginLeft"?: (number | #ParamRef), "facetMarginRight"?: (number | #ParamRef), "facetGrid"?: (bool | string | #Interval | [...] | #ParamRef), "facetLabel"?: (string | null | #ParamRef), "fxDomain"?: ([...] | #Fixed | #ParamRef), "fxRange"?: ([...] | #Fixed | #ParamRef), "fxInset"?: (number | #ParamRef), "fxInsetRight"?: (number | #ParamRef), "fxInsetLeft"?: (number | #ParamRef), "fxRound"?: (bool | #ParamRef), "fxAlign"?: (number | #ParamRef), "fxPadding"?: (number | #ParamRef), "fxPaddingInner"?: (number | #ParamRef), "fxPaddingOuter"?: (number | #ParamRef), "fxAxis"?: ("top" | "bottom" | "both" | bool | null | #ParamRef), "fxTicks"?: (number | #Interval | [...] | #ParamRef), "fxTickSize"?: (number | #ParamRef), "fxTickSpacing"?: (number | #ParamRef), "fxTickPadding"?: (number | #ParamRef), "fxTickFormat"?: (string | null | #ParamRef), "fxTickRotate"?: (number | #ParamRef), "fxGrid"?: (bool | string | #Interval | [...] | #ParamRef), "fxLine"?: (bool | #ParamRef), "fxLabel"?: (string | null | #ParamRef), "fxLabelAnchor"?: ("top" | "right" | "bottom" | "left" | "center" | #ParamRef), "fxLabelOffset"?: (number | #ParamRef), "fxFontVariant"?: (string | #ParamRef), "fxAriaLabel"?: (string | #ParamRef), "fxAriaDescription"?: (string | #ParamRef), "fxReverse"?: (bool | #ParamRef), "fyDomain"?: ([...] | #Fixed | #ParamRef), "fyRange"?: ([...] | #Fixed | #ParamRef), "fyInset"?: (number | #ParamRef), "fyInsetTop"?: (number | #ParamRef), "fyInsetBottom"?: (number | #ParamRef), "fyRound"?: (bool | #ParamRef), "fyAlign"?: (number | #ParamRef), "fyPadding"?: (number | #ParamRef), "fyPaddingInner"?: (number | #ParamRef), "fyPaddingOuter"?: (number | #ParamRef), "fyAxis"?: ("left" | "right" | "both" | bool | null | #ParamRef), "fyTicks"?: (number | #Interval | [...] | #ParamRef), "fyTickSize"?: (number | #ParamRef), "fyTickSpacing"?: (number | #ParamRef), "fyTickPadding"?: (number | #ParamRef), "fyTickFormat"?: (string | null | #ParamRef), "fyTickRotate"?: (number | #ParamRef), "fyGrid"?: (bool | string | #Interval | [...] | #ParamRef), "fyLine"?: (bool | #ParamRef), "fyLabel"?: (string | null | #ParamRef), "fyLabelAnchor"?: ("top" | "right" | "bottom" | "left" | "center" | #ParamRef), "fyLabelOffset"?: (number | #ParamRef), "fyFontVariant"?: (string | #ParamRef), "fyAriaLabel"?: (string | #ParamRef), "fyAriaDescription"?: (string | #ParamRef), "fyReverse"?: (bool | #ParamRef), "plot"!: [...(#PlotMark | #PlotInteractor | #PlotLegend)], "$schema"?: net.AbsURL, "meta"?: #Meta, "config"?: #Config, "data"?: #Data, "params"?: #Params, "plotDefaults"?: #PlotAttributes
}

#Admission_Spec_9: {"legend"!: ("color" | "opacity" | "symbol"), "as"?: #ParamRef, "field"?: string, "label"?: string, "tickSize"?: number, "marginTop"?: number, "marginRight"?: number, "marginBottom"?: number, "marginLeft"?: number, "width"?: number, "height"?: number, "columns"?: number, "for"!: string, "$schema"?: net.AbsURL, "meta"?: #Meta, "config"?: #Config, "data"?: #Data, "params"?: #Params, "plotDefaults"?: #PlotAttributes}

#PanZoomOptions: {
	"x"?:      #ParamRef
	"y"?:      #ParamRef
	"xfield"?: string
	"yfield"?: string
}

#Pan: {
	"x"?:      #ParamRef
	"y"?:      #ParamRef
	"xfield"?: string
	"yfield"?: string
	"select"!: "pan"
}

#PanX: {
	"x"?:      #ParamRef
	"y"?:      #ParamRef
	"xfield"?: string
	"yfield"?: string
	"select"!: "panX"
}

#PanY: {
	"x"?:      #ParamRef
	"y"?:      #ParamRef
	"xfield"?: string
	"yfield"?: string
	"select"!: "panY"
}

#PanZoom: {
	"x"?:      #ParamRef
	"y"?:      #ParamRef
	"xfield"?: string
	"yfield"?: string
	"select"!: "panZoom"
}

#PanZoomX: {
	"x"?:      #ParamRef
	"y"?:      #ParamRef
	"xfield"?: string
	"yfield"?: string
	"select"!: "panZoomX"
}

#PanZoomY: {
	"x"?:      #ParamRef
	"y"?:      #ParamRef
	"xfield"?: string
	"yfield"?: string
	"select"!: "panZoomY"
}

#ToggleOptions: {
	"as"!:    #ParamRef
	"peers"?: bool
}

#Toggle: {
	"as"!:     #ParamRef
	"peers"?:  bool
	"select"!: "toggle"
	"channels"!: [...string]
}

#ToggleX: {
	"as"!:     #ParamRef
	"peers"?:  bool
	"select"!: "toggleX"
}

#ToggleY: {
	"as"!:     #ParamRef
	"peers"?:  bool
	"select"!: "toggleY"
}

#ToggleZ: {
	"as"!:     #ParamRef
	"peers"?:  bool
	"select"!: "toggleZ"
}

#ToggleColor: {
	"as"!:     #ParamRef
	"peers"?:  bool
	"select"!: "toggleColor"
}

#NearestOptions: {
	"as"!: #ParamRef
	"channels"?: [...string]
	"fields"?: [...string]
	"maxRadius"?: number
}

#Nearest: {
	"as"!: #ParamRef
	"channels"?: [...string]
	"fields"?: [...string]
	"maxRadius"?: number
	"select"!:    "nearest"
}

#NearestX: {
	"as"!: #ParamRef
	"channels"?: [...string]
	"fields"?: [...string]
	"maxRadius"?: number
	"select"!:    "nearestX"
}

#NearestY: {
	"as"!: #ParamRef
	"channels"?: [...string]
	"fields"?: [...string]
	"maxRadius"?: number
	"select"!:    "nearestY"
}

#Highlight: {
	"select"!:        "highlight"
	"by"!:            #ParamRef
	"opacity"?:       number
	"fillOpacity"?:   number
	"strokeOpacity"?: number
	"fill"?:          string
	"stroke"?:        string
}

#BrushStyles: {
	"opacity"?:         number
	"fillOpacity"?:     number
	"strokeOpacity"?:   number
	"fill"?:            string
	"stroke"?:          string
	"strokeDasharray"?: string
}

#Interval1DOptions: {
	"as"!:        #ParamRef
	"field"?:     string
	"pixelSize"?: number
	"peers"?:     bool
	"brush"?:     #BrushStyles
}

#IntervalX: {
	"as"!:        #ParamRef
	"field"?:     string
	"pixelSize"?: number
	"peers"?:     bool
	"brush"?:     #BrushStyles
	"select"!:    "intervalX"
}

#IntervalY: {
	"as"!:        #ParamRef
	"field"?:     string
	"pixelSize"?: number
	"peers"?:     bool
	"brush"?:     #BrushStyles
	"select"!:    "intervalY"
}

#Interval2DOptions: {
	"as"!:        #ParamRef
	"xfield"?:    string
	"yfield"?:    string
	"pixelSize"?: number
	"peers"?:     bool
	"brush"?:     #BrushStyles
}

#IntervalXY: {
	"as"!:        #ParamRef
	"xfield"?:    string
	"yfield"?:    string
	"pixelSize"?: number
	"peers"?:     bool
	"brush"?:     #BrushStyles
	"select"!:    "intervalXY"
}

#RegionOptions: {
	"as"!: #ParamRef
	"channels"!: [...string]
	"peers"?: bool
	"brush"?: #BrushStyles
}

#Region: {
	"as"!: #ParamRef
	"channels"!: [...string]
	"peers"?:  bool
	"brush"?:  #BrushStyles
	"select"!: "region"
}

#HexbinOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"z"?:                #ChannelValue
	"r"?:                (#ChannelValueSpec | number | #ParamRef)
	"rotate"?:           (#ChannelValue | number | #ParamRef)
	"symbol"?:           (#ChannelValueSpec | #SymbolType | #ParamRef)
	"frameAnchor"?:      (#FrameAnchor | #ParamRef)
	"textAnchor"?:       ("start" | "middle" | "end" | #ParamRef)
	"lineHeight"?:       (number | #ParamRef)
	"lineWidth"?:        (number | #ParamRef)
	"textOverflow"?:     (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef)
	"monospace"?:        (bool | #ParamRef)
	"fontFamily"?:       (string | #ParamRef)
	"fontSize"?:         (#ChannelValue | #ParamRef)
	"fontStyle"?:        (string | #ParamRef)
	"fontVariant"?:      (string | #ParamRef)
	"fontWeight"?:       (string | number | #ParamRef)
	"type"?:             ("dot" | "circle" | "hexagon" | "text" | #ParamRef)
	"binWidth"?:         (number | #ParamRef)
}

#Hexbin: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"z"?:                #ChannelValue
	"r"?:                (#ChannelValueSpec | number | #ParamRef)
	"rotate"?:           (#ChannelValue | number | #ParamRef)
	"symbol"?:           (#ChannelValueSpec | #SymbolType | #ParamRef)
	"frameAnchor"?:      (#FrameAnchor | #ParamRef)
	"textAnchor"?:       ("start" | "middle" | "end" | #ParamRef)
	"lineHeight"?:       (number | #ParamRef)
	"lineWidth"?:        (number | #ParamRef)
	"textOverflow"?:     (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef)
	"monospace"?:        (bool | #ParamRef)
	"fontFamily"?:       (string | #ParamRef)
	"fontSize"?:         (#ChannelValue | #ParamRef)
	"fontStyle"?:        (string | #ParamRef)
	"fontVariant"?:      (string | #ParamRef)
	"fontWeight"?:       (string | number | #ParamRef)
	"type"?:             ("dot" | "circle" | "hexagon" | "text" | #ParamRef)
	"binWidth"?:         (number | #ParamRef)
	"mark"!:             "hexbin"
}

#RegressionOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"ci"?:               (number | #ParamRef)
	"precision"?:        (number | #ParamRef)
	"z"?:                #ChannelValue
}

#RegressionYOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"ci"?:               (number | #ParamRef)
	"precision"?:        (number | #ParamRef)
	"z"?:                #ChannelValue
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
}

#RegressionY: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"ci"?:               (number | #ParamRef)
	"precision"?:        (number | #ParamRef)
	"z"?:                #ChannelValue
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"mark"!:             "regressionY"
}

#ErrorBarOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"marker"?:           (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:      (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"ci"?:               (number | #ParamRef)
	"z"?:                #ChannelValue
}

#ErrorBarXOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"marker"?:           (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:      (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"ci"?:               (number | #ParamRef)
	"z"?:                #ChannelValue
	"x"!:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
}

#ErrorBarX: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"marker"?:           (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:      (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"ci"?:               (number | #ParamRef)
	"z"?:                #ChannelValue
	"x"!:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"mark"!:             "errorbarX"
}

#ErrorBarYOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"marker"?:           (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:      (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"ci"?:               (number | #ParamRef)
	"z"?:                #ChannelValue
	"x"?:                #ChannelValueSpec
	"y"!:                #ChannelValueSpec
}

#ErrorBarY: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"marker"?:           (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:      (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"ci"?:               (number | #ParamRef)
	"z"?:                #ChannelValue
	"x"?:                #ChannelValueSpec
	"y"!:                #ChannelValueSpec
	"mark"!:             "errorbarY"
}

#Grid2DOptions: {
	"x"?:           #ChannelValueSpec
	"y"?:           #ChannelValueSpec
	"width"?:       (number | #ParamRef)
	"height"?:      (number | #ParamRef)
	"pixelSize"?:   (number | #ParamRef)
	"pad"?:         (number | #ParamRef)
	"bandwidth"?:   (number | #ParamRef)
	"interpolate"?: (#GridInterpolate | null | #ParamRef)
}

#GridInterpolate: "none" | "linear" | "nearest" | "barycentric" | "random-walk"

#RasterOptions: {
	"x"?:               #ChannelValueSpec
	"y"?:               #ChannelValueSpec
	"width"?:           (number | #ParamRef)
	"height"?:          (number | #ParamRef)
	"pixelSize"?:       (number | #ParamRef)
	"pad"?:             (number | #ParamRef)
	"bandwidth"?:       (number | #ParamRef)
	"interpolate"?:     (#GridInterpolate | null | #ParamRef)
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"imageRendering"?:   (string | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
}

#Raster: {
	"data"!:            #PlotMarkData
	"x"?:               #ChannelValueSpec
	"y"?:               #ChannelValueSpec
	"width"?:           (number | #ParamRef)
	"height"?:          (number | #ParamRef)
	"pixelSize"?:       (number | #ParamRef)
	"pad"?:             (number | #ParamRef)
	"bandwidth"?:       (number | #ParamRef)
	"interpolate"?:     (#GridInterpolate | null | #ParamRef)
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"imageRendering"?:   (string | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"mark"!:             "raster"
}

#Heatmap: {
	"data"!:            #PlotMarkData
	"x"?:               #ChannelValueSpec
	"y"?:               #ChannelValueSpec
	"width"?:           (number | #ParamRef)
	"height"?:          (number | #ParamRef)
	"pixelSize"?:       (number | #ParamRef)
	"pad"?:             (number | #ParamRef)
	"bandwidth"?:       (number | #ParamRef)
	"interpolate"?:     (#GridInterpolate | null | #ParamRef)
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"imageRendering"?:   (string | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"mark"!:             "heatmap"
}

#RasterTile: {
	"data"!:            #PlotMarkData
	"x"?:               #ChannelValueSpec
	"y"?:               #ChannelValueSpec
	"width"?:           (number | #ParamRef)
	"height"?:          (number | #ParamRef)
	"pixelSize"?:       (number | #ParamRef)
	"pad"?:             (number | #ParamRef)
	"bandwidth"?:       (number | #ParamRef)
	"interpolate"?:     (#GridInterpolate | null | #ParamRef)
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"imageRendering"?:   (string | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"mark"!:             "rasterTile"
	"origin"?: ([number, number] | #ParamRef)
}

#ContourOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"width"?:            (number | #ParamRef)
	"height"?:           (number | #ParamRef)
	"pixelSize"?:        (number | #ParamRef)
	"pad"?:              (number | #ParamRef)
	"bandwidth"?:        (number | #ParamRef)
	"interpolate"?:      (#GridInterpolate | null | #ParamRef)
	"thresholds"?: (number | [...number] | #ParamRef)
}

#Contour: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"width"?:            (number | #ParamRef)
	"height"?:           (number | #ParamRef)
	"pixelSize"?:        (number | #ParamRef)
	"pad"?:              (number | #ParamRef)
	"bandwidth"?:        (number | #ParamRef)
	"interpolate"?:      (#GridInterpolate | null | #ParamRef)
	"thresholds"?: (number | [...number] | #ParamRef)
	"mark"!: "contour"
}

#DenseLineOptions: {
	"x"?:               #ChannelValueSpec
	"y"?:               #ChannelValueSpec
	"width"?:           (number | #ParamRef)
	"height"?:          (number | #ParamRef)
	"pixelSize"?:       (number | #ParamRef)
	"pad"?:             (number | #ParamRef)
	"bandwidth"?:       (number | #ParamRef)
	"interpolate"?:     (#GridInterpolate | null | #ParamRef)
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"imageRendering"?:   (string | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"normalize"?:        (bool | #ParamRef)
	"z"?:                #ChannelValue
}

#DenseLine: {
	"data"!:            #PlotMarkData
	"x"?:               #ChannelValueSpec
	"y"?:               #ChannelValueSpec
	"width"?:           (number | #ParamRef)
	"height"?:          (number | #ParamRef)
	"pixelSize"?:       (number | #ParamRef)
	"pad"?:             (number | #ParamRef)
	"bandwidth"?:       (number | #ParamRef)
	"interpolate"?:     (#GridInterpolate | null | #ParamRef)
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"imageRendering"?:   (string | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"normalize"?:        (bool | #ParamRef)
	"z"?:                #ChannelValue
	"mark"!:             "denseLine"
}

#Density2DOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"z"?:                #ChannelValue
	"r"?:                (#ChannelValueSpec | number | #ParamRef)
	"rotate"?:           (#ChannelValue | number | #ParamRef)
	"symbol"?:           (#ChannelValueSpec | #SymbolType | #ParamRef)
	"frameAnchor"?:      (#FrameAnchor | #ParamRef)
	"textAnchor"?:       ("start" | "middle" | "end" | #ParamRef)
	"lineHeight"?:       (number | #ParamRef)
	"lineWidth"?:        (number | #ParamRef)
	"textOverflow"?:     (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef)
	"monospace"?:        (bool | #ParamRef)
	"fontFamily"?:       (string | #ParamRef)
	"fontSize"?:         (#ChannelValue | #ParamRef)
	"fontStyle"?:        (string | #ParamRef)
	"fontVariant"?:      (string | #ParamRef)
	"fontWeight"?:       (string | number | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"width"?:            (number | #ParamRef)
	"height"?:           (number | #ParamRef)
	"pixelSize"?:        (number | #ParamRef)
	"pad"?:              (number | #ParamRef)
	"bandwidth"?:        (number | #ParamRef)
	"interpolate"?:      (#GridInterpolate | null | #ParamRef)
	"type"?:             ("dot" | "circle" | "hexagon" | "cell" | "text" | #ParamRef)
}

#Density: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"z"?:                #ChannelValue
	"r"?:                (#ChannelValueSpec | number | #ParamRef)
	"rotate"?:           (#ChannelValue | number | #ParamRef)
	"symbol"?:           (#ChannelValueSpec | #SymbolType | #ParamRef)
	"frameAnchor"?:      (#FrameAnchor | #ParamRef)
	"textAnchor"?:       ("start" | "middle" | "end" | #ParamRef)
	"lineHeight"?:       (number | #ParamRef)
	"lineWidth"?:        (number | #ParamRef)
	"textOverflow"?:     (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef)
	"monospace"?:        (bool | #ParamRef)
	"fontFamily"?:       (string | #ParamRef)
	"fontSize"?:         (#ChannelValue | #ParamRef)
	"fontStyle"?:        (string | #ParamRef)
	"fontVariant"?:      (string | #ParamRef)
	"fontWeight"?:       (string | number | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"width"?:            (number | #ParamRef)
	"height"?:           (number | #ParamRef)
	"pixelSize"?:        (number | #ParamRef)
	"pad"?:              (number | #ParamRef)
	"bandwidth"?:        (number | #ParamRef)
	"interpolate"?:      (#GridInterpolate | null | #ParamRef)
	"type"?:             ("dot" | "circle" | "hexagon" | "cell" | "text" | #ParamRef)
	"mark"!:             "density"
}

#Density1DOptions: {
	"bandwidth"?: (number | #ParamRef)
	"bins"?:      (number | #ParamRef)
	"normalize"?: (bool | "max" | "sum" | "none" | #ParamRef)
}

#DensityX: matchN(>=1, [#Admission_DensityX_0, #Admission_DensityX_1, #Admission_DensityX_2, #Admission_DensityX_3])

#DensityAreaXOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"offset"?:           (#StackOffset | null | #ParamRef)
	"order"?:            (#StackOrder | null | #ParamRef)
	"z"?:                #ChannelValue
	"curve"?:            (#Curve | #ParamRef)
	"tension"?:          (number | #ParamRef)
	"y"?:                #ChannelValueSpec
	"type"!:             "areaX"
	"stack"?:            (bool | #ParamRef)
}

#DensityY: matchN(>=1, [#Admission_DensityY_0, #Admission_DensityY_1, #Admission_DensityY_2, #Admission_DensityY_3])

#DensityAreaYOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"offset"?:           (#StackOffset | null | #ParamRef)
	"order"?:            (#StackOrder | null | #ParamRef)
	"z"?:                #ChannelValue
	"curve"?:            (#Curve | #ParamRef)
	"tension"?:          (number | #ParamRef)
	"x"?:                #ChannelValueSpec
	"type"?:             "areaY"
	"stack"?:            (bool | #ParamRef)
}

#DensityLineXOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"marker"?:           (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:      (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"curve"?:            (#Curve | "auto" | #ParamRef)
	"tension"?:          (number | #ParamRef)
	"y"?:                #ChannelValueSpec
	"z"?:                #ChannelValue
	"type"!:             "lineX"
}

#DensityLineYOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"marker"?:           (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:      (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"curve"?:            (#Curve | "auto" | #ParamRef)
	"tension"?:          (number | #ParamRef)
	"x"?:                #ChannelValueSpec
	"z"?:                #ChannelValue
	"type"!:             "lineY"
}

#DensityDotXOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"y"?:                #ChannelValueSpec
	"z"?:                #ChannelValue
	"r"?:                (#ChannelValueSpec | number | #ParamRef)
	"rotate"?:           (#ChannelValue | number | #ParamRef)
	"symbol"?:           (#ChannelValueSpec | #SymbolType | #ParamRef)
	"frameAnchor"?:      (#FrameAnchor | #ParamRef)
	"type"!:             "dotX"
}

#DensityDotYOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"x"?:                #ChannelValueSpec
	"z"?:                #ChannelValue
	"r"?:                (#ChannelValueSpec | number | #ParamRef)
	"rotate"?:           (#ChannelValue | number | #ParamRef)
	"symbol"?:           (#ChannelValueSpec | #SymbolType | #ParamRef)
	"frameAnchor"?:      (#FrameAnchor | #ParamRef)
	"type"!:             "dot" | "dotY" | "circle" | "hexagon"
}

#DensityTextXOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"textAnchor"?:       ("start" | "middle" | "end" | #ParamRef)
	"lineHeight"?:       (number | #ParamRef)
	"lineWidth"?:        (number | #ParamRef)
	"textOverflow"?:     (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef)
	"monospace"?:        (bool | #ParamRef)
	"fontFamily"?:       (string | #ParamRef)
	"fontSize"?:         (#ChannelValue | #ParamRef)
	"fontStyle"?:        (string | #ParamRef)
	"fontVariant"?:      (string | #ParamRef)
	"fontWeight"?:       (string | number | #ParamRef)
	"y"?:                #ChannelValueSpec
	"z"?:                #ChannelValue
	"text"?:             #ChannelValue
	"frameAnchor"?:      (#FrameAnchor | #ParamRef)
	"lineAnchor"?:       ("top" | "middle" | "bottom" | #ParamRef)
	"rotate"?:           (#ChannelValue | #ParamRef)
	"type"!:             "textX"
}

#DensityTextYOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"textAnchor"?:       ("start" | "middle" | "end" | #ParamRef)
	"lineHeight"?:       (number | #ParamRef)
	"lineWidth"?:        (number | #ParamRef)
	"textOverflow"?:     (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef)
	"monospace"?:        (bool | #ParamRef)
	"fontFamily"?:       (string | #ParamRef)
	"fontSize"?:         (#ChannelValue | #ParamRef)
	"fontStyle"?:        (string | #ParamRef)
	"fontVariant"?:      (string | #ParamRef)
	"fontWeight"?:       (string | number | #ParamRef)
	"x"?:                #ChannelValueSpec
	"z"?:                #ChannelValue
	"text"?:             #ChannelValue
	"frameAnchor"?:      (#FrameAnchor | #ParamRef)
	"lineAnchor"?:       ("top" | "middle" | "bottom" | #ParamRef)
	"rotate"?:           (#ChannelValue | #ParamRef)
	"type"!:             "text" | "textY"
}

#DensityXBase: {
	"data"!:      #PlotMarkData
	"bandwidth"?: (number | #ParamRef)
	"bins"?:      (number | #ParamRef)
	"normalize"?: (bool | "max" | "sum" | "none" | #ParamRef)
	"mark"!:      "densityX"
}

#DensityYBase: {
	"data"!:      #PlotMarkData
	"bandwidth"?: (number | #ParamRef)
	"bins"?:      (number | #ParamRef)
	"normalize"?: (bool | "max" | "sum" | "none" | #ParamRef)
	"mark"!:      "densityY"
}

#Admission_DensityX_0: {"data"!: #PlotMarkData, "bandwidth"?: (number | #ParamRef), "bins"?: (number | #ParamRef), "normalize"?: (bool | "max" | "sum" | "none" | #ParamRef), "mark"!: "densityX", "filter"?: #ChannelValue, "select"?: #SelectFilter, "reverse"?: (bool | #ParamRef), "sort"?: (#SortOrder | #ChannelDomainSort), "fx"?: #ChannelValue, "fy"?: #ChannelValue, "facet"?: ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef), "facetAnchor"?: ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef), "margin"?: (number | #ParamRef), "marginTop"?: (number | #ParamRef), "marginRight"?: (number | #ParamRef), "marginBottom"?: (number | #ParamRef), "marginLeft"?: (number | #ParamRef), "ariaDescription"?: (string | #ParamRef), "ariaHidden"?: (string | #ParamRef), "ariaLabel"?: #ChannelValue, "pointerEvents"?: (string | #ParamRef), "title"?: #ChannelValue, "tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef), "channels"?: {[string]: string}, "clip"?: ("frame" | "sphere" | bool | null | #ParamRef), "dx"?: (number | #ParamRef), "dy"?: (number | #ParamRef), "fill"?: (#ChannelValueSpec | #ParamRef), "fillOpacity"?: (#ChannelValueSpec | #ParamRef), "stroke"?: (#ChannelValueSpec | #ParamRef), "strokeDasharray"?: (string | number | #ParamRef), "strokeDashoffset"?: (string | number | #ParamRef), "strokeLinecap"?: (string | #ParamRef), "strokeLinejoin"?: (string | #ParamRef), "strokeMiterlimit"?: (number | #ParamRef), "strokeOpacity"?: #ChannelValueSpec, "strokeWidth"?: #ChannelValueSpec, "opacity"?: #ChannelValueSpec, "mixBlendMode"?: (string | #ParamRef), "imageFilter"?: (string | #ParamRef), "paintOrder"?: (string | #ParamRef), "shapeRendering"?: (string | #ParamRef), "href"?: #ChannelValue, "target"?: (string | #ParamRef), "offset"?: (#StackOffset | null | #ParamRef), "order"?: (#StackOrder | null | #ParamRef), "z"?: #ChannelValue, "curve"?: (#Curve | #ParamRef), "tension"?: (number | #ParamRef), "y"?: #ChannelValueSpec, "type"!: "areaX", "stack"?: (bool | #ParamRef)}

#Admission_DensityX_1: {"data"!: #PlotMarkData, "bandwidth"?: (number | #ParamRef), "bins"?: (number | #ParamRef), "normalize"?: (bool | "max" | "sum" | "none" | #ParamRef), "mark"!: "densityX", "filter"?: #ChannelValue, "select"?: #SelectFilter, "reverse"?: (bool | #ParamRef), "sort"?: (#SortOrder | #ChannelDomainSort), "fx"?: #ChannelValue, "fy"?: #ChannelValue, "facet"?: ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef), "facetAnchor"?: ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef), "margin"?: (number | #ParamRef), "marginTop"?: (number | #ParamRef), "marginRight"?: (number | #ParamRef), "marginBottom"?: (number | #ParamRef), "marginLeft"?: (number | #ParamRef), "ariaDescription"?: (string | #ParamRef), "ariaHidden"?: (string | #ParamRef), "ariaLabel"?: #ChannelValue, "pointerEvents"?: (string | #ParamRef), "title"?: #ChannelValue, "tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef), "channels"?: {[string]: string}, "clip"?: ("frame" | "sphere" | bool | null | #ParamRef), "dx"?: (number | #ParamRef), "dy"?: (number | #ParamRef), "fill"?: (#ChannelValueSpec | #ParamRef), "fillOpacity"?: (#ChannelValueSpec | #ParamRef), "stroke"?: (#ChannelValueSpec | #ParamRef), "strokeDasharray"?: (string | number | #ParamRef), "strokeDashoffset"?: (string | number | #ParamRef), "strokeLinecap"?: (string | #ParamRef), "strokeLinejoin"?: (string | #ParamRef), "strokeMiterlimit"?: (number | #ParamRef), "strokeOpacity"?: #ChannelValueSpec, "strokeWidth"?: #ChannelValueSpec, "opacity"?: #ChannelValueSpec, "mixBlendMode"?: (string | #ParamRef), "imageFilter"?: (string | #ParamRef), "paintOrder"?: (string | #ParamRef), "shapeRendering"?: (string | #ParamRef), "href"?: #ChannelValue, "target"?: (string | #ParamRef), "marker"?: (#MarkerName | "none" | bool | null | #ParamRef), "markerStart"?: (#MarkerName | "none" | bool | null | #ParamRef), "markerMid"?: (#MarkerName | "none" | bool | null | #ParamRef), "markerEnd"?: (#MarkerName | "none" | bool | null | #ParamRef), "curve"?: (#Curve | "auto" | #ParamRef), "tension"?: (number | #ParamRef), "y"?: #ChannelValueSpec, "z"?: #ChannelValue, "type"!: "lineX"}

#Admission_DensityX_2: {"data"!: #PlotMarkData, "bandwidth"?: (number | #ParamRef), "bins"?: (number | #ParamRef), "normalize"?: (bool | "max" | "sum" | "none" | #ParamRef), "mark"!: "densityX", "filter"?: #ChannelValue, "select"?: #SelectFilter, "reverse"?: (bool | #ParamRef), "sort"?: (#SortOrder | #ChannelDomainSort), "fx"?: #ChannelValue, "fy"?: #ChannelValue, "facet"?: ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef), "facetAnchor"?: ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef), "margin"?: (number | #ParamRef), "marginTop"?: (number | #ParamRef), "marginRight"?: (number | #ParamRef), "marginBottom"?: (number | #ParamRef), "marginLeft"?: (number | #ParamRef), "ariaDescription"?: (string | #ParamRef), "ariaHidden"?: (string | #ParamRef), "ariaLabel"?: #ChannelValue, "pointerEvents"?: (string | #ParamRef), "title"?: #ChannelValue, "tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef), "channels"?: {[string]: string}, "clip"?: ("frame" | "sphere" | bool | null | #ParamRef), "dx"?: (number | #ParamRef), "dy"?: (number | #ParamRef), "fill"?: (#ChannelValueSpec | #ParamRef), "fillOpacity"?: (#ChannelValueSpec | #ParamRef), "stroke"?: (#ChannelValueSpec | #ParamRef), "strokeDasharray"?: (string | number | #ParamRef), "strokeDashoffset"?: (string | number | #ParamRef), "strokeLinecap"?: (string | #ParamRef), "strokeLinejoin"?: (string | #ParamRef), "strokeMiterlimit"?: (number | #ParamRef), "strokeOpacity"?: #ChannelValueSpec, "strokeWidth"?: #ChannelValueSpec, "opacity"?: #ChannelValueSpec, "mixBlendMode"?: (string | #ParamRef), "imageFilter"?: (string | #ParamRef), "paintOrder"?: (string | #ParamRef), "shapeRendering"?: (string | #ParamRef), "href"?: #ChannelValue, "target"?: (string | #ParamRef), "y"?: #ChannelValueSpec, "z"?: #ChannelValue, "r"?: (#ChannelValueSpec | number | #ParamRef), "rotate"?: (#ChannelValue | number | #ParamRef), "symbol"?: (#ChannelValueSpec | #SymbolType | #ParamRef), "frameAnchor"?: (#FrameAnchor | #ParamRef), "type"!: "dotX"}

#Admission_DensityX_3: {"data"!: #PlotMarkData, "bandwidth"?: (number | #ParamRef), "bins"?: (number | #ParamRef), "normalize"?: (bool | "max" | "sum" | "none" | #ParamRef), "mark"!: "densityX", "filter"?: #ChannelValue, "select"?: #SelectFilter, "reverse"?: (bool | #ParamRef), "sort"?: (#SortOrder | #ChannelDomainSort), "fx"?: #ChannelValue, "fy"?: #ChannelValue, "facet"?: ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef), "facetAnchor"?: ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef), "margin"?: (number | #ParamRef), "marginTop"?: (number | #ParamRef), "marginRight"?: (number | #ParamRef), "marginBottom"?: (number | #ParamRef), "marginLeft"?: (number | #ParamRef), "ariaDescription"?: (string | #ParamRef), "ariaHidden"?: (string | #ParamRef), "ariaLabel"?: #ChannelValue, "pointerEvents"?: (string | #ParamRef), "title"?: #ChannelValue, "tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef), "channels"?: {[string]: string}, "clip"?: ("frame" | "sphere" | bool | null | #ParamRef), "dx"?: (number | #ParamRef), "dy"?: (number | #ParamRef), "fill"?: (#ChannelValueSpec | #ParamRef), "fillOpacity"?: (#ChannelValueSpec | #ParamRef), "stroke"?: (#ChannelValueSpec | #ParamRef), "strokeDasharray"?: (string | number | #ParamRef), "strokeDashoffset"?: (string | number | #ParamRef), "strokeLinecap"?: (string | #ParamRef), "strokeLinejoin"?: (string | #ParamRef), "strokeMiterlimit"?: (number | #ParamRef), "strokeOpacity"?: #ChannelValueSpec, "strokeWidth"?: #ChannelValueSpec, "opacity"?: #ChannelValueSpec, "mixBlendMode"?: (string | #ParamRef), "imageFilter"?: (string | #ParamRef), "paintOrder"?: (string | #ParamRef), "shapeRendering"?: (string | #ParamRef), "href"?: #ChannelValue, "target"?: (string | #ParamRef), "textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "y"?: #ChannelValueSpec, "z"?: #ChannelValue, "text"?: #ChannelValue, "frameAnchor"?: (#FrameAnchor | #ParamRef), "lineAnchor"?: ("top" | "middle" | "bottom" | #ParamRef), "rotate"?: (#ChannelValue | #ParamRef), "type"!: "textX"}

#Admission_DensityY_0: {"data"!: #PlotMarkData, "bandwidth"?: (number | #ParamRef), "bins"?: (number | #ParamRef), "normalize"?: (bool | "max" | "sum" | "none" | #ParamRef), "mark"!: "densityY", "filter"?: #ChannelValue, "select"?: #SelectFilter, "reverse"?: (bool | #ParamRef), "sort"?: (#SortOrder | #ChannelDomainSort), "fx"?: #ChannelValue, "fy"?: #ChannelValue, "facet"?: ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef), "facetAnchor"?: ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef), "margin"?: (number | #ParamRef), "marginTop"?: (number | #ParamRef), "marginRight"?: (number | #ParamRef), "marginBottom"?: (number | #ParamRef), "marginLeft"?: (number | #ParamRef), "ariaDescription"?: (string | #ParamRef), "ariaHidden"?: (string | #ParamRef), "ariaLabel"?: #ChannelValue, "pointerEvents"?: (string | #ParamRef), "title"?: #ChannelValue, "tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef), "channels"?: {[string]: string}, "clip"?: ("frame" | "sphere" | bool | null | #ParamRef), "dx"?: (number | #ParamRef), "dy"?: (number | #ParamRef), "fill"?: (#ChannelValueSpec | #ParamRef), "fillOpacity"?: (#ChannelValueSpec | #ParamRef), "stroke"?: (#ChannelValueSpec | #ParamRef), "strokeDasharray"?: (string | number | #ParamRef), "strokeDashoffset"?: (string | number | #ParamRef), "strokeLinecap"?: (string | #ParamRef), "strokeLinejoin"?: (string | #ParamRef), "strokeMiterlimit"?: (number | #ParamRef), "strokeOpacity"?: #ChannelValueSpec, "strokeWidth"?: #ChannelValueSpec, "opacity"?: #ChannelValueSpec, "mixBlendMode"?: (string | #ParamRef), "imageFilter"?: (string | #ParamRef), "paintOrder"?: (string | #ParamRef), "shapeRendering"?: (string | #ParamRef), "href"?: #ChannelValue, "target"?: (string | #ParamRef), "offset"?: (#StackOffset | null | #ParamRef), "order"?: (#StackOrder | null | #ParamRef), "z"?: #ChannelValue, "curve"?: (#Curve | #ParamRef), "tension"?: (number | #ParamRef), "x"?: #ChannelValueSpec, "type"?: "areaY", "stack"?: (bool | #ParamRef)}

#Admission_DensityY_1: {"data"!: #PlotMarkData, "bandwidth"?: (number | #ParamRef), "bins"?: (number | #ParamRef), "normalize"?: (bool | "max" | "sum" | "none" | #ParamRef), "mark"!: "densityY", "filter"?: #ChannelValue, "select"?: #SelectFilter, "reverse"?: (bool | #ParamRef), "sort"?: (#SortOrder | #ChannelDomainSort), "fx"?: #ChannelValue, "fy"?: #ChannelValue, "facet"?: ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef), "facetAnchor"?: ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef), "margin"?: (number | #ParamRef), "marginTop"?: (number | #ParamRef), "marginRight"?: (number | #ParamRef), "marginBottom"?: (number | #ParamRef), "marginLeft"?: (number | #ParamRef), "ariaDescription"?: (string | #ParamRef), "ariaHidden"?: (string | #ParamRef), "ariaLabel"?: #ChannelValue, "pointerEvents"?: (string | #ParamRef), "title"?: #ChannelValue, "tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef), "channels"?: {[string]: string}, "clip"?: ("frame" | "sphere" | bool | null | #ParamRef), "dx"?: (number | #ParamRef), "dy"?: (number | #ParamRef), "fill"?: (#ChannelValueSpec | #ParamRef), "fillOpacity"?: (#ChannelValueSpec | #ParamRef), "stroke"?: (#ChannelValueSpec | #ParamRef), "strokeDasharray"?: (string | number | #ParamRef), "strokeDashoffset"?: (string | number | #ParamRef), "strokeLinecap"?: (string | #ParamRef), "strokeLinejoin"?: (string | #ParamRef), "strokeMiterlimit"?: (number | #ParamRef), "strokeOpacity"?: #ChannelValueSpec, "strokeWidth"?: #ChannelValueSpec, "opacity"?: #ChannelValueSpec, "mixBlendMode"?: (string | #ParamRef), "imageFilter"?: (string | #ParamRef), "paintOrder"?: (string | #ParamRef), "shapeRendering"?: (string | #ParamRef), "href"?: #ChannelValue, "target"?: (string | #ParamRef), "marker"?: (#MarkerName | "none" | bool | null | #ParamRef), "markerStart"?: (#MarkerName | "none" | bool | null | #ParamRef), "markerMid"?: (#MarkerName | "none" | bool | null | #ParamRef), "markerEnd"?: (#MarkerName | "none" | bool | null | #ParamRef), "curve"?: (#Curve | "auto" | #ParamRef), "tension"?: (number | #ParamRef), "x"?: #ChannelValueSpec, "z"?: #ChannelValue, "type"!: "lineY"}

#Admission_DensityY_2: {"data"!: #PlotMarkData, "bandwidth"?: (number | #ParamRef), "bins"?: (number | #ParamRef), "normalize"?: (bool | "max" | "sum" | "none" | #ParamRef), "mark"!: "densityY", "filter"?: #ChannelValue, "select"?: #SelectFilter, "reverse"?: (bool | #ParamRef), "sort"?: (#SortOrder | #ChannelDomainSort), "fx"?: #ChannelValue, "fy"?: #ChannelValue, "facet"?: ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef), "facetAnchor"?: ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef), "margin"?: (number | #ParamRef), "marginTop"?: (number | #ParamRef), "marginRight"?: (number | #ParamRef), "marginBottom"?: (number | #ParamRef), "marginLeft"?: (number | #ParamRef), "ariaDescription"?: (string | #ParamRef), "ariaHidden"?: (string | #ParamRef), "ariaLabel"?: #ChannelValue, "pointerEvents"?: (string | #ParamRef), "title"?: #ChannelValue, "tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef), "channels"?: {[string]: string}, "clip"?: ("frame" | "sphere" | bool | null | #ParamRef), "dx"?: (number | #ParamRef), "dy"?: (number | #ParamRef), "fill"?: (#ChannelValueSpec | #ParamRef), "fillOpacity"?: (#ChannelValueSpec | #ParamRef), "stroke"?: (#ChannelValueSpec | #ParamRef), "strokeDasharray"?: (string | number | #ParamRef), "strokeDashoffset"?: (string | number | #ParamRef), "strokeLinecap"?: (string | #ParamRef), "strokeLinejoin"?: (string | #ParamRef), "strokeMiterlimit"?: (number | #ParamRef), "strokeOpacity"?: #ChannelValueSpec, "strokeWidth"?: #ChannelValueSpec, "opacity"?: #ChannelValueSpec, "mixBlendMode"?: (string | #ParamRef), "imageFilter"?: (string | #ParamRef), "paintOrder"?: (string | #ParamRef), "shapeRendering"?: (string | #ParamRef), "href"?: #ChannelValue, "target"?: (string | #ParamRef), "x"?: #ChannelValueSpec, "z"?: #ChannelValue, "r"?: (#ChannelValueSpec | number | #ParamRef), "rotate"?: (#ChannelValue | number | #ParamRef), "symbol"?: (#ChannelValueSpec | #SymbolType | #ParamRef), "frameAnchor"?: (#FrameAnchor | #ParamRef), "type"!: "dot" | "dotY" | "circle" | "hexagon"}

#Admission_DensityY_3: {"data"!: #PlotMarkData, "bandwidth"?: (number | #ParamRef), "bins"?: (number | #ParamRef), "normalize"?: (bool | "max" | "sum" | "none" | #ParamRef), "mark"!: "densityY", "filter"?: #ChannelValue, "select"?: #SelectFilter, "reverse"?: (bool | #ParamRef), "sort"?: (#SortOrder | #ChannelDomainSort), "fx"?: #ChannelValue, "fy"?: #ChannelValue, "facet"?: ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef), "facetAnchor"?: ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef), "margin"?: (number | #ParamRef), "marginTop"?: (number | #ParamRef), "marginRight"?: (number | #ParamRef), "marginBottom"?: (number | #ParamRef), "marginLeft"?: (number | #ParamRef), "ariaDescription"?: (string | #ParamRef), "ariaHidden"?: (string | #ParamRef), "ariaLabel"?: #ChannelValue, "pointerEvents"?: (string | #ParamRef), "title"?: #ChannelValue, "tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef), "channels"?: {[string]: string}, "clip"?: ("frame" | "sphere" | bool | null | #ParamRef), "dx"?: (number | #ParamRef), "dy"?: (number | #ParamRef), "fill"?: (#ChannelValueSpec | #ParamRef), "fillOpacity"?: (#ChannelValueSpec | #ParamRef), "stroke"?: (#ChannelValueSpec | #ParamRef), "strokeDasharray"?: (string | number | #ParamRef), "strokeDashoffset"?: (string | number | #ParamRef), "strokeLinecap"?: (string | #ParamRef), "strokeLinejoin"?: (string | #ParamRef), "strokeMiterlimit"?: (number | #ParamRef), "strokeOpacity"?: #ChannelValueSpec, "strokeWidth"?: #ChannelValueSpec, "opacity"?: #ChannelValueSpec, "mixBlendMode"?: (string | #ParamRef), "imageFilter"?: (string | #ParamRef), "paintOrder"?: (string | #ParamRef), "shapeRendering"?: (string | #ParamRef), "href"?: #ChannelValue, "target"?: (string | #ParamRef), "textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "z"?: #ChannelValue, "text"?: #ChannelValue, "frameAnchor"?: (#FrameAnchor | #ParamRef), "lineAnchor"?: ("top" | "middle" | "bottom" | #ParamRef), "rotate"?: (#ChannelValue | #ParamRef), "type"!: "text" | "textY"}

#TextOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"textAnchor"?:       ("start" | "middle" | "end" | #ParamRef)
	"lineHeight"?:       (number | #ParamRef)
	"lineWidth"?:        (number | #ParamRef)
	"textOverflow"?:     (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef)
	"monospace"?:        (bool | #ParamRef)
	"fontFamily"?:       (string | #ParamRef)
	"fontSize"?:         (#ChannelValue | #ParamRef)
	"fontStyle"?:        (string | #ParamRef)
	"fontVariant"?:      (string | #ParamRef)
	"fontWeight"?:       (string | number | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"z"?:                #ChannelValue
	"text"?:             #ChannelValue
	"frameAnchor"?:      (#FrameAnchor | #ParamRef)
	"lineAnchor"?:       ("top" | "middle" | "bottom" | #ParamRef)
	"rotate"?:           (#ChannelValue | #ParamRef)
}

#VectorShapeName: "arrow" | "spike"

#TextXOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"textAnchor"?:       ("start" | "middle" | "end" | #ParamRef)
	"lineHeight"?:       (number | #ParamRef)
	"lineWidth"?:        (number | #ParamRef)
	"textOverflow"?:     (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef)
	"monospace"?:        (bool | #ParamRef)
	"fontFamily"?:       (string | #ParamRef)
	"fontSize"?:         (#ChannelValue | #ParamRef)
	"fontStyle"?:        (string | #ParamRef)
	"fontVariant"?:      (string | #ParamRef)
	"fontWeight"?:       (string | number | #ParamRef)
	"x"?:                #ChannelValueSpec
	"z"?:                #ChannelValue
	"text"?:             #ChannelValue
	"frameAnchor"?:      (#FrameAnchor | #ParamRef)
	"lineAnchor"?:       ("top" | "middle" | "bottom" | #ParamRef)
	"rotate"?:           (#ChannelValue | #ParamRef)
	"y"?:                #ChannelValueIntervalSpec
	"interval"?:         (#Interval | #ParamRef)
}

#VectorShape: #VectorShapeName

#TextYOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"textAnchor"?:       ("start" | "middle" | "end" | #ParamRef)
	"lineHeight"?:       (number | #ParamRef)
	"lineWidth"?:        (number | #ParamRef)
	"textOverflow"?:     (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef)
	"monospace"?:        (bool | #ParamRef)
	"fontFamily"?:       (string | #ParamRef)
	"fontSize"?:         (#ChannelValue | #ParamRef)
	"fontStyle"?:        (string | #ParamRef)
	"fontVariant"?:      (string | #ParamRef)
	"fontWeight"?:       (string | number | #ParamRef)
	"y"?:                #ChannelValueSpec
	"z"?:                #ChannelValue
	"text"?:             #ChannelValue
	"frameAnchor"?:      (#FrameAnchor | #ParamRef)
	"lineAnchor"?:       ("top" | "middle" | "bottom" | #ParamRef)
	"rotate"?:           (#ChannelValue | #ParamRef)
	"x"?:                #ChannelValueIntervalSpec
	"interval"?:         #Interval
}

#Text: {
	"data"?:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"textAnchor"?:       ("start" | "middle" | "end" | #ParamRef)
	"lineHeight"?:       (number | #ParamRef)
	"lineWidth"?:        (number | #ParamRef)
	"textOverflow"?:     (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef)
	"monospace"?:        (bool | #ParamRef)
	"fontFamily"?:       (string | #ParamRef)
	"fontSize"?:         (#ChannelValue | #ParamRef)
	"fontStyle"?:        (string | #ParamRef)
	"fontVariant"?:      (string | #ParamRef)
	"fontWeight"?:       (string | number | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"z"?:                #ChannelValue
	"text"?:             #ChannelValue
	"frameAnchor"?:      (#FrameAnchor | #ParamRef)
	"lineAnchor"?:       ("top" | "middle" | "bottom" | #ParamRef)
	"rotate"?:           (#ChannelValue | #ParamRef)
	"mark"!:             "text"
}

#TextX: {
	"data"?:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"textAnchor"?:       ("start" | "middle" | "end" | #ParamRef)
	"lineHeight"?:       (number | #ParamRef)
	"lineWidth"?:        (number | #ParamRef)
	"textOverflow"?:     (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef)
	"monospace"?:        (bool | #ParamRef)
	"fontFamily"?:       (string | #ParamRef)
	"fontSize"?:         (#ChannelValue | #ParamRef)
	"fontStyle"?:        (string | #ParamRef)
	"fontVariant"?:      (string | #ParamRef)
	"fontWeight"?:       (string | number | #ParamRef)
	"x"?:                #ChannelValueSpec
	"z"?:                #ChannelValue
	"text"?:             #ChannelValue
	"frameAnchor"?:      (#FrameAnchor | #ParamRef)
	"lineAnchor"?:       ("top" | "middle" | "bottom" | #ParamRef)
	"rotate"?:           (#ChannelValue | #ParamRef)
	"y"?:                #ChannelValueIntervalSpec
	"interval"?:         (#Interval | #ParamRef)
	"mark"!:             "textX"
}

#TextY: {
	"data"?:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"textAnchor"?:       ("start" | "middle" | "end" | #ParamRef)
	"lineHeight"?:       (number | #ParamRef)
	"lineWidth"?:        (number | #ParamRef)
	"textOverflow"?:     (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef)
	"monospace"?:        (bool | #ParamRef)
	"fontFamily"?:       (string | #ParamRef)
	"fontSize"?:         (#ChannelValue | #ParamRef)
	"fontStyle"?:        (string | #ParamRef)
	"fontVariant"?:      (string | #ParamRef)
	"fontWeight"?:       (string | number | #ParamRef)
	"y"?:                #ChannelValueSpec
	"z"?:                #ChannelValue
	"text"?:             #ChannelValue
	"frameAnchor"?:      (#FrameAnchor | #ParamRef)
	"lineAnchor"?:       ("top" | "middle" | "bottom" | #ParamRef)
	"rotate"?:           (#ChannelValue | #ParamRef)
	"x"?:                #ChannelValueIntervalSpec
	"interval"?:         #Interval
	"mark"!:             "textY"
}

#ImageOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:                ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:                  (number | #ParamRef)
	"dy"?:                  (number | #ParamRef)
	"fill"?:                (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:         (#ChannelValueSpec | #ParamRef)
	"stroke"?:              (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:     (string | number | #ParamRef)
	"strokeDashoffset"?:    (string | number | #ParamRef)
	"strokeLinecap"?:       (string | #ParamRef)
	"strokeLinejoin"?:      (string | #ParamRef)
	"strokeMiterlimit"?:    (number | #ParamRef)
	"strokeOpacity"?:       #ChannelValueSpec
	"strokeWidth"?:         #ChannelValueSpec
	"opacity"?:             #ChannelValueSpec
	"mixBlendMode"?:        (string | #ParamRef)
	"imageFilter"?:         (string | #ParamRef)
	"paintOrder"?:          (string | #ParamRef)
	"shapeRendering"?:      (string | #ParamRef)
	"href"?:                #ChannelValue
	"target"?:              (string | #ParamRef)
	"x"?:                   #ChannelValueSpec
	"y"?:                   #ChannelValueSpec
	"width"?:               (#ChannelValue | #ParamRef)
	"height"?:              (#ChannelValue | #ParamRef)
	"r"?:                   (#ChannelValue | #ParamRef)
	"rotate"?:              (#ChannelValue | #ParamRef)
	"src"?:                 (#ChannelValue | #ParamRef)
	"preserveAspectRatio"?: (string | #ParamRef)
	"crossOrigin"?:         (string | #ParamRef)
	"frameAnchor"?:         (#FrameAnchor | #ParamRef)
	"imageRendering"?:      (string | #ParamRef)
}

#Image: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:                ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:                  (number | #ParamRef)
	"dy"?:                  (number | #ParamRef)
	"fill"?:                (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:         (#ChannelValueSpec | #ParamRef)
	"stroke"?:              (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:     (string | number | #ParamRef)
	"strokeDashoffset"?:    (string | number | #ParamRef)
	"strokeLinecap"?:       (string | #ParamRef)
	"strokeLinejoin"?:      (string | #ParamRef)
	"strokeMiterlimit"?:    (number | #ParamRef)
	"strokeOpacity"?:       #ChannelValueSpec
	"strokeWidth"?:         #ChannelValueSpec
	"opacity"?:             #ChannelValueSpec
	"mixBlendMode"?:        (string | #ParamRef)
	"imageFilter"?:         (string | #ParamRef)
	"paintOrder"?:          (string | #ParamRef)
	"shapeRendering"?:      (string | #ParamRef)
	"href"?:                #ChannelValue
	"target"?:              (string | #ParamRef)
	"x"?:                   #ChannelValueSpec
	"y"?:                   #ChannelValueSpec
	"width"?:               (#ChannelValue | #ParamRef)
	"height"?:              (#ChannelValue | #ParamRef)
	"r"?:                   (#ChannelValue | #ParamRef)
	"rotate"?:              (#ChannelValue | #ParamRef)
	"src"?:                 (#ChannelValue | #ParamRef)
	"preserveAspectRatio"?: (string | #ParamRef)
	"crossOrigin"?:         (string | #ParamRef)
	"frameAnchor"?:         (#FrameAnchor | #ParamRef)
	"imageRendering"?:      (string | #ParamRef)
	"mark"!:                "image"
}

#VectorOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"r"?:                (number | #ParamRef)
	"length"?:           #ChannelValueSpec
	"rotate"?:           #ChannelValue
	"shape"?:            (#VectorShape | #ParamRef)
	"anchor"?:           ("start" | "middle" | "end" | #ParamRef)
	"frameAnchor"?:      (#FrameAnchor | #ParamRef)
}

#Vector: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"r"?:                (number | #ParamRef)
	"length"?:           #ChannelValueSpec
	"rotate"?:           #ChannelValue
	"shape"?:            (#VectorShape | #ParamRef)
	"anchor"?:           ("start" | "middle" | "end" | #ParamRef)
	"frameAnchor"?:      (#FrameAnchor | #ParamRef)
	"mark"!:             "vector"
}

#VectorX: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"r"?:                (number | #ParamRef)
	"length"?:           #ChannelValueSpec
	"rotate"?:           #ChannelValue
	"shape"?:            (#VectorShape | #ParamRef)
	"anchor"?:           ("start" | "middle" | "end" | #ParamRef)
	"frameAnchor"?:      (#FrameAnchor | #ParamRef)
	"mark"!:             "vectorX"
}

#VectorY: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"r"?:                (number | #ParamRef)
	"length"?:           #ChannelValueSpec
	"rotate"?:           #ChannelValue
	"shape"?:            (#VectorShape | #ParamRef)
	"anchor"?:           ("start" | "middle" | "end" | #ParamRef)
	"frameAnchor"?:      (#FrameAnchor | #ParamRef)
	"mark"!:             "vectorY"
}

#Spike: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"r"?:                (number | #ParamRef)
	"length"?:           #ChannelValueSpec
	"rotate"?:           #ChannelValue
	"shape"?:            (#VectorShape | #ParamRef)
	"anchor"?:           ("start" | "middle" | "end" | #ParamRef)
	"frameAnchor"?:      (#FrameAnchor | #ParamRef)
	"mark"!:             "spike"
}

#WaffleOptions: {
	"multiple"?: (number | #ParamRef)
	"unit"?:     (number | #ParamRef)
	"gap"?:      (number | #ParamRef)
	"round"?:    (bool | #ParamRef)
}

#WaffleX: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"inset"?:            (number | #ParamRef)
	"insetTop"?:         (number | #ParamRef)
	"insetRight"?:       (number | #ParamRef)
	"insetBottom"?:      (number | #ParamRef)
	"insetLeft"?:        (number | #ParamRef)
	"rx"?:               (number | string | #ParamRef)
	"ry"?:               (number | string | #ParamRef)
	"offset"?:           (#StackOffset | null | #ParamRef)
	"order"?:            (#StackOrder | null | #ParamRef)
	"z"?:                #ChannelValue
	"interval"?:         (#Interval | #ParamRef)
	"x"?:                #ChannelValueIntervalSpec
	"x1"?:               #ChannelValueSpec
	"x2"?:               #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"multiple"?:         (number | #ParamRef)
	"unit"?:             (number | #ParamRef)
	"gap"?:              (number | #ParamRef)
	"round"?:            (bool | #ParamRef)
	"mark"!:             "waffleX"
}

#WaffleY: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"inset"?:            (number | #ParamRef)
	"insetTop"?:         (number | #ParamRef)
	"insetRight"?:       (number | #ParamRef)
	"insetBottom"?:      (number | #ParamRef)
	"insetLeft"?:        (number | #ParamRef)
	"rx"?:               (number | string | #ParamRef)
	"ry"?:               (number | string | #ParamRef)
	"offset"?:           (#StackOffset | null | #ParamRef)
	"order"?:            (#StackOrder | null | #ParamRef)
	"z"?:                #ChannelValue
	"interval"?:         (#Interval | #ParamRef)
	"y"?:                #ChannelValueIntervalSpec
	"y1"?:               #ChannelValueSpec
	"y2"?:               #ChannelValueSpec
	"x"?:                #ChannelValueSpec
	"multiple"?:         (number | #ParamRef)
	"unit"?:             (number | #ParamRef)
	"gap"?:              (number | #ParamRef)
	"round"?:            (bool | #ParamRef)
	"mark"!:             "waffleY"
}

#PlotLegend: {"legend"!: ("color" | "opacity" | "symbol"), "as"?: #ParamRef, "field"?: string, "label"?: string, "tickSize"?: number, "marginTop"?: number, "marginRight"?: number, "marginBottom"?: number, "marginLeft"?: number, "width"?: number, "height"?: number, "columns"?: number}

#Legend: {"legend"!: ("color" | "opacity" | "symbol"), "as"?: #ParamRef, "field"?: string, "label"?: string, "tickSize"?: number, "marginTop"?: number, "marginRight"?: number, "marginBottom"?: number, "marginLeft"?: number, "width"?: number, "height"?: number, "columns"?: number, "for"!: string}

#OmittedProperties: "parentRule" | "getPropertyPriority" | "getPropertyValue" | "item" | "removeProperty" | "setProperty"

#CSSStyles: {
	"length"?:             number
	[string & !="length"]: string
}

#Fixed: "Fixed"

#LiteralTimeInterval: "3 months" | "10 years" | #TimeIntervalName | "seconds" | "minutes" | "hours" | "days" | "weeks" | "months" | "quarters" | "halfs" | "years" | "mondays" | "tuesdays" | "wednesdays" | "thursdays" | "fridays" | "saturdays" | "sundays" | string | string

#TimeIntervalName: "second" | "minute" | "hour" | "day" | "week" | "month" | "quarter" | "half" | "year" | "monday" | "tuesday" | "wednesday" | "thursday" | "friday" | "saturday" | "sunday"

#Interval: #LiteralTimeInterval

#ScaleName: "x" | "y" | "fx" | "fy" | "r" | "color" | "opacity" | "symbol" | "length"

#PositionScaleType: "linear" | "pow" | "sqrt" | "log" | "symlog" | "utc" | "time" | "point" | "band" | "threshold" | "quantile" | "quantize" | "identity"

#ColorScaleType: "linear" | "pow" | "sqrt" | "log" | "symlog" | "utc" | "time" | "point" | "band" | "ordinal" | "sequential" | "cyclical" | "diverging" | "diverging-log" | "diverging-pow" | "diverging-sqrt" | "diverging-symlog" | "categorical" | "threshold" | "quantile" | "quantize" | "identity"

#ContinuousScaleType: "linear" | "pow" | "sqrt" | "log" | "symlog" | "utc" | "time" | "identity"

#DiscreteScaleType: "ordinal" | "identity"

#ProjectionName: "albers-usa" | "albers" | "azimuthal-equal-area" | "azimuthal-equidistant" | "conic-conformal" | "conic-equal-area" | "conic-equidistant" | "equal-earth" | "equirectangular" | "gnomonic" | "identity" | "reflect-y" | "mercator" | "orthographic" | "stereographic" | "transverse-mercator"

#Interpolate: "number" | "rgb" | "hsl" | "hcl" | "lab"

#ColorSchemeCase: "Accent" | "Category10" | "Dark2" | "Observable10" | "Paired" | "Pastel1" | "Pastel2" | "Set1" | "Set2" | "Set3" | "Tableau10" | "BrBG" | "PRGn" | "PiYG" | "PuOr" | "RdBu" | "RdGy" | "RdYlBu" | "RdYlGn" | "Spectral" | "BuRd" | "BuYlRd" | "Blues" | "Greens" | "Greys" | "Oranges" | "Purples" | "Reds" | "Turbo" | "Viridis" | "Magma" | "Inferno" | "Plasma" | "Cividis" | "Cubehelix" | "Warm" | "Cool" | "BuGn" | "BuPu" | "GnBu" | "OrRd" | "PuBu" | "PuBuGn" | "PuRd" | "RdPu" | "YlGn" | "YlGnBu" | "YlOrBr" | "YlOrRd" | "Rainbow" | "Sinebow"

#ColorScheme: #ColorSchemeCase | {...}

#SymbolType: "asterisk" | "circle" | "cross" | "diamond" | "diamond2" | "hexagon" | "plus" | "square" | "square2" | "star" | "times" | "triangle" | "triangle2" | "wye"

#FrameAnchor: "middle" | "top-left" | "top" | "top-right" | "right" | "bottom-right" | "bottom" | "bottom-left" | "left"

#Digit: 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9

#ReducerPercentile: "p00" | "p01" | "p02" | "p03" | "p04" | "p05" | "p06" | "p07" | "p08" | "p09" | "p10" | "p11" | "p12" | "p13" | "p14" | "p15" | "p16" | "p17" | "p18" | "p19" | "p20" | "p21" | "p22" | "p23" | "p24" | "p25" | "p26" | "p27" | "p28" | "p29" | "p30" | "p31" | "p32" | "p33" | "p34" | "p35" | "p36" | "p37" | "p38" | "p39" | "p40" | "p41" | "p42" | "p43" | "p44" | "p45" | "p46" | "p47" | "p48" | "p49" | "p50" | "p51" | "p52" | "p53" | "p54" | "p55" | "p56" | "p57" | "p58" | "p59" | "p60" | "p61" | "p62" | "p63" | "p64" | "p65" | "p66" | "p67" | "p68" | "p69" | "p70" | "p71" | "p72" | "p73" | "p74" | "p75" | "p76" | "p77" | "p78" | "p79" | "p80" | "p81" | "p82" | "p83" | "p84" | "p85" | "p86" | "p87" | "p88" | "p89" | "p90" | "p91" | "p92" | "p93" | "p94" | "p95" | "p96" | "p97" | "p98" | "p99" | "p25" | "p50" | "p75"

#Reducer: "first" | "last" | "identity" | "count" | "distinct" | "sum" | "proportion" | "proportion-facet" | "deviation" | "min" | "min-index" | "max" | "max-index" | "mean" | "median" | "variance" | "mode" | #ReducerPercentile

#CurveName: "basis" | "basis-closed" | "basis-open" | "bundle" | "bump-x" | "bump-y" | "cardinal" | "cardinal-closed" | "cardinal-open" | "catmull-rom" | "catmull-rom-closed" | "catmull-rom-open" | "linear" | "linear-closed" | "monotone-x" | "monotone-y" | "natural" | "step" | "step-after" | "step-before"

#ParamBase: {
	"select"?: "value"
}

#ParamRef: string

#ParamLiteral: matchN(>=1, [#Admission_ParamLiteral_0, #Admission_ParamLiteral_1, #Admission_ParamLiteral_2, #Admission_ParamLiteral_3])

#Param: {
	"select"?: "value"
	"value"!:  #ParamValue
}

#ParamValue: matchN(>=1, [#Admission_ParamValue_0, #Admission_ParamValue_1])

#ParamDate: {
	"select"?: "value"
	"date"!:   string
}

#ParamDefinition: matchN(>=1, [#Admission_ParamDefinition_0, #Admission_ParamDefinition_1, #Admission_ParamDefinition_2, #Admission_ParamDefinition_3])

#Selection: {
	"select"!: "crossfilter" | "intersect" | "single" | "union"
	"cross"?:  bool
	"empty"?:  bool
	"include"?: (#ParamRef | [...#ParamRef])
}

#Admission_ParamLiteral_0: null

#Admission_ParamLiteral_1: string

#Admission_ParamLiteral_2: number

#Admission_ParamLiteral_3: bool

#Admission_ParamValue_0: #ParamLiteral

#Admission_ParamValue_1: [...(#ParamLiteral | #ParamRef)]

#Admission_ParamDefinition_0: #ParamValue

#Admission_ParamDefinition_1: #Param

#Admission_ParamDefinition_2: #ParamDate

#Admission_ParamDefinition_3: #Selection

#HConcat: {
	"hconcat"!: [...#Component]
}

#VConcat: {
	"vconcat"!: [...#Component]
}

#HSpace: {
	"hspace"!: (number | string)
}

#VSpace: {
	"vspace"!: (number | string)
}

#DataBaseOptions: {
	"select"?: [...string]
	"where"?: (string | [...string])
	"view"?:    bool
	"temp"?:    bool
	"replace"?: bool
}

#DataQuery: string

#DataDefinition: matchN(>=1, [#Admission_DataDefinition_0, #Admission_DataDefinition_1, #Admission_DataDefinition_2, #Admission_DataDefinition_3, #Admission_DataDefinition_4, #Admission_DataDefinition_5, #Admission_DataDefinition_6, #Admission_DataDefinition_7, #Admission_DataDefinition_8])

#DataFile: {
	"select"?: [...string]
	"where"?: (string | [...string])
	"view"?:    bool
	"temp"?:    bool
	"replace"?: bool
	"file"!:    (string | string | string)
}

#DataArray: [...{...}]

#PlotMarkData: matchN(>=1, [#Admission_PlotMarkData_0, #Admission_PlotMarkData_1])

#DataTable: {
	"select"?: [...string]
	"where"?: (string | [...string])
	"view"?:    bool
	"temp"?:    bool
	"replace"?: bool
	"type"!:    "table"
	"query"!:   string
}

#PlotDataInline: [...]

#DataParquet: {
	"select"?: [...string]
	"where"?: (string | [...string])
	"view"?:    bool
	"temp"?:    bool
	"replace"?: bool
	"type"!:    "parquet"
	"file"!:    string
}

#DataCSV: {
	"select"?: [...string]
	"where"?: (string | [...string])
	"view"?:        bool
	"temp"?:        bool
	"replace"?:     bool
	"type"!:        "csv"
	"file"!:        string
	"delimiter"?:   string
	"sample_size"?: number
}

#DataSpatial: {
	"select"?: [...string]
	"where"?: (string | [...string])
	"view"?:    bool
	"temp"?:    bool
	"replace"?: bool
	"type"!:    "spatial"
	"file"!:    string
	"layer"?:   string
}

#DataJSON: {
	"select"?: [...string]
	"where"?: (string | [...string])
	"view"?:    bool
	"temp"?:    bool
	"replace"?: bool
	"type"!:    "json"
	"file"!:    string
}

#DataJSONObjects: {
	"select"?: [...string]
	"where"?: (string | [...string])
	"view"?:    bool
	"temp"?:    bool
	"replace"?: bool
	"type"?:    "json"
	"data"!: [...{...}]
}

#PlotFrom: {
	"from"!:     (string | #ParamRef)
	"filterBy"?: #ParamRef
	"optimize"?: bool
}

#Admission_DataDefinition_0: #DataQuery

#Admission_DataDefinition_1: #DataArray

#Admission_DataDefinition_2: #DataFile

#Admission_DataDefinition_3: #DataTable

#Admission_DataDefinition_4: #DataParquet

#Admission_DataDefinition_5: #DataCSV

#Admission_DataDefinition_6: #DataSpatial

#Admission_DataDefinition_7: #DataJSON

#Admission_DataDefinition_8: #DataJSONObjects

#Admission_PlotMarkData_0: #PlotDataInline

#Admission_PlotMarkData_1: #PlotFrom

#Admission_Expression_0: #SQLExpression

#Admission_Expression_1: #AggregateExpression

#Admission_TransformField_0: string

#Admission_TransformField_1: #ParamRef

#Admission_TransformField_2: #SQLExpression

#Admission_TransformField_3: #Transform

#Admission_FrameValue_0: number

#Admission_FrameValue_1: #IntervalTransform

#Admission_FrameValue_2: null

#AggregateExpression: {
	"agg"!:   string
	"label"?: string
}

#Bin: {
	"bin"!: (#TransformField | [#TransformField])
	"interval"?: #BinInterval
	"step"?:     number
	"steps"?:    number
	"minstep"?:  number
	"nice"?:     bool
	"offset"?:   number
}

#Centroid: {
	"centroid"!: (#TransformField | [#TransformField])
}

#CentroidX: {
	"centroidX"!: (#TransformField | [#TransformField])
}

#CentroidY: {
	"centroidY"!: (#TransformField | [#TransformField])
}

#Column: {
	"column"!: ((string | #ParamRef) | [(string | #ParamRef)])
}

#DateDay: {
	"dateDay"!: ((#TransformField | time.Time) | [(#TransformField | time.Time)])
}

#DateMonth: {
	"dateMonth"!: ((#TransformField | time.Time) | [(#TransformField | time.Time)])
}

#DateMonthDay: {
	"dateMonthDay"!: ((#TransformField | time.Time) | [(#TransformField | time.Time)])
}

#GeoJSON: {
	"geojson"!: (#TransformField | [#TransformField])
}

#SQLExpression: {
	"sql"!:   string
	"label"?: string
}

#Expression: matchN(>=1, [#Admission_Expression_0, #Admission_Expression_1])

#FrameExclude: "CURRENT ROW" | "GROUP" | "TIES" | "NO OTHERS"

#TransformField: matchN(>=1, [#Admission_TransformField_0, #Admission_TransformField_1, #Admission_TransformField_2, #Admission_TransformField_3])

#BinInterval: "date" | "number" | "millisecond" | "second" | "minute" | "hour" | "day" | "month" | "year"

#WindowOptions: {
	"orderby"?: (#TransformField | [...#TransformField])
	"partitionby"?: (#TransformField | [...#TransformField])
	"rows"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"range"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"groups"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"exclude"?: ("CURRENT ROW" | "GROUP" | "TIES" | "NO OTHERS" | "current row" | "group" | "ties" | "no others")
}

#FrameValue: matchN(>=1, [#Admission_FrameValue_0, #Admission_FrameValue_1, #Admission_FrameValue_2])

#MarginOptions: {
	"top"?:    (number | #ParamRef)
	"right"?:  (number | #ParamRef)
	"bottom"?: (number | #ParamRef)
	"left"?:   (number | #ParamRef)
}

#PlotContainerAttributes: {
	"name"?:            string
	"width"?:           (number | #ParamRef)
	"height"?:          (number | #ParamRef)
	"aspectRatio"?:     (number | bool | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"margins"?:         #MarginOptions
	"inset"?:           (number | #ParamRef)
	"style"?:           (string | #CSSStyles | null | #ParamRef)
	"align"?:           (number | #ParamRef)
	"padding"?:         (number | #ParamRef)
	"axis"?:            ("top" | "right" | "bottom" | "left" | "both" | bool | null | #ParamRef)
	"grid"?:            (bool | string | #ParamRef)
	"ariaLabel"?:       (string | null)
	"ariaDescription"?: (string | null)
	"clip"?:            ("frame" | "sphere" | bool | null | #ParamRef)
}

#Menu: {
	"input"!:     "menu"
	"as"?:        #ParamRef
	"field"?:     string
	"from"?:      string
	"column"?:    string
	"listMatch"?: "any" | "all"
	"filterBy"?:  #ParamRef
	"label"?:     string
	"options"?: [...(_ | {"value"!: _, "label"?: string})]
	"value"?: _
}

#Search: {
	"input"!:    "search"
	"as"?:       #ParamRef
	"field"?:    string
	"type"?:     "contains" | "prefix" | "suffix" | "regexp"
	"from"?:     string
	"column"?:   string
	"filterBy"?: #ParamRef
	"label"?:    string
}

#Slider: {
	"input"!:    "slider"
	"as"?:       #ParamRef
	"field"?:    string
	"select"?:   "point" | "interval"
	"from"?:     string
	"column"?:   string
	"filterBy"?: #ParamRef
	"min"?:      number
	"max"?:      number
	"step"?:     number
	"label"?:    string
	"value"?:    number
	"width"?:    number
}

#Table: {
	"input"!: "table"
	"as"?:    #ParamRef
	"from"!:  (string | #ParamRef)
	"columns"?: [...string]
	"filterBy"?: #ParamRef
	"align"?: {[string]: "left" | "right" | "center" | "justify"}
	"width"?: (number | {[string]: number})
	"maxWidth"?: number
	"height"?:   number
	"rowBatch"?: number
}

#AggregateOptions: {
	"distinct"?: bool
}

#Argmax: {
	"distinct"?: bool
	"orderby"?: (#TransformField | [...#TransformField])
	"partitionby"?: (#TransformField | [...#TransformField])
	"rows"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"range"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"groups"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"exclude"?: ("CURRENT ROW" | "GROUP" | "TIES" | "NO OTHERS" | "current row" | "group" | "ties" | "no others")
	"argmax"!: ([#TransformField, #TransformField])
}

#Argmin: {
	"distinct"?: bool
	"orderby"?: (#TransformField | [...#TransformField])
	"partitionby"?: (#TransformField | [...#TransformField])
	"rows"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"range"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"groups"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"exclude"?: ("CURRENT ROW" | "GROUP" | "TIES" | "NO OTHERS" | "current row" | "group" | "ties" | "no others")
	"argmin"!: ([#TransformField, #TransformField])
}

#Avg: {
	"distinct"?: bool
	"orderby"?: (#TransformField | [...#TransformField])
	"partitionby"?: (#TransformField | [...#TransformField])
	"rows"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"range"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"groups"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"exclude"?: ("CURRENT ROW" | "GROUP" | "TIES" | "NO OTHERS" | "current row" | "group" | "ties" | "no others")
	"avg"!: (#TransformField | [#TransformField])
}

#Count: {
	"distinct"?: bool
	"orderby"?: (#TransformField | [...#TransformField])
	"partitionby"?: (#TransformField | [...#TransformField])
	"rows"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"range"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"groups"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"exclude"?: ("CURRENT ROW" | "GROUP" | "TIES" | "NO OTHERS" | "current row" | "group" | "ties" | "no others")
	"count"!: ((null | []) | (#TransformField | [#TransformField]))
}

#CovarPop: {
	"distinct"?: bool
	"orderby"?: (#TransformField | [...#TransformField])
	"partitionby"?: (#TransformField | [...#TransformField])
	"rows"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"range"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"groups"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"exclude"?: ("CURRENT ROW" | "GROUP" | "TIES" | "NO OTHERS" | "current row" | "group" | "ties" | "no others")
	"covarPop"!: ([#TransformField, #TransformField])
}

#Covariance: {
	"distinct"?: bool
	"orderby"?: (#TransformField | [...#TransformField])
	"partitionby"?: (#TransformField | [...#TransformField])
	"rows"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"range"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"groups"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"exclude"?: ("CURRENT ROW" | "GROUP" | "TIES" | "NO OTHERS" | "current row" | "group" | "ties" | "no others")
	"covariance"!: ([#TransformField, #TransformField])
}

#First: {
	"distinct"?: bool
	"orderby"?: (#TransformField | [...#TransformField])
	"partitionby"?: (#TransformField | [...#TransformField])
	"rows"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"range"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"groups"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"exclude"?: ("CURRENT ROW" | "GROUP" | "TIES" | "NO OTHERS" | "current row" | "group" | "ties" | "no others")
	"first"!: (#TransformField | [#TransformField])
}

#Geomean: {
	"distinct"?: bool
	"orderby"?: (#TransformField | [...#TransformField])
	"partitionby"?: (#TransformField | [...#TransformField])
	"rows"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"range"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"groups"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"exclude"?: ("CURRENT ROW" | "GROUP" | "TIES" | "NO OTHERS" | "current row" | "group" | "ties" | "no others")
	"geomean"!: (#TransformField | [#TransformField])
}

#Last: {
	"distinct"?: bool
	"orderby"?: (#TransformField | [...#TransformField])
	"partitionby"?: (#TransformField | [...#TransformField])
	"rows"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"range"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"groups"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"exclude"?: ("CURRENT ROW" | "GROUP" | "TIES" | "NO OTHERS" | "current row" | "group" | "ties" | "no others")
	"last"!: (#TransformField | [#TransformField])
}

#Max: {
	"distinct"?: bool
	"orderby"?: (#TransformField | [...#TransformField])
	"partitionby"?: (#TransformField | [...#TransformField])
	"rows"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"range"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"groups"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"exclude"?: ("CURRENT ROW" | "GROUP" | "TIES" | "NO OTHERS" | "current row" | "group" | "ties" | "no others")
	"max"!: (#TransformField | [#TransformField])
}

#Median: {
	"distinct"?: bool
	"orderby"?: (#TransformField | [...#TransformField])
	"partitionby"?: (#TransformField | [...#TransformField])
	"rows"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"range"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"groups"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"exclude"?: ("CURRENT ROW" | "GROUP" | "TIES" | "NO OTHERS" | "current row" | "group" | "ties" | "no others")
	"median"!: (#TransformField | [#TransformField])
}

#Min: {
	"distinct"?: bool
	"orderby"?: (#TransformField | [...#TransformField])
	"partitionby"?: (#TransformField | [...#TransformField])
	"rows"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"range"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"groups"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"exclude"?: ("CURRENT ROW" | "GROUP" | "TIES" | "NO OTHERS" | "current row" | "group" | "ties" | "no others")
	"min"!: (#TransformField | [#TransformField])
}

#Mode: {
	"distinct"?: bool
	"orderby"?: (#TransformField | [...#TransformField])
	"partitionby"?: (#TransformField | [...#TransformField])
	"rows"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"range"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"groups"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"exclude"?: ("CURRENT ROW" | "GROUP" | "TIES" | "NO OTHERS" | "current row" | "group" | "ties" | "no others")
	"mode"!: (#TransformField | [#TransformField])
}

#Product: {
	"distinct"?: bool
	"orderby"?: (#TransformField | [...#TransformField])
	"partitionby"?: (#TransformField | [...#TransformField])
	"rows"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"range"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"groups"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"exclude"?: ("CURRENT ROW" | "GROUP" | "TIES" | "NO OTHERS" | "current row" | "group" | "ties" | "no others")
	"product"!: (#TransformField | [#TransformField])
}

#Quantile: {
	"distinct"?: bool
	"orderby"?: (#TransformField | [...#TransformField])
	"partitionby"?: (#TransformField | [...#TransformField])
	"rows"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"range"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"groups"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"exclude"?: ("CURRENT ROW" | "GROUP" | "TIES" | "NO OTHERS" | "current row" | "group" | "ties" | "no others")
	"quantile"!: [#TransformField, (#TransformField | number)]
}

#Stddev: {
	"distinct"?: bool
	"orderby"?: (#TransformField | [...#TransformField])
	"partitionby"?: (#TransformField | [...#TransformField])
	"rows"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"range"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"groups"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"exclude"?: ("CURRENT ROW" | "GROUP" | "TIES" | "NO OTHERS" | "current row" | "group" | "ties" | "no others")
	"stddev"!: (#TransformField | [#TransformField])
}

#StddevPop: {
	"distinct"?: bool
	"orderby"?: (#TransformField | [...#TransformField])
	"partitionby"?: (#TransformField | [...#TransformField])
	"rows"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"range"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"groups"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"exclude"?: ("CURRENT ROW" | "GROUP" | "TIES" | "NO OTHERS" | "current row" | "group" | "ties" | "no others")
	"stddevPop"!: (#TransformField | [#TransformField])
}

#Sum: {
	"distinct"?: bool
	"orderby"?: (#TransformField | [...#TransformField])
	"partitionby"?: (#TransformField | [...#TransformField])
	"rows"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"range"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"groups"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"exclude"?: ("CURRENT ROW" | "GROUP" | "TIES" | "NO OTHERS" | "current row" | "group" | "ties" | "no others")
	"sum"!: (#TransformField | [#TransformField])
}

#VarPop: {
	"distinct"?: bool
	"orderby"?: (#TransformField | [...#TransformField])
	"partitionby"?: (#TransformField | [...#TransformField])
	"rows"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"range"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"groups"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"exclude"?: ("CURRENT ROW" | "GROUP" | "TIES" | "NO OTHERS" | "current row" | "group" | "ties" | "no others")
	"varPop"!: (#TransformField | [#TransformField])
}

#Variance: {
	"distinct"?: bool
	"orderby"?: (#TransformField | [...#TransformField])
	"partitionby"?: (#TransformField | [...#TransformField])
	"rows"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"range"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"groups"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"exclude"?: ("CURRENT ROW" | "GROUP" | "TIES" | "NO OTHERS" | "current row" | "group" | "ties" | "no others")
	"variance"!: (#TransformField | [#TransformField])
}

#Admission_ArgLagLead_0: #TransformField

#Admission_ArgLagLead_1: [#TransformField, (#TransformField | number), (#TransformField | number | bool | time.Time | null)]

#Admission_IntervalTransform_0: #Years

#Admission_IntervalTransform_1: #Months

#Admission_IntervalTransform_2: #Days

#Admission_IntervalTransform_3: #Hours

#Admission_IntervalTransform_4: #Minutes

#Admission_IntervalTransform_5: #Seconds

#Admission_IntervalTransform_6: #Milliseconds

#Admission_IntervalTransform_7: #Microseconds

#CumeDist: {
	"orderby"?: (#TransformField | [...#TransformField])
	"partitionby"?: (#TransformField | [...#TransformField])
	"rows"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"range"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"groups"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"exclude"?: ("CURRENT ROW" | "GROUP" | "TIES" | "NO OTHERS" | "current row" | "group" | "ties" | "no others")
	"cume_dist"!: (null | [])
}

#Days: {
	"days"!: number
}

#DenseRank: {
	"orderby"?: (#TransformField | [...#TransformField])
	"partitionby"?: (#TransformField | [...#TransformField])
	"rows"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"range"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"groups"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"exclude"?: ("CURRENT ROW" | "GROUP" | "TIES" | "NO OTHERS" | "current row" | "group" | "ties" | "no others")
	"dense_rank"!: (null | [])
}

#FirstValue: {
	"orderby"?: (#TransformField | [...#TransformField])
	"partitionby"?: (#TransformField | [...#TransformField])
	"rows"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"range"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"groups"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"exclude"?: ("CURRENT ROW" | "GROUP" | "TIES" | "NO OTHERS" | "current row" | "group" | "ties" | "no others")
	"first_value"!: (#TransformField | [#TransformField])
}

#Hours: {
	"hours"!: number
}

#Lag: {
	"orderby"?: (#TransformField | [...#TransformField])
	"partitionby"?: (#TransformField | [...#TransformField])
	"rows"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"range"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"groups"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"exclude"?: ("CURRENT ROW" | "GROUP" | "TIES" | "NO OTHERS" | "current row" | "group" | "ties" | "no others")
	"lag"!: (#TransformField | [#TransformField, (#TransformField | number), (#TransformField | number | bool | time.Time | null)])
}

#LastValue: {
	"orderby"?: (#TransformField | [...#TransformField])
	"partitionby"?: (#TransformField | [...#TransformField])
	"rows"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"range"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"groups"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"exclude"?: ("CURRENT ROW" | "GROUP" | "TIES" | "NO OTHERS" | "current row" | "group" | "ties" | "no others")
	"last_value"!: (#TransformField | [#TransformField])
}

#Lead: {
	"orderby"?: (#TransformField | [...#TransformField])
	"partitionby"?: (#TransformField | [...#TransformField])
	"rows"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"range"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"groups"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"exclude"?: ("CURRENT ROW" | "GROUP" | "TIES" | "NO OTHERS" | "current row" | "group" | "ties" | "no others")
	"lead"!: (#TransformField | [#TransformField, (#TransformField | number), (#TransformField | number | bool | time.Time | null)])
}

#Microseconds: {
	"microseconds"!: number
}

#Milliseconds: {
	"milliseconds"!: number
}

#Minutes: {
	"minutes"!: number
}

#Months: {
	"months"!: number
}

#NTile: {
	"orderby"?: (#TransformField | [...#TransformField])
	"partitionby"?: (#TransformField | [...#TransformField])
	"rows"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"range"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"groups"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"exclude"?: ("CURRENT ROW" | "GROUP" | "TIES" | "NO OTHERS" | "current row" | "group" | "ties" | "no others")
	"ntile"!: (#TransformField | [#TransformField])
}

#NthValue: {
	"orderby"?: (#TransformField | [...#TransformField])
	"partitionby"?: (#TransformField | [...#TransformField])
	"rows"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"range"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"groups"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"exclude"?: ("CURRENT ROW" | "GROUP" | "TIES" | "NO OTHERS" | "current row" | "group" | "ties" | "no others")
	"nth_value"!: [#TransformField, (#TransformField | number)]
}

#PercentRank: {
	"orderby"?: (#TransformField | [...#TransformField])
	"partitionby"?: (#TransformField | [...#TransformField])
	"rows"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"range"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"groups"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"exclude"?: ("CURRENT ROW" | "GROUP" | "TIES" | "NO OTHERS" | "current row" | "group" | "ties" | "no others")
	"percent_rank"!: (null | [])
}

#Rank: {
	"orderby"?: (#TransformField | [...#TransformField])
	"partitionby"?: (#TransformField | [...#TransformField])
	"rows"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"range"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"groups"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"exclude"?: ("CURRENT ROW" | "GROUP" | "TIES" | "NO OTHERS" | "current row" | "group" | "ties" | "no others")
	"rank"!: (null | [])
}

#IntervalTransform: matchN(>=1, [#Admission_IntervalTransform_0, #Admission_IntervalTransform_1, #Admission_IntervalTransform_2, #Admission_IntervalTransform_3, #Admission_IntervalTransform_4, #Admission_IntervalTransform_5, #Admission_IntervalTransform_6, #Admission_IntervalTransform_7])

#RowNumber: {
	"orderby"?: (#TransformField | [...#TransformField])
	"partitionby"?: (#TransformField | [...#TransformField])
	"rows"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"range"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"groups"?: ([#FrameValue, #FrameValue] | #ParamRef)
	"exclude"?: ("CURRENT ROW" | "GROUP" | "TIES" | "NO OTHERS" | "current row" | "group" | "ties" | "no others")
	"row_number"!: (null | [])
}

#ArgLagLead: matchN(>=1, [#Admission_ArgLagLead_0, #Admission_ArgLagLead_1])

#Seconds: {
	"seconds"!: number
}

#Years: {
	"years"!: number
}

#CartesianAttributes: {
	"xScale"?: (#PositionScaleType | null | #ParamRef)
	"xDomain"?: ([...] | #Fixed | #ParamRef)
	"xRange"?: ([...] | #Fixed | #ParamRef)
	"xNice"?:         (bool | number | #Interval | #ParamRef)
	"xInset"?:        (number | #ParamRef)
	"xInsetRight"?:   (number | #ParamRef)
	"xInsetLeft"?:    (number | #ParamRef)
	"xClamp"?:        (bool | #ParamRef)
	"xRound"?:        (bool | #ParamRef)
	"xAlign"?:        (number | #ParamRef)
	"xPadding"?:      (number | #ParamRef)
	"xPaddingInner"?: (number | #ParamRef)
	"xPaddingOuter"?: (number | #ParamRef)
	"xAxis"?:         ("top" | "bottom" | "both" | bool | null | #ParamRef)
	"xTicks"?: (number | #Interval | [...] | #ParamRef)
	"xTickSize"?:    (number | #ParamRef)
	"xTickSpacing"?: (number | #ParamRef)
	"xTickPadding"?: (number | #ParamRef)
	"xTickFormat"?:  (string | null | #ParamRef)
	"xTickRotate"?:  (number | #ParamRef)
	"xGrid"?: (bool | string | #Interval | [...] | #ParamRef)
	"xLine"?:            (bool | #ParamRef)
	"xLabel"?:           (string | null | #ParamRef)
	"xLabelAnchor"?:     ("top" | "right" | "bottom" | "left" | "center" | #ParamRef)
	"xLabelArrow"?:      (#LabelArrow | #ParamRef)
	"xLabelOffset"?:     (number | #ParamRef)
	"xFontVariant"?:     (string | #ParamRef)
	"xAriaLabel"?:       (string | #ParamRef)
	"xAriaDescription"?: (string | #ParamRef)
	"xPercent"?:         (bool | #ParamRef)
	"xReverse"?:         (bool | #ParamRef)
	"xZero"?:            (bool | #ParamRef)
	"xExponent"?:        (number | #ParamRef)
	"xBase"?:            (number | #ParamRef)
	"xConstant"?:        (number | #ParamRef)
	"yScale"?:           (#PositionScaleType | null | #ParamRef)
	"yDomain"?: ([...] | #Fixed | #ParamRef)
	"yRange"?: ([...] | #Fixed | #ParamRef)
	"yNice"?:         (bool | number | #Interval | #ParamRef)
	"yInset"?:        (number | #ParamRef)
	"yInsetTop"?:     (number | #ParamRef)
	"yInsetBottom"?:  (number | #ParamRef)
	"yClamp"?:        (bool | #ParamRef)
	"yRound"?:        (bool | #ParamRef)
	"yAlign"?:        (number | #ParamRef)
	"yPadding"?:      (number | #ParamRef)
	"yPaddingInner"?: (number | #ParamRef)
	"yPaddingOuter"?: (number | #ParamRef)
	"yAxis"?:         ("left" | "right" | "both" | bool | null | #ParamRef)
	"yTicks"?: (number | #Interval | [...] | #ParamRef)
	"yTickSize"?:    (number | #ParamRef)
	"yTickSpacing"?: (number | #ParamRef)
	"yTickPadding"?: (number | #ParamRef)
	"yTickFormat"?:  (string | null | #ParamRef)
	"yTickRotate"?:  (number | #ParamRef)
	"yGrid"?: (bool | string | #Interval | [...] | #ParamRef)
	"yLine"?:            (bool | #ParamRef)
	"yLabel"?:           (string | null | #ParamRef)
	"yLabelAnchor"?:     ("top" | "right" | "bottom" | "left" | "center" | #ParamRef)
	"yLabelArrow"?:      (#LabelArrow | #ParamRef)
	"yLabelOffset"?:     (number | #ParamRef)
	"yFontVariant"?:     (string | #ParamRef)
	"yAriaLabel"?:       (string | #ParamRef)
	"yAriaDescription"?: (string | #ParamRef)
	"yPercent"?:         (bool | #ParamRef)
	"yReverse"?:         (bool | #ParamRef)
	"yZero"?:            (bool | #ParamRef)
	"yExponent"?:        (number | #ParamRef)
	"yBase"?:            (number | #ParamRef)
	"yConstant"?:        (number | #ParamRef)
	"xyDomain"?: ([...] | #Fixed | #ParamRef)
}

#LabelArrow: matchN(>=1, [#Admission_LabelArrow_0, #Admission_LabelArrow_1, #Admission_LabelArrow_2, #Admission_LabelArrow_3, #Admission_LabelArrow_4, #Admission_LabelArrow_5, #Admission_LabelArrow_6, #Admission_LabelArrow_7, #Admission_LabelArrow_8])

#Admission_LabelArrow_0: "auto"

#Admission_LabelArrow_1: "up"

#Admission_LabelArrow_2: "right"

#Admission_LabelArrow_3: "down"

#Admission_LabelArrow_4: "left"

#Admission_LabelArrow_5: "none"

#Admission_LabelArrow_6: true

#Admission_LabelArrow_7: false

#Admission_LabelArrow_8: null

#ColorAttributes: {
	"colorScale"?: (#ColorScaleType | null | #ParamRef)
	"colorDomain"?: ([...] | #Fixed | #ParamRef)
	"colorRange"?: ([...] | #Fixed | #ParamRef)
	"colorClamp"?:       (bool | #ParamRef)
	"colorN"?:           (number | #ParamRef)
	"colorNice"?:        (bool | number | #Interval | #ParamRef)
	"colorScheme"?:      (#ColorScheme | #ParamRef)
	"colorInterpolate"?: (#Interpolate | #ParamRef)
	"colorPivot"?:       (_ | #ParamRef)
	"colorSymmetric"?:   (bool | #ParamRef)
	"colorLabel"?:       (string | null | #ParamRef)
	"colorPercent"?:     (bool | #ParamRef)
	"colorReverse"?:     (bool | #ParamRef)
	"colorZero"?:        (bool | #ParamRef)
	"colorTickFormat"?:  (string | null | #ParamRef)
	"colorExponent"?:    (number | #ParamRef)
	"colorBase"?:        (number | #ParamRef)
	"colorConstant"?:    (number | #ParamRef)
	"opacityScale"?:     (#ContinuousScaleType | null | #ParamRef)
	"opacityDomain"?: ([...] | #Fixed | #ParamRef)
	"opacityRange"?: ([...] | #Fixed | #ParamRef)
	"opacityClamp"?:      (bool | #ParamRef)
	"opacityNice"?:       (bool | number | #Interval | #ParamRef)
	"opacityLabel"?:      (string | null | #ParamRef)
	"opacityPercent"?:    (bool | #ParamRef)
	"opacityReverse"?:    (bool | #ParamRef)
	"opacityZero"?:       (bool | #ParamRef)
	"opacityTickFormat"?: (string | null | #ParamRef)
	"opacityExponent"?:   (number | #ParamRef)
	"opacityBase"?:       (number | #ParamRef)
	"opacityConstant"?:   (number | #ParamRef)
	"symbolScale"?:       (#DiscreteScaleType | null | #ParamRef)
	"symbolDomain"?: ([...] | #Fixed | #ParamRef)
	"symbolRange"?: ([...] | #Fixed | #ParamRef)
}

#SizeAttributes: {
	"rScale"?: (#ContinuousScaleType | null | #ParamRef)
	"rDomain"?: ([...] | #Fixed | #ParamRef)
	"rRange"?: ([...] | #Fixed | #ParamRef)
	"rClamp"?:      _
	"rNice"?:       (bool | number | #Interval | #ParamRef)
	"rLabel"?:      (string | null | #ParamRef)
	"rPercent"?:    (bool | #ParamRef)
	"rZero"?:       (bool | #ParamRef)
	"rExponent"?:   (number | #ParamRef)
	"rBase"?:       (number | #ParamRef)
	"rConstant"?:   (number | #ParamRef)
	"lengthScale"?: (#ContinuousScaleType | null | #ParamRef)
	"lengthDomain"?: ([...] | #Fixed | #ParamRef)
	"lengthRange"?: ([...] | #Fixed | #ParamRef)
	"lengthClamp"?:    _
	"lengthNice"?:     (bool | number | #Interval | #ParamRef)
	"lengthPercent"?:  (bool | #ParamRef)
	"lengthZero"?:     (bool | #ParamRef)
	"lengthExponent"?: (number | #ParamRef)
	"lengthBase"?:     (number | #ParamRef)
	"lengthConstant"?: (number | #ParamRef)
}

#ProjectionAttributes: {
	"projectionType"?: (#ProjectionName | null | #ParamRef)
	"projectionDomain"?: ({...} | #ParamRef)
	"projectionRotate"?: ([(number | #ParamRef), (number | #ParamRef), (number | #ParamRef)] | #ParamRef)
	"projectionParallels"?: ([(number | #ParamRef), (number | #ParamRef)] | #ParamRef)
	"projectionPrecision"?:   (number | #ParamRef)
	"projectionClip"?:        (bool | number | "frame" | null | #ParamRef)
	"projectionInset"?:       (number | #ParamRef)
	"projectionInsetTop"?:    (number | #ParamRef)
	"projectionInsetRight"?:  (number | #ParamRef)
	"projectionInsetBottom"?: (number | #ParamRef)
	"projectionInsetLeft"?:   (number | #ParamRef)
}

#FacetAttributes: {
	"facetMargin"?:       (number | #ParamRef)
	"facetMarginTop"?:    (number | #ParamRef)
	"facetMarginBottom"?: (number | #ParamRef)
	"facetMarginLeft"?:   (number | #ParamRef)
	"facetMarginRight"?:  (number | #ParamRef)
	"facetGrid"?: (bool | string | #Interval | [...] | #ParamRef)
	"facetLabel"?: (string | null | #ParamRef)
	"fxDomain"?: ([...] | #Fixed | #ParamRef)
	"fxRange"?: ([...] | #Fixed | #ParamRef)
	"fxInset"?:        (number | #ParamRef)
	"fxInsetRight"?:   (number | #ParamRef)
	"fxInsetLeft"?:    (number | #ParamRef)
	"fxRound"?:        (bool | #ParamRef)
	"fxAlign"?:        (number | #ParamRef)
	"fxPadding"?:      (number | #ParamRef)
	"fxPaddingInner"?: (number | #ParamRef)
	"fxPaddingOuter"?: (number | #ParamRef)
	"fxAxis"?:         ("top" | "bottom" | "both" | bool | null | #ParamRef)
	"fxTicks"?: (number | #Interval | [...] | #ParamRef)
	"fxTickSize"?:    (number | #ParamRef)
	"fxTickSpacing"?: (number | #ParamRef)
	"fxTickPadding"?: (number | #ParamRef)
	"fxTickFormat"?:  (string | null | #ParamRef)
	"fxTickRotate"?:  (number | #ParamRef)
	"fxGrid"?: (bool | string | #Interval | [...] | #ParamRef)
	"fxLine"?:            (bool | #ParamRef)
	"fxLabel"?:           (string | null | #ParamRef)
	"fxLabelAnchor"?:     ("top" | "right" | "bottom" | "left" | "center" | #ParamRef)
	"fxLabelOffset"?:     (number | #ParamRef)
	"fxFontVariant"?:     (string | #ParamRef)
	"fxAriaLabel"?:       (string | #ParamRef)
	"fxAriaDescription"?: (string | #ParamRef)
	"fxReverse"?:         (bool | #ParamRef)
	"fyDomain"?: ([...] | #Fixed | #ParamRef)
	"fyRange"?: ([...] | #Fixed | #ParamRef)
	"fyInset"?:        (number | #ParamRef)
	"fyInsetTop"?:     (number | #ParamRef)
	"fyInsetBottom"?:  (number | #ParamRef)
	"fyRound"?:        (bool | #ParamRef)
	"fyAlign"?:        (number | #ParamRef)
	"fyPadding"?:      (number | #ParamRef)
	"fyPaddingInner"?: (number | #ParamRef)
	"fyPaddingOuter"?: (number | #ParamRef)
	"fyAxis"?:         ("left" | "right" | "both" | bool | null | #ParamRef)
	"fyTicks"?: (number | #Interval | [...] | #ParamRef)
	"fyTickSize"?:    (number | #ParamRef)
	"fyTickSpacing"?: (number | #ParamRef)
	"fyTickPadding"?: (number | #ParamRef)
	"fyTickFormat"?:  (string | null | #ParamRef)
	"fyTickRotate"?:  (number | #ParamRef)
	"fyGrid"?: (bool | string | #Interval | [...] | #ParamRef)
	"fyLine"?:            (bool | #ParamRef)
	"fyLabel"?:           (string | null | #ParamRef)
	"fyLabelAnchor"?:     ("top" | "right" | "bottom" | "left" | "center" | #ParamRef)
	"fyLabelOffset"?:     (number | #ParamRef)
	"fyFontVariant"?:     (string | #ParamRef)
	"fyAriaLabel"?:       (string | #ParamRef)
	"fyAriaDescription"?: (string | #ParamRef)
	"fyReverse"?:         (bool | #ParamRef)
}

#ChannelDomainOptions: {
	"reduce"?:  (#Reducer | bool | null)
	"order"?:   ("ascending" | "descending" | null)
	"reverse"?: bool
	"limit"?: (number | [number, number])
}

#ChannelName: "ariaLabel" | "fill" | "fillOpacity" | "fontSize" | "fx" | "fy" | "geometry" | "height" | "href" | "length" | "opacity" | "path" | "r" | "rotate" | "src" | "stroke" | "strokeOpacity" | "strokeWidth" | "symbol" | "text" | "title" | "weight" | "width" | "x" | "x1" | "x2" | "y" | "y1" | "y2" | "z"

#ChannelScale: matchN(>=1, [#Admission_ChannelScale_0, #Admission_ChannelScale_1, #Admission_ChannelScale_2, #Admission_ChannelScale_3])

#MarkData: {
	"data"!: #PlotMarkData
}

#ChannelDomainSort: {"x"?: #ChannelDomainValueSpec, "y"?: #ChannelDomainValueSpec, "fx"?: #ChannelDomainValueSpec, "fy"?: #ChannelDomainValueSpec, "r"?: #ChannelDomainValueSpec, "color"?: #ChannelDomainValueSpec, "opacity"?: #ChannelDomainValueSpec, "symbol"?: #ChannelDomainValueSpec, "length"?: #ChannelDomainValueSpec, "reduce"?: (#Reducer | bool | null), "order"?: ("ascending" | "descending" | null), "reverse"?: bool, "limit"?: (number | [number, number])}

#ChannelValue: matchN(>=1, [#Admission_ChannelValue_0, #Admission_ChannelValue_1, #Admission_ChannelValue_2, #Admission_ChannelValue_3, #Admission_ChannelValue_4, #Admission_ChannelValue_5, #Admission_ChannelValue_6, #Admission_ChannelValue_7])

#MarkDataOptional: {
	"data"?: #PlotMarkData
}

#ChannelReducers: {"ariaLabel"?: (#Reducer | {"reduce"!: #Reducer, "scale"?: #ChannelScale} | null), "fill"?: (#Reducer | {"reduce"!: #Reducer, "scale"?: #ChannelScale} | null), "fillOpacity"?: (#Reducer | {"reduce"!: #Reducer, "scale"?: #ChannelScale} | null), "fontSize"?: (#Reducer | {"reduce"!: #Reducer, "scale"?: #ChannelScale} | null), "fx"?: (#Reducer | {"reduce"!: #Reducer, "scale"?: #ChannelScale} | null), "fy"?: (#Reducer | {"reduce"!: #Reducer, "scale"?: #ChannelScale} | null), "geometry"?: (#Reducer | {"reduce"!: #Reducer, "scale"?: #ChannelScale} | null), "height"?: (#Reducer | {"reduce"!: #Reducer, "scale"?: #ChannelScale} | null), "href"?: (#Reducer | {"reduce"!: #Reducer, "scale"?: #ChannelScale} | null), "length"?: (#Reducer | {"reduce"!: #Reducer, "scale"?: #ChannelScale} | null), "opacity"?: (#Reducer | {"reduce"!: #Reducer, "scale"?: #ChannelScale} | null), "path"?: (#Reducer | {"reduce"!: #Reducer, "scale"?: #ChannelScale} | null), "r"?: (#Reducer | {"reduce"!: #Reducer, "scale"?: #ChannelScale} | null), "rotate"?: (#Reducer | {"reduce"!: #Reducer, "scale"?: #ChannelScale} | null), "src"?: (#Reducer | {"reduce"!: #Reducer, "scale"?: #ChannelScale} | null), "stroke"?: (#Reducer | {"reduce"!: #Reducer, "scale"?: #ChannelScale} | null), "strokeOpacity"?: (#Reducer | {"reduce"!: #Reducer, "scale"?: #ChannelScale} | null), "strokeWidth"?: (#Reducer | {"reduce"!: #Reducer, "scale"?: #ChannelScale} | null), "symbol"?: (#Reducer | {"reduce"!: #Reducer, "scale"?: #ChannelScale} | null), "text"?: (#Reducer | {"reduce"!: #Reducer, "scale"?: #ChannelScale} | null), "title"?: (#Reducer | {"reduce"!: #Reducer, "scale"?: #ChannelScale} | null), "weight"?: (#Reducer | {"reduce"!: #Reducer, "scale"?: #ChannelScale} | null), "width"?: (#Reducer | {"reduce"!: #Reducer, "scale"?: #ChannelScale} | null), "x"?: (#Reducer | {"reduce"!: #Reducer, "scale"?: #ChannelScale} | null), "x1"?: (#Reducer | {"reduce"!: #Reducer, "scale"?: #ChannelScale} | null), "x2"?: (#Reducer | {"reduce"!: #Reducer, "scale"?: #ChannelScale} | null), "y"?: (#Reducer | {"reduce"!: #Reducer, "scale"?: #ChannelScale} | null), "y1"?: (#Reducer | {"reduce"!: #Reducer, "scale"?: #ChannelScale} | null), "y2"?: (#Reducer | {"reduce"!: #Reducer, "scale"?: #ChannelScale} | null), "z"?: (#Reducer | {"reduce"!: #Reducer, "scale"?: #ChannelScale} | null)}

#ChannelValueSpec: matchN(>=1, [#Admission_ChannelValueSpec_0, #Admission_ChannelValueSpec_1])

#MarkOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
}

#ChannelStates: {"ariaLabel"?: {"value"!: [...], "scale"!: (#ScaleName | null)}, "fill"?: {"value"!: [...], "scale"!: (#ScaleName | null)}, "fillOpacity"?: {"value"!: [...], "scale"!: (#ScaleName | null)}, "fontSize"?: {"value"!: [...], "scale"!: (#ScaleName | null)}, "fx"?: {"value"!: [...], "scale"!: (#ScaleName | null)}, "fy"?: {"value"!: [...], "scale"!: (#ScaleName | null)}, "geometry"?: {"value"!: [...], "scale"!: (#ScaleName | null)}, "height"?: {"value"!: [...], "scale"!: (#ScaleName | null)}, "href"?: {"value"!: [...], "scale"!: (#ScaleName | null)}, "length"?: {"value"!: [...], "scale"!: (#ScaleName | null)}, "opacity"?: {"value"!: [...], "scale"!: (#ScaleName | null)}, "path"?: {"value"!: [...], "scale"!: (#ScaleName | null)}, "r"?: {"value"!: [...], "scale"!: (#ScaleName | null)}, "rotate"?: {"value"!: [...], "scale"!: (#ScaleName | null)}, "src"?: {"value"!: [...], "scale"!: (#ScaleName | null)}, "stroke"?: {"value"!: [...], "scale"!: (#ScaleName | null)}, "strokeOpacity"?: {"value"!: [...], "scale"!: (#ScaleName | null)}, "strokeWidth"?: {"value"!: [...], "scale"!: (#ScaleName | null)}, "symbol"?: {"value"!: [...], "scale"!: (#ScaleName | null)}, "text"?: {"value"!: [...], "scale"!: (#ScaleName | null)}, "title"?: {"value"!: [...], "scale"!: (#ScaleName | null)}, "weight"?: {"value"!: [...], "scale"!: (#ScaleName | null)}, "width"?: {"value"!: [...], "scale"!: (#ScaleName | null)}, "x"?: {"value"!: [...], "scale"!: (#ScaleName | null)}, "x1"?: {"value"!: [...], "scale"!: (#ScaleName | null)}, "x2"?: {"value"!: [...], "scale"!: (#ScaleName | null)}, "y"?: {"value"!: [...], "scale"!: (#ScaleName | null)}, "y1"?: {"value"!: [...], "scale"!: (#ScaleName | null)}, "y2"?: {"value"!: [...], "scale"!: (#ScaleName | null)}, "z"?: {"value"!: [...], "scale"!: (#ScaleName | null)}}

#ChannelValueIntervalSpec: matchN(>=1, [#Admission_ChannelValueIntervalSpec_0, #Admission_ChannelValueIntervalSpec_1])

#InsetOptions: {
	"inset"?:       (number | #ParamRef)
	"insetTop"?:    (number | #ParamRef)
	"insetRight"?:  (number | #ParamRef)
	"insetBottom"?: (number | #ParamRef)
	"insetLeft"?:   (number | #ParamRef)
}

#ChannelValues: {"ariaLabel"?: [...], "fill"?: [...], "fillOpacity"?: [...], "fontSize"?: [...], "fx"?: [...], "fy"?: [...], "geometry"?: [...], "height"?: [...], "href"?: [...], "length"?: [...], "opacity"?: [...], "path"?: [...], "r"?: [...], "rotate"?: [...], "src"?: [...], "stroke"?: [...], "strokeOpacity"?: [...], "strokeWidth"?: [...], "symbol"?: [...], "text"?: [...], "title"?: [...], "weight"?: [...], "width"?: [...], "x"?: [...], "x1"?: [...], "x2"?: [...], "y"?: [...], "y1"?: [...], "y2"?: [...], "z"?: [...], "channels"!: #ChannelStates}

#ChannelDomainName: matchN(>=1, [#Admission_ChannelDomainName_0, #Admission_ChannelDomainName_1, #Admission_ChannelDomainName_2, #Admission_ChannelDomainName_3])

#MarkerName: "arrow" | "arrow-reverse" | "dot" | "circle" | "circle-fill" | "circle-stroke" | "tick" | "tick-x" | "tick-y"

#TextStyles: {
	"textAnchor"?:   ("start" | "middle" | "end" | #ParamRef)
	"lineHeight"?:   (number | #ParamRef)
	"lineWidth"?:    (number | #ParamRef)
	"textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef)
	"monospace"?:    (bool | #ParamRef)
	"fontFamily"?:   (string | #ParamRef)
	"fontSize"?:     (#ChannelValue | #ParamRef)
	"fontStyle"?:    (string | #ParamRef)
	"fontVariant"?:  (string | #ParamRef)
	"fontWeight"?:   (string | number | #ParamRef)
}

#TipPointer: "x" | "y" | "xy"

#ChannelDomainValue: matchN(>=1, [#Admission_ChannelDomainValue_0, #Admission_ChannelDomainValue_1, #Admission_ChannelDomainValue_2])

#TipOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"textAnchor"?:       ("start" | "middle" | "end" | #ParamRef)
	"lineHeight"?:       (number | #ParamRef)
	"lineWidth"?:        (number | #ParamRef)
	"textOverflow"?:     (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef)
	"monospace"?:        (bool | #ParamRef)
	"fontFamily"?:       (string | #ParamRef)
	"fontSize"?:         (#ChannelValue | #ParamRef)
	"fontStyle"?:        (string | #ParamRef)
	"fontVariant"?:      (string | #ParamRef)
	"fontWeight"?:       (string | number | #ParamRef)
	"x"?:                #ChannelValueSpec
	"x1"?:               #ChannelValueSpec
	"x2"?:               #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"y1"?:               #ChannelValueSpec
	"y2"?:               #ChannelValueSpec
	"frameAnchor"?:      (#FrameAnchor | #ParamRef)
	"anchor"?:           (#FrameAnchor | #ParamRef)
	"preferredAnchor"?:  (#FrameAnchor | null | #ParamRef)
	"format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}
	"pathFilter"?:  (string | #ParamRef)
	"pointerSize"?: (number | #ParamRef)
	"textPadding"?: (number | #ParamRef)
}

#SelectFilter: "first" | "last" | "maxX" | "maxY" | "minX" | "minY" | "nearest" | "nearestX" | "nearestY"

#ChannelDomainValueSpec: matchN(>=1, [#Admission_ChannelDomainValueSpec_0, #Admission_ChannelDomainValueSpec_1])

#CurveOptions: {
	"curve"?:   (#Curve | #ParamRef)
	"tension"?: (number | #ParamRef)
}

#Curve: #CurveName

#SortOrder: matchN(>=1, [#Admission_SortOrder_0, #Admission_SortOrder_1, #Admission_SortOrder_2])

#CurveAutoOptions: {
	"curve"?:   (#Curve | "auto" | #ParamRef)
	"tension"?: (number | #ParamRef)
}

#StackOffsetName: "center" | "normalize" | "wiggle"

#StackOrder: matchN(>=1, [#Admission_StackOrder_0, #Admission_StackOrder_1, #Admission_StackOrder_2, #Admission_StackOrder_3])

#StackOptions: {
	"offset"?:  (#StackOffset | null | #ParamRef)
	"order"?:   (#StackOrder | null | #ParamRef)
	"reverse"?: (bool | #ParamRef)
	"z"?:       #ChannelValue
}

#StackOffset: #StackOffsetName

#MarkerOptions: {
	"marker"?:      (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?: (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:   (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:   (#MarkerName | "none" | bool | null | #ParamRef)
}

#StackOrderName: "value" | "x" | "y" | "z" | "sum" | "appearance" | "inside-out"

#Admission_ChannelScale_0: #ScaleName

#Admission_ChannelScale_1: "auto"

#Admission_ChannelScale_2: bool

#Admission_ChannelScale_3: null

#Admission_ChannelValue_0: [...]

#Admission_ChannelValue_1: string

#Admission_ChannelValue_2: number

#Admission_ChannelValue_3: bool

#Admission_ChannelValue_4: null

#Admission_ChannelValue_5: #Transform

#Admission_ChannelValue_6: #SQLExpression

#Admission_ChannelValue_7: #AggregateExpression

#Admission_ChannelValueSpec_0: #ChannelValue

#Admission_ChannelValueSpec_1: {"value"!: #ChannelValue, "label"?: string, "scale"?: (#ScaleName | "auto" | bool | null)}

#Admission_ChannelValueIntervalSpec_0: #ChannelValueSpec

#Admission_ChannelValueIntervalSpec_1: {"value"!: #ChannelValue, "interval"!: #Interval}

#Admission_ChannelDomainName_0: #ChannelName

#Admission_ChannelDomainName_1: "data"

#Admission_ChannelDomainName_2: "width"

#Admission_ChannelDomainName_3: "height"

#Admission_ChannelDomainValue_0: #ChannelDomainName

#Admission_ChannelDomainValue_1: "-ariaLabel" | "-fill" | "-fillOpacity" | "-fontSize" | "-fx" | "-fy" | "-geometry" | "-height" | "-href" | "-length" | "-opacity" | "-path" | "-r" | "-rotate" | "-src" | "-stroke" | "-strokeOpacity" | "-strokeWidth" | "-symbol" | "-text" | "-title" | "-weight" | "-width" | "-x" | "-x1" | "-x2" | "-y" | "-y1" | "-y2" | "-z" | "-data"

#Admission_ChannelDomainValue_2: null

#Admission_ChannelDomainValueSpec_0: #ChannelDomainValue

#Admission_ChannelDomainValueSpec_1: {"value"!: #ChannelDomainValue, "reduce"?: (#Reducer | bool | null), "order"?: ("ascending" | "descending" | null), "reverse"?: bool, "limit"?: (number | [number, number])}

#Admission_SortOrder_0: #ChannelValue

#Admission_SortOrder_1: {"value"?: #ChannelValue, "order"?: "ascending" | "descending"}

#Admission_SortOrder_2: {"channel"?: (#ChannelName | "-ariaLabel" | "-fill" | "-fillOpacity" | "-fontSize" | "-fx" | "-fy" | "-geometry" | "-height" | "-href" | "-length" | "-opacity" | "-path" | "-r" | "-rotate" | "-src" | "-stroke" | "-strokeOpacity" | "-strokeWidth" | "-symbol" | "-text" | "-title" | "-weight" | "-width" | "-x" | "-x1" | "-x2" | "-y" | "-y1" | "-y2" | "-z"), "order"?: "ascending" | "descending"}

#Admission_StackOrder_0: #StackOrderName

#Admission_StackOrder_1: "-value" | "-x" | "-y" | "-z" | "-sum" | "-appearance" | "-inside-out"

#Admission_StackOrder_2: string

#Admission_StackOrder_3: [...]

#AreaOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"offset"?:           (#StackOffset | null | #ParamRef)
	"order"?:            (#StackOrder | null | #ParamRef)
	"z"?:                #ChannelValue
	"curve"?:            (#Curve | #ParamRef)
	"tension"?:          (number | #ParamRef)
	"x1"?:               #ChannelValueSpec
	"x2"?:               #ChannelValueSpec
	"y1"?:               #ChannelValueSpec
	"y2"?:               #ChannelValueSpec
}

#AreaXOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"offset"?:           (#StackOffset | null | #ParamRef)
	"order"?:            (#StackOrder | null | #ParamRef)
	"z"?:                #ChannelValue
	"curve"?:            (#Curve | #ParamRef)
	"tension"?:          (number | #ParamRef)
	"x1"?:               #ChannelValueSpec
	"x2"?:               #ChannelValueSpec
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
}

#AreaYOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"offset"?:           (#StackOffset | null | #ParamRef)
	"order"?:            (#StackOrder | null | #ParamRef)
	"z"?:                #ChannelValue
	"curve"?:            (#Curve | #ParamRef)
	"tension"?:          (number | #ParamRef)
	"y1"?:               #ChannelValueSpec
	"y2"?:               #ChannelValueSpec
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
}

#Area: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"offset"?:           (#StackOffset | null | #ParamRef)
	"order"?:            (#StackOrder | null | #ParamRef)
	"z"?:                #ChannelValue
	"curve"?:            (#Curve | #ParamRef)
	"tension"?:          (number | #ParamRef)
	"x1"?:               #ChannelValueSpec
	"x2"?:               #ChannelValueSpec
	"y1"?:               #ChannelValueSpec
	"y2"?:               #ChannelValueSpec
	"mark"!:             "area"
}

#AreaX: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"offset"?:           (#StackOffset | null | #ParamRef)
	"order"?:            (#StackOrder | null | #ParamRef)
	"z"?:                #ChannelValue
	"curve"?:            (#Curve | #ParamRef)
	"tension"?:          (number | #ParamRef)
	"x1"?:               #ChannelValueSpec
	"x2"?:               #ChannelValueSpec
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"mark"!:             "areaX"
}

#AreaY: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"offset"?:           (#StackOffset | null | #ParamRef)
	"order"?:            (#StackOrder | null | #ParamRef)
	"z"?:                #ChannelValue
	"curve"?:            (#Curve | #ParamRef)
	"tension"?:          (number | #ParamRef)
	"y1"?:               #ChannelValueSpec
	"y2"?:               #ChannelValueSpec
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"mark"!:             "areaY"
}

#LineOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"marker"?:           (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:      (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"curve"?:            (#Curve | "auto" | #ParamRef)
	"tension"?:          (number | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"z"?:                #ChannelValue
}

#LineXOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"marker"?:           (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:      (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"curve"?:            (#Curve | "auto" | #ParamRef)
	"tension"?:          (number | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"z"?:                #ChannelValue
}

#LineYOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"marker"?:           (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:      (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"curve"?:            (#Curve | "auto" | #ParamRef)
	"tension"?:          (number | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"z"?:                #ChannelValue
}

#Line: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"marker"?:           (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:      (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"curve"?:            (#Curve | "auto" | #ParamRef)
	"tension"?:          (number | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"z"?:                #ChannelValue
	"mark"!:             "line"
}

#LineX: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"marker"?:           (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:      (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"curve"?:            (#Curve | "auto" | #ParamRef)
	"tension"?:          (number | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"z"?:                #ChannelValue
	"mark"!:             "lineX"
}

#LineY: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"marker"?:           (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:      (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"curve"?:            (#Curve | "auto" | #ParamRef)
	"tension"?:          (number | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"z"?:                #ChannelValue
	"mark"!:             "lineY"
}

#ArrowOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"x1"?:               #ChannelValueSpec
	"y1"?:               #ChannelValueSpec
	"x2"?:               #ChannelValueSpec
	"y2"?:               #ChannelValueSpec
	"bend"?:             (number | bool | #ParamRef)
	"headAngle"?:        (number | #ParamRef)
	"headLength"?:       (number | #ParamRef)
	"inset"?:            (number | #ParamRef)
	"insetStart"?:       (number | #ParamRef)
	"insetEnd"?:         (number | #ParamRef)
	"sweep"?:            (number | "+x" | "-x" | "+y" | "-y" | #ParamRef)
}

#Arrow: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"x1"?:               #ChannelValueSpec
	"y1"?:               #ChannelValueSpec
	"x2"?:               #ChannelValueSpec
	"y2"?:               #ChannelValueSpec
	"bend"?:             (number | bool | #ParamRef)
	"headAngle"?:        (number | #ParamRef)
	"headLength"?:       (number | #ParamRef)
	"inset"?:            (number | #ParamRef)
	"insetStart"?:       (number | #ParamRef)
	"insetEnd"?:         (number | #ParamRef)
	"sweep"?:            (number | "+x" | "-x" | "+y" | "-y" | #ParamRef)
	"mark"!:             "arrow"
}

#LinkOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"marker"?:           (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:      (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"curve"?:            ((#Curve | "auto" | #ParamRef) | #ParamRef)
	"tension"?:          (number | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"x1"?:               #ChannelValueSpec
	"y1"?:               #ChannelValueSpec
	"x2"?:               #ChannelValueSpec
	"y2"?:               #ChannelValueSpec
}

#Link: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"marker"?:           (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:      (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"curve"?:            ((#Curve | "auto" | #ParamRef) | #ParamRef)
	"tension"?:          (number | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"x1"?:               #ChannelValueSpec
	"y1"?:               #ChannelValueSpec
	"x2"?:               #ChannelValueSpec
	"y2"?:               #ChannelValueSpec
	"mark"!:             "link"
}

#BarOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"inset"?:            (number | #ParamRef)
	"insetTop"?:         (number | #ParamRef)
	"insetRight"?:       (number | #ParamRef)
	"insetBottom"?:      (number | #ParamRef)
	"insetLeft"?:        (number | #ParamRef)
	"rx"?:               (number | string | #ParamRef)
	"ry"?:               (number | string | #ParamRef)
	"offset"?:           (#StackOffset | null | #ParamRef)
	"order"?:            (#StackOrder | null | #ParamRef)
	"z"?:                #ChannelValue
	"interval"?:         (#Interval | #ParamRef)
}

#BarXOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"inset"?:            (number | #ParamRef)
	"insetTop"?:         (number | #ParamRef)
	"insetRight"?:       (number | #ParamRef)
	"insetBottom"?:      (number | #ParamRef)
	"insetLeft"?:        (number | #ParamRef)
	"rx"?:               (number | string | #ParamRef)
	"ry"?:               (number | string | #ParamRef)
	"offset"?:           (#StackOffset | null | #ParamRef)
	"order"?:            (#StackOrder | null | #ParamRef)
	"z"?:                #ChannelValue
	"interval"?:         (#Interval | #ParamRef)
	"x"?:                #ChannelValueIntervalSpec
	"x1"?:               #ChannelValueSpec
	"x2"?:               #ChannelValueSpec
	"y"?:                #ChannelValueSpec
}

#BarYOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"inset"?:            (number | #ParamRef)
	"insetTop"?:         (number | #ParamRef)
	"insetRight"?:       (number | #ParamRef)
	"insetBottom"?:      (number | #ParamRef)
	"insetLeft"?:        (number | #ParamRef)
	"rx"?:               (number | string | #ParamRef)
	"ry"?:               (number | string | #ParamRef)
	"offset"?:           (#StackOffset | null | #ParamRef)
	"order"?:            (#StackOrder | null | #ParamRef)
	"z"?:                #ChannelValue
	"interval"?:         (#Interval | #ParamRef)
	"y"?:                #ChannelValueIntervalSpec
	"y1"?:               #ChannelValueSpec
	"y2"?:               #ChannelValueSpec
	"x"?:                #ChannelValueSpec
}

#BarX: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"inset"?:            (number | #ParamRef)
	"insetTop"?:         (number | #ParamRef)
	"insetRight"?:       (number | #ParamRef)
	"insetBottom"?:      (number | #ParamRef)
	"insetLeft"?:        (number | #ParamRef)
	"rx"?:               (number | string | #ParamRef)
	"ry"?:               (number | string | #ParamRef)
	"offset"?:           (#StackOffset | null | #ParamRef)
	"order"?:            (#StackOrder | null | #ParamRef)
	"z"?:                #ChannelValue
	"interval"?:         (#Interval | #ParamRef)
	"x"?:                #ChannelValueIntervalSpec
	"x1"?:               #ChannelValueSpec
	"x2"?:               #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"mark"!:             "barX"
}

#BarY: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"inset"?:            (number | #ParamRef)
	"insetTop"?:         (number | #ParamRef)
	"insetRight"?:       (number | #ParamRef)
	"insetBottom"?:      (number | #ParamRef)
	"insetLeft"?:        (number | #ParamRef)
	"rx"?:               (number | string | #ParamRef)
	"ry"?:               (number | string | #ParamRef)
	"offset"?:           (#StackOffset | null | #ParamRef)
	"order"?:            (#StackOrder | null | #ParamRef)
	"z"?:                #ChannelValue
	"interval"?:         (#Interval | #ParamRef)
	"y"?:                #ChannelValueIntervalSpec
	"y1"?:               #ChannelValueSpec
	"y2"?:               #ChannelValueSpec
	"x"?:                #ChannelValueSpec
	"mark"!:             "barY"
}

#CellOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"inset"?:            (number | #ParamRef)
	"insetTop"?:         (number | #ParamRef)
	"insetRight"?:       (number | #ParamRef)
	"insetBottom"?:      (number | #ParamRef)
	"insetLeft"?:        (number | #ParamRef)
	"rx"?:               (number | string | #ParamRef)
	"ry"?:               (number | string | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
}

#Cell: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"inset"?:            (number | #ParamRef)
	"insetTop"?:         (number | #ParamRef)
	"insetRight"?:       (number | #ParamRef)
	"insetBottom"?:      (number | #ParamRef)
	"insetLeft"?:        (number | #ParamRef)
	"rx"?:               (number | string | #ParamRef)
	"ry"?:               (number | string | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"mark"!:             "cell"
}

#CellX: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"inset"?:            (number | #ParamRef)
	"insetTop"?:         (number | #ParamRef)
	"insetRight"?:       (number | #ParamRef)
	"insetBottom"?:      (number | #ParamRef)
	"insetLeft"?:        (number | #ParamRef)
	"rx"?:               (number | string | #ParamRef)
	"ry"?:               (number | string | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"mark"!:             "cellX"
}

#CellY: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"inset"?:            (number | #ParamRef)
	"insetTop"?:         (number | #ParamRef)
	"insetRight"?:       (number | #ParamRef)
	"insetBottom"?:      (number | #ParamRef)
	"insetLeft"?:        (number | #ParamRef)
	"rx"?:               (number | string | #ParamRef)
	"ry"?:               (number | string | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"mark"!:             "cellY"
}

#DotOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"z"?:                #ChannelValue
	"r"?:                (#ChannelValueSpec | number | #ParamRef)
	"rotate"?:           (#ChannelValue | number | #ParamRef)
	"symbol"?:           (#ChannelValueSpec | #SymbolType | #ParamRef)
	"frameAnchor"?:      (#FrameAnchor | #ParamRef)
}

#DotXOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"x"?:                #ChannelValueSpec
	"z"?:                #ChannelValue
	"r"?:                (#ChannelValueSpec | number | #ParamRef)
	"rotate"?:           (#ChannelValue | number | #ParamRef)
	"symbol"?:           (#ChannelValueSpec | #SymbolType | #ParamRef)
	"frameAnchor"?:      (#FrameAnchor | #ParamRef)
	"y"?:                #ChannelValueIntervalSpec
	"interval"?:         (#Interval | #ParamRef)
}

#DotYOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"y"?:                #ChannelValueSpec
	"z"?:                #ChannelValue
	"r"?:                (#ChannelValueSpec | number | #ParamRef)
	"rotate"?:           (#ChannelValue | number | #ParamRef)
	"symbol"?:           (#ChannelValueSpec | #SymbolType | #ParamRef)
	"frameAnchor"?:      (#FrameAnchor | #ParamRef)
	"x"?:                #ChannelValueIntervalSpec
	"interval"?:         (#Interval | #ParamRef)
}

#Dot: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"z"?:                #ChannelValue
	"r"?:                (#ChannelValueSpec | number | #ParamRef)
	"rotate"?:           (#ChannelValue | number | #ParamRef)
	"symbol"?:           (#ChannelValueSpec | #SymbolType | #ParamRef)
	"frameAnchor"?:      (#FrameAnchor | #ParamRef)
	"mark"!:             "dot"
}

#DotX: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"x"?:                #ChannelValueSpec
	"z"?:                #ChannelValue
	"r"?:                (#ChannelValueSpec | number | #ParamRef)
	"rotate"?:           (#ChannelValue | number | #ParamRef)
	"symbol"?:           (#ChannelValueSpec | #SymbolType | #ParamRef)
	"frameAnchor"?:      (#FrameAnchor | #ParamRef)
	"y"?:                #ChannelValueIntervalSpec
	"interval"?:         (#Interval | #ParamRef)
	"mark"!:             "dotX"
}

#DotY: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"y"?:                #ChannelValueSpec
	"z"?:                #ChannelValue
	"r"?:                (#ChannelValueSpec | number | #ParamRef)
	"rotate"?:           (#ChannelValue | number | #ParamRef)
	"symbol"?:           (#ChannelValueSpec | #SymbolType | #ParamRef)
	"frameAnchor"?:      (#FrameAnchor | #ParamRef)
	"x"?:                #ChannelValueIntervalSpec
	"interval"?:         (#Interval | #ParamRef)
	"mark"!:             "dotY"
}

#Circle: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"z"?:                #ChannelValue
	"r"?:                (#ChannelValueSpec | number | #ParamRef)
	"rotate"?:           (#ChannelValue | number | #ParamRef)
	"symbol"?:           (#ChannelValueSpec | #SymbolType | #ParamRef)
	"frameAnchor"?:      (#FrameAnchor | #ParamRef)
	"mark"!:             "circle"
}

#Hexagon: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"z"?:                #ChannelValue
	"r"?:                (#ChannelValueSpec | number | #ParamRef)
	"rotate"?:           (#ChannelValue | number | #ParamRef)
	"symbol"?:           (#ChannelValueSpec | #SymbolType | #ParamRef)
	"frameAnchor"?:      (#FrameAnchor | #ParamRef)
	"mark"!:             "hexagon"
}

#RectCornerOptions: {
	"rx"?: (number | string | #ParamRef)
	"ry"?: (number | string | #ParamRef)
}

#RectOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"inset"?:            (number | #ParamRef)
	"insetTop"?:         (number | #ParamRef)
	"insetRight"?:       (number | #ParamRef)
	"insetBottom"?:      (number | #ParamRef)
	"insetLeft"?:        (number | #ParamRef)
	"rx"?:               (number | string | #ParamRef)
	"ry"?:               (number | string | #ParamRef)
	"offset"?:           (#StackOffset | null | #ParamRef)
	"order"?:            (#StackOrder | null | #ParamRef)
	"z"?:                #ChannelValue
	"x"?:                #ChannelValueIntervalSpec
	"x1"?:               #ChannelValueSpec
	"x2"?:               #ChannelValueSpec
	"y"?:                #ChannelValueIntervalSpec
	"y1"?:               #ChannelValueSpec
	"y2"?:               #ChannelValueSpec
	"interval"?:         (#Interval | #ParamRef)
}

#RectXOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"inset"?:            (number | #ParamRef)
	"insetTop"?:         (number | #ParamRef)
	"insetRight"?:       (number | #ParamRef)
	"insetBottom"?:      (number | #ParamRef)
	"insetLeft"?:        (number | #ParamRef)
	"rx"?:               (number | string | #ParamRef)
	"ry"?:               (number | string | #ParamRef)
	"offset"?:           (#StackOffset | null | #ParamRef)
	"order"?:            (#StackOrder | null | #ParamRef)
	"z"?:                #ChannelValue
	"x"?:                #ChannelValueSpec
	"x1"?:               #ChannelValueSpec
	"x2"?:               #ChannelValueSpec
	"y"?:                #ChannelValueIntervalSpec
	"y1"?:               #ChannelValueSpec
	"y2"?:               #ChannelValueSpec
	"interval"?:         (#Interval | #ParamRef)
}

#RectYOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"inset"?:            (number | #ParamRef)
	"insetTop"?:         (number | #ParamRef)
	"insetRight"?:       (number | #ParamRef)
	"insetBottom"?:      (number | #ParamRef)
	"insetLeft"?:        (number | #ParamRef)
	"rx"?:               (number | string | #ParamRef)
	"ry"?:               (number | string | #ParamRef)
	"offset"?:           (#StackOffset | null | #ParamRef)
	"order"?:            (#StackOrder | null | #ParamRef)
	"z"?:                #ChannelValue
	"x"?:                #ChannelValueIntervalSpec
	"x1"?:               #ChannelValueSpec
	"x2"?:               #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"y1"?:               #ChannelValueSpec
	"y2"?:               #ChannelValueSpec
	"interval"?:         (#Interval | #ParamRef)
}

#Rect: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"inset"?:            (number | #ParamRef)
	"insetTop"?:         (number | #ParamRef)
	"insetRight"?:       (number | #ParamRef)
	"insetBottom"?:      (number | #ParamRef)
	"insetLeft"?:        (number | #ParamRef)
	"rx"?:               (number | string | #ParamRef)
	"ry"?:               (number | string | #ParamRef)
	"offset"?:           (#StackOffset | null | #ParamRef)
	"order"?:            (#StackOrder | null | #ParamRef)
	"z"?:                #ChannelValue
	"x"?:                #ChannelValueIntervalSpec
	"x1"?:               #ChannelValueSpec
	"x2"?:               #ChannelValueSpec
	"y"?:                #ChannelValueIntervalSpec
	"y1"?:               #ChannelValueSpec
	"y2"?:               #ChannelValueSpec
	"interval"?:         (#Interval | #ParamRef)
	"mark"!:             "rect"
}

#RectX: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"inset"?:            (number | #ParamRef)
	"insetTop"?:         (number | #ParamRef)
	"insetRight"?:       (number | #ParamRef)
	"insetBottom"?:      (number | #ParamRef)
	"insetLeft"?:        (number | #ParamRef)
	"rx"?:               (number | string | #ParamRef)
	"ry"?:               (number | string | #ParamRef)
	"offset"?:           (#StackOffset | null | #ParamRef)
	"order"?:            (#StackOrder | null | #ParamRef)
	"z"?:                #ChannelValue
	"x"?:                #ChannelValueSpec
	"x1"?:               #ChannelValueSpec
	"x2"?:               #ChannelValueSpec
	"y"?:                #ChannelValueIntervalSpec
	"y1"?:               #ChannelValueSpec
	"y2"?:               #ChannelValueSpec
	"interval"?:         (#Interval | #ParamRef)
	"mark"!:             "rectX"
}

#RectY: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"inset"?:            (number | #ParamRef)
	"insetTop"?:         (number | #ParamRef)
	"insetRight"?:       (number | #ParamRef)
	"insetBottom"?:      (number | #ParamRef)
	"insetLeft"?:        (number | #ParamRef)
	"rx"?:               (number | string | #ParamRef)
	"ry"?:               (number | string | #ParamRef)
	"offset"?:           (#StackOffset | null | #ParamRef)
	"order"?:            (#StackOrder | null | #ParamRef)
	"z"?:                #ChannelValue
	"x"?:                #ChannelValueIntervalSpec
	"x1"?:               #ChannelValueSpec
	"x2"?:               #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"y1"?:               #ChannelValueSpec
	"y2"?:               #ChannelValueSpec
	"interval"?:         (#Interval | #ParamRef)
	"mark"!:             "rectY"
}

#RuleOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"marker"?:           (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:      (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"interval"?:         (#Interval | #ParamRef)
}

#RuleXOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"marker"?:           (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:      (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"interval"?:         (#Interval | #ParamRef)
	"inset"?:            (number | #ParamRef)
	"insetTop"?:         (number | #ParamRef)
	"insetBottom"?:      (number | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueIntervalSpec
	"y1"?:               #ChannelValueSpec
	"y2"?:               #ChannelValueSpec
}

#RuleYOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"marker"?:           (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:      (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"interval"?:         (#Interval | #ParamRef)
	"inset"?:            (number | #ParamRef)
	"insetRight"?:       (number | #ParamRef)
	"insetLeft"?:        (number | #ParamRef)
	"x"?:                #ChannelValueIntervalSpec
	"x1"?:               #ChannelValueSpec
	"x2"?:               #ChannelValueSpec
	"y"?:                #ChannelValueSpec
}

#RuleX: {
	"data"?:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"marker"?:           (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:      (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"interval"?:         (#Interval | #ParamRef)
	"inset"?:            (number | #ParamRef)
	"insetTop"?:         (number | #ParamRef)
	"insetBottom"?:      (number | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueIntervalSpec
	"y1"?:               #ChannelValueSpec
	"y2"?:               #ChannelValueSpec
	"mark"!:             "ruleX"
}

#RuleY: {
	"data"?:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"marker"?:           (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:      (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"interval"?:         (#Interval | #ParamRef)
	"inset"?:            (number | #ParamRef)
	"insetTop"?:         (number | #ParamRef)
	"insetBottom"?:      (number | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueIntervalSpec
	"y1"?:               #ChannelValueSpec
	"y2"?:               #ChannelValueSpec
	"mark"!:             "ruleY"
}

#TickXOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"marker"?:           (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:      (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"inset"?:            (number | #ParamRef)
	"insetTop"?:         (number | #ParamRef)
	"insetBottom"?:      (number | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
}

#TickYOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"marker"?:           (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:      (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"inset"?:            (number | #ParamRef)
	"insetRight"?:       (number | #ParamRef)
	"insetLeft"?:        (number | #ParamRef)
	"y"?:                #ChannelValueSpec
	"x"?:                #ChannelValueSpec
}

#TickX: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"marker"?:           (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:      (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"inset"?:            (number | #ParamRef)
	"insetTop"?:         (number | #ParamRef)
	"insetBottom"?:      (number | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"mark"!:             "tickX"
}

#TickY: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"marker"?:           (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:      (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"inset"?:            (number | #ParamRef)
	"insetRight"?:       (number | #ParamRef)
	"insetLeft"?:        (number | #ParamRef)
	"y"?:                #ChannelValueSpec
	"x"?:                #ChannelValueSpec
	"mark"!:             "tickY"
}

#GeoOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"geometry"?:         #ChannelValue
	"r"?:                (#ChannelValueSpec | #ParamRef)
}

#Geo: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"geometry"?:         #ChannelValue
	"r"?:                (#ChannelValueSpec | #ParamRef)
	"mark"!:             "geo"
}

#Sphere: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"mark"!:             "sphere"
}

#Graticule: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"mark"!:             "graticule"
}

#DelaunayOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"marker"?:           (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:      (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"curve"?:            (#Curve | #ParamRef)
	"tension"?:          (number | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"z"?:                #ChannelValue
}

#DelaunayLink: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"marker"?:           (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:      (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"curve"?:            (#Curve | #ParamRef)
	"tension"?:          (number | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"z"?:                #ChannelValue
	"mark"!:             "delaunayLink"
}

#DelaunayMesh: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"marker"?:           (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:      (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"curve"?:            (#Curve | #ParamRef)
	"tension"?:          (number | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"z"?:                #ChannelValue
	"mark"!:             "delaunayMesh"
}

#Hull: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"marker"?:           (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:      (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"curve"?:            (#Curve | #ParamRef)
	"tension"?:          (number | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"z"?:                #ChannelValue
	"mark"!:             "hull"
}

#Voronoi: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"marker"?:           (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:      (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"curve"?:            (#Curve | #ParamRef)
	"tension"?:          (number | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"z"?:                #ChannelValue
	"mark"!:             "voronoi"
}

#VoronoiMesh: {
	"data"!:            #PlotMarkData
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"marker"?:           (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:      (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"curve"?:            (#Curve | #ParamRef)
	"tension"?:          (number | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"z"?:                #ChannelValue
	"mark"!:             "voronoiMesh"
}

#ScaleOptions: {
	"interval"?: (#Interval | #ParamRef)
	"ticks"?: (number | #Interval | [...] | #ParamRef)
	"tickSize"?:    (number | #ParamRef)
	"tickSpacing"?: (number | #ParamRef)
	"tickPadding"?: (number | #ParamRef)
	"tickFormat"?:  (string | null | #ParamRef)
	"tickRotate"?:  (number | #ParamRef)
	"label"?:       (string | null | #ParamRef)
	"labelAnchor"?: ("top" | "right" | "bottom" | "left" | "center" | #ParamRef)
	"labelOffset"?: (number | #ParamRef)
	"labelArrow"?:  ("auto" | "up" | "right" | "down" | "left" | "none" | true | false | null | #ParamRef)
}

#GridScaleOptions: {"interval"?: (#Interval | #ParamRef), "ticks"?: (number | #Interval | [...] | #ParamRef), "tickSpacing"?: (number | #ParamRef)}

#GridOptions: {
	"interval"?: (#Interval | #ParamRef)
	"ticks"?: (number | #Interval | [...] | #ParamRef)
	"tickSpacing"?: (number | #ParamRef)
	"anchor"?:      ("top" | "right" | "bottom" | "left" | #ParamRef)
	"color"?:       (#ChannelValueSpec | #ParamRef)
	"opacity"?:     #ChannelValueSpec
}

#AxisScaleOptions: {"tickSize"?: (number | #ParamRef), "tickPadding"?: (number | #ParamRef), "tickFormat"?: (string | null | #ParamRef), "tickRotate"?: (number | #ParamRef), "label"?: (string | null | #ParamRef), "labelAnchor"?: ("top" | "right" | "bottom" | "left" | "center" | #ParamRef), "labelOffset"?: (number | #ParamRef), "labelArrow"?: ("auto" | "up" | "right" | "down" | "left" | "none" | true | false | null | #ParamRef)}

#AxisOptions: {
	"interval"?: (#Interval | #ParamRef)
	"ticks"?: (number | #Interval | [...] | #ParamRef)
	"tickSpacing"?:     (number | #ParamRef)
	"anchor"?:          ("top" | "right" | "bottom" | "left" | #ParamRef)
	"color"?:           (#ChannelValueSpec | #ParamRef)
	"opacity"?:         #ChannelValueSpec
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:              ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:                (number | #ParamRef)
	"dy"?:                (number | #ParamRef)
	"fill"?:              (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:       (#ChannelValueSpec | #ParamRef)
	"stroke"?:            (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:   (string | number | #ParamRef)
	"strokeDashoffset"?:  (string | number | #ParamRef)
	"strokeLinecap"?:     (string | #ParamRef)
	"strokeLinejoin"?:    (string | #ParamRef)
	"strokeMiterlimit"?:  (number | #ParamRef)
	"strokeOpacity"?:     #ChannelValueSpec
	"strokeWidth"?:       #ChannelValueSpec
	"mixBlendMode"?:      (string | #ParamRef)
	"imageFilter"?:       (string | #ParamRef)
	"paintOrder"?:        (string | #ParamRef)
	"shapeRendering"?:    (string | #ParamRef)
	"href"?:              #ChannelValue
	"target"?:            (string | #ParamRef)
	"textAnchor"?:        ("start" | "middle" | "end" | #ParamRef)
	"lineHeight"?:        (number | #ParamRef)
	"lineWidth"?:         (number | #ParamRef)
	"textOverflow"?:      (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef)
	"monospace"?:         (bool | #ParamRef)
	"fontFamily"?:        (string | #ParamRef)
	"fontSize"?:          (#ChannelValue | #ParamRef)
	"fontStyle"?:         (string | #ParamRef)
	"fontVariant"?:       (string | #ParamRef)
	"fontWeight"?:        (string | number | #ParamRef)
	"x"?:                 #ChannelValueSpec
	"y"?:                 #ChannelValueSpec
	"z"?:                 #ChannelValue
	"text"?:              #ChannelValue
	"frameAnchor"?:       (#FrameAnchor | #ParamRef)
	"lineAnchor"?:        ("top" | "middle" | "bottom" | #ParamRef)
	"rotate"?:            (#ChannelValue | #ParamRef)
	"tickSize"?:          (number | #ParamRef)
	"tickPadding"?:       (number | #ParamRef)
	"tickFormat"?:        (string | null | #ParamRef)
	"tickRotate"?:        (number | #ParamRef)
	"label"?:             (string | null | #ParamRef)
	"labelAnchor"?:       ("top" | "right" | "bottom" | "left" | "center" | #ParamRef)
	"labelOffset"?:       (number | #ParamRef)
	"labelArrow"?:        ("auto" | "up" | "right" | "down" | "left" | "none" | true | false | null | #ParamRef)
	"textStroke"?:        (#ChannelValueSpec | #ParamRef)
	"textStrokeOpacity"?: #ChannelValueSpec
	"textStrokeWidth"?:   #ChannelValueSpec
}

#AxisXOptions: {
	"interval"?: (#Interval | #ParamRef)
	"ticks"?: (number | #Interval | [...] | #ParamRef)
	"tickSpacing"?:     (number | #ParamRef)
	"anchor"?:          ("top" | "right" | "bottom" | "left" | #ParamRef)
	"color"?:           (#ChannelValueSpec | #ParamRef)
	"opacity"?:         #ChannelValueSpec
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:              ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:                (number | #ParamRef)
	"dy"?:                (number | #ParamRef)
	"fill"?:              (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:       (#ChannelValueSpec | #ParamRef)
	"stroke"?:            (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:   (string | number | #ParamRef)
	"strokeDashoffset"?:  (string | number | #ParamRef)
	"strokeLinecap"?:     (string | #ParamRef)
	"strokeLinejoin"?:    (string | #ParamRef)
	"strokeMiterlimit"?:  (number | #ParamRef)
	"strokeOpacity"?:     #ChannelValueSpec
	"strokeWidth"?:       #ChannelValueSpec
	"mixBlendMode"?:      (string | #ParamRef)
	"imageFilter"?:       (string | #ParamRef)
	"paintOrder"?:        (string | #ParamRef)
	"shapeRendering"?:    (string | #ParamRef)
	"href"?:              #ChannelValue
	"target"?:            (string | #ParamRef)
	"textAnchor"?:        ("start" | "middle" | "end" | #ParamRef)
	"lineHeight"?:        (number | #ParamRef)
	"lineWidth"?:         (number | #ParamRef)
	"textOverflow"?:      (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef)
	"monospace"?:         (bool | #ParamRef)
	"fontFamily"?:        (string | #ParamRef)
	"fontSize"?:          (#ChannelValue | #ParamRef)
	"fontStyle"?:         (string | #ParamRef)
	"fontVariant"?:       (string | #ParamRef)
	"fontWeight"?:        (string | number | #ParamRef)
	"x"?:                 #ChannelValueSpec
	"y"?:                 #ChannelValueSpec
	"z"?:                 #ChannelValue
	"text"?:              #ChannelValue
	"frameAnchor"?:       (#FrameAnchor | #ParamRef)
	"lineAnchor"?:        ("top" | "middle" | "bottom" | #ParamRef)
	"rotate"?:            (#ChannelValue | #ParamRef)
	"tickSize"?:          (number | #ParamRef)
	"tickPadding"?:       (number | #ParamRef)
	"tickFormat"?:        (string | null | #ParamRef)
	"tickRotate"?:        (number | #ParamRef)
	"label"?:             (string | null | #ParamRef)
	"labelAnchor"?:       ("top" | "right" | "bottom" | "left" | "center" | #ParamRef)
	"labelOffset"?:       (number | #ParamRef)
	"labelArrow"?:        ("auto" | "up" | "right" | "down" | "left" | "none" | true | false | null | #ParamRef)
	"textStroke"?:        (#ChannelValueSpec | #ParamRef)
	"textStrokeOpacity"?: #ChannelValueSpec
	"textStrokeWidth"?:   #ChannelValueSpec
	"marker"?:            (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:       (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:         (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:         (#MarkerName | "none" | bool | null | #ParamRef)
	"inset"?:             (number | #ParamRef)
	"insetTop"?:          (number | #ParamRef)
	"insetBottom"?:       (number | #ParamRef)
}

#AxisYOptions: {
	"interval"?: (#Interval | #ParamRef)
	"ticks"?: (number | #Interval | [...] | #ParamRef)
	"tickSpacing"?:     (number | #ParamRef)
	"anchor"?:          ("top" | "right" | "bottom" | "left" | #ParamRef)
	"color"?:           (#ChannelValueSpec | #ParamRef)
	"opacity"?:         #ChannelValueSpec
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:              ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:                (number | #ParamRef)
	"dy"?:                (number | #ParamRef)
	"fill"?:              (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:       (#ChannelValueSpec | #ParamRef)
	"stroke"?:            (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:   (string | number | #ParamRef)
	"strokeDashoffset"?:  (string | number | #ParamRef)
	"strokeLinecap"?:     (string | #ParamRef)
	"strokeLinejoin"?:    (string | #ParamRef)
	"strokeMiterlimit"?:  (number | #ParamRef)
	"strokeOpacity"?:     #ChannelValueSpec
	"strokeWidth"?:       #ChannelValueSpec
	"mixBlendMode"?:      (string | #ParamRef)
	"imageFilter"?:       (string | #ParamRef)
	"paintOrder"?:        (string | #ParamRef)
	"shapeRendering"?:    (string | #ParamRef)
	"href"?:              #ChannelValue
	"target"?:            (string | #ParamRef)
	"textAnchor"?:        ("start" | "middle" | "end" | #ParamRef)
	"lineHeight"?:        (number | #ParamRef)
	"lineWidth"?:         (number | #ParamRef)
	"textOverflow"?:      (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef)
	"monospace"?:         (bool | #ParamRef)
	"fontFamily"?:        (string | #ParamRef)
	"fontSize"?:          (#ChannelValue | #ParamRef)
	"fontStyle"?:         (string | #ParamRef)
	"fontVariant"?:       (string | #ParamRef)
	"fontWeight"?:        (string | number | #ParamRef)
	"x"?:                 #ChannelValueSpec
	"y"?:                 #ChannelValueSpec
	"z"?:                 #ChannelValue
	"text"?:              #ChannelValue
	"frameAnchor"?:       (#FrameAnchor | #ParamRef)
	"lineAnchor"?:        ("top" | "middle" | "bottom" | #ParamRef)
	"rotate"?:            (#ChannelValue | #ParamRef)
	"tickSize"?:          (number | #ParamRef)
	"tickPadding"?:       (number | #ParamRef)
	"tickFormat"?:        (string | null | #ParamRef)
	"tickRotate"?:        (number | #ParamRef)
	"label"?:             (string | null | #ParamRef)
	"labelAnchor"?:       ("top" | "right" | "bottom" | "left" | "center" | #ParamRef)
	"labelOffset"?:       (number | #ParamRef)
	"labelArrow"?:        ("auto" | "up" | "right" | "down" | "left" | "none" | true | false | null | #ParamRef)
	"textStroke"?:        (#ChannelValueSpec | #ParamRef)
	"textStrokeOpacity"?: #ChannelValueSpec
	"textStrokeWidth"?:   #ChannelValueSpec
	"marker"?:            (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:       (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:         (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:         (#MarkerName | "none" | bool | null | #ParamRef)
	"inset"?:             (number | #ParamRef)
	"insetRight"?:        (number | #ParamRef)
	"insetLeft"?:         (number | #ParamRef)
}

#GridXOptions: {
	"interval"?: (#Interval | #ParamRef)
	"ticks"?: (number | #Interval | [...] | #ParamRef)
	"tickSpacing"?:     (number | #ParamRef)
	"anchor"?:          ("top" | "right" | "bottom" | "left" | #ParamRef)
	"color"?:           (#ChannelValueSpec | #ParamRef)
	"opacity"?:         #ChannelValueSpec
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"marker"?:           (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:      (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"inset"?:            (number | #ParamRef)
	"insetTop"?:         (number | #ParamRef)
	"insetBottom"?:      (number | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueIntervalSpec
	"y1"?:               #ChannelValueSpec
	"y2"?:               #ChannelValueSpec
}

#GridYOptions: {
	"interval"?: (#Interval | #ParamRef)
	"ticks"?: (number | #Interval | [...] | #ParamRef)
	"tickSpacing"?:     (number | #ParamRef)
	"anchor"?:          ("top" | "right" | "bottom" | "left" | #ParamRef)
	"color"?:           (#ChannelValueSpec | #ParamRef)
	"opacity"?:         #ChannelValueSpec
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"marker"?:           (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:      (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"inset"?:            (number | #ParamRef)
	"insetRight"?:       (number | #ParamRef)
	"insetLeft"?:        (number | #ParamRef)
	"x"?:                #ChannelValueIntervalSpec
	"x1"?:               #ChannelValueSpec
	"x2"?:               #ChannelValueSpec
	"y"?:                #ChannelValueSpec
}

#AxisX: {
	"interval"?: (#Interval | #ParamRef)
	"ticks"?: (number | #Interval | [...] | #ParamRef)
	"tickSpacing"?:     (number | #ParamRef)
	"anchor"?:          ("top" | "right" | "bottom" | "left" | #ParamRef)
	"color"?:           (#ChannelValueSpec | #ParamRef)
	"opacity"?:         #ChannelValueSpec
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:              ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:                (number | #ParamRef)
	"dy"?:                (number | #ParamRef)
	"fill"?:              (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:       (#ChannelValueSpec | #ParamRef)
	"stroke"?:            (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:   (string | number | #ParamRef)
	"strokeDashoffset"?:  (string | number | #ParamRef)
	"strokeLinecap"?:     (string | #ParamRef)
	"strokeLinejoin"?:    (string | #ParamRef)
	"strokeMiterlimit"?:  (number | #ParamRef)
	"strokeOpacity"?:     #ChannelValueSpec
	"strokeWidth"?:       #ChannelValueSpec
	"mixBlendMode"?:      (string | #ParamRef)
	"imageFilter"?:       (string | #ParamRef)
	"paintOrder"?:        (string | #ParamRef)
	"shapeRendering"?:    (string | #ParamRef)
	"href"?:              #ChannelValue
	"target"?:            (string | #ParamRef)
	"textAnchor"?:        ("start" | "middle" | "end" | #ParamRef)
	"lineHeight"?:        (number | #ParamRef)
	"lineWidth"?:         (number | #ParamRef)
	"textOverflow"?:      (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef)
	"monospace"?:         (bool | #ParamRef)
	"fontFamily"?:        (string | #ParamRef)
	"fontSize"?:          (#ChannelValue | #ParamRef)
	"fontStyle"?:         (string | #ParamRef)
	"fontVariant"?:       (string | #ParamRef)
	"fontWeight"?:        (string | number | #ParamRef)
	"x"?:                 #ChannelValueSpec
	"y"?:                 #ChannelValueSpec
	"z"?:                 #ChannelValue
	"text"?:              #ChannelValue
	"frameAnchor"?:       (#FrameAnchor | #ParamRef)
	"lineAnchor"?:        ("top" | "middle" | "bottom" | #ParamRef)
	"rotate"?:            (#ChannelValue | #ParamRef)
	"tickSize"?:          (number | #ParamRef)
	"tickPadding"?:       (number | #ParamRef)
	"tickFormat"?:        (string | null | #ParamRef)
	"tickRotate"?:        (number | #ParamRef)
	"label"?:             (string | null | #ParamRef)
	"labelAnchor"?:       ("top" | "right" | "bottom" | "left" | "center" | #ParamRef)
	"labelOffset"?:       (number | #ParamRef)
	"labelArrow"?:        ("auto" | "up" | "right" | "down" | "left" | "none" | true | false | null | #ParamRef)
	"textStroke"?:        (#ChannelValueSpec | #ParamRef)
	"textStrokeOpacity"?: #ChannelValueSpec
	"textStrokeWidth"?:   #ChannelValueSpec
	"marker"?:            (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:       (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:         (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:         (#MarkerName | "none" | bool | null | #ParamRef)
	"inset"?:             (number | #ParamRef)
	"insetTop"?:          (number | #ParamRef)
	"insetBottom"?:       (number | #ParamRef)
	"mark"!:              "axisX"
}

#AxisFx: {
	"interval"?: (#Interval | #ParamRef)
	"ticks"?: (number | #Interval | [...] | #ParamRef)
	"tickSpacing"?:     (number | #ParamRef)
	"anchor"?:          ("top" | "right" | "bottom" | "left" | #ParamRef)
	"color"?:           (#ChannelValueSpec | #ParamRef)
	"opacity"?:         #ChannelValueSpec
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:              ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:                (number | #ParamRef)
	"dy"?:                (number | #ParamRef)
	"fill"?:              (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:       (#ChannelValueSpec | #ParamRef)
	"stroke"?:            (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:   (string | number | #ParamRef)
	"strokeDashoffset"?:  (string | number | #ParamRef)
	"strokeLinecap"?:     (string | #ParamRef)
	"strokeLinejoin"?:    (string | #ParamRef)
	"strokeMiterlimit"?:  (number | #ParamRef)
	"strokeOpacity"?:     #ChannelValueSpec
	"strokeWidth"?:       #ChannelValueSpec
	"mixBlendMode"?:      (string | #ParamRef)
	"imageFilter"?:       (string | #ParamRef)
	"paintOrder"?:        (string | #ParamRef)
	"shapeRendering"?:    (string | #ParamRef)
	"href"?:              #ChannelValue
	"target"?:            (string | #ParamRef)
	"textAnchor"?:        ("start" | "middle" | "end" | #ParamRef)
	"lineHeight"?:        (number | #ParamRef)
	"lineWidth"?:         (number | #ParamRef)
	"textOverflow"?:      (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef)
	"monospace"?:         (bool | #ParamRef)
	"fontFamily"?:        (string | #ParamRef)
	"fontSize"?:          (#ChannelValue | #ParamRef)
	"fontStyle"?:         (string | #ParamRef)
	"fontVariant"?:       (string | #ParamRef)
	"fontWeight"?:        (string | number | #ParamRef)
	"x"?:                 #ChannelValueSpec
	"y"?:                 #ChannelValueSpec
	"z"?:                 #ChannelValue
	"text"?:              #ChannelValue
	"frameAnchor"?:       (#FrameAnchor | #ParamRef)
	"lineAnchor"?:        ("top" | "middle" | "bottom" | #ParamRef)
	"rotate"?:            (#ChannelValue | #ParamRef)
	"tickSize"?:          (number | #ParamRef)
	"tickPadding"?:       (number | #ParamRef)
	"tickFormat"?:        (string | null | #ParamRef)
	"tickRotate"?:        (number | #ParamRef)
	"label"?:             (string | null | #ParamRef)
	"labelAnchor"?:       ("top" | "right" | "bottom" | "left" | "center" | #ParamRef)
	"labelOffset"?:       (number | #ParamRef)
	"labelArrow"?:        ("auto" | "up" | "right" | "down" | "left" | "none" | true | false | null | #ParamRef)
	"textStroke"?:        (#ChannelValueSpec | #ParamRef)
	"textStrokeOpacity"?: #ChannelValueSpec
	"textStrokeWidth"?:   #ChannelValueSpec
	"marker"?:            (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:       (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:         (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:         (#MarkerName | "none" | bool | null | #ParamRef)
	"inset"?:             (number | #ParamRef)
	"insetTop"?:          (number | #ParamRef)
	"insetBottom"?:       (number | #ParamRef)
	"mark"!:              "axisFx"
}

#AxisY: {
	"interval"?: (#Interval | #ParamRef)
	"ticks"?: (number | #Interval | [...] | #ParamRef)
	"tickSpacing"?:     (number | #ParamRef)
	"anchor"?:          ("top" | "right" | "bottom" | "left" | #ParamRef)
	"color"?:           (#ChannelValueSpec | #ParamRef)
	"opacity"?:         #ChannelValueSpec
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:              ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:                (number | #ParamRef)
	"dy"?:                (number | #ParamRef)
	"fill"?:              (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:       (#ChannelValueSpec | #ParamRef)
	"stroke"?:            (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:   (string | number | #ParamRef)
	"strokeDashoffset"?:  (string | number | #ParamRef)
	"strokeLinecap"?:     (string | #ParamRef)
	"strokeLinejoin"?:    (string | #ParamRef)
	"strokeMiterlimit"?:  (number | #ParamRef)
	"strokeOpacity"?:     #ChannelValueSpec
	"strokeWidth"?:       #ChannelValueSpec
	"mixBlendMode"?:      (string | #ParamRef)
	"imageFilter"?:       (string | #ParamRef)
	"paintOrder"?:        (string | #ParamRef)
	"shapeRendering"?:    (string | #ParamRef)
	"href"?:              #ChannelValue
	"target"?:            (string | #ParamRef)
	"textAnchor"?:        ("start" | "middle" | "end" | #ParamRef)
	"lineHeight"?:        (number | #ParamRef)
	"lineWidth"?:         (number | #ParamRef)
	"textOverflow"?:      (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef)
	"monospace"?:         (bool | #ParamRef)
	"fontFamily"?:        (string | #ParamRef)
	"fontSize"?:          (#ChannelValue | #ParamRef)
	"fontStyle"?:         (string | #ParamRef)
	"fontVariant"?:       (string | #ParamRef)
	"fontWeight"?:        (string | number | #ParamRef)
	"x"?:                 #ChannelValueSpec
	"y"?:                 #ChannelValueSpec
	"z"?:                 #ChannelValue
	"text"?:              #ChannelValue
	"frameAnchor"?:       (#FrameAnchor | #ParamRef)
	"lineAnchor"?:        ("top" | "middle" | "bottom" | #ParamRef)
	"rotate"?:            (#ChannelValue | #ParamRef)
	"tickSize"?:          (number | #ParamRef)
	"tickPadding"?:       (number | #ParamRef)
	"tickFormat"?:        (string | null | #ParamRef)
	"tickRotate"?:        (number | #ParamRef)
	"label"?:             (string | null | #ParamRef)
	"labelAnchor"?:       ("top" | "right" | "bottom" | "left" | "center" | #ParamRef)
	"labelOffset"?:       (number | #ParamRef)
	"labelArrow"?:        ("auto" | "up" | "right" | "down" | "left" | "none" | true | false | null | #ParamRef)
	"textStroke"?:        (#ChannelValueSpec | #ParamRef)
	"textStrokeOpacity"?: #ChannelValueSpec
	"textStrokeWidth"?:   #ChannelValueSpec
	"marker"?:            (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:       (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:         (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:         (#MarkerName | "none" | bool | null | #ParamRef)
	"inset"?:             (number | #ParamRef)
	"insetRight"?:        (number | #ParamRef)
	"insetLeft"?:         (number | #ParamRef)
	"mark"!:              "axisY"
}

#AxisFy: {
	"interval"?: (#Interval | #ParamRef)
	"ticks"?: (number | #Interval | [...] | #ParamRef)
	"tickSpacing"?:     (number | #ParamRef)
	"anchor"?:          ("top" | "right" | "bottom" | "left" | #ParamRef)
	"color"?:           (#ChannelValueSpec | #ParamRef)
	"opacity"?:         #ChannelValueSpec
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:              ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:                (number | #ParamRef)
	"dy"?:                (number | #ParamRef)
	"fill"?:              (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:       (#ChannelValueSpec | #ParamRef)
	"stroke"?:            (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:   (string | number | #ParamRef)
	"strokeDashoffset"?:  (string | number | #ParamRef)
	"strokeLinecap"?:     (string | #ParamRef)
	"strokeLinejoin"?:    (string | #ParamRef)
	"strokeMiterlimit"?:  (number | #ParamRef)
	"strokeOpacity"?:     #ChannelValueSpec
	"strokeWidth"?:       #ChannelValueSpec
	"mixBlendMode"?:      (string | #ParamRef)
	"imageFilter"?:       (string | #ParamRef)
	"paintOrder"?:        (string | #ParamRef)
	"shapeRendering"?:    (string | #ParamRef)
	"href"?:              #ChannelValue
	"target"?:            (string | #ParamRef)
	"textAnchor"?:        ("start" | "middle" | "end" | #ParamRef)
	"lineHeight"?:        (number | #ParamRef)
	"lineWidth"?:         (number | #ParamRef)
	"textOverflow"?:      (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef)
	"monospace"?:         (bool | #ParamRef)
	"fontFamily"?:        (string | #ParamRef)
	"fontSize"?:          (#ChannelValue | #ParamRef)
	"fontStyle"?:         (string | #ParamRef)
	"fontVariant"?:       (string | #ParamRef)
	"fontWeight"?:        (string | number | #ParamRef)
	"x"?:                 #ChannelValueSpec
	"y"?:                 #ChannelValueSpec
	"z"?:                 #ChannelValue
	"text"?:              #ChannelValue
	"frameAnchor"?:       (#FrameAnchor | #ParamRef)
	"lineAnchor"?:        ("top" | "middle" | "bottom" | #ParamRef)
	"rotate"?:            (#ChannelValue | #ParamRef)
	"tickSize"?:          (number | #ParamRef)
	"tickPadding"?:       (number | #ParamRef)
	"tickFormat"?:        (string | null | #ParamRef)
	"tickRotate"?:        (number | #ParamRef)
	"label"?:             (string | null | #ParamRef)
	"labelAnchor"?:       ("top" | "right" | "bottom" | "left" | "center" | #ParamRef)
	"labelOffset"?:       (number | #ParamRef)
	"labelArrow"?:        ("auto" | "up" | "right" | "down" | "left" | "none" | true | false | null | #ParamRef)
	"textStroke"?:        (#ChannelValueSpec | #ParamRef)
	"textStrokeOpacity"?: #ChannelValueSpec
	"textStrokeWidth"?:   #ChannelValueSpec
	"marker"?:            (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:       (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:         (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:         (#MarkerName | "none" | bool | null | #ParamRef)
	"inset"?:             (number | #ParamRef)
	"insetRight"?:        (number | #ParamRef)
	"insetLeft"?:         (number | #ParamRef)
	"mark"!:              "axisFy"
}

#GridX: {
	"interval"?: (#Interval | #ParamRef)
	"ticks"?: (number | #Interval | [...] | #ParamRef)
	"tickSpacing"?:     (number | #ParamRef)
	"anchor"?:          ("top" | "right" | "bottom" | "left" | #ParamRef)
	"color"?:           (#ChannelValueSpec | #ParamRef)
	"opacity"?:         #ChannelValueSpec
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"marker"?:           (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:      (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"inset"?:            (number | #ParamRef)
	"insetTop"?:         (number | #ParamRef)
	"insetBottom"?:      (number | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueIntervalSpec
	"y1"?:               #ChannelValueSpec
	"y2"?:               #ChannelValueSpec
	"mark"!:             "gridX"
}

#GridFx: {
	"interval"?: (#Interval | #ParamRef)
	"ticks"?: (number | #Interval | [...] | #ParamRef)
	"tickSpacing"?:     (number | #ParamRef)
	"anchor"?:          ("top" | "right" | "bottom" | "left" | #ParamRef)
	"color"?:           (#ChannelValueSpec | #ParamRef)
	"opacity"?:         #ChannelValueSpec
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"marker"?:           (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:      (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"inset"?:            (number | #ParamRef)
	"insetTop"?:         (number | #ParamRef)
	"insetBottom"?:      (number | #ParamRef)
	"x"?:                #ChannelValueSpec
	"y"?:                #ChannelValueIntervalSpec
	"y1"?:               #ChannelValueSpec
	"y2"?:               #ChannelValueSpec
	"mark"!:             "gridFx"
}

#GridY: {
	"interval"?: (#Interval | #ParamRef)
	"ticks"?: (number | #Interval | [...] | #ParamRef)
	"tickSpacing"?:     (number | #ParamRef)
	"anchor"?:          ("top" | "right" | "bottom" | "left" | #ParamRef)
	"color"?:           (#ChannelValueSpec | #ParamRef)
	"opacity"?:         #ChannelValueSpec
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"marker"?:           (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:      (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"inset"?:            (number | #ParamRef)
	"insetRight"?:       (number | #ParamRef)
	"insetLeft"?:        (number | #ParamRef)
	"x"?:                #ChannelValueIntervalSpec
	"x1"?:               #ChannelValueSpec
	"x2"?:               #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"mark"!:             "gridY"
}

#GridFy: {
	"interval"?: (#Interval | #ParamRef)
	"ticks"?: (number | #Interval | [...] | #ParamRef)
	"tickSpacing"?:     (number | #ParamRef)
	"anchor"?:          ("top" | "right" | "bottom" | "left" | #ParamRef)
	"color"?:           (#ChannelValueSpec | #ParamRef)
	"opacity"?:         #ChannelValueSpec
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"marker"?:           (#MarkerName | "none" | bool | null | #ParamRef)
	"markerStart"?:      (#MarkerName | "none" | bool | null | #ParamRef)
	"markerMid"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"markerEnd"?:        (#MarkerName | "none" | bool | null | #ParamRef)
	"inset"?:            (number | #ParamRef)
	"insetRight"?:       (number | #ParamRef)
	"insetLeft"?:        (number | #ParamRef)
	"x"?:                #ChannelValueIntervalSpec
	"x1"?:               #ChannelValueSpec
	"x2"?:               #ChannelValueSpec
	"y"?:                #ChannelValueSpec
	"mark"!:             "gridFy"
}

#FrameOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"inset"?:            (number | #ParamRef)
	"insetTop"?:         (number | #ParamRef)
	"insetRight"?:       (number | #ParamRef)
	"insetBottom"?:      (number | #ParamRef)
	"insetLeft"?:        (number | #ParamRef)
	"rx"?:               (number | string | #ParamRef)
	"ry"?:               (number | string | #ParamRef)
	"anchor"?:           ("top" | "right" | "bottom" | "left" | null | #ParamRef)
}

#Frame: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"inset"?:            (number | #ParamRef)
	"insetTop"?:         (number | #ParamRef)
	"insetRight"?:       (number | #ParamRef)
	"insetBottom"?:      (number | #ParamRef)
	"insetLeft"?:        (number | #ParamRef)
	"rx"?:               (number | string | #ParamRef)
	"ry"?:               (number | string | #ParamRef)
	"anchor"?:           ("top" | "right" | "bottom" | "left" | null | #ParamRef)
	"mark"!:             "frame"
}

#HexgridOptions: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"binWidth"?:         (number | #ParamRef)
}

#Hexgrid: {
	"filter"?:          #ChannelValue
	"select"?:          #SelectFilter
	"reverse"?:         (bool | #ParamRef)
	"sort"?:            (#SortOrder | #ChannelDomainSort)
	"fx"?:              #ChannelValue
	"fy"?:              #ChannelValue
	"facet"?:           ("auto" | "include" | "exclude" | "super" | bool | null | #ParamRef)
	"facetAnchor"?:     ("top" | "right" | "bottom" | "left" | "top-left" | "top-right" | "bottom-left" | "bottom-right" | "top-empty" | "right-empty" | "bottom-empty" | "left-empty" | "empty" | null | #ParamRef)
	"margin"?:          (number | #ParamRef)
	"marginTop"?:       (number | #ParamRef)
	"marginRight"?:     (number | #ParamRef)
	"marginBottom"?:    (number | #ParamRef)
	"marginLeft"?:      (number | #ParamRef)
	"ariaDescription"?: (string | #ParamRef)
	"ariaHidden"?:      (string | #ParamRef)
	"ariaLabel"?:       #ChannelValue
	"pointerEvents"?:   (string | #ParamRef)
	"title"?:           #ChannelValue
	"tip"?: (bool | #TipPointer | {"textAnchor"?: ("start" | "middle" | "end" | #ParamRef), "lineHeight"?: (number | #ParamRef), "lineWidth"?: (number | #ParamRef), "textOverflow"?: (null | "clip" | "ellipsis" | "clip-start" | "clip-end" | "ellipsis-start" | "ellipsis-middle" | "ellipsis-end" | #ParamRef), "monospace"?: (bool | #ParamRef), "fontFamily"?: (string | #ParamRef), "fontSize"?: (#ChannelValue | #ParamRef), "fontStyle"?: (string | #ParamRef), "fontVariant"?: (string | #ParamRef), "fontWeight"?: (string | number | #ParamRef), "x"?: #ChannelValueSpec, "x1"?: #ChannelValueSpec, "x2"?: #ChannelValueSpec, "y"?: #ChannelValueSpec, "y1"?: #ChannelValueSpec, "y2"?: #ChannelValueSpec, "frameAnchor"?: (#FrameAnchor | #ParamRef), "anchor"?: (#FrameAnchor | #ParamRef), "preferredAnchor"?: (#FrameAnchor | null | #ParamRef), "format"?: {"ariaLabel"?: (bool | string | #ParamRef), "fill"?: (bool | string | #ParamRef), "fillOpacity"?: (bool | string | #ParamRef), "fontSize"?: (bool | string | #ParamRef), "fx"?: (bool | string | #ParamRef), "fy"?: (bool | string | #ParamRef), "geometry"?: (bool | string | #ParamRef), "height"?: (bool | string | #ParamRef), "href"?: (bool | string | #ParamRef), "length"?: (bool | string | #ParamRef), "opacity"?: (bool | string | #ParamRef), "path"?: (bool | string | #ParamRef), "r"?: (bool | string | #ParamRef), "rotate"?: (bool | string | #ParamRef), "src"?: (bool | string | #ParamRef), "stroke"?: (bool | string | #ParamRef), "strokeOpacity"?: (bool | string | #ParamRef), "strokeWidth"?: (bool | string | #ParamRef), "symbol"?: (bool | string | #ParamRef), "text"?: (bool | string | #ParamRef), "title"?: (bool | string | #ParamRef), "weight"?: (bool | string | #ParamRef), "width"?: (bool | string | #ParamRef), "x"?: (bool | string | #ParamRef), "x1"?: (bool | string | #ParamRef), "x2"?: (bool | string | #ParamRef), "y"?: (bool | string | #ParamRef), "y1"?: (bool | string | #ParamRef), "y2"?: (bool | string | #ParamRef), "z"?: (bool | string | #ParamRef)}, "pathFilter"?: (string | #ParamRef), "pointerSize"?: (number | #ParamRef), "textPadding"?: (number | #ParamRef), "pointer"?: #TipPointer, ...} | #ParamRef)
	"channels"?: {[string]: string}
	"clip"?:             ("frame" | "sphere" | bool | null | #ParamRef)
	"dx"?:               (number | #ParamRef)
	"dy"?:               (number | #ParamRef)
	"fill"?:             (#ChannelValueSpec | #ParamRef)
	"fillOpacity"?:      (#ChannelValueSpec | #ParamRef)
	"stroke"?:           (#ChannelValueSpec | #ParamRef)
	"strokeDasharray"?:  (string | number | #ParamRef)
	"strokeDashoffset"?: (string | number | #ParamRef)
	"strokeLinecap"?:    (string | #ParamRef)
	"strokeLinejoin"?:   (string | #ParamRef)
	"strokeMiterlimit"?: (number | #ParamRef)
	"strokeOpacity"?:    #ChannelValueSpec
	"strokeWidth"?:      #ChannelValueSpec
	"opacity"?:          #ChannelValueSpec
	"mixBlendMode"?:     (string | #ParamRef)
	"imageFilter"?:      (string | #ParamRef)
	"paintOrder"?:       (string | #ParamRef)
	"shapeRendering"?:   (string | #ParamRef)
	"href"?:             #ChannelValue
	"target"?:           (string | #ParamRef)
	"binWidth"?:         (number | #ParamRef)
	"mark"!:             "hexgrid"
}

#Meta: {"title"?: string, "description"?: string, "credit"?: string, ...}

#Config: {"extensions"?: (string | [...string]), ...}

#Data: {[string]: #DataDefinition}

#Params: {[string]: #ParamDefinition}

#SpecHead: {"$schema"?: net.AbsURL, "meta"?: #Meta, "config"?: #Config, "data"?: #Data, "params"?: #Params, "plotDefaults"?: #PlotAttributes}

#Plot: {"name"?: string, "width"?: (number | #ParamRef), "height"?: (number | #ParamRef), "aspectRatio"?: (number | bool | null | #ParamRef), "margin"?: (number | #ParamRef), "marginTop"?: (number | #ParamRef), "marginRight"?: (number | #ParamRef), "marginBottom"?: (number | #ParamRef), "marginLeft"?: (number | #ParamRef), "margins"?: {
		"top"?:                         (number | #ParamRef)
		"right"?:                       (number | #ParamRef)
		"bottom"?:                      (number | #ParamRef)
		"left"?:                        (number | #ParamRef)
}, "inset"?: (number | #ParamRef), "style"?: (string | #CSSStyles | null | #ParamRef), "align"?: (number | #ParamRef), "padding"?: (number | #ParamRef), "axis"?: ("top" | "right" | "bottom" | "left" | "both" | bool | null | #ParamRef), "grid"?: (bool | string | #ParamRef), "ariaLabel"?: (string | null), "ariaDescription"?: (string | null), "clip"?: ("frame" | "sphere" | bool | null | #ParamRef), "xScale"?: (#PositionScaleType | null | #ParamRef), "xDomain"?: ([...] | #Fixed | #ParamRef), "xRange"?: ([...] | #Fixed | #ParamRef), "xNice"?: (bool | number | #Interval | #ParamRef), "xInset"?: (number | #ParamRef), "xInsetRight"?: (number | #ParamRef), "xInsetLeft"?: (number | #ParamRef), "xClamp"?: (bool | #ParamRef), "xRound"?: (bool | #ParamRef), "xAlign"?: (number | #ParamRef), "xPadding"?: (number | #ParamRef), "xPaddingInner"?: (number | #ParamRef), "xPaddingOuter"?: (number | #ParamRef), "xAxis"?: ("top" | "bottom" | "both" | bool | null | #ParamRef), "xTicks"?: (number | #Interval | [...] | #ParamRef), "xTickSize"?: (number | #ParamRef), "xTickSpacing"?: (number | #ParamRef), "xTickPadding"?: (number | #ParamRef), "xTickFormat"?: (string | null | #ParamRef), "xTickRotate"?: (number | #ParamRef), "xGrid"?: (bool | string | #Interval | [...] | #ParamRef), "xLine"?: (bool | #ParamRef), "xLabel"?: (string | null | #ParamRef), "xLabelAnchor"?: ("top" | "right" | "bottom" | "left" | "center" | #ParamRef), "xLabelArrow"?: (#LabelArrow | #ParamRef), "xLabelOffset"?: (number | #ParamRef), "xFontVariant"?: (string | #ParamRef), "xAriaLabel"?: (string | #ParamRef), "xAriaDescription"?: (string | #ParamRef), "xPercent"?: (bool | #ParamRef), "xReverse"?: (bool | #ParamRef), "xZero"?: (bool | #ParamRef), "xExponent"?: (number | #ParamRef), "xBase"?: (number | #ParamRef), "xConstant"?: (number | #ParamRef), "yScale"?: (#PositionScaleType | null | #ParamRef), "yDomain"?: ([...] | #Fixed | #ParamRef), "yRange"?: ([...] | #Fixed | #ParamRef), "yNice"?: (bool | number | #Interval | #ParamRef), "yInset"?: (number | #ParamRef), "yInsetTop"?: (number | #ParamRef), "yInsetBottom"?: (number | #ParamRef), "yClamp"?: (bool | #ParamRef), "yRound"?: (bool | #ParamRef), "yAlign"?: (number | #ParamRef), "yPadding"?: (number | #ParamRef), "yPaddingInner"?: (number | #ParamRef), "yPaddingOuter"?: (number | #ParamRef), "yAxis"?: ("left" | "right" | "both" | bool | null | #ParamRef), "yTicks"?: (number | #Interval | [...] | #ParamRef), "yTickSize"?: (number | #ParamRef), "yTickSpacing"?: (number | #ParamRef), "yTickPadding"?: (number | #ParamRef), "yTickFormat"?: (string | null | #ParamRef), "yTickRotate"?: (number | #ParamRef), "yGrid"?: (bool | string | #Interval | [...] | #ParamRef), "yLine"?: (bool | #ParamRef), "yLabel"?: (string | null | #ParamRef), "yLabelAnchor"?: ("top" | "right" | "bottom" | "left" | "center" | #ParamRef), "yLabelArrow"?: (#LabelArrow | #ParamRef), "yLabelOffset"?: (number | #ParamRef), "yFontVariant"?: (string | #ParamRef), "yAriaLabel"?: (string | #ParamRef), "yAriaDescription"?: (string | #ParamRef), "yPercent"?: (bool | #ParamRef), "yReverse"?: (bool | #ParamRef), "yZero"?: (bool | #ParamRef), "yExponent"?: (number | #ParamRef), "yBase"?: (number | #ParamRef), "yConstant"?: (number | #ParamRef), "xyDomain"?: ([...] | #Fixed | #ParamRef), "colorScale"?: (#ColorScaleType | null | #ParamRef), "colorDomain"?: ([...] | #Fixed | #ParamRef), "colorRange"?: ([...] | #Fixed | #ParamRef), "colorClamp"?: (bool | #ParamRef), "colorN"?: (number | #ParamRef), "colorNice"?: (bool | number | #Interval | #ParamRef), "colorScheme"?: (#ColorScheme | #ParamRef), "colorInterpolate"?: (#Interpolate | #ParamRef), "colorPivot"?: (_ | #ParamRef), "colorSymmetric"?: (bool | #ParamRef), "colorLabel"?: (string | null | #ParamRef), "colorPercent"?: (bool | #ParamRef), "colorReverse"?: (bool | #ParamRef), "colorZero"?: (bool | #ParamRef), "colorTickFormat"?: (string | null | #ParamRef), "colorExponent"?: (number | #ParamRef), "colorBase"?: (number | #ParamRef), "colorConstant"?: (number | #ParamRef), "opacityScale"?: (#ContinuousScaleType | null | #ParamRef), "opacityDomain"?: ([...] | #Fixed | #ParamRef), "opacityRange"?: ([...] | #Fixed | #ParamRef), "opacityClamp"?: (bool | #ParamRef), "opacityNice"?: (bool | number | #Interval | #ParamRef), "opacityLabel"?: (string | null | #ParamRef), "opacityPercent"?: (bool | #ParamRef), "opacityReverse"?: (bool | #ParamRef), "opacityZero"?: (bool | #ParamRef), "opacityTickFormat"?: (string | null | #ParamRef), "opacityExponent"?: (number | #ParamRef), "opacityBase"?: (number | #ParamRef), "opacityConstant"?: (number | #ParamRef), "symbolScale"?: (#DiscreteScaleType | null | #ParamRef), "symbolDomain"?: ([...] | #Fixed | #ParamRef), "symbolRange"?: ([...] | #Fixed | #ParamRef), "rScale"?: (#ContinuousScaleType | null | #ParamRef), "rDomain"?: ([...] | #Fixed | #ParamRef), "rRange"?: ([...] | #Fixed | #ParamRef), "rClamp"?: _, "rNice"?: (bool | number | #Interval | #ParamRef), "rLabel"?: (string | null | #ParamRef), "rPercent"?: (bool | #ParamRef), "rZero"?: (bool | #ParamRef), "rExponent"?: (number | #ParamRef), "rBase"?: (number | #ParamRef), "rConstant"?: (number | #ParamRef), "lengthScale"?: (#ContinuousScaleType | null | #ParamRef), "lengthDomain"?: ([...] | #Fixed | #ParamRef), "lengthRange"?: ([...] | #Fixed | #ParamRef), "lengthClamp"?: _, "lengthNice"?: (bool | number | #Interval | #ParamRef), "lengthPercent"?: (bool | #ParamRef), "lengthZero"?: (bool | #ParamRef), "lengthExponent"?: (number | #ParamRef), "lengthBase"?: (number | #ParamRef), "lengthConstant"?: (number | #ParamRef), "projectionType"?: (#ProjectionName | null | #ParamRef), "projectionDomain"?: ({...} | #ParamRef), "projectionRotate"?: ([(number | #ParamRef), (number | #ParamRef), (number | #ParamRef)] | #ParamRef), "projectionParallels"?: ([(number | #ParamRef), (number | #ParamRef)] | #ParamRef), "projectionPrecision"?: (number | #ParamRef), "projectionClip"?: (bool | number | "frame" | null | #ParamRef), "projectionInset"?: (number | #ParamRef), "projectionInsetTop"?: (number | #ParamRef), "projectionInsetRight"?: (number | #ParamRef), "projectionInsetBottom"?: (number | #ParamRef), "projectionInsetLeft"?: (number | #ParamRef), "facetMargin"?: (number | #ParamRef), "facetMarginTop"?: (number | #ParamRef), "facetMarginBottom"?: (number | #ParamRef), "facetMarginLeft"?: (number | #ParamRef), "facetMarginRight"?: (number | #ParamRef), "facetGrid"?: (bool | string | #Interval | [...] | #ParamRef), "facetLabel"?: (string | null | #ParamRef), "fxDomain"?: ([...] | #Fixed | #ParamRef), "fxRange"?: ([...] | #Fixed | #ParamRef), "fxInset"?: (number | #ParamRef), "fxInsetRight"?: (number | #ParamRef), "fxInsetLeft"?: (number | #ParamRef), "fxRound"?: (bool | #ParamRef), "fxAlign"?: (number | #ParamRef), "fxPadding"?: (number | #ParamRef), "fxPaddingInner"?: (number | #ParamRef), "fxPaddingOuter"?: (number | #ParamRef), "fxAxis"?: ("top" | "bottom" | "both" | bool | null | #ParamRef), "fxTicks"?: (number | #Interval | [...] | #ParamRef), "fxTickSize"?: (number | #ParamRef), "fxTickSpacing"?: (number | #ParamRef), "fxTickPadding"?: (number | #ParamRef), "fxTickFormat"?: (string | null | #ParamRef), "fxTickRotate"?: (number | #ParamRef), "fxGrid"?: (bool | string | #Interval | [...] | #ParamRef), "fxLine"?: (bool | #ParamRef), "fxLabel"?: (string | null | #ParamRef), "fxLabelAnchor"?: ("top" | "right" | "bottom" | "left" | "center" | #ParamRef), "fxLabelOffset"?: (number | #ParamRef), "fxFontVariant"?: (string | #ParamRef), "fxAriaLabel"?: (string | #ParamRef), "fxAriaDescription"?: (string | #ParamRef), "fxReverse"?: (bool | #ParamRef), "fyDomain"?: ([...] | #Fixed | #ParamRef), "fyRange"?: ([...] | #Fixed | #ParamRef), "fyInset"?: (number | #ParamRef), "fyInsetTop"?: (number | #ParamRef), "fyInsetBottom"?: (number | #ParamRef), "fyRound"?: (bool | #ParamRef), "fyAlign"?: (number | #ParamRef), "fyPadding"?: (number | #ParamRef), "fyPaddingInner"?: (number | #ParamRef), "fyPaddingOuter"?: (number | #ParamRef), "fyAxis"?: ("left" | "right" | "both" | bool | null | #ParamRef), "fyTicks"?: (number | #Interval | [...] | #ParamRef), "fyTickSize"?: (number | #ParamRef), "fyTickSpacing"?: (number | #ParamRef), "fyTickPadding"?: (number | #ParamRef), "fyTickFormat"?: (string | null | #ParamRef), "fyTickRotate"?: (number | #ParamRef), "fyGrid"?: (bool | string | #Interval | [...] | #ParamRef), "fyLine"?: (bool | #ParamRef), "fyLabel"?: (string | null | #ParamRef), "fyLabelAnchor"?: ("top" | "right" | "bottom" | "left" | "center" | #ParamRef), "fyLabelOffset"?: (number | #ParamRef), "fyFontVariant"?: (string | #ParamRef), "fyAriaLabel"?: (string | #ParamRef), "fyAriaDescription"?: (string | #ParamRef), "fyReverse"?: (bool | #ParamRef), "plot"!: [...(#PlotMark | #PlotInteractor | #PlotLegend)]}
