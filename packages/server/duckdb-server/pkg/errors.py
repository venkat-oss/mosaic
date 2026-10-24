from __future__ import annotations

from http import HTTPStatus
from typing import TYPE_CHECKING, Any

from msgspec import DecodeError
from starlette.exceptions import HTTPException

from pkg.protocols import ProtocolError
from pkg.responses import JSONResponse

if TYPE_CHECKING:
    from collections.abc import Awaitable, Callable, Mapping

    from starlette.requests import Request


async def _protocol_error(_: Request, err: Exception) -> JSONResponse:
    if isinstance(err, ProtocolError):
        body: dict[str, Any] = {
            "error": str(err),
            "code": err.code,
            "reason": err.reason,
        }
        if err.field:
            body["field"] = err.field
        if err.reference:
            body["reference"] = err.reference
        headers = (
            {"Allow": "GET, POST, OPTIONS"}
            if err.status == HTTPStatus.METHOD_NOT_ALLOWED
            else None
        )
        return JSONResponse(body, err.status, headers=headers)
    return JSONResponse(
        {"error": str(err), "code": "internal_error", "reason": "internal_failure"}, 500
    )


async def _decode_error(request: Request, err: Exception) -> JSONResponse:
    return await _protocol_error(request, ProtocolError(str(err), "malformed_json"))


async def _http_error(request: Request, err: Exception) -> JSONResponse:
    if (
        isinstance(err, HTTPException)
        and err.status_code == HTTPStatus.METHOD_NOT_ALLOWED
    ):
        return await _protocol_error(
            request, ProtocolError(str(err), "method_not_allowed", status=405)
        )
    return await _protocol_error(request, err)


def create_exception_handlers() -> Mapping[
    type[Exception], Callable[[Request, Exception], Awaitable[JSONResponse]]
]:
    return {
        ProtocolError: _protocol_error,
        DecodeError: _decode_error,
        HTTPException: _http_error,
        Exception: _protocol_error,
    }
