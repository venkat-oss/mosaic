from __future__ import annotations

import json

import vgplot as vg

view = vg.spec(
    data={
        "connected_data": vg.table(
            "SELECT * FROM (VALUES (0,2,1,3,'A'),(1,4,2,1,'A'),(2,1,3,4,'A'),(0,3,1,2,'B'),(1,1,2,4,'B'),(2,4,3,1,'B')) AS t(x,y,u,v,series)"
        )
    },
    view=vg.plot(
        vg.line(
            vg.source("connected_data"),
            x=json.loads('"x"'),
            y=json.loads('"y"'),
            curve=json.loads('"linear"'),
            z=json.loads('"series"'),
            stroke=json.loads('"series"'),
        ),
        vg.width(json.loads("360")),
        vg.height(json.loads("220")),
    ),
)
