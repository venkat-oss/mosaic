# Mosaic DuckDB Server

[![PyPi](https://img.shields.io/pypi/v/duckdb-server.svg)](https://pypi.org/project/duckdb-server/)

A Python-based server that runs a local DuckDB instance and supports queries over HTTP, returning data in [Apache Arrow](https://arrow.apache.org/) format.

_Note:_ This package provides a local DuckDB server. To instead use DuckDB-WASM in the browser, use the `wasmConnector` in the [`mosaic-core`](https://github.com/uwdata/mosaic/tree/main/packages/mosaic/core) package.

## Installation and usage

We recommend running the server in an isolated environment with [uvx](https://docs.astral.sh/uv/). For example, to directly run the server, use:

```bash
uvx duckdb-server
```

Alternatively, you can install the server with `pip install duckdb-server`. Then you can start the server with `duckdb-server`.

## Developer Setup

From the repository root, start the server with `bazelisk run //packages/server/duckdb-server:server -- --no-http2`. Pass server flags after `--`.

For automatic restarts after Python edits, run `bazelisk run //packages/server/duckdb-server:dev` or `pnpm dev` from this package.

Run `bazelisk test //packages/server/duckdb-server:check` for tests, Ruff, formatting, typechecking and installed distribution consumers. Tests use the declared interpreter and locked dependencies; no activated environment is required. Use uv to update dependencies or create an IDE environment.

## API

The server implements the [shared HTTP protocol](https://uwdata.github.io/mosaic/api/duckdb/server-protocol): POST accepts `arrow`, `exec`, and `preagg` JSON commands. GET accepts read-only `arrow` commands through flat `type` and `sql` URL parameters. Arrow responses are IPC streams; errors use the common JSON error envelope.

For example: `http://localhost:3000/?type=arrow&sql=SELECT%201`.

Python 3.11 or newer is required. Dependencies include DuckDB 2 and PyArrow 26.

## Publishing

Build distributions with `bazelisk build //packages/server/duckdb-server:wheel //packages/server/duckdb-server:sdist`. The artifacts are under `bazel-bin/packages/server/duckdb-server/`. Upload those files explicitly with Twine after updating the package version. Credentials and publication remain separate from the build.
