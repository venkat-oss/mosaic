package query

import (
	"context"
	"crypto/sha256"
	"database/sql"
	"encoding/hex"
	"encoding/json"
	"errors"
	"github.com/duckdb/duckdb-go/v2"
	"github.com/duckdb/duckdb-go/v2/mapping"
	"strings"
	"time"
)

const readOnlyPlan = `WITH plan AS (SELECT system.main.json_serialize_plan(?) AS tree)
SELECT system.main.json_extract_string(tree, '$.error')::BOOLEAN AS unsupported,
EXISTS (SELECT 1 FROM system.main.json_tree(tree) WHERE
system.main.json_extract_string(value, '$.expression_class') = 'BOUND_FUNCTION'
AND system.main.json_extract_string(value, '$.qname.path[0]') = 'system'
AND system.main.json_extract_string(value, '$.qname.path[#-1]') IN ('nextval', 'setval', 'setseed', 'write_log')) AS writes
FROM plan`

type TableReference struct {
	Catalog string   `json:"catalog"`
	Schema  []string `json:"schema"`
	Table   string   `json:"table"`
}

type PreaggResponse struct {
	Reference TableReference `json:"reference"`
	CreatedAt string         `json:"createdAt"`
}

type ProtocolError struct {
	Message   string
	Code      string
	Reason    string
	Field     string
	Status    int
	Reference *TableReference
}

func (e *ProtocolError) Error() string { return e.Message }

func (db *DB) checkSQL(ctx context.Context, conn *sql.Conn, text string, readOnly bool) error {
	err := db.statementCount(text)
	if err != nil || !readOnly {
		return err
	}
	return checkReadOnly(ctx, conn, text)
}

func checkReadOnly(ctx context.Context, conn *sql.Conn, text string) error {
	var err error
	var parsed struct {
		Error bool `json:"error"`
	}
	var data string
	if err := conn.QueryRowContext(ctx, "SELECT CAST(system.main.json_serialize_sql(?) AS VARCHAR)", text).Scan(&data); err != nil {
		return err
	}
	if err := json.Unmarshal([]byte(data), &parsed); err != nil {
		return err
	}
	if parsed.Error {
		return &ProtocolError{Message: "Expected a read-only SELECT statement", Code: "bad_request", Reason: "not_read_only", Status: 400}
	}
	if _, err := conn.ExecContext(ctx, "BEGIN TRANSACTION READ ONLY"); err != nil {
		return err
	}
	_, err = conn.ExecContext(ctx, "EXPLAIN "+text)
	_, rollback := conn.ExecContext(context.WithoutCancel(ctx), "ROLLBACK")
	if engine, ok := errors.AsType[*duckdb.Error](err); ok && engine.Type == duckdb.ErrorTypeTransaction && strings.Contains(engine.Error(), "read-only mode") {
		err = &ProtocolError{Message: "Expected a read-only SELECT statement", Code: "bad_request", Reason: "not_read_only", Status: 400}
	}
	if failure := errors.Join(err, rollback); failure != nil {
		return failure
	}
	var unsupported, writes bool
	if err := conn.QueryRowContext(ctx, readOnlyPlan, text).Scan(&unsupported, &writes); err != nil {
		return err
	}
	if unsupported {
		return &ProtocolError{Message: "Cannot inspect this statement", Code: "bad_request", Reason: "unsupported_statement", Status: 400}
	}
	if writes {
		return &ProtocolError{Message: "Expected a read-only SELECT statement", Code: "bad_request", Reason: "not_read_only", Status: 400}
	}
	return nil
}

func (db *DB) QueryReadOnly(ctx context.Context, text string, policy *ValidationPolicy) ([]byte, error) {
	return db.query(ctx, text, policy, true)
}

func (db *DB) Preaggregate(ctx context.Context, text string, policy *ValidationPolicy) (response *PreaggResponse, failure error) {
	defer func() {
		if failure != nil {
			failure = db.missingMaterialization(failure)
		}
	}()
	conn, err := db.db.Conn(ctx)
	if err != nil {
		return nil, err
	}
	defer func() {
		if err := conn.Close(); err != nil {
			db.logger.Error("query: failed to release connection", "error", err)
		}
	}()
	db.tablesMu.Lock()
	defer db.tablesMu.Unlock()
	if err := db.checkSQL(ctx, conn, text, false); err != nil {
		return nil, err
	}
	if policy == nil && db.validation {
		policy = &ValidationPolicy{}
	}
	if policy != nil {
		if _, err := db.validateSQL(ctx, conn, text, *policy); err != nil {
			return nil, err
		}
	}
	if err := checkReadOnly(ctx, conn, text); err != nil {
		return nil, err
	}
	sum := sha256.Sum256([]byte(text))
	table := "preagg_" + hex.EncodeToString(sum[:16])
	var exists int
	if err := conn.QueryRowContext(ctx, "SELECT system.main.count(*) FROM system.information_schema.tables WHERE table_schema = 'mosaic' AND table_name = ?", table).Scan(&exists); err != nil {
		return nil, err
	}
	if cached, ok := db.tables[table]; ok && exists > 0 {
		return &cached, nil
	}
	if _, err := conn.ExecContext(ctx, "CREATE SCHEMA IF NOT EXISTS mosaic"); err != nil {
		return nil, err
	}
	if _, err := conn.ExecContext(ctx, "CREATE OR REPLACE TABLE mosaic."+table+" AS "+text); err != nil {
		return nil, err
	}
	var catalog string
	if err := conn.QueryRowContext(ctx, "SELECT system.main.current_database()").Scan(&catalog); err != nil {
		return nil, err
	}
	result := PreaggResponse{Reference: TableReference{Catalog: catalog, Schema: []string{"mosaic"}, Table: table}, CreatedAt: time.Now().UTC().Format(time.RFC3339Nano)}
	db.tables[table] = result
	return &result, nil
}

func (db *DB) missingMaterialization(err error) error {
	db.tablesMu.Lock()
	defer db.tablesMu.Unlock()
	message := err.Error()
	if engine, ok := errors.AsType[*duckdb.Error](err); ok {
		message = engine.Error()
	}
	for table, result := range db.tables {
		if strings.HasPrefix(message, "Catalog Error: Table with name "+table+" does not exist") {
			reference := result.Reference
			return &ProtocolError{Message: err.Error(), Code: "table_not_found", Reason: "materialization_missing", Status: 404, Reference: &reference}
		}
	}
	return err
}

func (db *DB) statementCount(text string) error {
	db.parserMu.Lock()
	defer db.parserMu.Unlock()
	if db.parserConnection.Ptr == nil {
		var message string
		if mapping.OpenExt(":memory:", &db.parserDatabase, mapping.Config{}, &message) != mapping.StateSuccess {
			return errors.New("query: could not open SQL parser: " + message)
		}
		if mapping.Connect(db.parserDatabase, &db.parserConnection) != mapping.StateSuccess {
			mapping.Close(&db.parserDatabase)
			return errors.New("query: could not connect SQL parser")
		}
	}
	var extracted mapping.ExtractedStatements
	count := mapping.ExtractStatements(db.parserConnection, text, &extracted)
	defer mapping.DestroyExtracted(&extracted)
	if message := mapping.ExtractStatementsError(extracted); message != "" {
		return &ProtocolError{Message: message, Code: "bad_request", Reason: "sql_parse_error", Status: 400}
	}
	if count != 1 {
		return &ProtocolError{Message: "Expected exactly one SQL statement", Code: "bad_request", Reason: "multiple_statements", Status: 400}
	}
	return nil
}
