from __future__ import annotations

import vgplot as vg

view = vg.Spec(
    data={
        "param_data": vg.table(
            "SELECT * FROM (VALUES (1,2,'A'),(2,1,'B'),(3,3,'A')) AS t(x,y,category)"
        )
    },
    view=vg.plot(vg.dot("param_data", x="x", y="y", r=vg.param(5))),
)
