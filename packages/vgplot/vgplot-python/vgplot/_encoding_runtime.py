from __future__ import annotations

from typing import Any

from ._types import UNSET


def transform(
    name: str, args: tuple[Any, ...], options: dict[str, Any]
) -> dict[str, Any]:
    vals = [a for a in args if a is not UNSET]
    value: Any = vals[0] if len(vals) == 1 else vals or ""
    return {name: value, **options}


def expression(key: str, expr: str) -> dict[str, Any]:
    return {key: expr}
