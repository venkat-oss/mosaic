from __future__ import annotations

import vgplot as vg

upstream = vg.selection.single()
brush = vg.selection.crossfilter(empty=False, include=[upstream])
view = vg.spec(
    data={
        "param_data": vg.table(
            "SELECT * FROM (VALUES (1,2,'A'),(2,1,'B'),(3,3,'A')) AS t(x,y,category)"
        )
    },
    params={"upstream": upstream, "brush": brush},
    view=vg.vconcat(
        vg.plot(
            vg.dot(vg.source("param_data", filter_by=brush), x="x", y="y"),
            vg.toggle_x(bind=brush),
        ),
        vg.plot(vg.dot(vg.source("param_data", filter_by=brush), x="x", y="y")),
    ),
)
