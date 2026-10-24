package serverprotocol

import "time"

#Request: {
	type!: "arrow" | "exec" | "preagg"
	sql!:  string & =~"\\S"
	...
}
#Reference: {
	catalog!: string & !=""
	schema!: [string & !="", ...string & !=""]
	table!: string & !=""
}
#PreaggResponse: {
	reference!: #Reference
	createdAt!: time.Time
	rows?:      int & >=0
	bytes?:     int & >=1
}

commands: [
	{name: "arrow", description: "Execute exactly one SQL statement and return an Arrow IPC stream. A trailing semicolon is allowed. A zero-row result retains its schema and end-of-stream marker."},
	{name: "exec", description: "Execute one or more statements in order on one connection and return an empty HTTP 200 response. The server does not retry or promise rollback of earlier effects."},
	{name: "preagg", description: "Atomically materialize one read-only SELECT, VALUES, set operation or CTE. Return a fully qualified table reference and an RFC 3339 createdAt timestamp. Reusing a table preserves its timestamp; rebuilding after a drop changes it."},
]
errors: [
	{code: "bad_request", status: 400, reasons: ["malformed_json", "missing_field", "invalid_field", "sql_parse_error", "multiple_statements", "not_read_only", "unsupported_statement", "method_not_allowed", "payload_too_large", "unsupported_media_type", "precondition_failed"]},
	{code: "unauthenticated", status: 401, reasons: ["authentication_required", "authentication_failed"]},
	{code: "forbidden", status: 403, reasons: ["policy_denied", "access_denied"]},
	{code: "table_not_found", status: 404, reasons: ["materialization_missing"]},
	{code: "unsupported_command", status: 400, reasons: ["command_disabled"]},
	{code: "resource_exhausted", status: 429, reasons: ["resource_limit_exceeded"]},
	{code: "deadline_exceeded", status: 504, reasons: ["command_deadline_exceeded"]},
	{code: "internal_error", status: 500, reasons: ["execution_failed", "validation_failed", "invalid_server_configuration", "internal_failure"]},
]
#Error: {
	error!: string & !=""
	code!: or([for Error in errors {Error.code}])
	reason!:       string
	field?:        string & !=""
	reference?:    #Reference
	retryAfterMs?: int & >=0
	catalog?:      _|_
	schema?:       _|_
	table?:        _|_
	for Error in errors if code == Error.code {
		reason!: or(Error.reasons)
	}
	if reason == "missing_field" || reason == "invalid_field" {field!: string & !=""}
	if reason != "missing_field" && reason != "invalid_field" {field?: _|_}
	if code == "table_not_found" {reference!: #Reference}
	if code != "table_not_found" {reference?: _|_}
	if code != "resource_exhausted" {retryAfterMs?: _|_}
	...
}

let Commands = commands
let Errors = errors

contract: {
	commands: Commands
	errors:   Errors
	methods: ["GET", "POST", "OPTIONS"]
	arrowMediaType:      "application/vnd.apache.arrow.stream"
	minimumRequestBytes: 1048576
	invalidRequests: [
		{body: {sql: "SELECT 1"}, reason: "missing_field", field: "type"},
		{body: {type: "arrow"}, reason: "missing_field", field: "sql"},
		for Type in [null, 1, true, "", "csv", "ARROW"] {{body: {type: Type, sql: "SELECT 1"}, reason: "invalid_field", field: "type"}},
		for SQL in [null, 1, true, "", " \t\n"] {{body: {type: "arrow", sql: SQL}, reason: "invalid_field", field: "sql"}},
	]
}
