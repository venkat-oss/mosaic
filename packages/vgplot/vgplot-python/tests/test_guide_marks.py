from __future__ import annotations

import inspect
import json
import os
import pickle
import runpy
import subprocess
from pathlib import Path
from typing import TYPE_CHECKING

import pytest
import vgplot as vg
from vgplot import _types
from vgplot._generated import guides_marks, marks

if TYPE_CHECKING:
    from typing import Any

ROOT = Path(os.environ["TEST_SRCDIR"]) / os.environ["TEST_WORKSPACE"]
DIRECTORY = ROOT / "templates" / "marks" / "guides"
CASES = sorted(path.stem for path in DIRECTORY.glob("*.json"))
NAMES = [
    ("frame", "frame"),
    ("axisX", "axis_x"),
    ("axisY", "axis_y"),
    ("axisFx", "axis_fx"),
    ("axisFy", "axis_fy"),
    ("gridX", "grid_x"),
    ("gridY", "grid_y"),
    ("gridFx", "grid_fx"),
    ("gridFy", "grid_fy"),
    ("hexgrid", "hexgrid"),
]


def assert_parameter_equivalent(
    expected: dict[str, Any], actual: dict[str, Any], names: dict[str, str]
) -> None:
    assert set(names) == set(expected["params"])
    assert set(names.values()) == set(actual["params"])
    assert len(names.values()) == len(set(names.values()))
    for original, emitted in names.items():
        assert expected["params"][original] == actual["params"][emitted]
    reverse = {emitted: original for original, emitted in names.items()}

    def normalize(value: Any) -> Any:
        if isinstance(value, str) and value.startswith("$"):
            assert value[1:] in reverse
            return "$" + reverse[value[1:]]
        if isinstance(value, list):
            return [normalize(item) for item in value]
        if isinstance(value, dict):
            return {key: normalize(item) for key, item in value.items()}
        return value

    normalized = normalize(
        {key: value for key, value in actual.items() if key != "params"}
    )
    normalized["params"] = {
        reverse[key]: value for key, value in actual["params"].items()
    }
    assert normalized == expected


@pytest.fixture(scope="module")
def ast_python() -> dict[str, str]:
    source = """
import {readFileSync,readdirSync} from 'node:fs';
import {parseSpec} from './packages/vgplot/spec/src/parse-spec.js';
import {astToPython} from './packages/vgplot/spec/src/ast-to-python.js';
const dir='templates/marks/guides';
const output={};
for(const name of readdirSync(dir).filter(name=>name.endsWith('.json'))){
 output[name.slice(0,-5)]=astToPython(parseSpec(JSON.parse(readFileSync(dir+'/'+name,'utf8'))));
}
process.stdout.write(JSON.stringify(output));
"""
    node = os.environ["MOSAIC_NODE"]
    result = subprocess.run(  # ruff: ignore[subprocess-without-shell-equals-true]
        [node, "--input-type=module", "-e", source],
        cwd=ROOT,
        check=False,
        capture_output=True,
        text=True,
        shell=False,
        timeout=30,
    )
    assert result.returncode == 0, result.stderr
    return json.loads(result.stdout)


@pytest.mark.parametrize("name", CASES)
def test_guide_source_and_ast_python_match_wire(
    name: str, ast_python: dict[str, str]
) -> None:
    expected = json.loads((DIRECTORY / f"{name}.json").read_text())
    source = DIRECTORY / f"{name}.py"
    assert runpy.run_path(str(source))["view"].to_dict() == expected
    namespace: dict[str, Any] = {}
    exec(compile(ast_python[name], f"<guide-ast-{name}>", "exec"), namespace)  # ruff: ignore[exec-builtin]
    emitted = namespace["view"].to_dict()
    if name in {"parameter-tick-padding", "vertical-label-position"}:
        original_name = "padding" if name == "parameter-tick-padding" else "position"
        assert_parameter_equivalent(expected, emitted, {original_name: "_param0"})
    else:
        assert emitted == expected
    assert "data" not in expected["plot"][1]


@pytest.mark.parametrize(("wire_name", "name"), NAMES)
def test_guide_public_facade_leaf_identity_and_native_options(
    wire_name: str, name: str
) -> None:
    function = getattr(vg, name)
    assert function is getattr(marks, name)
    assert function is getattr(guides_marks, name)
    assert function.__module__ == "vgplot._generated.marks"
    assert function.__qualname__ == name
    assert pickle.loads(pickle.dumps(function)) is function  # ruff: ignore[suspicious-pickle-usage]
    signature = inspect.signature(function)
    assert signature.parameters["data"].default is None
    assert signature.parameters["stroke"].default is _types.UNSET
    assert function().to_dict() == {"mark": wire_name}
    assert function(stroke=None, opacity=0, aria_hidden=False, title="").to_dict() == {
        "mark": wire_name,
        "stroke": None,
        "opacity": 0,
        "ariaHidden": False,
        "title": "",
    }
    assert function(stroke=_types.UNSET).to_dict() == {"mark": wire_name}
    assert function([{"value": 1}], stroke="red").to_dict() == {
        "mark": wire_name,
        "data": [{"value": 1}],
        "stroke": "red",
    }
    assert function("guide_rows", stroke="red").to_dict() == {
        "mark": wire_name,
        "data": {"from": "guide_rows"},
        "stroke": "red",
    }
    assert function(vg.source("guide_rows"), stroke="red").to_dict() == {
        "mark": wire_name,
        "data": {"from": "guide_rows"},
        "stroke": "red",
    }
    assert function(stroke_width=1, strokeWidth=3).to_dict()["strokeWidth"] == 3
    assert function(custom_option=None).to_dict()["customOption"] is None
    parameter = vg.param(2)
    payload = vg.spec(
        params={"padding": parameter},
        view=vg.plot(function(opacity=parameter)),
    ).to_dict()
    assert payload == {
        "params": {"padding": 2},
        "plot": [{"mark": wire_name, "opacity": "$padding"}],
    }


@pytest.mark.parametrize(
    "actual",
    [
        {"params": {}, "plot": [{"opacity": "$_param0"}]},
        {"params": {"_param0": 2, "extra": 2}, "plot": [{"opacity": "$_param0"}]},
        {"params": {"_param0": 3}, "plot": [{"opacity": "$_param0"}]},
        {"params": {"_param0": 2}, "plot": [{"opacity": "$wrong"}]},
        {"params": {"_param0": 2}, "plot": [{"opacity": "$_param0", "fill": "$wrong"}]},
    ],
)
def test_parameter_equivalence_rejects_incomplete_or_inconsistent_evidence(
    actual: dict[str, Any],
) -> None:
    expected = {"params": {"padding": 2}, "plot": [{"opacity": "$padding"}]}
    with pytest.raises(AssertionError):
        assert_parameter_equivalent(expected, actual, {"padding": "_param0"})
