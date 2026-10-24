# DuckDB Server

[![Crates.io](https://img.shields.io/crates/v/duckdb-server.svg)](https://crates.io/crates/duckdb-server)

A Rust-based server that runs a local DuckDB instance and supports queries over HTTP/HTTPS, returning data in [Apache Arrow](https://arrow.apache.org/) format.

_Note:_ This package provides a local DuckDB server. To instead use DuckDB-WASM in the browser, use the `wasmConnector` in the [`mosaic-core`](https://github.com/uwdata/mosaic/tree/main/packages/mosaic/core) package.

## Usage

Install the server with Cargo or [Cargo B(inary)Install](https://github.com/cargo-bins/cargo-binstall).

```sh
cargo install duckdb-server --features bundled
# or
cargo binstall duckdb-server
```

Then run the server with

```sh
duckdb-server
```

You can disable or customize logging with the `RUST_LOG` environment variable.

```sh
env RUST_LOG="" duckdb-server
```

The server can reuse existing sockets with `listenfd`.

```sh
systemfd --no-pid -s http::3000 -- duckdb-server
```

To set up shared HTTPS/HTTP/2 certificates, run from the repository root:

```sh
pnpm mkcert
```

Install native mkcert on `PATH` first. The server checks the working directory, then the shared user directory for `localhost.pem` and `localhost-key.pem`. See the [server guide](../README.md) for paths, local overrides, and renewal.

With certificates present, the server accepts both HTTP and HTTPS on the same port.

## API

The server implements the [shared HTTP protocol](https://uwdata.github.io/mosaic/api/duckdb/server-protocol): POST accepts `arrow`, `exec`, and `preagg` JSON commands. GET accepts read-only `arrow` commands through flat `type` and `sql` URL parameters. Arrow responses are IPC streams; errors use the common JSON error envelope.

For example: `http://localhost:3000/?type=arrow&sql=SELECT%201`.

## Developers

### Build

From the repository root, build the server and benchmark with

```sh
bazelisk build //packages/server/duckdb-server-rust:duckdb-server //packages/server/duckdb-server-rust:benchmark
```

Use `--config=release` for an optimized build. The server binary is under
`bazel-bin/packages/server/duckdb-server-rust/duckdb-server`.

### Develop

Run the server with

```sh
bazelisk run //packages/server/duckdb-server-rust:duckdb-server
```

Pass server arguments after `--`:

```sh
bazelisk run //packages/server/duckdb-server-rust:duckdb-server -- --port 3001
```

Before sending a pull request, run the runtime tests, format check and Clippy with

```sh
bazelisk test //packages/server/duckdb-server-rust:check
bazelisk build //packages/server/duckdb-server-rust:clippy
```

Clippy treats warnings as errors. Bazel resolves the pinned Rust toolchain and
dependencies from `Cargo.toml` and `Cargo.lock`, and links the declared official
DuckDB 2 shared library. Run with Bazel so its declared runtime libraries are
available. A standalone Cargo build can use `--features bundled` to compile the
engine, or set `DUCKDB_LIB_DIR` to an installed DuckDB 2 SDK. The repository's Bazel
build also raises the HTTP dependency's URI limit to support large GET queries;
standalone Cargo builds retain its upstream 64 KiB URI limit.

Run the benchmarks with

```sh
bazelisk run --config=release //packages/server/duckdb-server-rust:benchmark
```

### Update Dependencies

Update the lockfile with `cargo update` and look for outdated dependencies with [cargo-outdated](https://github.com/kbknapp/cargo-outdated) `cargo outdated -d 1`.

### Publishing

Bump the version in `Cargo.toml` and then run `cargo publish`.
