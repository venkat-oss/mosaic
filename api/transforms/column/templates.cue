package column

import (
	"encoding/json"
	"encoding/yaml"
	"strings"
)

columnExamples: [{key: "bin", field: "x", options: {steps: 4}}]
sqlExample: {spans: ["x + ", ""], parameter: "offset", value: 1}
aggregateExample: {value: {agg: "AVG(x)", label: "Average x"}}
#TemplateSpan: {value!: string, text: strings.Replace(strings.Replace(strings.Replace(value, "\\", "\\\\", -1), "`", "\\`", -1), "${", "\\${", -1)}
columnExampleQuery: "SELECT x, y, DATE '2024-01-01' + CAST(x AS INTEGER) AS time FROM (VALUES (1,2),(2,1),(3,3)) AS t(x,y)"
exampleProjections: bin: {
	wireExpression: {bin: columnExamples[0].field, steps: columnExamples[0].options.steps}
	spec: {data: column_data: {type: "table", query: columnExampleQuery}, plot: [{mark: "dot", data: {from: "column_data"}, x: wireExpression, y: "y"}]}
}
sqlWireExpression: {sql: sqlExample.spans[0] + "$" + sqlExample.parameter + sqlExample.spans[1]}
sqlTemplateSpec: {
	data: column_data: {type: "table", query: columnExampleQuery}
	params: (sqlExample.parameter): sqlExample.value
	plot: [{mark: "dot", data: {from: "column_data"}, x: sqlWireExpression, y: "y"}]
}

_columnTemplateFiles: {
	"aggregate-expression.ts": """
		import type { AggregateExpression } from '@uwdata/mosaic-spec';

		export const expression: AggregateExpression = \(json.Marshal(aggregateExample.value));

		"""
	"bin.json":                json.Indent(json.Marshal(exampleProjections.bin.spec), "", "  ") + "\n"
	"bin.yaml":                yaml.Marshal(exampleProjections.bin.spec)
	"bin.js":                  """
import * as vg from '@uwdata/vgplot';

await vg.coordinator().exec(vg.createTable('column_data', \(json.Marshal(columnExampleQuery))));
export default vg.plot(vg.dot(vg.from('column_data'), {x:vg.bin(\(json.Marshal(columnExamples[0].field)), \(json.Marshal(columnExamples[0].options))), y:'y'}));

"""
	"bin.py":                  """
from __future__ import annotations

import vgplot as vg

view = vg.spec(
    data={'column_data':vg.table(\(json.Marshal(columnExampleQuery)))},
    view=vg.plot(vg.dot('column_data', x=vg.bin(\(json.Marshal(columnExamples[0].field)), steps=\(columnExamples[0].options.steps)), y='y')),
)

"""

	"sql.json": json.Indent(json.Marshal(sqlTemplateSpec), "", "  ") + "\n"
	"sql.yaml": yaml.Marshal(sqlTemplateSpec)
	"sql.js":   """
		import * as vg from '@uwdata/vgplot';

		await vg.coordinator().exec(vg.createTable('column_data', \(json.Marshal(columnExampleQuery))));
		const \(sqlExample.parameter) = vg.Param.value(\(json.Marshal(sqlExample.value)));

		export default vg.plot(
		  vg.dot(vg.from('column_data'), {x: vg.sql`\((#TemplateSpan & {value: sqlExample.spans[0]}).text)${\(sqlExample.parameter)}\((#TemplateSpan & {value: sqlExample.spans[1]}).text)`, y: 'y'})
		);

		"""
	"sql.py":   """
		from __future__ import annotations

		import vgplot as vg

		\(sqlExample.parameter) = vg.param(\(json.Marshal(sqlExample.value)))
		view = vg.spec(
		    data={"column_data": vg.table(\(json.Marshal(columnExampleQuery)))},
		    params={\(json.Marshal(sqlExample.parameter)): \(sqlExample.parameter)},
		    view=vg.plot(vg.dot("column_data", x=vg.sql(\(json.Marshal(sqlWireExpression.sql))), y="y")),
		)

		"""
}

templateFiles: {
	for name, content in _columnTemplateFiles {
		"templates/transforms/column/\(name)": content
	}
}
