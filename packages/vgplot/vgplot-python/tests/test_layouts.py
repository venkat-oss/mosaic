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

import pytest
import vgplot as vg

ROOT = Path(os.environ["TEST_SRCDIR"]) / os.environ["TEST_WORKSPACE"]
NAMES = ["hconcat", "vconcat", "hspace", "vspace"]


@pytest.mark.parametrize("name", NAMES)
def test_public_layout_identity_signature_and_pickle(name: str) -> None:
    module = importlib.import_module("vgplot.plot")
    generated = importlib.import_module("vgplot._generated.layouts")
    factory = getattr(vg, name)
    assert factory is getattr(module, name)
    assert factory is getattr(generated, name)
    assert factory.__module__ == "vgplot.plot"
    assert factory.__qualname__ == name
    assert pickle.loads(pickle.dumps(factory)) is factory  # ruff: ignore[suspicious-pickle-usage]
    signature = inspect.signature(factory)
    assert signature.return_annotation == "View"
    if name.endswith("concat"):
        assert list(signature.parameters) == ["items", "param_names", "kwargs"]
        assert signature.parameters["items"].kind is inspect.Parameter.VAR_POSITIONAL
        assert signature.parameters["param_names"].default is None
        assert (
            signature.parameters["param_names"].kind is inspect.Parameter.KEYWORD_ONLY
        )
        assert signature.parameters["kwargs"].kind is inspect.Parameter.VAR_KEYWORD
    else:
        assert list(signature.parameters) == ["value"]
        assert signature.parameters["value"].annotation == "int | str"
        assert signature.parameters["value"].default is inspect.Parameter.empty
        with pytest.raises(TypeError):
            factory()


@pytest.mark.parametrize("name", ["hconcat", "vconcat"])
def test_concat_order_no_flattening_and_last_directive_wins(name: str) -> None:
    factory = getattr(vg, name)
    first = vg.plot(vg.directive("width", 100), vg.directive("width", 200))
    nested = [vg.hspace(3)._view, vg.vspace("2em")._view]
    result = factory(first, nested, vg.plot())
    assert isinstance(result, vg.View)
    assert result.to_dict(_context={}) == {
        name: [
            {"plot": [], "width": 200},
            [{"hspace": 3}, {"vspace": "2em"}],
            {"plot": []},
        ]
    }


def test_nested_view_preserves_caller_discovery_explicit_context_and_name_allocation() -> (
    None
):
    radius = vg.param(6)
    rows = vg.table("SELECT 1 AS x")
    view = vg.hconcat(vg.plot(vg.dot(rows, x="x", r=radius)), vg.vspace(2))
    payload = view.to_dict()
    assert payload["params"] == {"radius": 6}
    assert payload["data"] == {"rows": {"type": "table", "query": "SELECT 1 AS x"}}
    assert payload["hconcat"][0]["plot"][0]["data"] == {"from": "rows"}
    assert payload["hconcat"][0]["plot"][0]["r"] == "$radius"
    explicit = view.to_dict(_context={"renamed": radius, "source_rows": rows})
    assert explicit["params"] == {"renamed": 6}
    assert "rows" not in explicit["data"]
    assert explicit["hconcat"][0]["plot"][0]["r"] == "$renamed"
    collision = vg.Spec(
        params={"_param0": 9},
        view=vg.vconcat(vg.plot(vg.dot("rows", r=vg.param(3)))),
    ).to_dict()
    assert collision["params"] == {"_param0": 9, "_param1": 3}
    assert collision["vconcat"][0]["plot"][0]["r"] == "$_param1"


def test_layout_view_context_preserves_outer_defaults_and_explicit_data() -> None:
    rows = vg.table("SELECT 1 AS x")
    result = vg.vconcat(
        vg.plot(vg.dot(rows, x="x")),
        vg.hspace(0),
        data={"explicit": rows},
        plot_defaults={"width": 180},
        config={"extension": "custom"},
    ).to_dict(_context={"rows": rows})
    assert result["data"] == {"explicit": {"type": "table", "query": "SELECT 1 AS x"}}
    assert result["vconcat"][0]["plot"][0]["data"] == {"from": "explicit"}
    assert result["plotDefaults"] == {"width": 180}
    assert result["config"] == {"extension": "custom"}


@pytest.mark.parametrize("name", ["hspace", "vspace"])
def test_spacer_keeps_literal_strings_and_runtime_values(name: str) -> None:
    factory = getattr(vg, name)
    for value in [0, -1.5, "", "$literal", "1.5em", None]:
        assert factory(value).to_dict(_context={}) == {name: value}


@pytest.mark.parametrize("name", ["hconcat"])
def test_python_starter_matches_declarative_nested_layout(name: str) -> None:
    source = ROOT / "templates" / "layouts" / f"{name}.py"
    payload = runpy.run_path(str(source))["view"].to_dict()
    expected = json.loads(source.with_suffix(".json").read_text())
    assert payload == expected
    assert payload["params"] == {"radius": 4}
    assert payload["plotDefaults"] == {"width": 180, "height": 140}


@pytest.mark.parametrize(
    "module", ["vgplot", "vgplot.plot", "vgplot._types", "vgplot._generated.layouts"]
)
def test_layout_imports_are_cold_import_safe(module: str) -> None:
    subprocess.run(  # ruff: ignore[subprocess-without-shell-equals-true]
        [
            sys.executable,
            "-c",
            f"import importlib; importlib.import_module({module!r})",
        ],
        check=True,
        capture_output=True,
    )
