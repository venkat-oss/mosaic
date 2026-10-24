from __future__ import annotations

import importlib
import inspect
import pickle
from typing import Any

import pytest
import vgplot as vg


@pytest.mark.parametrize(
    ("name", "arguments"),
    [
        ("toggle", ["bind", "channels", "peers"]),
        ("toggle_x", ["bind", "peers"]),
        ("toggle_y", ["bind", "peers"]),
        ("toggle_z", ["bind", "peers"]),
        ("toggle_color", ["bind", "peers"]),
        ("nearest", ["bind", "field", "channels"]),
        ("nearest_x", ["bind", "field", "channels"]),
        ("nearest_y", ["bind", "field", "channels"]),
        ("highlight", ["by", "channels", "kwargs"]),
    ],
)
def test_point_signatures_omission_and_public_identity(
    name: str, arguments: list[str]
) -> None:
    factory = getattr(vg, name)
    assert factory is getattr(importlib.import_module("vgplot.plot"), name)
    assert factory is getattr(
        importlib.import_module("vgplot._generated.interactors"), name
    )
    assert factory is getattr(
        importlib.import_module("vgplot._generated.point_interactors"), name
    )
    signature = inspect.signature(factory)
    assert list(signature.parameters) == arguments
    for parameter in signature.parameters.values():
        assert parameter.annotation == "Any"
        if parameter.name == "kwargs":
            assert parameter.kind is inspect.Parameter.VAR_KEYWORD
        else:
            assert parameter.default is None
    assert signature.return_annotation == "dict[str, Any]"
    assert factory.__doc__ is None
    assert factory.__module__ == "vgplot.plot"
    assert pickle.loads(pickle.dumps(factory)) is factory  # ruff: ignore[suspicious-pickle-usage]
    wire = {
        "toggle_x": "toggleX",
        "toggle_y": "toggleY",
        "toggle_z": "toggleZ",
        "toggle_color": "toggleColor",
        "nearest_x": "nearestX",
        "nearest_y": "nearestY",
    }.get(name, name)
    assert factory() == {"select": wire}
    if name != "highlight":
        with pytest.raises(TypeError, match="unexpected keyword argument 'unknown'"):
            factory(unknown=True)


def test_nearest_retains_its_historical_singular_field_and_fixed_kwargs() -> None:
    assert vg.nearest("selected", "column", ["x"]) == {
        "select": "nearest",
        "as": "selected",
        "field": "column",
        "channels": ["x"],
    }
    for factory in [vg.nearest, vg.nearest_x, vg.nearest_y]:
        target: Any = factory
        with pytest.raises(TypeError, match="unexpected keyword argument 'fields'"):
            target(fields=["x"])
        with pytest.raises(TypeError, match="unexpected keyword argument 'max_radius'"):
            target(max_radius=18)
    assert vg.toggle("selected", [], False) == {
        "select": "toggle",
        "as": "selected",
        "channels": [],
        "peers": False,
    }


def test_highlight_preserves_channels_camelized_extras_and_override_precedence() -> (
    None
):
    assert vg.highlight(
        "selected",
        {"opacity": 0.1},
        fill_opacity=0.3,
        stroke_width=None,
        custom_value=False,
    ) == {
        "select": "highlight",
        "by": "selected",
        "channels": {"opacity": 0.1},
        "fillOpacity": 0.3,
        "customValue": False,
    }
    assert vg.highlight(select="nearest", by_value="column") == {
        "select": "nearest",
        "byValue": "column",
    }
