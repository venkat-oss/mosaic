from __future__ import annotations

import importlib
import inspect
import pickle

import pytest
import vgplot as vg


@pytest.mark.parametrize(
    ("name", "wire", "arguments"),
    [
        ("pan", "pan", ["x", "y", "xfield", "yfield"]),
        ("pan_x", "panX", ["x", "xfield"]),
        ("pan_y", "panY", ["y", "yfield"]),
        ("pan_zoom", "panZoom", ["x", "y", "xfield", "yfield"]),
        ("pan_zoom_x", "panZoomX", ["x", "xfield"]),
        ("pan_zoom_y", "panZoomY", ["y", "yfield"]),
    ],
)
def test_navigation_signature_omission_and_public_identity(
    name: str, wire: str, arguments: list[str]
) -> None:
    factory = getattr(vg, name)
    assert factory is getattr(importlib.import_module("vgplot.plot"), name)
    assert factory is getattr(
        importlib.import_module("vgplot._generated.interactors"), name
    )
    assert factory is getattr(
        importlib.import_module("vgplot._generated.navigation_interactors"), name
    )
    signature = inspect.signature(factory)
    assert list(signature.parameters) == arguments
    assert all(
        p.default is None and p.annotation == "Any"
        for p in signature.parameters.values()
    )
    assert signature.return_annotation == "dict[str, Any]"
    assert factory.__doc__ is None
    assert factory.__module__ == "vgplot.plot"
    assert pickle.loads(pickle.dumps(factory)) is factory  # ruff: ignore[suspicious-pickle-usage]
    assert factory() == factory(**dict.fromkeys(arguments)) == {"select": wire}
    with pytest.raises(TypeError, match="unexpected keyword argument 'zoom'"):
        factory(zoom=True)


def test_navigation_retains_selection_identity_and_false_values() -> None:
    x = vg.selection.intersect()
    y = vg.selection.intersect()
    directive = vg.pan_zoom(x, y, "a", "b")
    assert directive["x"] is x
    assert directive["y"] is y
    view = vg.spec(params={"x": x, "y": y}, view=vg.plot(directive))
    assert view.to_dict()["plot"] == [
        {"select": "panZoom", "x": "$x", "y": "$y", "xfield": "a", "yfield": "b"}
    ]
    assert vg.pan(False, 0, "", None) == {
        "select": "pan",
        "x": False,
        "y": 0,
        "xfield": "",
    }
    assert vg.pan_x("$x", "a") == {"select": "panX", "x": "$x", "xfield": "a"}
