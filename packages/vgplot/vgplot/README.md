# vgplot: A Mosaic-powered Visualization Grammar

[![npm version](https://img.shields.io/npm/v/@uwdata/vgplot.svg)](https://www.npmjs.com/package/@uwdata/vgplot)

A **v**isualization **g**rammar for interactive Mosaic-powered visualizations and dashboards. This package provides convenient, composable methods that combines multiple Mosaic packages (core, inputs, plot, etc.) in an integrated API.

vgplot is a JavaScript API for creating visualizations and dashboards. See the [mosaic-spec](https://github.com/uwdata/mosaic/tree/main/packages/vgplot/spec) package to instead use declarative specifications in JSON or YAML format.

From a repository checkout, run `bazelisk test //packages/vgplot/vgplot:check` for authoring, linked dashboard/rendering, cross-language templates, typechecking and lint. Tests use declared DuckDB, Python and fixture inputs. Build the publishable package with `bazelisk build //packages/vgplot/vgplot:tarball`; its `pkg.tgz` is under `bazel-bin/packages/vgplot/vgplot/`. Compilation consumes the committed API files.
