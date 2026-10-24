from __future__ import annotations

import vgplot as vg

upstream = vg.selection.intersect()
view = vg.Spec(
    data={
        "table_data": vg.table(
            "SELECT * FROM (VALUES (1,'A'),(2,'B'),(3,'A'),(4,'B'),(5,'A')) AS t(x,category)"
        )
    },
    params={"upstream": upstream},
    view=vg.vconcat(
        vg.menu(bind=upstream, field="category", options=["A", "B"]),
        vg.table_input(
            source="table_data",
            columns=["x", "category"],
            filter_by=upstream,
            row_batch=2,
        ),
    ),
)
