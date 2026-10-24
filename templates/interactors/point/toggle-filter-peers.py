from __future__ import annotations

import vgplot as vg

selection = vg.selection.intersect()
view = vg.spec(
    data={
        "point_rows": vg.table(
            "SELECT * FROM (VALUES (1,2,'A','red'),(3,4,'B','blue'),(5,6,'A','red')) AS t(x,y,series,category)"
        )
    },
    params={"selection": selection},
    view=vg.plot(
        vg.dot(vg.source("point_rows"), x="x", y="y", z="series", fill="category"),
        vg.toggle(bind=selection, channels=["x"], peers=False),
        vg.highlight(by=selection, opacity=0.15),
        vg.width(420),
        vg.height(260),
    ),
)
