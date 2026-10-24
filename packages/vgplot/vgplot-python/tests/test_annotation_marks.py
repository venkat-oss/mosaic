from __future__ import annotations

import inspect
import pickle

import pytest
import vgplot as vg
from vgplot._types import UNSET
from vgplot.plot import Mark


@pytest.mark.parametrize(
    ("name", "wire"),
    [
        ("text", "text"),
        ("text_x", "textX"),
        ("text_y", "textY"),
        ("image", "image"),
        ("vector", "vector"),
        ("vector_x", "vectorX"),
        ("vector_y", "vectorY"),
        ("spike", "spike"),
        ("waffle_x", "waffleX"),
        ("waffle_y", "waffleY"),
    ],
)
def test_annotation_public_factories_keep_keywords_and_pickle_identity(
    name: str, wire: str
) -> None:
    factory = getattr(vg, name)
    mark = factory("records", x=None, stroke_width=1, strokeWidth=2, title=UNSET)
    assert isinstance(mark, Mark)
    assert mark.to_dict() == {
        "mark": wire,
        "data": {"from": "records"},
        "x": None,
        "strokeWidth": 2,
    }
    assert factory.__module__ == "vgplot._generated.marks"
    assert pickle.loads(pickle.dumps(factory)) is factory  # ruff: ignore[suspicious-pickle-usage]
    parameters = inspect.signature(factory).parameters
    assert parameters["data"].default is None
    assert parameters["options"].kind == inspect.Parameter.VAR_KEYWORD
    assert all(
        value.kind == inspect.Parameter.KEYWORD_ONLY and value.default is UNSET
        for key, value in parameters.items()
        if key not in {"data", "options"}
    )


def test_annotation_python_vector_x_keeps_correct_wire_name() -> None:
    assert vg.vector_x([], length=12, rotate=90, anchor="start").to_dict() == {
        "mark": "vectorX",
        "data": [],
        "length": 12,
        "rotate": 90,
        "anchor": "start",
    }


def test_annotation_optional_data_and_open_native_options() -> None:
    assert vg.text(text="hello", future_style=7).to_dict() == {
        "mark": "text",
        "text": "hello",
        "futureStyle": 7,
    }
    assert vg.image([], src="https://example.com/image.png").to_dict()["data"] == []


def test_annotation_reference_values_retain_identity() -> None:
    angle = vg.param(90)
    mark = vg.vector("records", rotate=angle)
    assert mark.enc is not None
    assert mark.enc["rotate"] is angle
    assert mark.to_dict(param_names={id(angle): "angle"})["rotate"] == "$angle"


def test_annotation_inherited_and_aliased_signature_fields() -> None:
    assert {
        "text",
        "font_size",
        "text_anchor",
        "line_anchor",
        "interval",
    } <= inspect.signature(vg.text_x).parameters.keys()
    assert {
        "src",
        "width",
        "height",
        "preserve_aspect_ratio",
        "image_rendering",
        "cross_origin",
    } <= inspect.signature(vg.image).parameters.keys()
    assert {
        "x1",
        "x2",
        "inset_left",
        "multiple",
        "unit",
        "gap",
        "round",
    } <= inspect.signature(vg.waffle_x).parameters.keys()
    assert {
        "y1",
        "y2",
        "inset_top",
        "multiple",
        "unit",
        "gap",
        "round",
    } <= inspect.signature(vg.waffle_y).parameters.keys()
