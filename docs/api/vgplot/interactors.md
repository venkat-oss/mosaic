---
title: Interactors
---
<script setup>
import { withBase } from 'vitepress';
  import { useLang } from '../../.vitepress/theme/useLang.js';
  const { language, setLanguage } = useLang();
</script>

<LangToggle :model-value="language" aria-label="Interactors documentation language" @update:model-value="setLanguage" />

<template v-if="language === 'js'">

# Interactors

Interactors imbue plots with interactive behavior, such as selecting or highlighting values, and panning or zooming the display.

To determine which fields (database columns) an interactor should select, an interactor defaults to looking at the corresponding encoding channels for the most recently added mark.
Alternatively, interactors accept options that explicitly indicate which data fields should be selected.

## toggle

### toggle

`toggle(options)`

Select individual values.

[Options](#toggle-options).

### toggleX

`toggleX(options)`

Select individual values in the `x` scale domain. Clicking or touching a mark toggles its selection status.

[Options](#togglex-options).

### toggleY

`toggleY(options)`

Select individual values in the `y` scale domain. Clicking or touching a mark toggles its selection status.

[Options](#toggley-options).

### toggleZ

`toggleZ(options)`

Select individual values in the `z` scale domain. Clicking or touching a mark toggles its selection status.

[Options](#togglez-options).

### toggleColor

`toggleColor(options)`

Select individual values in the `color` scale domain. Clicking or touching a mark toggles its selection status.

[Options](#togglecolor-options).

## nearest

### nearest

`nearest(options)`

Select values from the mark closest to the pointer.

[Options](#nearest-options).

### nearestX

`nearestX(options)`

Select values from the mark closest to the pointer *x* location.

[Options](#nearestx-options).

### nearestY

`nearestY(options)`

Select values from the mark closest to the pointer *y* location.

[Options](#nearesty-options).

## region

`region(options)`

Select point values from elements within a rectangular region.
Unlike `interval` interactors (which select a domain value range along an axis), the `region` interactor generates clauses for values extracted from the selected set of on-screen elements. This interactor functions similar to `toggle`, but uses a rectangular selection region rather than click / tap interactions.

To select non-visualized data fields, use the plot `channels` property to define additional named channels, which can then be included in this interactor's _channels_ option.

- _as_: The [Selection](../core/selection) to populate with filter predicates. A clause of the form `(field = value1) OR (field = value2) ...` is added for the currently selected values.
- _channels_: An array of encoding channels (e.g., `"x"`, `"y"`, `"color"`) indicating the data values to select. A sub-clause will be included for each channel.
- _peers_: A Boolean-flag (default `true`) indicating if all marks in the current plot should be considered "peers" in the clients set used to perform cross-filtering. A peer mark will be exempt from filtering. Set this to false if you are using a cross-filtered selection but want to filter across marks within the same plot.
- _brush_: An optional object of CSS style attribute-value pairs for the selection brush (SVG `rect`) element.

## interval

Select all values within an interval range.

### intervalX

`intervalX(options)`

Select a 1D interval range along the x dimension. The supported _options_ are:

- _as_: The [Selection](../core/selection) to populate with filter predicates.
- _field_: The field to select. If not specified, the field backing the `"x"` encoding channel of the most recently added mark is used.
- _pixelSize_: The size of an interactive "pixel" (default 1). If set larger, the interval brush will "snap" to a grid larger than visible pixels. In some cases this can be helpful to improve scalability to large data by reducing interactive resolution.
- _peers_: A Boolean-flag (default `true`) indicating if all marks in the current plot should be considered "peers" in the clients set used to perform cross-filtering. A peer mark will be exempt from filtering. Set this to false if you are using a cross-filtered selection but want to filter across marks within the same plot.
- _brush_: An optional object of CSS style attribute-value pairs for the selection brush (SVG `rect`) element.

### intervalY

`intervalY(options)`

Select a 1D interval range along the y dimension. The supported _options_ are:

- _as_: The [Selection](../core/selection) to populate with filter predicates.
- _field_: The field to select. If not specified, the field backing the `"y"` encoding channel of the most recently added mark is used.
- _pixelSize_: The size of an interactive "pixel" (default 1). If set larger, the interval brush will "snap" to a grid larger than visible pixels. In some cases this can be helpful to improve scalability to large data by reducing interactive resolution.
- _peers_: A Boolean-flag (default `true`) indicating if all marks in the current plot should be considered "peers" in the clients set used to perform cross-filtering. A peer mark will be exempt from filtering. Set this to false if you are using a cross-filtered selection but want to filter across marks within the same plot.
- _brush_: An optional object of CSS style attribute-value pairs for the selection brush (SVG `rect`) element.

### intervalXY

`intervalXY(options)`

Select a 2D interval range along the x and y dimensions. The supported _options_ are:

- _as_: The [Selection](../core/selection) to populate with filter predicates.
- _xfield_: The x field to select. If not specified, the field backing the `"x"` encoding channel of the most recently added mark is used.
- _yfield_: The y field to select. If not specified, the field backing the `"y"` encoding channel of the most recently added mark is used.
- _pixelSize_: The size of an interactive "pixel" (default 1). If set larger, the interval brush will "snap" to a grid larger than visible pixels. In some cases this can be helpful to improve scalability to large data by reducing interactive resolution.
- _peers_: A Boolean-flag (default `true`) indicating if all marks in the current plot should be considered "peers" in the clients set used to perform cross-filtering. A peer mark will be exempt from filtering. Set this to false if you are using a cross-filtered selection but want to filter across marks within the same plot.
- _brush_: An optional object of CSS style attribute-value pairs for the selection brush (SVG `rect`) element.

## pan & zoom

Pan or zoom a plot.
To pan, click and drag within a plot.
To zoom, scroll within a plot.

Panning and zooming is implemented by changing the `x` and/or `y` scale domains and re-rendering the plot in response.

Pan/zoom interactors will automatically update the plot `xDomain` and `yDomain` attributes.
For linked panning and zooming across plots, first define your own selections and pass them as options.
You can additionally use such selections to have the pan/zoom state filter other marks.

All pan/zoom directives share the same possible _options_:

- _x_: The [Selection](../core/selection) over the `x` encoding channel domain. If unspecified, a new selection instance is used.
- _y_: The [Selection](../core/selection) over the `y` encoding channel domain. If unspecified, a new selection instance is used.
- _xfield_: The x field to select. If not specified, the field backing the `"x"` encoding channel of the most recently added mark is used.
- _yfield_: The y field to select. If not specified, the field backing the `"y"` encoding channel of the most recently added mark is used.

### pan

`pan(options)`

Pan the plot in either the `x` or `y` dimension.
Do not perform zooming.
The supported _options_ are listed above.

### panX

`panX(options)`

Pan the plot in the `x` dimension only.
Do not perform zooming.
The supported _options_ are listed above.

### panY

`panY(options)`

Pan the plot in the `y` dimension only.
Do not perform zooming.
The supported _options_ are listed above.

### panZoom

`panZoom(options)`

Pan or zoom the plot in either the `x` or `y` dimension.
The supported _options_ are listed above.

### panZoomX

`panZoomX(options)`

Pan or zoom the plot in the `x` dimension only.
The supported _options_ are listed above.

### panZoomY

`panZoomY(options)`

Pan or zoom the plot in the `y` dimension only.
The supported _options_ are listed above.


## highlight

### highlight

`highlight(options)`

Highlight selected marks by deemphasizing the others.

[Options](#highlight-options).

</template>

<template v-else-if="language === 'python'">

# Interactors

Interactors imbue plots with interactive behavior, such as selecting or highlighting values, and panning or zooming the display.

To determine which fields (database columns) an interactor should select, an interactor defaults to looking at the corresponding encoding channels for the most recently added mark.
Alternatively, interactors accept options that explicitly indicate which data fields should be selected.

## toggle

### toggle

`toggle(bind=None, channels=None, peers=None)`

Select individual values.

[Options](#toggle-options).

### toggle_x

`toggle_x(bind=None, peers=None)`

Select individual values in the `x` scale domain. Clicking or touching a mark toggles its selection status.

[Options](#togglex-options).

### toggle_y

`toggle_y(bind=None, peers=None)`

Select individual values in the `y` scale domain. Clicking or touching a mark toggles its selection status.

[Options](#toggley-options).

### toggle_z

`toggle_z(bind=None, peers=None)`

Select individual values in the `z` scale domain. Clicking or touching a mark toggles its selection status.

[Options](#togglez-options).

### toggle_color

`toggle_color(bind=None, peers=None)`

Select individual values in the `color` scale domain. Clicking or touching a mark toggles its selection status.

[Options](#togglecolor-options).

## nearest

### nearest

`nearest(bind=None, field=None, channels=None)`

Select values from the mark closest to the pointer.

[Options](#nearest-options).

### nearest_x

`nearest_x(bind=None, field=None, channels=None)`

Select values from the mark closest to the pointer *x* location.

[Options](#nearestx-options).

### nearest_y

`nearest_y(bind=None, field=None, channels=None)`

Select values from the mark closest to the pointer *y* location.

[Options](#nearesty-options).

## region

`region(options)`

Select point values from elements within a rectangular region.
Unlike `interval` interactors (which select a domain value range along an axis), the `region` interactor generates clauses for values extracted from the selected set of on-screen elements. This interactor functions similar to `toggle`, but uses a rectangular selection region rather than click / tap interactions.

To select non-visualized data fields, use the plot `channels` property to define additional named channels, which can then be included in this interactor's _channels_ option.

- _bind_: The [Selection](../core/selection) to populate with filter predicates. A clause of the form `(field = value1) OR (field = value2) ...` is added for the currently selected values.
- _channels_: An array of encoding channels (e.g., `"x"`, `"y"`, `"color"`) indicating the data values to select. A sub-clause will be included for each channel.
- _peers_: A Boolean-flag (default `true`) indicating if all marks in the current plot should be considered "peers" in the clients set used to perform cross-filtering. A peer mark will be exempt from filtering. Set this to false if you are using a cross-filtered selection but want to filter across marks within the same plot.
- _brush_: An optional object of CSS style attribute-value pairs for the selection brush (SVG `rect`) element.

## interval

Select all values within an interval range.

### interval_x

`interval_x(options)`

Select a 1D interval range along the x dimension. The supported _options_ are:

- _bind_: The [Selection](../core/selection) to populate with filter predicates.
- _field_: The field to select. If not specified, the field backing the `"x"` encoding channel of the most recently added mark is used.
- _pixel_size_: The size of an interactive "pixel" (default 1). If set larger, the interval brush will "snap" to a grid larger than visible pixels. In some cases this can be helpful to improve scalability to large data by reducing interactive resolution.
- _peers_: A Boolean-flag (default `true`) indicating if all marks in the current plot should be considered "peers" in the clients set used to perform cross-filtering. A peer mark will be exempt from filtering. Set this to false if you are using a cross-filtered selection but want to filter across marks within the same plot.
- _brush_: An optional object of CSS style attribute-value pairs for the selection brush (SVG `rect`) element.

### interval_y

`interval_y(options)`

Select a 1D interval range along the y dimension. The supported _options_ are:

- _bind_: The [Selection](../core/selection) to populate with filter predicates.
- _field_: The field to select. If not specified, the field backing the `"y"` encoding channel of the most recently added mark is used.
- _pixel_size_: The size of an interactive "pixel" (default 1). If set larger, the interval brush will "snap" to a grid larger than visible pixels. In some cases this can be helpful to improve scalability to large data by reducing interactive resolution.
- _peers_: A Boolean-flag (default `true`) indicating if all marks in the current plot should be considered "peers" in the clients set used to perform cross-filtering. A peer mark will be exempt from filtering. Set this to false if you are using a cross-filtered selection but want to filter across marks within the same plot.
- _brush_: An optional object of CSS style attribute-value pairs for the selection brush (SVG `rect`) element.

### interval_xy

`interval_xy(options)`

Select a 2D interval range along the x and y dimensions. The supported _options_ are:

- _bind_: The [Selection](../core/selection) to populate with filter predicates.
- _xfield_: The x field to select. If not specified, the field backing the `"x"` encoding channel of the most recently added mark is used.
- _yfield_: The y field to select. If not specified, the field backing the `"y"` encoding channel of the most recently added mark is used.
- _pixel_size_: The size of an interactive "pixel" (default 1). If set larger, the interval brush will "snap" to a grid larger than visible pixels. In some cases this can be helpful to improve scalability to large data by reducing interactive resolution.
- _peers_: A Boolean-flag (default `true`) indicating if all marks in the current plot should be considered "peers" in the clients set used to perform cross-filtering. A peer mark will be exempt from filtering. Set this to false if you are using a cross-filtered selection but want to filter across marks within the same plot.
- _brush_: An optional object of CSS style attribute-value pairs for the selection brush (SVG `rect`) element.

## pan & zoom

Pan or zoom a plot.
To pan, click and drag within a plot.
To zoom, scroll within a plot.

Panning and zooming is implemented by changing the `x` and/or `y` scale domains and re-rendering the plot in response.

Pan/zoom interactors will automatically update the plot `x_domain` and `y_domain` attributes.
For linked panning and zooming across plots, first define your own selections and pass them as options.
You can additionally use such selections to have the pan/zoom state filter other marks.

All pan/zoom directives share the same possible _options_:

- _x_: The [Selection](../core/selection) over the `x` encoding channel domain. If unspecified, a new selection instance is used.
- _y_: The [Selection](../core/selection) over the `y` encoding channel domain. If unspecified, a new selection instance is used.
- _xfield_: The x field to select. If not specified, the field backing the `"x"` encoding channel of the most recently added mark is used.
- _yfield_: The y field to select. If not specified, the field backing the `"y"` encoding channel of the most recently added mark is used.

### pan

`pan(options)`

Pan the plot in either the `x` or `y` dimension.
Do not perform zooming.
The supported _options_ are listed above.

### pan_x

`pan_x(options)`

Pan the plot in the `x` dimension only.
Do not perform zooming.
The supported _options_ are listed above.

### pan_y

`pan_y(options)`

Pan the plot in the `y` dimension only.
Do not perform zooming.
The supported _options_ are listed above.

### pan_zoom

`pan_zoom(options)`

Pan or zoom the plot in either the `x` or `y` dimension.
The supported _options_ are listed above.

### pan_zoom_x

`pan_zoom_x(options)`

Pan or zoom the plot in the `x` dimension only.
The supported _options_ are listed above.

### pan_zoom_y

`pan_zoom_y(options)`

Pan or zoom the plot in the `y` dimension only.
The supported _options_ are listed above.


## highlight

### highlight

`highlight(by=None, channels=None, **kwargs)`

Highlight selected marks by deemphasizing the others.

[Options](#highlight-options).

</template>

<LangError v-else :language="language" />

## point options

Options use wire names; Python arguments use the names shown in their signatures.

### ToggleOptions options

**as** (`ParamRef`) — The output selection. A clause of the form `(field = value1) OR (field = value2) ...` is added for the currently selected values.

**peers** (`boolean`) — A flag indicating if peer (sibling) marks are excluded when cross-filtering (default `true`). If set, peer marks will not be filtered by this interactor's selection in cross-filtering setups.

### Toggle options

Extends [`ToggleOptions`](#toggleoptions-options).

**channels** (`Array<string>`) — The encoding channels over which to select values. For a selected mark, selection clauses will cover the backing data fields for each channel.

### ToggleX options

Extends [`ToggleOptions`](#toggleoptions-options).


### ToggleY options

Extends [`ToggleOptions`](#toggleoptions-options).


### ToggleZ options

Extends [`ToggleOptions`](#toggleoptions-options).


### ToggleColor options

Extends [`ToggleOptions`](#toggleoptions-options).


### NearestOptions options

**as** (`ParamRef`) — The output selection. A clause of the form `field = value` is added for the currently nearest value.

**channels** (`Array<string>`) — The encoding channels whose domain values should be selected. For example, a setting of `['color']` selects the data value backing the color channel, whereas `['x', 'z']` selects both x and z channel domain values. If unspecified, the selected channels default to match the current pointer settings: a `nearestX` interactor selects the `['x']` channels, while a `nearest` interactor selects the `['x', 'y']` channels.

**fields** (`Array<string>`) — The fields (database column names) to use in generated selection clause predicates. If unspecified, the fields backing the selected *channels* in the first valid prior mark definition are used by default.

**maxRadius** (`number`) — The maximum radius of a nearest selection (default 40). Marks with (x, y) coordinates outside this radius will not be selected as nearest points.

### Nearest options

Extends [`NearestOptions`](#nearestoptions-options).


### NearestX options

Extends [`NearestOptions`](#nearestoptions-options).


### NearestY options

Extends [`NearestOptions`](#nearestoptions-options).


### Highlight options

**by** (`ParamRef`) — The input selection. Unselected marks are deemphasized.

**opacity** (`number`) — The overall opacity of deemphasized marks. By default the opacity is set to 0.2.

**fillOpacity** (`number`) — The fill opacity of deemphasized marks. By default the fill opacity is unchanged.

**strokeOpacity** (`number`) — The stroke opacity of deemphasized marks. By default the stroke opacity is unchanged.

**fill** (`string`) — The fill color of deemphasized marks. By default the fill is unchanged.

**stroke** (`string`) — The stroke color of deemphasized marks. By default the stroke is unchanged.

**toggle:** Interactors attach to the last preceding mark. Toggle aliases force x, y, z or color; color resolves color, fill, then stroke. Fields are inferred from encodings. Click again to clear; shift/meta-click combines values. Compound channels produce tuples. Native listMatch and unnest options are outside the wire format.

**nearest:** nearest, nearestX and nearestY force xy, x and y pointers. Fields default to the preceding mark; maxRadius defaults to 40. Python’s singular field argument is ignored by native inference and rejected by wire validation; fixed wrappers also reject fields, max_radius and extra kwargs. Use populated data with empty:true for an initially empty selection. Pointerleave clears a Selection but retains a plain Param value.

**highlight:** Highlight queries its Selection against the last mark’s data and dims unselected SVG elements, defaulting to opacity 0.2. Use queried data for active predicates. Clearing restores prior attributes, including literal null attributes. Python accepts channels and camelized extra kwargs, omits None, and lets select override the default; channels is not a wire property.

### point examples

`toggle-filter-peers`: [json](/templates/interactors/point/toggle-filter-peers.json) · [yaml](/templates/interactors/point/toggle-filter-peers.yaml) · [js](/templates/interactors/point/toggle-filter-peers.js) · <a :href="withBase('/templates/interactors/point/toggle-filter-peers.py')" download>Python</a>.


[Selection parameters](../core/selection).
