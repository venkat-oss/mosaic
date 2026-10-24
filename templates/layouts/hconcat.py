from __future__ import annotations

import vgplot as vg

radius = vg.param(4)


def chart() -> vg.View:
    return vg.plot(vg.dot("layout_data", x="x", y="y", r=radius))


view = vg.spec(
    data={
        "layout_data": vg.table(
            "SELECT * FROM (VALUES (1, 2, 'A'), (2, 1, 'B'), (3, 3, 'A')) AS t(x, y, category)"
        )
    },
    params={"radius": radius},
    plot_defaults={"width": 180, "height": 140},
    view=vg.hconcat(chart(), vg.hspace(12), vg.vconcat(chart(), vg.vspace(8), chart())),
)
