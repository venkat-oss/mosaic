from __future__ import annotations

import importlib
import inspect
import json
import os
import pickle
import runpy
import subprocess
import sys
from pathlib import Path
from typing import Any, cast

import pytest
import vgplot as vg

ROOT = Path(os.environ["TEST_SRCDIR"]) / os.environ["TEST_WORKSPACE"]


def test_option_omission_preserves_explicit_none_and_container_identity() -> None:
    label = object()
    assert vg.option(label) == {"label": label, "value": label}
    assert vg.option("Unset", None) == {"label": "Unset", "value": None}
    payload = {"nested": [1]}
    assert vg.option("Object", payload)["value"] is payload


def test_scalar_options_stay_scalar_and_mixed_options_normalize_only_nondicts() -> None:
    options = ["Alpha", 0, False, None]
    assert vg.menu(options=options)._view["options"] is options
    record = {"value": "Beta", "label": "Second"}
    sequence = [1, 2]
    mixed = vg.menu(options=["Alpha", record, sequence, None])._view["options"]
    assert mixed == [
        {"label": "Alpha", "value": "Alpha"},
        record,
        {"label": sequence, "value": sequence},
        {"label": None, "value": None},
    ]
    assert mixed[1] is record
    assert mixed[2]["value"] is sequence


def test_input_none_alias_order_falsy_values_and_arbitrary_options() -> None:
    assert vg.input(
        "custom",
        bind="$first",
        as_=None,
        source="rows",
        from_=None,
        max_width=0,
        enabled=False,
        label="",
        payload=None,
    ).to_dict(_context={}) == {
        "input": "custom",
        "as": "$first",
        "from": "rows",
        "maxWidth": 0,
        "enabled": False,
        "label": "",
    }
    assert vg.menu(bind="$first", as_="$last")._view["as"] == "$last"
    assert vg.search(source="first", from_="last")._view["from"] == "last"


@pytest.mark.parametrize("name", ["slider", "select", "checkbox"])
def test_required_python_label_and_binding_are_preserved(name: str) -> None:
    function = getattr(vg, name)
    signature = inspect.signature(function)
    assert signature.parameters["label"].default is inspect.Parameter.empty
    assert signature.parameters["bind"].default is inspect.Parameter.empty
    with pytest.raises(TypeError):
        function()


def test_target_only_extension_defaults_and_optional_shared_helpers() -> None:
    assert vg.menu()._view == {"input": "menu"}
    assert vg.search()._view == {"input": "search"}
    assert vg.slider("Value", "$value")._view == {
        "input": "slider",
        "label": "Value",
        "as": "$value",
    }
    assert vg.checkbox("Enabled", "$enabled")._view["value"] is False
    assert vg.select("Category", "$category", [])._view["multiple"] is False
    assert (
        "value" not in cast("Any", vg.checkbox)("Enabled", "$enabled", value=None)._view
    )


def test_input_bindings_and_data_are_discovered_from_the_calling_user() -> None:
    binding = vg.selection.crossfilter()
    records = vg.table("SELECT 'Alpha' AS category")
    result = vg.spec(view=vg.menu(bind=binding, source=records)).to_dict()
    assert result["as"] == "$binding"
    assert result["from"] == "records"
    assert result["params"]["binding"] == {"select": "crossfilter"}
    assert result["data"]["records"] == {
        "type": "table",
        "query": "SELECT 'Alpha' AS category",
    }


@pytest.mark.parametrize(
    "name", ["input", "option", "menu", "search", "slider", "select", "checkbox"]
)
def test_input_functions_keep_public_identity_and_deferred_annotations(
    name: str,
) -> None:
    module = importlib.import_module("vgplot.plot")
    function = getattr(vg, name)
    assert getattr(module, name) is function
    assert function.__module__ == "vgplot.plot"
    assert function.__qualname__ == name
    assert pickle.loads(pickle.dumps(function)) is function  # ruff: ignore[suspicious-pickle-usage]
    assert all(
        isinstance(annotation, str) for annotation in function.__annotations__.values()
    )


@pytest.mark.parametrize(
    "module",
    ["vgplot._input_api", "vgplot._input_runtime", "vgplot.plot", "vgplot.spec"],
)
def test_input_modules_import_in_a_fresh_process(module: str) -> None:
    result = subprocess.run(  # ruff: ignore[subprocess-without-shell-equals-true]
        [
            sys.executable,
            "-c",
            f"import {module}; import vgplot; assert callable(vgplot.menu)",
        ],
        env={**os.environ, "PYTHONPATH": str(ROOT / "packages/vgplot/vgplot-python")},
        check=False,
        capture_output=True,
        text=True,
    )
    assert result.returncode == 0, result.stderr


@pytest.mark.parametrize("name", ["menu-table", "slider-param"])
def test_python_input_starter_serializes_to_the_shared_spec(name: str) -> None:
    base = ROOT / "templates/inputs/basic" / name
    namespace = runpy.run_path(str(base.with_suffix(".py")))
    assert namespace["view"].to_dict() == json.loads(
        base.with_suffix(".json").read_text()
    )


def test_python_extension_starter_serializes_without_default_parser_claims() -> None:
    namespace = runpy.run_path(
        str(ROOT / "templates/inputs/basic/python-extensions.py")
    )
    results = {name: view.to_dict() for name, view in namespace["views"].items()}
    assert results["select"]["input"] == "select"
    assert results["select"]["multiple"] is True
    assert results["select"]["options"] == [
        {"label": "Alpha", "value": "Alpha"},
        {"label": "Second", "value": "Beta"},
    ]
    assert results["checkbox"]["value"] is False
    assert results["generic"]["input"] == "custom"
    assert results["option"]["options"] == [{"label": "Unset", "value": None}]
