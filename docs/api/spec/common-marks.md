<script setup>
import { withBase } from 'vitepress';
</script>

# Common mark contracts

Shared channels and options for mark families. Inherited fields are documented under their parent contract.

## Examples

- `parameter-channel`: [json](/templates/marks/common/parameter-channel.json) · [yaml](/templates/marks/common/parameter-channel.yaml) · [js](/templates/marks/common/parameter-channel.js) · <a :href="withBase('/templates/marks/common/parameter-channel.py')" download>Python</a>

Python examples use `mark`, `channels`, and `directive`; JavaScript examples use named mark factories.

## Target behavior

- The wire and TypeScript contracts describe channel value objects with value, scale, or interval fields. The retained source-backed mark runtime currently treats those objects as SQL expressions and cannot execute them; runnable examples use primitive field references and time-interval axis ticks.
- ChannelDomainOptions.limit has optional tuple positions in TypeScript, while the preserved wire and native contracts require both positions.
- Curve excludes auto. CurveOptions narrows CurveAutoOptions in TypeScript; its ParamRef branch remains an unrestricted wire string and therefore also admits auto.
- ChannelReducers is generic in TypeScript. Its standalone native contract validates the declared Reducer default specialization.
- A channel interval is a string in the existing wire contract, even though the conditional TypeScript Interval type can admit numbers.

The standalone native definitions are available in `packages/vgplot/spec/src/generated/common-marks.cue`. Use the composed schema to validate complete plot specifications.

## Python helpers

### mark

Create a mark. When specifying a mark channel’s value, you can provide a {value, scale} object to override the scale that would normally be associated with the channel.

```python
def mark(name: str, data: MarkData = None, **enc: Any) -> Mark
```

### channels

The set of known channel names. Create a channel mapping while preserving the supplied keys.

```python
def channels(**kwargs: str) -> dict[str, str]
```

### directive

Create a plot directive with a key and value.

```python
def directive(key: str, value: Any) -> Directive
```


## Data options

| Python option | Wire property | Meaning |
| --- | --- | --- |
| `filter_by` | `filterBy` | A selection that filters the mark data. |
| `optimize` | `optimize` | A flag (default `true`) to enable any mark-specific query optimizations. If `false`, optimizations are disabled to aid testing and debugging. |

## Contract reference

## ChannelName

The set of known channel names.

```ts
type ChannelName = 'ariaLabel' | 'fill' | 'fillOpacity' | 'fontSize' | 'fx' | 'fy' | 'geometry' | 'height' | 'href' | 'length' | 'opacity' | 'path' | 'r' | 'rotate' | 'src' | 'stroke' | 'strokeOpacity' | 'strokeWidth' | 'symbol' | 'text' | 'title' | 'weight' | 'width' | 'x' | 'x1' | 'x2' | 'y' | 'y1' | 'y2' | 'z';
```


## ChannelValue

A channel’s values may be expressed as:

- a field name, to extract the corresponding value for each datum
- an iterable of values, typically of the same length as the data
- a channel transform or SQL expression
- a constant number or boolean
- null to represent no value

```ts
type ChannelValue = Array<any> | (string & Record<never, never>) | number | boolean | null | Transform | SQLExpression | AggregateExpression;
```


## ChannelValueSpec

When specifying a mark channel’s value, you can provide a {value, scale} object to override the scale that would normally be associated with the channel.

```ts
type ChannelValueSpec = ChannelValue | { value: ChannelValue; label?: string; scale?: ScaleName | 'auto' | boolean | null; };
```


## ChannelValueIntervalSpec

In some contexts, when specifying a mark channel’s value, you can provide a {value, interval} object to specify an associated interval.

```ts
type ChannelValueIntervalSpec = ChannelValueSpec | { value: ChannelValue; interval: Interval; };
```


## ChannelDomainValue

The available inputs for imputing scale domains. In addition to a named channel, an input may be specified as:

- *data* - impute from mark data
- *width* - impute from |*x2* - *x1*|
- *height* - impute from |*y2* - *y1*|
- null - impute from input order

If the *x* channel is not defined, the *x2* channel will be used instead if available, and similarly for *y* and *y2*; this is useful for marks that implicitly stack. The *data* input is typically used in conjunction with a custom **reduce** function, as when the built-in single-channel reducers are insufficient.

```ts
type ChannelDomainValue = ChannelDomainName | `-${ChannelDomainName}` | null;
```


## ChannelDomainOptions

Options for imputing scale domains from channel values.

| Property | Type | Presence | Description |
| --- | --- | --- | --- |
| `reduce` | `` Reducer \| boolean \| null `` | optional | How to produce a singular value (for subsequent sorting) from aggregated channel values; one of:<br><br>- true (default) - alias for *max*<br>- false or null - disabled; don’t impute the scale domain<br>- a named reducer implementation such as *count* or *sum*<br>- a function that takes an array of values and returns the reduced value<br>- an object that implements the *reduceIndex* method |
| `order` | `` 'ascending' \| 'descending' \| null `` | optional | How to order reduced values. |
| `reverse` | `` boolean `` | optional | If true, reverse the order after sorting. |
| `limit` | `` number \| [lo?: number, hi?: number] `` | optional | If a positive number, limit the domain to the first *n* sorted values. If a negative number, limit the domain to the last *-n* sorted values. Hence, a positive **limit** with **reverse** true will return the top *n* values in descending order.<br><br>If an array [*lo*, *hi*], slices the sorted domain from *lo* (inclusive) to<br>*hi* (exclusive). As with [*array*.slice](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/slice), if either *lo* or *hi* are negative, it indicates an offset from the end of the array; if *lo* is undefined it defaults to 0, and if *hi* is undefined it defaults to Infinity.<br><br>Note: limiting the imputed domain of one scale, say *x*, does not affect the imputed domain of another scale, say *y*; each scale domain is imputed independently. |


## ChannelDomainValueSpec

How to derive a scale’s domain from a channel’s values.

```ts
type ChannelDomainValueSpec = ChannelDomainValue | ({ value: ChannelDomainValue; }) & (ChannelDomainOptions);
```


## ChannelDomainSort

How to impute scale domains from channel values.

```ts
type ChannelDomainSort = ({ [key in ScaleName]?: ChannelDomainValueSpec }) & (ChannelDomainOptions);
```


## ChannelReducers

Output channels for aggregating transforms, such as bin and group. Each
declared output channel has an associated reducer, and typically a
corresponding input channel in *options*. Non-grouping channels declared in
*options* but not *outputs* are computed on reduced data after grouping,
which defaults to the array of data for the current group.

If **title** is in *options* but not *outputs*, the reducer defaults to
summarizing the most common values. If **href** is in *options* but not
*outputs*, the reducer defaults to *first*. When **x1** or **x2** is in
*outputs*, reads the input channel **x** if **x1** or **x2** is not in
*options*; likewise for **y1** or **y2**, reads the input channel **y** if
**y1** or **y2** is not in *options*.

```ts
type ChannelReducers<T = Reducer> = { [key in ChannelName]?: T | { reduce: T; scale?: ChannelScale; } | null };
```


## ChannelStates

Abstract (unscaled) values, and associated scale, per channel.

```ts
type ChannelStates = { [key in ChannelName]?: { value: Array<any>; scale: ScaleName | null; } };
```


## ChannelValues

Possibly-scaled values for each channel.

```ts
type ChannelValues = ({ [key in ChannelName]?: Array<any> }) & ({ channels: ChannelStates; });
```


## SortOrder

How to order values; one of:

- a function for comparing data, returning a signed number
- a channel value definition for sorting given values in ascending order
- a {value, order} object for sorting given values
- a {channel, order} object for sorting the named channel’s values

```ts
type SortOrder = ChannelValue | { value?: ChannelValue; order?: 'ascending' | 'descending'; } | { channel?: ChannelName | `-${ChannelName}`; order?: 'ascending' | 'descending'; };
```


## TipPointer

The pointer mode for the tip; corresponds to pointerX, pointerY, and pointer.

```ts
type TipPointer = 'x' | 'y' | 'xy';
```


## SelectFilter

Selection filters to apply internally to mark data.

```ts
type SelectFilter = 'first' | 'last' | 'maxX' | 'maxY' | 'minX' | 'minY' | 'nearest' | 'nearestX' | 'nearestY';
```


## MarkData

The MarkData contract.

| Property | Type | Presence | Description |
| --- | --- | --- | --- |
| `data` | `` PlotMarkData `` | required | The data source for the mark. |


## MarkDataOptional

The MarkDataOptional contract.

| Property | Type | Presence | Description |
| --- | --- | --- | --- |
| `data` | `` PlotMarkData `` | optional | See [MarkData.data](#markdata).  |


## MarkOptions

Shared options for all marks.

| Property | Type | Presence | Description |
| --- | --- | --- | --- |
| `filter` | `` ChannelValue `` | optional | Applies a transform to filter the mark’s index according to the given channel values; only truthy values are retained.<br><br>Note that filtering only affects the rendered mark index, not the associated channel values, and has no effect on imputed scale domains. |
| `select` | `` SelectFilter `` | optional | Applies a filter transform after data is loaded to highlight selected values only. For example, `first` and `last` select the first or last values of series only (using the *z* channel to separate series). Meanwhile, `nearestX` and `nearestY` select the point nearest to the pointer along the *x* or *y* channel dimension. Unlike Mosaic selections, a mark level *select* is internal to the mark only, and does not populate a param or selection value to be shared across clients.<br><br>Note that filtering only affects the rendered mark index, not the associated channel values, and has no effect on imputed scale domains. |
| `reverse` | `` boolean \| ParamRef `` | optional | Applies a transform to reverse the order of the mark’s index, say for reverse input order. |
| `sort` | `` SortOrder \| ChannelDomainSort `` | optional | Either applies a transform to sort the mark’s index by the specified channel values, or imputes ordinal scale domains from this mark’s channels.<br><br>When imputing ordinal scale domains from channel values, the **sort** option is an object whose keys are ordinal scale names such as *x* or *fx*, and whose values are channel names such as *y*, *y1*, or *y2*. For example, to impute the *y* scale’s domain from the associated *x* channel values in ascending order:<br><br>```js sort: {y: "x"} ```<br><br>For different sort options for different scales, replace the channel name with a *value* object and per-scale options:<br><br>```js sort: {y: {value: "-x"}} ```<br><br>When sorting the mark’s index, the **sort** option is instead one of:<br><br>- a channel value definition for sorting given values in ascending order<br>- a {value, order} object for sorting given values<br>- a {channel, order} object for sorting the named channel’s values |
| `fx` | `` ChannelValue `` | optional | The horizontal facet position channel, for mark-level faceting, bound to the *fx* scale. |
| `fy` | `` ChannelValue `` | optional | The vertical facet position channel, for mark-level faceting, bound to the<br>*fy* scale. |
| `facet` | `` 'auto' \| 'include' \| 'exclude' \| 'super' \| boolean \| null \| ParamRef `` | optional | Whether to enable or disable faceting; one of:<br><br>- *auto* (default) - automatically determine if this mark should be faceted<br>- *include* (or true) - draw the subset of the mark’s data in the current facet<br>- *exclude* - draw the subset of the mark’s data *not* in the current facet<br>- *super* - draw this mark in a single frame that covers all facets<br>- null (or false) - repeat this mark’s data across all facets (*i.e.*, no faceting)<br><br>When a mark uses *super* faceting, it is not allowed to use position scales (*x*, *y*, *fx*, or *fy*); *super* faceting is intended for decorations, such as labels and legends.<br><br>When top-level faceting is used, the default *auto* setting is equivalent to *include* when the mark data is strictly equal to the top-level facet data; otherwise it is equivalent to null. When the *include* or *exclude* facet mode is chosen, the mark data must be parallel to the top-level facet data: the data must have the same length and order. If the data are not parallel, then the wrong data may be shown in each facet. The default<br>*auto* therefore requires strict equality (`===`) for safety, and using the facet data as mark data is recommended when using the *exclude* facet mode. (To construct parallel data safely, consider using [*array*.map](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/map) on the facet data.)<br><br>When mark-level faceting is used, the default *auto* setting is equivalent to *include*: the mark will be faceted if either the **fx** or **fy** channel option (or both) is specified. The null or false option will disable faceting, while *exclude* draws the subset of the mark’s data *not* in the current facet. |
| `facetAnchor` | `` 'top' \| 'right' \| 'bottom' \| 'left' \| 'top-left' \| 'top-right' \| 'bottom-left' \| 'bottom-right' \| 'top-empty' \| 'right-empty' \| 'bottom-empty' \| 'left-empty' \| 'empty' \| null \| ParamRef `` | optional | How to place the mark with respect to facets; one of:<br><br>- null (default for most marks) - display the mark in each non-empty facet<br>- *top*, *right*, *bottom*, or *left* - display the mark only in facets on   the given side<br>- *top-empty*, *right-empty*, *bottom-empty*, or *left-empty* (default for   axis marks) - display the mark only in facets that have empty space on   the given side: either the margin, or an empty facet<br>- *empty* - display the mark in empty facets only |
| `margin` | `` number \| ParamRef `` | optional | Shorthand to set the same default for all four mark margins: **marginTop**,<br>**marginRight**, **marginBottom**, and **marginLeft**; typically defaults to 0, except for axis marks. |
| `marginTop` | `` number \| ParamRef `` | optional | The mark’s top margin; the minimum distance in pixels between the top edges of the inner and outer plot area. |
| `marginRight` | `` number \| ParamRef `` | optional | The mark’s right margin; the minimum distance in pixels between the right edges of the mark’s inner and outer plot area. |
| `marginBottom` | `` number \| ParamRef `` | optional | The mark’s bottom margin; the minimum distance in pixels between the bottom edges of the inner and outer plot area. |
| `marginLeft` | `` number \| ParamRef `` | optional | The mark’s left margin; the minimum distance in pixels between the left edges of the inner and outer plot area. |
| `ariaDescription` | `` string \| ParamRef `` | optional | The [aria-description](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Attributes/aria-description); a constant textual description. |
| `ariaHidden` | `` string \| ParamRef `` | optional | The [aria-hidden](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Attributes/aria-hidden) state; a constant indicating whether the element is exposed to an accessibility API. |
| `ariaLabel` | `` ChannelValue `` | optional | The [aria-label](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Attributes/aria-label); a channel specifying short textual labels representing the value in the accessibility tree. |
| `pointerEvents` | `` string \| ParamRef `` | optional | The [pointer-events](https://developer.mozilla.org/en-US/docs/Web/CSS/pointer-events) property; a constant string such as *none*. |
| `title` | `` ChannelValue `` | optional | The title; a channel specifying accessible, short textual descriptions as strings (possibly with newlines). If the tip option is specified, the title will be displayed with an interactive tooltip instead of using the SVG [title element](https://developer.mozilla.org/en-US/docs/Web/SVG/Element/title). |
| `tip` | `` boolean \| TipPointer \| (TipOptions) &amp; ({ pointer?: TipPointer; }) \| ParamRef `` | optional | Whether to generate a tooltip for this mark, and any tip options. |
| `channels` | `` { [key: string]: string } `` | optional | Additional named channels, for example to include in a tooltip. Consists of (channel name, data field name) key-value pairs. |
| `clip` | `` 'frame' \| 'sphere' \| boolean \| null \| ParamRef `` | optional | How to clip the mark; one of:<br><br>- *frame* or true - clip to the plot’s frame (inner area)<br>- *sphere* - clip to the projected sphere (*e.g.*, front hemisphere)<br>- null or false - do not clip<br><br>The *sphere* clip option requires a geographic projection. |
| `dx` | `` number \| ParamRef `` | optional | The horizontal offset in pixels; a constant option. On low-density screens, an additional 0.5px offset may be applied for crisp edges. |
| `dy` | `` number \| ParamRef `` | optional | The vertical offset in pixels; a constant option. On low-density screens, an additional 0.5px offset may be applied for crisp edges. |
| `fill` | `` ChannelValueSpec \| ParamRef `` | optional | The [fill](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/fill); a constant CSS color string, or a channel typically bound to the *color* scale. If all channel values are valid CSS colors, by default the channel will not be bound to the *color* scale, interpreting the colors literally. |
| `fillOpacity` | `` ChannelValueSpec \| ParamRef `` | optional | The [fill-opacity](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/fill-opacity); a constant number between 0 and 1, or a channel typically bound to the *opacity* scale. If all channel values are numbers in [0, 1], by default the channel will not be bound to the *opacity* scale, interpreting the opacities literally. |
| `stroke` | `` ChannelValueSpec \| ParamRef `` | optional | The [stroke](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/stroke); a constant CSS color string, or a channel typically bound to the *color* scale. If all channel values are valid CSS colors, by default the channel will not be bound to the *color* scale, interpreting the colors literally. |
| `strokeDasharray` | `` string \| number \| ParamRef `` | optional | The [stroke-dasharray](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/stroke-dasharray); a constant number indicating the length in pixels of alternating dashes and gaps, or a constant string of numbers separated by spaces or commas (_e.g._, *10 2* for dashes of 10 pixels separated by gaps of 2 pixels), or *none* (the default) for no dashing |
| `strokeDashoffset` | `` string \| number \| ParamRef `` | optional | The [stroke-dashoffset](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/stroke-dashoffset); a constant indicating the offset in pixels of the first dash along the stroke; defaults to zero. |
| `strokeLinecap` | `` string \| ParamRef `` | optional | The [stroke-linecap](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/stroke-linecap); a constant specifying how to cap stroked paths, such as *butt*, *round*, or *square*. |
| `strokeLinejoin` | `` string \| ParamRef `` | optional | The [stroke-linejoin](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/stroke-linejoin); a constant specifying how to join stroked paths, such as *bevel*, *miter*, *miter-clip*, or *round*. |
| `strokeMiterlimit` | `` number \| ParamRef `` | optional | The [stroke-miterlimit](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/stroke-miterlimit); a constant number specifying how to limit the length of *miter* joins on stroked paths. |
| `strokeOpacity` | `` ChannelValueSpec `` | optional | The [stroke-opacity](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/stroke-opacity); a constant between 0 and 1, or a channel typically bound to the *opacity* scale. If all channel values are numbers in [0, 1], by default the channel will not be bound to the *opacity* scale, interpreting the opacities literally. |
| `strokeWidth` | `` ChannelValueSpec `` | optional | The [stroke-width](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/stroke-width); a constant number in pixels, or a channel. |
| `opacity` | `` ChannelValueSpec `` | optional | The [opacity](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/opacity); a constant between 0 and 1, or a channel typically bound to the *opacity* scale. If all channel values are numbers in [0, 1], by default the channel will not be bound to the *opacity* scale, interpreting the opacities literally. For faster rendering, prefer the **strokeOpacity** or **fillOpacity** option. |
| `mixBlendMode` | `` string \| ParamRef `` | optional | The [mix-blend-mode](https://developer.mozilla.org/en-US/docs/Web/CSS/mix-blend-mode); a constant string specifying how to blend content such as *multiply*. |
| `imageFilter` | `` string \| ParamRef `` | optional | A CSS [filter](https://developer.mozilla.org/en-US/docs/Web/CSS/filter); a constant string used to adjust the rendering of images, such as *blur(5px)*. |
| `paintOrder` | `` string \| ParamRef `` | optional | The [paint-order](https://developer.mozilla.org/en-US/docs/Web/CSS/paint-order); a constant string specifying the order in which the<br>**fill**, **stroke**, and any markers are drawn; defaults to *normal*, which draws the fill, then stroke, then markers; defaults to *stroke* for the text mark to create a “halo” around text to improve legibility. |
| `shapeRendering` | `` string \| ParamRef `` | optional | The [shape-rendering](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/shape-rendering); a constant string such as *crispEdges*. |
| `href` | `` ChannelValue `` | optional | The [href](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/href); a channel specifying URLs for clickable links. May be used in conjunction with the **target** option to open links in another window. |
| `target` | `` string \| ParamRef `` | optional | The [target](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/target); a constant string specifying the target window (_e.g._,<br>*_blank*) for clickable links; used in conjunction with the **href** option. |


## InsetOptions

Options for insetting rectangular shapes.

| Property | Type | Presence | Description |
| --- | --- | --- | --- |
| `inset` | `` number \| ParamRef `` | optional | Shorthand to set the same default for all four insets: **insetTop**,<br>**insetRight**, **insetBottom**, and **insetLeft**. All insets typically default to zero, though not always (say when using bin transform). A positive inset reduces effective area, while a negative inset increases it. |
| `insetTop` | `` number \| ParamRef `` | optional | Insets the top edge by the specified number of pixels. A positive value insets towards the bottom edge (reducing effective area), while a negative value insets away from the bottom edge (increasing it). |
| `insetRight` | `` number \| ParamRef `` | optional | Insets the right edge by the specified number of pixels. A positive value insets towards the left edge (reducing effective area), while a negative value insets away from the left edge (increasing it). |
| `insetBottom` | `` number \| ParamRef `` | optional | Insets the bottom edge by the specified number of pixels. A positive value insets towards the top edge (reducing effective area), while a negative value insets away from the top edge (increasing it). |
| `insetLeft` | `` number \| ParamRef `` | optional | Insets the left edge by the specified number of pixels. A positive value insets towards the right edge (reducing effective area), while a negative value insets away from the right edge (increasing it). |


## TextStyles

Options for styling text (independent of anchor position).

| Property | Type | Presence | Description |
| --- | --- | --- | --- |
| `textAnchor` | `` 'start' \| 'middle' \| 'end' \| ParamRef `` | optional | The [text anchor](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/text-anchor) controls how text is aligned (typically horizontally) relative to its anchor point; it is one of *start*, *end*, or *middle*. If the frame anchor is *left*, *top-left*, or *bottom-left*, the default text anchor is *start*; if the frame anchor is *right*, *top-right*, or<br>*bottom-right*, the default is *end*; otherwise it is *middle*. |
| `lineHeight` | `` number \| ParamRef `` | optional | The line height in ems; defaults to 1. The line height affects the (typically vertical) separation between adjacent baselines of text, as well as the separation between the text and its anchor point. |
| `lineWidth` | `` number \| ParamRef `` | optional | The line width in ems (e.g., 10 for about 20 characters); defaults to infinity, disabling wrapping and clipping.<br><br>If **textOverflow** is null, lines will be wrapped at the specified length. If a line is split at a soft hyphen (\xad), a hyphen (-) will be displayed at the end of the line. If **textOverflow** is not null, lines will be clipped according to the given strategy. |
| `textOverflow` | `` null \| 'clip' \| 'ellipsis' \| 'clip-start' \| 'clip-end' \| 'ellipsis-start' \| 'ellipsis-middle' \| 'ellipsis-end' \| ParamRef `` | optional | How truncate (or wrap) lines of text longer than the given **lineWidth**; one of:<br><br>- null (default) - preserve overflowing characters (and wrap if needed)<br>- *clip* or *clip-end* - remove characters from the end<br>- *clip-start* - remove characters from the start<br>- *ellipsis* or *ellipsis-end* - replace characters from the end with an ellipsis (…)<br>- *ellipsis-start* - replace characters from the start with an ellipsis (…)<br>- *ellipsis-middle* - replace characters from the middle with an ellipsis (…)<br><br>If no **title** was specified, if text requires truncation, a title containing the non-truncated text will be implicitly added. |
| `monospace` | `` boolean \| ParamRef `` | optional | If true, changes the default **fontFamily** to *monospace*, and uses simplified monospaced text metrics calculations. |
| `fontFamily` | `` string \| ParamRef `` | optional | The [font-family](https://developer.mozilla.org/en-US/docs/Web/CSS/font-family); a constant; defaults to the plot’s font family, which is typically [*system-ui*](https://drafts.csswg.org/css-fonts-4/#valdef-font-family-system-ui). |
| `fontSize` | `` ChannelValue \| ParamRef `` | optional | The [font size](https://developer.mozilla.org/en-US/docs/Web/CSS/font-size) in pixels; either a constant or a channel; defaults to the plot’s font size, which is typically 10. When a number, it is interpreted as a constant; otherwise it is interpreted as a channel. |
| `fontStyle` | `` string \| ParamRef `` | optional | The [font style](https://developer.mozilla.org/en-US/docs/Web/CSS/font-style); a constant; defaults to the plot’s font style, which is typically *normal*. |
| `fontVariant` | `` string \| ParamRef `` | optional | The [font variant](https://developer.mozilla.org/en-US/docs/Web/CSS/font-variant); a constant; if the **text** channel contains numbers or dates, defaults to *tabular-nums* to facilitate comparing numbers; otherwise defaults to the plot’s font style, which is typically *normal*. |
| `fontWeight` | `` string \| number \| ParamRef `` | optional | The [font weight](https://developer.mozilla.org/en-US/docs/Web/CSS/font-weight); a constant; defaults to the plot’s font weight, which is typically *normal*. |


## TipOptions

Options for the tip mark.

Extends [`MarkOptions`](#markoptions), [`TextStyles`](#textstyles).

| Property | Type | Presence | Description |
| --- | --- | --- | --- |
| `x` | `` ChannelValueSpec `` | optional | The horizontal position channel specifying the tip’s anchor, typically bound to the *x* scale. |
| `x1` | `` ChannelValueSpec `` | optional | The starting horizontal position channel specifying the tip’s anchor, typically bound to the *x* scale. |
| `x2` | `` ChannelValueSpec `` | optional | The ending horizontal position channel specifying the tip’s anchor, typically bound to the *x* scale. |
| `y` | `` ChannelValueSpec `` | optional | The vertical position channel specifying the tip’s anchor, typically bound to the *y* scale. |
| `y1` | `` ChannelValueSpec `` | optional | The starting vertical position channel specifying the tip’s anchor, typically bound to the *y* scale. |
| `y2` | `` ChannelValueSpec `` | optional | The ending vertical position channel specifying the tip’s anchor, typically bound to the *y* scale. |
| `frameAnchor` | `` FrameAnchor \| ParamRef `` | optional | The frame anchor specifies defaults for **x** and **y** based on the plot’s frame; it may be one of the four sides (*top*, *right*, *bottom*, *left*), one of the four corners (*top-left*, *top-right*, *bottom-right*,<br>*bottom-left*), or the *middle* of the frame. For example, for tips distributed horizontally at the top of the frame:<br><br>```js Plot.tip(data, {x: "date", frameAnchor: "top"}) ``` |
| `anchor` | `` FrameAnchor \| ParamRef `` | optional | The tip anchor specifies how to orient the tip box relative to its anchor position; it refers to the part of the tip box that is attached to the anchor point. For example, the *top-left* anchor places the top-left corner of tip box near the anchor position, hence placing the tip box below and to the right of the anchor position. |
| `preferredAnchor` | `` FrameAnchor \| null \| ParamRef `` | optional | If an explicit tip anchor is not specified, an anchor is chosen automatically such that the tip fits within the plot’s frame; if the preferred anchor fits, it is chosen. |
| `format` | `` { [name in ChannelName]?: boolean \| string \| ParamRef } `` | optional | How channel values are formatted for display. If a format is a string, it is interpreted as a (UTC) time format for temporal channels, and otherwise a number format. |
| `pathFilter` | `` string \| ParamRef `` | optional | The image filter for the tip’s box; defaults to a drop shadow. |
| `pointerSize` | `` number \| ParamRef `` | optional | The size of the tip’s pointer in pixels; defaults to 12. |
| `textPadding` | `` number \| ParamRef `` | optional | The padding around the text in pixels; defaults to 8. |


## Curve

How to interpolate between control points.

```ts
type Curve = CurveName;
```


## CurveOptions

Options for marks that support curves, such as lines and areas.

Extends [`CurveAutoOptions`](#curveautooptions).

| Property | Type | Presence | Description |
| --- | --- | --- | --- |
| `curve` | `` Curve \| ParamRef `` | optional | The curve (interpolation) method for connecting adjacent points. One of:<br><br>- *basis* - a cubic basis spline (repeating the end points)<br>- *basis-open* - an open cubic basis spline<br>- *basis-closed* - a closed cubic basis spline<br>- *bump-x* - a Bézier curve with horizontal tangents<br>- *bump-y* - a Bézier curve with vertical tangents<br>- *bundle* - a straightened cubic basis spline (suitable for lines only, not areas)<br>- *cardinal* - a cubic cardinal spline (with one-sided differences at the ends)<br>- *cardinal-open* - an open cubic cardinal spline<br>- *cardinal-closed* - an closed cubic cardinal spline<br>- *catmull-rom* - a cubic Catmull–Rom spline (with one-sided differences at the ends)<br>- *catmull-rom-open* - an open cubic Catmull–Rom spline<br>- *catmull-rom-closed* - a closed cubic Catmull–Rom spline<br>- *linear* - a piecewise linear curve (*i.e.*, straight line segments)<br>- *linear-closed* - a closed piecewise linear curve (*i.e.*, straight line segments)<br>- *monotone-x* - a cubic spline that preserves monotonicity in *x*<br>- *monotone-y* - a cubic spline that preserves monotonicity in *y*<br>- *natural* - a natural cubic spline<br>- *step* - a piecewise constant function where *y* changes at the midpoint of *x*<br>- *step-after* - a piecewise constant function where *y* changes after *x*<br>- *step-before* - a piecewise constant function where *x* changes after *y* |


## CurveAutoOptions

Options for marks that support possibly-projected curves.

| Property | Type | Presence | Description |
| --- | --- | --- | --- |
| `curve` | `` Curve \| 'auto' \| ParamRef `` | optional | See [CurveOptions.curve](#curveoptions). - *auto* (default) - like *linear*, but use the (possibly spherical) projection, if any<br><br>The *auto* curve is typically used in conjunction with a spherical projection to interpolate along geodesics. |
| `tension` | `` number \| ParamRef `` | optional | The tension option only has an effect on bundle, cardinal and Catmull–Rom splines (*bundle*, *cardinal*, *cardinal-open*, *cardinal-closed*,<br>*catmull-rom*, *catmull-rom-open*, and *catmull-rom-closed*). For bundle splines, it corresponds to [beta](https://d3js.org/d3-shape/curve#curveBundle_beta); for cardinal splines, [tension](https://d3js.org/d3-shape/curve#curveCardinal_tension); for Catmull–Rom splines, [alpha](https://d3js.org/d3-shape/curve#curveCatmullRom_alpha). |


## StackOffsetName

A built-in stack offset method; one of:

- *normalize* - rescale each stack to fill [0, 1]
- *center* - align the centers of all stacks
- *wiggle* - translate stacks to minimize apparent movement

If a given stack has zero total value, the *normalize* offset will not adjust the stack’s position. Both the *center* and *wiggle* offsets ensure that the lowest element across stacks starts at zero for better default axes. The
*wiggle* offset is recommended for streamgraphs in conjunction with the
*inside-out* order. For more, see [Byron & Wattenberg](https://leebyron.com/streamgraph/).

```ts
type StackOffsetName = 'center' | 'normalize' | 'wiggle';
```


## StackOffset

A stack offset method; one of:

- *normalize* - rescale each stack to fill [0, 1]
- *center* - align the centers of all stacks
- *wiggle* - translate stacks to minimize apparent movement

If a given stack has zero total value, the *normalize* offset will not adjust the stack’s position. Both the *center* and *wiggle* offsets ensure that the lowest element across stacks starts at zero for better default axes. The
*wiggle* offset is recommended for streamgraphs in conjunction with the
*inside-out* order. For more, see [Byron & Wattenberg](https://leebyron.com/streamgraph/).

```ts
type StackOffset = StackOffsetName;
```


## StackOrderName

The built-in stack order methods; one of:

- *x* - alias of *value*; for stackX only
- *y* - alias of *value*; for stackY only
- *value* - ascending value (or descending with **reverse**)
- *sum* - total value per series
- *appearance* - position of maximum value per series
- *inside-out* (default with *wiggle*) - order the earliest-appearing series on the inside

The *inside-out* order is recommended for streamgraphs in conjunction with the *wiggle* offset. For more, see [Byron & Wattenberg](https://leebyron.com/streamgraph/).

```ts
type StackOrderName = 'value' | 'x' | 'y' | 'z' | 'sum' | 'appearance' | 'inside-out';
```


## StackOrder

How to order layers prior to stacking; one of:

- a named stack order method such as *inside-out* or *sum*
- a field name, for natural order of the corresponding values
- an array of explicit **z** values in the desired order

```ts
type StackOrder = StackOrderName | `-${StackOrderName}` | (string & Record<never, never>) | Array<any>;
```


## StackOptions

Options for the stack transform.

| Property | Type | Presence | Description |
| --- | --- | --- | --- |
| `offset` | `` StackOffset \| null \| ParamRef `` | optional | After stacking, an optional **offset** can be applied to translate and scale stacks, say to produce a streamgraph; defaults to null for a zero baseline (**y** = 0 for stackY, and **x** = 0 for stackX). If the *wiggle* offset is used, the default **order** changes to *inside-out*. |
| `order` | `` StackOrder \| null \| ParamRef `` | optional | The order in which stacks are layered; one of:<br><br>- null (default) for input order<br>- a named stack order method such as *inside-out* or *sum*<br>- a field name, for natural order of the corresponding values<br>- a function of data, for natural order of the corresponding values<br>- an array of explicit **z** values in the desired order<br><br>If the *wiggle* **offset** is used, as for a streamgraph, the default changes to *inside-out*. |
| `reverse` | `` boolean \| ParamRef `` | optional | If true, reverse the effective order of the stacks. |
| `z` | `` ChannelValue `` | optional | The **z** channel defines the series of each value in the stack. Used when the **order** is *sum*, *appearance*, *inside-out*, or an explicit array of<br>**z** values. |


## MarkerName

The built-in marker implementations; one of:

- *arrow* - an arrowhead with *auto* orientation
- *arrow-reverse* - an arrowhead with *auto-start-reverse* orientation
- *dot* - a filled *circle* with no stroke and 2.5px radius
- *circle-fill* - a filled circle with a white stroke and 3px radius
- *circle-stroke* - a stroked circle with a white fill and 3px radius
- *circle* - alias for *circle-fill*
- *tick* - a small opposing line
- *tick-x* - a small horizontal line
- *tick-y* - a small vertical line

```ts
type MarkerName = 'arrow' | 'arrow-reverse' | 'dot' | 'circle' | 'circle-fill' | 'circle-stroke' | 'tick' | 'tick-x' | 'tick-y';
```


## MarkerOptions

Options for marks that support markers, such as lines and links.

| Property | Type | Presence | Description |
| --- | --- | --- | --- |
| `marker` | `` MarkerName \| 'none' \| boolean \| null \| ParamRef `` | optional | Shorthand to set the same default for markerStart, markerMid, and markerEnd; one of:<br><br>- a marker name such as *arrow* or *circle*<br>- *none* (default) - no marker<br>* true - alias for *circle-fill*<br>* false or null - alias for *none* |
| `markerStart` | `` MarkerName \| 'none' \| boolean \| null \| ParamRef `` | optional | The marker for the starting point of a line segment; one of:<br><br>- a marker name such as *arrow* or *circle*<br>* *none* (default) - no marker<br>* true - alias for *circle-fill*<br>* false or null - alias for *none* |
| `markerMid` | `` MarkerName \| 'none' \| boolean \| null \| ParamRef `` | optional | The marker for any middle (interior) points of a line segment. If the line segment only has a start and end point, this option has no effect. One of:<br><br>- a marker name such as *arrow* or *circle*<br>* *none* (default) - no marker<br>* true - alias for *circle-fill*<br>* false or null - alias for *none*<br>* a function - a custom marker function; see below |
| `markerEnd` | `` MarkerName \| 'none' \| boolean \| null \| ParamRef `` | optional | The marker for the ending point of a line segment; one of:<br><br>- a marker name such as *arrow* or *circle*<br>* *none* (default) - no marker<br>* true - alias for *circle-fill*<br>* false or null - alias for *none* |