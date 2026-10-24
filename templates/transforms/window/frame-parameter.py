from __future__ import annotations

import vgplot as vg

frame = vg.param([1, 0])
view = vg.spec(
    data={
        "window_data": vg.table(
            "SELECT id, x, y, category, TIMESTAMP '2024-01-01' + id * INTERVAL 1 MICROSECOND AS time FROM (VALUES (1, 1, 10, 'A'), (2, 2, 20, 'A'), (3, 2, 30, 'A'), (4, 3, 40, 'A')) AS t(id, x, y, category)"
        )
    },
    params={"frame": frame},
    view=vg.plot(
        vg.dot(
            "window_data",
            x="id",
            y=vg.sum("y", orderby="id", partitionby="category", rows=frame),
            r=4,
        )
    ),
)
