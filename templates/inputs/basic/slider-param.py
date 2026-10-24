from __future__ import annotations

import vgplot as vg

binding = vg.param(2)
view = vg.Spec(
    data={
        "input_data": vg.table(
            "SELECT * FROM (VALUES (1, 'Alpha', ['Alpha','Beta']), (2, 'Beta', ['Beta']), (3, 'Gamma', ['Gamma'])) AS t(x, category, items)"
        )
    },
    params={"binding": binding},
    view=vg.slider(
        bind=binding,
        label="Value",
        field="x",
        source="input_data",
        column="x",
        step=1,
        value=2,
    ),
)
