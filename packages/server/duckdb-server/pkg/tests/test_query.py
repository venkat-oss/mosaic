from __future__ import annotations

from typing import TYPE_CHECKING, Any
from typing import Literal as L  # ruff: ignore[camelcase-imported-as-acronym]

import httpx2
import msgspec
import pyarrow as pa
from httpx2 import RequestError

if TYPE_CHECKING:
    from typing import LiteralString

    from starlette.testclient import TestClient
    from typing_extensions import TypedDict

    class QueryParams(TypedDict, closed=True):
        query: LiteralString


def q(sql: LiteralString, /, type: L["arrow", "exec"] = "arrow") -> dict[str, str]:
    return {"type": type, "sql": sql}


def raise_for_status(response: httpx2.Response) -> httpx2.Response:
    if response.is_success:
        return response
    body = msgspec.json.decode(response.content, type=dict[str, Any])
    message = (
        f"'{response.status_code} {response.reason_phrase}' for url '{response.url}'\n    {body!r}\n"
        f"For more information check: https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/{response.status_code}"
    )
    raise RequestError(message)


def test_query_arrow(client_session: TestClient) -> None:
    response = client_session.get("/", params=q("SELECT 1 AS a"))
    raise_for_status(response)
    content = response.read()
    with pa.ipc.open_stream(content) as reader:
        table = reader.read_all()
    expected = pa.table({"a": [1]}, schema=pa.schema({"a": pa.int32()}))
    assert table.equals(expected)


def test_query_flat_parameters(client_session: TestClient) -> None:
    response = client_session.get(
        "/", params={"type": "arrow", "sql": "SELECT 'a & b \"c\"' AS a"}
    )
    raise_for_status(response)
    with pa.ipc.open_stream(response.content) as reader:
        assert reader.read_all().to_pylist() == [{"a": 'a & b "c"'}]


def test_large_application_number(client_session: TestClient) -> None:
    response = client_session.post(
        "/",
        content=b'{"type":"arrow","sql":"SELECT 1 AS x","application":{"number":1e400}}',
        headers={"Content-Type": "application/json"},
    )
    raise_for_status(response)
    with pa.ipc.open_stream(response.content) as reader:
        assert reader.read_all().to_pylist() == [{"x": 1}]


def test_large_protocol_number_is_invalid(client_session: TestClient) -> None:
    response = client_session.post(
        "/",
        content=b'{"type":"arrow","sql":1e400}',
        headers={"Content-Type": "application/json"},
    )
    assert response.status_code == 400
    assert response.json()["reason"] == "invalid_field"
    assert response.json()["field"] == "sql"
