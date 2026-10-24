# Mosaic Widget

[![PyPi](https://img.shields.io/pypi/v/mosaic-widget.svg)](https://pypi.org/project/mosaic-widget/)

A Jupyter widget for Mosaic. Given a declarative specification, will generate web-based visualizations while leveraging DuckDB in the Jupyter kernel. Create interactive Mosaic plots over Pandas and Polars data frames or DuckDB connections.

Learn how to install and use the widget in the [Mosaic documentation](https://uwdata.github.io/mosaic/jupyter/).

## Developer Setup

From the repository root, run `bazelisk run //packages/vgplot/widget:notebook -- --notebook-dir=dev/notebooks` to start Jupyter with the built widget and Python authoring API. The real JavaScript and CSS bundle are declared inputs beside the Python module. Rebuild and restart after editing frontend code.

Run `bazelisk test //packages/vgplot/widget:check` for Python behavior, JavaScript/Python typing, ESLint, Ruff and installed distribution consumers. No activated Python environment or prebuilt workspace static files are required. Use uv for dependency updates and IDE environments.

## Publishing

Run `bazelisk build //packages/vgplot/widget:wheel //packages/vgplot/widget:sdist`. Both artifacts are under `bazel-bin/packages/vgplot/widget/` and include the real JavaScript/CSS assets. The source distribution retains Hatchling support for consumers building outside this repository. Upload these existing files explicitly after version bumping and building; publication is separate from the build.
