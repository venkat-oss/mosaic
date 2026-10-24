from __future__ import annotations

import json

import vgplot as vg

view = vg.spec(
    view=vg.plot(
        vg.dot(
            json.loads(
                '[{"lon":-122.3,"lat":47.6},{"lon":-87.6,"lat":41.9},{"lon":-74,"lat":40.7}]'
            ),
            x=json.loads('"lon"'),
            y=json.loads('"lat"'),
            r=json.loads("4"),
        ),
        vg.width(json.loads("300")),
        vg.height(json.loads("200")),
        vg.projection_type(json.loads('"mercator"')),
    ),
)
