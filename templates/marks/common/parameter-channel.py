from __future__ import annotations

import vgplot as vg

fill = vg.param("steelblue")
view = vg.Spec(
    data={
        "common_data": vg.table(
            "SELECT * FROM (VALUES (1, 2, 'A', DATE '2024-01-01'), (1, 1, 'B', DATE '2024-01-01'), (2, 1, 'A', DATE '2024-01-02'), (2, 2, 'B', DATE '2024-01-02'), (3, 3, 'A', DATE '2024-01-03'), (3, 1, 'B', DATE '2024-01-03')) AS t(x, y, category, time)"
        )
    },
    params={"fill": fill},
    view=vg.plot(
        vg.dot(vg.source("common_data"), x="x", y="y", fill=fill), vg.width(360)
    ),
)
