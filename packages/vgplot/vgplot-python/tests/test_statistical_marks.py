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
from vgplot._generated import marks, statistical_marks
from vgplot._types import UNSET
from vgplot.plot import Mark

if TYPE_CHECKING:
    from typing import Any

ROOT = Path(os.environ["TEST_SRCDIR"]) / os.environ["TEST_WORKSPACE"]
DIRECTORY = ROOT / "templates" / "marks" / "statistical"
CASES = sorted(path.stem for path in DIRECTORY.glob("*.json"))
FACTORIES = [
    ("hexbin", "hexbin"),
    ("regressionY", "regression_y"),
    ("errorbarX", "errorbar_x"),
    ("errorbarY", "errorbar_y"),
]


@pytest.fixture(scope="module")
def ast_python() -> dict[str, str]:
    source = """
import {readFileSync,readdirSync} from 'node:fs';
import {parseSpec} from './packages/vgplot/spec/src/parse-spec.js';
import {astToPython} from './packages/vgplot/spec/src/ast-to-python.js';
const directory='templates/marks/statistical';
const output={};
for(const name of readdirSync(directory).filter(name=>name.endsWith('.json'))){
 output[name.slice(0,-5)]=astToPython(parseSpec(JSON.parse(readFileSync(directory+'/'+name,'utf8'))));
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
def test_statistical_python_source_and_ast_preserve_wire(
    name: str, ast_python: dict[str, str]
) -> None:
    expected = json.loads((DIRECTORY / f"{name}.json").read_text())
    path = DIRECTORY / f"{name}.py"
    assert runpy.run_path(str(path))["view"].to_dict() == expected
    namespace: dict[str, Any] = {}
    source = ast_python[name] + "\n_payload = view.to_dict()\n"
    exec(compile(source, f"<statistical-ast-{name}>", "exec"), namespace)  # ruff: ignore[exec-builtin]
    actual = namespace["_payload"]
    assert actual == expected


@pytest.mark.parametrize(("wire", "name"), FACTORIES)
def test_statistical_python_factories_preserve_public_identity_and_omission(
    wire: str, name: str
) -> None:
    factory = getattr(vg, name)
    assert factory is getattr(marks, name) is getattr(statistical_marks, name)
    assert factory.__module__ == "vgplot._generated.marks"
    assert factory.__qualname__ == name
    assert pickle.loads(pickle.dumps(factory)) is factory  # ruff: ignore[suspicious-pickle-usage]
    parameters = inspect.signature(factory).parameters
    assert parameters["data"].default is None
    assert parameters["options"].kind == inspect.Parameter.VAR_KEYWORD
    assert all(
        parameter.kind == inspect.Parameter.KEYWORD_ONLY and parameter.default is UNSET
        for key, parameter in parameters.items()
        if key not in {"data", "options"}
    )
    assert isinstance(factory(), Mark)
    assert factory().to_dict() == {"mark": wire}
    assert factory(stroke=UNSET).to_dict() == {"mark": wire}
    assert factory(stroke=None, opacity=0, aria_hidden=False, title="").to_dict() == {
        "mark": wire,
        "stroke": None,
        "opacity": 0,
        "ariaHidden": False,
        "title": "",
    }
    assert factory("records", stroke_width=1, strokeWidth=2).to_dict() == {
        "mark": wire,
        "data": {"from": "records"},
        "strokeWidth": 2,
    }
    assert factory(vg.source("records")).to_dict() == {
        "mark": wire,
        "data": {"from": "records"},
    }
    assert factory([{"x": 1}]).to_dict() == {
        "mark": wire,
        "data": [{"x": 1}],
    }
    assert factory(future_option=None).to_dict()["futureOption"] is None


def test_statistical_python_keeps_native_null_ci_and_reserved_type_keyword() -> None:
    assert vg.hexbin(type_="text", bin_width=0).to_dict() == {
        "mark": "hexbin",
        "type": "text",
        "binWidth": 0,
    }
    assert vg.regression_y(ci=None, precision=0).to_dict() == {
        "mark": "regressionY",
        "ci": None,
        "precision": 0,
    }
    assert vg.errorbar_x(x=None, y=False, marker_end=None).to_dict() == {
        "mark": "errorbarX",
        "x": None,
        "y": False,
        "markerEnd": None,
    }
    assert vg.errorbar_y(x=False, y=None, ci=0).to_dict() == {
        "mark": "errorbarY",
        "x": False,
        "y": None,
        "ci": 0,
    }


@pytest.mark.parametrize("factory", [vg.regression_y, vg.errorbar_x, vg.errorbar_y])
def test_statistical_python_keeps_confidence_parameter_identity(factory: Any) -> None:
    confidence = vg.param(0.95)
    mark = factory("records", x="x", y="y", ci=confidence)
    assert mark.enc["ci"] is confidence
    payload = vg.spec(params={"confidence": confidence}, view=vg.plot(mark)).to_dict()
    assert payload["params"] == {"confidence": 0.95}
    assert payload["plot"][0]["ci"] == "$confidence"
