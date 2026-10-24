package serverprotocol

import (
	"encoding/json"
	"strings"
	"idl.uw.edu/mosaic/api/model"
)

_documentation: """
	# Server Protocol

	The Node, Python, Go and Rust servers implement this HTTP protocol. Its canonical contract is `api/server/model.cue`; the shared native server tests exercise the same generated cases.

	## Requests

	POST a JSON object with case-sensitive, nonempty string fields `type` and `sql`. Additional application fields are accepted and cannot override those fields. `application/json; charset=utf-8` is supported. Servers accept commands of at least 1 MiB, including GET query strings.

	GET accepts flat `type=arrow&sql=...` URL parameters and runs exactly one read-only statement. A JSON `query` envelope is rejected. Mutating CTEs, stateful functions and statements are rejected before execution. OPTIONS supports browser CORS preflight; unsupported methods return 405 with an Allow header. CORS headers are present on successful and failed responses.

	| Type | Behavior |
	| --- | --- |
	\(strings.Join([for Command in commands {"| `" + Command.name + "` | " + Command.description + " |"}], "\n"))

	## Responses

	Arrow responses use `application/vnd.apache.arrow.stream`. Clients can decode them directly as streams, including empty results and results spanning multiple batches.

	A preaggregation response contains `reference: {catalog, schema, table}` and `createdAt`. The reference contains raw identifier components; `schema` is a nonempty array. Quote each component separately, doubling embedded double quotes, before joining with dots. Optional nonnegative `rows` and positive `bytes` describe the materialization. A failed build does not publish a partial table.

	```json
	{"reference":{"catalog":"memory","schema":["mosaic"],"table":"preagg_example"},"createdAt":"2026-10-23T00:00:00Z"}
	```

	## Errors

	Failed commands return a JSON object with nonempty `error`, `code` and `reason` fields. Missing or invalid protocol fields also include `field`. SQL syntax and statement-count errors are rejected before execution. Binder, catalog and execution errors are server errors.

	| Code | HTTP status | Reasons |
	| --- | --- | --- |
	\(strings.Join([for Error in errors {"| `" + Error.code + "` | " + "\(Error.status)" + " | " + strings.Join([for Reason in Error.reasons {"`" + Reason + "`"}], ", ") + " |"}], "\n"))

	Transport-specific bad-request statuses are 405 for unsupported methods, 412 for preconditions, 413 for size limits, and 415 for unsupported media types. A missing managed materialization includes its table reference so a client can rebuild it. Ordinary missing source tables are execution errors.

	## Running and testing

	Run a server with the repository's `pnpm server:node`, `pnpm server`, `pnpm server:go` or `pnpm server:rust` aliases. Run `bazelisk test //packages/server:protocol` for the same protocol suite against all four native executables, or select `:protocol_node`, `:protocol_python`, `:protocol_go` or `:protocol_rust`. These tests cover HTTP decoding, errors, read-only checks, native Arrow types, large requests and preaggregation lifecycle.

	TLS, HTTP/2, authentication, caching and deployment-specific policy settings remain explicit server options. See the [server guide](https://github.com/uwdata/mosaic/blob/main/packages/server/README.md) for startup and certificate configuration. The common HTTP query protocol is independent of those deployment options.
	""" + "\n"

contribution: {
	source: "./api/server"
	id:     "server-protocol"
	native: definitions: {}
	files: {
		"packages/server/protocol.json":      json.Indent(json.Marshal(contract), "", "  ") + "\n"
		"docs/api/duckdb/server-protocol.md": _documentation
	}
	sections: []
	nativeChecks: []
	referenceSections: []
	symbols: model.#Symbols & {marks: [], attributes: [], encodings: [], legends: []}
	schemas: []
}
