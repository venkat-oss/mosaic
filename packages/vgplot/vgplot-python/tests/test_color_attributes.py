from __future__ import annotations

import importlib
import inspect
import json
import os
import pickle
import runpy
from pathlib import Path

import pytest
import vgplot as vg

NAMES = [
    "colorScale",
    "colorDomain",
    "colorRange",
    "colorClamp",
    "colorN",
    "colorNice",
    "colorScheme",
    "colorInterpolate",
    "colorPivot",
    "colorSymmetric",
    "colorLabel",
    "colorPercent",
    "colorReverse",
    "colorZero",
    "colorTickFormat",
    "colorExponent",
    "colorBase",
    "colorConstant",
    "opacityScale",
    "opacityDomain",
    "opacityRange",
    "opacityClamp",
    "opacityNice",
    "opacityLabel",
    "opacityPercent",
    "opacityReverse",
    "opacityZero",
    "opacityTickFormat",
    "opacityExponent",
    "opacityBase",
    "opacityConstant",
    "symbolScale",
    "symbolDomain",
    "symbolRange",
]
TRUE_DEFAULTS = {
    "colorClamp",
    "colorNice",
    "colorSymmetric",
    "colorPercent",
    "colorReverse",
    "colorZero",
    "opacityClamp",
    "opacityNice",
    "opacityPercent",
    "opacityReverse",
    "opacityZero",
}


def python_name(name: str) -> str:
    return "".join(f"_{char.lower()}" if char.isupper() else char for char in name)


@pytest.mark.parametrize("name", NAMES)
def test_color_attribute_signature_none_and_historical_pickle_global(name: str) -> None:
    function = getattr(vg, python_name(name))
    parameter = inspect.signature(function).parameters["value"]
    assert parameter.annotation == "AttrValue"
    assert inspect.signature(function).return_annotation == "Directive"
    assert parameter.default is (
        True if name in TRUE_DEFAULTS else inspect.Parameter.empty
    )
    assert function(None).to_kv() == (name, None)
    historical = f"cvgplot._generated.attributes\n{function.__name__}\n.".encode()
    assert pickle.loads(historical) is function  # ruff: ignore[suspicious-pickle-usage]
    if name in TRUE_DEFAULTS:
        assert function().to_kv() == (name, True)
        assert function(False).to_kv() == (name, False)


def test_color_attribute_facade_forwards_the_same_factories() -> None:
    generated = importlib.import_module("vgplot._generated.color_attributes")
    facade = importlib.import_module("vgplot._generated.attributes")
    for name in NAMES:
        public_name = python_name(name)
        assert getattr(generated, public_name) is getattr(facade, public_name)
        assert getattr(vg, public_name) is getattr(facade, public_name)


@pytest.mark.parametrize("name", ["colorScheme"])
def test_color_starter_python_roundtrip(name: str) -> None:
    root = Path(os.environ["TEST_SRCDIR"]) / os.environ["TEST_WORKSPACE"]
    path = root / "templates/attributes/color" / f"{name}.py"
    namespace = runpy.run_path(str(path))
    assert namespace["view"].to_dict() == json.loads(
        path.with_suffix(".json").read_text()
    )
