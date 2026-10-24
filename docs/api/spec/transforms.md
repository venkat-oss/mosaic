<script setup>
import { withBase } from 'vitepress';
</script>

# Transform contracts

## Expressions and Column Transforms

Column transforms derive one value per source row. JavaScript calls the
existing SQL or plot function; Python builds a declarative dictionary for
the specification parser. These host representations have different purposes.
See the [SQL expression API](/api/sql/expressions) for expression and query methods.

Python helpers have the signature `helper(col: TransformArg, **options: Any)`.
Their options retain raw keys and values, including `None`, and may override
the transform's discriminator. This permissive authoring behavior does not
broaden the declared wire schema. A unary wire argument may be a scalar or a
singleton tuple; empty and longer tuples are rejected by the owning contract.

Spatial transforms require DuckDB's `spatial` extension. Declare it in
`config.extensions`, or install and load it before executing JavaScript queries.
Use the geojson transform to pass geometry results to a geo mark.

### Column examples

- `bin`: [YAML](/templates/transforms/column/bin.yaml) · [JSON](/templates/transforms/column/bin.json) · [JavaScript](/templates/transforms/column/bin.js) · <a :href="withBase('/templates/transforms/column/bin.py')" download>Python</a>.
- `sql`: [YAML](/templates/transforms/column/sql.yaml) · [JSON](/templates/transforms/column/sql.json) · [JavaScript](/templates/transforms/column/sql.js) · <a :href="withBase('/templates/transforms/column/sql.py')" download>Python</a>.
- [TypeScript aggregate expression](/templates/transforms/column/aggregate-expression.ts).

### bin

Bin a continuous variable into discrete intervals. The bin argument specifies a data column or expression to bin. Both numerical and temporal (date/time) values are supported.

JavaScript: `bin(column, options?)`, from `@uwdata/mosaic-plot`.
Python: `bin(col: TransformArg, **options: Any)`.

| Property | Type | Required | Description |
| --- | --- | --- | --- |
| `bin` | `Unary<TransformField>` | true | Bin a continuous variable into discrete intervals. The bin argument specifies a data column or expression to bin. Both numerical and temporal (date/time) values are supported. |
| `interval` | `BinInterval` | false | The interval bin unit to use, typically used to indicate a date/time unit for binning temporal values, such as `hour`, `day`, or `month`. If `date`, the extent of data values is used to automatically select an interval for temporal data. The value `number` enforces normal numerical binning, even over temporal data. If unspecified, defaults to `number` for numerical data and `date` for temporal data. |
| `step` | `number` | false | The step size to use between bins. When binning numerical values (or interval type `number`), this setting specifies the numerical step size. For data/time intervals, this indicates the number of steps of that unit, such as hours, days, or years. |
| `steps` | `number` | false | The target number of binning steps to use. To accommodate human-friendly ("nice") bin boundaries, the actual number of bins may diverge from this exact value. This option is ignored when **step** is specified. |
| `minstep` | `number` | false | The minimum allowed bin step size (default `0`) when performing numerical binning. For example, a setting of `1` prevents step sizes less than 1. This option is ignored when **step** is specified. |
| `nice` | `boolean` | false | A flag (default `true`) requesting "nice" human-friendly end points and step sizes when performing numerical binning. When **step** is specified, this option affects the binning end points (e.g., origin) only. |
| `offset` | `number` | false | Offset for computed bins (default `0`). For example, a value of `1` will result in using the next consecutive bin boundary. |


### column

Interpret a string or param-value as a column reference.

JavaScript: `column(column)`, from `@uwdata/mosaic-sql`.
Python: `column(col: TransformArg, **options: Any)`.

| Property | Type | Required | Description |
| --- | --- | --- | --- |
| `column` | `Unary<string \| ParamRef>` | true | Interpret a string or param-value as a column reference. |


### dateMonth

Transform a Date value to a month boundary for cyclic comparison. Year values are collapsed to enable comparison over months only.

JavaScript: `dateMonth(column)`, from `@uwdata/mosaic-sql`.
Python: `date_month(col: TransformArg, **options: Any)`.

| Property | Type | Required | Description |
| --- | --- | --- | --- |
| `dateMonth` | `Unary<TransformField \| Date>` | true | Transform a Date value to a month boundary for cyclic comparison. Year values are collapsed to enable comparison over months only. |


### dateMonthDay

Transform a Date value to a month and day boundary for cyclic comparison. Year values are collapsed to enable comparison over months and days only.

JavaScript: `dateMonthDay(column)`, from `@uwdata/mosaic-sql`.
Python: `date_month_day(col: TransformArg, **options: Any)`.

| Property | Type | Required | Description |
| --- | --- | --- | --- |
| `dateMonthDay` | `Unary<TransformField \| Date>` | true | Transform a Date value to a month and day boundary for cyclic comparison. Year values are collapsed to enable comparison over months and days only. |


### dateDay

Transform a Date value to a day of the month for cyclic comparison. Year and month values are collapsed to enable comparison over days only.

JavaScript: `dateDay(column)`, from `@uwdata/mosaic-sql`.
Python: `date_day(col: TransformArg, **options: Any)`.

| Property | Type | Required | Description |
| --- | --- | --- | --- |
| `dateDay` | `Unary<TransformField \| Date>` | true | Transform a Date value to a day of the month for cyclic comparison. Year and month values are collapsed to enable comparison over days only. |


### centroid

Compute the 2D centroid of geometry-typed data. This transform requires the DuckDB `spatial` extension.

JavaScript: `centroid(column)`, from `@uwdata/mosaic-sql`.
Python: `centroid(col: TransformArg, **options: Any)`.

| Property | Type | Required | Description |
| --- | --- | --- | --- |
| `centroid` | `Unary<TransformField>` | true | Compute the 2D centroid of geometry-typed data. This transform requires the DuckDB `spatial` extension. |


### centroidX

Compute the centroid x-coordinate of geometry-typed data. This transform requires the DuckDB `spatial` extension.

JavaScript: `centroidX(column)`, from `@uwdata/mosaic-sql`.
Python: `centroid_x(col: TransformArg, **options: Any)`.

| Property | Type | Required | Description |
| --- | --- | --- | --- |
| `centroidX` | `Unary<TransformField>` | true | Compute the centroid x-coordinate of geometry-typed data. This transform requires the DuckDB `spatial` extension. |


### centroidY

Compute the centroid y-coordinate of geometry-typed data. This transform requires the DuckDB `spatial` extension.

JavaScript: `centroidY(column)`, from `@uwdata/mosaic-sql`.
Python: `centroid_y(col: TransformArg, **options: Any)`.

| Property | Type | Required | Description |
| --- | --- | --- | --- |
| `centroidY` | `Unary<TransformField>` | true | Compute the centroid y-coordinate of geometry-typed data. This transform requires the DuckDB `spatial` extension. |


### geojson

Compute a GeoJSON-formatted string from geometry-typed data. This transform requires the DuckDB `spatial` extension.

JavaScript: `geojson(column)`, from `@uwdata/mosaic-sql`.
Python: `geojson(col: TransformArg, **options: Any)`.

| Property | Type | Required | Description |
| --- | --- | --- | --- |
| `geojson` | `Unary<TransformField>` | true | Compute a GeoJSON-formatted string from geometry-typed data. This transform requires the DuckDB `spatial` extension. |


## Expression Contracts

`sql` is a JavaScript template tag and a Python `sql(expr: str)` helper.
A declarative SQL expression uses `{"sql": "x + $offset"}`. `$offset` binds
a value parameter; `$$column` binds a column-valued parameter. Quoted SQL
strings and identifiers retain their existing tokenization behavior.

`SQLExpression` also declares an optional `label`. The current parser drops
that label when normalizing an expression. `AggregateExpression` is declared by the wire and TypeScript
contracts, but the parser retains an `agg` object as a literal instead of
constructing an aggregate expression. Use the supported aggregate helpers
when an evaluated aggregate is needed.

`AggregateExpression` has the optional label illustrated by the example above.
The SQL example's initial expression is `x + $offset` with
`offset = 1`.

### Expression

A custom scalar or aggregate SQL expression.

```ts
/**
 * A custom scalar or aggregate SQL expression.
 */
export type Expression = SQLExpression | AggregateExpression;
```

### SQLExpression

A custom SQL expression.

```ts
/**
 * A custom SQL expression.
 */
export interface SQLExpression {
  /**
   * A SQL expression string to derive a new column value. Embedded Param references, such as `$param + 1`, are supported. For expressions with aggregate functions, use *agg* instead.
   */
  sql: string;

  /**
   * A label for this expression, for example to label a plot axis.
   */
  label?: string;
}
```

### AggregateExpression

A custom SQL aggregate expression.

```ts
/**
 * A custom SQL aggregate expression.
 */
export interface AggregateExpression {
  /**
   * A SQL expression string to calculate an aggregate value. Embedded Param references, such as `SUM($param + 1)`, are supported. For expressions without aggregate functions, use *sql* instead.
   */
  agg: string;

  /**
   * A label for this expression, for example to label a plot axis.
   */
  label?: string;
}
```

## Shared Field and Frame Contracts

These field and frame types also appear in aggregate and window contracts.
They describe argument admission; the query engines implement their
semantics. Native JavaScript Date values adapt to date-time strings in the
wire schema for date transforms. This differs from a parameter's `date`
property, whose existing wire contract is an unrestricted string.

### TransformField

A field argument to a data transform.

```ts
/**
 * A field argument to a data transform.
 */
export type TransformField = string | ParamRef | SQLExpression | Transform;
```

### FrameExclude

Window frame exclusion modes.

```ts
/**
 * Window frame exclusion modes.
 */
export type FrameExclude = 'CURRENT ROW' | 'GROUP' | 'TIES' | 'NO OTHERS';
```

### FrameValue

A numeric, temporal interval, or unbounded window frame bound.

```ts
export type FrameValue = number | IntervalTransform | null;
```

### WindowOptions

Window transform options.

```ts
/**
 * Window transform options.
 */
export interface WindowOptions {
  orderby?: TransformField | Array<TransformField>;

  partitionby?: TransformField | Array<TransformField>;

  rows?: [FrameValue, FrameValue] | ParamRef;

  range?: [FrameValue, FrameValue] | ParamRef;

  groups?: [FrameValue, FrameValue] | ParamRef;

  exclude?: Uppercase<FrameExclude> | Lowercase<FrameExclude>;
}
```

### BinInterval

Binning interval names.

```ts
/**
 * Binning interval names.
 */
export type BinInterval = 'date' | 'number' | 'millisecond' | 'second' | 'minute' | 'hour' | 'day' | 'month' | 'year';
```

### Argument Shapes

| Shape | Meaning |
| --- | --- |
| `Nullary` | A zero argument transform signature. |
| `Unary<T>` | A single argument transform signature. |
| `Binary<T>` | A two argument transform signature; both arguments are required. |

## Aggregate Transforms

Aggregate transforms combine values within groups. A plot groups by its
non-aggregate channels. JavaScript calls the SQL expression functions;
Python helpers create dictionaries for the specification parser.
See [SQL aggregates](/api/sql/aggregate-functions) for the query methods.

`distinct` selects distinct input values. `orderby`, `partitionby`, `rows`,
`range`, `groups` and `exclude` turn the expression into a windowed aggregate.
JavaScript uses expression methods such as `.distinct()`, `.orderby(...)`,
`.partitionby(...)` and `.frame(vg.frameRows(...))`; Python passes these as
keyword options. Python retains raw option keys and values, including `None`,
and an option may override the transform discriminator. Parser normalization
and code generation may omit null or falsy options.

JavaScript `count()` counts all rows. Python `count()` emits `{"count": ""}`;
`count(None)` emits `{"count": None}`. The wire signature accepts null, an empty
tuple, or a field argument. The parser normalizes a nullary count to an empty
string, which is also wire-valid through the unary string-field alternative.

DuckDB `quantile` function computes a discrete quantile.
For an even-sized group, `quantile(column, 0.5)` can differ from `median(column)`.

`covariance`, `covarPop` and `geomean` have exported TypeScript interfaces,
JavaScript functions and parser registrations, but are absent from the
`AggregateTransform` wire union and Python API.

The additional JavaScript-only exports below have no declarative transform
interface, parser registration or Python helper.

### Aggregate example

- `avg`: [YAML](/templates/transforms/aggregate/avg.yaml) · [JSON](/templates/transforms/aggregate/avg.json) · [JavaScript](/templates/transforms/aggregate/avg.js) · <a :href="withBase('/templates/transforms/aggregate/avg.py')" download>Python</a>.

### argmax

Find a value of the first column that maximizes the second column.

JavaScript: `argmax(col, by)`, from `@uwdata/mosaic-sql`.
Python: `argmax(col, by, **options: Any)`.

```ts
/**
 * An argmax aggregate transform.
 */
export interface Argmax extends AggregateOptions, WindowOptions {
  /**
   * Find a value of the first column that maximizes the second column.
   */
  argmax: Binary<TransformField>;
}
```


### argmin

Find a value of the first column that minimizes the second column.

JavaScript: `argmin(col, by)`, from `@uwdata/mosaic-sql`.
Python: `argmin(col, by, **options: Any)`.

```ts
/**
 * An argmin aggregate transform.
 */
export interface Argmin extends AggregateOptions, WindowOptions {
  /**
   * Find a value of the first column that minimizes the second column.
   */
  argmin: Binary<TransformField>;
}
```


### avg

Compute the average (mean) value of the given column.

JavaScript: `avg(col)`, from `@uwdata/mosaic-sql`.
Python: `avg(col, **options: Any)`.

```ts
/**
 * An avg (average, or mean) aggregate transform.
 */
export interface Avg extends AggregateOptions, WindowOptions {
  /**
   * Compute the average (mean) value of the given column.
   */
  avg: Unary<TransformField>;
}
```


### count

Compute the count of records in an aggregation group.

JavaScript: `count(col?)`, from `@uwdata/mosaic-sql`.
Python: `count(col = UNSET, **options: Any)`.

```ts
/**
 * A count aggregate transform.
 */
export interface Count extends AggregateOptions, WindowOptions {
  /**
   * Compute the count of records in an aggregation group.
   */
  count: Nullary | Unary<TransformField>;
}
```


### covariance

Compute the sample covariance of between the given columns.

JavaScript: `covariance(col, by)`, from `@uwdata/mosaic-sql`.


```ts
/**
 * A sample covariance aggregate transform.
 */
export interface Covariance extends AggregateOptions, WindowOptions {
  /**
   * Compute the sample covariance of between the given columns.
   */
  covariance: Binary<TransformField>;
}
```


### covarPop

Compute the population covariance of between the given columns.

JavaScript: `covarPop(col, by)`, from `@uwdata/mosaic-sql`.


```ts
/**
 * A population covariance aggregate transform.
 */
export interface CovarPop extends AggregateOptions, WindowOptions {
  /**
   * Compute the population covariance of between the given columns.
   */
  covarPop: Binary<TransformField>;
}
```


### first

Return the first column value found in an aggregation group.

JavaScript: `first(col)`, from `@uwdata/mosaic-sql`.
Python: `first(col, **options: Any)`.

```ts
/**
 * A first aggregate transform.
 */
export interface First extends AggregateOptions, WindowOptions {
  /**
   * Return the first column value found in an aggregation group.
   */
  first: Unary<TransformField>;
}
```


### geomean

Compute the geometric mean value of the given column.

JavaScript: `geomean(col)`, from `@uwdata/mosaic-sql`.


```ts
/**
 * A geometric mean aggregate transform.
 */
export interface Geomean extends AggregateOptions, WindowOptions {
  /**
   * Compute the geometric mean value of the given column.
   */
  geomean: Unary<TransformField>;
}
```


### last

Return the last column value found in an aggregation group.

JavaScript: `last(col)`, from `@uwdata/mosaic-sql`.
Python: `last(col, **options: Any)`.

```ts
/**
 * A last aggregate transform.
 */
export interface Last extends AggregateOptions, WindowOptions {
  /**
   * Return the last column value found in an aggregation group.
   */
  last: Unary<TransformField>;
}
```


### max

Compute the maximum value of the given column.

JavaScript: `max(col)`, from `@uwdata/mosaic-sql`.
Python: `max(col, **options: Any)`.

```ts
/**
 * A max aggregate transform.
 */
export interface Max extends AggregateOptions, WindowOptions {
  /**
   * Compute the maximum value of the given column.
   */
  max: Unary<TransformField>;
}
```


### min

Compute the minimum value of the given column.

JavaScript: `min(col)`, from `@uwdata/mosaic-sql`.
Python: `min(col, **options: Any)`.

```ts
/**
 * A min aggregate transform.
 */
export interface Min extends AggregateOptions, WindowOptions {
  /**
   * Compute the minimum value of the given column.
   */
  min: Unary<TransformField>;
}
```


### median

Compute the median value of the given column.

JavaScript: `median(col)`, from `@uwdata/mosaic-sql`.
Python: `median(col, **options: Any)`.

```ts
/**
 * A median aggregate transform.
 */
export interface Median extends AggregateOptions, WindowOptions {
  /**
   * Compute the median value of the given column.
   */
  median: Unary<TransformField>;
}
```


### mode

Compute the mode value of the given column.

JavaScript: `mode(col)`, from `@uwdata/mosaic-sql`.
Python: `mode(col, **options: Any)`.

```ts
/**
 * A mode aggregate transform.
 */
export interface Mode extends AggregateOptions, WindowOptions {
  /**
   * Compute the mode value of the given column.
   */
  mode: Unary<TransformField>;
}
```


### product

Compute the product of the given column.

JavaScript: `product(col)`, from `@uwdata/mosaic-sql`.
Python: `product(col, **options: Any)`.

```ts
/**
 * A product aggregate transform.
 */
export interface Product extends AggregateOptions, WindowOptions {
  /**
   * Compute the product of the given column.
   */
  product: Unary<TransformField>;
}
```


### quantile

Compute the quantile value of the given column at the provided probability threshold. For example, 0.5 is the median.

JavaScript: `quantile(col, p)`, from `@uwdata/mosaic-sql`.
Python: `quantile(col, p, **options: Any)`.

```ts
/**
 * A quantile aggregate transform.
 */
export interface Quantile extends AggregateOptions, WindowOptions {
  /**
   * Compute the quantile value of the given column at the provided probability threshold. For example, 0.5 is the median.
   */
  quantile: [expr: TransformField, p: TransformField | number];
}
```


### stddev

Compute the sum of the given column.

JavaScript: `stddev(col)`, from `@uwdata/mosaic-sql`.
Python: `stddev(col, **options: Any)`.

```ts
/**
 * A sample standard deviation aggregate transform.
 */
export interface Stddev extends AggregateOptions, WindowOptions {
  /**
   * Compute the sum of the given column.
   */
  stddev: Unary<TransformField>;
}
```


### stddevPop

Compute the sum of the given column.

JavaScript: `stddevPop(col)`, from `@uwdata/mosaic-sql`.
Python: `stddev_pop(col, **options: Any)`.

```ts
/**
 * A population standard deviation aggregate transform.
 */
export interface StddevPop extends AggregateOptions, WindowOptions {
  /**
   * Compute the sum of the given column.
   */
  stddevPop: Unary<TransformField>;
}
```


### sum

Compute the sum of the given column.

JavaScript: `sum(col)`, from `@uwdata/mosaic-sql`.
Python: `sum(col, **options: Any)`.

```ts
/**
 * A sum aggregate transform.
 */
export interface Sum extends AggregateOptions, WindowOptions {
  /**
   * Compute the sum of the given column.
   */
  sum: Unary<TransformField>;
}
```


### variance

Compute the sample variance of the given column.

JavaScript: `variance(col)`, from `@uwdata/mosaic-sql`.
Python: `variance(col, **options: Any)`.

```ts
/**
 * A sample variance aggregate transform.
 */
export interface Variance extends AggregateOptions, WindowOptions {
  /**
   * Compute the sample variance of the given column.
   */
  variance: Unary<TransformField>;
}
```


### varPop

Compute the population variance of the given column.

JavaScript: `varPop(col)`, from `@uwdata/mosaic-sql`.
Python: `var_pop(col, **options: Any)`.

```ts
/**
 * A population variance aggregate transform.
 */
export interface VarPop extends AggregateOptions, WindowOptions {
  /**
   * Compute the population variance of the given column.
   */
  varPop: Unary<TransformField>;
}
```


### JavaScript-only Aggregate Exports

#### arrayAgg

Compute an array aggregation.

JavaScript: `arrayAgg(expr)`, from `@uwdata/mosaic-sql`.

#### corr

Compute a correlation aggregate.

JavaScript: `corr(x, y)`, from `@uwdata/mosaic-sql`.

#### entropy

Compute an entropy aggregate.

JavaScript: `entropy(expr)`, from `@uwdata/mosaic-sql`.

#### kurtosis

Compute a sample kurtosis aggregate.

JavaScript: `kurtosis(expr)`, from `@uwdata/mosaic-sql`.

#### mad

Compute a median absolute deviation (MAD) aggregate.

JavaScript: `mad(expr)`, from `@uwdata/mosaic-sql`.

#### skewness

Compute a skewness aggregate.

JavaScript: `skewness(expr)`, from `@uwdata/mosaic-sql`.

#### stringAgg

Compute a string aggregation.

JavaScript: `stringAgg(expr)`, from `@uwdata/mosaic-sql`.

## Window Transforms

Window transforms calculate values over ordered partitions. JavaScript calls
the SQL expression functions; Python helpers build dictionaries consumed by
the specification parser. Use `orderby`, `partitionby`, `rows`, `range`,
`groups` and `exclude` to configure a window, or the corresponding JavaScript
expression methods. The SQL engines execute the calculations.
See [SQL window functions](/api/sql/window-functions) for query methods.

The five nullary functions accept null or an empty tuple in a wire specification.
Python helpers return a null argument; JavaScript calls omit the argument.
The parser normalizes both wire forms to an empty string in `toJSON()`, which
remains outside the nullary wire signature. Python code generation emits the
no-argument helper, restoring its null dictionary representation.

TypeScript permits omitted lag/lead tuple offset and default members, while the
existing wire schema requires all three tuple positions. A scalar field is
accepted by both. The default value may be a date-time string in wire data or
a native Date in TypeScript. Python signatures use `UNSET` for optional
arguments and retain their historical omission compression: `lag("x",
default=None)` emits `{"lag": ["x", None]}`. An explicit null offset is kept.

`ntile` retains a field/expression argument in the declaration and wire schema.
A bare numeric bucket count is rejected there; use a SQL constant
expression such as `{"sql": "2"}`.

### row_number

Compute the 1-based row number over an ordered window partition.

JavaScript: `row_number()`, from `@uwdata/mosaic-sql`.
Python: `row_number(**options: Any)`.

```ts
/**
 * A row_number window transform.
 */
export interface RowNumber extends WindowOptions {
  /**
   * Compute the 1-based row number over an ordered window partition.
   */
  row_number: Nullary;
}
```


### rank

Compute the row rank over an ordered window partition. Sorting ties result in gaps in the rank numbers ([1, 1, 3, ...]).

JavaScript: `rank()`, from `@uwdata/mosaic-sql`.
Python: `rank(**options: Any)`.

```ts
/**
 * A rank window transform.
 */
export interface Rank extends WindowOptions {
  /**
   * Compute the row rank over an ordered window partition. Sorting ties result in gaps in the rank numbers ([1, 1, 3, ...]).
   */
  rank: Nullary;
}
```


### dense_rank

Compute the dense row rank (no gaps) over an ordered window partition. Sorting ties do not result in gaps in the rank numbers ([1, 1, 2, ...]).

JavaScript: `dense_rank()`, from `@uwdata/mosaic-sql`.
Python: `dense_rank(**options: Any)`.

```ts
/**
 * A dense_rank window transform.
 */
export interface DenseRank extends WindowOptions {
  /**
   * Compute the dense row rank (no gaps) over an ordered window partition. Sorting ties do not result in gaps in the rank numbers ([1, 1, 2, ...]).
   */
  dense_rank: Nullary;
}
```


### percent_rank

Compute the percentage rank over an ordered window partition.

JavaScript: `percent_rank()`, from `@uwdata/mosaic-sql`.
Python: `percent_rank(**options: Any)`.

```ts
/**
 * A percent_rank window transform.
 */
export interface PercentRank extends WindowOptions {
  /**
   * Compute the percentage rank over an ordered window partition.
   */
  percent_rank: Nullary;
}
```


### cume_dist

Compute the cumulative distribution value over an ordered window partition. Equals the number of partition rows preceding or peer with the current row, divided by the total number of partition rows.

JavaScript: `cume_dist()`, from `@uwdata/mosaic-sql`.
Python: `cume_dist(**options: Any)`.

```ts
/**
 * A cume_dist window transform.
 */
export interface CumeDist extends WindowOptions {
  /**
   * Compute the cumulative distribution value over an ordered window partition. Equals the number of partition rows preceding or peer with the current row, divided by the total number of partition rows.
   */
  cume_dist: Nullary;
}
```


### ntile

Compute an n-tile integer ranging from 1 to the provided argument (num_buckets), dividing the partition as equally as possible.

JavaScript: `ntile(buckets)`, from `@uwdata/mosaic-sql`.
Python: `ntile(buckets, **options: Any)`.

```ts
/**
 * An ntile window transform.
 */
export interface NTile extends WindowOptions {
  /**
   * Compute an n-tile integer ranging from 1 to the provided argument (num_buckets), dividing the partition as equally as possible.
   */
  ntile: Unary<TransformField>;
}
```


### lag

Compute lagging values in a column. Returns the value at the row that is `offset` (second argument, default `1`) rows before the current row within the window frame. If there is no such row, instead return `default` (third argument, default `null`). Both offset and default are evaluated with respect to the current row.

JavaScript: `lag(col, offset?, default?)`, from `@uwdata/mosaic-sql`.
Python: `lag(col, offset = UNSET, default = UNSET, **options: Any)`.

```ts
/**
 * A lag window transform.
 */
export interface Lag extends WindowOptions {
  /**
   * Compute lagging values in a column. Returns the value at the row that is `offset` (second argument, default `1`) rows before the current row within the window frame. If there is no such row, instead return `default` (third argument, default `null`). Both offset and default are evaluated with respect to the current row.
   */
  lag: ArgLagLead;
}
```


### lead

Compute leading values in a column. Returns the value at the row that is `offset` (second argument, default `1`) rows after the current row within the window frame. If there is no such row, instead return `default` (third argument, default `null`). Both offset and default are evaluated with respect to the current row.

JavaScript: `lead(col, offset?, default?)`, from `@uwdata/mosaic-sql`.
Python: `lead(col, offset = UNSET, default = UNSET, **options: Any)`.

```ts
/**
 * A lead window transform.
 */
export interface Lead extends WindowOptions {
  /**
   * Compute leading values in a column. Returns the value at the row that is `offset` (second argument, default `1`) rows after the current row within the window frame. If there is no such row, instead return `default` (third argument, default `null`). Both offset and default are evaluated with respect to the current row.
   */
  lead: ArgLagLead;
}
```


### first_value

Get the first value of the given column in the current window frame.

JavaScript: `first_value(col)`, from `@uwdata/mosaic-sql`.
Python: `first_value(col, **options: Any)`.

```ts
/**
 * A first_value window transform.
 */
export interface FirstValue extends WindowOptions {
  /**
   * Get the first value of the given column in the current window frame.
   */
  first_value: Unary<TransformField>;
}
```


### last_value

Get the last value of the given column in the current window frame.

JavaScript: `last_value(col)`, from `@uwdata/mosaic-sql`.
Python: `last_value(col, **options: Any)`.

```ts
/**
 * A last_value window transform.
 */
export interface LastValue extends WindowOptions {
  /**
   * Get the last value of the given column in the current window frame.
   */
  last_value: Unary<TransformField>;
}
```


### nth_value

Get the nth value of the given column in the current window frame, counting from one. The second argument is the offset for the nth row.

JavaScript: `nth_value(col, offset)`, from `@uwdata/mosaic-sql`.
Python: `nth_value(col, offset, **options: Any)`.

```ts
/**
 * An nth_value window transform.
 */
export interface NthValue extends WindowOptions {
  /**
   * Get the nth value of the given column in the current window frame, counting from one. The second argument is the offset for the nth row.
   */
  nth_value: [expr: TransformField, nth: TransformField | number];
}
```


### Lag and Lead Argument Contract

```ts
type ArgLagLead = TransformField | [expr: TransformField, offset?: TransformField | number, defaultValue?: TransformField | number | boolean | Date | null];
```

### Window Frames

Frame bounds contain exactly two values: a number, a date/time interval, or
null. A null bound means unbounded. JavaScript frame helpers retain the SQL
engine's offset interpretation, including zero as the current row. Frame
exclusion accepts all-uppercase or all-lowercase modes; the parser normalizes
exclusion to uppercase.

The parser chooses the first truthy frame key in the order shown below. A
parameter reference may provide a whole frame; individual string bounds stay
literals rather than becoming parameter references. Custom WindowFrameNode
types retain the existing computed helper-name fallback.

| Frame key | SQL type | JavaScript utility |
| --- | --- | --- |
| `rows` | `ROWS` | `frameRows(extent, exclude?)` |
| `range` | `RANGE` | `frameRange(extent, exclude?)` |
| `groups` | `GROUPS` | `frameGroups(extent, exclude?)` |

### Window examples

- `frame-parameter`: [YAML](/templates/transforms/window/frame-parameter.yaml) · [JSON](/templates/transforms/window/frame-parameter.json) · [JavaScript](/templates/transforms/window/frame-parameter.js) · <a :href="withBase('/templates/transforms/window/frame-parameter.py')" download>Python</a>.
- [JavaScript interval utility](/templates/transforms/window/generic-interval.js).

## Date/Time Intervals

Date/time interval transforms use a numeric value and remain JavaScript
utilities. Python has no interval or frame factory: use their dictionaries
in specification options. Python code generation preserves those interval
dictionaries instead of inventing Python utility calls.

```ts
/**
 * Date/time interval.
 */
export type IntervalTransform = Years | Months | Days | Hours | Minutes | Seconds | Milliseconds | Microseconds;
```

### years

A date/time interval in units of years.

JavaScript: `years(value)`, from `@uwdata/mosaic-sql`.

```ts
/**
 * A date/time interval in units of years.
 */
export interface Years {
  /**
   * A date/time interval in units of years.
   */
  years: number;
}
```

### months

A date/time interval in units of months.

JavaScript: `months(value)`, from `@uwdata/mosaic-sql`.

```ts
/**
 * A date/time interval in units of months.
 */
export interface Months {
  /**
   * A date/time interval in units of months.
   */
  months: number;
}
```

### days

A date/time interval in units of days.

JavaScript: `days(value)`, from `@uwdata/mosaic-sql`.

```ts
/**
 * A date/time interval in units of days.
 */
export interface Days {
  /**
   * A date/time interval in units of days.
   */
  days: number;
}
```

### hours

A date/time interval in units of hours.

JavaScript: `hours(value)`, from `@uwdata/mosaic-sql`.

```ts
/**
 * A date/time interval in units of hours.
 */
export interface Hours {
  /**
   * A date/time interval in units of hours.
   */
  hours: number;
}
```

### minutes

A date/time interval in units of minutes.

JavaScript: `minutes(value)`, from `@uwdata/mosaic-sql`.

```ts
/**
 * A date/time interval in units of minutes.
 */
export interface Minutes {
  /**
   * A date/time interval in units of minutes.
   */
  minutes: number;
}
```

### seconds

A date/time interval in units of seconds.

JavaScript: `seconds(value)`, from `@uwdata/mosaic-sql`.

```ts
/**
 * A date/time interval in units of seconds.
 */
export interface Seconds {
  /**
   * A date/time interval in units of seconds.
   */
  seconds: number;
}
```

### milliseconds

A date/time interval in units of milliseconds.

JavaScript: `milliseconds(value)`, from `@uwdata/mosaic-sql`.

```ts
/**
 * A date/time interval in units of milliseconds.
 */
export interface Milliseconds {
  /**
   * A date/time interval in units of milliseconds.
   */
  milliseconds: number;
}
```

### microseconds

A date/time interval in units of microseconds.

JavaScript: `microseconds(value)`, from `@uwdata/mosaic-sql`.

```ts
/**
 * A date/time interval in units of microseconds.
 */
export interface Microseconds {
  /**
   * A date/time interval in units of microseconds.
   */
  microseconds: number;
}
```
