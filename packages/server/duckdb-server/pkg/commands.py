from __future__ import annotations

from typing import TYPE_CHECKING, Any, final

import pyarrow as pa

from pkg import protocols
from pkg.responses import ArrowResponse, EmptyResponse, JSONResponse, empty_response

if TYPE_CHECKING:
    from pkg.db import Database


@final
class ArrowRequest(protocols.Command[pa.Buffer], forbid_unknown_fields=False):
    """Returns a result table."""

    def _query(self, db: Database, /) -> pa.Buffer:
        return db.get_arrow(self.sql)

    # TODO @dangotbanned: Figure out if `pa.Buffer.__buffer__` requires 3.12
    # starlette accepts memoryview, which might remove a copy that `to_pybytes` is doing
    def _into_response(self, buffer: pa.Buffer, /) -> ArrowResponse:
        return ArrowResponse(buffer.to_pybytes())


@final
class ExecRequest(protocols.Command[None], forbid_unknown_fields=False):
    """Statements run in order on one connection."""

    def _query(self, db: Database) -> None:
        db.execute(self.sql)

    def _into_response(self, _: None, /) -> EmptyResponse:
        return empty_response()


@final
class PreaggRequest(protocols.Command[dict[str, Any]], forbid_unknown_fields=False):
    def _query(self, db: Database, /) -> dict[str, Any]:
        return db.preaggregate(self.sql)

    def _into_response(self, result: dict[str, Any], /) -> JSONResponse:
        return JSONResponse(result)


Command = ArrowRequest | ExecRequest | PreaggRequest
