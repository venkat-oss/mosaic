# Data Loading

SQL data loading utilities.
These methods generate queries that create tables and load data into DuckDB. File paths and string-valued loading options are escaped as SQL literals, including strings nested in arrays or option maps. The `select` and `where` options contain SQL expressions.

Loaders construct Polyglot AST queries. Pass them directly to
`coordinator.exec`. Specifications and direct JavaScript calls use these same
loaders. Table names can be name paths such as `['main', 'rows']`; each component
is quoted separately.
Reader options accept native expressions and scalar parameters, including
expressions inside arrays and option maps. String `select` and `where` values
are parsed once as user-authored SQL; generated queries stay in the native AST.

```js
import { loadCSV, Query, gt } from '@uwdata/mosaic-sql';

await coordinator.exec(loadCSV(['main', 'rows'], 'rows.csv', {
  columns: { value: 'DOUBLE', label: 'VARCHAR' },
  select: ['label', 'value * 2 AS doubled'],
  where: gt('value', 0),
  replace: true
}));
const rows = await coordinator.query(Query.from('rows'));
```

File readers and spatial functions require a DuckDB target. Native compilation
rejects them for PostgreSQL; a PostgreSQL connection does not imply PostGIS or
access to DuckDB's file readers. Extension installation remains an explicit
DuckDB setup command. It can only execute when the source and target dialects
match.

## createTable

`createTable(name, query, options)`

Create a `CREATE TABLE` or `CREATE VIEW` query. The _options_ object supports _replace_ (use `OR REPLACE`), _temp_ (temporary table/view), and _view_ (create a view instead of a table).

## createSchema

`createSchema(name, options)`

Create a `CREATE SCHEMA` query. Set _strict_ to `true` to omit `IF NOT EXISTS`.

## loadExtension

`loadExtension(extensionName)`

Generates a query to install and load a named DuckDB extension. For example, `vg.loadExtension("spatial")` will load the [`spatial` extension](https://duckdb.org/docs/extensions/spatial.html).

## loadCSV

`loadCSV(tableName, file, options)`

Generate a SQL query to create a table containing the values of a CSV _file_.
The _file_ argument may be a URL or a local filesystem path (if running DuckDB locally, _not_ via WebAssembly).

The supported _options_ are:

- _select_: An optional list of column expressions to select. If not specified, all columns are included.
- _where_: An optional filter predicate (`WHERE` clause) to filter the data on load.
- _view_: A boolean flag (default `false`) indicating if a `VIEW` should be created over the file, rather than a `TABLE`.
- _temp_: A boolean flag (default `true`) indicating if the created table or view should be a temporary instance that should not persist beyond the current session.
- _replace_: A boolean flag (default `false`) indicating that the file contents should replace any existing table or view with the same name. The default behavior is to do nothing if a name conflict exists.
- Additional CSV-specific options, see the [DuckDB CSV documentation](https://duckdb.org/docs/data/csv/overview).

``` js
// Loads file.csv into the table "table1" with default options:
// CREATE TABLE IF NOT EXISTS table1 AS
//   SELECT *
//   FROM read_csv('file.csv', auto_detect=true, sample_size=-1)
loadCSV("table1", "file.csv");
```

## loadJSON

`loadJSON(tableName, file, options)`

Generate a SQL query to create a table containing the values of a JSON _file_.
The _file_ argument may be a URL or a local filesystem path (if running DuckDB locally, _not_ via WebAssembly).

The supported _options_ are:

- _select_: An optional list of column expressions to select. If not specified, all columns are included.
- _where_: An optional filter predicate (`WHERE` clause) to filter the data on load.
- _view_: A boolean flag (default `false`) indicating if a `VIEW` should be created over the file, rather than a `TABLE`.
- _temp_: A boolean flag (default `true`) indicating if the created table or view should be a temporary instance that should not persist beyond the current session.
- _replace_: A boolean flag (default `false`) indicating that the file contents should replace any existing table or view with the same name. The default behavior is to do nothing if a name conflict exists.
- Additional JSON-specific options. See the [DuckDB JSON documentation](https://duckdb.org/docs/data/json/overview).

``` js
// Loads file.json into the table "table1" with default options:
// CREATE TABLE IF NOT EXISTS table1 AS
//   SELECT *
//   FROM read_json('file.json', auto_detect=true, format='auto')
loadJSON("table1", "file.json");
```

## loadParquet

`loadParquet(tableName, file, options)`

Generate a SQL query to create a table containing the values of a Parquet _file_.
The _file_ argument may be a URL or a local filesystem path (if running DuckDB locally, _not_ via WebAssembly).

The supported _options_ are:

- _select_: An optional list of column expressions to select. If not specified, all columns are included.
- _where_: An optional filter predicate (`WHERE` clause) to filter the data on load.
- _view_: A boolean flag (default `false`) indicating if a `VIEW` should be created over the file, rather than a `TABLE`.
- _temp_: A boolean flag (default `true`) indicating if the created table or view should be a temporary instance that should not persist beyond the current session.
- _replace_: A boolean flag (default `false`) indicating that the file contents should replace any existing table or view with the same name. The default behavior is to do nothing if a name conflict exists.
- Additional Parquet-specific options. See the [DuckDB Parquet documentation](https://duckdb.org/docs/data/parquet/overview).

```js
// Load named columns from a parquet file, filtered upon load:
// CREATE TABLE IF NOT EXISTS table1 AS
//   SELECT foo, bar, value
//   FROM read_parquet('file.parquet')
//   WHERE value > 1
loadParquet("table1", "file.parquet", {
  select: [ "foo", "bar", "value" ],
  where: "value > 1"
});
```

## loadObjects

`loadObjects(tableName, objects, options)`

Generate a SQL query to create a table containing the values of the provided JavaScript _objects_. Object keys become quoted column names. A `select` projection applies to every input row, including reordered columns and computed expressions.

The supported _options_ are:

- _select_: An optional list of column expressions to select. If not specified, all columns are included.
- _view_: A boolean flag (default `false`) indicating if a `VIEW` should be created over the file, rather than a `TABLE`.
- _temp_: A boolean flag (default `true`) indicating if the created table or view should be a temporary instance that should not persist beyond the current session.
- _replace_: A boolean flag (default `false`) indicating that the file contents should replace any existing table or view with the same name. The default behavior is to do nothing if a name conflict exists.

``` js
// CREATE TABLE IF NOT EXISTS table3 AS
//   (SELECT 1 AS "foo", 2 AS "bar") UNION ALL
//   (SELECT 3 AS "foo", 4 AS "bar") UNION ALL ...
const q = loadObjects("table3", [
  { foo: 1, bar: 2 },
  { foo: 3, bar: 4 },
  ...
]);
```

The loader constructs the full `UNION ALL` before applying `select` and
`where`. Dates, nulls, strings, numeric and boolean values retain their SQL
types; nested arrays and objects become list and struct values. An empty object
array requires an application-defined schema rather than inferred columns.

`sqlFrom(objects, { columns })` returns the underlying
query without creating a table. `columns` can be an ordered list of input keys
or a map from input keys to output names. Names are quoted, including keys such
as `__proto__` or names containing quotes.

## loadSpatial

`loadSpatial(tableName, file, options)`

Generate a SQL query to create a table containing the values of a spatial data file by calling the [`ST_Read` function](https://duckdb.org/docs/extensions/spatial.html#st_read---read-spatial-data-from-files) of the DuckDB `spatial` extension.
The _file_ argument may be a URL or a local filesystem path (if running DuckDB locally, _not_ via WebAssembly).

The supported _options_ are:

- _select_: An optional list of column expressions to select. If not specified, all columns are included.
- _where_: An optional filter predicate (`WHERE` clause) to filter the data on load.
- _view_: A boolean flag (default `false`) indicating if a `VIEW` should be created over the file, rather than a `TABLE`.
- _temp_: A boolean flag (default `true`) indicating if the created table or view should be a temporary instance that should not persist beyond the current session.
- _replace_: A boolean flag (default `false`) indicating that the file contents should replace any existing table or view with the same name. The default behavior is to do nothing if a name conflict exists.
- _layer_: The layer to extract from a multi-layer file. For example, for TopoJSON data this indicates which named object to extract.
- Additional spatial-specific options. See the [DuckDB spatial documentation](https://duckdb.org/docs/extensions/spatial.html).

``` js
// Loads us-states.json into the table "table1":
// CREATE TABLE IF NOT EXISTS table1 AS
//   SELECT *
//   FROM st_read('us-states.json', layer='states')
loadSpatial("table1", "us-states.json", { layer: "states" });
```

The loader converts the nested `options` map to DuckDB's `open_options`
list. For example, `{ options: { flatten_nested_attributes: true } }` becomes
`open_options=['FLATTEN_NESTED_ATTRIBUTES=TRUE']`. Geometry coordinates and CRS
remain those of the source unless explicit reader options request a conversion.

## Spatial expressions

The SQL package exports `geojson(expr)`, `x(expr)`, `y(expr)`, `centroid(expr)`,
`centroidX(expr)` and `centroidY(expr)` from its root entry. They invoke DuckDB's `ST_AsGeoJSON`, `ST_X`, `ST_Y` and `ST_Centroid`
functions; load the `spatial` extension before executing them. String arguments
denote column names. Native expressions retain qualified fields and live bindings.

`geojson` returns encoded GeoJSON text. A `geo` mark decodes this text into
geometry objects for rendering. A `geo` mark with no `geometry` channel
requests `geojson('geom')`, matching the default column supplied by `ST_Read`.
An explicit `geometry` channel overrides that default.
