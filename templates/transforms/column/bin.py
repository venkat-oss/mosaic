from __future__ import annotations

import vgplot as vg

view = vg.spec(
    data={
        "column_data": vg.table(
            "SELECT x, y, DATE '2024-01-01' + CAST(x AS INTEGER) AS time FROM (VALUES (1,2),(2,1),(3,3)) AS t(x,y)"
        )
    },
    view=vg.plot(vg.dot("column_data", x=vg.bin("x", steps=4), y="y")),
)
