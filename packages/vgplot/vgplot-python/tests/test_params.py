from __future__ import annotations

import inspect
import json
import os
import pickle
import runpy
import subprocess
import sys
from datetime import date
from pathlib import Path
from typing import Any, get_type_hints

import pytest
import vgplot as vg
from vgplot import _param_runtime, params


def restore_pickle(payload: bytes) -> Any:
    return pickle.loads(payload)  # ruff: ignore[suspicious-pickle-usage]


def test_public_factory_signature_and_runtime_annotation_resolution() -> None:
    signature = inspect.signature(vg.param)
    assert list(signature.parameters) == ["value"]
    value = signature.parameters["value"]
    assert value.kind is inspect.Parameter.POSITIONAL_OR_KEYWORD
    assert value.default is None
    assert value.annotation == "Any"
    assert signature.return_annotation == "_ParamBase"
    assert get_type_hints(vg.param) == {"value": Any, "return": params._ParamBase}
    assert vg.param.__module__ == "vgplot.params"
    assert vg.param.__qualname__ == "param"
    assert vg.param is params.param


def test_selection_namespace_retains_method_order_and_identity() -> None:
    assert [name for name in vars(vg.selection) if not name.startswith("_")] == [
        "intersect",
        "crossfilter",
        "union",
        "single",
    ]
    assert vg.selection is params.selection
    assert vg.selection.__module__ == "vgplot.params"
    assert vg.selection.__qualname__ == "selection"
    assert vg.selection.__doc__ == "Namespace for creating selection params."


@pytest.mark.parametrize("kind", ["intersect", "crossfilter", "union", "single"])
def test_selection_factories_keep_variadic_signatures_and_raw_options(
    kind: str,
) -> None:
    factory = getattr(vg.selection, kind)
    signature = inspect.signature(factory)
    assert list(signature.parameters) == ["opts"]
    assert signature.parameters["opts"].kind is inspect.Parameter.VAR_KEYWORD
    assert signature.parameters["opts"].annotation == "Any"
    assert signature.return_annotation == "SelectionDef"
    assert get_type_hints(factory) == {"opts": Any, "return": params.SelectionDef}
    assert factory.__module__ == "vgplot.params"
    assert factory.__qualname__ == f"selection.{kind}"
    result = factory(
        cross=False,
        empty=False,
        include=None,
        custom_option="unchanged",
        zero=0,
        label="",
        ignored=None,
    )
    assert type(result) is params.SelectionDef
    assert result.param_def() == {
        "select": kind,
        "cross": False,
        "empty": False,
        "custom_option": "unchanged",
        "zero": 0,
        "label": "",
    }
    assert list(result.param_def()) == [
        "select",
        "cross",
        "empty",
        "custom_option",
        "zero",
        "label",
    ]
    with pytest.raises(TypeError, match=r"multiple values.*select"):
        factory(select="union")


@pytest.mark.parametrize("value", [None, False, 0, "", {"value": 3}, (1, 2)])
def test_non_list_values_keep_scalar_dispatch_and_object_identity(value: Any) -> None:
    parameter = vg.param(value)
    assert type(parameter) is params.ParamValue
    assert parameter.param_def() is value


def test_list_dispatch_shallow_copy_and_nested_identity_resolution() -> None:
    threshold = vg.param(2)
    nested: dict[str, Any] = {"values": [threshold, None]}
    original = [threshold, nested]
    parameter = vg.param(original)
    assert type(parameter) is params.ParamArray
    original.append("later")
    nested["flag"] = False
    assert parameter.param_def(param_names={id(threshold): "threshold"}) == [
        "$threshold",
        {"values": ["$threshold", None], "flag": False},
    ]
    assert repr(parameter).startswith("param.array(")


def test_scalar_tuple_does_not_recursively_resolve_parameter_objects() -> None:
    threshold = vg.param(2)
    value = (threshold, None)
    parameter = vg.param(value)
    assert parameter.param_def(param_names={id(threshold): "threshold"}) is value
    assert vg.param().param_def() is None
    assert vg.param("$threshold").param_def() == "$threshold"


def test_nested_selection_references_use_object_identity_and_keep_unknown_objects() -> (
    None
):
    upstream = vg.selection.single()
    unknown = vg.param(1)
    definition = vg.selection.intersect(
        include=[upstream], nested={"items": [upstream, unknown]}, empty=False
    )
    assert definition.param_def(param_names={id(upstream): "upstream"}) == {
        "select": "intersect",
        "include": ["$upstream"],
        "nested": {"items": ["$upstream", unknown]},
        "empty": False,
    }
    original = {"items": [upstream]}
    assert params._resolve(original, None) is original
    unmapped = params._resolve(original, {})
    assert unmapped == original
    assert unmapped is not original
    assert unmapped["items"][0] is upstream


def test_runtime_class_and_helper_import_paths_remain_canonical() -> None:
    for name in ("_ParamBase", "ParamValue", "ParamArray", "SelectionDef"):
        cls = getattr(params, name)
        assert cls is getattr(_param_runtime, name)
        assert cls.__module__ == "vgplot.params"
        assert cls.__qualname__ == name
        assert inspect.getmodule(cls) is params
        assert restore_pickle(pickle.dumps(cls)) is cls
    assert params._resolve is _param_runtime._resolve
    assert params._resolve.__module__ == "vgplot.params"
    assert inspect.getmodule(params._resolve) is params
    assert params.date is date
    assert params.Any is Any
    assert not hasattr(params, "__all__")
    assert restore_pickle(pickle.dumps(vg.param)) is vg.param
    assert restore_pickle(pickle.dumps(vg.selection)) is vg.selection
    assert restore_pickle(pickle.dumps(vg.selection.single)) is vg.selection.single


def test_pre_migration_parameter_pickles_still_restore() -> None:
    payload = (
        b"\x80\x04\x95\xad\x00\x00\x00\x00\x00\x00\x00\x8c\rvgplot.params\x94"
        b"\x8c\nParamValue\x94\x93\x94)\x81\x94}\x94\x8c\x06_value\x94K\x03sbh\x00"
        b"\x8c\nParamArray\x94\x93\x94)\x81\x94}\x94\x8c\x07_values\x94]\x94(h\x02)"
        b"\x81\x94}\x94h\x05K\x02sbNesbh\x00\x8c\x0cSelectionDef\x94\x93\x94)\x81\x94"
        b"}\x94(\x8c\x07_select\x94\x8c\tintersect\x94\x8c\x05_opts\x94}\x94"
        b"\x8c\x05empty\x94\x89sub\x87\x94."
    )
    scalar, array, selection = restore_pickle(payload)
    assert type(scalar) is params.ParamValue
    assert type(array) is params.ParamArray
    assert type(selection) is params.SelectionDef
    assert scalar.param_def() == 3
    assert array.param_def(param_names={id(array._values[0]): "threshold"}) == [
        "$threshold",
        None,
    ]
    assert selection.param_def() == {"select": "intersect", "empty": False}


@pytest.mark.parametrize(
    "module",
    [
        "vgplot.params",
        "vgplot._param_runtime",
        "vgplot._types",
        "vgplot._type_contracts",
        "vgplot.plot",
        "vgplot.spec",
    ],
)
def test_parameter_imports_and_pickles_in_fresh_processes(module: str) -> None:
    program = """
import importlib
import json
import pickle
import sys

importlib.import_module(sys.argv[1])
import vgplot as vg
from vgplot import _param_runtime, _types, params

parameter = vg.param(3)
restored = pickle.loads(pickle.dumps(parameter))
print(json.dumps({
    "class_identity": params.ParamValue is _param_runtime.ParamValue,
    "base_identity": _types._ParamBase is params._ParamBase,
    "module": type(restored).__module__,
    "value": restored.param_def(),
    "factory_identity": pickle.loads(pickle.dumps(vg.param)) is vg.param,
}))
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
        "class_identity": True,
        "base_identity": True,
        "module": "vgplot.params",
        "value": 3,
        "factory_identity": True,
    }


@pytest.mark.parametrize(
    "name",
    ["crossfilter"],
)
def test_shared_parameter_template_reserializes_to_its_wire_example(name: str) -> None:
    root = (
        Path(os.environ["TEST_SRCDIR"])
        / os.environ["TEST_WORKSPACE"]
        / "templates"
        / "params"
    )
    namespace = runpy.run_path(str(root / f"{name}.py"))
    expected = json.loads((root / f"{name}.json").read_text(encoding="utf-8"))
    assert namespace["view"].to_dict() == expected


def test_anonymous_parameter_template_uses_the_retained_auto_naming() -> None:
    root = (
        Path(os.environ["TEST_SRCDIR"])
        / os.environ["TEST_WORKSPACE"]
        / "templates"
        / "params"
    )
    namespace = runpy.run_path(str(root / "anonymous.py"))
    serialized = namespace["view"].to_dict()
    assert serialized["params"] == {"_param0": 5}
    assert serialized["plot"] == [
        {
            "mark": "dot",
            "data": {"from": "param_data"},
            "x": "x",
            "y": "y",
            "r": "$_param0",
        }
    ]
