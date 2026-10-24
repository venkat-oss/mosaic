from __future__ import annotations

import json

import vgplot as vg

view = vg.spec(
    data={
        "annotation_data": vg.table(
            "SELECT * FROM (VALUES (1,2,'First',3.5,90,'https://example.com/image.png'),(2,3,'Second',5.5,180,'https://example.com/other.png')) AS t(x,y,label,value,angle,src)"
        )
    },
    view=vg.plot(
        vg.text(
            vg.source("annotation_data"),
            x=json.loads('"x"'),
            y=json.loads('"y"'),
            text=json.loads('"label"'),
            font_size=json.loads("14"),
            text_anchor=json.loads('"start"'),
            line_anchor=json.loads('"top"'),
            line_width=json.loads("5"),
            text_overflow=json.loads('"ellipsis"'),
            rotate=json.loads("15"),
        ),
        vg.width(json.loads("360")),
        vg.height(json.loads("220")),
    ),
)
