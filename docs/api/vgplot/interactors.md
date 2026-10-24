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

### region

`region(options)`

Select aspects of individual marks within a 2D range.

[Options](#region-options).

## interval

### intervalX

`intervalX(options)`

Select a continuous 1D interval selection over the `x` scale domain.

[Options](#intervalx-options).

### intervalY

`intervalY(options)`

Select a continuous 1D interval selection over the `y` scale domain.

[Options](#intervaly-options).

### intervalXY

`intervalXY(options)`

Select a continuous 2D interval selection over the `x` and `y` scale domains.

[Options](#intervalxy-options).

## pan & zoom

### pan

`pan(options = {})`

Pan a plot along both the `x` and `y` scales.

[Options](#pan-options).

### panX

`panX(options = {})`

Pan a plot along the `x` scale only.

[Options](#panx-options).

### panY

`panY(options = {})`

Pan a plot along the `y` scale only.

[Options](#pany-options).

### panZoom

`panZoom(options = {})`

Pan and zoom a plot along both the `x` and `y` scales.

[Options](#panzoom-options).

### panZoomX

`panZoomX(options = {})`

Pan and zoom a plot along the `x` scale only.

[Options](#panzoomx-options).

### panZoomY

`panZoomY(options = {})`

Pan and zoom a plot along the `y` scale only.

[Options](#panzoomy-options).

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

### region

`region(bind=None, channels=None, peers=None, brush=None)`

Select aspects of individual marks within a 2D range.

[Options](#region-options).

## interval

### interval_x

`interval_x(bind=None, field=None, pixel_size=None, peers=None, brush=None)`

Select a continuous 1D interval selection over the `x` scale domain.

[Options](#intervalx-options).

### interval_y

`interval_y(bind=None, field=None, pixel_size=None, peers=None, brush=None)`

Select a continuous 1D interval selection over the `y` scale domain.

[Options](#intervaly-options).

### interval_xy

`interval_xy(bind=None, xfield=None, yfield=None, pixel_size=None, peers=None, brush=None)`

Select a continuous 2D interval selection over the `x` and `y` scale domains.

[Options](#intervalxy-options).

## pan & zoom

### pan

`pan(x=None, y=None, xfield=None, yfield=None)`

Pan a plot along both the `x` and `y` scales.

[Options](#pan-options).

### pan_x

`pan_x(x=None, xfield=None)`

Pan a plot along the `x` scale only.

[Options](#panx-options).

### pan_y

`pan_y(y=None, yfield=None)`

Pan a plot along the `y` scale only.

[Options](#pany-options).

### pan_zoom

`pan_zoom(x=None, y=None, xfield=None, yfield=None)`

Pan and zoom a plot along both the `x` and `y` scales.

[Options](#panzoom-options).

### pan_zoom_x

`pan_zoom_x(x=None, xfield=None)`

Pan and zoom a plot along the `x` scale only.

[Options](#panzoomx-options).

### pan_zoom_y

`pan_zoom_y(y=None, yfield=None)`

Pan and zoom a plot along the `y` scale only.

[Options](#panzoomy-options).

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

### Python brush and sort helpers

`brush(**kwargs)` converts snake_case keys to camelCase; `sort(**kwargs)` preserves keys. Both omit `None` and preserve other values. Use brush for brush styling and sort for mark ordering.

## brush options

Options use wire names; Python arguments use the names shown in their signatures.

### BrushStyles options

**opacity** (`number`) — The overall opacity of the brush rectangle.

**fillOpacity** (`number`) — The fill opacity of the brush rectangle.

**strokeOpacity** (`number`) — The stroke opacity of the brush rectangle.

**fill** (`string`) — The fill color of the brush rectangle.

**stroke** (`string`) — The stroke color of the brush rectangle.

**strokeDasharray** (`string`) — The stroke dash array of the brush rectangle.

### Interval1DOptions options

**as** (`ParamRef`) — The output selection. A clause of the form `field BETWEEN lo AND hi` is added for the currently selected interval [lo, hi].

**field** (`string`) — The name of the field (database column) over which the interval selection should be defined. If unspecified, the  channel field of the first valid prior mark definition is used.

**pixelSize** (`number`) — The size of an interactive pixel (default `1`). Larger pixel sizes reduce the brush resolution, which can reduce the size of pre-aggregated materialized views.

**peers** (`boolean`) — A flag indicating if peer (sibling) marks are excluded when cross-filtering (default `true`). If set, peer marks will not be filtered by this interactor's selection in cross-filtering setups.

**brush** (`BrushStyles`) — CSS styles for the brush (SVG `rect`) element.

### IntervalX options

Extends [`Interval1DOptions`](#interval1doptions-options).


### IntervalY options

Extends [`Interval1DOptions`](#interval1doptions-options).


### Interval2DOptions options

**as** (`ParamRef`) — The output selection. A clause of the form `(xfield BETWEEN x1 AND x2) AND (yfield BETWEEN y1 AND y2)` is added for the currently selected intervals.

**xfield** (`string`) — The name of the field (database column) over which the `x`-component of the interval selection should be defined. If unspecified, the `x` channel field of the first valid prior mark definition is used.

**yfield** (`string`) — The name of the field (database column) over which the `y`-component of the interval selection should be defined. If unspecified, the `y` channel field of the first valid prior mark definition is used.

**pixelSize** (`number`) — The size of an interactive pixel (default `1`). Larger pixel sizes reduce the brush resolution, which can reduce the size of pre-aggregated materialized views.

**peers** (`boolean`) — A flag indicating if peer (sibling) marks are excluded when cross-filtering (default `true`). If set, peer marks will not be filtered by this interactor's selection in cross-filtering setups.

**brush** (`BrushStyles`) — CSS styles for the brush (SVG `rect`) element.

### IntervalXY options

Extends [`Interval2DOptions`](#interval2doptions-options).


### RegionOptions options

**as** (`ParamRef`) — The output selection. A clause of the form `(field = value1) OR (field = value2) ...` is added for the currently selected values.

**channels** (`Array<string>`) — The encoding channels over which to select values. For a selected mark, selection clauses will cover the backing data fields for each channel.

**peers** (`boolean`) — A flag indicating if peer (sibling) marks are excluded when cross-filtering (default `true`). If set, peer marks will not be filtered by this interactor's selection in cross-filtering setups.

**brush** (`BrushStyles`) — CSS styles for the brush (SVG `rect`) element.

### Region options

Extends [`RegionOptions`](#regionoptions-options).


**interval:** Each interactor attaches to the last preceding mark. IntervalX and intervalY force their x or y channel after caller options. Fields are inferred from that mark unless field, xfield or yfield is provided. Pixel sizes quantize SVG coordinates downward before domain inversion; zero falls back to one. Domain intervals are sorted even when the screen scale is reversed. Brush clearing removes the selection clause. Resetting an interactor only clears its local brush state; Selection.reset clears the selection itself. Peer exclusion defaults to all sibling marks and can be disabled. Crossed facets share one domain selection across per-panel brushes.

**interval:** Known limitation: a plot with only a horizontal facet scale retains a malformed transform suffix in its brush groups. Use crossed facets for the runnable faceted starter; a single horizontal facet has this rendering limitation.

**region:** Region selects backing channel values from SVG elements intersecting its screen rectangle, including translated facet groups, and deduplicates equal tuples. Channels are required at runtime; color resolves color, fill, then stroke. Missing channels throw an error. Peer exclusion defaults to all sibling marks. The default brush uses fill none, currentColor stroke and a 1,1 dash pattern. Native style sanitization converts names to SVG attributes and retains additional names; strict wire values allow only BrushStyles fields.

### brush examples

`crossed-facets`: [json](/templates/interactors/brush/crossed-facets.json) · [yaml](/templates/interactors/brush/crossed-facets.yaml) · [js](/templates/interactors/brush/crossed-facets.js) · <a :href="withBase('/templates/interactors/brush/crossed-facets.py')" download>Python</a>.

[Selection parameters](../core/selection).

## Navigation options

Drag to pan and scroll to zoom. Each directive attaches to the last preceding mark. Fields default to that mark's x and y channels. The interactor updates plot domains through selections; pass the same selections to other plots to link their domains. Selection clauses retain their source and all sibling marks as clients, and can also drive filters. An external selection update changes all listening plots. Domains are initialized by plot attributes; the selection receives its interval after a drag or wheel update. The axis-specific wrappers disable the other axis, and pan wrappers disable zoom after caller options. Omitting options creates independent selections for that interactor.

### PanZoomOptions options

**x** (`ParamRef`) — The output selection for the `x` domain. A clause of the form `field BETWEEN x1 AND x2` is added for the current pan/zom interval [x1, x2].

**y** (`ParamRef`) — The output selection for the `y` domain. A clause of the form `field BETWEEN y1 AND y2` is added for the current pan/zom interval [y1, y2].

**xfield** (`string`) — The name of the field (database column) over which the `x`-component of the pan/zoom interval should be defined. If unspecified, the `x` channel field of the first valid prior mark definition is used.

**yfield** (`string`) — The name of the field (database column) over which the `y`-component of the pan/zoom interval should be defined. If unspecified, the `y` channel field of the first valid prior mark definition is used.

### Pan options

Extends [`PanZoomOptions`](#panzoomoptions-options).


### PanX options

Extends [`PanZoomOptions`](#panzoomoptions-options).


### PanY options

Extends [`PanZoomOptions`](#panzoomoptions-options).


### PanZoom options

Extends [`PanZoomOptions`](#panzoomoptions-options).


### PanZoomX options

Extends [`PanZoomOptions`](#panzoomoptions-options).


### PanZoomY options

Extends [`PanZoomOptions`](#panzoomoptions-options).


Use Selection objects for x and y. Passing null to an enabled axis throws when the runtime registers its listener. Ordinary value parameters do not implement the selection activation protocol. Python omits None values, while retaining false, zero and empty values; supplying such values does not make them valid runtime Selection objects.

Native JavaScript accepts zoom, panx and pany booleans or numeric extents. These controls are outside the strict declarative contract and Python signatures. The renderer resets its D3 transform at gesture end: zoom extents constrain each gesture, not the cumulative data-domain scale. With zoom=[1,2], a fresh zoom-out cannot undo a previous gesture, while repeated zoom-ins can exceed an overall twofold scale.
### navigation examples

`linked-x-domains`: [json](/templates/interactors/navigation/linked-x-domains.json) · [yaml](/templates/interactors/navigation/linked-x-domains.yaml) · [js](/templates/interactors/navigation/linked-x-domains.js) · <a :href="withBase('/templates/interactors/navigation/linked-x-domains.py')" download>Python</a>.


[Selection parameters](../core/selection).
