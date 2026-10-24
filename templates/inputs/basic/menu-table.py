from __future__ import annotations

import vgplot as vg

binding = vg.selection.crossfilter()
view = vg.Spec(
    data={
        "input_data": vg.table(
            "SELECT * FROM (VALUES (1, 'Alpha', ['Alpha','Beta']), (2, 'Beta', ['Beta']), (3, 'Gamma', ['Gamma'])) AS t(x, category, items)"
        )
    },
    params={"binding": binding},
    view=vg.menu(
        bind=binding,
        label="Category",
        field="category",
        source="input_data",
        column="category",
    ),
)
