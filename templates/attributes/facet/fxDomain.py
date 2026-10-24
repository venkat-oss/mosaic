from __future__ import annotations

import json

import vgplot as vg

view = vg.spec(
    view=vg.plot(
        vg.dot(
            json.loads(
                '[{"x":1,"y":1,"column":1,"row":10},{"x":2,"y":3,"column":2,"row":10},{"x":3,"y":2,"column":1,"row":20},{"x":4,"y":4,"column":2,"row":20}]'
            ),
            x=json.loads('"x"'),
            y=json.loads('"y"'),
            r=json.loads("4"),
            fx=json.loads('"column"'),
            fy=json.loads('"row"'),
        ),
        vg.width(json.loads("480")),
        vg.height(json.loads("360")),
        vg.fx_domain(json.loads("[2,1,3]")),
        vg.fy_domain(json.loads("[20,10]")),
    ),
)
