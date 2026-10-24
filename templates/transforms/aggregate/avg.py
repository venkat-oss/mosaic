from __future__ import annotations

import vgplot as vg

view = vg.spec(
    data={
        "aggregate_data": vg.table(
            "SELECT category, x, x * 2 AS y, 'v' || x::VARCHAR AS label FROM (VALUES ('A',1),('A',2),('A',2),('A',3),('A',4),('A',5),('B',2),('B',3),('B',3),('B',4),('B',5),('B',6)) AS t(category,x)"
        )
    },
    view=vg.plot(vg.bar_y("aggregate_data", x="category", y=vg.avg("x"))),
)
