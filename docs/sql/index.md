# Mosaic SQL

The Mosaic `sql` package supports authoring of SQL queries.
These utilities are used throughout Mosaic packages to build structured queries and perform query analysis.

## SQL compiler {#native-compiler-preview}

`@uwdata/mosaic-sql` builds Polyglot's native expression data. Mosaic retains
query authoring, live parameters, consolidation and DuckDB preaggregation;
Polyglot compiles the resolved tree to the connection's SQL dialect.
The package requires Node.js 22 or later, or a browser with WebAssembly and
ES2022 support.

```js
import { Query, compile, createExecutionContext, literal } from '@uwdata/mosaic-sql';

const query = Query.select({ value: literal(42) });
const statements = compile([query], createExecutionContext());
```

`asNode('amount')` creates a quoted column reference; `asLiteral('amount')`
creates a string value. `compile` resolves live bindings once for the batch,
preserves statement or scalar roots in input order, and raises
`SqlCompilationError` for unsupported target operations. Coordinators manage their
own execution context and compile at submission.

Node ESM initializes the compiler before imports complete. Browser builds must
emit the SDK's sibling WebAssembly asset and support top-level await. The
repository's Vite configurations select ES2022 and exclude the SDK from dependency
prebundling. The Jupyter frontend embeds this asset in its bundle.

Query alias maps accept names such as `first` and `sum`. For ambiguous
plain-data shapes, pass projection entries as `Query.select([[name, value]])`
or wrap an expression as `{ expression: node }`. The exact object
`{ null: null }` denotes a SQL NULL expression.

The mutable `Query` facade and `Aggregate`/`Window` authoring handles expose their
canonical tree as `.expression`. Plain expressions have no custom string renderer;
use `compile` to generate SQL. Low-level node constructors, underscore clause
mutation, global visitors and custom code-generator subclasses have been removed.
Use native factories, [tree inspection and rewriting](../api/sql/expressions#native-tree-inspection-and-rewriting),
and external delayed bindings for extensions.

### Query transforms

Numeric, string, interval and date helpers construct Polyglot expressions.
String search patterns and flags remain literal arguments, including live scalar
Params. Non-finite JavaScript literals become SQL NULL.

`bin1d`, `bin2d`, `binHistogram`, `binDate`, `binLinear1d`, `binLinear2d`, `m4`
and `lineDensity` construct binning and downsampling queries. For example:

```js
import { Query, binHistogram, count } from '@uwdata/mosaic-sql';

const histogram = Query.from('sales').select({
  bucket: binHistogram('amount', [0, 100], { step: 10 }),
  rows: count()
}).groupby('bucket').orderby('bucket');
```

Linear binning distributes weights over adjacent bins; an explicit zero weight
contributes no density. M4 retains endpoints and extrema per pixel group. Line
density uses an exclusive range and UNNEST for rasterization. These helpers
follow DuckDB semantics; unsupported cross-dialect conversions reject explicitly.

For list-valued fields, use core's
`clauseList(field, value, { source, listMatch: 'any' })`. Use `listMatch: 'all'`
to require every selected item. A scalar selection is wrapped as one list item;
`undefined` and an empty list clear the filter. A scalar `null` remains SQL NULL,
while `[null]` follows DuckDB's list-membership rules. Toggles and nearest
interactors on unnested marks use this same clause path.

## Query

Use the `Query` class to build complete SQL queries.
Upon string coercion, the resulting object produces a query string.

``` js
import { Query } from "@uwdata/mosaic-sql";

// SELECT foo AS a, bar AS b FROM table
Query.from("table").select({ a: "foo", b: "bar" })
```

The `Query` class supports a rich set of SQL features, including subqueries (by passing queries as arguments to `from()`) and [common table expressions](https://duckdb.org/docs/sql/query_syntax/with.html) (via the `with()` method). Here is a run down of the available methods:

``` js
Query
  .with(/* a map of named common table expression queries */)
  .select(/* column names or name -> expression maps */)
  .distinct(/* boolean to denote distinct values only */)
  .from(/* source table names or subqueries */)
  .sample(/* number of rows or % to sample */)
  .where(/* filter criteria */)
  .groupby(/* columns or expressions to group by */)
  .having(/* post-aggregation filter criteria */)
  .window(/* named window definitions */)
  .qualify(/* post-window filter criteria */)
  .orderby(/* columns or expressions to sort by */)
  .limit(/* max number of rows */)
  .offset(/* offset number of rows */)
```

Use `pivot()` to create DuckDB [`PIVOT`](https://duckdb.org/docs/sql/statements/pivot.html#simplified-pivot-syntax) queries using simplified syntax:

``` js
import { Query, sum } from "@uwdata/mosaic-sql";

// PIVOT "sales" ON "year" IN (2020, 2021) USING sum("amount") AS "total" GROUP BY "region"
Query
  .pivot("sales")
  .on("year")
  .in(2020, 2021)
  .using({ total: sum("amount") })
  .groupby("region")
```

[Query API Reference](/api/sql/queries)

## Operators

The Mosaic SQL package includes operators for manipulating and comparing values:

- Logical operators: `and`, `or`, `not`
- Comparison operators: `eq`, `neq`, `lt`, `gt`, `lte`, `gte`
- Range operators: `isBetween`, `isNotBetween`
- Set operators: `isIn`
- Subquery comparisons: `compareAny`, `compareAll`
- List operators: `listContains`, `listHasAll`, `listHasAny`, `subscript`, `slice`
- Null checks: `isNull`, `isNotNull`
- Null-sensitive comparison: `isDistinct`, `isNotDistinct`
- Arithmetic operators: `add`, `sub`, `mul`, `div`, `idiv`, `mod`, `pow`
- Bitwise operators: `bitNot`, `bitAnd`, `bitOr`, `bitLeft`, `bitRight`
- Conditionals: `cond`
- Unnest: `unnest`

When given a string input, an operator function interprets it as a column name.

For example, to create a simple range query:

``` js
import { Query, and, count, isBetween } from "@uwdata/mosaic-sql";
Query
  .from("myTable")
  .select({ count: count() })
  .where(and(isBetween("foo", [10, 50]), isBetween("bar", [-5, 10])))
```

[Operator API Reference](/api/sql/operators)

## Aggregate Functions

DuckDB-supported [aggregate functions](https://duckdb.org/docs/sql/aggregates.html), including `min`, `max`, `count`, `sum`, `avg`, `stddev`, `median`, `quantile`, `argmax`, `argmin`, `corr`, and others.

``` js
import { Query, max, min, quantile } from "@uwdata/mosaic-sql";

// get min/max, median, and interquartile range
Query.select({
  min: min("foo"),
  q25: quantile("foo", 0.25),
  q50: quantile("foo", 0.50),
  q75: quantile("foo", 0.75),
  max: max("foo"),
}).from("myTable");
```

[Aggregate Functions API Reference](/api/sql/aggregate-functions)

## Window Functions

General purpose [window functions](https://duckdb.org/docs/sql/window_functions) include `row_number`, `rank`, `cume_dist`, `lag`, `lead`, _etc_.
Aggregate functions become window operations (such as cumulative sums or moving averages) if you define `orderby`, `partitionby`, or a `frame` using `frameRows`, `frameRange` or `frameGroups`.

``` js
import { Query, row_number, avg, frameRows } from "@uwdata/mosaic-sql";

// 7-row moving average (previous and next 3 rows)
// and corresponding ordered row numbers
Query.select({
  avg: avg("foo").orderby("date").frame(frameRows([3, 3])),
  num: row_number().orderby("date")
}).from("myTable");
```

[Window Functions API Reference](/api/sql/window-functions)

## SQL Expressions

The `sql` template tag parses user-authored SQL into the same Polyglot tree used by structured helpers. Partial nested fragments compose before parsing at the enclosing complete expression or statement.

``` js
import { Query, sql } from "@uwdata/mosaic-sql";
Query
  .select({ logFoo: sql`log(foo + 1)` })
  .from("myTable");
```

Interpolated values may include column references, nested expressions, or params.
Referenced columns or params can later be extracted using SQL expression visitors.

``` js
import { Param } from "@uwdata/mosaic-core";
import { collectColumns, collectParams, column, sql } from "@uwdata/mosaic-sql";

const col = column("foo");
const param = Param.value(Math.PI);
const expr = sql`${col} * ${param}`;

const cols = collectColumns(expr); // -> [ col ]
const params = collectParams(expr); // -> [ param ]
```

[Expression API Reference](/api/sql/expressions)

## Data Loading

Data loading helpers construct queries for loading data from external CSV, JSON, or Parquet files: `loadCSV`, `loadJSON`, `loadParquet`.

``` js
import { loadCSV, loadParquet } from "@uwdata/mosaic-sql";

// Loads file.csv into the table "table1" with default options:
// CREATE TABLE IF NOT EXISTS table1 AS
//   SELECT *
//   FROM read_csv('file.csv', auto_detect=true, sample_size=-1)
const q1 = loadCSV("table1", "file.csv");

// Load named columns from a parquet file, filtered upon load:
// CREATE TABLE IF NOT EXISTS table2 AS
//   SELECT foo, bar, value
//   FROM read_parquet('file.parquet')
//   WHERE value > 1
const q2 = loadParquet("table2", "file.parquet", {
  select: [ "foo", "bar", "value" ],
  where: "value > 1"
});
```

Meanwhile, the `loadObjects` method takes an array of JavaScript objects and generates a query to insert those values into a database table.

``` js
import { loadObjects } from "@uwdata/mosaic-sql";

// CREATE TABLE IF NOT EXISTS table3 AS
//   (SELECT 1 AS "foo", 2 AS "bar") UNION ALL
//   (SELECT 3 AS "foo", 4 AS "bar") UNION ALL ...
const q = loadObjects("table3", [
  { foo: 1, bar: 2 },
  { foo: 3, bar: 4 },
  ...
]);
```

[Data Loading API Reference](/api/sql/data-loading)
