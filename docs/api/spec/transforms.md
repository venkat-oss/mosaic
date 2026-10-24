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
