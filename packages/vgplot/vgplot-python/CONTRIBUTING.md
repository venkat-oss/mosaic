# Contributing to the vgplot Python API

CUE owns the Python API's public contracts, type aliases, factory signatures, keyword mappings, exports, reference text and starter templates. The shared `pnpm generate:api` pipeline produces their bindings alongside JavaScript, TypeScript and JSON Schema outputs.

Canonical families live under `api/`: values and host adapters in `values/`; parameters and selections in `params/`; data sources and layouts in `data/` and `layouts/`; transforms in `transforms/`; attributes, marks, interactors and inputs in their matching directories. Common mark factory protocols live in `api/marks/profile/`, and Python language facts in `api/languages/python/`.

Each owning family package exposes its contribution in `contribution.cue`; `api/catalog/sources.cue` lists those packages. `api/catalog.cue` and `api/compose/` assemble shared modules and exports; `api/generated.json` lists generated filenames for stale-file cleanup. Edit the owning CUE contract and regenerate the public artifacts.

Runtime modules retain serialization, dataframe handling, parameter/reference resolution, selection behavior and caller-scope discovery. Preserve direct caller-sensitive `spec`/`View` operations when changing public exports: an extra forwarding frame can change which local data and parameters are discovered. The SQL, plot and notebook engines consume generated metadata through their existing runtime hooks.

## Regenerating the API

Install Bazelisk as described in the [root contributing guide]. From the repository root, run:

```sh
pnpm generate:api
pnpm check:api
pnpm test:api
```

`pnpm generate:python-api` is a compatibility alias for `pnpm generate:api`. Bazelisk runs generation with pinned CUE and Ruff tools. Ordinary builds and installed Python packages use committed outputs without CUE.

Check mode evaluates and formats outputs in temporary storage, then compares them without changing the workspace. CI checks committed artifacts before consumer tests. Commit source changes and regenerated outputs together. Python `_generated/` modules and public compatibility paths are generated outputs; their signatures, omission rules, sentinels and runtime class identities must remain consistent with the owning contracts.

The checked-in full schema is `packages/vgplot/spec/src/generated/mosaic-schema.json`; `//packages/vgplot/spec:schema` materializes it at the package's `dist/mosaic-schema.json` path in Bazel outputs. Admission tests use the current schema.

## Adding or changing an API

Update its canonical family and any target adapter, then regenerate its types, schema, bindings, docs and templates. Keep JavaScript and Python applicability explicit when one target supports native objects or options outside the shared declarative format. Exercise the public import and actual serialization or runtime path in normal tests.

Generated Python bindings need no hand edits. A missing public name raises `AttributeError` and is visible to type checkers. When changing omission or keyword handling, cover explicit None, UNSET, false and zero values, aliases, and parameter/data reference identity as applicable.

## Tests

```sh
bazelisk test //packages/vgplot/vgplot-python:check
```

The suite includes independently selectable Python tests, Ruff, formatting, TY and installed wheel/source-distribution consumers. Fixtures and cross-language tools come from declared runfiles. Static checking does not build the notebook widget's JavaScript bundle.

Run affected JavaScript/codegen tests as well when changing a shared authoring contract, and run `pnpm docs:build` after changing generated reference or template text.

## Distributions

Run `bazelisk build //packages/vgplot/vgplot-python:wheel //packages/vgplot/vgplot-python:sdist`. Artifacts are under `bazel-bin/packages/vgplot/vgplot-python/`. Both distributions use the version in `package.json`; the source archive retains its Hatchling backend for installation outside the repository. Publication uploads these existing artifacts after version bumping and building them.

[root contributing guide]: ../../../CONTRIBUTING.md#cue-api-generation
