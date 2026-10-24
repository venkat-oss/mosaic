from __future__ import annotations

import json

import vgplot as vg

x = vg.selection.intersect()


def chart() -> vg.View:
    return vg.plot(
        vg.dot(
            json.loads(
                '[{"x":1,"y":2},{"x":3,"y":4},{"x":5,"y":6},{"x":7,"y":3},{"x":9,"y":8}]'
            ),
            x="x",
            y="y",
        ),
        vg.pan_zoom_x(x=x),
        vg.x_domain([0, 10]),
        vg.y_domain([0, 10]),
        vg.width(360),
        vg.height(260),
    )


view = vg.spec(params={"x": x}, view=vg.hconcat(chart(), chart()))
