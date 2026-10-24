from __future__ import annotations

import importlib
import inspect
from typing import Any

import vgplot as vg
from vgplot._spec_contracts import RUNTIME_APIS, VIEW_KEYS


def test_retained_root_signatures_match_their_canonical_contracts() -> None:
    for contract in RUNTIME_APIS:
        target: Any = importlib.import_module(contract["module"])
        for name in contract["name"].split("."):
            target = getattr(target, name)
        signature = inspect.signature(target)
        actual = [
            {
                "name": parameter.name,
                "kind": parameter.kind.name,
                "annotation": ""
                if parameter.annotation is inspect.Parameter.empty
                else parameter.annotation,
                "default": "required"
                if parameter.default is inspect.Parameter.empty
                else repr(parameter.default),
            }
            for parameter in signature.parameters.values()
        ]
        assert actual == contract["parameters"], contract["name"]
        assert signature.return_annotation == contract["returns"]
        assert target.__module__ == contract["module"]


def test_caller_sensitive_exports_are_direct_runtime_bindings() -> None:
    runtime = importlib.import_module("vgplot.spec")
    assert vg.spec is runtime.spec
    assert vg.View is runtime.View
    assert vg.Spec is runtime.Spec
    assert VIEW_KEYS == {"plot", "vconcat", "hconcat", "hspace", "vspace", "input"}
    assert "legend" not in VIEW_KEYS
