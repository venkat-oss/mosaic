# mosaic-plot

[![npm version](https://img.shields.io/npm/v/@uwdata/mosaic-plot.svg)](https://www.npmjs.com/package/@uwdata/mosaic-plot)

A Mosaic-powered grammar of graphics based on [Observable Plot](https://github.com/observablehq/plot). Mmarks (plot layers) serve as individual Mosaic clients. These marks can push data processing (binning, hex binning, regression) and optimizations (such as M4 for line/area charts) down to the database. This package also provides interactors for linked selection, filtering, and highlighting using Mosaic Params and Selections.

The `mosaic-plot` package is included as part of the [vgplot](https://github.com/uwdata/mosaic/tree/main/packages/vgplot/vgplot) API.

From a repository checkout, run `bazelisk test //packages/vgplot/plot:check` for runtime/DOM tests, real DuckDB grid queries, test typechecking and lint. Build the publishable package with `bazelisk build //packages/vgplot/plot:tarball`; its `pkg.tgz` is under `bazel-bin/packages/vgplot/plot/`. Compilation consumes the committed API sources.

