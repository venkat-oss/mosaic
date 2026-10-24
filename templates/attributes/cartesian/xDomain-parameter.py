from __future__ import annotations

import json

import vgplot as vg

domain = vg.param(json.loads("[0,4]"))
view = vg.spec(
    params={"domain": domain},
    view=vg.plot(
        vg.dot(
            json.loads(
                '[{"x":1,"y":2,"category":"A"},{"x":2,"y":1,"category":"B"},{"x":3,"y":3,"category":"C"}]'
            ),
            x=json.loads('"x"'),
            y=json.loads('"y"'),
            r=json.loads("4"),
        ),
        vg.width(json.loads("300")),
        vg.height(json.loads("200")),
        vg.x_domain(domain),
    ),
)
