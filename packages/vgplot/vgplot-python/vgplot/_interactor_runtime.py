from __future__ import annotations

from typing import Any

from .util import omit_none


def _interactor(select: str, **opts: Any) -> dict[str, Any]:
    return omit_none({"select": select, **opts})
