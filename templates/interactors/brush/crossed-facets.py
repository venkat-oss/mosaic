from __future__ import annotations

import vgplot as vg

selection = vg.selection.crossfilter()
view = vg.spec(
    data={
        "brush_rows": vg.table(
            "SELECT * FROM (VALUES (1,2,'A','U'),(3,4,'B','V'),(5,6,'A','U')) AS t(x,y,category,bucket)"
        )
    },
    params={"selection": selection},
    view=vg.hconcat(
        vg.plot(
            vg.dot(
                vg.source("brush_rows", filter_by=selection),
                x="x",
                y="y",
                z="category",
                fill="category",
                fx="category",
                fy="bucket",
            ),
            vg.interval_x(bind=selection),
            vg.width(360),
            vg.height(260),
        ),
        vg.plot(
            vg.dot(
                vg.source("brush_rows", filter_by=selection),
                x="x",
                y="y",
                fill="category",
            ),
            vg.width(360),
            vg.height(260),
        ),
    ),
)
