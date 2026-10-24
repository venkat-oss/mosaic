from __future__ import annotations

import datetime as dt
import decimal
import http.client
import json
import os
import socket
import tempfile
import time
import unittest
from pathlib import Path
from typing import Any
from urllib.parse import urlencode

import bench
import pyarrow as pa


def quote_identifier(value: str) -> str:
    return '"' + value.replace('"', '""') + '"'


class ServerProtocolTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.contract = json.loads(
            bench.runfile(os.environ["MOSAIC_PROTOCOL_CONTRACT"]).read_text()
        )
        cls.directory = tempfile.TemporaryDirectory(prefix="mosaic-protocol-")
        cls.addClassCleanup(cls.directory.cleanup)
        with socket.socket() as listener:
            listener.bind(("127.0.0.1", 0))
            cls.port = listener.getsockname()[1]
        cls.server = os.environ["MOSAIC_PROTOCOL_SERVER"]
        cls.process = bench.start_server(cls.server, cls.port, Path(cls.directory.name))
        cls.addClassCleanup(bench.stop_server, cls.process)
        if not bench.wait_for_server(cls.server, "127.0.0.1", cls.port, cls.process):
            msg = f"{cls.server} failed to start"
            raise RuntimeError(msg)

    def request(
        self,
        payload: Any = None,
        *,
        method: str = "POST",
        raw: bytes | None = None,
        headers: dict[str, str] | None = None,
    ) -> tuple[int, dict[str, str], bytes]:
        path = "/"
        body = raw
        request_headers = {"Origin": "http://example.test"}
        if method == "GET":
            path += "?" + urlencode(payload or {})
        elif body is None and payload is not None:
            body = json.dumps(payload).encode()
        if method == "POST":
            request_headers["Content-Type"] = "application/json; charset=utf-8"
        request_headers.update(headers or {})
        connection = http.client.HTTPConnection("127.0.0.1", self.port, timeout=30)
        try:
            connection.request(method, path, body, request_headers)
            response = connection.getresponse()
            return (
                response.status,
                {name.lower(): value for name, value in response.getheaders()},
                response.read(),
            )
        finally:
            connection.close()

    def error(
        self,
        payload: Any = None,
        *,
        reason: str,
        code: str = "bad_request",
        status: int = 400,
        field: str | None = None,
        **options: Any,
    ) -> dict[str, Any]:
        actual, headers, body = self.request(payload, **options)
        self.assertEqual(actual, status, body)
        self.assertTrue(headers.get("content-type", "").startswith("application/json"))
        self.assertIn(
            headers.get("access-control-allow-origin"), ["*", "http://example.test"]
        )
        result = json.loads(body)
        self.assertIsInstance(result.get("error"), str)
        self.assertTrue(result["error"])
        self.assertEqual(result.get("code"), code, result)
        self.assertEqual(result.get("reason"), reason, result)
        if field is not None:
            self.assertEqual(result.get("field"), field, result)
        else:
            self.assertNotIn("field", result)
        if code != "table_not_found":
            self.assertNotIn("reference", result)
        if code != "resource_exhausted":
            self.assertNotIn("retryAfterMs", result)
        self.assertFalse(set(result) & {"catalog", "schema", "table"})
        return result

    def arrow(self, sql: str, **options: Any) -> pa.Table:
        status, headers, body = self.request({"type": "arrow", "sql": sql}, **options)
        self.assertEqual(status, 200, body)
        self.assertEqual(
            headers.get("content-type", "").split(";")[0],
            self.contract["arrowMediaType"],
        )
        self.assertEqual(body[-8:], b"\xff\xff\xff\xff\x00\x00\x00\x00")
        return pa.ipc.open_stream(body).read_all()

    def execute(self, sql: str) -> None:
        status, _, body = self.request({"type": "exec", "sql": sql})
        self.assertEqual(status, 200, body)
        self.assertEqual(body, b"")

    def preagg(self, sql: str) -> dict[str, Any]:
        status, headers, body = self.request({"type": "preagg", "sql": sql})
        self.assertEqual(status, 200, body)
        self.assertTrue(headers.get("content-type", "").startswith("application/json"))
        value = json.loads(body)
        self.assertEqual(
            set(value) - {"reference", "createdAt", "rows", "bytes"}, set()
        )
        reference = value["reference"]
        self.assertEqual(set(reference), {"catalog", "schema", "table"})
        self.assertIsInstance(reference["schema"], list)
        self.assertTrue(reference["schema"])
        for component in [
            reference["catalog"],
            *reference["schema"],
            reference["table"],
        ]:
            self.assertIsInstance(component, str)
            self.assertTrue(component)
        self.assertIsNotNone(dt.datetime.fromisoformat(value["createdAt"]).utcoffset())
        return value

    def test_invalid_requests(self) -> None:
        for case in self.contract["invalidRequests"]:
            with self.subTest(case=case):
                self.error(case["body"], reason=case["reason"], field=case["field"])
        for raw in [b'{"type":', b"[]", b"null", b"true", b"42", b'"text"']:
            with self.subTest(raw=raw):
                self.error(raw=raw, reason="malformed_json")

    def test_application_fields_and_charset(self) -> None:
        status, _, body = self.request(
            {
                "type": "arrow",
                "sql": "SELECT 1 AS x",
                "TYPE": "exec",
                "Sql": "SELECT 2 AS y",
                "context": {"tenant": "test", "tags": ["a", "b"]},
            }
        )
        self.assertEqual(status, 200, body)
        self.assertEqual(pa.ipc.open_stream(body).read_all().to_pylist(), [{"x": 1}])
        status, _, body = self.request(
            raw=b'{"type":"arrow","sql":"SELECT 1 AS x","metadata":{"large":1e400}}'
        )
        self.assertEqual(status, 200, body)
        self.assertEqual(pa.ipc.open_stream(body).read_all().to_pylist(), [{"x": 1}])

    def test_methods_and_cors(self) -> None:
        status, headers, body = self.request(
            method="OPTIONS",
            headers={
                "Access-Control-Request-Method": "POST",
                "Access-Control-Request-Headers": "content-type",
            },
        )
        self.assertIn(status, [200, 204])
        self.assertEqual(body, b"")
        self.assertIn(
            headers.get("access-control-allow-origin"), ["*", "http://example.test"]
        )
        self.assertIn("POST", headers.get("access-control-allow-methods", ""))
        self.assertIn(
            "content-type", headers.get("access-control-allow-headers", "").lower()
        )
        status, headers, body = self.request(method="PUT")
        self.assertEqual(status, 405, body)
        for method in self.contract["methods"]:
            self.assertIn(method, headers.get("allow", ""))
        self.error(method="PUT", reason="method_not_allowed", status=405)

    def test_get_and_read_only_validation(self) -> None:
        self.assertEqual(
            self.arrow(
                "WITH t(x) AS (VALUES (3)) SELECT x FROM t", method="GET"
            ).to_pylist(),
            [{"x": 3}],
        )
        self.error(
            {"query": json.dumps({"type": "arrow", "sql": "SELECT 1"})},
            method="GET",
            reason="missing_field",
            field="type",
        )
        for command in ["exec", "preagg"]:
            self.error(
                {"type": command, "sql": "SELECT 1"},
                method="GET",
                reason="invalid_field",
                field="type",
            )
        self.execute("CREATE OR REPLACE TABLE protocol_read_only AS SELECT 1 AS x")
        self.error(
            {"type": "arrow", "sql": "DELETE FROM protocol_read_only RETURNING x"},
            method="GET",
            reason="not_read_only",
        )
        self.assertEqual(
            self.arrow("SELECT * FROM protocol_read_only").to_pylist(), [{"x": 1}]
        )
        self.execute("CREATE OR REPLACE SEQUENCE protocol_sequence START 1")
        self.error(
            {"type": "arrow", "sql": "SELECT nextval('protocol_sequence')"},
            method="GET",
            reason="not_read_only",
        )
        self.assertEqual(
            self.arrow("SELECT nextval('protocol_sequence') AS n").to_pylist(),
            [{"n": 1}],
        )

    def test_statement_count_and_order(self) -> None:
        self.assertEqual(
            self.arrow("SELECT 1 AS x; -- final comment").to_pylist(), [{"x": 1}]
        )
        self.execute("CREATE OR REPLACE TABLE protocol_statements(x INTEGER)")
        for method in ["POST", "GET"]:
            self.error(
                {
                    "type": "arrow",
                    "sql": "INSERT INTO protocol_statements VALUES (99); SELECT 1",
                },
                method=method,
                reason="multiple_statements",
            )
        self.assertEqual(
            self.arrow("SELECT count(*) AS n FROM protocol_statements").to_pylist(),
            [{"n": 0}],
        )
        self.execute(
            "INSERT INTO protocol_statements VALUES (1); INSERT INTO protocol_statements VALUES (2)"
        )
        self.assertEqual(
            self.arrow("SELECT x FROM protocol_statements ORDER BY x").to_pylist(),
            [{"x": 1}, {"x": 2}],
        )
        self.error({"type": "arrow", "sql": "SELECT ("}, reason="sql_parse_error")
        self.error(
            {"type": "arrow", "sql": "SELECT * FROM protocol_missing_source"},
            code="internal_error",
            reason="execution_failed",
            status=500,
        )

    def test_get_rejects_macro_and_temporary_state_mutations(self) -> None:
        self.execute("CREATE TEMP SEQUENCE protocol_temp_sequence START 1")
        self.execute(
            "CREATE OR REPLACE MACRO protocol_mutator() AS nextval('protocol_temp_sequence')"
        )
        for sql in [
            "SELECT nextval('protocol_temp_sequence')",
            "SELECT protocol_mutator()",
            "SELECT setseed(0.5)",
        ]:
            self.error(
                {"type": "arrow", "sql": sql}, method="GET", reason="not_read_only"
            )
            self.error({"type": "preagg", "sql": sql}, reason="not_read_only")
        self.assertEqual(
            self.arrow("SELECT nextval('protocol_temp_sequence') AS n").to_pylist(),
            [{"n": 1}],
        )
        self.assertEqual(
            self.arrow(
                "SELECT random() BETWEEN 0 AND 1 AS valid", method="GET"
            ).to_pylist(),
            [{"valid": True}],
        )

    def test_read_only_checks_use_engine_functions(self) -> None:
        functions = [
            "json_serialize_sql",
            "json_serialize_plan",
            "json_extract_string",
            "json_tree",
        ]
        self.execute("CREATE TEMP SEQUENCE protocol_shadowed_sequence START 1")
        try:
            self.execute(
                "CREATE MACRO json_serialize_sql(q) AS '{\"error\":false}'; "
                "CREATE MACRO json_serialize_plan(q) AS '{\"error\":false}'; "
                "CREATE MACRO json_extract_string(v,p) AS ''; "
                "CREATE MACRO json_tree(v) AS TABLE SELECT '{}'::JSON AS value"
            )
            sql = "SELECT nextval('protocol_shadowed_sequence') AS n"
            self.error(
                {"type": "arrow", "sql": sql}, method="GET", reason="not_read_only"
            )
            self.error({"type": "preagg", "sql": sql}, reason="not_read_only")
            self.assertEqual(self.arrow(sql).to_pylist(), [{"n": 1}])
        finally:
            for function in functions:
                self.execute("DROP MACRO IF EXISTS " + function)
            self.execute("DROP SEQUENCE protocol_shadowed_sequence")

    def test_error_messages_preserve_execution_classification(self) -> None:
        for command in ["arrow", "exec"]:
            for message in ["Parser Error", "read-only mode", "Out of Memory Error"]:
                with self.subTest(command=command, message=message):
                    self.error(
                        {"type": command, "sql": f"SELECT error('{message}')"},
                        code="internal_error",
                        reason="execution_failed",
                        status=500,
                    )

    def test_arrow_shapes_and_types(self) -> None:
        empty = self.arrow("SELECT 1::INTEGER AS x WHERE false")
        self.assertEqual(empty.num_rows, 0)
        self.assertEqual(empty.schema, pa.schema([("x", pa.int32())]))
        values = self.arrow(
            "SELECT 1::INTEGER AS i, 2::BIGINT AS b, 1.5::DOUBLE AS d, "
            "'café' AS s, true AS t, NULL::VARCHAR AS n, "
            "12.34::DECIMAL(8,2) AS dec, DATE '2026-10-23' AS day, "
            "TIMESTAMPTZ '2026-10-23 12:34:56.123456+00' AS stamp, "
            "[1,2] AS list, {'x': 3} AS obj, from_hex('00ff') AS blob"
        ).to_pylist()
        self.assertEqual(
            values,
            [
                {
                    "i": 1,
                    "b": 2,
                    "d": 1.5,
                    "s": "café",
                    "t": True,
                    "n": None,
                    "dec": decimal.Decimal("12.34"),
                    "day": dt.date(2026, 10, 23),
                    "stamp": dt.datetime(
                        2026, 10, 23, 12, 34, 56, 123456, tzinfo=dt.timezone.utc
                    ),
                    "list": [1, 2],
                    "obj": {"x": 3},
                    "blob": b"\x00\xff",
                }
            ],
        )
        aliases = self.arrow('SELECT 1 AS x, 2 AS x, 3 AS "a""b"')
        self.assertEqual(aliases.column_names, ["x", "x", 'a"b'])
        self.assertEqual(
            [column.to_pylist() for column in aliases.columns], [[1], [2], [3]]
        )
        many = self.arrow("SELECT range::INTEGER AS i FROM range(100000)")
        self.assertEqual(many.num_rows, 100000)
        self.assertEqual(many.column("i")[99999].as_py(), 99999)

    def test_post_returning_executes_once(self) -> None:
        self.execute("CREATE OR REPLACE TABLE protocol_returning(x INTEGER)")
        self.assertEqual(
            self.arrow(
                "INSERT INTO protocol_returning VALUES (7) RETURNING x;"
            ).to_pylist(),
            [{"x": 7}],
        )
        self.assertEqual(
            self.arrow("SELECT count(*) AS n FROM protocol_returning").to_pylist(),
            [{"n": 1}],
        )

    def test_resource_errors(self) -> None:
        previous = self.arrow("SELECT current_setting('memory_limit') AS value")[
            "value"
        ][0].as_py()
        self.execute("SET memory_limit = '1MB'")
        try:
            self.error(
                {
                    "type": "arrow",
                    "sql": "SELECT range FROM range(10000000) ORDER BY hash(range)",
                },
                code="resource_exhausted",
                reason="resource_limit_exceeded",
                status=429,
            )
        finally:
            self.execute("SET memory_limit = '" + previous.replace("'", "''") + "'")

    def test_large_requests(self) -> None:
        size = self.contract["minimumRequestBytes"]
        payload = {"type": "arrow", "sql": "SELECT 1 AS x /**/"}
        padding = size - len(json.dumps(payload).encode())
        payload["sql"] = "SELECT 1 AS x /*" + "x" * padding + "*/"
        status, _, body = self.request(payload)
        self.assertEqual(status, 200, body[:500])
        self.assertEqual(pa.ipc.open_stream(body).read_all().to_pylist(), [{"x": 1}])
        self.assertEqual(
            self.arrow(payload["sql"], method="GET").to_pylist(), [{"x": 1}]
        )

    def test_preaggregation_lifecycle(self) -> None:
        source = "SELECT range::INTEGER AS x FROM range(3)"
        first = self.preagg(source)
        again = self.preagg(source)
        self.assertEqual(again["reference"], first["reference"])
        self.assertEqual(again["createdAt"], first["createdAt"])
        ref = first["reference"]
        name = ".".join(
            quote_identifier(value)
            for value in [ref["catalog"], *ref["schema"], ref["table"]]
        )
        self.assertEqual(
            self.arrow("SELECT x FROM " + name + " ORDER BY x").to_pylist(),
            [{"x": 0}, {"x": 1}, {"x": 2}],
        )
        self.execute("DROP TABLE " + name)
        for command in ["arrow", "exec", "preagg"]:
            missing = self.error(
                {"type": command, "sql": "SELECT * FROM " + name},
                code="table_not_found",
                reason="materialization_missing",
                status=404,
            )
            self.assertEqual(missing.get("reference"), ref)
        self.error(
            {
                "type": "arrow",
                "sql": f"SELECT missing({quote_identifier(ref['table'])})",
            },
            code="internal_error",
            reason="execution_failed",
            status=500,
        )
        time.sleep(0.01)
        rebuilt = self.preagg(source)
        self.assertEqual(rebuilt["reference"], ref)
        self.assertNotEqual(rebuilt["createdAt"], first["createdAt"])
        for sql in [
            "DELETE FROM " + name + " RETURNING *",
            "CREATE TABLE protocol_bad_preagg(x INTEGER)",
        ]:
            self.error({"type": "preagg", "sql": sql}, reason="not_read_only")
        self.assertEqual(
            self.arrow("SELECT count(*) AS n FROM " + name).to_pylist(), [{"n": 3}]
        )


if __name__ == "__main__":
    unittest.main()
