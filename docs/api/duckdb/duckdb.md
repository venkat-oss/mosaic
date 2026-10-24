# DuckDB API

The `DuckDB` class is a Promise-based Node.js API for interfacing with DuckDB,
providing a convenient way to launch a server-side DuckDB instance.
As illustrated in the snippet below, DuckDB queries can return either JavaScript objects or [Apache Arrow buffers](https://arrow.apache.org/).

``` js
import { DuckDB } from "@uwdata/mosaic-duckdb";

// create an in-memory DuckDB instance
// to open a database file, pass the path as the first argument
const db = new DuckDB();

// execute a query without a returned result, await completion
await db.exec(`CREATE TABLE myTable AS SELECT * FROM 'my-data.parquet'`);

// query for data, return as an array of JavaScript objects
const res = await db.query(`SELECT COUNT(*) FROM myTable`);

// query for data, return as a binary Apache Arrow buffer
const buf = await db.arrowBuffer(`SELECT AVG(value) FROM myTable`);

// shut down the DuckDB instance
db.close();
```

Unless provided with an explicit web URL (`http://...`), queries that load files (e.g., CSV, JSON, or Parquet) will do so relative to the current working directory.

## constructor

`new DuckDB(path)`

Create a new local DuckDB instance.
The optional _path_ argument indicates a database file path to load.
If omitted, a memory-only database instance is constructed.

## close

`db.close()`

Close the current database connection.
After closing, no more queries can be issued.

## exec

`db.exec(sql)`

Execute the provided _sql_ query and return a Promise that resolves when query evaluation completes.

## query

`db.query(sql)`

JSON row objects preserve quoted column names, including `__proto__`. Repeated
names use `:1`, `:2`, and subsequent suffixes. Prepared queries use the same naming
behavior; Arrow results retain their original column names and positions.

Execute the provided _sql_ query and return a Promise that resolves to the query result table as an array of JavaScript objects.

## arrowBuffer

`db.arrowBuffer(sql)`

Execute the provided _sql_ statement once and return a Promise that resolves to the query result table as binary data in the [streaming Apache Arrow IPC format](https://arrow.apache.org/). This includes schema-bearing empty results and statements with `RETURNING`. Trailing semicolons and comments are supported.

The Node adapter copies native result chunks through a temporary DuckDB table and IPC file before returning the bytes; Arrow export requires local file access. These temporary resources are removed after export, and caller-managed transactions remain under caller control.

## prepare

`db.prepare(sql)`

Return a new prepared statement for the given _sql_ query, which may contain `?` wildcard characters.
The resulting prepared statement instance exposes `exec(params)` and `query(params)` methods that accept parameter values for query wildcards.


## loadArrow

`loadArrow(db, tableName, data)`

Import Arrow IPC data into a table, replacing an existing table with the same name. The _data_ argument accepts byte chunks, a buffer or typed array, or a file path. Table names are quoted as identifiers, and temporary file paths support single quotes. The temporary IPC file is removed after the import.
