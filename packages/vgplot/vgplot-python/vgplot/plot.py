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
from ._generated import brush_interactors as _brush_interactors
from ._generated import layouts as _layouts
from ._generated import legends as _legends
from ._generated import plot_attributes as _plot_attributes
from ._generated import point_interactors as _point_interactors
from ._mark_contracts import DATA_OPTIONS as _DATA_OPTIONS
from .data import DataDef, is_frame
from .params import _ParamBase
from .util import camelize, omit_none

if TYPE_CHECKING:
    from vgplot._types import MarkData
    from vgplot.spec import View


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


def _interactor(select: str, **opts: Any) -> dict[str, Any]:
    return omit_none({"select": select, **opts})


def pan(
    x: Any = None, y: Any = None, xfield: Any = None, yfield: Any = None
) -> dict[str, Any]:
    return _interactor("pan", x=x, y=y, xfield=xfield, yfield=yfield)


def pan_x(x: Any = None, xfield: Any = None) -> dict[str, Any]:
    return _interactor("panX", x=x, xfield=xfield)


def pan_y(y: Any = None, yfield: Any = None) -> dict[str, Any]:
    return _interactor("panY", y=y, yfield=yfield)


def pan_zoom(
    x: Any = None, y: Any = None, xfield: Any = None, yfield: Any = None
) -> dict[str, Any]:
    return _interactor("panZoom", x=x, y=y, xfield=xfield, yfield=yfield)


def pan_zoom_x(x: Any = None, xfield: Any = None) -> dict[str, Any]:
    return _interactor("panZoomX", x=x, xfield=xfield)


def pan_zoom_y(y: Any = None, yfield: Any = None) -> dict[str, Any]:
    return _interactor("panZoomY", y=y, yfield=yfield)


_INPUT_ALIASES = {"bind": "as", "source": "from"}


hconcat = _layouts.hconcat
hspace = _layouts.hspace
vconcat = _layouts.vconcat
vspace = _layouts.vspace

source = _source_api.source

FromRef = _source_runtime.FromRef

checkbox = _input_api.checkbox
input = _input_api.input
menu = _input_api.menu
option = _input_api.option
search = _input_api.search
select = _input_api.select
slider = _input_api.slider

table_input = _table_api.table_input

directive = _mark_api.directive
mark = _mark_api.mark


_mark_runtime.bind_annotations(globals(), vars(_mark_api), _mark_api._RETURN_TYPES)

color_legend = _legends.color_legend
opacity_legend = _legends.opacity_legend
symbol_legend = _legends.symbol_legend

margins = _plot_attributes.margins

highlight = _point_interactors.highlight
nearest = _point_interactors.nearest
nearest_x = _point_interactors.nearest_x
nearest_y = _point_interactors.nearest_y
toggle = _point_interactors.toggle
toggle_color = _point_interactors.toggle_color
toggle_x = _point_interactors.toggle_x
toggle_y = _point_interactors.toggle_y
toggle_z = _point_interactors.toggle_z

brush = _brush_interactors.brush
interval_x = _brush_interactors.interval_x
interval_xy = _brush_interactors.interval_xy
interval_y = _brush_interactors.interval_y
region = _brush_interactors.region
sort = _brush_interactors.sort
