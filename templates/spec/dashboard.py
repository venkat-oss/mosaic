from __future__ import annotations

import vgplot as vg

dashboard_rows = vg.table(
    "SELECT * FROM (VALUES (1,10,'A'),(2,12,'B'),(3,15,'A'),(4,18,'B'),(5,14,'C'),(6,20,'C')) AS t(day,value,category)"
)
brush = vg.selection.crossfilter()
offset = vg.param(0)

view = vg.spec(
    data={"dashboard_rows": dashboard_rows},
    params={"brush": brush, "offset": offset},
    config={"extensions": []},
    plot_defaults={"width": 360, "height": 220},
    view=vg.vconcat(
        vg.slider(bind=offset, label="Vertical offset", min=-5, max=5, step=1),
        vg.hconcat(
            vg.plot(
                vg.dot(
                    vg.source("dashboard_rows", filter_by=brush),
                    x="day",
                    y=vg.sql("value + $offset"),
                    fill="category",
                ),
                vg.interval_x(bind=brush),
                vg.color_legend(),
                vg.x_label("Day"),
                vg.y_label("Value + offset"),
            ),
            vg.plot(
                vg.bar_y(
                    vg.source("dashboard_rows", filter_by=brush),
                    x="category",
                    y=vg.count(),
                    fill="category",
                ),
                vg.x_label("Category"),
                vg.y_label("Selected rows"),
            ),
        ),
        vg.table_input(
            "dashboard_rows",
            columns=["day", "value", "category"],
            filter_by=brush,
            row_batch=10,
        ),
    ),
)
