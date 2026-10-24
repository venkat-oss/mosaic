from __future__ import annotations

from http import HTTPStatus
from typing import TYPE_CHECKING

import pytest

if TYPE_CHECKING:
    from starlette.testclient import TestClient


@pytest.mark.parametrize(
    ("type", "sql", "reason", "field"),
    [
        (None, "SELECT 1", "missing_field", "type"),
        ("json", "SELECT 1", "invalid_field", "type"),
        ("arrow", None, "missing_field", "sql"),
        ("exec", None, "missing_field", "sql"),
        (None, None, "missing_field", "type"),
        ("arrow", "", "invalid_field", "sql"),
    ],
)
def test_bad_request(
    client_session: TestClient,
    type: str | None,
    sql: str | None,
    reason: str,
    field: str,
) -> None:
    params = {
        key: value for key, value in (("type", type), ("sql", sql)) if value is not None
    }
    response = client_session.get("/", params=params)
    assert response.status_code == HTTPStatus.BAD_REQUEST
    body = response.json()
    assert body["code"] == "bad_request"
    assert body["reason"] == reason
    assert body["field"] == field


def test_legacy_query_parameter_rejected(client_session: TestClient) -> None:
    response = client_session.get(
        "/", params={"query": '{"type":"arrow","sql":"SELECT 1"}'}
    )
    assert response.status_code == HTTPStatus.BAD_REQUEST
    assert response.json()["field"] == "type"


def test_method_not_allowed(client_session: TestClient) -> None:
    response = client_session.delete("/")
    assert response.status_code == HTTPStatus.METHOD_NOT_ALLOWED
    assert response.json()["reason"] == "method_not_allowed"
    assert response.headers["allow"] == "GET, POST, OPTIONS"
