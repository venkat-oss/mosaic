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

An `area` mark, with `areaX` and `areaY` variants.
When feasible, the `areaX` and `areaY` marks will perform [M4 optimization](https://observablehq.com/@uwdata/m4-scalable-time-series-visualization) to limit the number of sample points returned from the database.
Use `from("data", { optimize: false })` to disable this behavior.
For supported options, see the [Observable Plot `area` documentation](https://observablehq.com/plot/marks/area).

## Arrow

The `arrow` mark provides line segments with arrow heads.
For supported options, see the [Observable Plot `arrow` documentation](https://observablehq.com/plot/marks/arrow).

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

The `image` mark draws images centered at the given position in _x_ and _y_.
For supported options, see the [Observable Plot `image` documentation](https://observablehq.com/plot/marks/image).

## Line

A `line` mark, with `lineX` and `lineY` variants.
When feasible, the `lineX` and `lineY` marks will perform [M4 optimization](https://observablehq.com/@uwdata/m4-scalable-time-series-visualization) to limit the number of sample points returned from the database.
Use `from("data", { optimize: false })` to disable this behavior.
For supported options, see the [Observable Plot `line` documentation](https://observablehq.com/plot/marks/line).

## Regression

The `regressionY` mark draws a regression line and optional confidence interval area for a linear regression fit.
The regression calculation is pushed to the backing database.

The supported _options_ are:

- _x_: The x dimension (predictor) encoding channel
- _y_: The y dimension (predicted) encoding channel
- _ci_: The confidence level (default `0.95`) to visualize as a confidence band area; use zero or `null` to suppress
- _precision_: The distance (in pixels) between samples of the confidence band (default `4`)

## Link

The `link` mark draws straight lines between two points [_x1_, _y1_] and [_x2_, _y2_] in quantitative dimensions.
For supported options, see the [Observable Plot `link` documentation](https://observablehq.com/plot/marks/link).

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

The `text` mark, with `textX` and `textY` variants, draws text at the given position in _x_ and _y_. It is often used to label other marks.
For supported options, see the [Observable Plot `text` documentation](https://observablehq.com/plot/marks/text).

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

The `vector` mark, with `vectorX` and `vectorY` variants, draws little arrows, typically positioned in _x_ and _y_ quantitative dimensions, with an optional magnitude (`length`) and direction (`rotate`), as in a vector field.

The `spike` mark is equivalent to `vector`, but changes the default `shape`, `anchor`, and color options to draw a more spiky element.

For supported options, see the [Observable Plot `vector` documentation](https://observablehq.com/plot/marks/vector).


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

An `area` mark, with `area_x` and `area_y` variants.
When feasible, the `area_x` and `area_y` marks will perform [M4 optimization](https://observablehq.com/@uwdata/m4-scalable-time-series-visualization) to limit the number of sample points returned from the database.
Use `vg.source("data", optimize=False)` as the mark `data` argument to disable this behavior.
For supported options, see the [Observable Plot `area` documentation](https://observablehq.com/plot/marks/area).

## Arrow

The `arrow` mark provides line segments with arrow heads.
For supported options, see the [Observable Plot `arrow` documentation](https://observablehq.com/plot/marks/arrow).

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

The `image` mark draws images centered at the given position in _x_ and _y_.
For supported options, see the [Observable Plot `image` documentation](https://observablehq.com/plot/marks/image).

## Line

A `line` mark, with `line_x` and `line_y` variants.
When feasible, the `line_x` and `line_y` marks will perform [M4 optimization](https://observablehq.com/@uwdata/m4-scalable-time-series-visualization) to limit the number of sample points returned from the database.
Use `vg.source("data", optimize=False)` as the mark `data` argument to disable this behavior.
For supported options, see the [Observable Plot `line` documentation](https://observablehq.com/plot/marks/line).

## Regression

The `regression_y` mark draws a regression line and optional confidence interval area for a linear regression fit.
The regression calculation is pushed to the backing database.

The supported _options_ are:

- _x_: The x dimension (predictor) encoding channel
- _y_: The y dimension (predicted) encoding channel
- _ci_: The confidence level (default `0.95`) to visualize as a confidence band area; use zero or `null` to suppress
- _precision_: The distance (in pixels) between samples of the confidence band (default `4`)

## Link

The `link` mark draws straight lines between two points [_x1_, _y1_] and [_x2_, _y2_] in quantitative dimensions.
For supported options, see the [Observable Plot `link` documentation](https://observablehq.com/plot/marks/link).

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

The `text` mark, with `text_x` and `text_y` variants, draws text at the given position in _x_ and _y_. It is often used to label other marks.
For supported options, see the [Observable Plot `text` documentation](https://observablehq.com/plot/marks/text).

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

The `vector` mark, with `vector_x` and `vector_y` variants, draws little arrows, typically positioned in _x_ and _y_ quantitative dimensions, with an optional magnitude (`length`) and direction (`rotate`), as in a vector field.

The `spike` mark is equivalent to `vector`, but changes the default `shape`, `anchor`, and color options to draw a more spiky element.

For supported options, see the [Observable Plot `vector` documentation](https://observablehq.com/plot/marks/vector).


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
