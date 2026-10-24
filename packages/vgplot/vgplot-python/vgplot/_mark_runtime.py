from __future__ import annotations

from typing import TYPE_CHECKING, Any

if TYPE_CHECKING:
    from collections.abc import Sequence

    from ._types import MarkData
    from .plot import Directive, Mark


def mark_from_arguments(name: str, args: dict[str, Any]) -> Mark:
    from ._types import UNSET
    from .plot import Mark

    args = dict(args)
    data = args.pop("data")
    options = args.pop("options")
    enc = {k: v for k, v in args.items() if v is not UNSET}
    enc.update(options)
    return Mark(name, data=data, enc=enc or None)


def mark(name: str, data: MarkData, enc: dict[str, Any]) -> Mark:
    from .plot import Mark

    return Mark(name, data=data, enc=enc)


def directive(key: str, value: Any) -> Directive:
    from .plot import Directive

    return Directive(key, value)


def channels(kwargs: dict[str, str]) -> dict[str, str]:
    return dict(kwargs)


def bind_annotations(
    namespace: dict[str, Any], target: dict[str, Any], names: Sequence[str]
) -> None:
    for name in names:
        target[name] = namespace[name]
