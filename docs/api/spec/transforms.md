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
