from __future__ import annotations

import importlib
import json
import os
import runpy
import subprocess
import sys
from collections.abc import Sequence
from datetime import date, datetime, timezone
from pathlib import Path
from typing import Any, TypeAlias, get_args, get_type_hints

import pytest
import vgplot as vg
from narwhals.typing import IntoFrame
from vgplot import _type_contracts, _types
from vgplot.data import DataDef
from vgplot.params import _ParamBase
from vgplot.plot import FromRef


@pytest.mark.parametrize(
    "name", ["ChannelValue", "AttrValue", "MarkData", "TransformArg", "MimeBundle"]
)
def test_generated_alias_reexports_preserve_runtime_identity(name: str) -> None:
    assert getattr(_types, name) is getattr(_type_contracts, name)


def test_existing_type_module_reflection_and_adapter_imports_are_preserved() -> None:
    assert not hasattr(_types, "__all__")
    assert get_type_hints(_types) == {
        "MarkData": TypeAlias,
        "MimeBundle": TypeAlias,
    }
    assert _types.date is date
    assert _types.Sequence is Sequence
    assert _types.DataDef is DataDef
    assert _types.FromRef is FromRef
    assert _types._ParamBase is _ParamBase
    assert _types.IntoFrame is IntoFrame


def test_channel_and_attribute_aliases_include_native_dates_and_explicit_none() -> None:
    expected = (
        str,
        float,
        bool,
        date,
        dict[str, Any],
        Sequence[Any],
        _ParamBase,
        type(None),
    )
    assert get_args(_types.ChannelValue) == expected
    assert get_args(_types.AttrValue) == expected


def test_data_alias_includes_the_existing_host_and_source_types() -> None:
    assert _types.MarkData == (
        str
        | FromRef
        | DataDef
        | IntoFrame
        | dict[str, Any]
        | Sequence[Any]
        | _ParamBase
        | None
    )


def test_transform_alias_remains_narrower_than_channel_values() -> None:
    assert get_args(_types.TransformArg) == (
        str,
        float,
        bool,
        dict[str, Any],
        _ParamBase,
    )


def test_mime_bundle_alias_preserves_metadata_tuple_and_none() -> None:
    assert get_args(_types.MimeBundle) == (
        dict[str, str],
        tuple[dict[str, Any], dict[str, Any]],
        type(None),
    )


def test_date_parameters_serialize_while_native_channels_keep_their_objects() -> None:
    day = date(2020, 1, 2)
    timestamp = datetime(2020, 1, 2, 12, 30, tzinfo=timezone.utc)
    assert vg.param(day).param_def() == {"date": "2020-01-02"}
    assert vg.param(timestamp).param_def() == {"date": "2020-01-02T12:30:00+00:00"}
    assert vg.dot("rows", x=day).to_dict()["x"] is day
    assert vg.x_domain([day, timestamp]).to_kv() == ("xDomain", [day, timestamp])
    date_param = vg.param(day)
    view = vg.plot(vg.dot("rows", x=date_param), vg.color_label(None))
    assert view.to_dict(_context={"date_param": date_param}) == {
        "params": {"date_param": {"date": "2020-01-02"}},
        "plot": [{"mark": "dot", "data": {"from": "rows"}, "x": "$date_param"}],
        "colorLabel": None,
    }


def test_native_frames_remain_host_objects_with_named_references() -> None:
    pa = pytest.importorskip("pyarrow")
    frame = pa.table({"value": [1, 2]})
    view = vg.plot(vg.dot(frame, x="value"))
    serialized = view.to_dict()
    assert serialized["data"]["frame"] is frame
    assert serialized["plot"] == [
        {"mark": "dot", "data": {"from": "frame"}, "x": "value"}
    ]


def test_python_native_adapter_template_executes() -> None:
    pytest.importorskip("pyarrow")
    path = Path(os.environ["TEST_SRCDIR"]) / os.environ["TEST_WORKSPACE"] / "templates"
    namespace = runpy.run_path(str(path / "values/python-adapters.py"))
    serialized = namespace["view"].to_dict()
    assert serialized["data"]["source"] is namespace["source"]
    assert serialized["params"] == {"channel": {"date": "2020-01-02"}}
    assert serialized["plot"] == [
        {
            "mark": "dot",
            "data": {"from": "source"},
            "x": "value",
            "y": "$channel",
        }
    ]
    assert serialized["colorLabel"] is None
    assert namespace["mime"] == {"text/plain": "Python native value adapters"}


@pytest.mark.parametrize(
    "module",
    [
        "vgplot._type_contracts",
        "vgplot._types",
        "vgplot.plot",
    ],
)
def test_alias_imports_preserve_the_sentinel_in_fresh_processes(module: str) -> None:
    program = """
import copy
import importlib
import json
import pickle
import sys

importlib.import_module(sys.argv[1])
import vgplot as vg
from vgplot import _type_contracts, _types

print(json.dumps({
    "sentinel_module": _types.UNSET.__module__,
    "copy_identity": copy.copy(_types.UNSET) is _types.UNSET,
    "pickle_identity": pickle.loads(pickle.dumps(_types.UNSET)) is _types.UNSET,
    "alias_identity": _types.MarkData is _type_contracts.MarkData,
    "mark": vg.dot("rows", x=_types.UNSET, y=None).to_dict(),
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
        "sentinel_module": "vgplot._types",
        "copy_identity": True,
        "pickle_identity": True,
        "alias_identity": True,
        "mark": {"mark": "dot", "data": {"from": "rows"}, "y": None},
    }


def test_public_spec_remains_the_caller_sensitive_runtime_function() -> None:
    assert vg.spec is importlib.import_module("vgplot.spec").spec
