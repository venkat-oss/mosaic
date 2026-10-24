# mosaic-core

[![npm version](https://img.shields.io/npm/v/@uwdata/mosaic-core.svg)](https://www.npmjs.com/package/@uwdata/mosaic-core)

The core Mosaic components: a central coordinator, parameters (`Param`) and selections (`Selection`) for linking scalar values or query predicates (respectively) across Mosaic clients, and filter groups with materialized views of pre-aggregated data. The Mosaic coordinator can send queries either over the network to a backing server (`rest` client) or to a client-side [DuckDB-WASM](https://github.com/duckdb/duckdb-wasm) instance (`wasm` client).

From the repository root, run `bazelisk test //packages/mosaic/core:check` for
runtime tests, lint, test typechecking and installed-package tests. The installed
consumer exercises `@uwdata/mosaic-core/node-connector` with a real Arrow query
and checks the declared WASM/worker assets. Build the publishable package with
`bazelisk build //packages/mosaic/core:tarball`; its output is
`bazel-bin/packages/mosaic/core/pkg.tgz`.

