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

To go beyond the built-in axis generation, the axis mark supports explicit inclusion of axes, along with control over drawing order.
The provided mark directives are `axisX` and `axisY` (for standard axes) as well as `axisFx` and `axisFy` (for facet axes).
For supported options, see the [Observable Plot `axis` documentation](https://observablehq.com/plot/marks/axis).

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

The `contour` mark draws isolines to delineate regions above and below a particular continuous value.
It is often used to convey densities as a height field.
The special column name `"density"` can be used to map density values to the _fill_ or _stroke_ options.

The supported _options_ are:

- _x_: The x dimension encoding channel
- _y_: The y dimension encoding channel
- _fill_: The contour fill color
- _stroke_: The contour stroke color
- _thresholds_: The number of contour thresholds to include (default `10`)
- _bandwidth_: The kernel density bandwidth for smoothing, in pixels (default `20`)
- _interpolate_: The binning interpolation method to use, one of `"linear"` (default) or `"none"`
- _pixelSize_: The grid cell size in screen pixels (default `2`); ignored when _width_ and _height_ options are provided
- _width_: The number of grid bins to include along the _x_ dimension
- _height_: The number of grid bins to include along the _y_ dimension
- _pad_: The bin padding, one of `0` (default) to make the bins flush with the maximum domain value, or `1` to include extra padding for the final bin
- Other standard mark options including _fillOpacity_ and _strokeWidth_

## Delaunay

Given set of points in x and y, the Delaunay marks compute the Delaunay triangulation, its dual the Voronoi tessellation, and the convex hull.
The supported marks are `voronoi`, `voronoiMesh`, `delaunayLink`, `delaunayMesh`, and `hull`.
For more, see the [Observable Plot `delaunay` documentation](https://observablehq.com/plot/marks/delaunay).

## Density 1D

The 1D density marks show smoothed point cloud densities along one dimension.
The `densityX` and `densityY` marks bin the data, count the number of records that fall into each bin, smooth the resulting counts, then plot the smoothed distribution (by default using an `area` mark).
The `densityX` mark maps density values to the _x_ dimension automatically, while `densityY` maps the density values to the _y_ dimension.

The supported _options_ are:

- _x_: The x dimension encoding channel, used with `densityY`
- _y_: The y dimension encoding channel, used with `densityX`
- _type_: The mark type to use (default [`areaX`](#area) or [`areaY`](#area))
- _bins_: The number of bins (default `1024`)
- _bandwidth_: The kernel density bandwidth for smoothing, in pixels (default `20`)
- Any options accepted by the mark _type_, including _stroke_ and _fill_

## Density 2D

The 2D `density` mark shows smoothed point cloud densities along two dimensions.
The mark will bin the data, count the number of records that fall into each bin, smooth the resulting counts, then plot the smoothed distribution (by default using a circular `dot` mark).
The `density` mark calculates density values that can be mapped to encoding channels such as _fill_ or _r_ using the column name `"density"`.

The supported _options_ are:

- _x_: The x dimension encoding channel
- _y_: The y dimension encoding channel
- _type_: The mark type to use (default [`dot`](#dot))
- _bandwidth_: The kernel density bandwidth for smoothing, in pixels (default `20`)
- _interpolate_: The binning interpolation method to use, one of `"linear"` (default) or `"none"`
- _pixelSize_: The grid cell size in screen pixels (default `2`); ignored when _width_ and _height_ options are provided
- _width_: The number of grid bins to include along the _x_ dimension
- _height_: The number of grid bins to include along the _y_ dimension
- _pad_: The bin padding, one of `0` (default) to make the bins flush with the maximum domain value, or `1` to include extra padding for the final bin
- Any options accepted by the mark _type_, including _fill_, _stroke_, and _r_

## Dense Line

Rather than plot point densities, the `denseLine` mark plots line densities: the mark forms a binned raster grid and "draws" lines into it.
To avoid over-weighting steep lines, by default each drawn series will be normalized on a per-column basis to approximate arc length normalization.
The values for each series are then aggregated to form the line density, which is then drawn as an image similar to the [`raster`](#raster) mark.

The supported _options_ are:

- _x_: The x dimension encoding channel
- _y_: The y dimension encoding channel
- _bandwidth_: The kernel density bandwidth for smoothing (default `0`)
- _pixelSize_: The grid cell size in screen pixels (default `1`)
- _pad_: The bin padding, one of `1` (default) to include extra padding for the final bin, or `0` to make the bins flush with the maximum domain value.
- _width_: The number of grid bins to include along the _x_ dimension
- _height_: The number of grid bins to include along the _y_ dimension
- _normalize_: Boolean flag (default `true`) controlling approximate arc length normalization.

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

The `frame` mark draws a rectangle around the plot area.
It does not take a _data_ argument.
For supported options, see the [Observable Plot `frame` documentation](https://observablehq.com/plot/marks/frame).

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

The grid mark is a specially-configured rule for drawing an axis-aligned grid.
To go beyond the built-in axis generation, the grid mark supports explicit inclusion of grid lines, along with control over drawing order.
The provided mark directives are `gridX` and `gridY` (for standard axes) as well as `gridFx` and `gridFy` (for facet axes).
For supported options, see the [Observable Plot `grid` documentation](https://observablehq.com/plot/marks/grid).

## Heatmap

The `heatmap` mark is a raster mark with default options for accurate density estimation via smoothing.
The _bandwidth_ (`20`), _interpolate_ (`"linear"`), and _pixelSize_ (`2`) options are set to produce smoothed density heatmaps.
For all supported options, see the [`raster`](#raster) mark.

## Hexbin

The `hexbin` mark bins data into a hexagonal grid and visualizes aggregate functions per bin (e.g., `count` for binned density).
Hexagonal binning and aggregation are pushed to the backing database.
Aggregate functions can be used for the mark _fill_, _stroke_, or radius size _r_ options.

The supported _options_ are:

- _x_: The x dimension encoding channel
- _y_: The y dimension encoding channel
- _type_: The mark type to use (default [`hexagon`](#dot))
- _binWidth_: The hexagon bin width in screen pixels (default `20`)
- Any options accepted by the mark _type_, including _fill_, _stroke_, _r_.

## Hexgrid

The `hexgrid` mark draws a hexagonal grid spanning the frame.
For supported options, see the [Observable Plot `hexgrid` documentation](https://observablehq.com/plot/marks/hexgrid).

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

The `regressionY` mark draws a regression line and optional confidence interval area for a linear regression fit.
The regression calculation is pushed to the backing database.

The supported _options_ are:

- _x_: The x dimension (predictor) encoding channel
- _y_: The y dimension (predicted) encoding channel
- _ci_: The confidence level (default `0.95`) to visualize as a confidence band area; use zero or `null` to suppress
- _precision_: The distance (in pixels) between samples of the confidence band (default `4`)

## Link

### link

`link(data, options)`

A link mark, drawing line segments (curves) connecting pairs of points.

If the plot uses a spherical **projection**, the default *auto* **curve** will render links as geodesics; to draw a straight line instead, use the
*linear* **curve**.

[Options](#link-options).

## Raster

The `raster` mark draws an image whose pixel colors are a function of the underlying data.
The _x_ and _y_ data domains are binned into the cells ("pixels") of a raster grid, typically with an aggregate function evaluated over the binned data.
The result can be optionally smoothed (blurred) in-browser.
To create a smoothed density heatmap, use the [`heatmap`](#heatmap) mark; this is a raster mark with different default options.

The supported _options_ are:

- _x_: The x dimension encoding channel
- _y_: The y dimension encoding channel
- _fill_: The pixel fill color. Use the special value `"density"` to map computed density values to pixel colors. Use an aggregate expression to instead visualize an aggregate value per raster bin. If _fill_ is set to a constant color or to a non-aggregate field, opacity will be used to convey densities. If a non-aggregate (group by) field is provided, multiple rasters are created with a unique categorical color per layer.
- _fillOpacity_: The pixel fill opacity. Use the special value `"density"` to map computed density values to opacity. Use an aggregate expression to instead visualize an aggregate value per raster bin.
- _weight_: A data column by which to weight computed densities
- _bandwidth_: The kernel density bandwidth for smoothing, in pixels (default `0`)
- _interpolate_: The binning interpolation method to use. The `"none"` and `"linear"` methods are performed in-database and only fill bins corresponding to observed data samples. The other methods are performed in-browser and interpolate to fill all raster pixels. The options are:
  - `"none"` (default): Map data samples to single bins only.
  - `"linear"`: Linearly distribute the "weight" of a sample across adjacent bin boundaries. Linear binning provides more stable and accurate density estimation upon subsequent smoothing.
  - `"nearest"`: Perform nearest-neighbor interpolation, forming a pixel-level Voronoi diagram.
  - `"barycentric"`: Interpolate over a triangulation of sample points. Pixels outside the convex hull of data samples are extrapolated.
  - `"random-walk`: Apply a random walk from empty pixels until a sample is found.
- _pixelSize_: The grid cell size in screen pixels (default `1`); ignored when _width_ and _height_ options are provided
- _width_: The number of grid bins to include along the _x_ dimension
- _height_: The number of grid bins to include along the _y_ dimension
- _pad_: The bin padding, one of `1` (default) to include extra padding for the final bin, or `0` to make the bins flush with the maximum domain value

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

To go beyond the built-in axis generation, the axis mark supports explicit inclusion of axes, along with control over drawing order.
The provided mark directives are `axis_x` and `axis_y` (for standard axes) as well as `axis_fx` and `axis_fy` (for facet axes).
For supported options, see the [Observable Plot `axis` documentation](https://observablehq.com/plot/marks/axis).

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

The `contour` mark draws isolines to delineate regions above and below a particular continuous value.
It is often used to convey densities as a height field.
The special column name `"density"` can be used to map density values to the _fill_ or _stroke_ options.

The supported _options_ are:

- _x_: The x dimension encoding channel
- _y_: The y dimension encoding channel
- _fill_: The contour fill color
- _stroke_: The contour stroke color
- _thresholds_: The number of contour thresholds to include (default `10`)
- _bandwidth_: The kernel density bandwidth for smoothing, in pixels (default `20`)
- _interpolate_: The binning interpolation method to use, one of `"linear"` (default) or `"none"`
- _pixel_size_: The grid cell size in screen pixels (default `2`); ignored when _width_ and _height_ options are provided
- _width_: The number of grid bins to include along the _x_ dimension
- _height_: The number of grid bins to include along the _y_ dimension
- _pad_: The bin padding, one of `0` (default) to make the bins flush with the maximum domain value, or `1` to include extra padding for the final bin
- Other standard mark options including _fill_opacity_ and _stroke_width_

## Delaunay

Given set of points in x and y, the Delaunay marks compute the Delaunay triangulation, its dual the Voronoi tessellation, and the convex hull.
The supported marks are `voronoi`, `voronoi_mesh`, `delaunay_link`, `delaunay_mesh`, and `hull`.
For more, see the [Observable Plot `delaunay` documentation](https://observablehq.com/plot/marks/delaunay).

## Density 1D

The 1D density marks show smoothed point cloud densities along one dimension.
The `density_x` and `density_y` marks bin the data, count the number of records that fall into each bin, smooth the resulting counts, then plot the smoothed distribution (by default using an `area` mark).
The `density_x` mark maps density values to the _x_ dimension automatically, while `density_y` maps the density values to the _y_ dimension.

The supported _options_ are:

- _x_: The x dimension encoding channel, used with `density_y`
- _y_: The y dimension encoding channel, used with `density_x`
- _type_: The mark type to use (default [`area_x`](#area) or [`area_y`](#area))
- _bins_: The number of bins (default `1024`)
- _bandwidth_: The kernel density bandwidth for smoothing, in pixels (default `20`)
- Any options accepted by the mark _type_, including _stroke_ and _fill_

## Density 2D

The 2D `density` mark shows smoothed point cloud densities along two dimensions.
The mark will bin the data, count the number of records that fall into each bin, smooth the resulting counts, then plot the smoothed distribution (by default using a circular `dot` mark).
The `density` mark calculates density values that can be mapped to encoding channels such as _fill_ or _r_ using the column name `"density"`.

The supported _options_ are:

- _x_: The x dimension encoding channel
- _y_: The y dimension encoding channel
- _type_: The mark type to use (default [`dot`](#dot))
- _bandwidth_: The kernel density bandwidth for smoothing, in pixels (default `20`)
- _interpolate_: The binning interpolation method to use, one of `"linear"` (default) or `"none"`
- _pixel_size_: The grid cell size in screen pixels (default `2`); ignored when _width_ and _height_ options are provided
- _width_: The number of grid bins to include along the _x_ dimension
- _height_: The number of grid bins to include along the _y_ dimension
- _pad_: The bin padding, one of `0` (default) to make the bins flush with the maximum domain value, or `1` to include extra padding for the final bin
- Any options accepted by the mark _type_, including _fill_, _stroke_, and _r_

## Dense Line

Rather than plot point densities, the `dense_line` mark plots line densities: the mark forms a binned raster grid and "draws" lines into it.
To avoid over-weighting steep lines, by default each drawn series will be normalized on a per-column basis to approximate arc length normalization.
The values for each series are then aggregated to form the line density, which is then drawn as an image similar to the [`raster`](#raster) mark.

The supported _options_ are:

- _x_: The x dimension encoding channel
- _y_: The y dimension encoding channel
- _bandwidth_: The kernel density bandwidth for smoothing (default `0`)
- _pixel_size_: The grid cell size in screen pixels (default `1`)
- _pad_: The bin padding, one of `1` (default) to include extra padding for the final bin, or `0` to make the bins flush with the maximum domain value.
- _width_: The number of grid bins to include along the _x_ dimension
- _height_: The number of grid bins to include along the _y_ dimension
- _normalize_: Boolean flag (default `true`) controlling approximate arc length normalization.

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

The `frame` mark draws a rectangle around the plot area.
It does not take a _data_ argument.
For supported options, see the [Observable Plot `frame` documentation](https://observablehq.com/plot/marks/frame).

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

The grid mark is a specially-configured rule for drawing an axis-aligned grid.
To go beyond the built-in axis generation, the grid mark supports explicit inclusion of grid lines, along with control over drawing order.
The provided mark directives are `grid_x` and `grid_y` (for standard axes) as well as `grid_fx` and `grid_fy` (for facet axes).
For supported options, see the [Observable Plot `grid` documentation](https://observablehq.com/plot/marks/grid).

## Heatmap

The `heatmap` mark is a raster mark with default options for accurate density estimation via smoothing.
The _bandwidth_ (`20`), _interpolate_ (`"linear"`), and _pixel_size_ (`2`) options are set to produce smoothed density heatmaps.
For all supported options, see the [`raster`](#raster) mark.

## Hexbin

The `hexbin` mark bins data into a hexagonal grid and visualizes aggregate functions per bin (e.g., `count` for binned density).
Hexagonal binning and aggregation are pushed to the backing database.
Aggregate functions can be used for the mark _fill_, _stroke_, or radius size _r_ options.

The supported _options_ are:

- _x_: The x dimension encoding channel
- _y_: The y dimension encoding channel
- _type_: The mark type to use (default [`hexagon`](#dot))
- _bin_width_: The hexagon bin width in screen pixels (default `20`)
- Any options accepted by the mark _type_, including _fill_, _stroke_, _r_.

## Hexgrid

The `hexgrid` mark draws a hexagonal grid spanning the frame.
For supported options, see the [Observable Plot `hexgrid` documentation](https://observablehq.com/plot/marks/hexgrid).

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

The `regression_y` mark draws a regression line and optional confidence interval area for a linear regression fit.
The regression calculation is pushed to the backing database.

The supported _options_ are:

- _x_: The x dimension (predictor) encoding channel
- _y_: The y dimension (predicted) encoding channel
- _ci_: The confidence level (default `0.95`) to visualize as a confidence band area; use zero or `null` to suppress
- _precision_: The distance (in pixels) between samples of the confidence band (default `4`)

## Link

### link

`link(data=None, **options)`

A link mark, drawing line segments (curves) connecting pairs of points.

If the plot uses a spherical **projection**, the default *auto* **curve** will render links as geodesics; to draw a straight line instead, use the
*linear* **curve**.

[Options](#link-options).

## Raster

The `raster` mark draws an image whose pixel colors are a function of the underlying data.
The _x_ and _y_ data domains are binned into the cells ("pixels") of a raster grid, typically with an aggregate function evaluated over the binned data.
The result can be optionally smoothed (blurred) in-browser.
To create a smoothed density heatmap, use the [`heatmap`](#heatmap) mark; this is a raster mark with different default options.

The supported _options_ are:

- _x_: The x dimension encoding channel
- _y_: The y dimension encoding channel
- _fill_: The pixel fill color. Use the special value `"density"` to map computed density values to pixel colors. Use an aggregate expression to instead visualize an aggregate value per raster bin. If _fill_ is set to a constant color or to a non-aggregate field, opacity will be used to convey densities. If a non-aggregate (group by) field is provided, multiple rasters are created with a unique categorical color per layer.
- _fill_opacity_: The pixel fill opacity. Use the special value `"density"` to map computed density values to opacity. Use an aggregate expression to instead visualize an aggregate value per raster bin.
- _weight_: A data column by which to weight computed densities
- _bandwidth_: The kernel density bandwidth for smoothing, in pixels (default `0`)
- _interpolate_: The binning interpolation method to use. The `"none"` and `"linear"` methods are performed in-database and only fill bins corresponding to observed data samples. The other methods are performed in-browser and interpolate to fill all raster pixels. The options are:
  - `"none"` (default): Map data samples to single bins only.
  - `"linear"`: Linearly distribute the "weight" of a sample across adjacent bin boundaries. Linear binning provides more stable and accurate density estimation upon subsequent smoothing.
  - `"nearest"`: Perform nearest-neighbor interpolation, forming a pixel-level Voronoi diagram.
  - `"barycentric"`: Interpolate over a triangulation of sample points. Pixels outside the convex hull of data samples are extrapolated.
  - `"random-walk`: Apply a random walk from empty pixels until a sample is found.
- _pixel_size_: The grid cell size in screen pixels (default `1`); ignored when _width_ and _height_ options are provided
- _width_: The number of grid bins to include along the _x_ dimension
- _height_: The number of grid bins to include along the _y_ dimension
- _pad_: The bin padding, one of `1` (default) to include extra padding for the final bin, or `0` to make the bins flush with the maximum domain value

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
