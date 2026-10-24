from __future__ import annotations

import importlib
import pickle
from typing import Any

import pytest
import vgplot as vg
from vgplot._types import UNSET
from vgplot.plot import Mark


@pytest.mark.parametrize(
    "source",
    ["records", None, [], {"from": "records", "filterBy": "old", "optimize": True}],
)
def test_mark_data_options_relocation_preserves_none_falsy_priority_and_sources(
    source: Any,
) -> None:
    enc = {"filter_by": None, "optimize": False, "stroke_width": 1, "strokeWidth": 2}
    original = dict(enc)
    mark = Mark("dot", data=source, enc=enc)
    result = mark.to_dict()
    assert enc == original
    assert result["strokeWidth"] == 2
    if isinstance(source, (str, dict)):
        assert result["data"] == {
            "from": "records",
            "filterBy": None,
            "optimize": False,
        }
        assert "filterBy" not in result
        assert "optimize" not in result
    else:
        assert result["filterBy"] is None
        assert result["optimize"] is False
        assert ("data" in result) is (source is not None)
    if isinstance(source, dict):
        assert source == {"from": "records", "filterBy": "old", "optimize": True}


def test_camel_source_alias_is_distinct_from_the_relocated_snake_option() -> None:
    result = vg.mark("dot", "records", filter_by="snake", filterBy="camel").to_dict()
    assert result == {
        "mark": "dot",
        "data": {"from": "records", "filterBy": "snake"},
        "filterBy": "camel",
    }


def test_generic_mark_keeps_explicit_unset_while_concrete_wrapper_omits_it() -> None:
    assert vg.mark("dot", "records", x=UNSET).to_dict()["x"] is UNSET
    assert "x" not in vg.dot("records", x=UNSET).to_dict()
    assert (
        vg.dot("records", stroke_width=1, strokeWidth=2).to_dict()["strokeWidth"] == 2
    )


def test_channels_preserve_unmodified_keys_and_values() -> None:
    value: Any = {"nested": [1, None]}
    result = vg.channels(custom_field=value)
    assert result == {"custom_field": {"nested": [1, None]}}
    assert result["custom_field"] is value
    assert vg.channels() == {}


def test_generic_directive_retains_value_identity_and_camelizes_only_the_key() -> None:
    value: Any = {"nested_key": None}
    directive = vg.directive("x_domain", value)
    key, actual = directive.to_kv()
    assert key == "xDomain"
    assert actual is value


@pytest.mark.parametrize(
    ("name", "module"),
    [
        ("channels", "vgplot.encodings"),
        ("mark", "vgplot.plot"),
        ("directive", "vgplot.plot"),
    ],
)
def test_generic_authoring_helpers_preserve_deep_aliases_and_pickle_identity(
    name: str, module: str
) -> None:
    factory = getattr(vg, name)
    assert factory is getattr(importlib.import_module(module), name)
    assert factory.__module__ == module
    assert pickle.loads(pickle.dumps(factory)) is factory  # ruff: ignore[suspicious-pickle-usage]


def test_generic_helper_annotation_reflection_preserves_its_historical_boundary() -> (
    None
):
    from typing import get_type_hints

    from vgplot.plot import Directive

    assert get_type_hints(vg.channels) == {"kwargs": str, "return": dict[str, str]}
    assert get_type_hints(vg.directive) == {
        "key": str,
        "value": Any,
        "return": Directive,
    }
    with pytest.raises(NameError, match="MarkData"):
        get_type_hints(vg.mark)
