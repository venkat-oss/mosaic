from __future__ import annotations

import hashlib
import json
from datetime import UTC, datetime
from typing import TYPE_CHECKING, Any

import duckdb
import pyarrow as pa
from duckdb import DuckDBPyConnection

from pkg.protocols import ProtocolError

if TYPE_CHECKING:
    from pathlib import Path
    from typing import Self

    from pkg.protocols import Sql


_READ_ONLY_PLAN = """WITH plan AS (SELECT system.main.json_serialize_plan(?) AS tree)
SELECT system.main.json_extract_string(tree, '$.error')::BOOLEAN AS unsupported,
EXISTS (SELECT 1 FROM system.main.json_tree(tree) WHERE
system.main.json_extract_string(value, '$.expression_class') = 'BOUND_FUNCTION'
AND system.main.json_extract_string(value, '$.qname.path[0]') = 'system'
AND system.main.json_extract_string(value, '$.qname.path[#-1]') IN ('nextval', 'setval', 'setseed', 'write_log')) AS writes
FROM plan"""


class Database:
    _con: DuckDBPyConnection | None
    path: Path | str

    def __init__(self, path: Path | str = ":memory:") -> None:
        self.path = path
        self._con = None
        self.tables: dict[str, dict[str, Any]] = {}

    def __enter__(self) -> Self:
        if self._con is not None:
            msg = f"{type(self).__name__!r} is not reentrant"
            raise TypeError(msg)

        self._con = duckdb.connect(self.path)
        return self

    @property
    def con(self) -> DuckDBPyConnection:
        con = self._con
        if con is None:
            msg = f"{type(self).__name__!r} connection should not be None"
            raise TypeError(msg)
        return con

    def __exit__(self, *excinfo: object) -> None:
        con = self._con
        if con is None:
            msg = f"{type(self).__name__!r} connection should not be None"
            raise TypeError(msg)
        con.close()
        self._con = None

    def execute(self, sql: Sql) -> None:
        self.con.execute(sql)

    def get_arrow(self, sql: Sql) -> pa.Buffer:
        relation = self.con.sql(sql)
        if relation is None:
            msg = "Statement does not return a table"
            raise ProtocolError(msg, "unsupported_statement")
        reader = relation.to_arrow_reader()
        if reader is None:
            msg = "Statement does not return a table"
            raise ProtocolError(msg, "unsupported_statement")
        sink = pa.BufferOutputStream()
        with pa.ipc.new_stream(sink, reader.schema) as writer:
            for batch in reader:
                writer.write_batch(batch)
        return sink.getvalue()

    def validate(self, sql: Sql, read_only: bool) -> None:
        statements = self.con.extract_statements(sql)
        if len(statements) != 1:
            msg = "Expected exactly one SQL statement"
            raise ProtocolError(msg, "multiple_statements")
        if not read_only:
            return
        parsed = json.loads(
            self.con.execute(
                "SELECT system.main.json_serialize_sql(?)", [sql]
            ).fetchall()[0][0]
        )
        if parsed["error"]:
            msg = "Expected a read-only SELECT statement"
            raise ProtocolError(msg, "not_read_only")
        self.con.execute("BEGIN TRANSACTION READ ONLY")
        try:
            self.con.execute(f"EXPLAIN {sql}")
        except duckdb.TransactionException as err:
            if "read-only mode" in str(err):
                msg = "Expected a read-only SELECT statement"
                raise ProtocolError(msg, "not_read_only") from err
            raise
        finally:
            self.con.execute("ROLLBACK")
        unsupported, writes = self.con.execute(_READ_ONLY_PLAN, [sql]).fetchall()[0]
        if unsupported:
            msg = "Cannot inspect this statement"
            raise ProtocolError(msg, "unsupported_statement")
        if writes:
            msg = "Expected a read-only SELECT statement"
            raise ProtocolError(msg, "not_read_only")

    def preaggregate(self, sql: Sql) -> dict[str, Any]:
        table = "preagg_" + hashlib.sha256(sql.encode()).hexdigest()[:32]
        exists = self.con.execute(
            "SELECT system.main.count(*) FROM system.information_schema.tables WHERE table_schema = 'mosaic' AND table_name = ?",
            [table],
        ).fetchall()[0][0]
        if table in self.tables and exists:
            return self.tables[table]
        self.con.execute("CREATE SCHEMA IF NOT EXISTS mosaic")
        self.con.execute(f"CREATE OR REPLACE TABLE mosaic.{table} AS {sql}")
        result = {
            "reference": {
                "catalog": self.con.execute(
                    "SELECT system.main.current_database()"
                ).fetchall()[0][0],
                "schema": ["mosaic"],
                "table": table,
            },
            "createdAt": datetime.now(UTC).isoformat().replace("+00:00", "Z"),
        }
        self.tables[table] = result
        return result

    def failure(self, err: Exception) -> ProtocolError:
        message = str(err)
        for table, result in self.tables.items():
            if message.startswith(
                f"Catalog Error: Table with name {table} does not exist"
            ):
                return ProtocolError(
                    message,
                    "materialization_missing",
                    code="table_not_found",
                    status=404,
                    reference=result["reference"],
                )
        if isinstance(err, duckdb.ParserException):
            return ProtocolError(message, "sql_parse_error")
        if isinstance(err, duckdb.TransactionException) and "read-only mode" in message:
            return ProtocolError(message, "not_read_only")
        if isinstance(err, duckdb.OutOfMemoryException):
            return ProtocolError(
                message,
                "resource_limit_exceeded",
                code="resource_exhausted",
                status=429,
            )
        return ProtocolError(
            message, "execution_failed", code="internal_error", status=500
        )
