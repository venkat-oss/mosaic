package server

import (
	"bytes"
	"context"
	"database/sql/driver"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"os"
	"strings"
	"testing"

	"github.com/apache/arrow-go/v18/arrow/ipc"
	"github.com/duckdb/duckdb-go/v2"
	"github.com/stretchr/testify/require"

	fixture "github.com/uwdata/mosaic/packages/server/duckdb-server-go/internal/gatekeepertest"
	"github.com/uwdata/mosaic/packages/server/duckdb-server-go/pkg/query"
)

func commandRequest(method, target string, body io.Reader) *http.Request {
	request := httptest.NewRequest(method, target, body)
	if method == http.MethodPost {
		request.Header.Set("Content-Type", "application/json")
	}
	return request
}

func errorMessage(t *testing.T, body []byte) string {
	t.Helper()
	var envelope struct {
		Error string `json:"error"`
	}
	require.NoError(t, json.Unmarshal(body, &envelope))
	return envelope.Error
}

func setupTestDB(t *testing.T) *query.DB {
	t.Helper()
	return setupDB(t, nil)
}

func setupConfiguredDB(t *testing.T, configure string, opts ...query.OptionFunc) *query.DB {
	t.Helper()
	return setupDB(t, func(execer driver.ExecerContext) error {
		if err := fixture.Load(t.Context(), execer); err != nil {
			return err
		}
		if configure == "" {
			return nil
		}
		_, err := execer.ExecContext(t.Context(), configure, nil)
		return err
	}, opts...)
}

func setupDB(t *testing.T, init func(driver.ExecerContext) error, opts ...query.OptionFunc) *query.DB {
	t.Helper()
	dsn := ":memory:"
	if init != nil {
		dsn = fixture.DSN(dsn)
	}
	connector, err := duckdb.NewConnector(dsn, init)
	require.NoError(t, err)
	t.Cleanup(func() { require.NoError(t, connector.Close()) })
	db, err := query.New(t.Context(), connector, opts...)
	require.NoError(t, err)
	t.Cleanup(db.Close)
	return db
}

func mustHandler(t *testing.T, executor commandExecutor, opts ...Option) *handler {
	t.Helper()
	cfg, err := applyOptions(opts)
	require.NoError(t, err)
	return newHandler(executor, cfg)
}

type failOnCallExecutor struct{ testing.TB }

func (e failOnCallExecutor) Exec(context.Context, string) error { return e.fail("Exec") }
func (e failOnCallExecutor) Query(context.Context, string, *query.ValidationPolicy) ([]byte, error) {
	return nil, e.fail("Query")
}
func (e failOnCallExecutor) fail(method string) error {
	e.Helper()
	err := fmt.Errorf("unexpected command executor call: %s", method)
	e.Error(err)
	return err
}

func arrowRows(t *testing.T, data []byte) []map[string]any {
	t.Helper()
	rdr, err := ipc.NewReader(bytes.NewReader(data))
	require.NoError(t, err)
	defer rdr.Release()
	rows := []map[string]any{}
	for rdr.Next() {
		batchJSON, err := rdr.RecordBatch().MarshalJSON()
		require.NoError(t, err)
		var batch []map[string]any
		require.NoError(t, json.Unmarshal(batchJSON, &batch))
		rows = append(rows, batch...)
	}
	require.NoError(t, rdr.Err())
	return rows
}

func TestArrowResponseFraming(t *testing.T) {
	db := setupTestDB(t)
	handler, err := New(db)
	require.NoError(t, err)
	body := `{"type":"arrow","sql":"SELECT 1 AS value"}`
	req := commandRequest(http.MethodPost, "/", strings.NewReader(body))
	res := httptest.NewRecorder()
	handler.ServeHTTP(res, req)
	require.Equal(t, http.StatusOK, res.Code)
	require.Equal(t, "application/vnd.apache.arrow.stream", res.Header().Get("Content-Type"))
	want := []map[string]any{{"value": float64(1)}}
	require.Equal(t, want, arrowRows(t, res.Body.Bytes()))
}

func TestValidationErrorResponses(t *testing.T) {
	for _, tc := range []struct {
		name   string
		err    error
		status int
		level  string
	}{
		{"denial", query.ErrorDetails{Code: "forbidden", Message: "private-diagnostic"}, 403, "WARN"},
		{"unsupported", query.ErrorDetails{Code: "unsupported", Message: "private-diagnostic"}, 400, "WARN"},
		{"parser", query.ErrorDetails{Code: "parser", Message: "private-diagnostic"}, 400, "WARN"},
		{"binding", query.ErrorDetails{Code: "binding", Message: "private-diagnostic"}, 500, "ERROR"},
		{"invalid SQL", query.ErrorDetails{Code: "invalid_input", Message: "private-diagnostic"}, 400, "WARN"},
		{"invalid policy", errors.Join(query.ErrInvalidPolicy, query.ErrorDetails{Code: "invalid_input", Message: "private-diagnostic"}), 500, "ERROR"},
		{"driver failure", errors.New("private-diagnostic"), 500, "ERROR"},
	} {
		t.Run(tc.name, func(t *testing.T) {
			var logs bytes.Buffer
			err := errors.Join(query.ErrValidation, tc.err)
			executor := &spyCommandExecutor{failOnCallExecutor: failOnCallExecutor{t},
				queryFn: func(context.Context, string, *query.ValidationPolicy) ([]byte, error) {
					return nil, err
				},
			}
			handler := mustHandler(t, executor, WithLogger(slog.New(slog.NewJSONHandler(&logs, nil))))
			body := `{"type":"arrow","sql":"SELECT 1"}`
			res := httptest.NewRecorder()
			handler.ServeHTTP(res, commandRequest(http.MethodPost, "/", strings.NewReader(body)))
			require.Equal(t, tc.status, res.Code)
			require.Equal(t, err.Error(), errorMessage(t, res.Body.Bytes()))
			var record map[string]any
			require.NoError(t, json.NewDecoder(bytes.NewReader(logs.Bytes())).Decode(&record))
			require.Equal(t, tc.level, record["level"])
			require.Contains(t, record["error"], "private-diagnostic")
		})
	}
}

func TestMain(m *testing.M) {
	home, err := os.MkdirTemp(os.Getenv("TEST_TMPDIR"), "mosaic-go-tests-")
	if err != nil {
		panic(err)
	}
	for _, name := range []string{"HOME", "USERPROFILE"} {
		if err := os.Setenv(name, home); err != nil {
			panic(err)
		}
	}
	code := m.Run()
	_ = os.RemoveAll(home)
	os.Exit(code)
}
