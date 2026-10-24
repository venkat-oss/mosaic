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
CASES = [
    ("name", "name", False),
    ("width", "width", False),
    ("height", "height", False),
    ("aspectRatio", "aspect_ratio", True),
    ("margin", "margin", False),
    ("marginTop", "margin_top", False),
    ("marginRight", "margin_right", False),
    ("marginBottom", "margin_bottom", False),
    ("marginLeft", "margin_left", False),
    ("inset", "inset", False),
    ("style", "style", False),
    ("align", "align", False),
    ("padding", "padding", False),
    ("axis", "axis", True),
    ("grid", "grid", True),
    ("ariaLabel", "aria_label", False),
    ("ariaDescription", "aria_description", False),
    ("clip", "clip", True),
]


@pytest.mark.parametrize("key,name,boolean_default", CASES)
def test_value_directive_signature_defaults_null_identity_and_public_pickle(
    key: str, name: str, boolean_default: bool
) -> None:
    factory = getattr(vg, name)
    directive_type = importlib.import_module("vgplot.plot").Directive
    signature = inspect.signature(factory)
    assert list(signature.parameters) == ["value"]
    argument = signature.parameters["value"]
    assert argument.kind is inspect.Parameter.POSITIONAL_OR_KEYWORD
    assert argument.annotation == "AttrValue"
    assert signature.return_annotation == "Directive"
    assert argument.default is (True if boolean_default else inspect.Parameter.empty)
    if boolean_default:
        assert factory().value is True
    else:
        with pytest.raises(TypeError):
            factory()
    assert factory(None).value is None
    assert factory(False).to_kv() == (key, False)
    value = vg.param(7)
    result = factory(value)
    assert isinstance(result, directive_type)
    assert result.value is value
    payload = vg.plot(result).to_dict(_context={"value": value})
    assert payload["params"] == {"value": 7}
    assert payload[key] == "$value"
    historical_pickle = f"cvgplot._generated.attributes\n{name}\n.".encode()
    assert pickle.loads(historical_pickle) is factory  # ruff: ignore[suspicious-pickle-usage]


def test_margins_preserves_signature_omission_raw_keys_and_root_identity() -> None:
    module = importlib.import_module("vgplot.plot")
    assert vg.margins is module.margins
    assert vg.margins.__module__ == "vgplot.plot"
    assert vg.margins.__qualname__ == "margins"
    signature = inspect.signature(vg.margins)
    assert list(signature.parameters) == ["top", "right", "bottom", "left", "kwargs"]
    for name in ["top", "right", "bottom", "left"]:
        assert signature.parameters[name].default is None
        assert signature.parameters[name].annotation == "int | None"
    assert signature.parameters["kwargs"].kind is inspect.Parameter.VAR_KEYWORD
    assert signature.parameters["kwargs"].annotation == "Any"
    assert signature.return_annotation == "Directive"
    assert vg.margins().to_kv() == ("margins", {})
    assert vg.margins(0, None, False, 4, custom_key=7, omit=None).to_kv() == (
        "margins",
        {"top": 0, "bottom": False, "left": 4, "custom_key": 7},
    )
    assert pickle.loads(b"cvgplot.plot\nmargins\n.") is vg.margins  # ruff: ignore[suspicious-pickle-usage]
    assert vg.__all__.count("margins") == 1


def test_last_wins_directives_keep_explicit_null_and_named_nested_parameters() -> None:
    width = vg.param(320)
    payload = vg.Spec(
        params={"dimension": width},
        view=vg.plot(
            vg.width(100), vg.width(width), vg.style({"color": "red"}), vg.style(None)
        ),
    ).to_dict()
    assert payload == {
        "params": {"dimension": 320},
        "plot": [],
        "width": "$dimension",
        "style": None,
    }
    assert vg.Spec(
        params={"dimension": width}, view=vg.plot(vg.margins(top=cast("Any", width)))
    ).to_dict() == {
        "params": {"dimension": 320},
        "plot": [],
        "margins": {"top": "$dimension"},
    }


def test_generated_factories_keep_single_public_identity_and_retire_legacy_entries() -> (
    None
):
    generated = importlib.import_module("vgplot._generated.plot_attributes")
    facade = importlib.import_module("vgplot._generated.attributes")
    with pytest.raises(ModuleNotFoundError) as missing:
        importlib.import_module("vgplot._generated.legacy_attributes")
    assert missing.value.name == "vgplot._generated.legacy_attributes"
    for _, name, _ in CASES:
        assert getattr(vg, name) is getattr(generated, name)
        assert getattr(facade, name) is getattr(generated, name)
    assert vg.margins is generated.margins


@pytest.mark.parametrize("name", ["margins"])
def test_python_starter_matches_admitted_declarative_payload(name: str) -> None:
    source = ROOT / "templates/attributes/plot" / f"{name}.py"
    payload = runpy.run_path(str(source))["view"].to_dict()
    expected = json.loads(source.with_suffix(".json").read_text())
    assert payload == expected
    if name in ["ariaLabel", "ariaDescription", "clip"]:
        assert name in payload


@pytest.mark.parametrize(
    "module",
    [
        "vgplot",
        "vgplot.plot",
        "vgplot._types",
        "vgplot._generated.plot_attributes",
        "vgplot._generated.attributes",
    ],
)
def test_attribute_factories_are_cold_import_safe(module: str) -> None:
    subprocess.run(  # ruff: ignore[subprocess-without-shell-equals-true]
        [
            sys.executable,
            "-c",
            f"import importlib; importlib.import_module({module!r})",
        ],
        check=True,
        capture_output=True,
    )
