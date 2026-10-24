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

<template v-if="language === 'js'">

- `name(value)`: Set a globally unique name by which to refer to the plot.
- `style(value)`: Set CSS styles to apply to the plot output.
- `width(value)`: Set the plot width in pixels, including margins.
- `height(value)`: Set the plot height in pixels, including margins.
- `margin(value)`: Sets all margins to the same value in pixels.
- `marginLeft(value)`: Set the left plot margin in pixels.
- `marginRight(value)`: Set the right plot margin in pixels.
- `marginTop(value)`: Set the top plot margin in pixels.
- `marginBottom(value)`: Set the bottom plot margin in pixels.
- `margins(value)`: Set plot margins in pixels, using an object of the form `{left, right, top, bottom}`. Margins omitted from the object are not set.
- `align(value)`: Set the plot alignment.
- `aspectRatio(value)`: Set the plot aspect ratio.
- `inset(value)`: Set the plot insets in pixels.
- `axis(value)`: Set a global setting for including axes.
- `grid(value)`: Set a global setting for including grid lines.
- `label(value)`: Set a global setting for axis labels.
- `padding(value)`: Set the axis padding across all axes.
- `round(value)`: Set axis roundings across all axes.

## x Scale Attributes

- `xScale(value)`: Set the scale type, such as `"linear"`, `"log"`, etc.
- `xDomain(value)`: Set the scale domain.
- `xRange(value)`: Set the scale range.
- `xNice(value)`: Set if the scale domain should have "nice" (human-friendly) end points.
- `xInset(value)`: Set the scale insets in pixels.
- `xInsetLeft(value)`: Set the left inset in pixels.
- `xInsetRight(value)`: Set the right inset in pixels.
- `xClamp(value)`: Set if the scale should clamp out-of-domain values.
- `xRound(value)`: Set if the scale should round output values to the nearest pixel.
- `xAlign(value)`: Set the axis alignment: where to distribute points or bands (0 = at start, 0.5 = at middle, 1 = at end).
- `xPadding(value)`: Set the axis padding (for `band` or `point` scales).
- `xPaddingInner(value)`: Set the axis inner padding (for `band` or `point` scales).
- `xPaddingOuter(value)`: Set the axis outer padding (for `band` or `point` scales).
- `xAxis(value)`: Set the axis position (`"top"` or `"bottom"`) or hide the axis (`null`).
- `xTicks(value)`: Set the approximate number of ticks to generate, or interval, or array of values.
- `xTickSize(value)`: Set the axis tick size.
- `xTickSpacing(value)`: Set the approximate number of pixels between ticks (if xTicks is not specified).
- `xTickPadding(value)`: Set the axis tick padding.
- `xTickFormat(value)`: Set the axis tick format.
- `xTickRotate(value)`: Set the axis tick rotation.
- `xGrid(value)`: Set if the axis should include grid lines.
- `xLine(value)`: Set if the axis should include a line on the plot edge.
- `xLabel(value)`: Set the axis label.
- `xLabelAnchor(value)`: Set the axis label anchor (`"left"`, `"center"`, `"right"`).
- `xLabelOffset(value)`: Set the axis label offset in pixels.
- `xFontVariant(value)`: Set the axis label font variant.
- `xAriaLabel(value)`: Set the axis ARIA label for accessibility.
- `xAriaDescription(value)`: Set the axis ARIA description for accessibility.
- `xReverse(value)`: Set if the range should be reversed.
- `xZero(value)`: Set the domain to always include zero.

## y Scale Attributes

- `yScale(value)`: Set the scale type, such as `"linear"`, `"log"`, etc.
- `yDomain(value)`: Set the scale domain.
- `yRange(value)`: Set the scale range.
- `yNice(value)`: Set if the scale domain should have "nice" (human-friendly) end points.
- `yInset(value)`: Set the scale insets in pixels.
- `yInsetTop(value)`: Set the top inset in pixels.
- `yInsetBottom(value)`: Set the bottom inset in pixels.
- `yClamp(value)`: Set if the scale should clamp out-of-domain values.
- `yRound(value)`: Set if the scale should round output values to the nearest pixel.
- `yAlign(value)`: Set the axis alignment: where to distribute points or bands (0 = at start, 0.5 = at middle, 1 = at end).
- `yPadding(value)`: Set the axis padding (for `band` or `point` scales).
- `yPaddingInner(value)`: Set the axis inner padding (for `band` or `point` scales).
- `yPaddingOuter(value)`: Set the axis outer padding (for `band` or `point` scales).
- `yAxis(value)`: Set the axis position (`"left"` or `"right"`) or hide the axis (`null`).
- `yTicks(value)`: Set the approximate number of ticks to generate, or interval, or array of values.
- `yTickSize(value)`: Set the axis tick size.
- `yTickSpacing(value)`: Set the approximate number of pixels between ticks (if yTicks is not specified).
- `yTickPadding(value)`: Set the axis tick padding.
- `yTickFormat(value)`: Set the axis tick format.
- `yTickRotate(value)`: Set the axis tick rotation.
- `yGrid(value)`: Set if the axis should include grid lines.
- `yLine(value)`: Set if the axis should include a line on the plot edge.
- `yLabel(value)`: Set the axis label.
- `yLabelAnchor(value)`: Set the axis label anchor (`"top"`, `"middle"`, `"bottom"`).
- `yLabelOffset(value)`: Set the axis label offset in pixels.
- `yFontVariant(value)`: Set the axis label font variant.
- `yAriaLabel(value)`: Set the axis ARIA label for accessibility.
- `yAriaDescription(value)`: Set the axis ARIA description for accessibility.
- `yReverse(value)`: Set if the range should be reversed.
- `yZero(value)`: Set the domain to always include zero.

## color Scale Attributes

- `colorScale(value)`: Set the scale type, such as `"linear"`, `"log"`, etc.
- `colorDomain(value)`: Set the scale domain.
- `colorRange(value)`: Set the scale range.
- `colorClamp(value)`: Set if the scale should clamp out-of-domain values.
- `colorNice(value)`: Set if the scale domain should have "nice" (human-friendly) end points.
- `colorScheme(value)`: Set the named color scheme to use.
- `colorInterpolate(value)`: Set a custom color interpolation function.
- `colorPivot(value)`: Set the pivot value for diverging `color` scales.
- `colorSymmetric(value)`: Set the domain to be symmetric around a pivot.
- `colorLabel(value)`: Set the scale label.
- `colorReverse(value)`: Set if the range should be reversed.
- `colorZero(value)`: Set the domain to always include zero.
- `colorTickFormat(value)`: Set the legend tick format.

## opacity Scale Attributes

- `opacityScale(value)`: Set the scale type, such as `"linear"`, `"log"`, etc.
- `opacityDomain(value)`: Set the scale domain.
- `opacityRange(value)`: Set the scale range.
- `opacityClamp(value)`: Set if the scale should clamp out-of-domain values.
- `opacityNice(value)`: Set if the scale domain should have "nice" (human-friendly) end points.
- `opacityLabel(value)`: Set the scale label.
- `opacityReverse(value)`: Set if the range should be reversed.
- `opacityZero(value)`: Set the domain to always include zero.
- `opacityTickFormat(value)`: Set the legend tick format.

## r Scale Attributes

- `rScale(value)`: Set the scale type, such as `"linear"`, `"log"`, etc.
- `rDomain(value)`: Set the scale domain.
- `rRange(value)`: Set the scale range.
- `rClamp(value)`: Set if the scale should clamp out-of-domain values.
- `rNice(value)`: Set if the scale domain should have "nice" (human-friendly) end points.
- `rLabel(value)`: Set the scale label.
- `rZero(value)`: Set the domain to always include zero.

## length Scale Attributes

- `lengthScale(value)`: Set the scale type, such as `"linear"`, `"log"`, etc.
- `lengthDomain(value)`: Set the scale domain.
- `lengthRange(value)`: Set the scale range.
- `lengthClamp(value)`: Set if the scale should clamp out-of-domain values.
- `lengthNice(value)`: Set if the scale domain should have "nice" (human-friendly) end points.
- `lengthZero(value)`: Set the domain to always include zero.

## fx Scale Attributes

- `fxDomain(value)`: Set the scale domain.
- `fxRange(value)`: Set the scale range.
- `fxInset(value)`: Set the scale insets in pixels.
- `fxInsetLeft(value)`: Set the left inset in pixels.
- `fxInsetRight(value)`: Set the right inset in pixels.
- `fxRound(value)`: Set if the scale should round output values to the nearest pixel.
- `fxAlign(value)`: Set the axis alignment: where to distribute points or bands (0 = at start, 0.5 = at middle, 1 = at end).
- `fxPadding(value)`: Set the axis padding (for `band` or `point` scales).
- `fxPaddingInner(value)`: Set the axis inner padding (for `band` or `point` scales).
- `fxPaddingOuter(value)`: Set the axis outer padding (for `band` or `point` scales).
- `fxAxis(value)`: Set the axis position (`"top"` or `"bottom"`) or hide the axis (`null`).
- `fxTickSize(value)`: Set the axis tick size.
- `fxTickPadding(value)`: Set the axis tick padding.
- `fxTickFormat(value)`: Set the axis tick format.
- `fxTickRotate(value)`: Set the axis tick rotation.
- `fxGrid(value)`: Set if the axis should include grid lines.
- `fxLabel(value)`: Set the axis label.
- `fxLabelAnchor(value)`: Set the axis label anchor (`"left"`, `"center"`, `"right"`).
- `fxLabelOffset(value)`: Set the axis label offset in pixels.
- `fxFontVariant(value)`: Set the axis label font variant.
- `fxAriaLabel(value)`: Set the axis ARIA label for accessibility.
- `fxAriaDescription(value)`: Set the axis ARIA description for accessibility.
- `fxReverse(value)`: Set if the range should be reversed.

## fy Scale Attributes

- `fyDomain(value)`: Set the scale domain.
- `fyRange(value)`: Set the  scale range.
- `fyInset(value)`: Set the scale insets in pixels.
- `fyInsetTop(value)`: Set the top inset in pixels.
- `fyInsetBottom(value)`: Set the bottom inset in pixels.
- `fyRound(value)`: Set if the scale should round output values to the nearest pixel.
- `fyAlign(value)`: Set the axis alignment: where to distribute points or bands (0 = at start, 0.5 = at middle, 1 = at end).
- `fyPadding(value)`: Set the axis padding (for `band` or `point` scales).
- `fyPaddingInner(value)`: Set the axis inner padding (for `band` or `point` scales).
- `fyPaddingOuter(value)`: Set the axis outer padding (for `band` or `point` scales).
- `fyAxis(value)`: Set the axis position (`"top"` or `"bottom"`) or hide the axis (`null`).
- `fyTickSize(value)`: Set the axis tick size.
- `fyTickPadding(value)`: Set the axis tick padding.
- `fyTickFormat(value)`: Set the axis tick format.
- `fyTickRotate(value)`: Set the axis tick rotation.
- `fyGrid(value)`: Set if the axis should include grid lines.
- `fyLabel(value)`: Set the axis label.
- `fyLabelAnchor(value)`: Set the axis label anchor (`"left"`, `"center"`, `"right"`).
- `fyLabelOffset(value)`: Set the axis label offset in pixels.
- `fyFontVariant(value)`: Set the axis label font variant.
- `fyAriaLabel(value)`: Set the axis ARIA label for accessibility.
- `fyAriaDescription(value)`: Set the axis ARIA description for accessibility.
- `fyReverse(value)`: Set if the range should be reversed.

## Facet Attributes

- `facetMargin(value)`: Set all four facet margins.
- `facetMarginTop(value)`: Set the facet top margin.
- `facetMarginBottom(value)`: Set the facet bottom margin.
- `facetMarginLeft(value)`: Set the facet left margin.
- `facetMarginRight(value)`: Set the facet right margin.
- `facetGrid(value)`: Set if grid lines should be drawn for each facet.
- `facetLabel(value)`: If null, disable default facet axis labels.

## Projection Attributes

For more on projections, see the [Observable Plot projection documentation](https://observablehq.com/plot/features/projections).

- `projectionType(value)`: Set the projection type, such as `"mercator"`, `"orthographic"`.
- `projectionParallels(value)`: Set the [standard parallels](https://github.com/d3/d3-geo/blob/main/README.md#conic_parallels) (for conic projections only).
- `projectionPrecision(value)`: Set the [sampling threshold](https://github.com/d3/d3-geo/blob/main/README.md#projection_precision).
- `projectionRotate(value)`: Set a two- or three- element array of Euler angles to rotate the sphere.
- `projectionDomain(value)`: Set a GeoJSON object to fit in the center of the (inset) frame.
- `projectionInset(value)`: Set the inset to the given amount in pixels when fitting to the frame (default zero).
- `projectionInsetLeft(value)`: Set the inset from the left edge of the frame (defaults to `projectionInset`).
- `projectionInsetRight(value)`: Set the inset from the right edge of the frame (defaults to `projectionInset`).
- `projectionInsetTop(value)`: Set the inset from the top edge of the frame (defaults to `projectionInset`).
- `projectionInsetBottom(value)`: Set the inset from the bottom edge of the frame (defaults to `projectionInset`).
- `projectionClip(value)`: Set the projection clipping method. One of: `"frame"` or `true` (default) to clip to the extent of the frame (including margins but not insets), a number to clip to a great circle of the given radius in degrees centered around the origin, or `null` or `false` to disable clipping.

<div v-if="language === 'js'">

::: warning
Interval interactors are not currently supported when cartographic projections are used.
:::

</div>

</template>

<template v-else-if="language === 'python'">

- `name(value)`: Set a globally unique name by which to refer to the plot.
- `style(value)`: Set CSS styles to apply to the plot output.
- `width(value)`: Set the plot width in pixels, including margins.
- `height(value)`: Set the plot height in pixels, including margins.
- `margin(value)`: Sets all margins to the same value in pixels.
- `margin_left(value)`: Set the left plot margin in pixels.
- `margin_right(value)`: Set the right plot margin in pixels.
- `margin_top(value)`: Set the top plot margin in pixels.
- `margin_bottom(value)`: Set the bottom plot margin in pixels.
- `margins(value)`: Set plot margins in pixels, using an object of the form `{left, right, top, bottom}`. Margins omitted from the object are not set.
- `align(value)`: Set the plot alignment.
- `aspect_ratio(value)`: Set the plot aspect ratio.
- `inset(value)`: Set the plot insets in pixels.
- `axis(value)`: Set a global setting for including axes.
- `grid(value)`: Set a global setting for including grid lines.
- `label(value)`: Set a global setting for axis labels.
- `padding(value)`: Set the axis padding across all axes.
- `round(value)`: Set axis roundings across all axes.

## x Scale Attributes

- `x_scale(value)`: Set the scale type, such as `"linear"`, `"log"`, etc.
- `x_domain(value)`: Set the scale domain.
- `x_range(value)`: Set the scale range.
- `x_nice(value)`: Set if the scale domain should have "nice" (human-friendly) end points.
- `x_inset(value)`: Set the scale insets in pixels.
- `x_inset_left(value)`: Set the left inset in pixels.
- `x_inset_right(value)`: Set the right inset in pixels.
- `x_clamp(value)`: Set if the scale should clamp out-of-domain values.
- `x_round(value)`: Set if the scale should round output values to the nearest pixel.
- `x_align(value)`: Set the axis alignment: where to distribute points or bands (0 = at start, 0.5 = at middle, 1 = at end).
- `x_padding(value)`: Set the axis padding (for `band` or `point` scales).
- `x_padding_inner(value)`: Set the axis inner padding (for `band` or `point` scales).
- `x_padding_outer(value)`: Set the axis outer padding (for `band` or `point` scales).
- `x_axis(value)`: Set the axis position (`"top"` or `"bottom"`) or hide the axis (`null`).
- `x_ticks(value)`: Set the approximate number of ticks to generate, or interval, or array of values.
- `x_tick_size(value)`: Set the axis tick size.
- `x_tick_spacing(value)`: Set the approximate number of pixels between ticks (if `x_ticks` is not specified).
- `x_tick_padding(value)`: Set the axis tick padding.
- `x_tick_format(value)`: Set the axis tick format.
- `x_tick_rotate(value)`: Set the axis tick rotation.
- `x_grid(value)`: Set if the axis should include grid lines.
- `x_line(value)`: Set if the axis should include a line on the plot edge.
- `x_label(value)`: Set the axis label.
- `x_label_anchor(value)`: Set the axis label anchor (`"left"`, `"center"`, `"right"`).
- `x_label_offset(value)`: Set the axis label offset in pixels.
- `x_font_variant(value)`: Set the axis label font variant.
- `x_aria_label(value)`: Set the axis ARIA label for accessibility.
- `x_aria_description(value)`: Set the axis ARIA description for accessibility.
- `x_reverse(value)`: Set if the range should be reversed.
- `x_zero(value)`: Set the domain to always include zero.

## y Scale Attributes

- `y_scale(value)`: Set the scale type, such as `"linear"`, `"log"`, etc.
- `y_domain(value)`: Set the scale domain.
- `y_range(value)`: Set the scale range.
- `y_nice(value)`: Set if the scale domain should have "nice" (human-friendly) end points.
- `y_inset(value)`: Set the scale insets in pixels.
- `y_inset_top(value)`: Set the top inset in pixels.
- `y_inset_bottom(value)`: Set the bottom inset in pixels.
- `y_clamp(value)`: Set if the scale should clamp out-of-domain values.
- `y_round(value)`: Set if the scale should round output values to the nearest pixel.
- `y_align(value)`: Set the axis alignment: where to distribute points or bands (0 = at start, 0.5 = at middle, 1 = at end).
- `y_padding(value)`: Set the axis padding (for `band` or `point` scales).
- `y_padding_inner(value)`: Set the axis inner padding (for `band` or `point` scales).
- `y_padding_outer(value)`: Set the axis outer padding (for `band` or `point` scales).
- `y_axis(value)`: Set the axis position (`"left"` or `"right"`) or hide the axis (`null`).
- `y_ticks(value)`: Set the approximate number of ticks to generate, or interval, or array of values.
- `y_tick_size(value)`: Set the axis tick size.
- `y_tick_spacing(value)`: Set the approximate number of pixels between ticks (if `y_ticks` is not specified).
- `y_tick_padding(value)`: Set the axis tick padding.
- `y_tick_format(value)`: Set the axis tick format.
- `y_tick_rotate(value)`: Set the axis tick rotation.
- `y_grid(value)`: Set if the axis should include grid lines.
- `y_line(value)`: Set if the axis should include a line on the plot edge.
- `y_label(value)`: Set the axis label.
- `y_label_anchor(value)`: Set the axis label anchor (`"top"`, `"middle"`, `"bottom"`).
- `y_label_offset(value)`: Set the axis label offset in pixels.
- `y_font_variant(value)`: Set the axis label font variant.
- `y_aria_label(value)`: Set the axis ARIA label for accessibility.
- `y_aria_description(value)`: Set the axis ARIA description for accessibility.
- `y_reverse(value)`: Set if the range should be reversed.
- `y_zero(value)`: Set the domain to always include zero.

## color Scale Attributes

- `color_scale(value)`: Set the scale type, such as `"linear"`, `"log"`, etc.
- `color_domain(value)`: Set the scale domain.
- `color_range(value)`: Set the scale range.
- `color_clamp(value)`: Set if the scale should clamp out-of-domain values.
- `color_nice(value)`: Set if the scale domain should have "nice" (human-friendly) end points.
- `color_scheme(value)`: Set the named color scheme to use.
- `color_interpolate(value)`: Set a custom color interpolation function.
- `color_pivot(value)`: Set the pivot value for diverging `color` scales.
- `color_symmetric(value)`: Set the domain to be symmetric around a pivot.
- `color_label(value)`: Set the scale label.
- `color_reverse(value)`: Set if the range should be reversed.
- `color_zero(value)`: Set the domain to always include zero.
- `color_tick_format(value)`: Set the legend tick format.

## opacity Scale Attributes

- `opacity_scale(value)`: Set the scale type, such as `"linear"`, `"log"`, etc.
- `opacity_domain(value)`: Set the scale domain.
- `opacity_range(value)`: Set the scale range.
- `opacity_clamp(value)`: Set if the scale should clamp out-of-domain values.
- `opacity_nice(value)`: Set if the scale domain should have "nice" (human-friendly) end points.
- `opacity_label(value)`: Set the scale label.
- `opacity_reverse(value)`: Set if the range should be reversed.
- `opacity_zero(value)`: Set the domain to always include zero.
- `opacity_tick_format(value)`: Set the legend tick format.

## r Scale Attributes

- `r_scale(value)`: Set the scale type, such as `"linear"`, `"log"`, etc.
- `r_domain(value)`: Set the scale domain.
- `r_range(value)`: Set the scale range.
- `r_clamp(value)`: Set if the scale should clamp out-of-domain values.
- `r_nice(value)`: Set if the scale domain should have "nice" (human-friendly) end points.
- `r_label(value)`: Set the scale label.
- `r_zero(value)`: Set the domain to always include zero.

## length Scale Attributes

- `length_scale(value)`: Set the scale type, such as `"linear"`, `"log"`, etc.
- `length_domain(value)`: Set the scale domain.
- `length_range(value)`: Set the scale range.
- `length_clamp(value)`: Set if the scale should clamp out-of-domain values.
- `length_nice(value)`: Set if the scale domain should have "nice" (human-friendly) end points.
- `length_zero(value)`: Set the domain to always include zero.

## fx Scale Attributes

- `fx_domain(value)`: Set the scale domain.
- `fx_range(value)`: Set the scale range.
- `fx_inset(value)`: Set the scale insets in pixels.
- `fx_inset_left(value)`: Set the left inset in pixels.
- `fx_inset_right(value)`: Set the right inset in pixels.
- `fx_round(value)`: Set if the scale should round output values to the nearest pixel.
- `fx_align(value)`: Set the axis alignment: where to distribute points or bands (0 = at start, 0.5 = at middle, 1 = at end).
- `fx_padding(value)`: Set the axis padding (for `band` or `point` scales).
- `fx_padding_inner(value)`: Set the axis inner padding (for `band` or `point` scales).
- `fx_padding_outer(value)`: Set the axis outer padding (for `band` or `point` scales).
- `fx_axis(value)`: Set the axis position (`"top"` or `"bottom"`) or hide the axis (`null`).
- `fx_tick_size(value)`: Set the axis tick size.
- `fx_tick_padding(value)`: Set the axis tick padding.
- `fx_tick_format(value)`: Set the axis tick format.
- `fx_tick_rotate(value)`: Set the axis tick rotation.
- `fx_grid(value)`: Set if the axis should include grid lines.
- `fx_label(value)`: Set the axis label.
- `fx_label_anchor(value)`: Set the axis label anchor (`"left"`, `"center"`, `"right"`).
- `fx_label_offset(value)`: Set the axis label offset in pixels.
- `fx_font_variant(value)`: Set the axis label font variant.
- `fx_aria_label(value)`: Set the axis ARIA label for accessibility.
- `fx_aria_description(value)`: Set the axis ARIA description for accessibility.
- `fx_reverse(value)`: Set if the range should be reversed.

## fy Scale Attributes

- `fy_domain(value)`: Set the scale domain.
- `fy_range(value)`: Set the  scale range.
- `fy_inset(value)`: Set the scale insets in pixels.
- `fy_inset_top(value)`: Set the top inset in pixels.
- `fy_inset_bottom(value)`: Set the bottom inset in pixels.
- `fy_round(value)`: Set if the scale should round output values to the nearest pixel.
- `fy_align(value)`: Set the axis alignment: where to distribute points or bands (0 = at start, 0.5 = at middle, 1 = at end).
- `fy_padding(value)`: Set the axis padding (for `band` or `point` scales).
- `fy_padding_inner(value)`: Set the axis inner padding (for `band` or `point` scales).
- `fy_padding_outer(value)`: Set the axis outer padding (for `band` or `point` scales).
- `fy_axis(value)`: Set the axis position (`"top"` or `"bottom"`) or hide the axis (`null`).
- `fy_tick_size(value)`: Set the axis tick size.
- `fy_tick_padding(value)`: Set the axis tick padding.
- `fy_tick_format(value)`: Set the axis tick format.
- `fy_tick_rotate(value)`: Set the axis tick rotation.
- `fy_grid(value)`: Set if the axis should include grid lines.
- `fy_label(value)`: Set the axis label.
- `fy_label_anchor(value)`: Set the axis label anchor (`"left"`, `"center"`, `"right"`).
- `fy_label_offset(value)`: Set the axis label offset in pixels.
- `fy_font_variant(value)`: Set the axis label font variant.
- `fy_aria_label(value)`: Set the axis ARIA label for accessibility.
- `fy_aria_description(value)`: Set the axis ARIA description for accessibility.
- `fy_reverse(value)`: Set if the range should be reversed.

## Facet Attributes

- `facet_margin(value)`: Set all four facet margins.
- `facet_margin_top(value)`: Set the facet top margin.
- `facet_margin_bottom(value)`: Set the facet bottom margin.
- `facet_margin_left(value)`: Set the facet left margin.
- `facet_margin_right(value)`: Set the facet right margin.
- `facet_grid(value)`: Set if grid lines should be drawn for each facet.
- `facet_label(value)`: If null, disable default facet axis labels.

## Projection Attributes

For more on projections, see the [Observable Plot projection documentation](https://observablehq.com/plot/features/projections).

- `projection_type(value)`: Set the projection type, such as `"mercator"`, `"orthographic"`.
- `projection_parallels(value)`: Set the [standard parallels](https://github.com/d3/d3-geo/blob/main/README.md#conic_parallels) (for conic projections only).
- `projection_precision(value)`: Set the [sampling threshold](https://github.com/d3/d3-geo/blob/main/README.md#projection_precision).
- `projection_rotate(value)`: Set a two- or three- element array of Euler angles to rotate the sphere.
- `projection_domain(value)`: Set a GeoJSON object to fit in the center of the (inset) frame.
- `projection_inset(value)`: Set the inset to the given amount in pixels when fitting to the frame (default zero).
- `projection_inset_left(value)`: Set the inset from the left edge of the frame (defaults to `projection_inset`).
- `projection_inset_right(value)`: Set the inset from the right edge of the frame (defaults to `projection_inset`).
- `projection_inset_top(value)`: Set the inset from the top edge of the frame (defaults to `projection_inset`).
- `projection_inset_bottom(value)`: Set the inset from the bottom edge of the frame (defaults to `projection_inset`).
- `projection_clip(value)`: Set the projection clipping method. One of: `"frame"` or `true` (default) to clip to the extent of the frame (including margins but not insets), a number to clip to a great circle of the given radius in degrees centered around the origin, or `null` or `false` to disable clipping.

<div v-if="language === 'python'">

::: warning
Interval interactors are not currently supported when cartographic projections are used.
:::

</div>

</template>

<LangError v-else :language="language" />

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
