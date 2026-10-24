from __future__ import annotations

import json

import vgplot as vg

view = vg.spec(
    view=vg.plot(
        vg.dot(
            json.loads(
                '[{"t":1,"u":2,"v":3,"w":4,"category":"A","row":"first","keep":true,"radius":3},{"t":3,"u":4,"v":5,"w":6,"category":"B","row":"first","keep":false,"radius":0},{"t":5,"u":6,"v":2,"w":3,"category":"A","row":"second","keep":true,"radius":-1},{"t":7,"u":8,"v":4,"w":5,"category":"B","row":"second","keep":false,"radius":4}]'
            ),
            x=json.loads('"t"'),
            y=json.loads('"v"'),
            r=json.loads("4"),
        ),
        vg.width(json.loads("420")),
        vg.height(json.loads("260")),
    ),
)
