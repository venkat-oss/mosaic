use std::{
    collections::HashMap,
    ffi::{CStr, CString},
    ptr,
    sync::Mutex,
};

use anyhow::{anyhow, Result};
use async_trait::async_trait;
use duckdb::{ffi, Connection, DuckdbConnectionManager};
use serde_json::{json, Value};

use crate::interfaces::ProtocolError;

const READ_ONLY_PLAN: &str = r"WITH plan AS (SELECT system.main.json_serialize_plan(?) AS tree)
SELECT system.main.json_extract_string(tree, '$.error')::BOOLEAN AS unsupported,
EXISTS (SELECT 1 FROM system.main.json_tree(tree) WHERE
system.main.json_extract_string(value, '$.expression_class') = 'BOUND_FUNCTION'
AND system.main.json_extract_string(value, '$.qname.path[0]') = 'system'
AND system.main.json_extract_string(value, '$.qname.path[#-1]') IN ('nextval', 'setval', 'setseed', 'write_log')) AS writes
FROM plan";

#[async_trait]
pub trait Database: Send + Sync {
    async fn execute(&self, sql: &str) -> Result<()>;
    async fn get_arrow(&self, sql: &str) -> Result<Vec<u8>>;
    async fn get_arrow_readonly(&self, sql: &str) -> Result<Vec<u8>>;
    async fn validate(&self, sql: &str, read_only: bool) -> Result<()>;
    async fn preaggregate(&self, sql: &str) -> Result<Value>;
}

pub struct ConnectionPool {
    pool: r2d2::Pool<DuckdbConnectionManager>,
    tables: Mutex<HashMap<String, Value>>,
}

impl ConnectionPool {
    pub fn new(db_path: &str, pool_size: u32) -> Result<Self> {
        let manager = DuckdbConnectionManager::file(db_path)?;
        let pool = r2d2::Pool::builder().max_size(pool_size).build(manager)?;
        Ok(Self {
            pool,
            tables: Mutex::new(HashMap::new()),
        })
    }
    pub fn get(&self) -> Result<r2d2::PooledConnection<DuckdbConnectionManager>> {
        Ok(self.pool.get()?)
    }
    fn failure(&self, error: anyhow::Error) -> anyhow::Error {
        if let Ok(tables) = self.tables.lock() {
            let message = error.to_string();
            for (table, result) in tables.iter() {
                if message.starts_with(&format!(
                    "Catalog Error: Table with name {table} does not exist"
                )) {
                    let mut err = ProtocolError::new(message, "materialization_missing");
                    err.code = "table_not_found";
                    err.status = axum::http::StatusCode::NOT_FOUND;
                    err.reference = Some(result["reference"].clone());
                    return err.into();
                }
            }
        }
        error
    }
}

fn statement_count(sql: &str) -> Result<usize> {
    let sql =
        CString::new(sql).map_err(|e| ProtocolError::new(e.to_string(), "sql_parse_error"))?;
    // SAFETY: Handles belong to this scope; the error string is copied before extraction is destroyed.
    // duckdb-rs prepare executes preceding statements, so validation must use the C extractor.
    unsafe {
        let mut database = ptr::null_mut();
        if ffi::duckdb_open(c":memory:".as_ptr(), &mut database) != ffi::DuckDBSuccess {
            return Err(anyhow!("Could not open SQL parser"));
        }
        let mut connection = ptr::null_mut();
        if ffi::duckdb_connect(database, &mut connection) != ffi::DuckDBSuccess {
            ffi::duckdb_close(&mut database);
            return Err(anyhow!("Could not connect SQL parser"));
        }
        let mut extracted = ptr::null_mut();
        let count = ffi::duckdb_extract_statements(connection, sql.as_ptr(), &mut extracted);
        let message = ffi::duckdb_extract_statements_error(extracted);
        let error = if message.is_null() {
            None
        } else {
            let message = CStr::from_ptr(message).to_string_lossy();
            if message.is_empty() {
                None
            } else {
                Some(message.into_owned())
            }
        };
        ffi::duckdb_destroy_extracted(&mut extracted);
        ffi::duckdb_disconnect(&mut connection);
        ffi::duckdb_close(&mut database);
        if let Some(error) = error {
            return Err(ProtocolError::new(error, "sql_parse_error").into());
        }
        Ok(count as usize)
    }
}

fn validate_readonly(connection: &Connection, sql: &str) -> Result<()> {
    let parsed: String = connection.query_row(
        "SELECT CAST(system.main.json_serialize_sql(?) AS VARCHAR)",
        [sql],
        |r| r.get(0),
    )?;
    let parsed: Value = serde_json::from_str(&parsed)?;
    if parsed["error"] == true {
        return Err(
            ProtocolError::new("Expected a read-only SELECT statement", "not_read_only").into(),
        );
    }
    connection.execute_batch("BEGIN TRANSACTION READ ONLY")?;
    let result = connection.execute_batch(&format!("EXPLAIN {sql}"));
    connection.execute_batch("ROLLBACK")?;
    if let Err(error) = result {
        if error.to_string().starts_with("TransactionContext Error:")
            && error.to_string().contains("read-only mode")
        {
            return Err(ProtocolError::new(
                "Expected a read-only SELECT statement",
                "not_read_only",
            )
            .into());
        }
        return Err(error.into());
    }
    let (unsupported, writes): (bool, bool) =
        connection.query_row(READ_ONLY_PLAN, [sql], |row| Ok((row.get(0)?, row.get(1)?)))?;
    if unsupported {
        return Err(
            ProtocolError::new("Cannot inspect this statement", "unsupported_statement").into(),
        );
    }
    if writes {
        return Err(
            ProtocolError::new("Expected a read-only SELECT statement", "not_read_only").into(),
        );
    }
    Ok(())
}

fn arrow_buffer(connection: &Connection, sql: &str) -> Result<Vec<u8>> {
    let mut statement = connection.prepare(sql)?;
    let result = statement.query_arrow([])?;
    let schema = result.get_schema();
    let mut buffer = Vec::new();
    {
        let mut writer = arrow::ipc::writer::StreamWriter::try_new(&mut buffer, schema.as_ref())?;
        for batch in result {
            writer.write(&batch)?;
        }
        writer.finish()?;
    }
    Ok(buffer)
}

#[async_trait]
impl Database for ConnectionPool {
    async fn execute(&self, sql: &str) -> Result<()> {
        let result = self.get()?.execute_batch(sql).map_err(anyhow::Error::from);
        result.map_err(|error| self.failure(error))
    }
    async fn get_arrow(&self, sql: &str) -> Result<Vec<u8>> {
        {
            let connection = self.get()?;
            arrow_buffer(&connection, sql).map_err(|e| self.failure(e))
        }
    }
    async fn get_arrow_readonly(&self, sql: &str) -> Result<Vec<u8>> {
        let connection = self.get()?;
        connection.execute_batch("BEGIN TRANSACTION READ ONLY")?;
        let result = arrow_buffer(&connection, sql);
        connection.execute_batch("ROLLBACK")?;
        result.map_err(|e| self.failure(e))
    }
    async fn validate(&self, sql: &str, read_only: bool) -> Result<()> {
        if statement_count(sql)? != 1 {
            return Err(ProtocolError::new(
                "Expected exactly one SQL statement",
                "multiple_statements",
            )
            .into());
        }
        if read_only {
            {
                let connection = self.get()?;
                validate_readonly(&connection, sql).map_err(|error| self.failure(error))?;
            }
        }
        Ok(())
    }
    async fn preaggregate(&self, sql: &str) -> Result<Value> {
        let result = (|| -> Result<Value> {
            let connection = self.get()?;
            let mut tables = self
                .tables
                .lock()
                .map_err(|_| anyhow!("Preaggregate registry is unavailable"))?;
            let (catalog, digest): (String, String) = connection.query_row(
                "SELECT system.main.current_database(), system.main.sha256(?)",
                [sql],
                |r| Ok((r.get(0)?, r.get(1)?)),
            )?;
            let table = format!("preagg_{}", &digest[..32]);
            let exists:i64=connection.query_row("SELECT system.main.count(*) FROM system.information_schema.tables WHERE table_schema='mosaic' AND table_name=?",[&table],|r|r.get(0))?;
            if exists > 0 {
                if let Some(cached) = tables.get(&table) {
                    return Ok(cached.clone());
                }
            }
            connection.execute_batch("CREATE SCHEMA IF NOT EXISTS mosaic")?;
            connection
                .execute_batch(&format!("CREATE OR REPLACE TABLE mosaic.{table} AS {sql}"))?;
            let created: String = connection.query_row(
                "SELECT system.main.strftime(system.main.timezone('UTC', system.main.now()), '%Y-%m-%dT%H:%M:%S.%fZ')",
                [],
                |r| r.get(0),
            )?;
            let result = json!({"reference":{"catalog":catalog,"schema":["mosaic"],"table":table},"createdAt":created});
            tables.insert(table, result.clone());
            Ok(result)
        })();
        result.map_err(|error| self.failure(error))
    }
}
