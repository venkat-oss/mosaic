from __future__ import annotations

import json

import vgplot as vg

view = vg.spec(
    data={
        "grid_data": vg.table(
            "SELECT * FROM (VALUES (0,0,'A',1),(1,1,'A',2),(2,2,'A',3),(3,3,'A',4),(4,4,'A',5),(0,4,'B',2),(1,3,'B',3),(2,2,'B',4),(3,1,'B',5),(4,0,'B',6)) AS t(x,y,series,value)"
        )
    },
    view=vg.plot(
        vg.raster(
            vg.source("grid_data"),
            x=json.loads('"x"'),
            y=json.loads('"y"'),
            fill=json.loads('"density"'),
            width=json.loads("5"),
            height=json.loads("5"),
            bandwidth=json.loads("8"),
        ),
        vg.x_domain(json.loads("[0,4]")),
        vg.y_domain(json.loads("[0,4]")),
        vg.width(json.loads("180")),
        vg.height(json.loads("160")),
    ),
)
