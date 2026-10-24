# mosaic-duckdb

For shared localhost HTTPS/HTTP/2 setup, install native mkcert on `PATH`, then run `pnpm mkcert` from the repository root. See the [server guide](../README.md) for certificate locations, overrides, and renewal.

[![npm version](https://img.shields.io/npm/v/@uwdata/mosaic-duckdb.svg)](https://www.npmjs.com/package/@uwdata/mosaic-duckdb)

A Promise-based Node.js API to DuckDB, along with a data server that supports transfer of [Apache Arrow](https://arrow.apache.org/) data over HTTP.

_Note:_ This package provides a local DuckDB server for Node.js. To instead use DuckDB-WASM in the browser, use the `wasmConnector` in the [`mosaic-core`](https://github.com/uwdata/mosaic/tree/main/packages/mosaic/core) package.

From the repository root, run `bazelisk run //packages/server/duckdb:server --`
to start the server. Arguments after `--` are forwarded to the application.
Run `bazelisk test //packages/server/duckdb:check` for runtime tests, lint,
test typechecking and installed-package tests, including the conversion CLIs.
Extension installation tests use an isolated home directory and need network access.
Build the publishable package with `bazelisk build //packages/server/duckdb:tarball`;
its output is `bazel-bin/packages/server/duckdb/pkg.tgz`.

## HTTP API

The server implements the [shared HTTP protocol](https://uwdata.github.io/mosaic/api/duckdb/server-protocol): POST accepts `arrow`, `exec`, and `preagg` JSON commands. GET accepts read-only `arrow` commands through flat `type` and `sql` URL parameters. Arrow responses are IPC streams, including empty results; errors use the common JSON error envelope.
