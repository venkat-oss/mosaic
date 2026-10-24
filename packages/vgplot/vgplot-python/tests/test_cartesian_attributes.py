from __future__ import annotations

import importlib
import inspect
import pickle
import subprocess
import sys
from typing import Any

import pytest
import vgplot as vg

SUFFIXES = [
    "scale",
    "domain",
    "range",
    "nice",
    "inset",
    "clamp",
    "round",
    "align",
    "padding",
    "padding_inner",
    "padding_outer",
    "axis",
    "ticks",
    "tick_size",
    "tick_spacing",
    "tick_padding",
    "tick_format",
    "tick_rotate",
    "grid",
    "line",
    "label",
    "label_anchor",
    "label_arrow",
    "label_offset",
    "font_variant",
    "aria_label",
    "aria_description",
    "percent",
    "reverse",
    "zero",
    "exponent",
    "base",
    "constant",
]
TRUE_DEFAULTS = {
    "nice",
    "clamp",
    "round",
    "axis",
    "grid",
    "line",
    "percent",
    "reverse",
    "zero",
}
NAMES = [
    (axis + "_" + suffix, suffix in TRUE_DEFAULTS)
    for axis in ["x", "y"]
    for suffix in SUFFIXES
]
NAMES.extend(
    (name, False)
    for name in [
        "x_inset_left",
        "x_inset_right",
        "y_inset_top",
        "y_inset_bottom",
        "xy_domain",
    ]
)


@pytest.mark.parametrize("name,default_true", NAMES)
def test_public_signature_null_parameter_identity_and_historical_pickle(
    name: str, default_true: bool
) -> None:
    factory = getattr(vg, name)
    key = name.split("_", maxsplit=1)[0] + "".join(
        part.title() for part in name.split("_")[1:]
    )
    signature = inspect.signature(factory)
    assert list(signature.parameters) == ["value"]
    parameter = signature.parameters["value"]
    assert parameter.kind is inspect.Parameter.POSITIONAL_OR_KEYWORD
    assert parameter.default is (True if default_true else inspect.Parameter.empty)
    assert parameter.annotation == "AttrValue"
    assert signature.return_annotation == "Directive"
    assert factory.__qualname__ == name
    assert factory.__module__ == "vgplot._generated.attributes"
    if default_true:
        assert factory().to_kv() == (key, True)
    else:
        with pytest.raises(TypeError):
            factory()
    assert factory(None).to_kv() == (key, None)
    assert factory(False).to_kv() == (key, False)
    parameter_value = vg.param([0, 4])
    directive = factory(parameter_value)
    assert isinstance(directive, importlib.import_module("vgplot.plot").Directive)
    assert directive.value is parameter_value
    assert vg.Spec(
        params={"domain": parameter_value}, view=vg.plot(directive)
    ).to_dict() == {"params": {"domain": [0, 4]}, "plot": [], key: "$domain"}
    assert pickle.loads(f"cvgplot._generated.attributes\n{name}\n.".encode()) is factory  # ruff: ignore[suspicious-pickle-usage]
    assert vg.__all__.count(name) == 1


def test_paired_domain_is_one_directive_and_native_authoring_retains_unsupported_wire_values() -> (
    None
):
    value: list[int] = [0, 4]
    directive = vg.xy_domain(value)
    assert directive.value is value
    assert directive.to_kv() == ("xyDomain", value)
    assert vg.plot(
        directive, vg.x_grid(None), vg.y_grid(4), vg.x_label_anchor("top")
    ).to_dict() == {
        "plot": [],
        "xyDomain": [0, 4],
        "xGrid": None,
        "yGrid": 4,
        "xLabelAnchor": "top",
    }
    assert vg.plot(vg.x_domain([1, 2]), vg.x_domain([3, 4])).to_dict()["xDomain"] == [
        3,
        4,
    ]


@pytest.mark.parametrize("name", ["x_label_arrow", "y_label_arrow"])
def test_indirect_boolean_label_arrow_remains_required(name: str) -> None:
    factory: Any = getattr(vg, name)
    with pytest.raises(TypeError):
        factory()
    assert factory(True).value is True


def test_generated_attribute_facade_supports_cold_import_in_either_order() -> None:
    for names in [
        ["vgplot._generated.cartesian_attributes", "vgplot"],
        ["vgplot", "vgplot._generated.cartesian_attributes"],
    ]:
        subprocess.run(  # ruff: ignore[subprocess-without-shell-equals-true]
            [
                sys.executable,
                "-c",
                "import importlib; "
                + "; ".join(f"importlib.import_module({name!r})" for name in names)
                + "; import vgplot as vg; from vgplot._generated import attributes; assert attributes.xy_domain is vg.xy_domain; assert vg.x_scale.__module__ == 'vgplot._generated.attributes'",
            ],
            check=True,
        )
