from __future__ import annotations

import importlib
import inspect
import pickle
import subprocess
import sys

import pytest
import vgplot as vg

SUFFIXES = [
    "domain",
    "range",
    "inset",
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
    "label_offset",
    "font_variant",
    "aria_label",
    "aria_description",
    "reverse",
]
TRUE_DEFAULTS = {"round", "axis", "grid", "line", "reverse"}
NAMES = [
    (axis + "_" + suffix, suffix in TRUE_DEFAULTS)
    for axis in ["fx", "fy"]
    for suffix in SUFFIXES
]
NAMES.extend(
    (name, False)
    for name in [
        "fx_inset_left",
        "fx_inset_right",
        "fy_inset_top",
        "fy_inset_bottom",
        "facet_margin",
        "facet_margin_top",
        "facet_margin_bottom",
        "facet_margin_left",
        "facet_margin_right",
        "facet_label",
    ]
)
NAMES.append(("facet_grid", True))


@pytest.mark.parametrize("name,default_true", NAMES)
def test_signature_defaults_null_identity_and_historical_pickle(
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
    parameter_value = vg.param([1, 2])
    directive = factory(parameter_value)
    assert isinstance(directive, importlib.import_module("vgplot.plot").Directive)
    assert directive.value is parameter_value
    assert vg.Spec(
        params={"setting": parameter_value}, view=vg.plot(directive)
    ).to_dict() == {"params": {"setting": [1, 2]}, "plot": [], key: "$setting"}
    assert pickle.loads(f"cvgplot._generated.attributes\n{name}\n.".encode()) is factory  # ruff: ignore[suspicious-pickle-usage]
    assert vg.__all__.count(name) == 1


def test_facet_authoring_preserves_explicit_native_grid_values_and_last_wins_order() -> (
    None
):
    assert vg.plot(vg.fx_grid(None), vg.fy_grid(4), vg.fy_inset(60)).to_dict() == {
        "plot": [],
        "fxGrid": None,
        "fyGrid": 4,
        "fyInset": 60,
    }
    assert vg.plot(vg.fx_domain([1, 2]), vg.fx_domain([2, 1, 3])).to_dict()[
        "fxDomain"
    ] == [2, 1, 3]
    assert not hasattr(vg, "fx_scale")
    assert not hasattr(vg, "fy_scale")


def test_generated_facet_module_supports_both_cold_import_orders() -> None:
    for names in [
        ["vgplot._generated.facet_attributes", "vgplot"],
        ["vgplot", "vgplot._generated.facet_attributes"],
    ]:
        subprocess.run(  # ruff: ignore[subprocess-without-shell-equals-true]
            [
                sys.executable,
                "-c",
                "import importlib; "
                + "; ".join(f"importlib.import_module({name!r})" for name in names)
                + "; import vgplot as vg; from vgplot._generated import attributes; assert attributes.fy_inset is vg.fy_inset; assert vg.fx_domain.__module__ == 'vgplot._generated.attributes'",
            ],
            check=True,
        )
