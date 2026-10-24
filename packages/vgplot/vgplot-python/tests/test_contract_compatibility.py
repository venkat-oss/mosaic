from __future__ import annotations

import inspect
import json
import subprocess
import sys

import pytest
import vgplot as vg


def test_source_preserves_unnest_and_omits_none_options() -> None:
    source = vg.source("records", unnest=["items"], filter_by=None, optimize=False)
    assert vg.dot(source, x="items").to_dict() == {
        "mark": "dot",
        "data": {"from": "records", "unnest": ["items"], "optimize": False},
        "x": "items",
    }


def test_lag_compresses_an_omitted_offset_before_an_explicit_default() -> None:
    assert vg.lag("v") == {"lag": "v"}
    assert vg.lag("v", default=None) == {"lag": ["v", None]}  # ty: ignore[invalid-argument-type]
    assert vg.lag("v", 2, None) == {"lag": ["v", 2, None]}  # ty: ignore[invalid-argument-type]
    assert vg.lag("v", order_by="time", descending=False) == {
        "lag": "v",
        "order_by": "time",
        "descending": False,
    }


def test_input_omits_none_before_applying_aliases() -> None:
    assert vg.menu(bind="$original", as_=None).to_dict(_context={}) == {
        "input": "menu",
        "as": "$original",
    }
    assert vg.menu(bind="$original", as_="$override").to_dict(_context={}) == {
        "input": "menu",
        "as": "$override",
    }
    assert vg.search(source="records", from_=None).to_dict(_context={}) == {
        "input": "search",
        "from": "records",
    }


def test_margins_accepts_four_positional_sides() -> None:
    parameters = inspect.signature(vg.margins).parameters
    assert list(parameters) == ["top", "right", "bottom", "left", "kwargs"]
    for name in ("top", "right", "bottom", "left"):
        assert parameters[name].default is None
        assert parameters[name].kind is inspect.Parameter.POSITIONAL_OR_KEYWORD
    assert parameters["kwargs"].kind is inspect.Parameter.VAR_KEYWORD
    assert vg.margins(0, 2, None, 4).to_kv() == (
        "margins",
        {"top": 0, "right": 2, "left": 4},
    )
    assert vg.plot(vg.margins(0, 2, None, 4)).to_dict(_context={}) == {
        "plot": [],
        "margins": {"top": 0, "right": 2, "left": 4},
    }


def test_table_source_and_table_input_have_distinct_public_names() -> None:
    assert vg.table("SELECT * FROM records").to_dict() == {
        "type": "table",
        "query": "SELECT * FROM records",
    }
    assert vg.table_input("records", bind="$rows", row_batch=10).to_dict(
        _context={}
    ) == {
        "input": "table",
        "from": "records",
        "as": "$rows",
        "rowBatch": 10,
    }


def test_select_and_checkbox_remain_python_authoring_helpers() -> None:
    assert vg.select("Category", "$choice", ["A", vg.option("Bee", "B")]).to_dict(
        _context={}
    ) == {
        "input": "select",
        "label": "Category",
        "as": "$choice",
        "options": [
            {"label": "A", "value": "A"},
            {"label": "Bee", "value": "B"},
        ],
        "multiple": False,
    }
    assert vg.checkbox("Enabled", "$enabled").to_dict(_context={}) == {
        "input": "checkbox",
        "label": "Enabled",
        "as": "$enabled",
        "value": False,
    }


def test_public_spec_discovers_data_and_params_in_its_callers_scope() -> None:
    records = vg.json([{"v": 1}])
    threshold = vg.param(1)
    result = vg.spec(view=vg.plot(vg.dot(records, x=threshold)))
    assert result.to_dict() == {
        "data": {"records": {"type": "json", "data": [{"v": 1}]}},
        "params": {"threshold": 1},
        "plot": [{"mark": "dot", "data": {"from": "records"}, "x": "$threshold"}],
    }


def test_public_spec_explicit_names_override_caller_names() -> None:
    records = vg.json([{"v": 1}])
    threshold = vg.param(1)
    result = vg.spec(
        data={"renamed": records},
        params={"cutoff": threshold},
        view=vg.plot(vg.dot(records, x=threshold)),
    )
    assert result.to_dict() == {
        "data": {"renamed": {"type": "json", "data": [{"v": 1}]}},
        "params": {"cutoff": 1},
        "plot": [{"mark": "dot", "data": {"from": "renamed"}, "x": "$cutoff"}],
    }


def test_view_explicit_context_replaces_caller_discovery() -> None:
    records = vg.json([{"v": 1}])
    threshold = vg.param(1)
    view = vg.plot(vg.dot(records, x=threshold))
    assert view.to_dict(_context={"renamed": records, "cutoff": threshold}) == {
        "data": {"renamed": {"type": "json", "data": [{"v": 1}]}},
        "params": {"cutoff": 1},
        "plot": [{"mark": "dot", "data": {"from": "renamed"}, "x": "$cutoff"}],
    }


def test_positional_legend_dict_is_interpreted_as_data() -> None:
    assert vg.spec(vg.color_legend(plot="chart")).to_dict() == {
        "data": {"legend": "color", "for": "chart"}
    }


@pytest.mark.parametrize(
    "module",
    [
        "vgplot",
        "vgplot.plot",
        "vgplot._types",
        "vgplot._generated",
        "vgplot._generated.marks",
        "vgplot._generated.attributes",
        "vgplot._generated.encodings",
        "vgplot._generated.legends",
        "vgplot._generated.facet_attributes",
        "vgplot._mark_runtime",
        "vgplot._mark_api",
        "vgplot._mark_contracts",
    ],
)
def test_public_modules_import_in_fresh_processes(module: str) -> None:
    program = """
import importlib
import json
import sys

importlib.import_module(sys.argv[1])
import vgplot as vg
from vgplot._types import UNSET

print(json.dumps(vg.dot("records", x=UNSET, y=None).to_dict()))
"""
    result = subprocess.run(  # ruff: ignore[subprocess-without-shell-equals-true]
        [sys.executable, "-c", program, module],
        capture_output=True,
        check=True,
        shell=False,
        text=True,
        timeout=15,
    )
    assert json.loads(result.stdout) == {
        "mark": "dot",
        "data": {"from": "records"},
        "y": None,
    }
