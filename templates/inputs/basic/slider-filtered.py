from __future__ import annotations

import vgplot as vg

upstream = vg.selection.intersect()

binding = vg.selection.crossfilter()
view = vg.Spec(
    data={
        "input_data": vg.table(
            "SELECT * FROM (VALUES (1, 'Alpha', ['Alpha','Beta']), (2, 'Beta', ['Beta']), (3, 'Gamma', ['Gamma'])) AS t(x, category, items)"
        )
    },
    params={"binding": binding, "upstream": upstream},
    view=vg.vconcat(
        vg.menu(bind=upstream, field="category", options=["Alpha", "Beta", "Gamma"]),
        vg.slider(
            bind=binding,
            label="Value",
            field="x",
            source="input_data",
            column="x",
            step=1,
            value=2,
            select="point",
            filter_by=upstream,
        ),
    ),
)
