# Mosaic DuckDB Servers

Mosaic provides Python, Node.js, Go, and Rust servers that expose a native DuckDB instance through the same [HTTP protocol](/api/duckdb/server-protocol). Query results are Apache Arrow IPC streams. Execution commands run SQL statements in order, and preaggregation commands return managed table references. Command metadata and errors use JSON.

::: tip
To run DuckDB in the browser, use the `wasmConnector` from the [`mosaic-core`](/core/) package.
:::

::: info
DuckDB can also connect to and query other databases, such as PostgreSQL and MySQL. See the [multi-database support page](/api/core/multi-database-support) for examples.
:::

## Python installation

The Python server package is available on [PyPI](https://pypi.org/project/duckdb-server/) and requires Python 3.11 or newer.

Run it in an isolated environment with [uvx](https://docs.astral.sh/uv/):

```bash
uvx duckdb-server
```

Alternatively, you can install the server with `pip install duckdb-server`. Then you can start the server with `duckdb-server`.

## Developer Setup

From the repository root, the following aliases run the native Bazel targets:

| Server | Command |
| --- | --- |
| Python, with source reload | `pnpm server` |
| Node.js | `pnpm server:node` |
| Go | `pnpm server:go` |
| Rust | `pnpm server:rust` |

Run `bazelisk test //packages/server:protocol` to exercise the same HTTP tests against all four implementations. See the [build workflow](/development/build) for package checks, server benchmarks, and artifact paths. Installed packages do not require Bazel or CUE.

For shared localhost HTTPS/HTTP/2 setup for Node, Rust, and Go, install [native mkcert](https://github.com/FiloSottile/mkcert#installation) on `PATH`, then run `pnpm mkcert` from the repository root. See the [server guide](https://github.com/uwdata/mosaic/blob/main/packages/server/README.md) for certificate discovery and renewal.

The package guides describe implementation-specific options: [Python](https://github.com/uwdata/mosaic/tree/main/packages/server/duckdb-server), [Node.js](https://github.com/uwdata/mosaic/tree/main/packages/server/duckdb), [Go](https://github.com/uwdata/mosaic/tree/main/packages/server/duckdb-server-go), and [Rust](https://github.com/uwdata/mosaic/tree/main/packages/server/duckdb-server-rust).
