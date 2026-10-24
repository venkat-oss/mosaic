from __future__ import annotations

import inspect
import pickle

import pytest
import vgplot as vg
from vgplot._types import UNSET


@pytest.mark.parametrize(
    ("name", "wire"),
    [
        ("density", "density"),
        ("dense_line", "denseLine"),
        ("contour", "contour"),
        ("heatmap", "heatmap"),
        ("raster", "raster"),
        ("raster_tile", "rasterTile"),
    ],
)
def test_grid_public_factories_keep_omission_keywords_and_identity(
    name: str, wire: str
) -> None:
    factory = getattr(vg, name)
    assert factory(
        "records", x=None, pixel_size=2, pixelSize=3, title=UNSET
    ).to_dict() == {
        "mark": wire,
        "data": {"from": "records"},
        "x": None,
        "pixelSize": 3,
    }
    assert factory.__module__ == "vgplot._generated.marks"
    assert pickle.loads(pickle.dumps(factory)) is factory  # ruff: ignore[suspicious-pickle-usage]
    parameters = inspect.signature(factory).parameters
    assert parameters["data"].default is None
    assert parameters["options"].kind == inspect.Parameter.VAR_KEYWORD
    assert {"width", "height", "pixel_size", "bandwidth", "interpolate"} <= set(
        parameters
    )


def test_grid_specific_options_and_references() -> None:
    resolution = vg.param(5)
    mark = vg.density("records", type_="cell", width=resolution, pad=1)
    assert mark.enc is not None
    assert mark.enc["width"] is resolution
    assert mark.to_dict(param_names={id(resolution): "resolution"}) == {
        "mark": "density",
        "data": {"from": "records"},
        "type": "cell",
        "width": "$resolution",
        "pad": 1,
    }
    assert vg.contour([], thresholds=[0.1, 0.3]).to_dict()["thresholds"] == [0.1, 0.3]
    assert vg.raster_tile([], origin=[0, 0]).to_dict()["origin"] == [0, 0]
    assert vg.dense_line([], normalize=False).to_dict()["normalize"] is False
