from __future__ import annotations

from typing import Any

from .util import camelize


class FromRef:
    def __init__(self, name: str, **opts: Any) -> None:
        self.name = name
        self.opts = {camelize(k): v for k, v in opts.items() if v is not None}

    def to_dict(self) -> dict[str, Any]:
        return {"from": self.name, **self.opts}
