# mosaic-sql

[![npm version](https://img.shields.io/npm/v/@uwdata/mosaic-sql.svg)](https://www.npmjs.com/package/@uwdata/mosaic-sql)

An API for convenient construction and analysis of SQL queries. Constructed `Query` objects coerce to SQL query strings.

From the repository root, run `bazelisk test //packages/mosaic/sql:check` for
runtime tests, lint, test typechecking and installed-package tests. Build the
publishable package with `bazelisk build //packages/mosaic/sql:tarball`; its output
is `bazel-bin/packages/mosaic/sql/pkg.tgz`.
