from __future__ import annotations

import json

import vgplot as vg

view = vg.spec(
    view=vg.plot(
        vg.geo(
            json.loads(
                '[{"geometry":{"type":"Polygon","coordinates":[[[-25,-10],[-25,10],[-5,10],[-5,-10],[-25,-10]]]},"name":"West"},{"geometry":{"type":"Polygon","coordinates":[[[5,-10],[5,10],[25,10],[25,-10],[5,-10]]]},"name":"East"}]'
            ),
            stroke=json.loads('"steelblue"'),
            geometry=json.loads('"geometry"'),
            r=json.loads("4"),
        ),
        vg.width(json.loads("420")),
        vg.height(json.loads("260")),
        vg.projection_type(json.loads('"equirectangular"')),
        vg.projection_domain(json.loads('{"type":"Sphere"}')),
    ),
)
