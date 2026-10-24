from __future__ import annotations

import json
import os
import runpy
from pathlib import Path

import pytest

ROOT = Path(os.environ["TEST_SRCDIR"]) / os.environ["TEST_WORKSPACE"]
CASES = ["fixed"]


@pytest.mark.parametrize("name", CASES)
def test_python_value_starter_matches_declarative_payload(name: str) -> None:
    source = ROOT / "templates" / "values" / f"{name}.py"
    namespace = runpy.run_path(str(source))
    payload = namespace["view"].to_dict()
    expected = json.loads(source.with_suffix(".json").read_text())
    assert payload == expected
    assert payload["data"]["value_data"]["type"] == "table"
    assert len(payload["plot"]) == 1
