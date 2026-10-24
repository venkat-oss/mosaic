from __future__ import annotations

import importlib
import inspect
import pickle

import pytest
import vgplot as vg
from vgplot._generated import attributes

CASES = [
    ("r_scale", "rScale", False),
    ("r_domain", "rDomain", False),
    ("r_range", "rRange", False),
    ("r_clamp", "rClamp", False),
    ("r_nice", "rNice", True),
    ("r_label", "rLabel", False),
    ("r_percent", "rPercent", True),
    ("r_zero", "rZero", True),
    ("r_exponent", "rExponent", False),
    ("r_base", "rBase", False),
    ("r_constant", "rConstant", False),
    ("length_scale", "lengthScale", False),
    ("length_domain", "lengthDomain", False),
    ("length_range", "lengthRange", False),
    ("length_clamp", "lengthClamp", False),
    ("length_nice", "lengthNice", True),
    ("length_percent", "lengthPercent", True),
    ("length_zero", "lengthZero", True),
    ("length_exponent", "lengthExponent", False),
    ("length_base", "lengthBase", False),
    ("length_constant", "lengthConstant", False),
    ("projection_type", "projectionType", False),
    ("projection_domain", "projectionDomain", False),
    ("projection_rotate", "projectionRotate", False),
    ("projection_parallels", "projectionParallels", False),
    ("projection_precision", "projectionPrecision", False),
    ("projection_clip", "projectionClip", True),
    ("projection_inset", "projectionInset", False),
    ("projection_inset_top", "projectionInsetTop", False),
    ("projection_inset_right", "projectionInsetRight", False),
    ("projection_inset_bottom", "projectionInsetBottom", False),
    ("projection_inset_left", "projectionInsetLeft", False),
]


@pytest.mark.parametrize(("name", "wire", "boolean_default"), CASES)
def test_attribute_signature_identity_and_explicit_values(
    name: str, wire: str, boolean_default: bool
) -> None:
    factory = getattr(vg, name)
    module = importlib.import_module(
        "vgplot._generated."
        + (
            "projection_attributes"
            if wire.startswith("projection")
            else "size_attributes"
        )
    )
    assert factory is getattr(attributes, name)
    assert factory is getattr(module, name)
    assert factory.__module__ == "vgplot._generated.attributes"
    assert factory.__qualname__ == name
    assert pickle.loads(pickle.dumps(factory)) is factory  # ruff: ignore[suspicious-pickle-usage]
    signature = inspect.signature(factory)
    assert list(signature.parameters) == ["value"]
    assert signature.parameters["value"].annotation == "AttrValue"
    assert signature.return_annotation == "Directive"
    if boolean_default:
        assert signature.parameters["value"].default is True
        assert factory().to_kv() == (wire, True)
    else:
        assert signature.parameters["value"].default is inspect.Parameter.empty
        with pytest.raises(TypeError):
            factory()
    for value in [None, False, 0, [0, 1]]:
        assert factory(value).to_kv() == (wire, value)
