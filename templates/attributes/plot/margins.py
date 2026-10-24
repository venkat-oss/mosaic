from __future__ import annotations

import json

import vgplot as vg

view = vg.spec(
    view=vg.plot(
        vg.dot(
            json.loads('[{"x":1,"y":2},{"x":2,"y":1},{"x":3,"y":3}]'), x="x", y="y", r=4
        ),
        vg.width(280),
        vg.height(180),
        vg.margins(**json.loads('{"top":20,"right":12,"bottom":26,"left":34}')),
    )
)
