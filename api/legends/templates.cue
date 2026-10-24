package legends

import (
	"encoding/json"
	"encoding/yaml"
	"strings"
)

_rows: [
	{x: 1, y: 2, category: "A", alpha: 0.3},
	{x: 2, y: 1, category: "B", alpha: 0.7},
	{x: 3, y: 3, category: "A", alpha: 1},
]
_pythonRows: strings.Join([for row in _rows {
	"                {" + strings.Join([for key, value in row {"\(json.Marshal(key)): \(json.Marshal(value))"}], ", ") + "},"
}], "\n")

templates: {
	for api in apis if api.channel == "color" {
		"\(api.channel)": {
			data: legend_data: _rows
			params: brush: select: "crossfilter"
			plot: [
				{
					mark: "dot"
					data: {from: "legend_data", filterBy: "$brush"}
					x:                 "x", y: "y"
					"\(api.encoding)": api.field
				},
				#PlotLegend & {legend: api.channel, as: "$brush", field: api.field},
			]
		}
	}
}

_templateFiles: {
	for api in apis if api.channel == "color" {
		"\(api.channel).json": json.Indent(json.Marshal(templates[api.channel]), "", "  ") + "\n"
		"\(api.channel).yaml": yaml.Marshal(templates[api.channel])
		"\(api.channel).js":   """
			// \(_header)
			import * as vg from '@uwdata/vgplot';

			await vg.coordinator().exec(vg.loadObjects('legend_data', \(json.Marshal(_rows))));
			const brush = vg.Selection.crossfilter();

			export default vg.plot(
			  vg.dot(vg.from('legend_data', { filterBy: brush }), {
			    x: 'x', y: 'y', \(api.encoding): '\(api.field)'
			  }),
			  vg.\(api.js)({ as: brush, field: '\(api.field)' })
			);

			"""
		"\(api.channel).py":   """
			# \(_header)
			from __future__ import annotations

			import vgplot as vg

			brush = vg.selection.crossfilter()
			view = vg.spec(
			    data={
			        "legend_data": vg.json(
			            [
			\(_pythonRows)
			            ]
			        )
			    },
			    params={"brush": brush},
			    view=vg.plot(
			        vg.dot(
			            vg.source("legend_data", filter_by=brush), x="x", y="y", \(api.encoding)="\(api.field)"
			        ),
			        vg.\(api.python)(\(pythonNames["as"])=brush, \(pythonNames.field)="\(api.field)"),
			    ),
			)

			"""
	}
}

_artifacts: {
	for name, contents in _templateFiles {
		"templates/legends/\(name)": contents
	}
}
