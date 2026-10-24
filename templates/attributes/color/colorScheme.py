from __future__ import annotations

import json

import vgplot as vg

setting = vg.param(json.loads('"YlGnBu"'))
view = vg.spec(
    params={"setting": setting},
    view=vg.plot(
        vg.dot(
            json.loads(
                '[{"x":1,"y":2,"value":1,"category":"A"},{"x":2,"y":1,"value":2,"category":"B"},{"x":3,"y":3,"value":3,"category":"C"}]'
            ),
            x=json.loads('"x"'),
            y=json.loads('"y"'),
            r=json.loads("5"),
            fill=json.loads('"value"'),
        ),
        vg.width(json.loads("320")),
        vg.height(json.loads("200")),
        vg.color_scale(json.loads('"linear"')),
        vg.color_scheme(setting),
    ),
)
