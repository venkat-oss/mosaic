from __future__ import annotations

import json

import vgplot as vg

view = vg.spec(
    data={
        "statistical_regressionY": vg.table(
            "SELECT g, CAST(x AS DOUBLE) AS x, CAST(y AS DOUBLE) AS y FROM (VALUES ('A',1,1),('A',2,3),('A',3,2),('A',4,5),('A',5,4),('A',6,6.5)) AS t(g,x,y)"
        )
    },
    view=vg.plot(
        vg.regression_y(
            vg.source("statistical_regressionY"),
            x=json.loads('"x"'),
            y=json.loads('"y"'),
            stroke=json.loads('"g"'),
        ),
        vg.width(json.loads("320")),
        vg.height(json.loads("240")),
        vg.margin(json.loads("40")),
        vg.axis(json.loads("null")),
        vg.x_domain(json.loads("[1,6]")),
        vg.y_domain(json.loads("[0,8]")),
    ),
)
