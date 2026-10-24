from __future__ import annotations

import json

import vgplot as vg

range = vg.param(json.loads("[2,14]"))
view = vg.spec(
    params={"range": range},
    view=vg.plot(
        vg.dot(
            json.loads(
                '[{"x":1,"y":1,"radius":1,"magnitude":2},{"x":2,"y":2,"radius":4,"magnitude":5},{"x":3,"y":1,"radius":9,"magnitude":8}]'
            ),
            x=json.loads('"x"'),
            y=json.loads('"y"'),
            r=json.loads('"radius"'),
        ),
        vg.width(json.loads("300")),
        vg.height(json.loads("180")),
        vg.r_scale(json.loads('"linear"')),
        vg.r_domain(json.loads("[0,10]")),
        vg.r_range(range),
    ),
)
