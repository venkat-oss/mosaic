from __future__ import annotations

import inspect

import pytest
import vgplot as vg
from vgplot._types import UNSET


@pytest.mark.parametrize(
    "name", ["cume_dist", "dense_rank", "percent_rank", "rank", "row_number"]
)
def test_nullary_window_signatures_keep_null_dictionary_arguments(name: str) -> None:
    factory = getattr(vg, name)
    signature = inspect.signature(factory)
    assert list(signature.parameters) == ["options"]
    assert signature.parameters["options"].kind is inspect.Parameter.VAR_KEYWORD
    assert factory(rows=[None, 0], raw_option=None) == {
        name: None,
        "rows": [None, 0],
        "raw_option": None,
    }
    assert factory(**{name: "override"}) == {name: "override"}


@pytest.mark.parametrize(
    ("name", "arguments"),
    [
        ("first_value", ["col"]),
        ("last_value", ["col"]),
        ("nth_value", ["col", "offset"]),
        ("ntile", ["buckets"]),
        ("lag", ["col", "offset", "default"]),
        ("lead", ["col", "offset", "default"]),
    ],
)
def test_window_signatures(name: str, arguments: list[str]) -> None:
    signature = inspect.signature(getattr(vg, name))
    assert list(signature.parameters) == [*arguments, "options"]
    for argument in arguments:
        optional = name in {"lag", "lead"} and argument != "col"
        assert signature.parameters[argument].default is (
            UNSET if optional else inspect.Parameter.empty
        )
        assert signature.parameters[argument].annotation == (
            "TransformArg | UNSET" if optional else "TransformArg"
        )
    assert signature.return_annotation == "dict[str, Any]"


@pytest.mark.parametrize("name", ["lag", "lead"])
def test_lag_and_lead_keep_unset_hole_compression(name: str) -> None:
    factory = getattr(vg, name)
    assert factory("x") == {name: "x"}
    assert factory("x", default=None) == {name: ["x", None]}
    assert factory("x", default=0) == {name: ["x", 0]}
    assert factory("x", None, None) == {name: ["x", None, None]}
    assert factory("x", 2, None, raw_option=None) == {
        name: ["x", 2, None],
        "raw_option": None,
    }


def test_interval_and_frame_utilities_remain_javascript_only() -> None:
    for name in ["days", "interval", "frame_rows", "frame_range", "frame_groups"]:
        assert not hasattr(vg, name)
