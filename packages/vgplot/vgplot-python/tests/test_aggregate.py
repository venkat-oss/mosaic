from __future__ import annotations

import inspect
from typing import Any

import pytest
import vgplot as vg
from vgplot._types import UNSET


@pytest.mark.parametrize(
    ("name", "wire", "arguments"),
    [
        ("argmax", "argmax", ["col", "by"]),
        ("argmin", "argmin", ["col", "by"]),
        ("avg", "avg", ["col"]),
        ("count", "count", ["col"]),
        ("first", "first", ["col"]),
        ("last", "last", ["col"]),
        ("max", "max", ["col"]),
        ("median", "median", ["col"]),
        ("min", "min", ["col"]),
        ("mode", "mode", ["col"]),
        ("product", "product", ["col"]),
        ("quantile", "quantile", ["col", "p"]),
        ("stddev", "stddev", ["col"]),
        ("stddev_pop", "stddevPop", ["col"]),
        ("sum", "sum", ["col"]),
        ("variance", "variance", ["col"]),
        ("var_pop", "varPop", ["col"]),
    ],
)
def test_aggregate_signatures_and_dictionary_options(
    name: str, wire: str, arguments: list[str]
) -> None:
    factory = getattr(vg, name)
    signature = inspect.signature(factory)
    assert list(signature.parameters) == [*arguments, "options"]
    assert signature.parameters["options"].kind is inspect.Parameter.VAR_KEYWORD
    for argument in arguments:
        parameter = signature.parameters[argument]
        assert parameter.kind is inspect.Parameter.POSITIONAL_OR_KEYWORD
        assert parameter.annotation == (
            "TransformArg | UNSET" if name == "count" else "TransformArg"
        )
        assert parameter.default is (
            UNSET if name == "count" else inspect.Parameter.empty
        )
    assert signature.return_annotation == "dict[str, Any]"
    values = [{"sql": "x"}, {"sql": "y"}][: len(arguments)]
    expected: Any = values[0] if len(values) == 1 else values
    actual = factory(*values, distinct=False, raw_option=None)
    assert actual == {wire: expected, "distinct": False, "raw_option": None}
    assert factory(*values, **{wire: "override"}) == {wire: "override"}


def test_count_omission_explicit_null_and_unsupported_python_capabilities() -> None:
    assert vg.count() == {"count": ""}
    null_argument: Any = None
    assert vg.count(null_argument) == {"count": None}
    assert vg.count(UNSET) == {"count": ""}
    for name in ["covariance", "covar_pop", "geomean", "array_agg", "corr", "entropy"]:
        assert not hasattr(vg, name)


def test_aggregate_parameter_and_nested_reference_serialization() -> None:
    field = vg.param("x")
    view = vg.plot(vg.dot("data", x=vg.sum(vg.avg(field), distinct=True)))
    result = vg.Spec(view=view, params={"field": field}).to_dict()
    assert result["plot"][0]["x"] == {
        "sum": {"avg": "$field"},
        "distinct": True,
    }
