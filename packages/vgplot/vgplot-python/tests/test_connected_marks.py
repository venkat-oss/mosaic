from __future__ import annotations

import importlib
import inspect
import pickle
import subprocess
import sys

import pytest
import vgplot as vg
from vgplot._generated import connected_marks
from vgplot._types import UNSET
from vgplot.plot import Mark


@pytest.mark.parametrize(
    ("name", "wire"),
    [
        ("area", "area"),
        ("area_x", "areaX"),
        ("area_y", "areaY"),
        ("line", "line"),
        ("line_x", "lineX"),
        ("line_y", "lineY"),
        ("arrow", "arrow"),
        ("link", "link"),
    ],
)
def test_connected_factory_keeps_explicit_null_and_keyword_precedence(
    name: str, wire: str
) -> None:
    factory = getattr(connected_marks, name)
    mark = factory("records", x=None, stroke_width=1, strokeWidth=2, title=UNSET)
    assert isinstance(mark, Mark)
    assert mark.to_dict() == {
        "mark": wire,
        "data": {"from": "records"},
        "x": None,
        "strokeWidth": 2,
    }
    assert factory.__module__ == "vgplot._generated.marks"
    parameters = inspect.signature(factory).parameters
    assert parameters["data"].default is None
    assert parameters["options"].kind == inspect.Parameter.VAR_KEYWORD
    assert all(
        value.kind == inspect.Parameter.KEYWORD_ONLY and value.default is UNSET
        for key, value in parameters.items()
        if key not in {"data", "options"}
    )


@pytest.mark.parametrize("data", [None, []])
def test_connected_optional_data_preserves_none_and_empty_array(
    data: list[object] | None,
) -> None:
    result = connected_marks.line(data, x="x", y="y").to_dict()
    assert ("data" in result) is (data is not None)
    if data is not None:
        assert result["data"] == []


def test_connected_parameters_keep_global_identity() -> None:
    value = vg.param([2, 4, 1])
    mark = connected_marks.line_y("records", y=value)
    assert mark.enc is not None
    assert mark.enc["y"] is value
    assert mark.to_dict(param_names={id(value): "values"})["y"] == "$values"


def test_connected_endpoint_signatures_preserve_aliases() -> None:
    for name in ["arrow", "link"]:
        parameters = inspect.signature(getattr(connected_marks, name)).parameters
        assert {"x", "x1", "x2", "y", "y1", "y2"} <= parameters.keys()
    assert "y1" not in inspect.signature(connected_marks.area_x).parameters
    assert "x1" not in inspect.signature(connected_marks.area_y).parameters


@pytest.mark.parametrize("name", connected_marks.__all__)
def test_connected_public_facade_and_pickle_identity(name: str) -> None:
    facade = importlib.import_module("vgplot._generated.marks")
    factory = getattr(connected_marks, name)
    assert getattr(vg, name) is getattr(facade, name) is factory
    assert pickle.loads(pickle.dumps(factory)) is factory  # ruff: ignore[suspicious-pickle-usage]


@pytest.mark.parametrize(
    "first",
    [
        "vgplot",
        "vgplot._generated.marks",
        "vgplot._generated.connected_marks",
    ],
)
def test_connected_cold_import_identity(first: str) -> None:
    code = (
        f"import importlib,pickle;importlib.import_module({first!r});"
        "import vgplot;from vgplot._generated import marks,connected_marks;"
        "assert all(getattr(vgplot,n) is getattr(marks,n) "
        "is getattr(connected_marks,n) and "
        "pickle.loads(pickle.dumps(getattr(vgplot,n))) is getattr(vgplot,n) "
        "for n in connected_marks.__all__)"
    )
    subprocess.run(  # ruff: ignore[subprocess-without-shell-equals-true]
        [sys.executable, "-c", code], check=True
    )
