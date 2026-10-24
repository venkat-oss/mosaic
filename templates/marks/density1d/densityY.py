from __future__ import annotations

import json

import vgplot as vg

view = vg.spec(
    data={
        "density_data": vg.table(
            "SELECT * FROM (VALUES (0,'A',1),(1,'A',2),(2,'A',3),(3,'A',2),(4,'A',1),(0,'B',2),(1,'B',1),(2,'B',2),(3,'B',1),(4,'B',2)) AS t(value,series,weight)"
        )
    },
    view=vg.plot(
        vg.density_y(
            vg.source("density_data"),
            x=json.loads('"value"'),
            fill=json.loads('"series"'),
            bins=json.loads("32"),
            normalize=json.loads("false"),
            bandwidth=json.loads("8"),
        ),
        vg.x_domain(json.loads("[0,4]")),
        vg.width(json.loads("360")),
        vg.height(json.loads("220")),
    ),
)
