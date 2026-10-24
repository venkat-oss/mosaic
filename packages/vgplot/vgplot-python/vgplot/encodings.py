from __future__ import annotations

import typing as _typing

from . import _expression_contracts


def channels(**kwargs: str) -> dict[str, str]:
    return dict(kwargs)


sql = _expression_contracts.sql

Any = _typing.Any
