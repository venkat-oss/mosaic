from __future__ import annotations

from dataclasses import dataclass
from typing import Any

import narwhals as nw


@dataclass
class DataDef:
    payload: dict[str, Any]

    def to_dict(self) -> dict[str, Any]:
        return self.payload


def is_frame(obj: Any) -> bool:
    """True if `obj` is a dataframe-like object (pandas/polars/Arrow/...)."""
    if obj is None or isinstance(
        obj, (str, bytes, int, float, bool, dict, list, tuple)
    ):
        return False
    try:
        nw.from_native(obj)
    except TypeError:
        return False
    return True


def named_data(named_defs: dict[str, DataDef]) -> dict[str, Any]:
    out: dict[str, Any] = {}
    for k, v in named_defs.items():
        out[k] = v.to_dict() if hasattr(v, "to_dict") else v
    return out
