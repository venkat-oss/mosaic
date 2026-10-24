from __future__ import annotations

import logging
from contextlib import asynccontextmanager
from io import BytesIO
from typing import TYPE_CHECKING, Any, TypedDict

import duckdb
import msgspec
from starlette.applications import Starlette
from starlette.endpoints import HTTPEndpoint
from starlette.middleware import Middleware
from starlette.middleware.cors import CORSMiddleware
from starlette.routing import Route

from pkg.commands import Command
from pkg.db import Database
from pkg.errors import create_exception_handlers
from pkg.protocols import ProtocolError
from pkg.serde import deserialize_json

if TYPE_CHECKING:
    from collections.abc import AsyncGenerator
    from pathlib import Path

    from starlette.datastructures import Headers
    from starlette.requests import Request
    from starlette.responses import Response


_ALLOW_ALL = ("*",)
_SECONDS_24_HOURS = 86_400
logger = logging.getLogger(__name__)


class CORS(CORSMiddleware):
    def preflight_response(self, request_headers: Headers) -> Response:
        response = super().preflight_response(request_headers)
        response.body = b""
        response.headers["Content-Length"] = "0"
        response.headers["Cache-Control"] = "no-store"
        return response


class AppState(TypedDict):
    db: Database


@asynccontextmanager
async def lifespan(app: Starlette) -> AsyncGenerator[AppState, None]:
    db_path = app.state.db_path
    with Database(db_path) as db:
        logger.info("Connected to DuckDB %s", db_path)
        yield {"db": db}
    logger.info("Closed DuckDB %s", db_path)


# TODO @dangotbanned: Slow query logging
# start: `query.run_command`
# end  : after the `Response` is served
# - not sure how to hook into that yet
class Endpoint(HTTPEndpoint):
    async def get(self, request: Request[AppState]) -> Response:
        if request.method != "GET":
            msg = "Unsupported HTTP method"
            raise ProtocolError(msg, "method_not_allowed", status=405)
        return self.run(request, dict(request.query_params), True)

    async def post(self, request: Request[AppState]) -> Response:
        media_type = (
            request.headers.get("content-type", "").split(";", 1)[0].strip().lower()
        )
        if media_type != "application/json":
            msg = "Content-Type must be application/json"
            raise ProtocolError(msg, "unsupported_media_type", status=415)
        buf = BytesIO()
        async for chunk in request.stream():
            buf.write(chunk)
            if buf.tell() > 16 * 1024 * 1024:
                msg = "Request body exceeds 16 MiB"
                raise ProtocolError(msg, "payload_too_large", status=413)
        return self.run(request, deserialize_json(buf.getbuffer()), False)

    def run(self, request: Request[AppState], value: Any, get: bool) -> Response:
        if not isinstance(value, dict):
            msg = "Expected a JSON object"
            raise ProtocolError(msg, "malformed_json")
        for field in ("type", "sql"):
            if field not in value:
                msg = f"Missing required field: {field}"
                raise ProtocolError(msg, "missing_field", field)
            if not isinstance(value[field], str) or not value[field].strip():
                msg = f"Invalid field: {field}"
                raise ProtocolError(msg, "invalid_field", field)
        if value["type"] not in ("arrow", "exec", "preagg") or (
            get and value["type"] != "arrow"
        ):
            msg = "Invalid command type"
            raise ProtocolError(msg, "invalid_field", "type")
        query = msgspec.convert(value, Command)
        db = request.state["db"]
        try:
            if value["type"] != "exec":
                db.validate(query.sql, get or value["type"] == "preagg")
            if get:
                db.con.execute("BEGIN TRANSACTION READ ONLY")
                try:
                    return query.run(db)
                finally:
                    db.con.execute("ROLLBACK")
            return query.run(db)
        except duckdb.Error as err:
            raise db.failure(err) from err

    async def options(self, request: Request[AppState]) -> Response:
        from pkg.responses import empty_response

        return empty_response()


def create_app(db_path: Path | str = ":memory:") -> Starlette:
    cors = Middleware(
        CORS,
        allow_origins=_ALLOW_ALL,
        allow_methods=("OPTIONS", "POST", "GET"),
        allow_headers=_ALLOW_ALL,
        max_age=_SECONDS_24_HOURS,
    )
    # TODO @dangotbanned: Look into compression/tracing equivalent
    middleware = (cors,)
    routes = (Route("/", Endpoint, methods=("GET", "POST", "OPTIONS")),)

    app = Starlette(
        routes=routes,
        middleware=middleware,
        exception_handlers=create_exception_handlers(),
        lifespan=lifespan,
    )
    app.state.db_path = db_path
    return app
