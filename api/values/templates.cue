package values

import (
	"encoding/json"
	"encoding/yaml"
)

valueExamples: [{name: "fixed", contract: "Fixed", value: "Fixed"}]
nativeIntervalExample: {contract: "Interval", target: "javascript", parameterType: "number", value: number & >0 & 1}
valueExampleQuery: "SELECT * FROM (VALUES (1,2),(2,1),(3,3)) AS t(x,y)"
exampleProjections: fixed: spec: {
	data: value_data: {type: "table", query: valueExampleQuery}
	plot: [{mark: "dot", data: {from: "value_data"}, x: "x", y: "y"}]
	xDomain: valueExamples[0].value
}
templateFiles: {
	"templates/values/fixed.json":          json.Indent(json.Marshal(exampleProjections.fixed.spec), "", "  ") + "\n"
	"templates/values/fixed.yaml":          yaml.Marshal(exampleProjections.fixed.spec)
	"templates/values/fixed.js":            """
import * as vg from '@uwdata/vgplot';

await vg.coordinator().exec(vg.createTable('value_data', \(json.Marshal(valueExampleQuery))));
export default vg.plot(vg.dot(vg.from('value_data'), {x:'x', y:'y'}), vg.xDomain(vg.Fixed));

"""
	"templates/values/fixed.py":            """
from __future__ import annotations

import vgplot as vg

view = vg.spec(
    data={'value_data':vg.table(\(json.Marshal(valueExampleQuery)))},
    view=vg.plot(vg.dot('value_data', x='x', y='y'), vg.directive('xDomain', 'Fixed')),
)

"""
	"templates/values/numeric-interval.js": """
import * as vg from '@uwdata/vgplot';

await vg.coordinator().exec(vg.createTable('value_data', \(json.Marshal(valueExampleQuery))));
export default vg.plot(vg.dotX(vg.from('value_data'), {x:'x', y:'y', interval:\(nativeIntervalExample.value)}));

"""
}
