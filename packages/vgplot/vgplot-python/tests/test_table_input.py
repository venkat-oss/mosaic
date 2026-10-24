from __future__ import annotations

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


def test_table_input_signature_and_public_identity() -> None:
    assert str(inspect.signature(vg.table_input)) == (
        "(source: 'Any', bind: 'Any' = None, columns: 'Any' = None, "
        "filter_by: 'Any' = None, width: 'Any' = None, height: 'Any' = None, "
        "max_width: 'Any' = None, row_batch: 'Any' = None, align: 'Any' = None, "
        "**opts: 'Any') -> 'View'"
    )
    assert vg.table_input.__module__ == "vgplot.plot"
    assert pickle.loads(pickle.dumps(vg.table_input)) is vg.table_input  # ruff: ignore[suspicious-pickle-usage]
    with pytest.raises(TypeError, match="source"):
        cast("Any", vg.table_input)()


def test_table_input_preserves_alias_precedence_and_omits_none_before_normalization() -> (
    None
):
    assert vg.table_input(
        None,
        max_width=300,
        row_batch=0,
        height=0,
        **{"from": "rows", "maxWidth": 400, "raw_option": False, "unused": None},
    ).to_dict() == {
        "input": "table",
        "from": "rows",
        "maxWidth": 400,
        "rowBatch": 0,
        "height": 0,
        "rawOption": False,
    }
    assert vg.table_input(None).to_dict() == {"input": "table"}


def test_table_input_retains_reference_identity_and_distinct_data_factory() -> None:
    source = vg.param("rows")
    brush = vg.selection.crossfilter()
    view = vg.Spec(
        params={"source_name": source, "brush": brush},
        view=vg.table_input(source, bind=brush, filter_by=brush, columns=["x"]),
    )
    assert view.to_dict() == {
        "params": {"source_name": "rows", "brush": {"select": "crossfilter"}},
        "input": "table",
        "from": "$source_name",
        "as": "$brush",
        "filterBy": "$brush",
        "columns": ["x"],
    }
    assert vg.table("SELECT 1 AS x").to_dict() == {
        "type": "table",
        "query": "SELECT 1 AS x",
    }


@pytest.mark.parametrize("name", ["filtered"])
def test_table_starter_python_roundtrip(name: str) -> None:
    root = Path(os.environ["TEST_SRCDIR"]) / os.environ["TEST_WORKSPACE"]
    path = root / "templates/inputs/table" / f"{name}.py"
    namespace = runpy.run_path(str(path))
    assert namespace["view"].to_dict() == json.loads(
        path.with_suffix(".json").read_text()
    )


@pytest.mark.parametrize("first", ["vgplot._table_api", "vgplot.plot", "vgplot.spec"])
def test_table_facade_cold_import_preserves_public_identity(first: str) -> None:
    subprocess.run(  # ruff: ignore[subprocess-without-shell-equals-true]
        [
            sys.executable,
            "-c",
            (
                f"import {first}; import importlib; import vgplot as vg; p=importlib.import_module('vgplot.plot'); "
                "assert vg.table_input is p.table_input; "
                "assert vg.table_input('rows').to_dict() == {'input':'table','from':'rows'}"
            ),
        ],
        check=True,
    )
