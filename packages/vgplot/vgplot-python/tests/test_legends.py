from __future__ import annotations

import inspect
import json
import os
import runpy
from pathlib import Path
from typing import TYPE_CHECKING, Any

import pytest
import vgplot as vg
from vgplot.plot import Directive

if TYPE_CHECKING:
    from collections.abc import Callable


@pytest.fixture(params=["color", "opacity", "symbol"])
def legend(request: pytest.FixtureRequest) -> tuple[str, Callable[..., dict[str, Any]]]:
    channel = request.param
    return channel, getattr(vg, f"{channel}_legend")


def test_public_signature(
    legend: tuple[str, Callable[..., dict[str, Any]]],
) -> None:
    channel, helper = legend
    assert f"{channel}_legend" in vg.__all__
    parameters = inspect.signature(helper).parameters
    assert list(parameters) == ["plot", "bind", "label", "columns", "kwargs"]
    for name in ("plot", "bind", "label", "columns"):
        assert parameters[name].default is None
        assert parameters[name].kind is inspect.Parameter.POSITIONAL_OR_KEYWORD
    assert parameters["kwargs"].kind is inspect.Parameter.VAR_KEYWORD


def test_positional_arguments_and_option_names(
    legend: tuple[str, Callable[..., dict[str, Any]]],
) -> None:
    channel, helper = legend
    assert helper("chart", "$brush", "Categories", 2, tick_size=4, margin_top=1) == {
        "legend": channel,
        "for": "chart",
        "as": "$brush",
        "label": "Categories",
        "columns": 2,
        "tickSize": 4,
        "marginTop": 1,
    }


def test_keyword_aliases_override_named_arguments(
    legend: tuple[str, Callable[..., dict[str, Any]]],
) -> None:
    channel, helper = legend
    assert helper(plot="original", bind="$original", for_="chart", as_="$brush") == {
        "legend": channel,
        "for": "chart",
        "as": "$brush",
    }


def test_none_is_omitted_but_falsy_options_are_preserved(
    legend: tuple[str, Callable[..., dict[str, Any]]],
) -> None:
    channel, helper = legend
    assert helper() == {"legend": channel}
    assert helper(None, None, None, None, tick_size=None) == {"legend": channel}
    assert helper(label="", columns=0, reverse=False, unknown_option="kept") == {
        "legend": channel,
        "label": "",
        "columns": 0,
        "reverse": False,
        "unknownOption": "kept",
    }
    assert helper(plot="chart", for_=None, bind="$brush", as_=None) == {
        "legend": channel
    }


def test_inline_view_serialization_resolves_selection_and_directives(
    legend: tuple[str, Callable[..., dict[str, Any]]],
) -> None:
    channel, helper = legend
    selection = vg.selection.single()
    view = vg.plot(
        helper(bind=selection, field="category"),
        vg.directive("name", "chart"),
        vg.color_label(None),
    )
    assert isinstance(view, vg.View)
    assert isinstance(vg.color_label(None), Directive)
    assert view.to_dict(_context={}) == {
        "params": {"_param0": {"select": "single"}},
        "plot": [{"legend": channel, "as": "$_param0", "field": "category"}],
        "name": "chart",
        "colorLabel": None,
    }


def test_standalone_layout_serialization(
    legend: tuple[str, Callable[..., dict[str, Any]]],
) -> None:
    channel, helper = legend
    view = vg.vconcat(
        vg.plot(vg.directive("name", "chart")),
        helper(plot="chart", label="Categories"),
    )
    assert view.to_dict(_context={}) == {
        "vconcat": [
            {"plot": [], "name": "chart"},
            {"legend": channel, "for": "chart", "label": "Categories"},
        ]
    }


def test_python_template_execution() -> None:
    channel = "color"
    root = (
        Path(os.environ["TEST_SRCDIR"])
        / os.environ["TEST_WORKSPACE"]
        / "templates"
        / "legends"
    )
    namespace = runpy.run_path(str(root / f"{channel}.py"))
    view = namespace["view"]
    assert isinstance(view, vg.Spec)
    serialized = view.to_dict()
    expected = json.loads((root / f"{channel}.json").read_text(encoding="utf-8"))
    data = [
        {"x": 1, "y": 2, "category": "A", "alpha": 0.3},
        {"x": 2, "y": 1, "category": "B", "alpha": 0.7},
        {"x": 3, "y": 3, "category": "A", "alpha": 1},
    ]
    assert expected["data"] == {"legend_data": data}
    expected["data"] = {"legend_data": {"type": "json", "data": data}}
    assert serialized == expected
    assert serialized["params"] == {"brush": {"select": "crossfilter"}}
    field = "alpha" if channel == "opacity" else "category"
    encoding = "fill" if channel == "color" else channel
    assert serialized["plot"] == [
        {
            "mark": "dot",
            "data": {"from": "legend_data", "filterBy": "$brush"},
            "x": "x",
            "y": "y",
            encoding: field,
        },
        {"legend": channel, "as": "$brush", "field": field},
    ]
