from __future__ import annotations

import dataclasses
import importlib
import inspect
import json
import os
import pickle
import runpy
import subprocess
import sys
from pathlib import Path
from typing import Any, get_type_hints

import pytest
import vgplot as vg
from vgplot import _data_runtime, _source_api, _source_runtime
from vgplot.data import DataDef, is_frame
from vgplot.plot import FromRef

ROOT = Path(os.environ["TEST_SRCDIR"]) / os.environ["TEST_WORKSPACE"]


def test_data_definition_identity_annotations_and_payload_aliasing() -> None:
    module = importlib.import_module("vgplot.data")
    payload: dict[str, Any] = {"type": "json", "data": [{"v": 1}]}
    definition = DataDef(payload)
    assert dataclasses.is_dataclass(definition)
    assert DataDef is _data_runtime.DataDef
    assert DataDef.__module__ == "vgplot.data"
    assert inspect.getmodule(DataDef) is module
    assert get_type_hints(DataDef) == {"payload": dict[str, Any]}
    assert definition.to_dict() is payload
    payload["custom"] = None
    assert definition.to_dict()["custom"] is None
    assert module.dataclass is dataclasses.dataclass
    assert module.nw is _data_runtime.nw
    assert is_frame is _data_runtime.is_frame
    assert is_frame.__module__ == "vgplot.data"
    restored = pickle.loads(pickle.dumps(definition))  # ruff: ignore[suspicious-pickle-usage]
    assert type(restored) is DataDef
    assert restored.to_dict() == payload


@pytest.mark.parametrize("name", ["parquet", "csv", "spatial", "table", "json", "data"])
def test_factories_preserve_public_identity_and_resolvable_annotations(
    name: str,
) -> None:
    module = importlib.import_module("vgplot.data")
    function = getattr(vg, name)
    assert function is getattr(module, name)
    assert function.__module__ == "vgplot.data"
    assert function.__qualname__ == name
    get_type_hints(function)
    assert pickle.loads(pickle.dumps(function)) is function  # ruff: ignore[suspicious-pickle-usage]


def test_loader_factories_preserve_raw_keys_none_falsy_values_and_overrides() -> None:
    assert vg.parquet(
        "rows.parquet", select=None, where=None, custom_option=None
    ).to_dict() == {
        "type": "parquet",
        "file": "rows.parquet",
        "custom_option": None,
    }
    assert vg.parquet(
        "rows.parquet", select=[], where="", type="csv", sample_size=0
    ).to_dict() == {
        "type": "csv",
        "file": "rows.parquet",
        "select": [],
        "where": "",
        "sample_size": 0,
    }
    assert vg.csv(
        "rows.csv", sample_size=-1, delimiter=";", custom_option=None, replace=False
    ).to_dict() == {
        "type": "csv",
        "file": "rows.csv",
        "sample_size": -1,
        "delimiter": ";",
        "custom_option": None,
        "replace": False,
    }
    assert vg.spatial("rows.geojson", layer=None, custom_option=None).to_dict() == {
        "type": "spatial",
        "file": "rows.geojson",
        "custom_option": None,
    }
    assert vg.spatial("rows.geojson", layer="", temp=False).to_dict() == {
        "type": "spatial",
        "file": "rows.geojson",
        "layer": "",
        "temp": False,
    }
    assert vg.json().to_dict() == {"type": "json"}
    assert vg.json([], "rows.json", custom_option=None).to_dict() == {
        "type": "json",
        "file": "rows.json",
        "data": [],
        "custom_option": None,
    }
    assert list(vg.json([{}], "rows.json").to_dict()) == ["type", "file", "data"]
    assert vg.table(" SELECT 1 ").to_dict() == {"type": "table", "query": " SELECT 1 "}
    with pytest.raises(TypeError, match="unexpected keyword argument"):
        vg.table("SELECT 1", temp=True)  # ty: ignore[unknown-argument]


def test_named_data_serializes_duck_typed_values_and_retains_every_other_value() -> (
    None
):
    class Custom:
        def to_dict(self) -> dict[str, int]:
            return {"value": 3}

    raw = {"raw_key": None}
    factory: Any = vg.data
    result = factory(named=vg.csv("rows.csv"), custom=Custom(), raw=raw, omitted=None)
    assert result == {
        "named": {"type": "csv", "file": "rows.csv"},
        "custom": {"value": 3},
        "raw": raw,
        "omitted": None,
    }
    assert result["raw"] is raw


def test_source_keeps_runtime_identity_raw_name_and_camelized_option_policy() -> None:
    module = importlib.import_module("vgplot.plot")
    assert FromRef is _source_runtime.FromRef
    assert FromRef.__module__ == "vgplot.plot"
    assert inspect.getmodule(FromRef) is module
    assert vg.source is _source_api.source is module.source
    assert vg.source.__module__ == "vgplot.plot"
    assert vg.source.__qualname__ == "source"
    assert get_type_hints(vg.source) == {"name": str, "opts": Any, "return": FromRef}
    source = vg.source(
        "rows",
        filter_by=None,
        optimize=False,
        custom_option=0,
        empty="",
        unnest=["items"],
    )
    assert source.to_dict() == {
        "from": "rows",
        "optimize": False,
        "customOption": 0,
        "empty": "",
        "unnest": ["items"],
    }
    assert pickle.loads(pickle.dumps(source)).to_dict() == source.to_dict()  # ruff: ignore[suspicious-pickle-usage]
    assert pickle.loads(pickle.dumps(vg.source)) is vg.source  # ruff: ignore[suspicious-pickle-usage]


def test_anonymous_definition_naming_reuses_identity_and_avoids_reserved_names() -> (
    None
):
    anonymous = vg.json([{"v": 1}])
    spec = vg.Spec(
        data={"_data0": vg.table("SELECT 2 AS v")},
        view=vg.vconcat(
            vg.plot(vg.dot(anonymous, x="v")), vg.plot(vg.dot(anonymous, y="v"))
        ),
    )
    value = spec.to_dict()
    assert value["data"] == {
        "_data0": {"type": "table", "query": "SELECT 2 AS v"},
        "_data1": {"type": "json", "data": [{"v": 1}]},
    }
    assert [plot["plot"][0]["data"] for plot in value["vconcat"]] == [
        {"from": "_data1"},
        {"from": "_data1"},
    ]


@pytest.mark.parametrize("value", [None, "rows", b"rows", 1, 1.5, False, {}, [], ()])
def test_builtin_values_are_not_native_frames(value: Any) -> None:
    assert is_frame(value) is False


@pytest.mark.parametrize("name", ["source-filtered"])
def test_generated_python_starter_matches_its_declarative_example(name: str) -> None:
    path = ROOT / "templates" / "data" / name
    namespace = runpy.run_path(str(path.with_suffix(".py")))
    expected = json.loads(path.with_suffix(".json").read_text())
    assert namespace["view"].to_dict() == expected


def test_native_unnest_starter_retains_the_source_extension() -> None:
    namespace = runpy.run_path(str(ROOT / "templates" / "data/unnest.py"))
    assert namespace["view"].to_dict()["plot"][0]["data"] == {
        "from": "nested_rows",
        "unnest": ["items"],
    }


def test_native_frame_starter_keeps_registered_host_object() -> None:
    pytest.importorskip("pyarrow")
    namespace = runpy.run_path(str(ROOT / "templates" / "data/frames.py"))
    frame = namespace["frame"]
    assert is_frame(frame)
    result = namespace["view"].to_dict(_context={"frame": frame})
    assert result["data"]["frame"] is frame
    assert result["plot"][0]["data"] == {"from": "frame"}


@pytest.mark.parametrize(
    "module",
    [
        "vgplot.data",
        "vgplot._data_runtime",
        "vgplot._source_runtime",
        "vgplot._source_api",
        "vgplot.plot",
        "vgplot._types",
        "vgplot._type_contracts",
        "vgplot.spec",
    ],
)
def test_data_and_source_imports_are_safe_in_fresh_processes(module: str) -> None:
    program = """
import importlib
import json
import pickle
import sys
importlib.import_module(sys.argv[1])
import vgplot as vg
from vgplot.data import DataDef
from vgplot.plot import FromRef
from vgplot._data_runtime import DataDef as RuntimeDataDef
from vgplot._source_runtime import FromRef as RuntimeFromRef
print(json.dumps({"data":DataDef is RuntimeDataDef,"source":FromRef is RuntimeFromRef,"pickle":pickle.loads(pickle.dumps(vg.csv("rows.csv"))).to_dict(),"module":vg.source.__module__}))
"""
    result = subprocess.run(  # ruff: ignore[subprocess-without-shell-equals-true]
        [sys.executable, "-c", program, module],
        check=True,
        capture_output=True,
        text=True,
        shell=False,
        timeout=15,
    )
    assert json.loads(result.stdout) == {
        "data": True,
        "source": True,
        "pickle": {"type": "csv", "file": "rows.csv"},
        "module": "vgplot.plot",
    }
