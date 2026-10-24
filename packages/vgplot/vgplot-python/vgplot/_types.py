from __future__ import annotations

from vgplot._compat import sentinel

from . import _type_contracts
from ._type_contracts import *  # noqa: F403

UNSET = sentinel("UNSET")
"""Sentinel for mark channels that were not passed (distinct from None)."""

__annotations__ = _type_contracts.__annotations__
