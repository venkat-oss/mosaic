from __future__ import annotations

import json

import vgplot as vg

view = vg.spec(
    view=vg.plot(
        vg.dot(
            json.loads(
                '[{"x":2,"y":3,"facet":"a","row":"c"},{"x":7,"y":8,"facet":"b","row":"d"}]'
            ),
            x=json.loads('"x"'),
            y=json.loads('"y"'),
        ),
        vg.axis_x(),
        vg.width(json.loads("320")),
        vg.height(json.loads("240")),
        vg.margin(json.loads("40")),
        vg.axis(json.loads("null")),
        vg.x_domain(json.loads("[0,10]")),
        vg.y_domain(json.loads("[0,10]")),
    ),
)
