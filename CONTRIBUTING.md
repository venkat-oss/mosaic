# Contributing to Mosaic

Thanks for your interest in contributing to Mosaic! This guide covers how to set up a local development environment, run the test suite, and work on the documentation. For an overview of the repository's packages, see the [Repository Structure](README.md#repository-structure) section of the README.

Bug reports, feature requests, and questions are welcome via [GitHub issues](https://github.com/uwdata/mosaic/issues). For larger changes, please open an issue to discuss the design before sending a pull request.

## Prerequisites

- [Bazelisk](https://github.com/bazelbuild/bazelisk), which selects Bazel using `.bazelversion` and downloads the declared language tools and dependencies.
- A C/C++ toolchain for the DuckDB server builds.
- Docker for the matching Playwright browser environment.
- [Node.js](https://nodejs.org/) with [`pnpm`](https://pnpm.io/) and [`uv`](https://docs.astral.sh/uv/) when updating dependency locks or setting up IDE environments. They do not orchestrate repository builds or tests.

## Getting started

* Clone [https://github.com/uwdata/mosaic](https://github.com/uwdata/mosaic).
* Run `bazelisk build //:build` to build packages, servers, examples and documentation, including Rust Clippy.
* Run `bazelisk test //:check` to run the normal language, API and gallery checks.
* Run `bin/visual-test.sh` for browser tests in the container matching the locked Playwright version.
* Optionally run `pnpm install` and `uv sync` for IDE dependency resolution. Bazel builds and tests do not use these workspace installations.

The first build downloads the declared tools, dependencies, and DuckDB SDK; subsequent commands reuse Bazel's cache. Select a package's `:check` target while developing, for example `bazelisk test //packages/mosaic/sql:check`. `pnpm build`, `pnpm test`, `pnpm lint` and `pnpm typecheck` are thin Bazel aliases. See the `scripts` in [`package.json`](package.json) for other commands and the [build workflow](docs/development/build.md) for target ownership and artifact paths.

Build publishable archives with `bazelisk build //:packages`; `bazelisk cquery //:packages --output=files` lists their paths. JavaScript tarballs are under `bazel-bin/<package>/pkg.tgz`; Python wheels and source archives are under each package's corresponding `bazel-bin/` directory. Build outputs stay outside the source directories. `bazelisk clean` removes build outputs; it is not needed for normal iteration.

## Running examples locally

* Run `bazelisk run //:dev` (or `pnpm dev`) to launch the gallery with source hot reload. By default, examples use DuckDB-WASM in the browser.
* Run `bazelisk run //packages/server/duckdb-server:dev` (or `pnpm server`) to launch the Python server with automatic restarts after source edits. The Node, Go and Rust servers have matching `pnpm server:node`, `pnpm server:go` and `pnpm server:rust` aliases.
* The standalone applications expose `:dev`, `:build` and `:preview` under `//packages/examples/{vanilla-example,vega-example,svelte-example}`. Restart dev servers after changing build configuration or dependencies.

## Documentation

The documentation site is built with [VitePress](https://vitepress.dev/) from the `docs/` directory. Run `bazelisk run //docs:dev` for hot reload, `bazelisk build //docs:site` to build, or `bazelisk run //docs:preview` to inspect the production site. The `pnpm docs:dev`, `pnpm docs:build` and `pnpm docs:preview` aliases select these targets. The site output is `bazel-bin/docs/site`, including generated gallery pages, data and template downloads; deployment uploads this directory.

The production build also generates [LLM-friendly](https://llmstxt.org/) `llms.txt` and `llms-full.txt` through [`vitepress-plugin-llms`](https://github.com/okineadev/vitepress-plugin-llms). They regenerate from the docs pages and stay in build outputs. Do not commit site output, caches or LLM files.

## Generated files

Some files are generated, so don't edit them by hand. Change the source and regenerate instead, then commit the regenerated files together with your change (CI fails if the committed files don't match a fresh regeneration):

* Example specs under `specs/` and `docs/public/specs`: run `pnpm docs:examples`.
* Declarative specification files, API wrappers and mappings, generated reference sections, and starter templates: run `pnpm generate:api`. Generated filenames are listed in `api/generated.json` for stale-file cleanup.
* The generated Python vgplot API uses the same command. `pnpm generate:python-api` is a compatibility alias; see the [vgplot-python contributing guide](packages/vgplot/vgplot-python/CONTRIBUTING.md).

### CUE API generation

CUE owns the declarative specification and the corresponding JavaScript and Python authoring contracts: values, params, transforms, data, layouts, attributes, marks, interactors, legends and inputs. Their family packages under `api/` generate types, the full JSON Schema, bindings, parser/codegen metadata, reference sections and starter templates. The shared server protocol is also a CUE family, generating its common cases and reference page. The root specification contracts and parser/runtime API metadata live in `api/spec/model/`. Shared model-only packages let families reuse canonical contracts without loading another family's generation graph.

`api/catalog/sources.cue` lists the owning family packages. Each family’s `contribution.cue` connects its generated artifacts to `api/catalog.cue`; `api/model/`, `api/render/` and `api/compose/` provide shared records, projections and composition. Public generated files have one owning CUE producer.

Edit an owning CUE contract and regenerate its outputs. Keep explicit target adapters: TypeScript, wire data and native JavaScript/Python objects can have distinct contracts. Query/render engines, selections, DOM interactions, serialization, sentinel identity and Python caller-scope discovery retain their runtime implementations.

Install Bazelisk; `.bazelversion` pins Bazel, and the build downloads the pinned CUE and Ruff tools. Installed packages and ordinary builds consume committed artifacts without CUE:

```sh
bazelisk run //:generate
bazelisk test //:api_check
bazelisk build //:build
bazelisk test //bin/test:tests
```

Generation validates and exports each family separately, composes the outputs, and formats them before syncing. `pnpm generate:api` runs `bazelisk run //:generate` and removes obsolete files using `api/generated.json`. `pnpm check:api` runs the read-only Bazel comparison. Commit source changes and regenerated artifacts together. Run `bazelisk test //bin/test:tests` for the native contract/consumer tests; Bazel supplies their pinned CUE, TypeScript and Python tools.

The complete CUE-generated schema is checked in at `packages/vgplot/spec/src/generated/mosaic-schema.json`. Ordinary builds materialize it into the existing `dist/mosaic-schema.json` consumer path. The root `cue.mod/module.cue` defines the CUE module.

See the [specification generation guide](docs/spec-generation/index.md) for source layout and workflow. Gallery examples still originate in `specs/yaml/`; run `pnpm docs:examples` to update their generated variants. Build documentation changes with `pnpm docs:build`.

## Before opening a pull request

Run the affected package's `:check` target and regenerate any generated files your change affects. Before integration, run `bazelisk build //:build`, `bazelisk test //:check` and `bin/visual-test.sh`. `pnpm lint:fix` runs the declared ESLint engine as an explicit source-writing operation. CI selects the same targets in [`.github/workflows/test.yml`](.github/workflows/test.yml), preserving Go race, Rust lint, notebook, gallery and browser coverage.

Release versioning remains an explicit Lerna operation. Its root `version` hook refreshes and stages `MODULE.bazel.lock` after manifest versions change; the spec hook publishes versioned schemas. Do not invoke these hooks or `pnpm docs:schema` as validation. The release workflow builds `//:packages` after versioning, then publishes those tarballs, wheels and source archives without rebuilding through package lifecycle hooks.

## License

By contributing, you agree that your contributions will be licensed under the [BSD-3-Clause License](LICENSE).
