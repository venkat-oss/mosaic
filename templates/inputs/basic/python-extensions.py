from __future__ import annotations

import vgplot as vg

choice = vg.param("Alpha")
enabled = vg.param(False)
views = {
    "select": vg.Spec(
        params={"choice": choice},
        view=vg.select(
            "Category", choice, ["Alpha", vg.option("Second", "Beta")], multiple=True
        ),
    ),
    "checkbox": vg.Spec(
        params={"enabled": enabled}, view=vg.checkbox("Enabled", enabled)
    ),
    "generic": vg.Spec(
        params={"choice": choice}, view=vg.input("custom", label="Custom", bind=choice)
    ),
    "option": vg.Spec(
        params={"choice": choice},
        view=vg.menu(options=[vg.option("Unset", None)], bind=choice),
    ),
}
