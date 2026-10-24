from __future__ import annotations

import inspect
import pickle

import pytest
import vgplot as vg
from vgplot._generated import marks, spatial_marks

CASES = [
    ("geo", "geo"),
    ("sphere", "sphere"),
    ("graticule", "graticule"),
    ("voronoi", "voronoi"),
    ("voronoiMesh", "voronoi_mesh"),
    ("delaunayLink", "delaunay_link"),
    ("delaunayMesh", "delaunay_mesh"),
    ("hull", "hull"),
]


@pytest.mark.parametrize(("wire", "name"), CASES)
def test_owned_spatial_factories_preserve_public_identity_and_serialization(
    wire: str,
    name: str,
) -> None:
    factory = getattr(vg, name)
    assert factory is getattr(marks, name) is getattr(spatial_marks, name)
    assert factory.__module__ == "vgplot._generated.marks"
    assert pickle.loads(pickle.dumps(factory)) is factory  # ruff: ignore[suspicious-pickle-usage]
    assert inspect.signature(factory).parameters["data"].default is None
    assert vg.plot(factory(None, stroke=None)).to_dict() == {
        "plot": [{"mark": wire, "stroke": None}],
    }
    assert vg.plot(factory([], stroke_width=1, strokeWidth=2)).to_dict() == {
        "plot": [{"mark": wire, "data": [], "strokeWidth": 2}],
    }


def test_geo_geometry_transform_and_inline_geometry_keep_public_wire_values() -> None:
    point = {"type": "Point", "coordinates": [0, 0]}
    assert vg.plot(vg.geo([{}], geometry=[point])).to_dict() == {
        "plot": [{"mark": "geo", "data": [{}], "geometry": [point]}],
    }
    assert vg.plot(vg.geo("records", geometry=vg.geojson("shape"))).to_dict() == {
        "plot": [
            {
                "mark": "geo",
                "data": {"from": "records"},
                "geometry": {"geojson": "shape"},
            }
        ],
    }


def test_sphere_and_graticule_keep_optional_python_data_despite_strict_wire_boundary() -> (
    None
):
    for factory in [vg.sphere, vg.graticule]:
        assert "geometry" not in inspect.signature(factory).parameters
        assert factory(stroke="steelblue").to_dict() == {
            "mark": factory.__name__,
            "stroke": "steelblue",
        }
