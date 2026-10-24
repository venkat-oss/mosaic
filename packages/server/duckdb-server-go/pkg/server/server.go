package server

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"mime"
	"net/http"
	"strings"

	"github.com/klauspost/compress/gzhttp"

	"github.com/uwdata/mosaic/packages/server/duckdb-server-go/pkg/query"
)

type queryParams struct {
	Type *CommandType `json:"type"`
	SQL  *string      `json:"sql"`
	raw  []byte
}

const arrowContentType = "application/vnd.apache.arrow.stream"

// commandExecutor is private so the server package does not expose query's
// current schema-policy plumbing as a supported extension point.
type commandExecutor interface {
	Exec(context.Context, string) error
	Query(context.Context, string, *query.ValidationPolicy) ([]byte, error)
}

type handler struct {
	db           commandExecutor
	logger       *slog.Logger
	authorizer   commandAuthorizer
	httpHandler  http.Handler
	cacheControl string
	varyHeaders  []string
}

// New constructs a Mosaic HTTP handler backed by db. Omitting
// WithAuthorizer preserves unrestricted command behavior.
func New(db *query.DB, opts ...Option) (http.Handler, error) {
	if db == nil {
		return nil, errors.New("server: database is required")
	}

	cfg, err := applyOptions(opts)
	if err != nil {
		return nil, err
	}

	return newHandler(db, cfg), nil
}

func newHandler(db commandExecutor, cfg config) *handler {
	s := &handler{
		db:           db,
		logger:       cfg.logger,
		authorizer:   cfg.authorizer,
		cacheControl: cfg.cacheControl,
		varyHeaders:  cfg.varyHeaders,
	}

	s.httpHandler = newCORSHandler(cfg.cors, cfg.corsProtection, gzhttp.GzipHandler(http.HandlerFunc(s.handleHTTP)))
	if cfg.maxBytes > 0 {
		s.httpHandler = http.MaxBytesHandler(s.httpHandler, cfg.maxBytes)
	}

	return s
}

func (s *handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	if s.cacheControl != "" || w.Header().Get("Cache-Control") == "" {
		w.Header().Set("Cache-Control", "no-store")
	}
	if len(s.varyHeaders) > 0 {
		w.Header().Add("Vary", strings.Join(s.varyHeaders, ", "))
	}

	s.httpHandler.ServeHTTP(w, r)
}

func (s *handler) handleHTTP(w http.ResponseWriter, r *http.Request) {
	var params queryParams

	switch r.Method {
	case http.MethodPost:
		mediaType, _, mediaErr := mime.ParseMediaType(r.Header.Get("Content-Type"))
		if mediaErr != nil || mediaType != "application/json" {
			s.writeError(w, r, &query.ProtocolError{Message: "Content-Type must be application/json", Code: "bad_request", Reason: "unsupported_media_type", Status: 415})
			return
		}
		raw, err := io.ReadAll(r.Body)
		if err == nil {
			params, err = decodeParams(raw)
		}
		if err != nil {
			s.writeError(w, r, fmt.Errorf("%w: decode request body: %w", ErrInvalidCommand, err))
			return
		}
		params.raw = raw

	case http.MethodGet:
		q := r.URL.Query()
		if q.Has("type") {
			params.Type = new(CommandType(q.Get("type")))
		}
		if q.Has("sql") {
			params.SQL = new(q.Get("sql"))
		}

	default:
		w.Header().Set("Allow", "GET, POST, OPTIONS")
		s.writeError(w, r, fmt.Errorf("%w: %s", errMethodNotAllowed, r.Method))
		return
	}

	data, err := s.execCommand(r, params)
	if err != nil {
		s.writeError(w, r, err)
		return
	}

	if *params.Type == CommandExec {
		w.WriteHeader(http.StatusOK)
		return
	}

	if r.Method == http.MethodGet && s.cacheControl != "" {
		etag := responseETag(data, responseEncoding(r, data))
		if value := strings.Join(r.Header.Values("If-Match"), ","); value != "" && !matchesETag(value, etag, false) {
			s.writeError(w, r, &query.ProtocolError{Message: "If-Match did not match", Code: "bad_request", Reason: "precondition_failed", Status: 412})
			return
		}
		w.Header().Set("ETag", etag)
		w.Header().Set("Cache-Control", s.cacheControl)
		if matchesETag(strings.Join(r.Header.Values("If-None-Match"), ","), etag, true) {
			w.WriteHeader(http.StatusNotModified)
			return
		}
	}

	if *params.Type == CommandPreagg {
		w.Header().Set("Content-Type", "application/json")
	} else {
		w.Header().Set("Content-Type", arrowContentType)
	}
	if _, err = w.Write(data); err != nil {
		s.logger.Error("server: failed to write response", "error", err)
	}
}

func (s *handler) execCommand(r *http.Request, params queryParams) ([]byte, error) {
	if err := params.Validate(); err != nil {
		return nil, err
	}
	if r.Method == http.MethodGet && *params.Type != CommandArrow {
		return nil, &query.ProtocolError{Message: "GET only accepts arrow", Code: "bad_request", Reason: "invalid_field", Field: "type", Status: 400}
	}
	ctx := r.Context()
	var err error
	var policy *query.ValidationPolicy

	if s.authorizer != nil {
		if policy, err = s.authorizer(r, params); err != nil {
			return nil, err
		}
	}

	switch *params.Type {
	case CommandExec:
		if policy != nil {
			return nil, query.ErrExecWithValidation
		}
		return nil, s.db.Exec(ctx, *params.SQL)

	case CommandArrow:
		if r.Method == http.MethodGet {
			if db, ok := s.db.(interface {
				QueryReadOnly(context.Context, string, *query.ValidationPolicy) ([]byte, error)
			}); ok {
				return db.QueryReadOnly(ctx, *params.SQL, policy)
			}
		}
		return s.db.Query(ctx, *params.SQL, policy)
	case CommandPreagg:
		if db, ok := s.db.(interface {
			Preaggregate(context.Context, string, *query.ValidationPolicy) (*query.PreaggResponse, error)
		}); ok {
			result, err := db.Preaggregate(ctx, *params.SQL, policy)
			if err != nil {
				return nil, err
			}
			return json.Marshal(result)
		}
		return nil, &query.ProtocolError{Message: "Preaggregation is disabled", Code: "unsupported_command", Reason: "command_disabled", Status: 400}

	default:
		return nil, fmt.Errorf("server: no executor for command type %q", *params.Type)
	}
}

func decodeParams(raw []byte) (queryParams, error) {
	var fields map[string]json.RawMessage
	if err := json.Unmarshal(raw, &fields); err != nil || fields == nil {
		return queryParams{}, &query.ProtocolError{Message: "Expected a JSON object", Code: "bad_request", Reason: "malformed_json", Status: 400}
	}
	var p queryParams
	for _, field := range []string{"type", "sql"} {
		value, ok := fields[field]
		if !ok {
			continue
		}
		var text string
		if err := json.Unmarshal(value, &text); err != nil || string(value) == "null" {
			return p, &query.ProtocolError{Message: "Invalid field: " + field, Code: "bad_request", Reason: "invalid_field", Field: field, Status: 400}
		}
		if field == "type" {
			p.Type = new(CommandType(text))
		} else {
			p.SQL = new(text)
		}
	}
	return p, nil
}

func (p queryParams) Validate() error {
	for _, field := range []string{"type", "sql"} {
		var value *string
		if field == "type" {
			if p.Type != nil {
				text := string(*p.Type)
				value = &text
			}
		} else {
			value = p.SQL
		}
		if value == nil {
			return &query.ProtocolError{Message: "Missing required field: " + field, Code: "bad_request", Reason: "missing_field", Field: field, Status: 400}
		}
		if strings.TrimSpace(*value) == "" {
			return &query.ProtocolError{Message: "Invalid field: " + field, Code: "bad_request", Reason: "invalid_field", Field: field, Status: 400}
		}
	}
	if *p.Type != CommandArrow && *p.Type != CommandExec && *p.Type != CommandPreagg {
		return &query.ProtocolError{Message: "Invalid command type", Code: "bad_request", Reason: "invalid_field", Field: "type", Status: 400}
	}
	return nil
}
