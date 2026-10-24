from __future__ import annotations

import vgplot as vg

brush = vg.selection.intersect(empty=False)
view = vg.spec(
    data={
        "data_rows": vg.table(
            "SELECT * FROM (VALUES (39.1,181),(39.5,186),(40.3,195)) AS t(bill_length,flipper_length)"
        )
    },
    params={"brush": brush},
    view=vg.plot(
        vg.dot(
            vg.source("data_rows", filter_by=brush), x="bill_length", y="flipper_length"
        )
    ),
)
