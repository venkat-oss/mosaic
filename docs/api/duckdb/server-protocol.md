# Server Protocol

The Node, Python, Go and Rust servers implement this HTTP protocol. Its canonical contract is `api/server/model.cue`; the shared native server tests exercise the same generated cases.

## Requests

POST a JSON object with case-sensitive, nonempty string fields `type` and `sql`. Additional application fields are accepted and cannot override those fields. `application/json; charset=utf-8` is supported. Servers accept commands of at least 1 MiB, including GET query strings.

GET accepts flat `type=arrow&sql=...` URL parameters and runs exactly one read-only statement. A JSON `query` envelope is rejected. Mutating CTEs, stateful functions and statements are rejected before execution. OPTIONS supports browser CORS preflight; unsupported methods return 405 with an Allow header. CORS headers are present on successful and failed responses.

| Type | Behavior |
| --- | --- |
| `arrow` | Execute exactly one SQL statement and return an Arrow IPC stream. A trailing semicolon is allowed. A zero-row result retains its schema and end-of-stream marker. |
| `exec` | Execute one or more statements in order on one connection and return an empty HTTP 200 response. The server does not retry or promise rollback of earlier effects. |
| `preagg` | Atomically materialize one read-only SELECT, VALUES, set operation or CTE. Return a fully qualified table reference and an RFC 3339 createdAt timestamp. Reusing a table preserves its timestamp; rebuilding after a drop changes it. |

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
| `bad_request` | 400 | `malformed_json`, `missing_field`, `invalid_field`, `sql_parse_error`, `multiple_statements`, `not_read_only`, `unsupported_statement`, `method_not_allowed`, `payload_too_large`, `unsupported_media_type`, `precondition_failed` |
| `unauthenticated` | 401 | `authentication_required`, `authentication_failed` |
| `forbidden` | 403 | `policy_denied`, `access_denied` |
| `table_not_found` | 404 | `materialization_missing` |
| `unsupported_command` | 400 | `command_disabled` |
| `resource_exhausted` | 429 | `resource_limit_exceeded` |
| `deadline_exceeded` | 504 | `command_deadline_exceeded` |
| `internal_error` | 500 | `execution_failed`, `validation_failed`, `invalid_server_configuration`, `internal_failure` |

Transport-specific bad-request statuses are 405 for unsupported methods, 412 for preconditions, 413 for size limits, and 415 for unsupported media types. A missing managed materialization includes its table reference so a client can rebuild it. Ordinary missing source tables are execution errors.

## Running and testing

Run a server with the repository's `pnpm server:node`, `pnpm server`, `pnpm server:go` or `pnpm server:rust` aliases. Run `bazelisk test //packages/server:protocol` for the same protocol suite against all four native executables, or select `:protocol_node`, `:protocol_python`, `:protocol_go` or `:protocol_rust`. These tests cover HTTP decoding, errors, read-only checks, native Arrow types, large requests and preaggregation lifecycle.

TLS, HTTP/2, authentication, caching and deployment-specific policy settings remain explicit server options. See the [server guide](https://github.com/uwdata/mosaic/blob/main/packages/server/README.md) for startup and certificate configuration. The common HTTP query protocol is independent of those deployment options.
