package rootspec

import (
	jsonEncoding "encoding/json"
	yamlEncoding "encoding/yaml"
	"list"
	"strings"
	specmodel "idl.uw.edu/mosaic/api/spec/model:specmodel"
)

#DashboardExample: {
	id!:     "dashboard"
	title!:  string & !=""
	table!:  string & =~"^[a-z][a-z_]*$"
	query!:  string & !=""
	width!:  int & >=100
	height!: int & >=100
	offset!: {initial!: number, minimum!: number & <=initial, maximum!: number & >=initial, step!: number & >0}
}
dashboard: #DashboardExample & {
	id:     "dashboard"
	title:  "Linked dashboard"
	table:  "dashboard_rows"
	query:  "SELECT * FROM (VALUES (1,10,'A'),(2,12,'B'),(3,15,'A'),(4,18,'B'),(5,14,'C'),(6,20,'C')) AS t(day,value,category)"
	width:  360
	height: 220
	offset: {initial: 0, minimum: -5, maximum: 5, step: 1}
}
let Dashboard = dashboard
_dashboardData: {type: "table", query: Dashboard.query}
_dashboardParams: {brush: {select: "crossfilter"}, offset: Dashboard.offset.initial}
_dashboardDefaults: {width: Dashboard.width, height: Dashboard.height}
_dashboardScatter: {
	plot: [
		{mark: "dot", data: {from: Dashboard.table, filterBy: "$brush"}, x: "day", y: {sql: "value + $offset"}, fill: "category"},
		{select: "intervalX", as: "$brush"},
		{legend: "color"},
	]
	xLabel: "Day"
	yLabel: "Value + offset"
}
_dashboardBars: {plot: [{mark: "barY", data: {from: Dashboard.table, filterBy: "$brush"}, x: "category", y: {count: ""}, fill: "category"}], xLabel: "Category", yLabel: "Selected rows"}
_dashboardSlider: {input: "slider", as: "$offset", label: "Vertical offset", min: Dashboard.offset.minimum, max: Dashboard.offset.maximum, step: Dashboard.offset.step}
_dashboardTable: {input: "table", from: Dashboard.table, columns: ["day", "value", "category"], filterBy: "$brush", rowBatch: 10}
dashboardSpec: {
	config: {extensions: []}
	data: {(Dashboard.table): _dashboardData}
	params:       _dashboardParams
	plotDefaults: _dashboardDefaults
	vconcat: [_dashboardSlider, {hconcat: [_dashboardScatter, _dashboardBars]}, _dashboardTable]
}
dashboardChecks: {
	headerFields: [for Key, _ in dashboardSpec if Key != "vconcat" {true & list.Contains([for Field in specmodel.contractIndex.SpecHead.fields {Field.name}], Key)}]
	componentKinds: [for Kind in ["Slider", "VConcat", "HConcat", "Plot", "Table"] {true & list.Contains(specmodel.componentTypes, Kind)}]
}
dashboardJavaScript: """
import * as vg from '@uwdata/vgplot';

export const brush = vg.Selection.crossfilter();
export const offset = vg.Param.value(\(Dashboard.offset.initial));
await vg.coordinator().exec(vg.createTable('\(Dashboard.table)', \(jsonEncoding.Marshal(Dashboard.query))));

export default vg.vconcat(
  vg.slider({as: offset, label: \(jsonEncoding.Marshal(_dashboardSlider.label)), min: \(Dashboard.offset.minimum), max: \(Dashboard.offset.maximum), step: \(Dashboard.offset.step)}),
  vg.hconcat(
    vg.plot(
      vg.dot(vg.from('\(Dashboard.table)', {filterBy: brush}), {x: \(jsonEncoding.Marshal(_dashboardScatter.plot[0].x)), y: vg.sql`\(strings.Replace(_dashboardScatter.plot[0].y.sql, "$offset", "${offset}", -1))`, fill: \(jsonEncoding.Marshal(_dashboardScatter.plot[0].fill))}),
      vg.intervalX({as: brush}), vg.colorLegend(),
      vg.xLabel(\(jsonEncoding.Marshal(_dashboardScatter.xLabel))), vg.yLabel(\(jsonEncoding.Marshal(_dashboardScatter.yLabel))),
      vg.width(\(Dashboard.width)), vg.height(\(Dashboard.height))
    ),
    vg.plot(
      vg.barY(vg.from('\(Dashboard.table)', {filterBy: brush}), {x: \(jsonEncoding.Marshal(_dashboardBars.plot[0].x)), y: vg.count(), fill: \(jsonEncoding.Marshal(_dashboardBars.plot[0].fill))}),
      vg.xLabel(\(jsonEncoding.Marshal(_dashboardBars.xLabel))), vg.yLabel(\(jsonEncoding.Marshal(_dashboardBars.yLabel))),
      vg.width(\(Dashboard.width)), vg.height(\(Dashboard.height))
    )
  ),
  vg.table({from: '\(Dashboard.table)', columns: \(jsonEncoding.Marshal(_dashboardTable.columns)), filterBy: brush, rowBatch: \(_dashboardTable.rowBatch)})
);

"""
dashboardPython:     """
from __future__ import annotations

import vgplot as vg

\(Dashboard.table) = vg.table(\(jsonEncoding.Marshal(Dashboard.query)))
brush = vg.selection.crossfilter()
offset = vg.param(\(Dashboard.offset.initial))

view = vg.spec(
    data={"\(Dashboard.table)": \(Dashboard.table)},
    params={"brush": brush, "offset": offset},
    config={"extensions": []},
    plot_defaults={"width": \(Dashboard.width), "height": \(Dashboard.height)},
    view=vg.vconcat(
        vg.slider(bind=offset, label=\(jsonEncoding.Marshal(_dashboardSlider.label)), min=\(Dashboard.offset.minimum), max=\(Dashboard.offset.maximum), step=\(Dashboard.offset.step)),
        vg.hconcat(
            vg.plot(
                vg.dot(vg.source("\(Dashboard.table)", filter_by=brush), x=\(jsonEncoding.Marshal(_dashboardScatter.plot[0].x)), y=vg.sql(\(jsonEncoding.Marshal(_dashboardScatter.plot[0].y.sql))), fill=\(jsonEncoding.Marshal(_dashboardScatter.plot[0].fill))),
                vg.interval_x(bind=brush), vg.color_legend(),
                vg.x_label(\(jsonEncoding.Marshal(_dashboardScatter.xLabel))), vg.y_label(\(jsonEncoding.Marshal(_dashboardScatter.yLabel))),
            ),
            vg.plot(
                vg.bar_y(vg.source("\(Dashboard.table)", filter_by=brush), x=\(jsonEncoding.Marshal(_dashboardBars.plot[0].x)), y=vg.count(), fill=\(jsonEncoding.Marshal(_dashboardBars.plot[0].fill))),
                vg.x_label(\(jsonEncoding.Marshal(_dashboardBars.xLabel))), vg.y_label(\(jsonEncoding.Marshal(_dashboardBars.yLabel))),
            ),
        ),
        vg.table_input("\(Dashboard.table)", columns=\(jsonEncoding.Marshal(_dashboardTable.columns)), filter_by=brush, row_batch=\(_dashboardTable.rowBatch)),
    ),
)

"""
templateFiles: {for Format, Source in {json: jsonEncoding.Indent(jsonEncoding.Marshal(dashboardSpec), "", "  ") + "\n", yaml: yamlEncoding.Marshal(dashboardSpec), js: dashboardJavaScript, py: dashboardPython} {
	"templates/spec/\(Dashboard.id).\(Format)": Source
}}
