---
title: Attributes
---
<script setup>
  import { withBase } from 'vitepress';
  import { useLang } from '../../.vitepress/theme/useLang.js';
  const { language, setLanguage } = useLang();
</script>

<LangToggle :model-value="language" aria-label="Attributes documentation language" @update:model-value="setLanguage" />

# Attributes

Plot attributes configure plot layout and scales, including resulting axes and legends.
Attributes are included as plot directives, in the form of functions that take either a literal attribute value or a [`Param`](../core/param) as input.

<template v-if="language === 'js'">

In addition to value arrays, scale domain attributes accept the `Fixed` symbol.

</template>

<template v-else-if="language === 'python'">

In addition to value arrays, scale domain attributes accept the string `"Fixed"` for a fixed domain (for example `vg.x_domain("Fixed")`).

</template>

<LangError v-else :language="language" />

This setting indicates that the scale domain should first be determined by the data, but should then be held fixed across subsequent data updates.
A fixed domain will remain stable, preventing "jumps" in a display that might hamper interpretation of changes.

For additional documentation of scale attributes, see the corresponding [Observable Plot documentation](https://observablehq.com/plot/features/scales#scale-options).

<template v-if="language === 'js'">

Attributes are passed as directives to `plot`, together with marks, interactors, and legends:

``` js
plot(
  width(640),
  height(400),
  marginLeft(48),
  xDomain(Fixed),
  colorScheme("blues")
)
```

</template>

<template v-else-if="language === 'python'">

Attributes are passed as directives to `vg.plot`, together with marks, interactors, and legends:

``` python
import vgplot as vg

vg.plot(
    vg.width(640),
    vg.height(400),
    vg.margin_left(48),
    vg.x_domain("Fixed"),
    vg.color_scheme("blues"),
)
```

</template>

<LangError v-else :language="language" />

## Plot Attributes

JavaScript omitted directive values remain undefined. Python directives whose type admits a boolean default to `True`; other value directives require an argument. Explicit Python `None` is preserved as null.

<template v-if="language === 'js'">



## Facet Attributes

| Directive | Value type |
| --- | --- |
| [`facetMargin(value)`](#facetmargin) | `` number \| ParamRef `` |
| [`facetMarginTop(value)`](#facetmargintop) | `` number \| ParamRef `` |
| [`facetMarginBottom(value)`](#facetmarginbottom) | `` number \| ParamRef `` |
| [`facetMarginLeft(value)`](#facetmarginleft) | `` number \| ParamRef `` |
| [`facetMarginRight(value)`](#facetmarginright) | `` number \| ParamRef `` |
| [`facetGrid(value)`](#facetgrid) | `` boolean \| string \| Interval \| Array<any> \| ParamRef `` |
| [`facetLabel(value)`](#facetlabel) | `` string \| null \| ParamRef `` |


| Directive |
| --- |
| [`name(name)`](#name) |
| [`width(value)`](#width) |
| [`height(value)`](#height) |
| [`aspectRatio(value)`](#aspectratio) |
| [`margin(value)`](#margin) |
| [`marginTop(value)`](#margintop) |
| [`marginRight(value)`](#marginright) |
| [`marginBottom(value)`](#marginbottom) |
| [`marginLeft(value)`](#marginleft) |
| [`margins(object)`](#margins) |
| [`inset(value)`](#inset) |
| [`style(value)`](#style) |
| [`align(value)`](#align) |
| [`padding(value)`](#padding) |
| [`axis(value)`](#axis) |
| [`grid(value)`](#grid) |
| [`ariaLabel(value)`](#arialabel) |
| [`ariaDescription(value)`](#ariadescription) |
| [`clip(value)`](#clip) |


## Projection Attributes

| Directive | Value type |
| --- | --- |
| [`projectionType(value)`](#projectiontype) | `` ProjectionName \| null \| ParamRef `` |
| [`projectionDomain(value)`](#projectiondomain) | `` object \| ParamRef `` |
| [`projectionRotate(value)`](#projectionrotate) | `` [x: number \| ParamRef, y: number \| ParamRef, z?: number \| ParamRef] \| ParamRef `` |
| [`projectionParallels(value)`](#projectionparallels) | `` [y1: number \| ParamRef, y2: number \| ParamRef] \| ParamRef `` |
| [`projectionPrecision(value)`](#projectionprecision) | `` number \| ParamRef `` |
| [`projectionClip(value)`](#projectionclip) | `` boolean \| number \| 'frame' \| null \| ParamRef `` |
| [`projectionInset(value)`](#projectioninset) | `` number \| ParamRef `` |
| [`projectionInsetTop(value)`](#projectioninsettop) | `` number \| ParamRef `` |
| [`projectionInsetRight(value)`](#projectioninsetright) | `` number \| ParamRef `` |
| [`projectionInsetBottom(value)`](#projectioninsetbottom) | `` number \| ParamRef `` |
| [`projectionInsetLeft(value)`](#projectioninsetleft) | `` number \| ParamRef `` |


## Color Scale Attributes

| Directive | Value type |
| --- | --- |
| [`colorScale(value)`](#colorscale) | `` ColorScaleType \| null \| ParamRef `` |
| [`colorDomain(value)`](#colordomain) | `` Array<any> \| Fixed \| ParamRef `` |
| [`colorRange(value)`](#colorrange) | `` Array<any> \| Fixed \| ParamRef `` |
| [`colorClamp(value)`](#colorclamp) | `` boolean \| ParamRef `` |
| [`colorN(value)`](#colorn) | `` number \| ParamRef `` |
| [`colorNice(value)`](#colornice) | `` boolean \| number \| Interval \| ParamRef `` |
| [`colorScheme(value)`](#colorscheme) | `` ColorScheme \| ParamRef `` |
| [`colorInterpolate(value)`](#colorinterpolate) | `` Interpolate \| ParamRef `` |
| [`colorPivot(value)`](#colorpivot) | `` any \| ParamRef `` |
| [`colorSymmetric(value)`](#colorsymmetric) | `` boolean \| ParamRef `` |
| [`colorLabel(value)`](#colorlabel) | `` string \| null \| ParamRef `` |
| [`colorPercent(value)`](#colorpercent) | `` boolean \| ParamRef `` |
| [`colorReverse(value)`](#colorreverse) | `` boolean \| ParamRef `` |
| [`colorZero(value)`](#colorzero) | `` boolean \| ParamRef `` |
| [`colorTickFormat(value)`](#colortickformat) | `` string \| null \| ParamRef `` |
| [`colorExponent(value)`](#colorexponent) | `` number \| ParamRef `` |
| [`colorBase(value)`](#colorbase) | `` number \| ParamRef `` |
| [`colorConstant(value)`](#colorconstant) | `` number \| ParamRef `` |
## Symbol Scale Attributes

| Directive | Value type |
| --- | --- |
| [`symbolScale(value)`](#symbolscale) | `` DiscreteScaleType \| null \| ParamRef `` |
| [`symbolDomain(value)`](#symboldomain) | `` Array<any> \| Fixed \| ParamRef `` |
| [`symbolRange(value)`](#symbolrange) | `` Array<any> \| Fixed \| ParamRef `` |


## fx Scale Attributes

| Directive | Value type |
| --- | --- |
| [`fxDomain(value)`](#fxdomain) | `` Array<any> \| Fixed \| ParamRef `` |
| [`fxRange(value)`](#fxrange) | `` Array<any> \| Fixed \| ParamRef `` |
| [`fxInset(value)`](#fxinset) | `` number \| ParamRef `` |
| [`fxInsetRight(value)`](#fxinsetright) | `` number \| ParamRef `` |
| [`fxInsetLeft(value)`](#fxinsetleft) | `` number \| ParamRef `` |
| [`fxRound(value)`](#fxround) | `` boolean \| ParamRef `` |
| [`fxAlign(value)`](#fxalign) | `` number \| ParamRef `` |
| [`fxPadding(value)`](#fxpadding) | `` number \| ParamRef `` |
| [`fxPaddingInner(value)`](#fxpaddinginner) | `` number \| ParamRef `` |
| [`fxPaddingOuter(value)`](#fxpaddingouter) | `` number \| ParamRef `` |
| [`fxAxis(value)`](#fxaxis) | `` 'top' \| 'bottom' \| 'both' \| boolean \| null \| ParamRef `` |
| [`fxTicks(value)`](#fxticks) | `` number \| Interval \| Array<any> \| ParamRef `` |
| [`fxTickSize(value)`](#fxticksize) | `` number \| ParamRef `` |
| [`fxTickSpacing(value)`](#fxtickspacing) | `` number \| ParamRef `` |
| [`fxTickPadding(value)`](#fxtickpadding) | `` number \| ParamRef `` |
| [`fxTickFormat(value)`](#fxtickformat) | `` string \| null \| ParamRef `` |
| [`fxTickRotate(value)`](#fxtickrotate) | `` number \| ParamRef `` |
| [`fxGrid(value)`](#fxgrid) | `` boolean \| string \| Interval \| Array<any> \| ParamRef `` |
| [`fxLine(value)`](#fxline) | `` boolean \| ParamRef `` |
| [`fxLabel(value)`](#fxlabel) | `` string \| null \| ParamRef `` |
| [`fxLabelAnchor(value)`](#fxlabelanchor) | `` 'top' \| 'right' \| 'bottom' \| 'left' \| 'center' \| ParamRef `` |
| [`fxLabelOffset(value)`](#fxlabeloffset) | `` number \| ParamRef `` |
| [`fxFontVariant(value)`](#fxfontvariant) | `` string \| ParamRef `` |
| [`fxAriaLabel(value)`](#fxarialabel) | `` string \| ParamRef `` |
| [`fxAriaDescription(value)`](#fxariadescription) | `` string \| ParamRef `` |
| [`fxReverse(value)`](#fxreverse) | `` boolean \| ParamRef `` |


## fy Scale Attributes

| Directive | Value type |
| --- | --- |
| [`fyDomain(value)`](#fydomain) | `` Array<any> \| Fixed \| ParamRef `` |
| [`fyRange(value)`](#fyrange) | `` Array<any> \| Fixed \| ParamRef `` |
| [`fyInset(value)`](#fyinset) | `` number \| ParamRef `` |
| [`fyInsetTop(value)`](#fyinsettop) | `` number \| ParamRef `` |
| [`fyInsetBottom(value)`](#fyinsetbottom) | `` number \| ParamRef `` |
| [`fyRound(value)`](#fyround) | `` boolean \| ParamRef `` |
| [`fyAlign(value)`](#fyalign) | `` number \| ParamRef `` |
| [`fyPadding(value)`](#fypadding) | `` number \| ParamRef `` |
| [`fyPaddingInner(value)`](#fypaddinginner) | `` number \| ParamRef `` |
| [`fyPaddingOuter(value)`](#fypaddingouter) | `` number \| ParamRef `` |
| [`fyAxis(value)`](#fyaxis) | `` 'left' \| 'right' \| 'both' \| boolean \| null \| ParamRef `` |
| [`fyTicks(value)`](#fyticks) | `` number \| Interval \| Array<any> \| ParamRef `` |
| [`fyTickSize(value)`](#fyticksize) | `` number \| ParamRef `` |
| [`fyTickSpacing(value)`](#fytickspacing) | `` number \| ParamRef `` |
| [`fyTickPadding(value)`](#fytickpadding) | `` number \| ParamRef `` |
| [`fyTickFormat(value)`](#fytickformat) | `` string \| null \| ParamRef `` |
| [`fyTickRotate(value)`](#fytickrotate) | `` number \| ParamRef `` |
| [`fyGrid(value)`](#fygrid) | `` boolean \| string \| Interval \| Array<any> \| ParamRef `` |
| [`fyLine(value)`](#fyline) | `` boolean \| ParamRef `` |
| [`fyLabel(value)`](#fylabel) | `` string \| null \| ParamRef `` |
| [`fyLabelAnchor(value)`](#fylabelanchor) | `` 'top' \| 'right' \| 'bottom' \| 'left' \| 'center' \| ParamRef `` |
| [`fyLabelOffset(value)`](#fylabeloffset) | `` number \| ParamRef `` |
| [`fyFontVariant(value)`](#fyfontvariant) | `` string \| ParamRef `` |
| [`fyAriaLabel(value)`](#fyarialabel) | `` string \| ParamRef `` |
| [`fyAriaDescription(value)`](#fyariadescription) | `` string \| ParamRef `` |
| [`fyReverse(value)`](#fyreverse) | `` boolean \| ParamRef `` |


## Length Scale Attributes

| Directive | Value type |
| --- | --- |
| [`lengthScale(value)`](#lengthscale) | `` ContinuousScaleType \| null \| ParamRef `` |
| [`lengthDomain(value)`](#lengthdomain) | `` Array<any> \| Fixed \| ParamRef `` |
| [`lengthRange(value)`](#lengthrange) | `` Array<any> \| Fixed \| ParamRef `` |
| [`lengthClamp(value)`](#lengthclamp) | `` any `` |
| [`lengthNice(value)`](#lengthnice) | `` boolean \| number \| Interval \| ParamRef `` |
| [`lengthPercent(value)`](#lengthpercent) | `` boolean \| ParamRef `` |
| [`lengthZero(value)`](#lengthzero) | `` boolean \| ParamRef `` |
| [`lengthExponent(value)`](#lengthexponent) | `` number \| ParamRef `` |
| [`lengthBase(value)`](#lengthbase) | `` number \| ParamRef `` |
| [`lengthConstant(value)`](#lengthconstant) | `` number \| ParamRef `` |


## Opacity Scale Attributes

| Directive | Value type |
| --- | --- |
| [`opacityScale(value)`](#opacityscale) | `` ContinuousScaleType \| null \| ParamRef `` |
| [`opacityDomain(value)`](#opacitydomain) | `` Array<any> \| Fixed \| ParamRef `` |
| [`opacityRange(value)`](#opacityrange) | `` Array<any> \| Fixed \| ParamRef `` |
| [`opacityClamp(value)`](#opacityclamp) | `` boolean \| ParamRef `` |
| [`opacityNice(value)`](#opacitynice) | `` boolean \| number \| Interval \| ParamRef `` |
| [`opacityLabel(value)`](#opacitylabel) | `` string \| null \| ParamRef `` |
| [`opacityPercent(value)`](#opacitypercent) | `` boolean \| ParamRef `` |
| [`opacityReverse(value)`](#opacityreverse) | `` boolean \| ParamRef `` |
| [`opacityZero(value)`](#opacityzero) | `` boolean \| ParamRef `` |
| [`opacityTickFormat(value)`](#opacitytickformat) | `` string \| null \| ParamRef `` |
| [`opacityExponent(value)`](#opacityexponent) | `` number \| ParamRef `` |
| [`opacityBase(value)`](#opacitybase) | `` number \| ParamRef `` |
| [`opacityConstant(value)`](#opacityconstant) | `` number \| ParamRef `` |


## Radius Scale Attributes

| Directive | Value type |
| --- | --- |
| [`rScale(value)`](#rscale) | `` ContinuousScaleType \| null \| ParamRef `` |
| [`rDomain(value)`](#rdomain) | `` Array<any> \| Fixed \| ParamRef `` |
| [`rRange(value)`](#rrange) | `` Array<any> \| Fixed \| ParamRef `` |
| [`rClamp(value)`](#rclamp) | `` any `` |
| [`rNice(value)`](#rnice) | `` boolean \| number \| Interval \| ParamRef `` |
| [`rLabel(value)`](#rlabel) | `` string \| null \| ParamRef `` |
| [`rPercent(value)`](#rpercent) | `` boolean \| ParamRef `` |
| [`rZero(value)`](#rzero) | `` boolean \| ParamRef `` |
| [`rExponent(value)`](#rexponent) | `` number \| ParamRef `` |
| [`rBase(value)`](#rbase) | `` number \| ParamRef `` |
| [`rConstant(value)`](#rconstant) | `` number \| ParamRef `` |


## x Scale Attributes

| Directive | Value type |
| --- | --- |
| [`xScale(value)`](#xscale) | `` PositionScaleType \| null \| ParamRef `` |
| [`xDomain(value)`](#xdomain) | `` Array<any> \| Fixed \| ParamRef `` |
| [`xRange(value)`](#xrange) | `` Array<any> \| Fixed \| ParamRef `` |
| [`xNice(value)`](#xnice) | `` boolean \| number \| Interval \| ParamRef `` |
| [`xInset(value)`](#xinset) | `` number \| ParamRef `` |
| [`xInsetRight(value)`](#xinsetright) | `` number \| ParamRef `` |
| [`xInsetLeft(value)`](#xinsetleft) | `` number \| ParamRef `` |
| [`xClamp(value)`](#xclamp) | `` boolean \| ParamRef `` |
| [`xRound(value)`](#xround) | `` boolean \| ParamRef `` |
| [`xAlign(value)`](#xalign) | `` number \| ParamRef `` |
| [`xPadding(value)`](#xpadding) | `` number \| ParamRef `` |
| [`xPaddingInner(value)`](#xpaddinginner) | `` number \| ParamRef `` |
| [`xPaddingOuter(value)`](#xpaddingouter) | `` number \| ParamRef `` |
| [`xAxis(value)`](#xaxis) | `` 'top' \| 'bottom' \| 'both' \| boolean \| null \| ParamRef `` |
| [`xTicks(value)`](#xticks) | `` number \| Interval \| Array<any> \| ParamRef `` |
| [`xTickSize(value)`](#xticksize) | `` number \| ParamRef `` |
| [`xTickSpacing(value)`](#xtickspacing) | `` number \| ParamRef `` |
| [`xTickPadding(value)`](#xtickpadding) | `` number \| ParamRef `` |
| [`xTickFormat(value)`](#xtickformat) | `` string \| null \| ParamRef `` |
| [`xTickRotate(value)`](#xtickrotate) | `` number \| ParamRef `` |
| [`xGrid(value)`](#xgrid) | `` boolean \| string \| Interval \| Array<any> \| ParamRef `` |
| [`xLine(value)`](#xline) | `` boolean \| ParamRef `` |
| [`xLabel(value)`](#xlabel) | `` string \| null \| ParamRef `` |
| [`xLabelAnchor(value)`](#xlabelanchor) | `` 'top' \| 'right' \| 'bottom' \| 'left' \| 'center' \| ParamRef `` |
| [`xLabelArrow(value)`](#xlabelarrow) | `` LabelArrow \| ParamRef `` |
| [`xLabelOffset(value)`](#xlabeloffset) | `` number \| ParamRef `` |
| [`xFontVariant(value)`](#xfontvariant) | `` string \| ParamRef `` |
| [`xAriaLabel(value)`](#xarialabel) | `` string \| ParamRef `` |
| [`xAriaDescription(value)`](#xariadescription) | `` string \| ParamRef `` |
| [`xPercent(value)`](#xpercent) | `` boolean \| ParamRef `` |
| [`xReverse(value)`](#xreverse) | `` boolean \| ParamRef `` |
| [`xZero(value)`](#xzero) | `` boolean \| ParamRef `` |
| [`xExponent(value)`](#xexponent) | `` number \| ParamRef `` |
| [`xBase(value)`](#xbase) | `` number \| ParamRef `` |
| [`xConstant(value)`](#xconstant) | `` number \| ParamRef `` |
## Paired Scale Domains

| Directive | Value type |
| --- | --- |
| [`xyDomain(value)`](#xydomain) | `` Array<any> \| Fixed \| ParamRef `` |


## y Scale Attributes

| Directive | Value type |
| --- | --- |
| [`yScale(value)`](#yscale) | `` PositionScaleType \| null \| ParamRef `` |
| [`yDomain(value)`](#ydomain) | `` Array<any> \| Fixed \| ParamRef `` |
| [`yRange(value)`](#yrange) | `` Array<any> \| Fixed \| ParamRef `` |
| [`yNice(value)`](#ynice) | `` boolean \| number \| Interval \| ParamRef `` |
| [`yInset(value)`](#yinset) | `` number \| ParamRef `` |
| [`yInsetTop(value)`](#yinsettop) | `` number \| ParamRef `` |
| [`yInsetBottom(value)`](#yinsetbottom) | `` number \| ParamRef `` |
| [`yClamp(value)`](#yclamp) | `` boolean \| ParamRef `` |
| [`yRound(value)`](#yround) | `` boolean \| ParamRef `` |
| [`yAlign(value)`](#yalign) | `` number \| ParamRef `` |
| [`yPadding(value)`](#ypadding) | `` number \| ParamRef `` |
| [`yPaddingInner(value)`](#ypaddinginner) | `` number \| ParamRef `` |
| [`yPaddingOuter(value)`](#ypaddingouter) | `` number \| ParamRef `` |
| [`yAxis(value)`](#yaxis) | `` 'left' \| 'right' \| 'both' \| boolean \| null \| ParamRef `` |
| [`yTicks(value)`](#yticks) | `` number \| Interval \| Array<any> \| ParamRef `` |
| [`yTickSize(value)`](#yticksize) | `` number \| ParamRef `` |
| [`yTickSpacing(value)`](#ytickspacing) | `` number \| ParamRef `` |
| [`yTickPadding(value)`](#ytickpadding) | `` number \| ParamRef `` |
| [`yTickFormat(value)`](#ytickformat) | `` string \| null \| ParamRef `` |
| [`yTickRotate(value)`](#ytickrotate) | `` number \| ParamRef `` |
| [`yGrid(value)`](#ygrid) | `` boolean \| string \| Interval \| Array<any> \| ParamRef `` |
| [`yLine(value)`](#yline) | `` boolean \| ParamRef `` |
| [`yLabel(value)`](#ylabel) | `` string \| null \| ParamRef `` |
| [`yLabelAnchor(value)`](#ylabelanchor) | `` 'top' \| 'right' \| 'bottom' \| 'left' \| 'center' \| ParamRef `` |
| [`yLabelArrow(value)`](#ylabelarrow) | `` LabelArrow \| ParamRef `` |
| [`yLabelOffset(value)`](#ylabeloffset) | `` number \| ParamRef `` |
| [`yFontVariant(value)`](#yfontvariant) | `` string \| ParamRef `` |
| [`yAriaLabel(value)`](#yarialabel) | `` string \| ParamRef `` |
| [`yAriaDescription(value)`](#yariadescription) | `` string \| ParamRef `` |
| [`yPercent(value)`](#ypercent) | `` boolean \| ParamRef `` |
| [`yReverse(value)`](#yreverse) | `` boolean \| ParamRef `` |
| [`yZero(value)`](#yzero) | `` boolean \| ParamRef `` |
| [`yExponent(value)`](#yexponent) | `` number \| ParamRef `` |
| [`yBase(value)`](#ybase) | `` number \| ParamRef `` |
| [`yConstant(value)`](#yconstant) | `` number \| ParamRef `` |

</template>

<template v-else-if="language === 'python'">



## Facet Attributes

| Directive | Value type |
| --- | --- |
| [`vg.facet_margin(value)`](#facetmargin) | `` number \| ParamRef `` |
| [`vg.facet_margin_top(value)`](#facetmargintop) | `` number \| ParamRef `` |
| [`vg.facet_margin_bottom(value)`](#facetmarginbottom) | `` number \| ParamRef `` |
| [`vg.facet_margin_left(value)`](#facetmarginleft) | `` number \| ParamRef `` |
| [`vg.facet_margin_right(value)`](#facetmarginright) | `` number \| ParamRef `` |
| [`vg.facet_grid(value=True)`](#facetgrid) | `` boolean \| string \| Interval \| Array<any> \| ParamRef `` |
| [`vg.facet_label(value)`](#facetlabel) | `` string \| null \| ParamRef `` |


## Plot Attributes

| Directive |
| --- |
| [`vg.name(value)`](#name) |
| [`vg.width(value)`](#width) |
| [`vg.height(value)`](#height) |
| [`vg.aspect_ratio(value=True)`](#aspectratio) |
| [`vg.margin(value)`](#margin) |
| [`vg.margin_top(value)`](#margintop) |
| [`vg.margin_right(value)`](#marginright) |
| [`vg.margin_bottom(value)`](#marginbottom) |
| [`vg.margin_left(value)`](#marginleft) |
| [`vg.margins(top=None, right=None, bottom=None, left=None, **kwargs)`](#margins) |
| [`vg.inset(value)`](#inset) |
| [`vg.style(value)`](#style) |
| [`vg.align(value)`](#align) |
| [`vg.padding(value)`](#padding) |
| [`vg.axis(value=True)`](#axis) |
| [`vg.grid(value=True)`](#grid) |
| [`vg.aria_label(value)`](#arialabel) |
| [`vg.aria_description(value)`](#ariadescription) |
| [`vg.clip(value=True)`](#clip) |


## Projection Attributes

| Directive | Value type |
| --- | --- |
| [`vg.projection_type(value)`](#projectiontype) | `` ProjectionName \| null \| ParamRef `` |
| [`vg.projection_domain(value)`](#projectiondomain) | `` object \| ParamRef `` |
| [`vg.projection_rotate(value)`](#projectionrotate) | `` [x: number \| ParamRef, y: number \| ParamRef, z?: number \| ParamRef] \| ParamRef `` |
| [`vg.projection_parallels(value)`](#projectionparallels) | `` [y1: number \| ParamRef, y2: number \| ParamRef] \| ParamRef `` |
| [`vg.projection_precision(value)`](#projectionprecision) | `` number \| ParamRef `` |
| [`vg.projection_clip(value=True)`](#projectionclip) | `` boolean \| number \| 'frame' \| null \| ParamRef `` |
| [`vg.projection_inset(value)`](#projectioninset) | `` number \| ParamRef `` |
| [`vg.projection_inset_top(value)`](#projectioninsettop) | `` number \| ParamRef `` |
| [`vg.projection_inset_right(value)`](#projectioninsetright) | `` number \| ParamRef `` |
| [`vg.projection_inset_bottom(value)`](#projectioninsetbottom) | `` number \| ParamRef `` |
| [`vg.projection_inset_left(value)`](#projectioninsetleft) | `` number \| ParamRef `` |


## Color Scale Attributes

| Directive | Value type |
| --- | --- |
| [`vg.color_scale(value)`](#colorscale) | `` ColorScaleType \| null \| ParamRef `` |
| [`vg.color_domain(value)`](#colordomain) | `` Array<any> \| Fixed \| ParamRef `` |
| [`vg.color_range(value)`](#colorrange) | `` Array<any> \| Fixed \| ParamRef `` |
| [`vg.color_clamp(value=True)`](#colorclamp) | `` boolean \| ParamRef `` |
| [`vg.color_n(value)`](#colorn) | `` number \| ParamRef `` |
| [`vg.color_nice(value=True)`](#colornice) | `` boolean \| number \| Interval \| ParamRef `` |
| [`vg.color_scheme(value)`](#colorscheme) | `` ColorScheme \| ParamRef `` |
| [`vg.color_interpolate(value)`](#colorinterpolate) | `` Interpolate \| ParamRef `` |
| [`vg.color_pivot(value)`](#colorpivot) | `` any \| ParamRef `` |
| [`vg.color_symmetric(value=True)`](#colorsymmetric) | `` boolean \| ParamRef `` |
| [`vg.color_label(value)`](#colorlabel) | `` string \| null \| ParamRef `` |
| [`vg.color_percent(value=True)`](#colorpercent) | `` boolean \| ParamRef `` |
| [`vg.color_reverse(value=True)`](#colorreverse) | `` boolean \| ParamRef `` |
| [`vg.color_zero(value=True)`](#colorzero) | `` boolean \| ParamRef `` |
| [`vg.color_tick_format(value)`](#colortickformat) | `` string \| null \| ParamRef `` |
| [`vg.color_exponent(value)`](#colorexponent) | `` number \| ParamRef `` |
| [`vg.color_base(value)`](#colorbase) | `` number \| ParamRef `` |
| [`vg.color_constant(value)`](#colorconstant) | `` number \| ParamRef `` |
## Symbol Scale Attributes

| Directive | Value type |
| --- | --- |
| [`vg.symbol_scale(value)`](#symbolscale) | `` DiscreteScaleType \| null \| ParamRef `` |
| [`vg.symbol_domain(value)`](#symboldomain) | `` Array<any> \| Fixed \| ParamRef `` |
| [`vg.symbol_range(value)`](#symbolrange) | `` Array<any> \| Fixed \| ParamRef `` |


## fx Scale Attributes

| Directive | Value type |
| --- | --- |
| [`vg.fx_domain(value)`](#fxdomain) | `` Array<any> \| Fixed \| ParamRef `` |
| [`vg.fx_range(value)`](#fxrange) | `` Array<any> \| Fixed \| ParamRef `` |
| [`vg.fx_inset(value)`](#fxinset) | `` number \| ParamRef `` |
| [`vg.fx_inset_right(value)`](#fxinsetright) | `` number \| ParamRef `` |
| [`vg.fx_inset_left(value)`](#fxinsetleft) | `` number \| ParamRef `` |
| [`vg.fx_round(value=True)`](#fxround) | `` boolean \| ParamRef `` |
| [`vg.fx_align(value)`](#fxalign) | `` number \| ParamRef `` |
| [`vg.fx_padding(value)`](#fxpadding) | `` number \| ParamRef `` |
| [`vg.fx_padding_inner(value)`](#fxpaddinginner) | `` number \| ParamRef `` |
| [`vg.fx_padding_outer(value)`](#fxpaddingouter) | `` number \| ParamRef `` |
| [`vg.fx_axis(value=True)`](#fxaxis) | `` 'top' \| 'bottom' \| 'both' \| boolean \| null \| ParamRef `` |
| [`vg.fx_ticks(value)`](#fxticks) | `` number \| Interval \| Array<any> \| ParamRef `` |
| [`vg.fx_tick_size(value)`](#fxticksize) | `` number \| ParamRef `` |
| [`vg.fx_tick_spacing(value)`](#fxtickspacing) | `` number \| ParamRef `` |
| [`vg.fx_tick_padding(value)`](#fxtickpadding) | `` number \| ParamRef `` |
| [`vg.fx_tick_format(value)`](#fxtickformat) | `` string \| null \| ParamRef `` |
| [`vg.fx_tick_rotate(value)`](#fxtickrotate) | `` number \| ParamRef `` |
| [`vg.fx_grid(value=True)`](#fxgrid) | `` boolean \| string \| Interval \| Array<any> \| ParamRef `` |
| [`vg.fx_line(value=True)`](#fxline) | `` boolean \| ParamRef `` |
| [`vg.fx_label(value)`](#fxlabel) | `` string \| null \| ParamRef `` |
| [`vg.fx_label_anchor(value)`](#fxlabelanchor) | `` 'top' \| 'right' \| 'bottom' \| 'left' \| 'center' \| ParamRef `` |
| [`vg.fx_label_offset(value)`](#fxlabeloffset) | `` number \| ParamRef `` |
| [`vg.fx_font_variant(value)`](#fxfontvariant) | `` string \| ParamRef `` |
| [`vg.fx_aria_label(value)`](#fxarialabel) | `` string \| ParamRef `` |
| [`vg.fx_aria_description(value)`](#fxariadescription) | `` string \| ParamRef `` |
| [`vg.fx_reverse(value=True)`](#fxreverse) | `` boolean \| ParamRef `` |


## fy Scale Attributes

| Directive | Value type |
| --- | --- |
| [`vg.fy_domain(value)`](#fydomain) | `` Array<any> \| Fixed \| ParamRef `` |
| [`vg.fy_range(value)`](#fyrange) | `` Array<any> \| Fixed \| ParamRef `` |
| [`vg.fy_inset(value)`](#fyinset) | `` number \| ParamRef `` |
| [`vg.fy_inset_top(value)`](#fyinsettop) | `` number \| ParamRef `` |
| [`vg.fy_inset_bottom(value)`](#fyinsetbottom) | `` number \| ParamRef `` |
| [`vg.fy_round(value=True)`](#fyround) | `` boolean \| ParamRef `` |
| [`vg.fy_align(value)`](#fyalign) | `` number \| ParamRef `` |
| [`vg.fy_padding(value)`](#fypadding) | `` number \| ParamRef `` |
| [`vg.fy_padding_inner(value)`](#fypaddinginner) | `` number \| ParamRef `` |
| [`vg.fy_padding_outer(value)`](#fypaddingouter) | `` number \| ParamRef `` |
| [`vg.fy_axis(value=True)`](#fyaxis) | `` 'left' \| 'right' \| 'both' \| boolean \| null \| ParamRef `` |
| [`vg.fy_ticks(value)`](#fyticks) | `` number \| Interval \| Array<any> \| ParamRef `` |
| [`vg.fy_tick_size(value)`](#fyticksize) | `` number \| ParamRef `` |
| [`vg.fy_tick_spacing(value)`](#fytickspacing) | `` number \| ParamRef `` |
| [`vg.fy_tick_padding(value)`](#fytickpadding) | `` number \| ParamRef `` |
| [`vg.fy_tick_format(value)`](#fytickformat) | `` string \| null \| ParamRef `` |
| [`vg.fy_tick_rotate(value)`](#fytickrotate) | `` number \| ParamRef `` |
| [`vg.fy_grid(value=True)`](#fygrid) | `` boolean \| string \| Interval \| Array<any> \| ParamRef `` |
| [`vg.fy_line(value=True)`](#fyline) | `` boolean \| ParamRef `` |
| [`vg.fy_label(value)`](#fylabel) | `` string \| null \| ParamRef `` |
| [`vg.fy_label_anchor(value)`](#fylabelanchor) | `` 'top' \| 'right' \| 'bottom' \| 'left' \| 'center' \| ParamRef `` |
| [`vg.fy_label_offset(value)`](#fylabeloffset) | `` number \| ParamRef `` |
| [`vg.fy_font_variant(value)`](#fyfontvariant) | `` string \| ParamRef `` |
| [`vg.fy_aria_label(value)`](#fyarialabel) | `` string \| ParamRef `` |
| [`vg.fy_aria_description(value)`](#fyariadescription) | `` string \| ParamRef `` |
| [`vg.fy_reverse(value=True)`](#fyreverse) | `` boolean \| ParamRef `` |


## Length Scale Attributes

| Directive | Value type |
| --- | --- |
| [`vg.length_scale(value)`](#lengthscale) | `` ContinuousScaleType \| null \| ParamRef `` |
| [`vg.length_domain(value)`](#lengthdomain) | `` Array<any> \| Fixed \| ParamRef `` |
| [`vg.length_range(value)`](#lengthrange) | `` Array<any> \| Fixed \| ParamRef `` |
| [`vg.length_clamp(value)`](#lengthclamp) | `` any `` |
| [`vg.length_nice(value=True)`](#lengthnice) | `` boolean \| number \| Interval \| ParamRef `` |
| [`vg.length_percent(value=True)`](#lengthpercent) | `` boolean \| ParamRef `` |
| [`vg.length_zero(value=True)`](#lengthzero) | `` boolean \| ParamRef `` |
| [`vg.length_exponent(value)`](#lengthexponent) | `` number \| ParamRef `` |
| [`vg.length_base(value)`](#lengthbase) | `` number \| ParamRef `` |
| [`vg.length_constant(value)`](#lengthconstant) | `` number \| ParamRef `` |


## Opacity Scale Attributes

| Directive | Value type |
| --- | --- |
| [`vg.opacity_scale(value)`](#opacityscale) | `` ContinuousScaleType \| null \| ParamRef `` |
| [`vg.opacity_domain(value)`](#opacitydomain) | `` Array<any> \| Fixed \| ParamRef `` |
| [`vg.opacity_range(value)`](#opacityrange) | `` Array<any> \| Fixed \| ParamRef `` |
| [`vg.opacity_clamp(value=True)`](#opacityclamp) | `` boolean \| ParamRef `` |
| [`vg.opacity_nice(value=True)`](#opacitynice) | `` boolean \| number \| Interval \| ParamRef `` |
| [`vg.opacity_label(value)`](#opacitylabel) | `` string \| null \| ParamRef `` |
| [`vg.opacity_percent(value=True)`](#opacitypercent) | `` boolean \| ParamRef `` |
| [`vg.opacity_reverse(value=True)`](#opacityreverse) | `` boolean \| ParamRef `` |
| [`vg.opacity_zero(value=True)`](#opacityzero) | `` boolean \| ParamRef `` |
| [`vg.opacity_tick_format(value)`](#opacitytickformat) | `` string \| null \| ParamRef `` |
| [`vg.opacity_exponent(value)`](#opacityexponent) | `` number \| ParamRef `` |
| [`vg.opacity_base(value)`](#opacitybase) | `` number \| ParamRef `` |
| [`vg.opacity_constant(value)`](#opacityconstant) | `` number \| ParamRef `` |


## Radius Scale Attributes

| Directive | Value type |
| --- | --- |
| [`vg.r_scale(value)`](#rscale) | `` ContinuousScaleType \| null \| ParamRef `` |
| [`vg.r_domain(value)`](#rdomain) | `` Array<any> \| Fixed \| ParamRef `` |
| [`vg.r_range(value)`](#rrange) | `` Array<any> \| Fixed \| ParamRef `` |
| [`vg.r_clamp(value)`](#rclamp) | `` any `` |
| [`vg.r_nice(value=True)`](#rnice) | `` boolean \| number \| Interval \| ParamRef `` |
| [`vg.r_label(value)`](#rlabel) | `` string \| null \| ParamRef `` |
| [`vg.r_percent(value=True)`](#rpercent) | `` boolean \| ParamRef `` |
| [`vg.r_zero(value=True)`](#rzero) | `` boolean \| ParamRef `` |
| [`vg.r_exponent(value)`](#rexponent) | `` number \| ParamRef `` |
| [`vg.r_base(value)`](#rbase) | `` number \| ParamRef `` |
| [`vg.r_constant(value)`](#rconstant) | `` number \| ParamRef `` |


## x Scale Attributes

| Directive | Value type |
| --- | --- |
| [`vg.x_scale(value)`](#xscale) | `` PositionScaleType \| null \| ParamRef `` |
| [`vg.x_domain(value)`](#xdomain) | `` Array<any> \| Fixed \| ParamRef `` |
| [`vg.x_range(value)`](#xrange) | `` Array<any> \| Fixed \| ParamRef `` |
| [`vg.x_nice(value=True)`](#xnice) | `` boolean \| number \| Interval \| ParamRef `` |
| [`vg.x_inset(value)`](#xinset) | `` number \| ParamRef `` |
| [`vg.x_inset_right(value)`](#xinsetright) | `` number \| ParamRef `` |
| [`vg.x_inset_left(value)`](#xinsetleft) | `` number \| ParamRef `` |
| [`vg.x_clamp(value=True)`](#xclamp) | `` boolean \| ParamRef `` |
| [`vg.x_round(value=True)`](#xround) | `` boolean \| ParamRef `` |
| [`vg.x_align(value)`](#xalign) | `` number \| ParamRef `` |
| [`vg.x_padding(value)`](#xpadding) | `` number \| ParamRef `` |
| [`vg.x_padding_inner(value)`](#xpaddinginner) | `` number \| ParamRef `` |
| [`vg.x_padding_outer(value)`](#xpaddingouter) | `` number \| ParamRef `` |
| [`vg.x_axis(value=True)`](#xaxis) | `` 'top' \| 'bottom' \| 'both' \| boolean \| null \| ParamRef `` |
| [`vg.x_ticks(value)`](#xticks) | `` number \| Interval \| Array<any> \| ParamRef `` |
| [`vg.x_tick_size(value)`](#xticksize) | `` number \| ParamRef `` |
| [`vg.x_tick_spacing(value)`](#xtickspacing) | `` number \| ParamRef `` |
| [`vg.x_tick_padding(value)`](#xtickpadding) | `` number \| ParamRef `` |
| [`vg.x_tick_format(value)`](#xtickformat) | `` string \| null \| ParamRef `` |
| [`vg.x_tick_rotate(value)`](#xtickrotate) | `` number \| ParamRef `` |
| [`vg.x_grid(value=True)`](#xgrid) | `` boolean \| string \| Interval \| Array<any> \| ParamRef `` |
| [`vg.x_line(value=True)`](#xline) | `` boolean \| ParamRef `` |
| [`vg.x_label(value)`](#xlabel) | `` string \| null \| ParamRef `` |
| [`vg.x_label_anchor(value)`](#xlabelanchor) | `` 'top' \| 'right' \| 'bottom' \| 'left' \| 'center' \| ParamRef `` |
| [`vg.x_label_arrow(value)`](#xlabelarrow) | `` LabelArrow \| ParamRef `` |
| [`vg.x_label_offset(value)`](#xlabeloffset) | `` number \| ParamRef `` |
| [`vg.x_font_variant(value)`](#xfontvariant) | `` string \| ParamRef `` |
| [`vg.x_aria_label(value)`](#xarialabel) | `` string \| ParamRef `` |
| [`vg.x_aria_description(value)`](#xariadescription) | `` string \| ParamRef `` |
| [`vg.x_percent(value=True)`](#xpercent) | `` boolean \| ParamRef `` |
| [`vg.x_reverse(value=True)`](#xreverse) | `` boolean \| ParamRef `` |
| [`vg.x_zero(value=True)`](#xzero) | `` boolean \| ParamRef `` |
| [`vg.x_exponent(value)`](#xexponent) | `` number \| ParamRef `` |
| [`vg.x_base(value)`](#xbase) | `` number \| ParamRef `` |
| [`vg.x_constant(value)`](#xconstant) | `` number \| ParamRef `` |
## Paired Scale Domains

| Directive | Value type |
| --- | --- |
| [`vg.xy_domain(value)`](#xydomain) | `` Array<any> \| Fixed \| ParamRef `` |


## y Scale Attributes

| Directive | Value type |
| --- | --- |
| [`vg.y_scale(value)`](#yscale) | `` PositionScaleType \| null \| ParamRef `` |
| [`vg.y_domain(value)`](#ydomain) | `` Array<any> \| Fixed \| ParamRef `` |
| [`vg.y_range(value)`](#yrange) | `` Array<any> \| Fixed \| ParamRef `` |
| [`vg.y_nice(value=True)`](#ynice) | `` boolean \| number \| Interval \| ParamRef `` |
| [`vg.y_inset(value)`](#yinset) | `` number \| ParamRef `` |
| [`vg.y_inset_top(value)`](#yinsettop) | `` number \| ParamRef `` |
| [`vg.y_inset_bottom(value)`](#yinsetbottom) | `` number \| ParamRef `` |
| [`vg.y_clamp(value=True)`](#yclamp) | `` boolean \| ParamRef `` |
| [`vg.y_round(value=True)`](#yround) | `` boolean \| ParamRef `` |
| [`vg.y_align(value)`](#yalign) | `` number \| ParamRef `` |
| [`vg.y_padding(value)`](#ypadding) | `` number \| ParamRef `` |
| [`vg.y_padding_inner(value)`](#ypaddinginner) | `` number \| ParamRef `` |
| [`vg.y_padding_outer(value)`](#ypaddingouter) | `` number \| ParamRef `` |
| [`vg.y_axis(value=True)`](#yaxis) | `` 'left' \| 'right' \| 'both' \| boolean \| null \| ParamRef `` |
| [`vg.y_ticks(value)`](#yticks) | `` number \| Interval \| Array<any> \| ParamRef `` |
| [`vg.y_tick_size(value)`](#yticksize) | `` number \| ParamRef `` |
| [`vg.y_tick_spacing(value)`](#ytickspacing) | `` number \| ParamRef `` |
| [`vg.y_tick_padding(value)`](#ytickpadding) | `` number \| ParamRef `` |
| [`vg.y_tick_format(value)`](#ytickformat) | `` string \| null \| ParamRef `` |
| [`vg.y_tick_rotate(value)`](#ytickrotate) | `` number \| ParamRef `` |
| [`vg.y_grid(value=True)`](#ygrid) | `` boolean \| string \| Interval \| Array<any> \| ParamRef `` |
| [`vg.y_line(value=True)`](#yline) | `` boolean \| ParamRef `` |
| [`vg.y_label(value)`](#ylabel) | `` string \| null \| ParamRef `` |
| [`vg.y_label_anchor(value)`](#ylabelanchor) | `` 'top' \| 'right' \| 'bottom' \| 'left' \| 'center' \| ParamRef `` |
| [`vg.y_label_arrow(value)`](#ylabelarrow) | `` LabelArrow \| ParamRef `` |
| [`vg.y_label_offset(value)`](#ylabeloffset) | `` number \| ParamRef `` |
| [`vg.y_font_variant(value)`](#yfontvariant) | `` string \| ParamRef `` |
| [`vg.y_aria_label(value)`](#yarialabel) | `` string \| ParamRef `` |
| [`vg.y_aria_description(value)`](#yariadescription) | `` string \| ParamRef `` |
| [`vg.y_percent(value=True)`](#ypercent) | `` boolean \| ParamRef `` |
| [`vg.y_reverse(value=True)`](#yreverse) | `` boolean \| ParamRef `` |
| [`vg.y_zero(value=True)`](#yzero) | `` boolean \| ParamRef `` |
| [`vg.y_exponent(value)`](#yexponent) | `` number \| ParamRef `` |
| [`vg.y_base(value)`](#ybase) | `` number \| ParamRef `` |
| [`vg.y_constant(value)`](#yconstant) | `` number \| ParamRef `` |

</template>

<LangError v-else :language="language" />


## cartesian attribute reference

### xScale

The *x* scale type, affecting how the scale encodes abstract data, say by
applying a mathematical transformation. If null, the scale is disabled.

For quantitative data (numbers), defaults to *linear*; for temporal data
(dates), defaults to *utc*; for ordinal data (strings or booleans),
defaults to *point* for position scales, *categorical* for color scales,
and otherwise *ordinal*. However, the radius scale defaults to *sqrt*, and
the length and opacity scales default to *linear*; these scales are
intended for quantitative data. The plot’s marks may also impose a scale
type; for example, the barY mark requires that *x* is a *band* scale.

### xDomain

The extent of the scale’s inputs (abstract values). By default inferred
from channel values. For continuous data (numbers and dates), it is
typically [*min*, *max*]; it can be [*max*, *min*] to reverse the scale.
For ordinal data (strings or booleans), it is an array (or iterable) of
values is the desired order, defaulting to natural ascending order.

Linear scales have a default domain of [0, 1]. Log scales have a default
domain of [1, 10] and cannot include zero. Radius scales have a default
domain from 0 to the median first quartile of associated channels. Length
have a default domain from 0 to the median median of associated channels.
Opacity scales have a default domain from 0 to the maximum value of
associated channels.

### xRange

The extent of the scale’s outputs (visual values). By default inferred from
the scale’s **type** and **domain**, and for position scales, the plot’s
dimensions. For continuous data (numbers and dates), and for ordinal
position scales (*point* and *band*), it is typically [*min*, *max*]; it
can be [*max*, *min*] to reverse the scale.

### xNice

<span id="ynice"></span>
Applies to `xNice`, `yNice`.

If true, or a tick count or interval, extend the domain to nice round
values. Defaults to 1, 2 or 5 times a power of 10 for *linear* scales, and
nice time intervals for *utc* and *time* scales. Pass an interval such as
*minute*, *wednesday* or *month* to specify what constitutes a nice
interval.

For continuous scales only.

### xInset

<span id="yinset"></span>
Applies to `xInset`, `yInset`.

Shorthand to set the same default for all four insets: **insetTop**,
**insetRight**, **insetBottom**, and **insetLeft**. All insets typically
default to zero, though not always (say when using bin transform). A
positive inset reduces effective area, while a negative inset increases it.

### xInsetRight

Insets the right edge by the specified number of pixels. A positive value
insets towards the left edge (reducing effective area), while a negative
value insets away from the left edge (increasing it).

### xInsetLeft

Insets the left edge by the specified number of pixels. A positive value
insets towards the right edge (reducing effective area), while a negative
value insets away from the right edge (increasing it).

### xClamp

<span id="yclamp"></span>
Applies to `xClamp`, `yClamp`.

If true, values below the domain minimum are treated as the domain minimum,
and values above the domain maximum are treated as the domain maximum.

Clamping is useful for focusing on a subset of the data while ensuring that
extreme values remain visible, but use caution: clamped values may need an
annotation to avoid misinterpretation. Clamping typically requires setting
an explicit **domain** since if the domain is inferred, no values will be
outside the domain.

For continuous scales only.

### xRound

<span id="yround"></span>
Applies to `xRound`, `yRound`.

If true, round the output value to the nearest integer (pixel); useful for
crisp edges when rendering.

For position scales only.

### xAlign

<span id="yalign"></span>
Applies to `xAlign`, `yAlign`.

How to distribute unused space in the **range** for *point* and *band*
scales. A number in [0, 1], such as:

- 0 - use the start of the range, putting unused space at the end
- 0.5 (default) - use the middle, distributing unused space evenly
- 1 use the end, putting unused space at the start

For ordinal position scales only.

### xPadding

<span id="ypadding"></span>
Applies to `xPadding`, `yPadding`.

For *band* scales, how much of the **range** to reserve to separate
adjacent bands; defaults to 0.1 (10%). For *point* scales, the amount of
inset for the first and last value as a proportion of the bandwidth;
defaults to 0.5 (50%).

For ordinal position scales only.

### xPaddingInner

<span id="ypaddinginner"></span>
Applies to `xPaddingInner`, `yPaddingInner`.

For a *band* scale, how much of the range to reserve to separate
adjacent bands.

### xPaddingOuter

<span id="ypaddingouter"></span>
Applies to `xPaddingOuter`, `yPaddingOuter`.

For a *band* scale, how much of the range to reserve to inset first and
last bands.

### xAxis

The side of the frame on which to place the implicit axis: *top* or
*bottom* for *x*. Defaults to *bottom* for an *x* scale.

If *both*, an implicit axis will be rendered on both sides of the plot
(*top* and *bottom* for *x*). If null, the implicit axis is suppressed.

### xTicks

<span id="yticks"></span>
Applies to `xTicks`, `yTicks`.

The desired approximate number of axis ticks, or an explicit array of tick
values, or an interval such as *day* or *month*.

### xTickSize

<span id="yticksize"></span>
Applies to `xTickSize`, `yTickSize`.

The length of axis tick marks in pixels; negative values extend in the
opposite direction. Defaults to 6 for *x* and *y* axes and *color* and
*opacity* *ramp* legends, and 0 for *fx* and *fy* axes.

### xTickSpacing

<span id="ytickspacing"></span>
Applies to `xTickSpacing`, `yTickSpacing`.

The desired approximate spacing between adjacent axis ticks, affecting the
default **ticks**; defaults to 80 pixels for *x* and *fx*, and 35 pixels
for *y* and *fy*.

### xTickPadding

The distance between an axis tick mark and its associated text label (in
pixels); often defaults to 3, but may be affected by **xTickSize** and
**xTickRotate**.

### xTickFormat

<span id="ytickformat"></span>
Applies to `xTickFormat`, `yTickFormat`.

How to format inputs (abstract values) for axis tick labels; one of:

- a [d3-format](https://d3js.org/d3-time) string for numeric scales
- a [d3-time-format](https://d3js.org/d3-time-format) string for temporal scales

### xTickRotate

<span id="ytickrotate"></span>
Applies to `xTickRotate`, `yTickRotate`.

The rotation angle of axis tick labels in degrees clocksize; defaults to 0.

### xGrid

<span id="ygrid"></span>
Applies to `xGrid`, `yGrid`.

Whether to show a grid aligned with the scale’s ticks. If true, show a grid
with the currentColor stroke; if a string, show a grid with the specified
stroke color; if an approximate number of ticks, an interval, or an array
of tick values, show corresponding grid lines. See also the grid mark.

For axes only.

### xLine

<span id="yline"></span>
Applies to `xLine`, `yLine`.

If true, draw a line along the axis; if false (default), do not.

### xLabel

<span id="ylabel"></span>
Applies to `xLabel`, `yLabel`.

A textual label to show on the axis or legend; if null, show no label. By
default the scale label is inferred from channel definitions, possibly with
an arrow (↑, →, ↓, or ←) to indicate the direction of increasing value.

For axes and legends only.

### xLabelAnchor

<span id="ylabelanchor"></span>
Applies to `xLabelAnchor`, `yLabelAnchor`.

Where to place the axis **label** relative to the plot’s frame. For
vertical position scales (*y* and *fy*), may be *top*, *bottom*, or
*center*; for horizontal position scales (*x* and *fx*), may be *left*,
*right*, or *center*. Defaults to *center* for ordinal scales (including
*fx* and *fy*), and otherwise *top* for *y*, and *right* for *x*.

### xLabelArrow

<span id="ylabelarrow"></span>
Applies to `xLabelArrow`, `yLabelArrow`.

Whether to apply a directional arrow such as → or ↑ to the x-axis scale
label. If *auto* (the default), the presence of the arrow depends on
whether the scale is ordinal.

### xLabelOffset

<span id="ylabeloffset"></span>
Applies to `xLabelOffset`, `yLabelOffset`.

The axis **label** position offset (in pixels); default depends on margins
and orientation.

### xFontVariant

<span id="yfontvariant"></span>
Applies to `xFontVariant`, `yFontVariant`.

The font-variant attribute for axis ticks; defaults to *tabular-nums* for
quantitative axes.

### xAriaLabel

<span id="yarialabel"></span>
Applies to `xAriaLabel`, `yAriaLabel`.

A short label representing the axis in the accessibility tree.

### xAriaDescription

<span id="yariadescription"></span>
Applies to `xAriaDescription`, `yAriaDescription`.

A textual description for the axis in the accessibility tree.

### xPercent

<span id="ypercent"></span>
Applies to `xPercent`, `yPercent`.

If true, shorthand for a transform suitable for percentages, mapping
proportions in [0, 1] to [0, 100].

### xReverse

Whether to reverse the scale’s encoding; equivalent to reversing either the
**domain** or **range**.

### xZero

<span id="yzero"></span>
Applies to `xZero`, `yZero`.

Whether the **domain** must include zero. If the domain minimum is
positive, it will be set to zero; otherwise if the domain maximum is
negative, it will be set to zero.

For quantitative scales only.

### xExponent

<span id="yexponent"></span>
Applies to `xExponent`, `yExponent`.

A power scale’s exponent (*e.g.*, 0.5 for sqrt); defaults to 1 for a
linear scale. For *pow* scales only.

### xBase

<span id="ybase"></span>
Applies to `xBase`, `yBase`.

A log scale’s base; defaults to 10. Does not affect the scale’s encoding,
but rather the default ticks. For *log* scales only.

### xConstant

<span id="yconstant"></span>
Applies to `xConstant`, `yConstant`.

A symlog scale’s constant, expressing the magnitude of the linear region
around the origin; defaults to 1. For *symlog* scales only.

### yScale

The *y* scale type, affecting how the scale encodes abstract data, say by
applying a mathematical transformation. If null, the scale is disabled.

For quantitative data (numbers), defaults to *linear*; for temporal data
(dates), defaults to *utc*; for ordinal data (strings or booleans),
defaults to *point* for position scales,  The plot’s marks may also impose
a scale type; for example, the barY mark requires that *x* is a *band*
scale.

### yDomain

The extent of the scale’s inputs (abstract values). By default inferred
from channel values. For continuous data (numbers and dates), it is
typically [*min*, *max*]; it can be [*max*, *min*] to reverse the scale.
For ordinal data (strings or booleans), it is an array (or iterable) of
values is the desired order, defaulting to natural ascending order.

Linear scales have a default domain of [0, 1]. Log scales have a default
domain of [1, 10] and cannot include zero.

### yRange

The extent of the scale’s outputs (visual values). By default inferred
from the scale’s **type** and **domain**, and for position scales, the
plot’s dimensions. For continuous data (numbers and dates), and for
ordinal position scales (*point* and *band*), it is typically [*min*,
*max*]; it can be [*max*, *min*] to reverse the scale.

### yInsetTop

Insets the top edge by the specified number of pixels. A positive value
insets towards the bottom edge (reducing effective area), while a negative
value insets away from the bottom edge (increasing it).

### yInsetBottom

Insets the bottom edge by the specified number of pixels. A positive value
insets towards the top edge (reducing effective area), while a negative
value insets away from the top edge (increasing it).

### yAxis

The side of the frame on which to place the implicit axis: *left* or
*right* for *y*. Defaults to *left* for a *y* scale.

If *both*, an implicit axis will be rendered on both sides of the plot
(*left* and *right* for *y*). If null, the implicit axis is suppressed.

### yTickPadding

The distance between an axis tick mark and its associated text label (in
pixels); often defaults to 3, but may be affected by **yTickSize** and
**yTickRotate**.

### yReverse

Whether to reverse the scale’s encoding; equivalent to reversing either the
**domain** or **range**. Note that by default, when the *y* scale is
continuous, the *max* value points to the top of the screen, whereas
ordinal values are ranked from top to bottom.

### xyDomain

Set the *x* and *y* scale domains.

**`xRange`:** **Known limitation**: Fixed is admitted and serializes for ranges, but the renderer only implements Fixed domain inference. Use an explicit range array.

**`yRange`:** **Known limitation**: Fixed is admitted and serializes for ranges, but the renderer only implements Fixed domain inference. Use an explicit range array.

**`xScale`:** **Known limitation**: Null is admitted and serializes, but scale creation rejects it with unknown scale type: null.

**`yScale`:** **Known limitation**: Null is admitted and serializes, but scale creation rejects it with unknown scale type: null.

**`xLabelAnchor`:** **Known limitation**: The renderer accepts left/right/center for horizontal label anchors and top/bottom/center for vertical label anchors.

**`yLabelAnchor`:** **Known limitation**: The renderer accepts left/right/center for horizontal label anchors and top/bottom/center for vertical label anchors.

**`xTickFormat`, `yTickFormat`:** JavaScript formatter functions are native execution adapters beyond the string/null/reference wire contract.

**`xGrid`, `yGrid`:** Native JavaScript and Python authoring can retain null, and JavaScript can execute numeric interval counts. The current wire Interval default is a string, so those native variants are not presented as JSON/YAML starters.

### Cartesian examples

`xDomain-parameter`: [json](/templates/attributes/cartesian/xDomain-parameter.json) · [yaml](/templates/attributes/cartesian/xDomain-parameter.yaml) · [js](/templates/attributes/cartesian/xDomain-parameter.js) · <a :href="withBase('/templates/attributes/cartesian/xDomain-parameter.py')" download>Python</a>.


## color attribute reference

### colorScale

The *color* scale type, affecting how the scale encodes abstract data, say by applying a mathematical transformation. If null, the scale is disabled.

For quantitative data (numbers), defaults to *linear*; for temporal data (dates), defaults to *utc*; for ordinal data (strings or booleans), defaults to *point* for position scales, *categorical* for color scales, and otherwise *ordinal*.

### colorDomain

The extent of the scale’s inputs (abstract values). By default inferred from channel values. For continuous data (numbers and dates), it is typically [*min*, *max*]; it can be [*max*, *min*] to reverse the scale. For ordinal data (strings or booleans), it is an array (or iterable) of values is the desired order, defaulting to natural ascending order.

### colorRange

The extent of the scale’s outputs (visual values). By default inferred from the scale’s **type** and **domain**. For other ordinal data, it is an array (or iterable) of output values in the same order as the **domain**.

### colorClamp

<span id="opacityclamp"></span>
Applies to `colorClamp`, `opacityClamp`.

If true, values below the domain minimum are treated as the domain minimum, and values above the domain maximum are treated as the domain maximum.

Clamping is useful for focusing on a subset of the data while ensuring that extreme values remain visible, but use caution: clamped values may need an annotation to avoid misinterpretation. Clamping typically requires setting an explicit **domain** since if the domain is inferred, no values will be outside the domain.

For continuous scales only.

### colorN

For a *quantile* scale, the number of quantiles (creates *n* - 1 thresholds); for a *quantize* scale, the approximate number of thresholds; defaults to 5.

### colorNice

<span id="opacitynice"></span>
Applies to `colorNice`, `opacityNice`.

If true, or a tick count or interval, extend the domain to nice round values. Defaults to 1, 2 or 5 times a power of 10 for *linear* scales, and nice time intervals for *utc* and *time* scales. Pass an interval such as
*minute*, *wednesday* or *month* to specify what constitutes a nice interval.

For continuous scales only.

### colorScheme

If specified, shorthand for setting the **colorRange** or **colorInterpolate** option of a *color* scale.

### colorInterpolate

How to interpolate color range values. For quantitative scales only. This attribute can be used to specify a color space for interpolating colors specified in the **colorRange**.

### colorPivot

For a diverging color scale, the input value (abstract value) that divides the domain into two parts; defaults to 0 for *diverging* scales, dividing the domain into negative and positive parts; defaults to 1 for
*diverging-log* scales. By default, diverging scales are symmetric around the pivot; see the **symmetric** option.

### colorSymmetric

For a diverging color scale, if true (the default), extend the domain to ensure that the lower part of the domain (below the **pivot**) is commensurate with the upper part of the domain (above the **pivot**).

A symmetric diverging color scale may not use all of its output **range**; this reduces contrast but ensures that deviations both below and above the
**pivot** are represented proportionally. Otherwise if false, the full output **range** will be used; this increases contrast but values on opposite sides of the **pivot** may not be meaningfully compared.

### colorLabel

<span id="opacitylabel"></span>
Applies to `colorLabel`, `opacityLabel`.

A textual label to show on the axis or legend; if null, show no label. By default the scale label is inferred from channel definitions, possibly with an arrow (↑, →, ↓, or ←) to indicate the direction of increasing value.

For axes and legends only.

### colorPercent

<span id="opacitypercent"></span>
Applies to `colorPercent`, `opacityPercent`.

If true, shorthand for a transform suitable for percentages, mapping proportions in [0, 1] to [0, 100].

### colorReverse

<span id="opacityreverse"></span>
Applies to `colorReverse`, `opacityReverse`.

Whether to reverse the scale’s encoding; equivalent to reversing either the
**domain** or **range**.

### colorZero

<span id="opacityzero"></span>
Applies to `colorZero`, `opacityZero`.

Whether the **domain** must include zero. If the domain minimum is positive, it will be set to zero; otherwise if the domain maximum is negative, it will be set to zero.

For quantitative scales only.

### colorTickFormat

<span id="opacitytickformat"></span>
Applies to `colorTickFormat`, `opacityTickFormat`.

How to format inputs (abstract values) for axis tick labels; one of:

- a [d3-format](https://d3js.org/d3-time) string for numeric scales
- a [d3-time-format](https://d3js.org/d3-time-format) string for temporal scales

### colorExponent

A power scale’s exponent (*e.g.*, 0.5 for sqrt); defaults to 1 for a linear scale. For *pow* and *diverging-pow* scales only.

### colorBase

A log scale’s base; defaults to 10. Does not affect the scale’s encoding, but rather the default ticks. For *log* and *diverging-log* scales only.

### colorConstant

A symlog scale’s constant, expressing the magnitude of the linear region around the origin; defaults to 1. For *symlog* and *diverging-symlog* scales only.

### opacityScale

The *opacity* scale type, affecting how the scale encodes abstract data, say by applying a mathematical transformation. If null, the scale is disabled. The opacity scale defaults to *linear*; this scales is intended for quantitative data.

### opacityDomain

The extent of the scale’s inputs (abstract values). By default inferred from channel values. For continuous data (numbers and dates), it is typically [*min*, *max*]; it can be [*max*, *min*] to reverse the scale. For ordinal data (strings or booleans), it is an array (or iterable) of values is the desired order, defaulting to natural ascending order.

Opacity scales have a default domain from 0 to the maximum value of associated channels.

### opacityRange

The extent of the scale’s outputs (visual values).

Opacity scales have a default range of [0, 1].

### opacityExponent

A power scale’s exponent (*e.g.*, 0.5 for sqrt); defaults to 1 for a linear scale. For *pow* scales only.

### opacityBase

A log scale’s base; defaults to 10. Does not affect the scale’s encoding, but rather the default ticks. For *log* scales only.

### opacityConstant

A symlog scale’s constant, expressing the magnitude of the linear region around the origin; defaults to 1. For *symlog* scales only.

### symbolScale

The *symbol* scale type, affecting how the scale encodes abstract data, say by applying a mathematical transformation. If null, the scale is disabled. Defaults to an *ordinal* scale type.

### symbolDomain

The extent of the scale’s inputs (abstract values). By default inferred from channel values. As symbol scales are discrete, the domain is an array (or iterable) of values is the desired order, defaulting to natural ascending order.

### symbolRange

The extent of the scale’s outputs (visual values). By default inferred from the scale’s **type** and **domain**, and for position scales, the plot’s dimensions. For continuous data (numbers and dates), and for ordinal position scales (*point* and *band*), it is typically [*min*, *max*]; it can be [*max*, *min*] to reverse the scale. For other ordinal data, such as for a *color* scale, it is an array (or iterable) of output values in the same order as the **domain**.

Symbol scales have a default range of categorical symbols; the choice of symbols depends on whether the associated dot mark is filled or stroked.

**`colorScale`, `opacityScale`, `symbolScale`:** Compatibility limitation: null is accepted by the specification, but rendering a matching data channel currently throws `unknown scale type: null`. The null-scale examples preserve this expected rejection.

**`colorRange`, `opacityRange`, `symbolRange`:** Compatibility limitation: `Fixed` is accepted by the specification for this range, but the retained renderer throws an unsupported fixed attribute error. Fixed domains remain supported.

**`colorScheme`:** Compatibility limitation: the wire contract accepts open objects and parameter-reference strings; quantitative rendering rejects scheme objects and unknown scheme strings. Known scheme strings are normalized without case sensitivity.

**`colorInterpolate`:** JavaScript additionally accepts a native one-argument sequential interpolator such as D3 `interpolateBlues`; install `d3` to run the native examples. Functions have no JSON, YAML or Python wire representation.

**`colorInterpolate`:** JavaScript additionally accepts a two-argument D3 interpolation factory such as `interpolateRgb.gamma(2.2)` together with explicit color range endpoints; install `d3` for this native example.

**`colorRange`:** For an ordinal color scale, a native JavaScript range callback receives the scale domain and returns the output colors. This callback is a JavaScript-only runtime value.

**`symbolRange`:** JavaScript additionally accepts native D3 symbol objects such as `symbolStar` in a symbol range; install `d3` for the native example. Shared templates use symbol names.

### Color examples

`colorScheme`: [json](/templates/attributes/color/colorScheme.json) · [yaml](/templates/attributes/color/colorScheme.yaml) · [js](/templates/attributes/color/colorScheme.js) · <a :href="withBase('/templates/attributes/color/colorScheme.py')" download>Python</a>.


## facet attribute reference

### facetMargin

Shorthand to set the same default for all four facet margins: marginTop, marginRight, marginBottom, and marginLeft.

### facetMarginTop

The top facet margin; the (minimum) distance in pixels between the top edges of the inner and outer plot area.

### facetMarginBottom

The bottom facet margin; the (minimum) distance in pixels between the bottom edges of the inner and outer plot area.

### facetMarginLeft

The left facet margin; the (minimum) distance in pixels between the left edges of the inner and outer plot area.

### facetMarginRight

The right facet margin; the (minimum) distance in pixels between the right edges of the inner and outer plot area.

### facetGrid

Default axis grid for fx and fy scales; typically set to true to enable.

### facetLabel

Default axis label for fx and fy scales; typically set to null to disable.

### fxDomain

<span id="fydomain"></span>
Applies to `fxDomain`, `fyDomain`.

The extent of the scale’s inputs (abstract values). By default inferred from channel values. For ordinal data (strings or booleans), it is an array (or iterable) of values is the desired order, defaulting to natural ascending order.

### fxRange

<span id="fyrange"></span>
Applies to `fxRange`, `fyRange`.

The extent of the scale’s outputs (visual values). By default inferred from the scale’s **type** and **domain**, and the plot’s dimensions. For ordinal position scales (*point* and *band*), it is typically [*min*, *max*]; it can be [*max*, *min*] to reverse the scale.

### fxInset

<span id="fyinset"></span>
Applies to `fxInset`, `fyInset`.

Shorthand to set the same default for all four insets: **insetTop**,
**insetRight**, **insetBottom**, and **insetLeft**. All insets typically default to zero, though not always (say when using bin transform). A positive inset reduces effective area, while a negative inset increases it.

### fxInsetRight

Insets the right edge by the specified number of pixels. A positive value insets towards the left edge (reducing effective area), while a negative value insets away from the left edge (increasing it).

### fxInsetLeft

Insets the left edge by the specified number of pixels. A positive value insets towards the right edge (reducing effective area), while a negative value insets away from the right edge (increasing it).

### fxRound

<span id="fyround"></span>
Applies to `fxRound`, `fyRound`.

If true, round the output value to the nearest integer (pixel); useful for crisp edges when rendering.

For position scales only.

### fxAlign

<span id="fyalign"></span>
Applies to `fxAlign`, `fyAlign`.

How to distribute unused space in the **range** for *point* and *band* scales. A number in [0, 1], such as:

- 0 - use the start of the range, putting unused space at the end
- 0.5 (default) - use the middle, distributing unused space evenly
- 1 use the end, putting unused space at the start

For ordinal position scales only.

### fxPadding

<span id="fypadding"></span>
Applies to `fxPadding`, `fyPadding`.

For *band* scales, how much of the **range** to reserve to separate adjacent bands; defaults to 0.1 (10%). For *point* scales, the amount of inset for the first and last value as a proportion of the bandwidth; defaults to 0.5 (50%).

For ordinal position scales only.

### fxPaddingInner

<span id="fypaddinginner"></span>
Applies to `fxPaddingInner`, `fyPaddingInner`.

For a *band* scale, how much of the range to reserve to separate adjacent bands.

### fxPaddingOuter

<span id="fypaddingouter"></span>
Applies to `fxPaddingOuter`, `fyPaddingOuter`.

For a *band* scale, how much of the range to reserve to inset first and last bands.

### fxAxis

The side of the frame on which to place the implicit axis: *top* or
*bottom* for *fx*. Defaults to *top* if there is a *bottom* *x* axis, and otherwise *bottom*.

If *both*, an implicit axis will be rendered on both sides of the plot (*top* and *bottom* for *fx*). If null, the implicit axis is suppressed.

### fxTicks

<span id="fyticks"></span>
Applies to `fxTicks`, `fyTicks`.

The desired approximate number of axis ticks, or an explicit array of tick values, or an interval such as *day* or *month*.

### fxTickSize

<span id="fyticksize"></span>
Applies to `fxTickSize`, `fyTickSize`.

The length of axis tick marks in pixels; negative values extend in the opposite direction. Defaults to 6 for *x* and *y* axes and *color* and
*opacity* *ramp* legends, and 0 for *fx* and *fy* axes.

### fxTickSpacing

<span id="fytickspacing"></span>
Applies to `fxTickSpacing`, `fyTickSpacing`.

The desired approximate spacing between adjacent axis ticks, affecting the default **ticks**; defaults to 80 pixels for *x* and *fx*, and 35 pixels for *y* and *fy*.

### fxTickPadding

The distance between an axis tick mark and its associated text label (in pixels); often defaults to 3, but may be affected by **fxTickSize** and
**fxTickRotate**.

### fxTickFormat

<span id="fytickformat"></span>
Applies to `fxTickFormat`, `fyTickFormat`.

How to format inputs (abstract values) for axis tick labels; one of:

- a [d3-format](https://d3js.org/d3-time) string for numeric scales
- a [d3-time-format](https://d3js.org/d3-time-format) string for temporal scales

### fxTickRotate

<span id="fytickrotate"></span>
Applies to `fxTickRotate`, `fyTickRotate`.

The rotation angle of axis tick labels in degrees clocksize; defaults to 0.

### fxGrid

<span id="fygrid"></span>
Applies to `fxGrid`, `fyGrid`.

Whether to show a grid aligned with the scale’s ticks. If true, show a grid with the currentColor stroke; if a string, show a grid with the specified stroke color; if an approximate number of ticks, an interval, or an array of tick values, show corresponding grid lines. See also the grid mark.

For axes only.

### fxLine

<span id="fyline"></span>
Applies to `fxLine`, `fyLine`.

If true, draw a line along the axis; if false (default), do not.

### fxLabel

<span id="fylabel"></span>
Applies to `fxLabel`, `fyLabel`.

A textual label to show on the axis or legend; if null, show no label. By default the scale label is inferred from channel definitions, possibly with an arrow (↑, →, ↓, or ←) to indicate the direction of increasing value.

For axes and legends only.

### fxLabelAnchor

<span id="fylabelanchor"></span>
Applies to `fxLabelAnchor`, `fyLabelAnchor`.

Where to place the axis **label** relative to the plot’s frame. For vertical position scales (*y* and *fy*), may be *top*, *bottom*, or
*center*; for horizontal position scales (*x* and *fx*), may be *left*,
*right*, or *center*. Defaults to *center* for ordinal scales (including
*fx* and *fy*), and otherwise *top* for *y*, and *right* for *x*.

### fxLabelOffset

<span id="fylabeloffset"></span>
Applies to `fxLabelOffset`, `fyLabelOffset`.

The axis **label** position offset (in pixels); default depends on margins and orientation.

### fxFontVariant

<span id="fyfontvariant"></span>
Applies to `fxFontVariant`, `fyFontVariant`.

The font-variant attribute for axis ticks; defaults to *tabular-nums* for quantitative axes.

### fxAriaLabel

<span id="fyarialabel"></span>
Applies to `fxAriaLabel`, `fyAriaLabel`.

A short label representing the axis in the accessibility tree.

### fxAriaDescription

<span id="fyariadescription"></span>
Applies to `fxAriaDescription`, `fyAriaDescription`.

A textual description for the axis in the accessibility tree.

### fxReverse

<span id="fyreverse"></span>
Applies to `fxReverse`, `fyReverse`.

Whether to reverse the scale’s encoding; equivalent to reversing either the
**domain** or **range**.

### fyInsetTop

Insets the top edge by the specified number of pixels. A positive value insets towards the bottom edge (reducing effective area), while a negative value insets away from the bottom edge (increasing it).

### fyInsetBottom

Insets the bottom edge by the specified number of pixels. A positive value insets towards the top edge (reducing effective area), while a negative value insets away from the top edge (increasing it).

### fyAxis

The side of the frame on which to place the implicit axis: *left* or
*right* for *fy*. Defaults to *left* for an *fy* scale.

If *both*, an implicit axis will be rendered on both sides of the plot (*left* and *right* for *fy*). If null, the implicit axis is suppressed.

### fyTickPadding

The distance between an axis tick mark and its associated text label (in pixels); often defaults to 3, but may be affected by **fyTickSize** and
**fyTickRotate**.

**`fxTickFormat`, `fyTickFormat`:** JavaScript formatter callbacks are native execution adapters beyond the string/null/reference wire contract.

**`fxRange`:** **Known limitation**: Fixed is admitted and serializes for facet ranges, but the renderer only implements Fixed domain inference. Use an explicit range array.

**`fyRange`:** **Known limitation**: Fixed is admitted and serializes for facet ranges, but the renderer only implements Fixed domain inference. Use an explicit range array.

**`fxLabelAnchor`:** **Known limitation**: The renderer accepts left/right/center for horizontal facet label anchors and top/bottom/center for vertical facet label anchors.

**`fyLabelAnchor`:** **Known limitation**: The renderer accepts left/right/center for horizontal facet label anchors and top/bottom/center for vertical facet label anchors.

**`fyInset`:** **Known limitation**: The retained route is spelled fy,inset with a comma, so this directive does not change the facet scale range. Use fyInsetTop or fyInsetBottom.

### Facet examples

`fxDomain`: [json](/templates/attributes/facet/fxDomain.json) · [yaml](/templates/attributes/facet/fxDomain.yaml) · [js](/templates/attributes/facet/fxDomain.js) · <a :href="withBase('/templates/attributes/facet/fxDomain.py')" download>Python</a>.


## Plot attribute reference

### name

A unique name for the plot. The name is used by standalone legend
components to to lookup the plot and access scale mappings.

Names are registered in the calling API context, or in the default named-plot registry when no local context is supplied. Naming preserves the original plot identity.

### width

The outer width of the plot in pixels, including margins. Defaults to 640.
On Observable, this can be set to the built-in [width](https://github.com/observablehq/stdlib/blob/main/README.md#width) for full-width
responsive plots. Note: the default style has a max-width of 100%; the plot
will automatically shrink to fit even when a fixed width is specified.

### height

The outer height of the plot in pixels, including margins. The default
depends on the plot’s scales, and the plot’s width if an aspectRatio is
specified. For example, if the *y* scale is linear and there is no *fy*
scale, it might be 396.

### aspectRatio

The desired aspect ratio of the *x* and *y* scales, affecting the default
height. Given an aspect ratio of *dx* / *dy*, and assuming that the *x* and
*y* scales represent equivalent units (say, degrees Celsius or meters),
computes a default height such that *dx* pixels along *x* represents the
same variation as *dy* pixels along *y*. Note: when faceting, set the *fx*
and *fy* scales’ **round** option to false for an exact aspect ratio.

### margin

Shorthand to set the same default for all four margins: **marginTop**,
**marginRight**, **marginBottom**, and **marginLeft**. Otherwise, the
default margins depend on the maximum margins of the plot’s marks. While
most marks default to zero margins (because they are drawn inside the chart
area), Plot’s axis marks have non-zero default margins.

### marginTop

The top margin; the distance in pixels between the top edges of the inner
and outer plot area. Defaults to the maximum top margin of the plot’s
marks.

### marginRight

The right margin; the distance in pixels between the right edges of the
inner and outer plot area. Defaults to the maximum right margin of the
plot’s marks.

### marginBottom

The bottom margin; the distance in pixels between the bottom edges of the
inner and outer plot area. Defaults to the maximum bottom margin of the
plot’s marks.

### marginLeft

The left margin; the distance in pixels between the left edges of the inner
and outer plot area. Defaults to the maximum left margin of the plot’s
marks.

### margins

A shorthand object notation for setting multiple margin values.
The object keys are margin names (top, right, etc).

Python uses `vg.margins(top=None, right=None, bottom=None, left=None, **kwargs)`, with each margin passed separately. `None` entries are omitted, falsy values are retained, and extra keyword entries are preserved. JavaScript uses a single object and sets only its defined sides.

### inset

Shorthand to set the same default for all four insets: **insetTop**,
**insetRight**, **insetBottom**, and **insetLeft**. All insets typically
default to zero, though not always (say when using bin transform). A
positive inset reduces effective area, while a negative inset increases it.

### style

Custom styles to override Plot’s defaults. Styles may be specified either
as a string of inline styles (*e.g.*, `"color: red;"`, in the same fashion
as assigning [*element*.style](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/style)) or an object of properties (*e.g.*,
`{color: "red"}`, in the same fashion as assigning [*element*.style
properties](https://developer.mozilla.org/en-US/docs/Web/API/CSSStyleDeclaration)). Note that unitless numbers ([quirky lengths](https://www.w3.org/TR/css-values-4/#deprecated-quirky-length)) such as
`{padding: 20}` may not supported by some browsers; you should instead
specify a string with units such as `{padding: "20px"}`. By default, the
returned plot has a max-width of 100%, and the system-ui font. Plot’s marks
and axes default to [currentColor](https://developer.mozilla.org/en-US/docs/Web/CSS/color_value#currentcolor_keyword), meaning that they will inherit the
surrounding content’s color.

### align

How to distribute unused space in the **range** for *point* and *band*
scales. A number in [0, 1], such as:

- 0 - use the start of the range, putting unused space at the end
- 0.5 (default) - use the middle, distributing unused space evenly
- 1 use the end, putting unused space at the start

For ordinal position scales only.

### padding

For *band* scales, how much of the **range** to reserve to separate
adjacent bands; defaults to 0.1 (10%). For *point* scales, the amount of
inset for the first and last value as a proportion of the bandwidth;
defaults to 0.5 (50%).

For ordinal position scales only.

### axis

The side of the frame on which to place the implicit axis: *top* or
*bottom* for *x* or *fx*, or *left* or *right* for *y* or *fy*. The default
depends on the scale:

- *x* - *bottom*
- *y* - *left*
- *fx* - *top* if there is a *bottom* *x* axis, and otherwise *bottom*
- *fy* - *right* if there is a *left* *y* axis, and otherwise *right*

If *both*, an implicit axis will be rendered on both sides of the plot
(*top* and *bottom* for *x* or *fx*, or *left* and *right* for *y* or
*fy*). If null, the implicit axis is suppressed.

For position axes only.

### grid

Whether to show a grid aligned with the scale’s ticks. If true, show a grid
with the currentColor stroke; if a string, show a grid with the specified
stroke color; if an approximate number of ticks, an interval, or an array
of tick values, show corresponding grid lines. See also the grid mark.

For axes only.

### ariaLabel

The [aria-label attribute](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Attributes/aria-label) on the SVG root.

**Known limitation**: This attribute is admitted by the declarative schema and serializes in Python, but the JavaScript renderer has no route for it. Rendering rejects with the error below. Error: `Unrecognized plot attribute: ariaLabel`.

### ariaDescription

The [aria-description attribute](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Attributes/aria-description) on the SVG root.

**Known limitation**: This attribute is admitted by the declarative schema and serializes in Python, but the JavaScript renderer has no route for it. Rendering rejects with the error below. Error: `Unrecognized plot attribute: ariaDescription`.

### clip

The default clip for all marks.

**Known limitation**: This attribute is admitted by the declarative schema and serializes in Python, but the JavaScript renderer has no route for it. Rendering rejects with the error below. Error: `Unrecognized plot attribute: clip`.

### Plot attribute examples

`margins`: [JSON](/templates/attributes/plot/margins.json) · [YAML](/templates/attributes/plot/margins.yaml) · [JavaScript](/templates/attributes/plot/margins.js) · <a :href="withBase('/templates/attributes/plot/margins.py')" download>Python</a>.


## projection attribute reference

### projectionType

The desired projection; one of:

- a named built-in projection such as *albers-usa*
- null, for no projection

Named projections are scaled and translated to fit
the **domain** to the plot’s frame (minus insets).

### projectionDomain

A GeoJSON object to fit to the plot’s frame (minus insets); defaults to a
Sphere for spherical projections (outline of the the whole globe).

### projectionRotate

A rotation of the sphere before projection; defaults to [0, 0, 0].
Specified as Euler angles λ (yaw, or reference longitude), φ (pitch, or
reference latitude), and optionally γ (roll), in degrees.

### projectionParallels

The [standard parallels](https://d3js.org/d3-geo/conic#conic_parallels). For conic projections only.

### projectionPrecision

The projection’s [sampling threshold](https://d3js.org/d3-geo/projection#projection_precision).

### projectionClip

The projection’s clipping method; one of:

- *frame* or true (default) - clip to the plot’s frame (including margins but not insets)
- a number - clip to a circle of the given radius in degrees centered around the origin
- null or false - do not clip

Some projections (such as [*armadillo*](https://observablehq.com/@d3/armadillo) and [*berghaus*](https://observablehq.com/@d3/berghaus-star)) require
spherical clipping: in that case set the marks’ **clip** option to
*sphere*.

### projectionInset

Shorthand to set the same default for all four projection insets.
All insets typically default to zero, though not always. A positive
inset reduces effective area, while a negative inset increases it.

### projectionInsetTop

Insets the top edge of the projection by the specified number of pixels.
A positive value insets towards the bottom edge (reducing effective area),
while a negative value insets away from the bottom edge (increasing it).

### projectionInsetRight

Insets the right edge of the projection by the specified number of pixels.
A positive value insets towards the left edge (reducing effective area),
while a negative value insets away from the left edge (increasing it).

### projectionInsetBottom

Insets the bottom edge of the projection by the specified number of pixels.
A positive value insets towards the top edge (reducing effective area),
while a negative value insets away from the top edge (increasing it).

### projectionInsetLeft

Insets the left edge of the projection by the specified number of pixels.
A positive value insets towards the right edge (reducing effective area),
while a negative value insets away from the right edge (increasing it).

**`projectionType`:** Native JavaScript initializer functions may return a D3 projection; they receive the available inner frame dimensions and routed projection options. A direct D3 projection passed through this attribute fails with projection.stream is not a function, and a plain projection object fails with unknown projection type: [object Object]. These forms are outside the declared name union. Install d3 alongside @uwdata/vgplot for the examples that import geoMercator.

**`projectionRotate`:** TypeScript and native JavaScript permit a two-angle rotation, but the existing wire schema requires exactly three items. Use three angles in declarative specifications.

**`projectionClip`:** Python defaults to True; JavaScript omitted values remain undefined. False and null disable clipping, while a number requests angular clipping in degrees.

### Projection examples

`projectionType`: [json](/templates/attributes/projection/projectionType.json) · [yaml](/templates/attributes/projection/projectionType.yaml) · [js](/templates/attributes/projection/projectionType.js) · <a :href="withBase('/templates/attributes/projection/projectionType.py')" download>Python</a>.

JavaScript-only [`native-initializer`](/templates/attributes/projection/native-initializer.js).


## size attribute reference

### rScale

The *r* (radius) scale type, affecting how the scale encodes abstract
data, say by applying a mathematical transformation. If null, the scale
is disabled. The radius scale defaults to *sqrt*; this scale is intended
for quantitative data.

### rDomain

The extent of the scale’s inputs (abstract values). By default inferred
from channel values. For continuous data (numbers and dates), it is
typically [*min*, *max*]; it can be [*max*, *min*] to reverse the scale.
For ordinal data (strings or booleans), it is an array (or iterable) of
values is the desired order, defaulting to natural ascending order.

Radius scales have a default domain from 0 to the median first quartile
of associated channels.

### rRange

The extent of the scale’s outputs (visual values). By default inferred from
the scale’s **type** and **domain**, and for position scales, the plot’s
dimensions. For continuous data (numbers and dates), and for ordinal
position scales (*point* and *band*), it is typically [*min*, *max*]; it
can be [*max*, *min*] to reverse the scale. For other ordinal data, such as
for a *color* scale, it is an array (or iterable) of output values in the
same order as the **domain**.

Radius scales have a default range of [0, 3].

### rClamp

<span id="lengthclamp"></span>
Applies to `rClamp`, `lengthClamp`.

If true, values below the domain minimum are treated as the domain minimum,
and values above the domain maximum are treated as the domain maximum.

Clamping is useful for focusing on a subset of the data while ensuring that
extreme values remain visible, but use caution: clamped values may need an
annotation to avoid misinterpretation. Clamping typically requires setting
an explicit **domain** since if the domain is inferred, no values will be
outside the domain.

For continuous scales only.

### rNice

<span id="lengthnice"></span>
Applies to `rNice`, `lengthNice`.

If true, or a tick count or interval, extend the domain to nice round
values. Defaults to 1, 2 or 5 times a power of 10 for *linear* scales, and
nice time intervals for *utc* and *time* scales. Pass an interval such as
*minute*, *wednesday* or *month* to specify what constitutes a nice
interval.

For continuous scales only.

### rLabel

A textual label to show on the axis or legend; if null, show no label. By
default the scale label is inferred from channel definitions, possibly with
an arrow (↑, →, ↓, or ←) to indicate the direction of increasing value.

### rPercent

<span id="lengthpercent"></span>
Applies to `rPercent`, `lengthPercent`.

If true, shorthand for a transform suitable for percentages, mapping
proportions in [0, 1] to [0, 100].

### rZero

<span id="lengthzero"></span>
Applies to `rZero`, `lengthZero`.

Whether the **domain** must include zero. If the domain minimum is
positive, it will be set to zero; otherwise if the domain maximum is
negative, it will be set to zero.

For quantitative scales only.

### rExponent

<span id="lengthexponent"></span>
Applies to `rExponent`, `lengthExponent`.

A power scale’s exponent (*e.g.*, 0.5 for sqrt); defaults to 1 for a
linear scale. For *pow* scales only.

### rBase

<span id="lengthbase"></span>
Applies to `rBase`, `lengthBase`.

A log scale’s base; defaults to 10. Does not affect the scale’s encoding,
but rather the default ticks. For *log* scales only.

### rConstant

<span id="lengthconstant"></span>
Applies to `rConstant`, `lengthConstant`.

A symlog scale’s constant, expressing the magnitude of the linear region
around the origin; defaults to 1. For *symlog* scales only.

### lengthScale

The *length* scale type, affecting how the scale encodes abstract data,
say by applying a mathematical transformation. If null, the scale is
disabled. The length scale defaults to *linear*, as this scale is intended
for quantitative data.

### lengthDomain

The extent of the scale’s inputs (abstract values). By default inferred
from channel values. For continuous data (numbers and dates), it is
typically [*min*, *max*]; it can be [*max*, *min*] to reverse the scale.
For ordinal data (strings or booleans), it is an array (or iterable) of
values is the desired order, defaulting to natural ascending order.

Linear scales have a default domain of [0, 1]. Log scales have a default
domain of [1, 10] and cannot include zero. Radius scales have a default
domain from 0 to the median first quartile of associated channels. Length
have a default domain from 0 to the median median of associated channels.
Opacity scales have a default domain from 0 to the maximum value of
associated channels.

### lengthRange

The extent of the scale’s outputs (visual values). By default inferred from
the scale’s **type** and **domain**, and for position scales, the plot’s
dimensions. For continuous data (numbers and dates), and for ordinal
position scales (*point* and *band*), it is typically [*min*, *max*]; it
can be [*max*, *min*] to reverse the scale. For other ordinal data, such as
for a *color* scale, it is an array (or iterable) of output values in the
same order as the **domain**.

Length scales have a default range of [0, 12].

**`rClamp`, `lengthClamp`:** The declared value is unrestricted. Python requires an explicit argument; it does not infer a default from the clamp option's purpose.

**`rRange`:** **Known limitation**: Fixed is admitted and serializes, but only Fixed domain inference is implemented. Use an explicit range array. The JavaScript error is Unsupported fixed attribute: rRange.

**`lengthRange`:** **Known limitation**: Fixed is admitted and serializes, but only Fixed domain inference is implemented. Use an explicit range array. The JavaScript error is Unsupported fixed attribute: lengthRange.

**`rScale`:** **Known limitation**: Null is admitted and serializes, but scale creation rejects it. The JavaScript error is unknown scale type: null.

**`lengthScale`:** **Known limitation**: Null is admitted and serializes, but scale creation rejects it. The JavaScript error is unknown scale type: null.

**`rDomain`, `lengthDomain`:** Fixed domains are inferred from actual scale channels once and cached across later mark updates. Scalar radius/length constants bypass scale inference; field or array channels establish a scale.

### Size examples

`radius-range-parameter`: [json](/templates/attributes/size/radius-range-parameter.json) · [yaml](/templates/attributes/size/radius-range-parameter.yaml) · [js](/templates/attributes/size/radius-range-parameter.js) · <a :href="withBase('/templates/attributes/size/radius-range-parameter.py')" download>Python</a>.
