from __future__ import annotations

import inspect
from typing import Any

import pytest
import vgplot as vg
from vgplot import encodings


@pytest.mark.parametrize(
    ("name", "wire"),
    [
        ("bin", "bin"),
        ("column", "column"),
        ("date_month", "dateMonth"),
        ("date_month_day", "dateMonthDay"),
        ("date_day", "dateDay"),
        ("centroid", "centroid"),
        ("centroid_x", "centroidX"),
        ("centroid_y", "centroidY"),
        ("geojson", "geojson"),
    ],
)
def test_column_factories_keep_signatures_arguments_and_raw_options(
    name: str, wire: str
) -> None:
    factory = getattr(vg, name)
    signature = inspect.signature(factory)
    assert list(signature.parameters) == ["col", "options"]
    assert signature.parameters["col"].kind is inspect.Parameter.POSITIONAL_OR_KEYWORD
    assert signature.parameters["col"].default is inspect.Parameter.empty
    assert signature.parameters["col"].annotation == "TransformArg"
    assert signature.parameters["options"].kind is inspect.Parameter.VAR_KEYWORD
    assert signature.return_annotation == "dict[str, Any]"
    argument = {"sql": "x + 1"}
    actual = factory(argument, raw_option=None, mixedCase=False)
    assert actual == {wire: argument, "raw_option": None, "mixedCase": False}
    assert actual[wire] is argument
    assert factory("x", **{wire: "replacement"}) == {wire: "replacement"}
    assert factory(None) == {wire: None}


def test_sql_adapter_keeps_signature_identity_and_dictionary_behavior() -> None:
    assert vg.sql is encodings.sql
    assert encodings.Any is Any
    assert vg.sql.__module__ == "vgplot.encodings"
    assert vg.sql.__qualname__ == "sql"
    signature = inspect.signature(vg.sql)
    assert list(signature.parameters) == ["expr"]
    assert signature.parameters["expr"].annotation == "str"
    assert signature.return_annotation == "dict[str, Any]"
    assert vg.sql("$offset + x") == {"sql": "$offset + x"}
    assert vg.sql("") == {"sql": ""}
    nonstring: Any = None
    assert vg.sql(nonstring) == {"sql": None}


def test_column_helpers_resolve_named_parameter_values_at_spec_serialization() -> None:
    lower = vg.param("x")
    view = vg.plot(
        vg.dot("data", x=vg.bin(lower, step=2, nice=False)),
    )
    spec = vg.Spec(view=view, params={"lower": lower}).to_dict()
    assert spec["params"] == {"lower": "x"}
    assert spec["plot"][0]["x"] == {"bin": "$lower", "step": 2, "nice": False}
