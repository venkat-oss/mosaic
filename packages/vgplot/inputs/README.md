# mosaic-inputs

[![npm version](https://img.shields.io/npm/v/@uwdata/mosaic-inputs.svg)](https://www.npmjs.com/package/@uwdata/mosaic-inputs)

Standalone data-driven components such as input menus, text search boxes, and sortable, load-on-scroll data tables. Input widgets integrate with Mosaic Params and Selections, and can either be used in a standalone fashion or draw values from a backing data table.

The `mosaic-inputs` package is included as part of the [vgplot](https://github.com/uwdata/mosaic/tree/main/packages/vgplot/vgplot) API.

From a repository checkout, run `bazelisk test //packages/vgplot/inputs:check` for runtime/DOM tests, test typechecking and lint. Build the publishable package with `bazelisk build //packages/vgplot/inputs:tarball`; its `pkg.tgz` is under `bazel-bin/packages/vgplot/inputs/`. Compilation uses the committed CUE-generated API sources and does not regenerate them.
