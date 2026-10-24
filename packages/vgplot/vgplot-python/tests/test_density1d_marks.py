from __future__ import annotations

import inspect
import pickle

import pytest
import vgplot as vg
from vgplot._types import UNSET
from vgplot.plot import Mark


@pytest.mark.parametrize(
    ("name", "wire"),
    [
        ("density_x", "densityX"),
        ("density_y", "densityY"),
    ],
)
def test_density1d_public_factories_keep_keywords_and_pickle_identity(
    name: str, wire: str
) -> None:
    factory = getattr(vg, name)
    mark = factory("records", x=None, stroke_width=1, strokeWidth=2, title=UNSET)
    assert isinstance(mark, Mark)
    assert mark.to_dict() == {
        "mark": wire,
        "data": {"from": "records"},
        "x": None,
        "strokeWidth": 2,
    }
    assert factory.__module__ == "vgplot._generated.marks"
    assert pickle.loads(pickle.dumps(factory)) is factory  # ruff: ignore[suspicious-pickle-usage]
    parameters = inspect.signature(factory).parameters
    assert parameters["data"].default is None
    assert parameters["options"].kind == inspect.Parameter.VAR_KEYWORD
    assert all(
        value.kind == inspect.Parameter.KEYWORD_ONLY and value.default is UNSET
        for key, value in parameters.items()
        if key not in {"data", "options"}
    )


def test_density1d_keywords_keep_branch_options_and_native_omission() -> None:
    assert vg.density_x("records", type_="lineX", y="value").to_dict() == {
        "mark": "densityX",
        "data": {"from": "records"},
        "type": "lineX",
        "y": "value",
    }
    assert vg.density_y("records", x="value").to_dict() == {
        "mark": "densityY",
        "data": {"from": "records"},
        "x": "value",
    }
    assert vg.density_x(type_=UNSET, future_style=7).to_dict() == {
        "mark": "densityX",
        "futureStyle": 7,
    }


def test_density1d_bandwidth_reference_retains_identity() -> None:
    bandwidth = vg.param(8)
    mark = vg.density_y("records", bandwidth=bandwidth)
    assert mark.enc is not None
    assert mark.enc["bandwidth"] is bandwidth
    assert (
        mark.to_dict(param_names={id(bandwidth): "bandwidth"})["bandwidth"]
        == "$bandwidth"
    )


def test_density1d_signatures_keep_distinct_first_seen_branch_order() -> None:
    for factory in [vg.density_x, vg.density_y]:
        names = list(inspect.signature(factory).parameters)
        assert names.index("type_") < names.index("r") < names.index("text")
        assert {
            "bandwidth",
            "bins",
            "normalize",
            "stack",
            "curve",
            "r",
            "text",
            "font_size",
        } <= set(names)
