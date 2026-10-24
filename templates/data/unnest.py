from __future__ import annotations

import vgplot as vg

view = vg.Spec(
    data={"nested_rows": vg.table("SELECT [1,2,3] AS items, 1 AS y")},
    view=vg.plot(vg.dot(vg.source("nested_rows", unnest=["items"]), x="items", y="y")),
)
