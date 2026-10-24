# Bazel build workflow

Bazel owns repository builds, tests and publishable archives. Package scripts
delegate to the same native targets. Bazelisk selects `.bazelversion`; toolchains
and dependencies are declared in `MODULE.bazel` and its lockfile.

| Task | Command |
| --- | --- |
| Build packages, servers, docs and examples | `bazelisk build //:build` |
| Run runtime, type, lint and installed-package checks | `bazelisk test //:check` |
| Build npm tarballs and Python archives | `bazelisk build //:packages` |
| List archive paths | `bazelisk cquery //:packages --output=files` |
| Run browser suites in the matching container | `bin/visual-test.sh` |
| Build docs | `pnpm docs:build` |

Select a package's `:check` target while developing. Browser tests are separate
from the ordinary suite because they require the matching Playwright container.
Builds write to Bazel outputs; generator synchronization and snapshot updates are
explicit run operations. Installed packages need neither Bazel nor repository
build tools.

The spec package materializes the published schema at its existing
`dist/mosaic-schema.json` path. Python bindings are moving to their owning CUE families; ordinary package
compilation consumes committed bindings. Validate a family with its
`//api/<family>:contribution` target. Whole-API synchronization follows root
composition after every family has an owner.

Release versioning remains explicit. Lerna updates package metadata, and the
release workflow builds `//:packages` before publishing the archives. Do not run
`pnpm docs:schema` or version hooks as checks: they publish schema history.
