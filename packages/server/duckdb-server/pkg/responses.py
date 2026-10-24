from __future__ import annotations

from typing import TYPE_CHECKING, Any, NewType

import starlette.responses

from pkg.serde import serialize_json

if TYPE_CHECKING:
    from collections.abc import Mapping


class NoStoreResponse(starlette.responses.Response):
    def init_headers(self, headers: Mapping[str, str] | None = None) -> None:
        super().init_headers({"Cache-Control": "no-store", **(headers or {})})


class JSONResponse(starlette.responses.JSONResponse, NoStoreResponse):
    def render(self, content: Any) -> bytes:
        return serialize_json(content)


class ArrowResponse(NoStoreResponse):
    media_type = "application/vnd.apache.arrow.stream"


EmptyResponse = NewType("EmptyResponse", starlette.responses.Response)


def empty_response() -> EmptyResponse:
    return EmptyResponse(NoStoreResponse())
