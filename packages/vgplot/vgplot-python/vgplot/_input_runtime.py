from __future__ import annotations

from typing import TYPE_CHECKING, Any

from .util import camelize

if TYPE_CHECKING:
    from .spec import View

_MISSING = object()


def input_view(kind: str, opts: dict[str, Any], aliases: dict[str, str]) -> View:
    from .spec import View

    payload: dict[str, Any] = {"input": kind}
    for k, v in opts.items():
        if v is None:
            continue
        key = aliases.get(k, camelize(k))
        if (
            key == "options"
            and isinstance(v, list)
            and any(isinstance(i, dict) for i in v)
        ):
            v = [{"label": i, "value": i} if not isinstance(i, dict) else i for i in v]
        payload[key] = v
    return View(payload)
