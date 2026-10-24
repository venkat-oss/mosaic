from __future__ import annotations

import vgplot as vg


def test_dashboard_named_caller_data_params_and_selection() -> None:
    dashboard_rows = vg.table("SELECT 1 AS day, 10 AS value")
    brush = vg.selection.crossfilter()
    offset = vg.param(0)
    assert offset.param_def() == 0
    view = vg.spec(
        view=vg.plot(
            vg.dot(
                dashboard_rows, x="day", y=vg.sql("value + $offset"), filter_by=brush
            ),
            vg.interval_x(bind=brush),
        ),
        meta={"title": "Caller metadata"},
    )
    payload = view.to_dict()
    assert payload["data"] == {
        "dashboard_rows": {"type": "table", "query": "SELECT 1 AS day, 10 AS value"}
    }
    assert payload["params"] == {"brush": {"select": "crossfilter"}, "offset": 0}
    assert payload["plot"][0]["data"] == {
        "from": "dashboard_rows",
        "filterBy": "$brush",
    }
    assert payload["plot"][1] == {"select": "intervalX", "as": "$brush"}
    assert payload["meta"] == {"title": "Caller metadata"}


def test_dashboard_explicit_context_precedes_caller_names() -> None:
    dashboard_rows = vg.table("SELECT 1 AS day")
    brush = vg.selection.crossfilter()
    view = vg.plot(vg.dot(dashboard_rows, x="day", filter_by=brush))
    payload = view.to_dict(_context={"rows": dashboard_rows, "selected": brush})
    assert payload["plot"][0]["data"] == {"from": "rows", "filterBy": "$selected"}
    assert set(payload["data"]) == {"rows"}
    assert set(payload["params"]) == {"selected"}
