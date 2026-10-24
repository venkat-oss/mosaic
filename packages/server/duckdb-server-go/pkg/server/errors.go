package server

import (
	"context"
	"encoding/json"
	"errors"
	"github.com/duckdb/duckdb-go/v2"
	"log/slog"
	"net/http"
	"strings"

	"github.com/uwdata/mosaic/packages/server/duckdb-server-go/pkg/query"
)

var errMethodNotAllowed = errors.New("server: method not allowed")

func (s *handler) writeError(w http.ResponseWriter, r *http.Request, err error) {
	status := http.StatusInternalServerError
	code, reason, field := "internal_error", "execution_failed", ""
	var reference *query.TableReference
	if protocol, ok := errors.AsType[*query.ProtocolError](err); ok {
		code, reason, field, reference, status = protocol.Code, protocol.Reason, protocol.Field, protocol.Reference, protocol.Status
	} else if _, ok := errors.AsType[*http.MaxBytesError](err); ok {
		code, reason, status = "bad_request", "payload_too_large", 413
	} else if errors.Is(err, errMethodNotAllowed) {
		code, reason, status = "bad_request", "method_not_allowed", 405
	} else if errors.Is(err, ErrUnauthenticated) {
		code, reason, status = "unauthenticated", "authentication_required", 401
	} else if errors.Is(err, ErrPermissionDenied) {
		code, reason, status = "forbidden", "access_denied", 403
	} else if errors.Is(err, query.ErrAccessDenied) {
		code, reason, status = "forbidden", "policy_denied", 403
	} else if errors.Is(err, query.ErrExecWithValidation) {
		code, reason, status = "unsupported_command", "command_disabled", 400
	} else if details, ok := errors.AsType[query.ErrorDetails](err); ok && !errors.Is(err, query.ErrInvalidPolicy) {
		switch details.Code {
		case "unsupported":
			code, reason, status = "bad_request", "unsupported_statement", 400
		case "parser":
			code, reason, status = "bad_request", "sql_parse_error", 400
		case "binding":
			code, reason, status = "internal_error", "execution_failed", 500
		case "invalid_input":
			code, reason, field, status = "bad_request", "invalid_field", "sql", 400
		default:
			reason, status = "validation_failed", 500
		}
	} else if errors.Is(err, query.ErrInvalidPolicy) || errors.Is(err, query.ErrValidation) {
		reason = "validation_failed"
	} else if errors.Is(err, query.ErrUnsupportedStatement) {
		code, reason, status = "bad_request", "unsupported_statement", 400
	} else if errors.Is(err, ErrInvalidCommand) {
		code, reason, status = "bad_request", "malformed_json", 400
	} else if engine, ok := errors.AsType[*duckdb.Error](err); ok && engine.Type == duckdb.ErrorTypeOutOfMemory {
		code, reason, status = "resource_exhausted", "resource_limit_exceeded", 429
	} else if engine, ok := errors.AsType[*duckdb.Error](err); ok && engine.Type == duckdb.ErrorTypeParser {
		code, reason, status = "bad_request", "sql_parse_error", 400
	} else if engine, ok := errors.AsType[*duckdb.Error](err); ok && engine.Type == duckdb.ErrorTypeTransaction && strings.Contains(engine.Error(), "read-only mode") {
		code, reason, status = "bad_request", "not_read_only", 400
	} else if errors.Is(err, context.DeadlineExceeded) {
		code, reason, status = "deadline_exceeded", "command_deadline_exceeded", 504
	}
	if !errors.Is(err, context.Canceled) && !errors.Is(err, context.DeadlineExceeded) {
		level := slog.LevelWarn
		if status >= http.StatusInternalServerError {
			level = slog.LevelError
		}
		s.logger.Log(r.Context(), level, "server: request failed", "status", status, "error", err)
	}
	body := map[string]any{"error": err.Error(), "code": code, "reason": reason}
	if field != "" {
		body["field"] = field
	}
	if reference != nil {
		body["reference"] = reference
	}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if encodeErr := json.NewEncoder(w).Encode(body); encodeErr != nil {
		s.logger.Error("server: failed to write error", "error", encodeErr)
	}
}
