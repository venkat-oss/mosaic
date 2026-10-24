---
title: Marks
---
<script setup>
import { withBase } from 'vitepress';
  import { useLang } from '../../.vitepress/theme/useLang.js';
  const { language, setLanguage } = useLang();
</script>

<LangToggle :model-value="language" aria-label="Marks documentation language" @update:model-value="setLanguage" />

<template v-if="language === 'js'">

# Marks

Marks visualize data through named channels, including position, color, opacity, and size. The set of known channel names. The [common mark contracts](../spec/common-marks) describe channel values, shared options, and target-specific behavior.

Most mark functions accept a data source and an options object. Use `from(tableName)` for database data, or pass an array for inline data. Passing only an options object to an ordinary mark uses a single empty row; reference marks such as axes, grids, and frames can omit data.

```js
import * as vg from '@uwdata/vgplot';

vg.plot(vg.dot(vg.from('data'), {x: 'x', y: 'y'}));
```

Marks follow [Observable Plot](https://observablehq.com/plot/features/marks) semantics. Mark variants can imply different scale types; for example, `barY` uses an ordinal horizontal scale while `rectY` uses a continuous one.

[Examples and target-specific authoring](../spec/common-marks#examples).

## Area

### area

`area(data, options)`

An area mark. The area mark is rarely used directly; it is only needed when the baseline and topline have neither *x* nor *y* values in common. Use areaY for a horizontal orientation where the baseline and topline share *x* values, or areaX for a vertical orientation where the baseline and topline share *y* values.

[Options](#area-options).

### areaX

`areaX(data, options)`

A vertically-oriented area mark, where the baseline and topline share
**y** values, as in a time-series area chart where time goes up↑.

If neither **x1** nor **x2** is specified, an implicit stackX transform is applied and **x** defaults to the identity function, assuming that *data* = [*x₀*, *x₁*, *x₂*, …]. Otherwise, if only one of **x1** or **x2** is specified, the other defaults to **x**, which defaults to zero.

If an **interval** is specified, **y** values are binned accordingly, allowing zeroes for empty bins instead of interpolating across gaps. This is recommended to “regularize” sampled data; for example, if your data represents timestamped observations and you expect one observation per day, use *day* as the **interval**.

Variable aesthetic channels are supported: if the **fill** is defined as a channel, the area will be broken into contiguous overlapping sections when the fill color changes; the fill color will apply to the interval spanning the current data point and the following data point. This behavior also applies to the **fillOpacity**, **stroke**, **strokeOpacity**,
**strokeWidth**, **opacity**, **href**, **title**, and **ariaLabel** channels. When any of these channels are used, setting an explicit **z** channel (possibly to null) is strongly recommended.

[Options](#areax-options).

### areaY

`areaY(data, options)`

A horizontally-oriented area mark, where the baseline and topline share
**x** values, as in a time-series area chart where time goes right→.

If neither **y1** nor **y2** is specified, an implicit stackY transform is applied and **y** defaults to the identity function, assuming that *data* = [*y₀*, *y₁*, *y₂*, …]. Otherwise, if only one of **y1** or **y2** is specified, the other defaults to **y**, which defaults to zero.

If an **interval** is specified, **x** values are binned accordingly, allowing zeroes for empty bins instead of interpolating across gaps. This is recommended to “regularize” sampled data; for example, if your data represents timestamped observations and you expect one observation per day, use *day* as the **interval**.

Variable aesthetic channels are supported: if the **fill** is defined as a channel, the area will be broken into contiguous overlapping sections when the fill color changes; the fill color will apply to the interval spanning the current data point and the following data point. This behavior also applies to the **fillOpacity**, **stroke**, **strokeOpacity**,
**strokeWidth**, **opacity**, **href**, **title**, and **ariaLabel** channels. When any of these channels are used, setting an explicit **z** channel (possibly to null) is strongly recommended.

[Options](#areay-options).

## Arrow

### arrow

`arrow(data, options)`

An arrow mark, drawing (possibly swoopy) arrows connecting pairs of points.

[Options](#arrow-options).

## Axis

### axisX

`axisX(options)`

An axis mark to document the visual encoding of the horizontal position
*x* scale, comprised of (up to) three marks: a vector for ticks, a text for tick labels, and another text for an axis label. The data defaults to tick values sampled from the *x* scale’s domain; if desired, use one of the **ticks**, **tickSpacing**, or **interval** options.

The **facetAnchor** option defaults to *bottom-empty* if **anchor** is
*bottom*, and *top-empty* if **anchor** is *top*. The default margins likewise depend on **anchor** as follows; in order of **marginTop**,
**marginRight**, **marginBottom**, and **marginLeft**, in pixels:

- *top* - 30, 20, 0, 20
- *bottom* - 0, 20, 30, 20

For simplicity, and for consistent layout across plots, default axis margins are not affected by tick labels. If tick labels are too long, either increase the margin or shorten the labels: use the *k* SI-prefix tick format; use the
**transform** *y*-scale option to show thousands or millions; or use the
**textOverflow** and **lineWidth** options to clip.

[Options](#axisx-options).

### axisY

`axisY(options)`

An axis mark to document the visual encoding of the vertical position *y* scale, comprised of (up to) three marks: a vector for ticks, a text for tick labels, and another text for an axis label. The data defaults to tick values sampled from the *y* scale’s domain; if desired, use one of the
**ticks**, **tickSpacing**, or **interval** options.

The **facetAnchor** option defaults to *right-empty* if **anchor** is
*right*, and *left-empty* if **anchor** is *left*. The default margins likewise depend on **anchor** as follows; in order of **marginTop**,
**marginRight**, **marginBottom**, and **marginLeft**, in pixels:

- *right* - 20, 40, 20, 0
- *left* - 20, 0, 20, 40

For simplicity, and for consistent layout across plots, default axis margins are not affected by tick labels. If tick labels are too long, either increase the margin or shorten the labels: use the *k* SI-prefix tick format; or use the **textOverflow** and **lineWidth** options to clip.

[Options](#axisy-options).

### axisFx

`axisFx(options)`

An axis mark to document the visual encoding of the horizontal facet position *fx* scale, comprised of (up to) three marks: a vector for ticks, a text for tick labels, and another text for an axis label. The data defaults to the *fx* scale’s domain; if desired, use one of the **ticks**,
**tickSpacing**, or **interval** options.

The **facetAnchor** and **frameAnchor** options defaults to **anchor**. The default margins likewise depend on **anchor** as follows; in order of
**marginTop**, **marginRight**, **marginBottom**, and **marginLeft**, in pixels:

- *top* - 30, 20, 0, 20
- *bottom* - 0, 20, 30, 20

For simplicity, and for consistent layout across plots, default axis margins are not affected by tick labels. If tick labels are too long, either increase the margin or shorten the labels: use the *k* SI-prefix tick format; use the
**transform** *y*-scale option to show thousands or millions; or use the
**textOverflow** and **lineWidth** options to clip.

[Options](#axisfx-options).

### axisFy

`axisFy(options)`

An axis mark to document the visual encoding of the vertical facet position *fy* scale, comprised of (up to) three marks: a vector for ticks, a text for tick labels, and another text for an axis label. The data defaults to the *fy* scale’s domain; if desired, use one of the **ticks**,
**tickSpacing**, or **interval** options.

The **facetAnchor** option defaults to *right-empty* if **anchor** is
*right*, and *left-empty* if **anchor** is *left*. The default margins likewise depend on **anchor** as follows; in order of **marginTop**,
**marginRight**, **marginBottom**, and **marginLeft**, in pixels:

- *right* - 20, 40, 20, 0
- *left* - 20, 0, 20, 40

For simplicity, and for consistent layout across plots, default axis margins are not affected by tick labels. If tick labels are too long, either increase the margin or shorten the labels: use the *k* SI-prefix tick format; or use the **textOverflow** and **lineWidth** options to clip.

[Options](#axisfy-options).

## Bar

### barX

`barX(data, options)`

A horizontal bar mark. The required *x* values should be quantitative or temporal, and the optional *y* values should be ordinal.

If neither **x1** nor **x2** nor **interval** is specified, an implicit stackX transform is applied and **x** defaults to the identity function, assuming that *data* = [*x₀*, *x₁*, *x₂*, …]. Otherwise if an **interval** is specified, then **x1** and **x2** are derived from **x**, representing the lower and upper bound of the containing interval, respectively. Otherwise, if only one of **x1** or **x2** is specified, the other defaults to **x**, which defaults to zero.

The optional **y** ordinal channel specifies the vertical position; it is typically bound to the *y* scale, which must be a *band* scale. If the
**y** channel is not specified, the bar will span the vertical extent of the plot’s frame.

If *y* is quantitative, use the rectX mark instead. If *x* is ordinal, use the cell mark instead.

[Options](#barx-options).

### barY

`barY(data, options)`

A vertical bar mark. The required *y* values should be quantitative or temporal, and the optional *x* values should be ordinal.

If neither **y1** nor **y2** nor **interval** is specified, an implicit stackY transform is applied and **y** defaults to the identity function, assuming that *data* = [*y₀*, *y₁*, *y₂*, …]. Otherwise if an **interval** is specified, then **y1** and **y2** are derived from **y**, representing the lower and upper bound of the containing interval, respectively. Otherwise, if only one of **y1** or **y2** is specified, the other defaults to **y**, which defaults to zero.

The optional **x** ordinal channel specifies the horizontal position; it is typically bound to the *x* scale, which must be a *band* scale. If the
**x** channel is not specified, the bar will span the horizontal extent of the plot’s frame.

If *x* is quantitative, use the rectY mark instead. If *y* is ordinal, use the cell mark instead.

[Options](#bary-options).

## Cell

### cell

`cell(data, options)`

A rectangular cell mark. Along with **x** and/or **y**, a **fill** channel is typically specified to encode value as color.

If neither **x** nor **y** are specified, *data* is assumed to be an array of pairs [[*x₀*, *y₀*], [*x₁*, *y₁*], [*x₂*, *y₂*], …] such that **x** = [*x₀*,
*x₁*, *x₂*, …] and **y** = [*y₀*, *y₁*, *y₂*, …].

Both **x** and **y** should be ordinal; if only **x** is quantitative (or temporal), use a barX mark; if only **y** is quantitative, use a barY mark; if both are quantitative, use a rect mark.

[Options](#cell-options).

### cellX

`cellX(data, options)`

Like cell, but **x** defaults to the zero-based index [0, 1, 2, …], and if
**stroke** is not a channel, **fill** defaults to the identity function, assuming that *data* = [*x₀*, *x₁*, *x₂*, …].

[Options](#cellx-options).

### cellY

`cellY(data, options)`

Like cell, but **y** defaults to the zero-based index [0, 1, 2, …], and if
**stroke** is not a channel, **fill** defaults to the identity function, assuming that *data* = [*y₀*, *y₁*, *y₂*, …].

[Options](#celly-options).

## Contour

### contour

`contour(data, options)`

A contour mark that draws isolines to delineate regions above and below a particular continuous value. It is often used to convey densities as a height field. The special column name "density" can be used to map density values to the fill or stroke options.

[Options](#contour-options).

## Delaunay

Given set of points in x and y, the Delaunay marks compute the Delaunay triangulation, its dual the Voronoi tessellation, and the convex hull.
The supported marks are `voronoi`, `voronoiMesh`, `delaunayLink`, `delaunayMesh`, and `hull`.
For more, see the [Observable Plot `delaunay` documentation](https://observablehq.com/plot/marks/delaunay).

## Density 1D

### densityX

`densityX(data, options)`

A densityX mark that visualizes smoothed point cloud densities along the
**x** dimension. The mark bins the data, counts the number of records that fall into each bin, smooths the resulting counts, and then plots the smoothed distribution, by default using an areaX mark.

Set the *type* property to use a different base mark type.

[Options](#densityx-options).

### densityY

`densityY(data, options)`

A densityY mark that visualizes smoothed point cloud densities along the
**y** dimension. The mark bins the data, counts the number of records that fall into each bin, smooths the resulting counts, and then plots the smoothed distribution, by default using an areaY mark.

Set the *type* property to use a different base mark type.

[Options](#densityy-options).

## Density 2D

### density

`density(data, options)`

A 2D density mark that shows smoothed point cloud densities along two dimensions. The mark bins the data, counts the number of records that fall into each bin, and smooths the resulting counts, then plots the smoothed distribution, by default using a circular dot mark. The density mark calculates density values that can be mapped to encoding channels such as fill or r using the special field name "density".

Set the *type* property to use a different base mark type.

[Options](#density-options).

## Dense Line

### denseLine

`denseLine(data, options)`

A denseLine mark that plots line densities rather than point densities. The mark forms a binned raster grid and "draws" straight lines into it. To avoid over-weighting steep lines, by default each drawn series is normalized on a per-column basis to approximate arc length normalization. The values for each series are aggregated to form the line density, which is then drawn as an image similar to the raster mark.

[Options](#denseline-options).

## Dot

### dot

`dot(data, options)`

A dot mark that draws circles, or other symbols, as in a scatterplot.

If either **x** or **y** is not specified, the default is determined by the
**frameAnchor** option. If none of **x**, **y**, and **frameAnchor** are specified, *data* is assumed to be an array of pairs [[*x₀*, *y₀*], [*x₁*,
*y₁*], [*x₂*, *y₂*], …] such that **x** = [*x₀*, *x₁*, *x₂*, …] and **y** = [*y₀*, *y₁*, *y₂*, …].

Dots are sorted by descending radius **r** by default to mitigate overplotting; set the **sort** option to null to draw them in input order.

[Options](#dot-options).

### dotX

`dotX(data, options)`

Like dot, except that **x** defaults to the identity function, assuming that
*data* = [*x₀*, *x₁*, *x₂*, …].

If an **interval** is specified, such as *day*, **y** is transformed to the middle of the interval.

[Options](#dotx-options).

### dotY

`dotY(data, options)`

Like dot, except that **y** defaults to the identity function, assuming that
*data* = [*y₀*, *y₁*, *y₂*, …].

If an **interval** is specified, such as *day*, **x** is transformed to the middle of the interval.

[Options](#doty-options).

### circle

`circle(data, options)`

Like dot, except that the **symbol** option is set to *circle*.

[Options](#circle-options).

### hexagon

`hexagon(data, options)`

Like dot, except that the **symbol** option is set to *hexagon*.

[Options](#hexagon-options).

## Frame

### frame

`frame(options)`

Draws a rectangle around the plot’s frame, or if an **anchor** is given, a line on the given side. Useful for visual separation of facets, or in conjunction with axes and grids to fill the frame’s background.

[Options](#frame-options).

## Geo

The `geo` mark draws geographic features—polygons, lines, points, and other geometry—often as thematic maps.
Input data can be provided directly as an array of GeoJSON features or geographic data can be loaded and queried directly in DuckDB using the `spatial` extension.

The _geometry_ option indicates the column name containing GeoJSON features or GeoJSON geometry objects.
If _geometry_ is not specified, the mark will interpret input objects as GeoJSON when data is passed in directly.
When querying geometry from a DuckDB table, the _geometry_ option will default to `'geom'` (the default name for geometry data loaded using the `spatial` extension's `ST_Read` function) and will be automatically converted to GeoJSON format in the database using the `ST_asGeoJSON` function.
If the _geometry_ option is specified, automatic conversion of DuckDB query results is _not_ performed; this enables more fine-grained control, but may require explicit conversion of data to GeoJSON format using `ST_asGeoJSON` (or equivalently using Mosaic's `geojson()` SQL helper).

The `sphere` and `graticule` marks (which do not accept input data) include the sphere of the Earth and global reference lines, respectively.
For other supported options, see the [Observable Plot `geo` documentation](https://observablehq.com/plot/marks/geo).

## Grid

### gridX

`gridX(options)`

A horizontally-positioned ruleX mark (a vertical line, |) that renders a grid for the *x* scale. The data defaults to tick values sampled from the
*x* scale’s domain; if desired, use one of the **ticks**, **tickSpacing**, or **interval** options.

[Options](#gridx-options).

### gridY

`gridY(options)`

A vertically-positioned ruleY mark (a horizontal line, —) that renders a grid for the *y* scale. The data defaults to tick values sampled from the
*y* scale’s domain; if desired, use one of the **ticks**, **tickSpacing**, or **interval** options.

[Options](#gridy-options).

### gridFx

`gridFx(options)`

A horizontally-positioned ruleX mark (a vertical line, |) that renders a grid for the *fx* scale. The data defaults to the *fx* scale’s domain; if desired, use the **ticks** option.

[Options](#gridfx-options).

### gridFy

`gridFy(options)`

A vertically-positioned ruleY mark (a horizontal line, —) that renders a grid for the *fy* scale. The data defaults to the *fy* scale’s domain; if desired, use the **ticks** option.

[Options](#gridfy-options).

## Heatmap

### heatmap

`heatmap(data, options)`

Like raster, but with default options for accurate density estimation via smoothing. The *bandwidth* (20), *interpolate* ("linear"), and
*pixelSize* (2) options are set to produce smoothed density heatmaps.

[Options](#heatmap-options).

## Hexbin

### hexbin

`hexbin(data, options)`

A hexbin mark that bins **x** and **y** data into a hexagonal grid and visualizes aggregate functions per bin (e.g., count for binned density). Aggregate functions can be used for fill, stroke, or r (radius) options.

[Options](#hexbin-options).

## Hexgrid

### hexgrid

`hexgrid(options)`

The hexgrid decoration mark complements the hexbin mark, showing the outlines of all hexagons spanning the frame with a default **stroke** of
*currentColor* and a default **strokeOpacity** of 0.1, similar to the default axis grids.

Note that the **binWidth** option of the hexgrid mark should match that of the hexbin transform. The grid is clipped by the frame. This is a stroke-only mark, and **fill** is not supported; to fill the frame, use the frame mark.

[Options](#hexgrid-options).

## Image

### image

`image(data, options)`

An image mark that draws images as in a scatterplot.

If either **x** or **y** is not specified, the default is determined by the **frameAnchor** option. If none of **x**, **y**, and **frameAnchor** are specified, *data* is assumed to be an array of pairs [[*x₀*, *y₀*], [*x₁*, *y₁*], [*x₂*, *y₂*], …] such that **x** = [*x₀*, *x₁*, *x₂*, …] and **y** = [*y₀*, *y₁*, *y₂*, …].

[Options](#image-options).

## Line

### line

`line(data, options)`

A line mark that connects control points.

Points along the line are connected in input order. If there are multiple series via the **z**, **fill**, or **stroke** channel, series are drawn in input order such that the last series is drawn on top. Typically *data* is already in sorted order, such as chronological for time series; if needed, consider a **sort** transform.

If any **x** or **y** values are invalid (undefined, null, or NaN), the line will be interrupted, resulting in a break that divides the line shape into multiple segments. If a line segment consists of only a single point, it may appear invisible unless rendered with rounded or square line caps. In addition, some curves such as *cardinal-open* only render a visible segment if it contains multiple points.

Variable aesthetic channels are supported: if the **stroke** is defined as a channel, the line will be broken into contiguous overlapping segments when the stroke color changes; the stroke color will apply to the interval spanning the current data point and the following data point. This behavior also applies to the **fill**, **fillOpacity**, **strokeOpacity**,
**strokeWidth**, **opacity**, **href**, **title**, and **ariaLabel** channels. When any of these channels are used, setting an explicit **z** channel (possibly to null) is strongly recommended.

[Options](#line-options).

### lineX

`lineX(data, options)`

Like line, except that **x** defaults to the identity function assuming that *data* = [*x₀*, *x₁*, *x₂*, …] and **y** defaults to the zero-based index [0, 1, 2, …].

[Options](#linex-options).

### lineY

`lineY(data, options)`

Like line, except **y** defaults to the identity function and assumes that *data* = [*y₀*, *y₁*, *y₂*, …] and **x** defaults to the zero-based index [0, 1, 2, …].

[Options](#liney-options).

## Regression

### regressionY

`regressionY(data, options)`

A mark that draws [linear regression](https://en.wikipedia.org/wiki/Linear_regression) lines with confidence bands, representing the estimated relation of a dependent variable (*y*) on an independent variable (*x*).

The linear regression line is fit using the [least squares](https://en.wikipedia.org/wiki/Least_squares) approach. See Torben Jansen’s [“Linear regression with confidence bands”](https://observablehq.com/@toja/linear-regression-with-confidence-bands) and [this StatExchange question](https://stats.stackexchange.com/questions/101318/understanding-shape-and-calculation-of-confidence-bands-in-linear-regression) for details on the confidence interval calculation.

Multiple regressions can be produced by specifying a **z**, **fill**, or
**stroke** channel.

[Options](#regressiony-options).

## Link

### link

`link(data, options)`

A link mark, drawing line segments (curves) connecting pairs of points.

If the plot uses a spherical **projection**, the default *auto* **curve** will render links as geodesics; to draw a straight line instead, use the
*linear* **curve**.

[Options](#link-options).

## Raster

### raster

`raster(data, options)`

A raster mark which renders a raster image from spatial samples. It represents discrete samples in abstract coordinates **x** and **y**; the **fill** and **fillOpacity** channels specify further abstract values (_e.g._, height in a topographic map) to be spatially interpolated to produce an image.

The **x** and **y** data domains are binned into the cells ("pixels") of a raster grid, typically with an aggregate function evaluated over the binned data. The result can be optionally smoothed (blurred).

To create a smoothed density heatmap, use the heatmap mark, which is a raster mark with different default options.

[Options](#raster-options).

### rasterTile

`rasterTile(data, options)`

An experimental raster mark which performs tiling and prefetching to support more scalable rasters upon panning the domain. Uses a tile size that matches with current width and height, and prefetches data from neighboring tile segments.

[Options](#rastertile-options).

## Rect

### rect

`rect(data, options)`

A rect mark. The rectangle extends horizontally from **x1** to **x2**, and vertically from **y1** to **y2**. The position channels are often derived with a transform.

When **y** extends from zero, for example for a histogram where the height of each rect reflects a count of values, use the rectY mark for an implicit stackY transform; similarly, if **x** extends from zero, use the rectX mark for an implicit stackX transform.

If an **interval** is specified, then **x1** and **x2** are derived from
**x**, and **y1** and **y2** are derived from **y**, each representing the lower and upper bound of the containing interval, respectively.

Both *x* and *y* should be quantitative or temporal; otherwise, use a bar or cell mark.

[Options](#rect-options).

### rectX

`rectX(data, options)`

Like rect, but if neither **x1** nor **x2** is specified, an implicit stackX transform is applied to **x**, and if **x** is not specified, it defaults to the identity function, assuming that *data* is an array of numbers [*x₀*, *x₁*, *x₂*, …].

[Options](#rectx-options).

### rectY

`rectY(data, options)`

Like rect, but if neither **y1** nor **y2** is specified, apply an implicit stackY transform is applied to **y**, and if **y** is not specified, it defaults to the identity function, assuming that *data* is an array of numbers [*y₀*, *y₁*, *y₂*, …].

[Options](#recty-options).

## Rule

### ruleX

`ruleX(data, options)`

A horizontally-positioned ruleX mark (a vertical line, |). The **x** channel specifies the rule’s horizontal position and defaults to identity, assuming that *data* = [*x₀*, *x₁*, *x₂*, …]; the optional **y1** and
**y2** channels specify its vertical extent.

The ruleX mark is often used to highlight specific *x* values. If *y* represents ordinal values, use a tickX mark instead.

[Options](#rulex-options).

### ruleY

`ruleY(data, options)`

A vertically-positioned ruleY mark (a horizontal line, —). The **y** channel specifies the rule's vertical position and defaults to identity, assuming that *data* = [*y₀*, *y₁*, *y₂*, …]; the optional **x1** and
**x2** channels specify its horizontal extent.

The ruleY mark is often used to highlight specific *y* values. If *x* represents ordinal values, use a tickY mark instead.

[Options](#ruley-options).

## Text

### text

`text(data, options)`

A text mark. The **text** channel specifies the textual contents of the mark, which may be preformatted with line breaks (\n, \r\n, or \r), or wrapped or clipped using the **lineWidth** and **textOverflow** options.

If **text** contains numbers or dates, a default formatter will be applied, and the **fontVariant** will default to *tabular-nums* instead of *normal*. If **text** is not specified, it defaults to the identity function for primitive data (such as numbers, dates, and strings), and to the zero-based index [0, 1, 2, …] for objects (so that something identifying is visible by default).

If either **x** or **y** is not specified, the default is determined by the **frameAnchor** option.

[Options](#text-options).

### textX

`textX(data, options)`

Like text, but **x** defaults to the identity function, assuming that
*data* = [*x₀*, *x₁*, *x₂*, …]. If an **interval** is specified, such as
*day*, **y** is transformed to the middle of the interval.

[Options](#textx-options).

### textY

`textY(data, options)`

Like text, but **y** defaults to the identity function, assuming that
*data* = [*y₀*, *y₁*, *y₂*, …]. If an **interval** is specified, such as
*day*, **x** is transformed to the middle of the interval.

[Options](#texty-options).

## Tick

### tickX

`tickX(data, options)`

A horizontally-positioned tickX mark (a vertical line, |). The **x** channel specifies the tick’s horizontal position and defaults to identity, assuming that *data* = [*x₀*, *x₁*, *x₂*, …]; the optional **y** ordinal channel specifies its vertical position.

If *y* represents quantitative or temporal values, use a ruleX mark instead.

[Options](#tickx-options).

### tickY

`tickY(data, options)`

A vertically-positioned tickY mark (a horizontal line, —). The **y** channel specifies the tick's vertical position and defaults to identity, assuming that *data* = [*y₀*, *y₁*, *y₂*, …]; the optional **x** ordinal channel specifies its horizontal position.

If *x* represents quantitative or temporal values, use a ruleY mark instead.

[Options](#ticky-options).

## Vector

### vector

`vector(data, options)`

A vector mark.

If none of **frameAnchor**, **x**, and **y** are specified, then **x** and
**y** default to accessors assuming that *data* contains tuples [[*x₀*,
*y₀*], [*x₁*, *y₁*], [*x₂*, *y₂*], …]

[Options](#vector-options).

### vectorX

`vectorX(data, options)`

Like vector, but **x** instead defaults to the identity function and **y** defaults to null, assuming that *data* is an array of numbers [*x₀*, *x₁*,
*x₂*, …].

[Options](#vectorx-options).

### vectorY

`vectorY(data, options)`

Like vector, but **y** instead defaults to the identity function and **x** defaults to null, assuming that *data* is an array of numbers [*y₀*, *y₁*,
*y₂*, …].

[Options](#vectory-options).

### spike

`spike(data, options)`

Like vector, but with default *options* suitable for drawing a spike map.

[Options](#spike-options).

## Waffle

### waffleX

`waffleX(data, options)`

A horizontal waffle mark. The required *x* values should be quantitative, and the optional *y* values should be ordinal.

If neither **x1** nor **x2** nor **interval** is specified, an implicit stackX transform is applied and **x** defaults to the identity function, assuming that *data* = [*x₀*, *x₁*, *x₂*, …]. Otherwise if an **interval** is specified, then **x1** and **x2** are derived from **x**, representing the lower and upper bound of the containing interval, respectively. Otherwise, if only one of **x1** or **x2** is specified, the other defaults to **x**, which defaults to zero.

The optional **y** ordinal channel specifies the vertical position; it is typically bound to the *y* scale, which must be a *band* scale. If the
**y** channel is not specified, the bar will span the vertical extent of the plot’s frame. Because a waffle represents a discrete number of square cells, it may not use all of the available bandwidth.

[Options](#wafflex-options).

### waffleY

`waffleY(data, options)`

A vertical waffle mark. The required *y* values should be quantitative, and the optional *x* values should be ordinal.

If neither **y1** nor **y2** nor **interval** is specified, an implicit stackY transform is applied and **y** defaults to the identity function, assuming that *data* = [*y₀*, *y₁*, *y₂*, …]. Otherwise if an **interval** is specified, then **y1** and **y2** are derived from **y**, representing the lower and upper bound of the containing interval, respectively. Otherwise, if only one of **y1** or **y2** is specified, the other defaults to **y**, which defaults to zero.

The optional **x** ordinal channel specifies the horizontal position; it is typically bound to the *x* scale, which must be a *band* scale. If the
**x** channel is not specified, the bar will span the horizontal extent of the plot’s frame. Because a waffle represents a discrete number of square cells, it may not use all of the available bandwidth.

[Options](#waffley-options).

## Error Bar

### errorbarX

`errorbarX(data, options)`

A mark that draws error bars for a calculated parametric confidence interval for a dependent variable (*x*), potentially grouped by an independent variable (*y*).

This mark aggregates raw values to produce a [parametric confidence interval](https://en.wikipedia.org/wiki/Normal_distribution#Confidence_intervals) of the mean, assuming a normal distribution. To instead visualize pre-computed interval values or custom aggregations, use a **ruleY** mark with specified **x1** and **x2** channels.

Multiple error bars can be produced by specifying a **z** or **stroke** channel. Set the **marker** option to `'tick'` to add small perpendicular lines at the start and end of the error interval.

[Options](#errorbarx-options).

### errorbarY

`errorbarY(data, options)`

A mark that draws error bars for a calculated parametric confidence interval for a dependent variable (*y*), potentially grouped by an independent variable (*x*).

This mark aggregates raw values to produce a [parametric confidence interval](https://en.wikipedia.org/wiki/Normal_distribution#Confidence_intervals) of the mean, assuming a normal distribution. To instead visualize pre-computed interval values or custom aggregations, use a **ruleX** mark with specified **y1** and **y2** channels.

Multiple error bars can be produced by specifying a **z** or **stroke** channel. Set the **marker** option to `'tick'` to add small perpendicular lines at the start and end of the error interval.

[Options](#errorbary-options).

</template>

<template v-else-if="language === 'python'">

# Marks

Marks visualize data through named channels, including position, color, opacity, and size. The set of known channel names. The [common mark contracts](../spec/common-marks) describe channel values, shared options, and target-specific behavior.

Use a named mark helper or `vg.mark(name, data, **options)` to create marks. Data can be a `DataDef`, a `vg.source(tableName)` reference, an inline array, or a supported frame. Named helpers omit `UNSET` keyword values; the generic `vg.mark` retains the supplied encoding values.

```python
import vgplot as vg

vg.plot(vg.mark('dot', vg.source('data'), x='x', y='y'));
```

`vg.channels(**kwargs)` preserves channel keys and values. `vg.directive(key, value)` creates a plot directive. For source-backed marks, the data options `filter_by` → `filterBy`, `optimize` → `optimize` are attached to the data reference. See [Python helpers](../spec/common-marks#python-helpers) for signatures.

[Examples and target-specific authoring](../spec/common-marks#examples).

## Area

### area

`area(data=None, **options)`

An area mark. The area mark is rarely used directly; it is only needed when the baseline and topline have neither *x* nor *y* values in common. Use areaY for a horizontal orientation where the baseline and topline share *x* values, or areaX for a vertical orientation where the baseline and topline share *y* values.

[Options](#area-options).

### area_x

`area_x(data=None, **options)`

A vertically-oriented area mark, where the baseline and topline share
**y** values, as in a time-series area chart where time goes up↑.

If neither **x1** nor **x2** is specified, an implicit stackX transform is applied and **x** defaults to the identity function, assuming that *data* = [*x₀*, *x₁*, *x₂*, …]. Otherwise, if only one of **x1** or **x2** is specified, the other defaults to **x**, which defaults to zero.

If an **interval** is specified, **y** values are binned accordingly, allowing zeroes for empty bins instead of interpolating across gaps. This is recommended to “regularize” sampled data; for example, if your data represents timestamped observations and you expect one observation per day, use *day* as the **interval**.

Variable aesthetic channels are supported: if the **fill** is defined as a channel, the area will be broken into contiguous overlapping sections when the fill color changes; the fill color will apply to the interval spanning the current data point and the following data point. This behavior also applies to the **fillOpacity**, **stroke**, **strokeOpacity**,
**strokeWidth**, **opacity**, **href**, **title**, and **ariaLabel** channels. When any of these channels are used, setting an explicit **z** channel (possibly to null) is strongly recommended.

[Options](#areax-options).

### area_y

`area_y(data=None, **options)`

A horizontally-oriented area mark, where the baseline and topline share
**x** values, as in a time-series area chart where time goes right→.

If neither **y1** nor **y2** is specified, an implicit stackY transform is applied and **y** defaults to the identity function, assuming that *data* = [*y₀*, *y₁*, *y₂*, …]. Otherwise, if only one of **y1** or **y2** is specified, the other defaults to **y**, which defaults to zero.

If an **interval** is specified, **x** values are binned accordingly, allowing zeroes for empty bins instead of interpolating across gaps. This is recommended to “regularize” sampled data; for example, if your data represents timestamped observations and you expect one observation per day, use *day* as the **interval**.

Variable aesthetic channels are supported: if the **fill** is defined as a channel, the area will be broken into contiguous overlapping sections when the fill color changes; the fill color will apply to the interval spanning the current data point and the following data point. This behavior also applies to the **fillOpacity**, **stroke**, **strokeOpacity**,
**strokeWidth**, **opacity**, **href**, **title**, and **ariaLabel** channels. When any of these channels are used, setting an explicit **z** channel (possibly to null) is strongly recommended.

[Options](#areay-options).

## Arrow

### arrow

`arrow(data=None, **options)`

An arrow mark, drawing (possibly swoopy) arrows connecting pairs of points.

[Options](#arrow-options).

## Axis

### axis_x

`axis_x(data=None, **options)`

An axis mark to document the visual encoding of the horizontal position
*x* scale, comprised of (up to) three marks: a vector for ticks, a text for tick labels, and another text for an axis label. The data defaults to tick values sampled from the *x* scale’s domain; if desired, use one of the **ticks**, **tickSpacing**, or **interval** options.

The **facetAnchor** option defaults to *bottom-empty* if **anchor** is
*bottom*, and *top-empty* if **anchor** is *top*. The default margins likewise depend on **anchor** as follows; in order of **marginTop**,
**marginRight**, **marginBottom**, and **marginLeft**, in pixels:

- *top* - 30, 20, 0, 20
- *bottom* - 0, 20, 30, 20

For simplicity, and for consistent layout across plots, default axis margins are not affected by tick labels. If tick labels are too long, either increase the margin or shorten the labels: use the *k* SI-prefix tick format; use the
**transform** *y*-scale option to show thousands or millions; or use the
**textOverflow** and **lineWidth** options to clip.

[Options](#axisx-options).

### axis_y

`axis_y(data=None, **options)`

An axis mark to document the visual encoding of the vertical position *y* scale, comprised of (up to) three marks: a vector for ticks, a text for tick labels, and another text for an axis label. The data defaults to tick values sampled from the *y* scale’s domain; if desired, use one of the
**ticks**, **tickSpacing**, or **interval** options.

The **facetAnchor** option defaults to *right-empty* if **anchor** is
*right*, and *left-empty* if **anchor** is *left*. The default margins likewise depend on **anchor** as follows; in order of **marginTop**,
**marginRight**, **marginBottom**, and **marginLeft**, in pixels:

- *right* - 20, 40, 20, 0
- *left* - 20, 0, 20, 40

For simplicity, and for consistent layout across plots, default axis margins are not affected by tick labels. If tick labels are too long, either increase the margin or shorten the labels: use the *k* SI-prefix tick format; or use the **textOverflow** and **lineWidth** options to clip.

[Options](#axisy-options).

### axis_fx

`axis_fx(data=None, **options)`

An axis mark to document the visual encoding of the horizontal facet position *fx* scale, comprised of (up to) three marks: a vector for ticks, a text for tick labels, and another text for an axis label. The data defaults to the *fx* scale’s domain; if desired, use one of the **ticks**,
**tickSpacing**, or **interval** options.

The **facetAnchor** and **frameAnchor** options defaults to **anchor**. The default margins likewise depend on **anchor** as follows; in order of
**marginTop**, **marginRight**, **marginBottom**, and **marginLeft**, in pixels:

- *top* - 30, 20, 0, 20
- *bottom* - 0, 20, 30, 20

For simplicity, and for consistent layout across plots, default axis margins are not affected by tick labels. If tick labels are too long, either increase the margin or shorten the labels: use the *k* SI-prefix tick format; use the
**transform** *y*-scale option to show thousands or millions; or use the
**textOverflow** and **lineWidth** options to clip.

[Options](#axisfx-options).

### axis_fy

`axis_fy(data=None, **options)`

An axis mark to document the visual encoding of the vertical facet position *fy* scale, comprised of (up to) three marks: a vector for ticks, a text for tick labels, and another text for an axis label. The data defaults to the *fy* scale’s domain; if desired, use one of the **ticks**,
**tickSpacing**, or **interval** options.

The **facetAnchor** option defaults to *right-empty* if **anchor** is
*right*, and *left-empty* if **anchor** is *left*. The default margins likewise depend on **anchor** as follows; in order of **marginTop**,
**marginRight**, **marginBottom**, and **marginLeft**, in pixels:

- *right* - 20, 40, 20, 0
- *left* - 20, 0, 20, 40

For simplicity, and for consistent layout across plots, default axis margins are not affected by tick labels. If tick labels are too long, either increase the margin or shorten the labels: use the *k* SI-prefix tick format; or use the **textOverflow** and **lineWidth** options to clip.

[Options](#axisfy-options).

## Bar

### bar_x

`bar_x(data=None, **options)`

A horizontal bar mark. The required *x* values should be quantitative or temporal, and the optional *y* values should be ordinal.

If neither **x1** nor **x2** nor **interval** is specified, an implicit stackX transform is applied and **x** defaults to the identity function, assuming that *data* = [*x₀*, *x₁*, *x₂*, …]. Otherwise if an **interval** is specified, then **x1** and **x2** are derived from **x**, representing the lower and upper bound of the containing interval, respectively. Otherwise, if only one of **x1** or **x2** is specified, the other defaults to **x**, which defaults to zero.

The optional **y** ordinal channel specifies the vertical position; it is typically bound to the *y* scale, which must be a *band* scale. If the
**y** channel is not specified, the bar will span the vertical extent of the plot’s frame.

If *y* is quantitative, use the rectX mark instead. If *x* is ordinal, use the cell mark instead.

[Options](#barx-options).

### bar_y

`bar_y(data=None, **options)`

A vertical bar mark. The required *y* values should be quantitative or temporal, and the optional *x* values should be ordinal.

If neither **y1** nor **y2** nor **interval** is specified, an implicit stackY transform is applied and **y** defaults to the identity function, assuming that *data* = [*y₀*, *y₁*, *y₂*, …]. Otherwise if an **interval** is specified, then **y1** and **y2** are derived from **y**, representing the lower and upper bound of the containing interval, respectively. Otherwise, if only one of **y1** or **y2** is specified, the other defaults to **y**, which defaults to zero.

The optional **x** ordinal channel specifies the horizontal position; it is typically bound to the *x* scale, which must be a *band* scale. If the
**x** channel is not specified, the bar will span the horizontal extent of the plot’s frame.

If *x* is quantitative, use the rectY mark instead. If *y* is ordinal, use the cell mark instead.

[Options](#bary-options).

## Cell

### cell

`cell(data=None, **options)`

A rectangular cell mark. Along with **x** and/or **y**, a **fill** channel is typically specified to encode value as color.

If neither **x** nor **y** are specified, *data* is assumed to be an array of pairs [[*x₀*, *y₀*], [*x₁*, *y₁*], [*x₂*, *y₂*], …] such that **x** = [*x₀*,
*x₁*, *x₂*, …] and **y** = [*y₀*, *y₁*, *y₂*, …].

Both **x** and **y** should be ordinal; if only **x** is quantitative (or temporal), use a barX mark; if only **y** is quantitative, use a barY mark; if both are quantitative, use a rect mark.

[Options](#cell-options).

### cell_x

`cell_x(data=None, **options)`

Like cell, but **x** defaults to the zero-based index [0, 1, 2, …], and if
**stroke** is not a channel, **fill** defaults to the identity function, assuming that *data* = [*x₀*, *x₁*, *x₂*, …].

[Options](#cellx-options).

### cell_y

`cell_y(data=None, **options)`

Like cell, but **y** defaults to the zero-based index [0, 1, 2, …], and if
**stroke** is not a channel, **fill** defaults to the identity function, assuming that *data* = [*y₀*, *y₁*, *y₂*, …].

[Options](#celly-options).

## Contour

### contour

`contour(data=None, **options)`

A contour mark that draws isolines to delineate regions above and below a particular continuous value. It is often used to convey densities as a height field. The special column name "density" can be used to map density values to the fill or stroke options.

[Options](#contour-options).

## Delaunay

Given set of points in x and y, the Delaunay marks compute the Delaunay triangulation, its dual the Voronoi tessellation, and the convex hull.
The supported marks are `voronoi`, `voronoi_mesh`, `delaunay_link`, `delaunay_mesh`, and `hull`.
For more, see the [Observable Plot `delaunay` documentation](https://observablehq.com/plot/marks/delaunay).

## Density 1D

### density_x

`density_x(data=None, **options)`

A densityX mark that visualizes smoothed point cloud densities along the
**x** dimension. The mark bins the data, counts the number of records that fall into each bin, smooths the resulting counts, and then plots the smoothed distribution, by default using an areaX mark.

Set the *type* property to use a different base mark type.

[Options](#densityx-options).

### density_y

`density_y(data=None, **options)`

A densityY mark that visualizes smoothed point cloud densities along the
**y** dimension. The mark bins the data, counts the number of records that fall into each bin, smooths the resulting counts, and then plots the smoothed distribution, by default using an areaY mark.

Set the *type* property to use a different base mark type.

[Options](#densityy-options).

## Density 2D

### density

`density(data=None, **options)`

A 2D density mark that shows smoothed point cloud densities along two dimensions. The mark bins the data, counts the number of records that fall into each bin, and smooths the resulting counts, then plots the smoothed distribution, by default using a circular dot mark. The density mark calculates density values that can be mapped to encoding channels such as fill or r using the special field name "density".

Set the *type* property to use a different base mark type.

[Options](#density-options).

## Dense Line

### dense_line

`dense_line(data=None, **options)`

A denseLine mark that plots line densities rather than point densities. The mark forms a binned raster grid and "draws" straight lines into it. To avoid over-weighting steep lines, by default each drawn series is normalized on a per-column basis to approximate arc length normalization. The values for each series are aggregated to form the line density, which is then drawn as an image similar to the raster mark.

[Options](#denseline-options).

## Dot

### dot

`dot(data=None, **options)`

A dot mark that draws circles, or other symbols, as in a scatterplot.

If either **x** or **y** is not specified, the default is determined by the
**frameAnchor** option. If none of **x**, **y**, and **frameAnchor** are specified, *data* is assumed to be an array of pairs [[*x₀*, *y₀*], [*x₁*,
*y₁*], [*x₂*, *y₂*], …] such that **x** = [*x₀*, *x₁*, *x₂*, …] and **y** = [*y₀*, *y₁*, *y₂*, …].

Dots are sorted by descending radius **r** by default to mitigate overplotting; set the **sort** option to null to draw them in input order.

[Options](#dot-options).

### dot_x

`dot_x(data=None, **options)`

Like dot, except that **x** defaults to the identity function, assuming that
*data* = [*x₀*, *x₁*, *x₂*, …].

If an **interval** is specified, such as *day*, **y** is transformed to the middle of the interval.

[Options](#dotx-options).

### dot_y

`dot_y(data=None, **options)`

Like dot, except that **y** defaults to the identity function, assuming that
*data* = [*y₀*, *y₁*, *y₂*, …].

If an **interval** is specified, such as *day*, **x** is transformed to the middle of the interval.

[Options](#doty-options).

### circle

`circle(data=None, **options)`

Like dot, except that the **symbol** option is set to *circle*.

[Options](#circle-options).

### hexagon

`hexagon(data=None, **options)`

Like dot, except that the **symbol** option is set to *hexagon*.

[Options](#hexagon-options).

## Frame

### frame

`frame(data=None, **options)`

Draws a rectangle around the plot’s frame, or if an **anchor** is given, a line on the given side. Useful for visual separation of facets, or in conjunction with axes and grids to fill the frame’s background.

[Options](#frame-options).

## Geo

The `geo` mark draws geographic features—polygons, lines, points, and other geometry—often as thematic maps.
Input data can be provided directly as an array of GeoJSON features or geographic data can be loaded and queried directly in DuckDB using the `spatial` extension.

The _geometry_ option indicates the column name containing GeoJSON features or GeoJSON geometry objects.
If _geometry_ is not specified, the mark will interpret input objects as GeoJSON when data is passed in directly.
When querying geometry from a DuckDB table, the _geometry_ option will default to `'geom'` (the default name for geometry data loaded using the `spatial` extension's `ST_Read` function) and will be automatically converted to GeoJSON format in the database using the `ST_asGeoJSON` function.
If the _geometry_ option is specified, automatic conversion of DuckDB query results is _not_ performed; this enables more fine-grained control, but may require explicit conversion of data to GeoJSON format using `ST_asGeoJSON` (or equivalently using Mosaic's `geojson()` SQL helper).

The `sphere` and `graticule` marks (which do not accept input data) include the sphere of the Earth and global reference lines, respectively.
For other supported options, see the [Observable Plot `geo` documentation](https://observablehq.com/plot/marks/geo).

## Grid

### grid_x

`grid_x(data=None, **options)`

A horizontally-positioned ruleX mark (a vertical line, |) that renders a grid for the *x* scale. The data defaults to tick values sampled from the
*x* scale’s domain; if desired, use one of the **ticks**, **tickSpacing**, or **interval** options.

[Options](#gridx-options).

### grid_y

`grid_y(data=None, **options)`

A vertically-positioned ruleY mark (a horizontal line, —) that renders a grid for the *y* scale. The data defaults to tick values sampled from the
*y* scale’s domain; if desired, use one of the **ticks**, **tickSpacing**, or **interval** options.

[Options](#gridy-options).

### grid_fx

`grid_fx(data=None, **options)`

A horizontally-positioned ruleX mark (a vertical line, |) that renders a grid for the *fx* scale. The data defaults to the *fx* scale’s domain; if desired, use the **ticks** option.

[Options](#gridfx-options).

### grid_fy

`grid_fy(data=None, **options)`

A vertically-positioned ruleY mark (a horizontal line, —) that renders a grid for the *fy* scale. The data defaults to the *fy* scale’s domain; if desired, use the **ticks** option.

[Options](#gridfy-options).

## Heatmap

### heatmap

`heatmap(data=None, **options)`

Like raster, but with default options for accurate density estimation via smoothing. The *bandwidth* (20), *interpolate* ("linear"), and
*pixelSize* (2) options are set to produce smoothed density heatmaps.

[Options](#heatmap-options).

## Hexbin

### hexbin

`hexbin(data=None, **options)`

A hexbin mark that bins **x** and **y** data into a hexagonal grid and visualizes aggregate functions per bin (e.g., count for binned density). Aggregate functions can be used for fill, stroke, or r (radius) options.

[Options](#hexbin-options).

## Hexgrid

### hexgrid

`hexgrid(data=None, **options)`

The hexgrid decoration mark complements the hexbin mark, showing the outlines of all hexagons spanning the frame with a default **stroke** of
*currentColor* and a default **strokeOpacity** of 0.1, similar to the default axis grids.

Note that the **binWidth** option of the hexgrid mark should match that of the hexbin transform. The grid is clipped by the frame. This is a stroke-only mark, and **fill** is not supported; to fill the frame, use the frame mark.

[Options](#hexgrid-options).

## Image

### image

`image(data=None, **options)`

An image mark that draws images as in a scatterplot.

If either **x** or **y** is not specified, the default is determined by the **frameAnchor** option. If none of **x**, **y**, and **frameAnchor** are specified, *data* is assumed to be an array of pairs [[*x₀*, *y₀*], [*x₁*, *y₁*], [*x₂*, *y₂*], …] such that **x** = [*x₀*, *x₁*, *x₂*, …] and **y** = [*y₀*, *y₁*, *y₂*, …].

[Options](#image-options).

## Line

### line

`line(data=None, **options)`

A line mark that connects control points.

Points along the line are connected in input order. If there are multiple series via the **z**, **fill**, or **stroke** channel, series are drawn in input order such that the last series is drawn on top. Typically *data* is already in sorted order, such as chronological for time series; if needed, consider a **sort** transform.

If any **x** or **y** values are invalid (undefined, null, or NaN), the line will be interrupted, resulting in a break that divides the line shape into multiple segments. If a line segment consists of only a single point, it may appear invisible unless rendered with rounded or square line caps. In addition, some curves such as *cardinal-open* only render a visible segment if it contains multiple points.

Variable aesthetic channels are supported: if the **stroke** is defined as a channel, the line will be broken into contiguous overlapping segments when the stroke color changes; the stroke color will apply to the interval spanning the current data point and the following data point. This behavior also applies to the **fill**, **fillOpacity**, **strokeOpacity**,
**strokeWidth**, **opacity**, **href**, **title**, and **ariaLabel** channels. When any of these channels are used, setting an explicit **z** channel (possibly to null) is strongly recommended.

[Options](#line-options).

### line_x

`line_x(data=None, **options)`

Like line, except that **x** defaults to the identity function assuming that *data* = [*x₀*, *x₁*, *x₂*, …] and **y** defaults to the zero-based index [0, 1, 2, …].

[Options](#linex-options).

### line_y

`line_y(data=None, **options)`

Like line, except **y** defaults to the identity function and assumes that *data* = [*y₀*, *y₁*, *y₂*, …] and **x** defaults to the zero-based index [0, 1, 2, …].

[Options](#liney-options).

## Regression

### regression_y

`regression_y(data=None, **options)`

A mark that draws [linear regression](https://en.wikipedia.org/wiki/Linear_regression) lines with confidence bands, representing the estimated relation of a dependent variable (*y*) on an independent variable (*x*).

The linear regression line is fit using the [least squares](https://en.wikipedia.org/wiki/Least_squares) approach. See Torben Jansen’s [“Linear regression with confidence bands”](https://observablehq.com/@toja/linear-regression-with-confidence-bands) and [this StatExchange question](https://stats.stackexchange.com/questions/101318/understanding-shape-and-calculation-of-confidence-bands-in-linear-regression) for details on the confidence interval calculation.

Multiple regressions can be produced by specifying a **z**, **fill**, or
**stroke** channel.

[Options](#regressiony-options).

## Link

### link

`link(data=None, **options)`

A link mark, drawing line segments (curves) connecting pairs of points.

If the plot uses a spherical **projection**, the default *auto* **curve** will render links as geodesics; to draw a straight line instead, use the
*linear* **curve**.

[Options](#link-options).

## Raster

### raster

`raster(data=None, **options)`

A raster mark which renders a raster image from spatial samples. It represents discrete samples in abstract coordinates **x** and **y**; the **fill** and **fillOpacity** channels specify further abstract values (_e.g._, height in a topographic map) to be spatially interpolated to produce an image.

The **x** and **y** data domains are binned into the cells ("pixels") of a raster grid, typically with an aggregate function evaluated over the binned data. The result can be optionally smoothed (blurred).

To create a smoothed density heatmap, use the heatmap mark, which is a raster mark with different default options.

[Options](#raster-options).

### raster_tile

`raster_tile(data=None, **options)`

An experimental raster mark which performs tiling and prefetching to support more scalable rasters upon panning the domain. Uses a tile size that matches with current width and height, and prefetches data from neighboring tile segments.

[Options](#rastertile-options).

## Rect

### rect

`rect(data=None, **options)`

A rect mark. The rectangle extends horizontally from **x1** to **x2**, and vertically from **y1** to **y2**. The position channels are often derived with a transform.

When **y** extends from zero, for example for a histogram where the height of each rect reflects a count of values, use the rectY mark for an implicit stackY transform; similarly, if **x** extends from zero, use the rectX mark for an implicit stackX transform.

If an **interval** is specified, then **x1** and **x2** are derived from
**x**, and **y1** and **y2** are derived from **y**, each representing the lower and upper bound of the containing interval, respectively.

Both *x* and *y* should be quantitative or temporal; otherwise, use a bar or cell mark.

[Options](#rect-options).

### rect_x

`rect_x(data=None, **options)`

Like rect, but if neither **x1** nor **x2** is specified, an implicit stackX transform is applied to **x**, and if **x** is not specified, it defaults to the identity function, assuming that *data* is an array of numbers [*x₀*, *x₁*, *x₂*, …].

[Options](#rectx-options).

### rect_y

`rect_y(data=None, **options)`

Like rect, but if neither **y1** nor **y2** is specified, apply an implicit stackY transform is applied to **y**, and if **y** is not specified, it defaults to the identity function, assuming that *data* is an array of numbers [*y₀*, *y₁*, *y₂*, …].

[Options](#recty-options).

## Rule

### rule_x

`rule_x(data=None, **options)`

A horizontally-positioned ruleX mark (a vertical line, |). The **x** channel specifies the rule’s horizontal position and defaults to identity, assuming that *data* = [*x₀*, *x₁*, *x₂*, …]; the optional **y1** and
**y2** channels specify its vertical extent.

The ruleX mark is often used to highlight specific *x* values. If *y* represents ordinal values, use a tickX mark instead.

[Options](#rulex-options).

### rule_y

`rule_y(data=None, **options)`

A vertically-positioned ruleY mark (a horizontal line, —). The **y** channel specifies the rule's vertical position and defaults to identity, assuming that *data* = [*y₀*, *y₁*, *y₂*, …]; the optional **x1** and
**x2** channels specify its horizontal extent.

The ruleY mark is often used to highlight specific *y* values. If *x* represents ordinal values, use a tickY mark instead.

[Options](#ruley-options).

## Text

### text

`text(data=None, **options)`

A text mark. The **text** channel specifies the textual contents of the mark, which may be preformatted with line breaks (\n, \r\n, or \r), or wrapped or clipped using the **lineWidth** and **textOverflow** options.

If **text** contains numbers or dates, a default formatter will be applied, and the **fontVariant** will default to *tabular-nums* instead of *normal*. If **text** is not specified, it defaults to the identity function for primitive data (such as numbers, dates, and strings), and to the zero-based index [0, 1, 2, …] for objects (so that something identifying is visible by default).

If either **x** or **y** is not specified, the default is determined by the **frameAnchor** option.

[Options](#text-options).

### text_x

`text_x(data=None, **options)`

Like text, but **x** defaults to the identity function, assuming that
*data* = [*x₀*, *x₁*, *x₂*, …]. If an **interval** is specified, such as
*day*, **y** is transformed to the middle of the interval.

[Options](#textx-options).

### text_y

`text_y(data=None, **options)`

Like text, but **y** defaults to the identity function, assuming that
*data* = [*y₀*, *y₁*, *y₂*, …]. If an **interval** is specified, such as
*day*, **x** is transformed to the middle of the interval.

[Options](#texty-options).

## Tick

### tick_x

`tick_x(data=None, **options)`

A horizontally-positioned tickX mark (a vertical line, |). The **x** channel specifies the tick’s horizontal position and defaults to identity, assuming that *data* = [*x₀*, *x₁*, *x₂*, …]; the optional **y** ordinal channel specifies its vertical position.

If *y* represents quantitative or temporal values, use a ruleX mark instead.

[Options](#tickx-options).

### tick_y

`tick_y(data=None, **options)`

A vertically-positioned tickY mark (a horizontal line, —). The **y** channel specifies the tick's vertical position and defaults to identity, assuming that *data* = [*y₀*, *y₁*, *y₂*, …]; the optional **x** ordinal channel specifies its horizontal position.

If *x* represents quantitative or temporal values, use a ruleY mark instead.

[Options](#ticky-options).

## Vector

### vector

`vector(data=None, **options)`

A vector mark.

If none of **frameAnchor**, **x**, and **y** are specified, then **x** and
**y** default to accessors assuming that *data* contains tuples [[*x₀*,
*y₀*], [*x₁*, *y₁*], [*x₂*, *y₂*], …]

[Options](#vector-options).

### vector_x

`vector_x(data=None, **options)`

Like vector, but **x** instead defaults to the identity function and **y** defaults to null, assuming that *data* is an array of numbers [*x₀*, *x₁*,
*x₂*, …].

[Options](#vectorx-options).

### vector_y

`vector_y(data=None, **options)`

Like vector, but **y** instead defaults to the identity function and **x** defaults to null, assuming that *data* is an array of numbers [*y₀*, *y₁*,
*y₂*, …].

[Options](#vectory-options).

### spike

`spike(data=None, **options)`

Like vector, but with default *options* suitable for drawing a spike map.

[Options](#spike-options).

## Waffle

### waffle_x

`waffle_x(data=None, **options)`

A horizontal waffle mark. The required *x* values should be quantitative, and the optional *y* values should be ordinal.

If neither **x1** nor **x2** nor **interval** is specified, an implicit stackX transform is applied and **x** defaults to the identity function, assuming that *data* = [*x₀*, *x₁*, *x₂*, …]. Otherwise if an **interval** is specified, then **x1** and **x2** are derived from **x**, representing the lower and upper bound of the containing interval, respectively. Otherwise, if only one of **x1** or **x2** is specified, the other defaults to **x**, which defaults to zero.

The optional **y** ordinal channel specifies the vertical position; it is typically bound to the *y* scale, which must be a *band* scale. If the
**y** channel is not specified, the bar will span the vertical extent of the plot’s frame. Because a waffle represents a discrete number of square cells, it may not use all of the available bandwidth.

[Options](#wafflex-options).

### waffle_y

`waffle_y(data=None, **options)`

A vertical waffle mark. The required *y* values should be quantitative, and the optional *x* values should be ordinal.

If neither **y1** nor **y2** nor **interval** is specified, an implicit stackY transform is applied and **y** defaults to the identity function, assuming that *data* = [*y₀*, *y₁*, *y₂*, …]. Otherwise if an **interval** is specified, then **y1** and **y2** are derived from **y**, representing the lower and upper bound of the containing interval, respectively. Otherwise, if only one of **y1** or **y2** is specified, the other defaults to **y**, which defaults to zero.

The optional **x** ordinal channel specifies the horizontal position; it is typically bound to the *x* scale, which must be a *band* scale. If the
**x** channel is not specified, the bar will span the horizontal extent of the plot’s frame. Because a waffle represents a discrete number of square cells, it may not use all of the available bandwidth.

[Options](#waffley-options).

## Error Bar

### errorbar_x

`errorbar_x(data=None, **options)`

A mark that draws error bars for a calculated parametric confidence interval for a dependent variable (*x*), potentially grouped by an independent variable (*y*).

This mark aggregates raw values to produce a [parametric confidence interval](https://en.wikipedia.org/wiki/Normal_distribution#Confidence_intervals) of the mean, assuming a normal distribution. To instead visualize pre-computed interval values or custom aggregations, use a **ruleY** mark with specified **x1** and **x2** channels.

Multiple error bars can be produced by specifying a **z** or **stroke** channel. Set the **marker** option to `'tick'` to add small perpendicular lines at the start and end of the error interval.

[Options](#errorbarx-options).

### errorbar_y

`errorbar_y(data=None, **options)`

A mark that draws error bars for a calculated parametric confidence interval for a dependent variable (*y*), potentially grouped by an independent variable (*x*).

This mark aggregates raw values to produce a [parametric confidence interval](https://en.wikipedia.org/wiki/Normal_distribution#Confidence_intervals) of the mean, assuming a normal distribution. To instead visualize pre-computed interval values or custom aggregations, use a **ruleX** mark with specified **y1** and **y2** channels.

Multiple error bars can be produced by specifying a **z** or **stroke** channel. Set the **marker** option to `'tick'` to add small perpendicular lines at the start and end of the error interval.

[Options](#errorbary-options).

</template>

<LangError v-else :language="language" />

## basic mark options

Options use their wire names below; Python keyword names use snake_case. See [common mark options](../spec/common-marks#markoptions) for shared channels and styles.

### BarOptions options

Options for the barX and barY marks.

Extends [`MarkOptions`](../spec/common-marks#markoptions), [`InsetOptions`](../spec/common-marks#insetoptions), [`RectCornerOptions`](#rectcorneroptions-options), [`StackOptions`](../spec/common-marks#stackoptions).

**interval** (`Interval | ParamRef`) — How to convert a continuous value (**x** for barX, or **y** for barY) into an interval (**x1** and **x2** for barX, or **y1** and **y2** for barY); one of:

- a named time interval such as *day* (for date intervals)
- a number (for number intervals), defining intervals at integer multiples of *n*

Setting this option disables the implicit stack transform (stackX for barX, or stackY for barY).

### BarXOptions options

Options for the barX mark.

Extends [`BarOptions`](#baroptions-options).

**x** (`ChannelValueIntervalSpec`) — The horizontal position (or length/width) channel, typically bound to the
*x* scale.

If neither **x1** nor **x2** nor **interval** is specified, an implicit stackX transform is applied and **x** defaults to the identity function, assuming that *data* = [*x₀*, *x₁*, *x₂*, …]. Otherwise if an **interval** is specified, then **x1** and **x2** are derived from **x**, representing the lower and upper bound of the containing interval, respectively. Otherwise, if only one of **x1** or **x2** is specified, the other defaults to **x**, which defaults to zero.

**x1** (`ChannelValueSpec`) — The required primary (starting, often left) horizontal position channel, typically bound to the *x* scale. Setting this option disables the implicit stackX transform.

If *x* represents ordinal values, use a cell mark instead.

**x2** (`ChannelValueSpec`) — The required secondary (ending, often right) horizontal position channel, typically bound to the *x* scale. Setting this option disables the implicit stackX transform.

If *x* represents ordinal values, use a cell mark instead.

**y** (`ChannelValueSpec`) — The optional vertical position of the bar; a ordinal channel typically bound to the *y* scale. If not specified, the bar spans the vertical extent of the frame; otherwise the *y* scale must be a *band* scale.

If *y* represents quantitative or temporal values, use a rectX mark instead.

### BarYOptions options

Options for the barY mark.

Extends [`BarOptions`](#baroptions-options).

**y** (`ChannelValueIntervalSpec`) — The vertical position (or length/height) channel, typically bound to the
*y* scale.

If neither **y1** nor **y2** nor **interval** is specified, an implicit stackY transform is applied and **y** defaults to the identity function, assuming that *data* = [*y₀*, *y₁*, *y₂*, …]. Otherwise if an **interval** is specified, then **y1** and **y2** are derived from **y**, representing the lower and upper bound of the containing interval, respectively. Otherwise, if only one of **y1** or **y2** is specified, the other defaults to **y**, which defaults to zero.

**y1** (`ChannelValueSpec`) — The required primary (starting, often bottom) vertical position channel, typically bound to the *y* scale. Setting this option disables the implicit stackY transform.

If *y* represents ordinal values, use a cell mark instead.

**y2** (`ChannelValueSpec`) — The required secondary (ending, often top) horizontal position channel, typically bound to the *y* scale. Setting this option disables the implicit stackY transform.

If *y* represents ordinal values, use a cell mark instead.

**x** (`ChannelValueSpec`) — The optional horizontal position of the bar; a ordinal channel typically bound to the *x* scale. If not specified, the bar spans the horizontal extent of the frame; otherwise the *x* scale must be a *band* scale.

If *x* represents quantitative or temporal values, use a rectY mark instead.

### BarX options

Extends [`MarkData`](../spec/common-marks#markdata), [`BarXOptions`](#barxoptions-options).


### BarY options

Extends [`MarkData`](../spec/common-marks#markdata), [`BarYOptions`](#baryoptions-options).


### CellOptions options

Options for the cell mark.

Extends [`MarkOptions`](../spec/common-marks#markoptions), [`InsetOptions`](../spec/common-marks#insetoptions), [`RectCornerOptions`](#rectcorneroptions-options).

**x** (`ChannelValueSpec`) — The horizontal position of the cell; an optional ordinal channel typically bound to the *x* scale. If not specified, the cell spans the horizontal extent of the frame; otherwise the *x* scale must be a *band* scale.

If *x* represents quantitative or temporal values, use a barX mark instead; if *y* is also quantitative or temporal, use a rect mark.

**y** (`ChannelValueSpec`) — The vertical position of the cell; an optional ordinal channel typically bound to the *y* scale. If not specified, the cell spans the vertical extent of the frame; otherwise the *y* scale must be a *band* scale.

If *y* represents quantitative or temporal values, use a barY mark instead; if *x* is also quantitative or temporal, use a rect mark.

### Cell options

Extends [`MarkData`](../spec/common-marks#markdata), [`CellOptions`](#celloptions-options).


### CellX options

Extends [`MarkData`](../spec/common-marks#markdata), [`CellOptions`](#celloptions-options).


### CellY options

Extends [`MarkData`](../spec/common-marks#markdata), [`CellOptions`](#celloptions-options).


### DotOptions options

Options for the dot mark.

Extends [`MarkOptions`](../spec/common-marks#markoptions).

**x** (`ChannelValueSpec`) — The horizontal position channel specifying the dot’s center, typically bound to the *x* scale.

**y** (`ChannelValueSpec`) — The vertical position channel specifying the dot’s center, typically bound to the *y* scale.

**z** (`ChannelValue`) — An optional ordinal channel for grouping data into series.

**r** (`ChannelValueSpec | number | ParamRef`) — The radius of dots; either a channel or constant. When a number, it is interpreted as a constant radius in pixels. Otherwise it is interpreted as a channel, typically bound to the *r* channel, which defaults to the *sqrt* type for proportional symbols. The radius defaults to 4.5 pixels when using the **symbol** channel, and otherwise 3 pixels. Dots with a nonpositive radius are not drawn.

**rotate** (`ChannelValue | number | ParamRef`) — The rotation angle of dots in degrees clockwise; either a channel or a constant. When a number, it is interpreted as a constant; otherwise it is interpreted as a channel. Defaults to 0°, pointing up.

**symbol** (`ChannelValueSpec | SymbolType | ParamRef`) — The categorical symbol; either a channel or a constant. A constant symbol can be specified by a valid symbol name such as *star*, or a symbol object (implementing the draw method); otherwise it is interpreted as a channel. Defaults to *circle* for the **dot** mark, and *hexagon* for the
**hexagon** mark.

If the **symbol** channel’s values are all symbols, symbol names, or nullish, the channel is unscaled (values are interpreted literally); otherwise, the channel is bound to the *symbol* scale.

**frameAnchor** (`FrameAnchor | ParamRef`) — The frame anchor specifies defaults for **x** and **y** based on the plot’s frame; it may be one of the four sides (*top*, *right*, *bottom*, *left*), one of the four corners (*top-left*, *top-right*, *bottom-right*,
*bottom-left*), or the *middle* of the frame. For example, for dots distributed horizontally at the top of the frame:

```js Plot.dot(data, {x: "date", frameAnchor: "top"}) ```

### DotXOptions options

Options for the dotX mark.

Extends [`Omit<DotOptions, 'y'>`](#dotoptions-options).

**y** (`ChannelValueIntervalSpec`) — The vertical position of the dot’s center, typically bound to the *y* scale.

**interval** (`Interval | ParamRef`) — An interval (such as *day* or a number), to transform **y** values to the middle of the interval.

### DotYOptions options

Options for the dotY mark.

Extends [`Omit<DotOptions, 'x'>`](#dotoptions-options).

**x** (`ChannelValueIntervalSpec`) — The horizontal position of the dot’s center, typically bound to the *x* scale.

**interval** (`Interval | ParamRef`) — An interval (such as *day* or a number), to transform **x** values to the middle of the interval.

### Dot options

Extends [`MarkData`](../spec/common-marks#markdata), [`DotOptions`](#dotoptions-options).


### DotX options

Extends [`MarkData`](../spec/common-marks#markdata), [`DotXOptions`](#dotxoptions-options).


### DotY options

Extends [`MarkData`](../spec/common-marks#markdata), [`DotYOptions`](#dotyoptions-options).


### Circle options

Extends [`MarkData`](../spec/common-marks#markdata), [`Exclude<DotOptions, 'symbol'>`](#dotoptions-options).


### Hexagon options

Extends [`MarkData`](../spec/common-marks#markdata), [`Exclude<DotOptions, 'symbol'>`](#dotoptions-options).


### RectCornerOptions options

Options for marks that render rectangles, including bar, cell, and rect.

**rx** (`number | string | ParamRef`) — The rounded corner [*x*-radius](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/rx), either in pixels or as a percentage of the rect width. If **rx** is not specified, it defaults to **ry** if present, and otherwise draws square corners.

**ry** (`number | string | ParamRef`) — The rounded corner [*y*-radius](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/ry), either in pixels or as a percentage of the rect height. If **ry** is not specified, it defaults to **rx** if present, and otherwise draws square corners.

### RectOptions options

Options for the rect mark.

Extends [`MarkOptions`](../spec/common-marks#markoptions), [`InsetOptions`](../spec/common-marks#insetoptions), [`RectCornerOptions`](#rectcorneroptions-options), [`StackOptions`](../spec/common-marks#stackoptions).

**x** (`ChannelValueIntervalSpec`) — The horizontal position (or length/width) channel, typically bound to the
*x* scale.

If an **interval** is specified, then **x1** and **x2** are derived from
**x**, representing the lower and upper bound of the containing interval, respectively. For example, for a vertical bar chart of items sold by day:

```js Plot.rectY(sales, {x: "date", interval: "day", y2: "items"}) ```

If *x* represents ordinal values, use a bar or cell mark instead.

**x1** (`ChannelValueSpec`) — The required primary (starting, often left) horizontal position channel, typically bound to the *x* scale. Setting this option disables the rectX mark’s implicit stackX transform.

If *x* represents ordinal values, use a bar or cell mark instead.

**x2** (`ChannelValueSpec`) — The required secondary (ending, often right) horizontal position channel, typically bound to the *x* scale. Setting this option disables the rectX mark’s implicit stackX transform.

If *x* represents ordinal values, use a bar or cell mark instead.

**y** (`ChannelValueIntervalSpec`) — The vertical position (or length/height) channel, typically bound to the
*y* scale.

If an **interval** is specified, then **y1** and **y2** are derived from
**y**, representing the lower and upper bound of the containing interval, respectively. For example, for a horizontal bar chart of items sold by day:

```js Plot.rectX(sales, {y: "date", interval: "day", x2: "items"}) ```

If *y* represents ordinal values, use a bar or cell mark instead.

**y1** (`ChannelValueSpec`) — The required primary (starting, often bottom) vertical position channel, typically bound to the *y* scale. Setting this option disables the rectY mark’s implicit stackY transform.

If *y* represents ordinal values, use a bar or cell mark instead.

**y2** (`ChannelValueSpec`) — The required secondary (ending, often top) vertical position channel, typically bound to the *y* scale. Setting this option disables the rectY mark’s implicit stackY transform.

If *y* represents ordinal values, use a bar or cell mark instead.

**interval** (`Interval | ParamRef`) — How to convert a continuous value (**x** for rectY, **y** for rectX, or both for rect) into an interval (**x1** and **x2** for rectY, or **y1** and
**y2** for rectX, or both for rect); one of:

- a named time interval such as *day* (for date intervals)
- a number (for number intervals), defining intervals at integer multiples of *n*

Setting this option disables the implicit stack transform (stackX for rectX, or stackY for rectY).

### RectXOptions options

Options for the rectX mark.

Extends [`RectOptions`](#rectoptions-options).

**x** (`ChannelValueSpec`) — The horizontal position (or length/width) channel, typically bound to the
*x* scale.

If neither **x1** nor **x2** is specified, an implicit stackX transform is applied and **x** defaults to the identity function, assuming that *data* = [*x₀*, *x₁*, *x₂*, …]. Otherwise, if only one of **x1** or **x2** is specified, the other defaults to **x**, which defaults to zero.

### RectYOptions options

Options for the rectY mark.

Extends [`RectOptions`](#rectoptions-options).

**y** (`ChannelValueSpec`) — The vertical position (or length/height) channel, typically bound to the
*y* scale.

If neither **y1** nor **y2** is specified, an implicit stackY transform is applied and **y** defaults to the identity function, assuming that *data* = [*y₀*, *y₁*, *y₂*, …]. Otherwise, if only one of **y1** or **y2** is specified, the other defaults to **y**, which defaults to zero.

### Rect options

Extends [`MarkData`](../spec/common-marks#markdata), [`RectOptions`](#rectoptions-options).


### RectX options

Extends [`MarkData`](../spec/common-marks#markdata), [`RectXOptions`](#rectxoptions-options).


### RectY options

Extends [`MarkData`](../spec/common-marks#markdata), [`RectYOptions`](#rectyoptions-options).


### RuleOptions options

Options for the ruleX and ruleY marks.

Extends [`MarkOptions`](../spec/common-marks#markoptions), [`MarkerOptions`](../spec/common-marks#markeroptions).

**interval** (`Interval | ParamRef`) — How to convert a continuous value (**y** for ruleX, or **x** for ruleY) into an interval (**y1** and **y2** for ruleX, or **x1** and **x2** for ruleY); one of:

- a named time interval such as *day* (for date intervals)
- a number (for number intervals), defining intervals at integer multiples of *n*

### RuleXOptions options

Options for the ruleX mark.

Extends [`RuleOptions`](#ruleoptions-options), [`Omit<InsetOptions, 'insetLeft' | 'insetRight'>`](../spec/common-marks#insetoptions).

**x** (`ChannelValueSpec`) — The horizontal position of the tick; an optional channel bound to the *x* scale. If not specified, the rule will be horizontally centered in the plot’s frame.

**y** (`ChannelValueIntervalSpec`) — Shorthand for specifying both the primary and secondary vertical position of the tick as the bounds of the containing interval; can only be used in conjunction with the **interval** option.

**y1** (`ChannelValueSpec`) — The primary (starting, often bottom) vertical position of the tick; a channel bound to the *y* scale.

If *y* represents ordinal values, use a tickX mark instead.

**y2** (`ChannelValueSpec`) — The secondary (ending, often top) vertical position of the tick; a channel bound to the *y* scale.

If *y* represents ordinal values, use a tickX mark instead.

### RuleYOptions options

Options for the ruleY mark.

Extends [`RuleOptions`](#ruleoptions-options), [`Omit<InsetOptions, 'insetTop' | 'insetBottom'>`](../spec/common-marks#insetoptions).

**x** (`ChannelValueIntervalSpec`) — Shorthand for specifying both the primary and secondary horizontal position of the tick as the bounds of the containing interval; can only be used in conjunction with the **interval** option.

**x1** (`ChannelValueSpec`) — The primary (starting, often left) horizontal position of the tick; a channel bound to the *x* scale.

If *x* represents ordinal values, use a tickY mark instead.

**x2** (`ChannelValueSpec`) — The secondary (ending, often right) horizontal position of the tick; a channel bound to the *x* scale.

If *x* represents ordinal values, use a tickY mark instead.

**y** (`ChannelValueSpec`) — The vertical position of the tick; an optional channel bound to the *y* scale. If not specified, the rule will be vertically centered in the plot’s frame.

### RuleX options

Extends [`MarkDataOptional`](../spec/common-marks#markdataoptional), [`RuleXOptions`](#rulexoptions-options).


### RuleY options

Extends [`MarkDataOptional`](../spec/common-marks#markdataoptional), [`RuleXOptions`](#rulexoptions-options).


### TickXOptions options

Options for the tickX mark.

Extends [`MarkOptions`](../spec/common-marks#markoptions), [`MarkerOptions`](../spec/common-marks#markeroptions), [`Omit<InsetOptions, 'insetLeft' | 'insetRight'>`](../spec/common-marks#insetoptions).

**x** (`ChannelValueSpec`) — The required horizontal position of the tick; a channel typically bound to the *x* scale.

**y** (`ChannelValueSpec`) — The optional vertical position of the tick; an ordinal channel typically bound to the *y* scale. If not specified, the tick spans the vertical extent of the frame; otherwise the *y* scale must be a *band* scale.

If *y* represents quantitative or temporal values, use a ruleX mark instead.

### TickYOptions options

Options for the tickY mark.

Extends [`MarkOptions`](../spec/common-marks#markoptions), [`MarkerOptions`](../spec/common-marks#markeroptions), [`Omit<InsetOptions, 'insetTop' | 'insetBottom'>`](../spec/common-marks#insetoptions).

**y** (`ChannelValueSpec`) — The required vertical position of the tick; a channel typically bound to the *y* scale.

**x** (`ChannelValueSpec`) — The optional horizontal position of the tick; an ordinal channel typically bound to the *x* scale. If not specified, the tick spans the horizontal extent of the frame; otherwise the *x* scale must be a *band* scale.

If *x* represents quantitative or temporal values, use a ruleY mark instead.

### TickX options

Extends [`MarkData`](../spec/common-marks#markdata), [`TickXOptions`](#tickxoptions-options).


### TickY options

Extends [`MarkData`](../spec/common-marks#markdata), [`TickYOptions`](#tickyoptions-options).


**`ruleY`:** **RuleY limitation:** its wire contract inherits RuleXOptions, admitting y1/y2 and top/bottom insets instead of horizontal endpoints. Native JavaScript supports x1/x2.

**`circle`, `hexagon`:** Circle and hexagon force their named geometry, even when a symbol option is supplied.

**`barX`, `barY`, `dotX`, `dotY`, `rect`, `rectX`, `rectY`, `ruleX`, `ruleY`:** Numeric intervals work in TypeScript and native JavaScript. For declarative intervals, bind a named parameter containing a time interval string; a literal string such as `day` is interpreted as a SQL field by the mark runtime.

**`barX`, `barY`, `cell`, `cellX`, `cellY`, `rect`, `rectX`, `rectY`, `dot`, `dotX`, `dotY`, `circle`, `hexagon`, `tickX`, `tickY`:** The wire format requires data for these marks. Python defaults data to None; the JavaScript options-only overload supplies one empty row.

### basic examples

`dot`: [json](/templates/marks/basic/dot.json) · [yaml](/templates/marks/basic/dot.yaml) · [js](/templates/marks/basic/dot.js) · <a :href="withBase('/templates/marks/basic/dot.py')" download>Python</a>.

## connected mark options

Options use their wire names below; Python keyword names use snake_case. See [common mark options](../spec/common-marks#markoptions) for shared channels and styles.

### AreaOptions options

Options for the area, areaX, and areaY marks.

Extends [`MarkOptions`](../spec/common-marks#markoptions), [`StackOptions`](../spec/common-marks#stackoptions), [`CurveOptions`](../spec/common-marks#curveoptions).

**x1** (`ChannelValueSpec`) — The required primary (starting, often left) horizontal position channel, representing the area’s baseline, typically bound to the *x* scale. For areaX, setting this option disables the implicit stackX transform.

**x2** (`ChannelValueSpec`) — The optional secondary (ending, often right) horizontal position channel, representing the area’s topline, typically bound to the *x* scale; if not specified, **x1** is used. For areaX, setting this option disables the implicit stackX transform.

**y1** (`ChannelValueSpec`) — The required primary (starting, often bottom) vertical position channel, representing the area’s baseline, typically bound to the *y* scale. For areaY, setting this option disables the implicit stackY transform.

**y2** (`ChannelValueSpec`) — The optional secondary (ending, often top) vertical position channel, representing the area’s topline, typically bound to the *y* scale; if not specified, **y1** is used. For areaY, setting this option disables the implicit stackY transform.

**z** (`ChannelValue`) — An optional ordinal channel for grouping data into (possibly stacked) series to be drawn as separate areas; defaults to **fill** if a channel, or
**stroke** if a channel.

### AreaXOptions options

Options for the areaX mark.

Extends [`Omit<AreaOptions, 'y1' | 'y2'>`](#areaoptions-options).

**x** (`ChannelValueSpec`) — The horizontal position (or length) channel, typically bound to the *x* scale.

If neither **x1** nor **x2** is specified, an implicit stackX transform is applied and **x** defaults to the identity function, assuming that *data* = [*x₀*, *x₁*, *x₂*, …]. Otherwise, if only one of **x1** or **x2** is specified, the other defaults to **x**, which defaults to zero.

**y** (`ChannelValueSpec`) — The vertical position channel, typically bound to the *y* scale; defaults to the zero-based index of the data [0, 1, 2, …].

### AreaYOptions options

Options for the areaY mark.

Extends [`Omit<AreaOptions, 'x1' | 'x2'>`](#areaoptions-options).

**x** (`ChannelValueSpec`) — The horizontal position channel, typically bound to the *x* scale; defaults to the zero-based index of the data [0, 1, 2, …].

**y** (`ChannelValueSpec`) — The vertical position (or length) channel, typically bound to the *y* scale.

If neither **y1** nor **y2** is specified, an implicit stackY transform is applied and **y** defaults to the identity function, assuming that *data* = [*y₀*, *y₁*, *y₂*, …]. Otherwise, if only one of **y1** or **y2** is specified, the other defaults to **y**, which defaults to zero.

### Area options

Extends [`MarkData`](../spec/common-marks#markdata), [`AreaOptions`](#areaoptions-options).


### AreaX options

Extends [`MarkData`](../spec/common-marks#markdata), [`AreaXOptions`](#areaxoptions-options).


### AreaY options

Extends [`MarkData`](../spec/common-marks#markdata), [`AreaYOptions`](#areayoptions-options).


### LineOptions options

Options for the line mark.

Extends [`MarkOptions`](../spec/common-marks#markoptions), [`MarkerOptions`](../spec/common-marks#markeroptions), [`CurveAutoOptions`](../spec/common-marks#curveautooptions).

**x** (`ChannelValueSpec`) — The required horizontal position channel, typically bound to the *x* scale.

**y** (`ChannelValueSpec`) — The required vertical position channel, typically bound to the *y* scale.

**z** (`ChannelValue`) — An optional ordinal channel for grouping data into (possibly stacked) series to be drawn as separate lines. If not specified, it defaults to
**fill** if a channel, or **stroke** if a channel.

### LineXOptions options

Options for the lineX mark.

Extends [`LineOptions`](#lineoptions-options).

**y** (`ChannelValueSpec`) — The vertical position channel, typically bound to the *y* scale; defaults to the zero-based index of the data [0, 1, 2, …].

### LineYOptions options

Options for the lineY mark.

Extends [`LineOptions`](#lineoptions-options).

**x** (`ChannelValueSpec`) — The horizontal position channel, typically bound to the *x* scale; defaults to the zero-based index of the data [0, 1, 2, …].

### Line options

Extends [`MarkData`](../spec/common-marks#markdata), [`LineOptions`](#lineoptions-options).


### LineX options

Extends [`MarkData`](../spec/common-marks#markdata), [`LineXOptions`](#linexoptions-options).


### LineY options

Extends [`MarkData`](../spec/common-marks#markdata), [`LineYOptions`](#lineyoptions-options).


### ArrowOptions options

Options for the arrow mark.

Extends [`MarkOptions`](../spec/common-marks#markoptions).

**x** (`ChannelValueSpec`) — The horizontal position, for vertical arrows; typically bound to the *x* scale; shorthand for setting defaults for both **x1** and **x2**.

**y** (`ChannelValueSpec`) — The vertical position, for horizontal arrows; typically bound to the *y* scale; shorthand for setting defaults for both **y1** and **y2**.

**x1** (`ChannelValueSpec`) — The starting horizontal position; typically bound to the *x* scale; also sets a default for **x2**.

**y1** (`ChannelValueSpec`) — The starting vertical position; typically bound to the *y* scale; also sets a default for **y2**.

**x2** (`ChannelValueSpec`) — The ending horizontal position; typically bound to the *x* scale; also sets a default for **x1**.

**y2** (`ChannelValueSpec`) — The ending vertical position; typically bound to the *y* scale; also sets a default for **y1**.

**bend** (`number | boolean | ParamRef`) — The angle, a constant in degrees, between the straight line intersecting the arrow’s two control points and the outgoing tangent direction of the arrow from the start point. The angle must be within ±90°; a positive angle will produce a clockwise curve, while a negative angle will produce a counterclockwise curve; zero (the default) will produce a straight line. Use true for 22.5°.

**headAngle** (`number | ParamRef`) — How pointy the arrowhead is, in degrees; a constant typically between 0° and 180°, and defaults to 60°.

**headLength** (`number | ParamRef`) — The size of the arrowhead relative to the **strokeWidth**; a constant. Assuming the default of stroke width 1.5px, this is the length of the arrowhead’s side in pixels.

**inset** (`number | ParamRef`) — Shorthand to set the same default for **insetStart** and **insetEnd**.

**insetStart** (`number | ParamRef`) — The starting inset, a constant in pixels; defaults to 0. A positive inset shortens the arrow by moving the starting point towards the endpoint point, while a negative inset extends it by moving the starting point in the opposite direction. A positive starting inset may be useful if the arrow emerges from a dot.

**insetEnd** (`number | ParamRef`) — The ending inset, a constant in pixels; defaults to 0. A positive inset shortens the arrow by moving the ending point towards the starting point, while a negative inset extends it by moving the ending point in the opposite direction. A positive ending inset may be useful if the arrow points to a dot.

**sweep** (`number | '+x' | '-x' | '+y' | '-y' | ParamRef`) — The sweep order; defaults to 1 indicating a positive (clockwise) bend angle; -1 indicates a negative (anticlockwise) bend angle; 0 effectively clears the bend angle. If set to *-x*, the bend angle is flipped when the ending point is to the left of the starting point — ensuring all arrows bulge up (down if bend is negative); if set to *-y*, the bend angle is flipped when the ending point is above the starting point — ensuring all arrows bulge right (left if bend is negative); the sign is negated for
*+x* and *+y*.

### Arrow options

Extends [`MarkData`](../spec/common-marks#markdata), [`ArrowOptions`](#arrowoptions-options).


### LinkOptions options

Options for the link mark.

Extends [`MarkOptions`](../spec/common-marks#markoptions), [`MarkerOptions`](../spec/common-marks#markeroptions), [`CurveAutoOptions`](../spec/common-marks#curveautooptions).

**x** (`ChannelValueSpec`) — The horizontal position, for vertical links; typically bound to the *x* scale; shorthand for setting defaults for both **x1** and **x2**.

**y** (`ChannelValueSpec`) — The vertical position, for horizontal links; typically bound to the *y* scale; shorthand for setting defaults for both **y1** and **y2**.

**x1** (`ChannelValueSpec`) — The starting horizontal position; typically bound to the *x* scale; also sets a default for **x2**.

**y1** (`ChannelValueSpec`) — The starting vertical position; typically bound to the *y* scale; also sets a default for **y2**.

**x2** (`ChannelValueSpec`) — The ending horizontal position; typically bound to the *x* scale; also sets a default for **x1**.

**y2** (`ChannelValueSpec`) — The ending vertical position; typically bound to the *y* scale; also sets a default for **y1**.

**curve** (`CurveAutoOptions['curve'] | ParamRef`) — The curve (interpolation) method for connecting adjacent points.

Since a link has exactly two points, only the following curves (or a custom curve) are recommended: *linear*, *step*, *step-after*, *step-before*,
*bump-x*, or *bump-y*. Note that the *linear* curve is incapable of showing a fill since a straight line has zero area. For a curved link, use an arrow mark with the **bend** option.

If the plot uses a spherical **projection**, the default *auto* **curve** will render links as geodesics; to draw a straight line instead, use the
*linear* **curve**.

### Link options

Extends [`MarkData`](../spec/common-marks#markdata), [`LinkOptions`](#linkoptions-options).


**`arrow`:** Directional sweep strings (`+x`, `-x`, `+y`, `-y`) are admitted by the specification, but the current SQL-backed runtime interprets them as column names. A missing matching column produces a Binder Error. Use numeric `sweep` values for SQL-backed arrows; the bent-arrow starter uses `1`.

### connected examples

`line`: [json](/templates/marks/connected/line.json) · [yaml](/templates/marks/connected/line.yaml) · [js](/templates/marks/connected/line.js) · <a :href="withBase('/templates/marks/connected/line.py')" download>Python</a>.

JavaScript-only `native-curve`: [js](/templates/marks/connected/native-curve.js).

## annotation mark options

Options use their wire names below; Python keyword names use snake_case. See [common mark options](../spec/common-marks#markoptions) for shared channels and styles.

### TextOptions options

Options for the text mark.

Extends [`MarkOptions`](../spec/common-marks#markoptions), [`TextStyles`](../spec/common-marks#textstyles).

**x** (`ChannelValueSpec`) — The horizontal position channel specifying the text’s anchor point, typically bound to the *x* scale.

**y** (`ChannelValueSpec`) — The vertical position channel specifying the text’s anchor point, typically bound to the *y* scale.

**z** (`ChannelValue`) — An optional ordinal channel for grouping data into series.

**text** (`ChannelValue`) — The text contents channel, possibly with line breaks (\n, \r\n, or \r). If not specified, defaults to the zero-based index [0, 1, 2, …].

**frameAnchor** (`FrameAnchor | ParamRef`) — The frame anchor specifies defaults for **x** and **y**, along with
**textAnchor** and **lineAnchor**, based on the plot’s frame; it may be one of the four sides (*top*, *right*, *bottom*, *left*), one of the four corners (*top-left*, *top-right*, *bottom-right*, *bottom-left*), or the
*middle* of the frame.

**lineAnchor** (`'top' | 'middle' | 'bottom' | ParamRef`) — The line anchor controls how text is aligned (typically vertically) relative to its anchor point; it is one of *top*, *bottom*, or *middle*. If the frame anchor is *top*, *top-left*, or *top-right*, the default line anchor is *top*; if the frame anchor is *bottom*, *bottom-right*, or
*bottom-left*, the default is *bottom*; otherwise it is *middle*.

**rotate** (`ChannelValue | ParamRef`) — The rotation angle in degrees clockwise; a constant or a channel; defaults to 0°. When a number, it is interpreted as a constant; otherwise it is interpreted as a channel.

### TextXOptions options

Options for the textX mark.

Extends [`Omit<TextOptions, 'y'>`](#textoptions-options).

**y** (`ChannelValueIntervalSpec`) — The vertical position of the text’s anchor point, typically bound to the
*y* scale.

**interval** (`Interval | ParamRef`) — An interval (such as *day* or a number), to transform **y** values to the middle of the interval.

### TextYOptions options

Options for the textY mark.

Extends [`Omit<TextOptions, 'x'>`](#textoptions-options).

**x** (`ChannelValueIntervalSpec`) — The horizontal position of the text’s anchor point, typically bound to the
*x* scale.

**interval** (`Interval`) — An interval (such as *day* or a number), to transform **x** values to the middle of the interval.

### Text options

Extends [`MarkDataOptional`](../spec/common-marks#markdataoptional), [`TextOptions`](#textoptions-options).


### TextX options

Extends [`MarkDataOptional`](../spec/common-marks#markdataoptional), [`TextXOptions`](#textxoptions-options).


### TextY options

Extends [`MarkDataOptional`](../spec/common-marks#markdataoptional), [`TextYOptions`](#textyoptions-options).


### ImageOptions options

Options for the image mark.

Extends [`MarkOptions`](../spec/common-marks#markoptions).

**x** (`ChannelValueSpec`) — The horizontal position channel specifying the image’s center; typically bound to the *x* scale.

**y** (`ChannelValueSpec`) — The vertical position channel specifying the image’s center; typically bound to the *y* scale.

**width** (`ChannelValue | ParamRef`) — The image width in pixels. When a number, it is interpreted as a constant radius in pixels; otherwise it is interpreted as a channel. Also sets the default **height**; if neither are set, defaults to 16. Images with a nonpositive width are not drawn.

**height** (`ChannelValue | ParamRef`) — The image height in pixels. When a number, it is interpreted as a constant radius in pixels; otherwise it is interpreted as a channel. Also sets the default **height**; if neither are set, defaults to 16. Images with a nonpositive height are not drawn.

**r** (`ChannelValue | ParamRef`) — The image clip radius, for circular images. If null (default), images are not clipped; when a number, it is interpreted as a constant in pixels; otherwise it is interpreted as a channel, typically bound to the *r* scale. Also defaults **height** and **width** to twice its value.

**rotate** (`ChannelValue | ParamRef`) — The rotation angle, in degrees clockwise. When a number, it is interpreted as a constant; otherwise it is interpreted as a channel.

**src** (`ChannelValue | ParamRef`) — The required image URL (or relative path). If a string that starts with a dot, slash, or URL protocol (*e.g.*, “https:”) it is assumed to be a constant; otherwise it is interpreted as a channel.

**preserveAspectRatio** (`string | ParamRef`) — The image [aspect ratio](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/preserveAspectRatio); defaults to *xMidYMid meet*. To crop the image instead of scaling it to fit, use *xMidYMid slice*.

**crossOrigin** (`string | ParamRef`) — The [cross-origin](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/crossorigin) behavior. See the [Plot.image notebook](https://observablehq.com/@observablehq/plot-image) for details.

**frameAnchor** (`FrameAnchor | ParamRef`) — The frame anchor specifies defaults for **x** and **y** based on the plot’s frame; it may be one of the four sides (*top*, *right*, *bottom*, *left*), one of the four corners (*top-left*, *top-right*, *bottom-right*,
*bottom-left*), or the *middle* of the frame.

**imageRendering** (`string | ParamRef`) — The [image-rendering attribute](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/image-rendering); defaults to *auto* (bilinear). The option may be set to *pixelated* to disable bilinear interpolation for a sharper image; however, note that this is not supported in WebKit.

### Image options

Extends [`MarkData`](../spec/common-marks#markdata), [`ImageOptions`](#imageoptions-options).


### VectorOptions options

Options for the vector mark.

Extends [`MarkOptions`](../spec/common-marks#markoptions).

**x** (`ChannelValueSpec`) — The horizontal position of the vector’s anchor point; an optional channel bound to the *x* scale. Default depends on the **frameAnchor**.

**y** (`ChannelValueSpec`) — The vertical position of the vector’s anchor point; an optional channel bound to the *y* scale. Default depends on the **frameAnchor**.

**r** (`number | ParamRef`) — The vector shape’s radius, such as half the width of the *arrow*’s head or the *spike*’s base; a constant number in pixels. Defaults to 3.5 pixels.

**length** (`ChannelValueSpec`) — The vector’s length; either an optional channel bound to the *length* scale or a constant number in pixels. Defaults to 12 pixels.

**rotate** (`ChannelValue`) — The vector’s orientation (rotation angle); either a constant number in degrees clockwise, or an optional channel (with no associated scale). Defaults to 0 degrees with the vector pointing up.

**shape** (`VectorShape | ParamRef`) — The shape of the vector; a constant. Defaults to *arrow*.

**anchor** (`'start' | 'middle' | 'end' | ParamRef`) — The vector’s position along its orientation relative to its anchor point; a constant. Assuming a default **rotate** angle of 0°, one of:

- *start* - from [*x*, *y*] to [*x*, *y* - *l*]
- *middle* (default) - from [*x*, *y* + *l* / 2] to [*x*, *y* - *l* / 2]
- *end* - from [*x*, *y* + *l*] to [*x*, *y*]

where [*x*, *y*] is the vector’s anchor point and *l* is the vector’s (possibly scaled) length in pixels.

**frameAnchor** (`FrameAnchor | ParamRef`) — The vector’s frame anchor, to default **x** and **y** relative to the frame; a constant representing one of the frame corners (*top-left*,
*top-right*, *bottom-right*, *bottom-left*), sides (*top*, *right*,
*bottom*, *left*), or *middle* (default). Has no effect if both **x** and **y** are specified.

### Vector options

Extends [`MarkData`](../spec/common-marks#markdata), [`VectorOptions`](#vectoroptions-options).


### VectorX options

Extends [`MarkData`](../spec/common-marks#markdata), [`VectorOptions`](#vectoroptions-options).


### VectorY options

Extends [`MarkData`](../spec/common-marks#markdata), [`VectorOptions`](#vectoroptions-options).


### Spike options

Extends [`MarkData`](../spec/common-marks#markdata), [`VectorOptions`](#vectoroptions-options).


### WaffleOptions options

Options for the waffleX and waffleY mark.

**multiple** (`number | ParamRef`) — The number of cells per row or column; defaults to undefined for automatic.

**unit** (`number | ParamRef`) — The quantity each cell represents; defaults to 1.

**gap** (`number | ParamRef`) — The gap in pixels between cells; defaults to 1.

**round** (`boolean | ParamRef`) — If true, round to integers to avoid partial cells.

### WaffleX options

Extends [`MarkData`](../spec/common-marks#markdata), [`BarXOptions`](#barxoptions-options), [`WaffleOptions`](#waffleoptions-options).


### WaffleY options

Extends [`MarkData`](../spec/common-marks#markdata), [`BarYOptions`](#baryoptions-options), [`WaffleOptions`](#waffleoptions-options).


### VectorShapeName options

```ts
type VectorShapeName = 'arrow' | 'spike';
```

### VectorShape options

```ts
type VectorShape = VectorShapeName;
```

**`vectorX`:** Known JavaScript limitation: vectorX dispatches to the misspelled vectoX runtime type and rendering raises TypeError. Declarative and Python APIs accept and serialize vectorX, but rendering uses the same JavaScript runtime.

**`vector`:** **Specification vocabulary: VectorShapeName**

The built-in vector shape implementations; one of:

- *arrow* - a straight line with an open arrowhead at the end (↑)
- *spike* - an isosceles triangle with a flat base (▲)

**Specification vocabulary: VectorShape**

How to draw a vector: either a named shape or a custom implementation.

### annotation examples

`multiline-text`: [json](/templates/marks/annotation/multiline-text.json) · [yaml](/templates/marks/annotation/multiline-text.yaml) · [js](/templates/marks/annotation/multiline-text.js) · <a :href="withBase('/templates/marks/annotation/multiline-text.py')" download>Python</a>.

## guides mark options

Options use their wire names below; Python keyword names use snake_case. See [common mark options](../spec/common-marks#markoptions) for shared channels and styles.

### ScaleOptions options

The scale options used by axis and grid marks.

**interval** (`Interval | ParamRef`) — Enforces uniformity for data at regular intervals, such as integer values or daily samples. The interval may be one of:

- a named time interval such as *day* (for date intervals)
- a number (for number intervals), defining intervals at integer multiples of *n*

This option sets the internal transform to the given interval’s
*interval*.floor function. In addition, the default **domain** will align with interval boundaries.

**ticks** (`number | Interval | Array<any> | ParamRef`) — The desired approximate number of axis ticks, or an explicit array of tick values, or an interval such as *day* or *month*.

**tickSize** (`number | ParamRef`) — The length of axis tick marks in pixels; negative values extend in the opposite direction. Defaults to 6 for *x* and *y* axes and *color* and
*opacity* *ramp* legends, and 0 for *fx* and *fy* axes.

**tickSpacing** (`number | ParamRef`) — The desired approximate spacing between adjacent axis ticks, affecting the default **ticks**; defaults to 80 pixels for *x* and *fx*, and 35 pixels for *y* and *fy*.

**tickPadding** (`number | ParamRef`) — The distance between an axis tick mark and its associated text label (in pixels); often defaults to 3, but may be affected by **xTickSize** and
**xTickRotate**.

**tickFormat** (`string | null | ParamRef`) — How to format inputs (abstract values) for axis tick labels; one of:

- a [d3-format](https://d3js.org/d3-time) string for numeric scales
- a [d3-time-format](https://d3js.org/d3-time-format) string for temporal scales

**tickRotate** (`number | ParamRef`) — The rotation angle of axis tick labels in degrees clocksize; defaults to 0.

**label** (`string | null | ParamRef`) — A textual label to show on the axis or legend; if null, show no label. By default the scale label is inferred from channel definitions, possibly with an arrow (↑, →, ↓, or ←) to indicate the direction of increasing value.

For axes and legends only.

**labelAnchor** (`'top' | 'right' | 'bottom' | 'left' | 'center' | ParamRef`) — Where to place the axis **label** relative to the plot’s frame. For vertical position scales (*y* and *fy*), may be *top*, *bottom*, or
*center*; for horizontal position scales (*x* and *fx*), may be *left*,
*right*, or *center*. Defaults to *center* for ordinal scales (including
*fx* and *fy*), and otherwise *top* for *y*, and *right* for *x*.

**labelOffset** (`number | ParamRef`) — The axis **label** position offset (in pixels); default depends on margins and orientation.

**labelArrow** (`'auto' | 'up' | 'right' | 'down' | 'left' | 'none' | true | false | null | ParamRef`) — Whether to apply a directional arrow such as → or ↑ to the scale label. If
*auto* (the default), the presence of the arrow depends on whether the scale is ordinal.

### GridOptions options

Options for the grid marks.

Extends [`GridScaleOptions`](#scaleoptions-options).

**anchor** (`'top' | 'right' | 'bottom' | 'left' | ParamRef`) — The side of the frame on which to place the axis: *top* or *bottom* for horizontal axes (axisX and axisFx) and their associated vertical grids (gridX and gridFx), or *left* or *right* for vertical axes (axisY and axisFY) and their associated horizontal grids (gridY and gridFy).

The default **anchor** depends on the associated scale:

- *x* - *bottom*
- *y* - *left*
- *fx* - *top* if there is a *bottom* *x* axis, and otherwise *bottom*
- *fy* - *right* if there is a *left* *y* axis, and otherwise *right*

For grids, the **anchor** also affects the extent of grid lines when the opposite dimension is specified (**x** for gridY and **y** for gridX).

**color** (`MarkOptions['stroke']`) — A shorthand for setting both **fill** and **stroke**; affects the stroke of tick vectors and grid rules, and the fill of tick texts and axis label texts; defaults to *currentColor*.

**opacity** (`MarkOptions['opacity']`) — A shorthand for setting both **fillOpacity** and **strokeOpacity**; affects the stroke opacity of tick vectors and grid rules, and the fill opacity of tick texts and axis label texts; defaults to 1 for axes and 0.1 for grids.

### AxisOptions options

Options for the axis marks.

Extends [`GridOptions`](#gridoptions-options), [`MarkOptions`](../spec/common-marks#markoptions), [`TextOptions`](#textoptions-options), [`AxisScaleOptions`](#scaleoptions-options).

**textStroke** (`MarkOptions['stroke']`) — The tick text **stroke**, say for a *white* outline to improve legibility; defaults to null.

**textStrokeOpacity** (`MarkOptions['strokeOpacity']`) — The tick text **strokeOpacity**; defaults to 1; has no effect unless **textStroke** is set.

**textStrokeWidth** (`MarkOptions['strokeWidth']`) — The tick text **strokeWidth**; defaults to 4; has no effect unless **textStroke** is set.

### AxisXOptions options

Options for the axisX and axisFx marks.

Extends [`AxisOptions`](#axisoptions-options), [`Omit<TickXOptions, 'data'>`](#tickxoptions-options).


### AxisYOptions options

Options for the axisY and axisFy marks.

Extends [`AxisOptions`](#axisoptions-options), [`Omit<TickYOptions, 'data'>`](#tickyoptions-options).


### GridXOptions options

Options for the gridX and gridFx marks.

Extends [`GridOptions`](#gridoptions-options), [`Omit<RuleXOptions, 'data' | 'interval'>`](#rulexoptions-options).


### GridYOptions options

Options for the gridY and gridFy marks.

Extends [`GridOptions`](#gridoptions-options), [`Omit<RuleYOptions, 'data' | 'interval'>`](#ruleyoptions-options).


### AxisX options

Extends [`AxisXOptions`](#axisxoptions-options).


### AxisFx options

Extends [`AxisXOptions`](#axisxoptions-options).


### AxisY options

Extends [`AxisYOptions`](#axisyoptions-options).


### AxisFy options

Extends [`AxisYOptions`](#axisyoptions-options).


### GridX options

Extends [`GridXOptions`](#gridxoptions-options).


### GridFx options

Extends [`GridXOptions`](#gridxoptions-options).


### GridY options

Extends [`GridYOptions`](#gridyoptions-options).


### GridFy options

Extends [`GridYOptions`](#gridyoptions-options).


### FrameOptions options

Options for the frame decoration mark.

Extends [`MarkOptions`](../spec/common-marks#markoptions), [`InsetOptions`](../spec/common-marks#insetoptions), [`RectCornerOptions`](#rectcorneroptions-options).

**anchor** (`'top' | 'right' | 'bottom' | 'left' | null | ParamRef`) — If null (default), the rectangular outline of the frame is drawn; otherwise the frame is drawn as a line only on the given side, and the
**rx**, **ry**, **fill**, and **fillOpacity** options are ignored.

### Frame options

Extends [`FrameOptions`](#frameoptions-options).


### HexgridOptions options

Options for the hexgrid mark.

Extends [`MarkOptions`](../spec/common-marks#markoptions).

**binWidth** (`number | ParamRef`) — The distance between centers of neighboring hexagons, in pixels; defaults to 20. Should match the **binWidth** of the hexbin mark.

### Hexgrid options

Extends [`HexgridOptions`](#hexgridoptions-options).


### GridScaleOptions options

The subset of scale options for grids.

```ts
type GridScaleOptions = Pick<ScaleOptions, 'interval' | 'ticks' | 'tickSpacing'>;
```

### AxisScaleOptions options

The subset of scale options for axes.

```ts
type AxisScaleOptions = Pick<ScaleOptions, 'tickSize' | 'tickPadding' | 'tickFormat' | 'tickRotate' | 'label' | 'labelOffset' | 'labelAnchor' | 'labelArrow'>;
```

**`frame`, `axisX`, `axisY`, `axisFx`, `axisFy`, `gridX`, `gridY`, `gridFx`, `gridFy`, `hexgrid`:** These decorative marks support data-free, options-only JavaScript calls. JavaScript and Python helpers also accept native data/source arguments and extra options, while their closed declarative contracts omit the data property. The renderer retains that target difference.

**`axisX`, `axisY`, `axisFx`, `axisFy`, `gridX`, `gridY`, `gridFx`, `gridFy`:** Axis and grid anchors follow scale orientation: top/bottom for x/fx, left/right for y/fy. Other sides are admitted by the broad wire and TypeScript contracts but the retained renderer rejects them with invalid anchor: side.

**`axisX`, `axisY`, `axisFx`, `axisFy`:** Formatting functions are JavaScript-only. Numeric intervals remain native values beyond the default wire Interval alias. Numeric scales retain their default labels for an explicit null tickFormat. Use a named parameter for string-valued options that the retained mark runtime would otherwise classify as a field.

**`hexgrid`:** The retained hexgrid renderer uses stroke-only outlines and defaults binWidth to 20. Fill remains admitted by inherited mark options; use frame to fill a background.

### guides examples

`axisX`: [json](/templates/marks/guides/axisX.json) · [yaml](/templates/marks/guides/axisX.yaml) · [js](/templates/marks/guides/axisX.js) · <a :href="withBase('/templates/marks/guides/axisX.py')" download>Python</a>.

JavaScript-only `native-formatter`: [js](/templates/marks/guides/native-formatter.js).

## density1d mark options

Options use their wire names below; Python keyword names use snake_case. See [common mark options](../spec/common-marks#markoptions) for shared channels and styles.

### Density1DOptions options

The Density1DOptions contract.

**bandwidth** (`number | ParamRef`) — The kernel density bandwidth for smoothing, in pixels. Defaults to 20.

**bins** (`number | ParamRef`) — The number of bins over which to discretize the data prior to smoothing. Defaults to 1024.

**normalize** (`boolean | 'max' | 'sum' | 'none' | ParamRef`) — Normalization method for density estimates. If `false` or `'none'` (the default), the density estimates are smoothed weighted counts. If `true` or `'sum'`, density estimates are divided by the sum of the total point mass. If `'max'`, estimates are divided by the maximum smoothed value.

### DensityAreaXOptions options

The DensityAreaXOptions contract.

Extends [`Omit<AreaXOptions, 'x' | 'x1' | 'x2'>`](#areaxoptions-options).

**type** (`'areaX'`) — The basic mark type to use to render 1D density values. Defaults to an areaX mark; lineX, dotX, and textX marks are also supported.

**stack** (`boolean | ParamRef`) — Flag indicating if densities should be stacked. Defaults to false.

### DensityAreaYOptions options

The DensityAreaYOptions contract.

Extends [`Omit<AreaYOptions, 'y' | 'y1' | 'y2'>`](#areayoptions-options).

**type** (`'areaY'`) — The basic mark type to use to render 1D density values. Defaults to an areaY mark; lineY, dot, and text marks are also supported.

**stack** (`boolean | ParamRef`) — Flag indicating if densities should be stacked. Defaults to false.

### DensityLineXOptions options

The DensityLineXOptions contract.

Extends [`Omit<LineXOptions, 'x' | 'x1' | 'x2'>`](#linexoptions-options).

**type** (`'lineX'`) — The basic mark type to use to render 1D density values. Defaults to an areaX mark; lineX, dotX, and textX marks are also supported.

### DensityLineYOptions options

The DensityLineYOptions contract.

Extends [`Omit<LineYOptions, 'y' | 'y1' | 'y2'>`](#lineyoptions-options).

**type** (`'lineY'`) — The basic mark type to use to render 1D density values. Defaults to an areaY mark; lineY, dot, and text marks are also supported.

### DensityDotXOptions options

The DensityDotXOptions contract.

Extends [`Omit<DotOptions, 'x'>`](#dotoptions-options).

**type** (`'dotX'`) — The basic mark type to use to render 1D density values. Defaults to an areaX mark; lineX, dotX, and textX marks are also supported.

### DensityDotYOptions options

The DensityDotYOptions contract.

Extends [`Omit<DotOptions, 'y'>`](#dotoptions-options).

**type** (`'dot' | 'dotY' | 'circle' | 'hexagon'`) — The basic mark type to use to render 1D density values. Defaults to an areaY mark; lineY, dot, and text marks are also supported.

### DensityTextXOptions options

The DensityTextXOptions contract.

Extends [`Omit<TextOptions, 'x'>`](#textoptions-options).

**type** (`'textX'`) — The basic mark type to use to render 1D density values. Defaults to an areaX mark; lineX, dotX, and textX marks are also supported.

### DensityTextYOptions options

The DensityTextYOptions contract.

Extends [`Omit<TextOptions, 'y'>`](#textoptions-options).

**type** (`'text' | 'textY'`) — The basic mark type to use to render 1D density values. Defaults to an areaY mark; lineY, dot, and text marks are also supported.

### DensityXBase options

The DensityXBase contract.

Extends [`MarkData`](../spec/common-marks#markdata), [`Density1DOptions`](#density1doptions-options).


### DensityYBase options

The DensityYBase contract.

Extends [`MarkData`](../spec/common-marks#markdata), [`Density1DOptions`](#density1doptions-options).


### DensityX options

Combines [`DensityXBase`](#densityxbase-options) with [`DensityAreaXOptions`](#densityareaxoptions-options), [`DensityLineXOptions`](#densitylinexoptions-options), [`DensityDotXOptions`](#densitydotxoptions-options), [`DensityTextXOptions`](#densitytextxoptions-options).

### DensityY options

Combines [`DensityYBase`](#densityybase-options) with [`DensityAreaYOptions`](#densityareayoptions-options), [`DensityLineYOptions`](#densitylineyoptions-options), [`DensityDotYOptions`](#densitydotyoptions-options), [`DensityTextYOptions`](#densitytextyoptions-options).

**`densityX`, `densityY`:** Density wrappers always construct areaX or areaY. An explicit type is interpreted as a queried column, causing a missing-column error. Use densityY without type for the supported declarative form; native densityX must also omit type.

**`densityX`, `densityY`:** Density rendering requires a SQL-backed data source. Inline arrays remain admitted by the general declarative data type, but the retained density query engine rejects them. Native weight channels retain separate authoring applicability.

### density1d examples

`densityY`: [json](/templates/marks/density1d/densityY.json) · [yaml](/templates/marks/density1d/densityY.yaml) · [js](/templates/marks/density1d/densityY.js) · <a :href="withBase('/templates/marks/density1d/densityY.py')" download>Python</a>.

## grid mark options

Options use their wire names below; Python keyword names use snake_case. See [common mark options](../spec/common-marks#markoptions) for shared channels and styles.

### Grid2DOptions options

Options for grid2d marks.

**x** (`ChannelValueSpec`) — The horizontal position channel, typically bound to the *x* scale. Domain values are binned into a grid with *width* horizontal bins.

**y** (`ChannelValueSpec`) — The vertical position channel, typically bound to the *y* scale. Domain values are binned into a grid with *height* vertical bins.

**width** (`number | ParamRef`) — The width (number of columns) of the grid, in actual pixels.

**height** (`number | ParamRef`) — The height (number of rows) of the grid, in actual pixels.

**pixelSize** (`number | ParamRef`) — The effective screen size of a raster pixel, used to determine the height and width of the raster from the frame’s dimensions; defaults to 1.

**pad** (`number | ParamRef`) — The bin padding, one of 1 (default) to include extra padding for the final bin, or 0 to make the bins flush with the maximum domain value.

**bandwidth** (`number | ParamRef`) — The kernel density bandwidth for smoothing, in pixels.

**interpolate** (`GridInterpolate | null | ParamRef`) — The spatial interpolation method; one of:

- *none* - do not perform interpolation (the default), maps samples to single bins
- *linear* - apply proportional linear interpolation across adjacent bins
- *nearest* - assign each pixel to the closest sample’s value (Voronoi diagram)
- *barycentric* - apply barycentric interpolation over the Delaunay triangulation
- *random-walk* - apply a random walk from each pixel, stopping when near a sample

### RasterOptions options

Options for the raster mark.

Extends [`Grid2DOptions`](#grid2doptions-options), [`Omit<MarkOptions, 'fill' | 'fillOpacity'>`](../spec/common-marks#markoptions).

**imageRendering** (`string | ParamRef`) — The [image-rendering attribute](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/image-rendering); defaults to *auto* (bilinear). The option may be set to *pixelated* to disable bilinear interpolation for a sharper image; however, note that this is not supported in WebKit.

**fill** (`ChannelValueSpec | ParamRef`) — The fill, typically bound to the *color* scale. Can be specified as a constant or a channel based on the input data.  Use the special value `"density"` to map computed density values to pixel colors. Use an aggregate expression to instead visualize an aggregate value per raster bin. If fill is set to a constant color or to a non-aggregate field, opacity will be used to convey densities. If a non-aggregate (group by) field is provided, multiple rasters are created with a unique categorical color per layer.

**fillOpacity** (`ChannelValueSpec | ParamRef`) — The opacity, typically bound to the *opacity* scale. Can be specified as a constant or a channel based on the input data. Use the special value `"density"` to map computed density values to opacity. Use an aggregate expression to instead visualize an aggregate value per raster bin.

### Raster options

Extends [`MarkData`](../spec/common-marks#markdata), [`RasterOptions`](#rasteroptions-options).


### Heatmap options

Extends [`MarkData`](../spec/common-marks#markdata), [`RasterOptions`](#rasteroptions-options).


### RasterTile options

Extends [`MarkData`](../spec/common-marks#markdata), [`RasterOptions`](#rasteroptions-options).

**origin** (`[number, number] | ParamRef`) — The coordinates of the tile origin in the **x** and **y** data domains. Defaults to [0, 0].

### ContourOptions options

The ContourOptions contract.

Extends [`MarkOptions`](../spec/common-marks#markoptions), [`Grid2DOptions`](#grid2doptions-options).

**thresholds** (`number | Array<number> | ParamRef`) — The number of contour thresholds to subdivide the domain into discrete level sets; defaults to 10. One of:

- a count representing the desired number of bins
- an array of *n* threshold values for *n* - 1 bins

### Contour options

Extends [`MarkData`](../spec/common-marks#markdata), [`ContourOptions`](#contouroptions-options).


### DenseLineOptions options

The DenseLineOptions contract.

Extends [`RasterOptions`](#rasteroptions-options).

**normalize** (`boolean | ParamRef`) — Flag to perform approximate arc length normalization of line segments to prevent artifacts due to overcounting steep lines. Defaults to `true`.

**z** (`ChannelValue`) — A ordinal channel for grouping data into series to be drawn as separate lines.

### DenseLine options

Extends [`MarkData`](../spec/common-marks#markdata), [`DenseLineOptions`](#denselineoptions-options).


### Density2DOptions options

The Density2DOptions contract.

Extends [`MarkOptions`](../spec/common-marks#markoptions), [`Omit<DotOptions, 'x' | 'y'>`](#dotoptions-options), [`TextStyles`](../spec/common-marks#textstyles), [`Grid2DOptions`](#grid2doptions-options).

**type** (`'dot' | 'circle' | 'hexagon' | 'cell' | 'text' | ParamRef`) — The basic mark type to use to render 2D density values. Defaults to a dot mark; cell and text marks are also supported.

### Density options

Extends [`MarkData`](../spec/common-marks#markdata), [`Density2DOptions`](#density2doptions-options).


### GridInterpolate options

```ts
type GridInterpolate = 'none' | 'linear' | 'nearest' | 'barycentric' | 'random-walk';
```

**`rasterTile`:** rasterTile fails on multi-pixel grids; use raster or heatmap. Tile queries use the global coordinator even inside a local API context.

**`density`:** Density cells use ordinal domains; set pad=1 so endpoint grid positions fall inside those domains.

**`density`, `denseLine`, `contour`, `heatmap`, `raster`, `rasterTile`:** Null interpolation fails during rendering. Use none to disable interpolation.

### grid examples

`raster`: [json](/templates/marks/grid/raster.json) · [yaml](/templates/marks/grid/raster.yaml) · [js](/templates/marks/grid/raster.js) · <a :href="withBase('/templates/marks/grid/raster.py')" download>Python</a>.

JavaScript-only `native-interpolator`: [js](/templates/marks/grid/native-interpolator.js).

## statistical mark options

Options use their wire names below; Python keyword names use snake_case. See [common mark options](../spec/common-marks#markoptions) for shared channels and styles.

### HexbinOptions options

Options for the hexbin mark.

Extends [`DotOptions`](#dotoptions-options), [`TextStyles`](../spec/common-marks#textstyles).

**type** (`'dot' | 'circle' | 'hexagon' | 'text' | ParamRef`) — The basic mark type to use for hex-binned values. Defaults to a hexagon mark; dot and text marks are also supported.

**binWidth** (`number | ParamRef`) — The distance between centers of neighboring hexagons, in pixels; defaults to 20. If also using a hexgrid mark, use matching **binWidth** values.

**z** (`ChannelValue`) — How to subdivide bins. If not specified, defaults to the *fill* channel, if any, or the *stroke* channel, if any. If null, bins will not be subdivided.

### Hexbin options

Extends [`MarkData`](../spec/common-marks#markdata), [`HexbinOptions`](#hexbinoptions-options).


### RegressionOptions options

Options for regression marks.

Extends [`MarkOptions`](../spec/common-marks#markoptions).

**ci** (`number | ParamRef`) — The confidence interval in (0, 1), or 0 to hide bands; defaults to 0.95.

**precision** (`number | ParamRef`) — The distance in pixels between samples of the confidence band; defaults to 4.

**z** (`ChannelValue`) — An optional ordinal channel for grouping data into (possibly stacked) series, producing an independent regression for each group. If not specified, it defaults to **fill** if a channel, or **stroke** if a channel.

### RegressionYOptions options

Options for the regressionY mark.

Extends [`RegressionOptions`](#regressionoptions-options).

**x** (`ChannelValueSpec`) — The independent variable horizontal position channel, typically bound to the *x* scale; defaults to the zero-based index of the data [0, 1, 2, …].

**y** (`ChannelValueSpec`) — The dependent variable vertical position channel, typically bound to the
*y* scale; defaults to identity, assuming that *data* = [*y₀*, *y₁*, *y₂*, …].

### RegressionY options

Extends [`MarkData`](../spec/common-marks#markdata), [`RegressionYOptions`](#regressionyoptions-options).


### ErrorBarOptions options

Options for errorbar marks.

Extends [`MarkOptions`](../spec/common-marks#markoptions), [`MarkerOptions`](../spec/common-marks#markeroptions).

**ci** (`number | ParamRef`) — The confidence interval in (0, 1); defaults to 0.95.

**z** (`ChannelValue`) — An optional ordinal channel for grouping data, producing an independent error bar for each group. If not specified, it defaults to **stroke** if a channel.

### ErrorBarXOptions options

Options for the errorbarX mark.

Extends [`ErrorBarOptions`](#errorbaroptions-options).

**x** (`ChannelValueSpec`) — The dependent variable horizontal position channel, typically bound to the
*x* scale.

**y** (`ChannelValueSpec`) — The independent variable vertical position channel, typically bound to the *y* scale; defaults to the zero-based index of the data [0, 1, 2, …].

### ErrorBarX options

Extends [`MarkData`](../spec/common-marks#markdata), [`ErrorBarXOptions`](#errorbarxoptions-options).


### ErrorBarYOptions options

Options for the errorbarY mark.

Extends [`ErrorBarOptions`](#errorbaroptions-options).

**x** (`ChannelValueSpec`) — The independent variable horizontal position channel, typically bound to the *x* scale; defaults to the zero-based index of the data [0, 1, 2, …].

**y** (`ChannelValueSpec`) — The dependent variable vertical position channel, typically bound to the
*y* scale.

### ErrorBarY options

Extends [`MarkData`](../spec/common-marks#markdata), [`ErrorBarYOptions`](#errorbaryoptions-options).


**`hexbin`, `regressionY`, `errorbarX`, `errorbarY`:** These statistical marks use SQL-backed sources. The starters create a small table through the configured Mosaic DuckDB connector. Native JavaScript calls require both the data/source argument and an options object; Python helpers retain their permissive serialization defaults.

**`regressionY`:** The retained regression engine groups by stroke, z, fx, or fy. Fill alone does not create separate regressions. A confidence value of zero hides the band; confidence and precision parameters recompute the existing fit. SQL-backed regression requires explicit x and y fields despite the optional declarative types.

**`errorbarX`, `errorbarY`:** errorbarX computes horizontal confidence bounds and renders ruleY; errorbarY computes vertical bounds and renders ruleX. Bounds use the normal quantile and standard error of the mean. The dependent x or y channel is required.

**`hexbin`:** Hexbin aggregates in screen coordinates and excludes null x/y positions. Its retained constructor supports hexagon, dot, circle, and text. Text without a native text channel displays row indexes. SQL-backed binning requires explicit x and y fields.

**`hexbin`:** Known parameter limitations: a Param type reaches the renderer as an object and throws Plot[type] is not a function; a Param binWidth computes a NaN default radius before unwrapping. An explicit radius avoids that default-radius issue. Confidence and precision parameters on the other statistical marks remain supported.

### statistical examples

`regressionY`: [json](/templates/marks/statistical/regressionY.json) · [yaml](/templates/marks/statistical/regressionY.yaml) · [js](/templates/marks/statistical/regressionY.js) · <a :href="withBase('/templates/marks/statistical/regressionY.py')" download>Python</a>.
