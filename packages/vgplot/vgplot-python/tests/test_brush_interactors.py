from __future__ import annotations

import importlib
import inspect
import pickle
import subprocess
import sys

import vgplot as vg


def test_brush_interactor_contracts() -> None:
    plot = importlib.import_module("vgplot.plot")
    facade = importlib.import_module("vgplot._generated.interactors")
    family = importlib.import_module("vgplot._generated.brush_interactors")
    arguments = {
        "interval_x": ["bind", "field", "pixel_size", "peers", "brush"],
        "interval_y": ["bind", "field", "pixel_size", "peers", "brush"],
        "interval_xy": ["bind", "xfield", "yfield", "pixel_size", "peers", "brush"],
        "region": ["bind", "channels", "peers", "brush"],
    }
    for name, names in arguments.items():
        factory = getattr(vg, name)
        assert (
            factory
            is getattr(plot, name)
            is getattr(facade, name)
            is getattr(family, name)
        )
        signature = inspect.signature(factory)
        assert list(signature.parameters) == names
        assert all(
            p.default is None and p.annotation == "Any"
            for p in signature.parameters.values()
        )
        assert signature.return_annotation == "dict[str, Any]"
        assert factory.__doc__ is None
        assert factory.__module__ == "vgplot.plot"
        assert pickle.loads(pickle.dumps(factory)) is factory  # ruff: ignore[suspicious-pickle-usage]
        assert factory() == {
            "select": {
                "interval_x": "intervalX",
                "interval_y": "intervalY",
                "interval_xy": "intervalXY",
                "region": "region",
            }[name]
        }
        assert factory(**dict.fromkeys(names)) == factory()
        try:
            factory(unknown=True)
        except TypeError as error:
            assert (
                str(error) == name + "() got an unexpected keyword argument 'unknown'"
            )
        else:
            raise AssertionError(name)
    assert vg.interval_x("selected", "field", 0, False, {}) == {
        "select": "intervalX",
        "as": "selected",
        "field": "field",
        "pixelSize": 0,
        "peers": False,
        "brush": {},
    }
    assert vg.interval_xy("s", "a", "b", 8, False, {}) == {
        "select": "intervalXY",
        "as": "s",
        "xfield": "a",
        "yfield": "b",
        "pixelSize": 8,
        "peers": False,
        "brush": {},
    }
    assert vg.region("s", [], False, {}) == {
        "select": "region",
        "as": "s",
        "channels": [],
        "peers": False,
        "brush": {},
    }
    for name in ["brush", "sort"]:
        factory = getattr(vg, name)
        assert (
            factory
            is getattr(plot, name)
            is getattr(facade, name)
            is getattr(family, name)
        )
        assert (
            str(inspect.signature(factory)) == "(**kwargs: 'Any') -> 'dict[str, Any]'"
        )
        assert factory.__doc__ is None
        assert factory.__module__ == "vgplot.plot"
        assert pickle.loads(pickle.dumps(factory)) is factory  # ruff: ignore[suspicious-pickle-usage]
        assert factory() == {}
    assert vg.brush(
        fill_opacity=0,
        stroke_dasharray="",
        opacity=False,
        empty=None,
        additional_key=[],
    ) == {
        "fillOpacity": 0,
        "strokeDasharray": "",
        "opacity": False,
        "additionalKey": [],
    }
    assert vg.brush(fillOpacity=0.2, fill_opacity=0.4) == {"fillOpacity": 0.4}
    assert vg.sort(fill_opacity=0, opacity=False, extra_key="", empty=None) == {
        "fill_opacity": 0,
        "opacity": False,
        "extra_key": "",
    }
    for name in [
        "vgplot",
        "vgplot.plot",
        "vgplot._generated.interactors",
        "vgplot._generated.brush_interactors",
    ]:
        subprocess.run(  # ruff: ignore[subprocess-without-shell-equals-true]
            [
                sys.executable,
                "-c",
                "import importlib; importlib.import_module(" + repr(name) + ")",
            ],
            check=True,
        )
