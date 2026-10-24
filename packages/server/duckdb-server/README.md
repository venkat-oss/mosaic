# Mosaic DuckDB Server

[![PyPi](https://img.shields.io/pypi/v/duckdb-server.svg)](https://pypi.org/project/duckdb-server/)

A Python-based server that runs a local DuckDB instance and supports queries over HTTP, returning data in [Apache Arrow](https://arrow.apache.org/) format.

_Note:_ This package provides a local DuckDB server. To instead use DuckDB-WASM in the browser, use the `wasmConnector` in the [`mosaic-core`](https://github.com/uwdata/mosaic/tree/main/packages/mosaic/core) package.

## Installation and usage

We recommend running the server in an isolated environment with [uvx](https://docs.astral.sh/uv/). For example, to directly run the server, use:

```bash
uvx duckdb-server
```

Alternatively, you can install the server with `pip install duckdb-server`. Then you can start the server with `duckdb-server`.

## Developer Setup

We use [uv](https://docs.astral.sh/uv/) to manage our development setup.

Start the server with `uv run duckdb-server`. The server will not restart when the code changes.

Start the server in development with `pnpm dev`. The server restarts when you change the code.

Run `uv run ruff check --fix` and `uv run ruff format` to lint the code.

To run the tests, use `uv run pytest`.

## API

The server implements the [shared HTTP protocol](https://uwdata.github.io/mosaic/api/duckdb/server-protocol): POST accepts `arrow`, `exec`, and `preagg` JSON commands. GET accepts read-only `arrow` commands through flat `type` and `sql` URL parameters. Arrow responses are IPC streams; errors use the common JSON error envelope.

For example: `http://localhost:3000/?type=arrow&sql=SELECT%201`.

Python 3.11 or newer is required. Dependencies include DuckDB 2 and PyArrow 26.

## Publishing

Run the build with `uv build`. Then publish with `uvx twine upload --skip-existing ../../dist/*`. We publish using tokens so when asked, set the username to `__token__` and then use your token as the password. Alternatively, create a [`.pypirc` file](https://packaging.python.org/en/latest/guides/distributing-packages-using-setuptools/#create-an-account).

