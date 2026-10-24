# Data Server

The data server provides network access to a server-side DuckDB instance from Node.js.

The Node, Python, Go and Rust servers share the [server protocol](./server-protocol), including Arrow streams, sequential execution and managed preaggregation.

## dataServer

`dataServer(db, options)`

Launch a new data server instance.
The _db_ argument should be a [`DuckDB`](./duckdb) instance.

The following _options_ are supported:

- _port_: The port number (default `3000`) on which to listen for query requests.
- _rest_: Boolean flag (default `true`) indicating if HTTP REST connections should be enabled.

For HTTPS/HTTP/2, install native mkcert on `PATH`, then run `pnpm mkcert` from the repository root. The server checks for a complete `localhost.pem` / `localhost-key.pem` pair in its working directory, then the shared OS user configuration directory under `mosaic/https`. A selected invalid pair fails startup; without a pair, the server uses plaintext HTTP. HTTPS also supports HTTP/1.1 clients. See the [server guide](https://github.com/uwdata/mosaic/blob/main/packages/server/README.md) for platform paths, mounts, and renewal.

POST commands contain required, case-sensitive `type` and `sql` string fields. Supported command types are `arrow`, `exec` and `preagg`. GET uses flat `type=arrow&sql=...` parameters and permits read-only queries. Errors use the shared JSON error envelope; see the [protocol reference](./server-protocol) for validation, response formats and status codes.

### Examples

Launch a data server in Node.js:

``` js
import { DuckDB, dataServer } from "@uwdata/mosaic-duckdb";
dataServer(new DuckDB(), { rest: true });
```
