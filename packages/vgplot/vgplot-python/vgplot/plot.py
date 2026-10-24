from __future__ import annotations

from collections.abc import Mapping
from dataclasses import dataclass
from typing import TYPE_CHECKING, Any

from . import (
    _input_api,
    _mark_api,
    _mark_runtime,
    _source_api,
    _source_runtime,
    _table_api,
)
from ._generated import layouts as _layouts
from ._generated import plot_attributes as _plot_attributes
from ._generated.interactors import *  # noqa: F403
from ._mark_contracts import DATA_OPTIONS as _DATA_OPTIONS
from .data import DataDef, is_frame
from .params import _ParamBase
from .util import camelize

if TYPE_CHECKING:
    from vgplot._types import MarkData
    from vgplot.spec import View


input = _input_api.input
option = _input_api.option
slider = _input_api.slider
select = _input_api.select
checkbox = _input_api.checkbox
menu = _input_api.menu
search = _input_api.search
table_input = _table_api.table_input
FromRef = _source_runtime.FromRef
source = _source_api.source
hconcat = _layouts.hconcat
hspace = _layouts.hspace
vconcat = _layouts.vconcat
vspace = _layouts.vspace
margins = _plot_attributes.margins


@dataclass
class Directive:
    key: str
    value: Any

    def to_kv(self) -> tuple[str, Any]:
        return camelize(self.key), self.value


@dataclass
class Mark:
    mark: str
    data: MarkData = None
    enc: dict[str, Any] | None = None

    def to_dict(self, param_names: dict[int, str] | None = None) -> dict[str, Any]:
        payload: dict[str, Any] = {"mark": self.mark}
        enc = dict(self.enc or {})
        data_opts = {
            out: enc.pop(key) for key, out in _DATA_OPTIONS.items() if key in enc
        }
        if self.data is not None:
            if isinstance(self.data, (str, _ParamBase)):
                data_dict: Any = {"from": self.data}
            elif isinstance(self.data, FromRef):
                data_dict = dict(self.data.to_dict())
            elif isinstance(self.data, DataDef) or is_frame(self.data):
                data_dict = {"from": self.data}
            else:
                data_dict = self.data
            if data_opts and isinstance(data_dict, dict):
                data_dict = {**data_dict, **data_opts}
                data_opts = {}
            payload["data"] = encode_value(data_dict, param_names)
        for key, val in data_opts.items():
            payload[key] = encode_value(val, param_names)
        for k, v in enc.items():
            payload[camelize(k)] = encode_value(v, param_names)
        return payload


def encode_value(
    v: Any,
    param_names: dict[int, str] | None = None,
    data_names: dict[int, str] | None = None,
) -> Any:
    if isinstance(v, DataDef):
        if data_names and id(v) in data_names:
            return data_names[id(v)]
        return v
    if isinstance(v, _ParamBase):
        # Resolve to "$name" ref using the reverse lookup table
        if param_names and id(v) in param_names:
            return f"${param_names[id(v)]}"
        return v
    if isinstance(v, FromRef):
        return v.to_dict()
    if isinstance(v, Mark):
        return v.to_dict(param_names)
    if isinstance(v, list):
        return [encode_value(x, param_names, data_names) for x in v]
    if isinstance(v, dict):
        return {k: encode_value(val, param_names, data_names) for k, val in v.items()}
    if is_frame(v):
        if data_names and id(v) in data_names:
            return data_names[id(v)]
        return v
    return v


def plot(
    *items: Mark | Directive | Mapping[str, Any],
    param_names: dict[int, str] | None = None,
    **kwargs: Any,
) -> View:
    from .spec import View

    marks: list[dict[str, Any]] = []
    directives: dict[str, Any] = {}
    for item in items:
        if isinstance(item, Mark):
            marks.append(item.to_dict(param_names))
        elif isinstance(item, Directive):
            k, v = item.to_kv()
            directives[k] = encode_value(v, param_names)
        elif isinstance(item, (dict, Mapping)):
            marks.append({k: encode_value(v, param_names) for k, v in item.items()})
        else:
            msg = f"Unsupported plot item: {item}"
            raise TypeError(msg)
    root: dict[str, Any] = {"plot": marks}
    root.update(directives)
    return View(root, **kwargs)


_mark_runtime.bind_annotations(globals(), vars(_mark_api), _mark_api._RETURN_TYPES)
directive = _mark_api.directive
mark = _mark_api.mark


def _encode_component(
    item: Any,
    param_names: dict[int, str] | None,
    data_names: dict[int, str] | None = None,
) -> Any:
    from .spec import View

    if isinstance(item, View):
        item = item._view
    if isinstance(item, dict) and "plot" in item:
        # re-encode an already-built plot dict so param refs resolve
        marks = [
            (
                {k: encode_value(v, param_names, data_names) for k, v in m.items()}
                if isinstance(m, dict)
                else m
            )
            for m in item["plot"]
        ]
        rest = {
            k: encode_value(v, param_names, data_names)
            for k, v in item.items()
            if k != "plot"
        }
        return {"plot": marks, **rest}
    return encode_value(item, param_names, data_names)
