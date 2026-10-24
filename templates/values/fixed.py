from __future__ import annotations

import vgplot as vg

view = vg.spec(
    data={"value_data": vg.table("SELECT * FROM (VALUES (1,2),(2,1),(3,3)) AS t(x,y)")},
    view=vg.plot(vg.dot("value_data", x="x", y="y"), vg.directive("xDomain", "Fixed")),
)
