# Bazel build workflow

Bazel owns repository builds and tests, from source through runnable outputs and
publishable archives. Package scripts delegate to the same targets. CUE owns API
contracts and generated types, bindings, reference sections and starter templates;
runtime engines implement queries, rendering, interactions and serialization.

`api/catalog/sources.cue` lists the owning family packages, each with its own
`:contribution` target; see [specification generation](../spec-generation/).
Use `bazelisk run //:generate` and `bazelisk test //:api_check` to update and check
committed API files. Ordinary package compilation consumes those files without
regenerating the entire API.

The [native Polyglot design](./polyglot/index.md) and its
[implementation packets](./polyglot/work-packets.md) describe the SQL compiler
migration. The temporary SQL `/native` entry consumes a pinned, prebuilt Polyglot
SDK archive with its matching WebAssembly binary. Browser builds emit that asset;
the Jupyter bundle embeds it. Mosaic builds consume the archive without compiling
Polyglot's Rust sources. DuckDB remains the execution backend during this foundation.

## Commands

Run commands from the repository root. Bazelisk selects `.bazelversion`; the
language tools and dependency translations are declared in `MODULE.bazel` and
its lockfile. Package manifests and dependency locks remain their metadata sources.
The first build downloads the declared DuckDB SDK, toolchains and dependencies;
later commands reuse Bazel's cache.

The Rust server links the pinned official DuckDB shared SDK. Bazel supplies the
library and its runtime files; building the server does not compile DuckDB itself.
The build also widens `http`'s URI offsets and raises its limit to 2 MiB so long
generated SQL works over GET, matching the other servers.
Standalone Cargo users can choose the package's `bundled` feature instead.

| Task | Command |
| --- | --- |
| Build packages, servers, docs, examples and Rust Clippy | `bazelisk build //:build` |
| Run normal language, API, gallery and installed-package checks | `bazelisk test //:check` |
| Build npm tarballs and Python wheels/source archives | `bazelisk build //:packages` |
| List publishable archive paths | `bazelisk cquery //:packages --output=files` |
| Run browsers in the matching Playwright container | `bin/visual-test.sh` |
| Build / develop / preview docs | `bazelisk build //docs:site` / `bazelisk run //docs:dev` / `bazelisk run //docs:preview` |
| Sync / check gallery outputs | `bazelisk run //:examples` / `bazelisk test //:examples_check` |
| Generate / check CUE-owned API files | `bazelisk run //:generate` / `bazelisk test //:api_check` |
| Develop the gallery | `bazelisk run //:dev` |

Select an affected package's `:check` target during development. The five CI jobs
select `//:node_checks`, `//:python_checks`, `//:browser_tests` and the Go/Rust
package targets. Browser tests remain separate from normal checks because they
need their matching container. The browser helper caches a derived Playwright
image with GCC and C headers, which Bazel's Python tooling requires when building
the docs fixtures. Source hot reload uses `:dev`; restart after changing
dependencies or build configuration.

DuckDB 2 checks community extensions against their repository origin. Browser and
Node server checks install `nanoarrow` by name from `community`, so their first
startup needs network access. Bazel prefetches the signed core `httpfs` and
`spatial` binaries; all extension signature checks remain enabled.

Go policy tests build Gatekeeper 0.4.3 from its pinned upstream source against
DuckDB 2.0 and explicitly allow that unsigned local fixture in their test
connections. Production connections retain signature checking. The signed
Gatekeeper 2.0 community artifact is currently unavailable. Build the local
extension with `bazelisk build //packages/server/duckdb-server-go/gatekeeper:extension`.
Loading it explicitly requires `--database=':memory:?allow_unsigned_extensions=true'`
and `--load-extensions` pointing to the generated `gatekeeper.duckdb_extension`.

Archives are under each package's `bazel-bin/` path. `:pkg` is an npm package tree;
`:tarball` is its publishable `.tgz`. The documentation output is
`bazel-bin/docs/site`, including gallery pages, downloads and LLM files. Ordinary
builds write Bazel outputs; generation sync and snapshot updates are explicit run
operations. Installed packages need neither Bazel nor CUE.

Release versioning remains explicit. Lerna updates manifests, the root version
hook refreshes/stages `MODULE.bazel.lock`, and the release workflow builds
`//:packages` before publishing those archives. Python prerelease names use the
packaging tools' PEP 440 normalization. Schema publication remains an explicit
release operation; do not invoke `pnpm docs:schema` or version hooks as checks.

## Downstream applications

Build `//:packages` and install its archives in the downstream application. Consume
the packaged JavaScript and declarations through their public exports; downstream
builds do not need this repository's Bazel workspace or CUE toolchain.

When testing local archives, override the full Mosaic dependency set together.
Otherwise an application can load local packages alongside registry copies,
splitting `Coordinator`, `Param` and `Selection` identities. For npm, add these
`overrides` to the application's `package.json`, adjusting the repository path,
and use the same archive paths for any direct Mosaic dependencies:

```json
{
  "overrides": {
    "@uwdata/mosaic-sql": "file:../mosaic/bazel-bin/packages/mosaic/sql/pkg.tgz",
    "@uwdata/mosaic-core": "file:../mosaic/bazel-bin/packages/mosaic/core/pkg.tgz",
    "@uwdata/mosaic-duckdb": "file:../mosaic/bazel-bin/packages/server/duckdb/pkg.tgz",
    "@uwdata/mosaic-inputs": "file:../mosaic/bazel-bin/packages/vgplot/inputs/pkg.tgz",
    "@uwdata/mosaic-plot": "file:../mosaic/bazel-bin/packages/vgplot/plot/pkg.tgz",
    "@uwdata/vgplot": "file:../mosaic/bazel-bin/packages/vgplot/vgplot/pkg.tgz",
    "@uwdata/mosaic-spec": "file:../mosaic/bazel-bin/packages/vgplot/spec/pkg.tgz"
  }
}
```

Embedding Atlas's embedded components accept a Mosaic coordinator. Supply the
connector and create the data table before mounting the component:

```js
import { EmbeddingAtlas } from 'embedding-atlas';
import { Coordinator, restConnector } from '@uwdata/mosaic-core';

const coordinator = new Coordinator(restConnector({ uri: 'http://localhost:3000/' }));
await coordinator.exec(`CREATE TABLE points AS
  SELECT i::INTEGER AS id, i::DOUBLE AS x, sin(i)::DOUBLE AS y FROM range(100) t(i)`);

const atlas = new EmbeddingAtlas(document.getElementById('atlas'), {
  coordinator,
  data: { table: 'points', id: 'id', projection: { x: 'x', y: 'y' } }
});
```

The target element needs an explicit size. Call `atlas.destroy()` when unmounting.
For an in-browser database, supply `wasmConnector()` instead. Older standalone
viewer sources that import `socketConnector` must update their transport to REST
or WASM; Mosaic's servers use HTTP and no longer provide the WebSocket connector.

## Server benchmarks

Run `bazelisk run //packages/server/bench:bench -- -n 100 -w 5` to compare the
Rust, Go, Python and Node servers. Bazel builds the executables and supplies the
benchmark datasets; the runner starts each server in a temporary directory and
measures the same HTTP query suite. Use `-p 3001` to select a port, or
`--servers python,node` to choose among the target's included servers.
The runner waits for each child to report a successful bind before querying it.
An occupied port or a server startup failure stops the command with a nonzero
exit status, without querying an existing server on that port.

For a single implementation, use `:bench_rust`, `:bench_go`, `:bench_python` or
`:bench_node` in the same package. These targets build only their selected server.
Use `--config=release` before the target for optimized Rust benchmark builds.
`bazelisk test //packages/server/bench:smoke` runs a bounded startup and query
check for all four servers; individual `:smoke_rust`, `:smoke_go`,
`:smoke_python` and `:smoke_node` targets are also available. The package's
`:check` runs Python lint, formatting and unit tests without building servers.

## Package targets

JavaScript packages expose `:types`, `:pkg`, `:tarball` and `:check`. Checks cover
runtime tests, typechecking, lint and installed-package consumers. Python packages
expose `:wheel`, `:sdist` and `:check`. Server packages expose their executable and
`:check` targets; Rust also exposes `:clippy`.

Shared JavaScript rules live in `build/javascript.bzl`; Python rules live in
`build/python/`. Package BUILD files declare their sources and consumers. CUE
family actions stay independently selectable and cached. Source files, templates
and fixtures are declared inputs; ordinary actions write only to Bazel outputs.
