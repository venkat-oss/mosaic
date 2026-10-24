from __future__ import annotations

import inspect
import pickle

import pytest
import vgplot as vg
from vgplot._generated import basic_marks, marks

CASES = [
    ("barX", "bar_x"),
    ("barY", "bar_y"),
    ("cell", "cell"),
    ("cellX", "cell_x"),
    ("cellY", "cell_y"),
    ("rect", "rect"),
    ("rectX", "rect_x"),
    ("rectY", "rect_y"),
    ("dot", "dot"),
    ("dotX", "dot_x"),
    ("dotY", "dot_y"),
    ("circle", "circle"),
    ("hexagon", "hexagon"),
    ("ruleX", "rule_x"),
    ("ruleY", "rule_y"),
    ("tickX", "tick_x"),
    ("tickY", "tick_y"),
]


@pytest.mark.parametrize(("wire", "name"), CASES)
def test_owned_basic_mark_factories_preserve_public_identity_and_serialization(
    wire: str,
    name: str,
) -> None:
    factory = getattr(vg, name)
    assert factory is getattr(marks, name) is getattr(basic_marks, name)
    assert factory.__module__ == "vgplot._generated.marks"
    assert pickle.loads(pickle.dumps(factory)) is factory  # ruff: ignore[suspicious-pickle-usage]
    assert inspect.signature(factory).parameters["data"].default is None
    assert vg.plot(factory(None, x=1, fill=None)).to_dict() == {
        "plot": [{"mark": wire, "x": 1, "fill": None}],
    }
    assert vg.plot(factory([{"t": 1}], stroke_width=1, strokeWidth=2)).to_dict() == {
        "plot": [{"mark": wire, "data": [{"t": 1}], "strokeWidth": 2}],
    }


def test_rule_y_and_forced_geometry_keep_their_declared_option_boundaries() -> None:
    rule = inspect.signature(vg.rule_y).parameters
    assert all(name in rule for name in ["y1", "y2", "inset_top", "inset_bottom"])
    assert all(name not in rule for name in ["x1", "x2", "inset_left", "inset_right"])
    for factory in [vg.circle, vg.hexagon]:
        assert "symbol" in inspect.signature(factory).parameters
        assert factory(None, symbol="square").to_dict()["symbol"] == "square"


def test_named_interval_parameter_serializes_through_the_public_factory() -> None:
    interval = vg.param("day")
    spec = vg.Spec(
        params={"dayInterval": interval},
        view=vg.plot(vg.bar_x("records", x="date", interval=interval)),
    ).to_dict()
    assert spec == {
        "params": {"dayInterval": "day"},
        "plot": [
            {
                "mark": "barX",
                "data": {"from": "records"},
                "x": "date",
                "interval": "$dayInterval",
            }
        ],
    }
