package connected

import (
	starter "idl.uw.edu/mosaic/api/marks/render:markrender"
	"encoding/json"
	values "idl.uw.edu/mosaic/api/values"
)

exampleWidth:  number & >0 & 360
exampleHeight: number & >0 & 220
exampleCurve:  string & or(values.contractIndex.CurveName.values) & "linear"
exampleQuery:  string & "SELECT * FROM (VALUES (0,2,1,3,'A'),(1,4,2,1,'A'),(2,1,3,4,'A'),(0,3,1,2,'B'),(1,1,2,4,'B'),(2,4,3,1,'B')) AS t(x,y,u,v,series)"
examples: [{id: "line", mark: "line", kind: "base"}]
exampleProjections: {"line": starter.#PlotStarter & {name: "line"
	table: "connected_data", query: exampleQuery
	marks: [{name: "line", data: "table", options: {x: "x", y: "y", curve: exampleCurve, z: "series", stroke: "series"}}]
	attributes: {width: exampleWidth, height: exampleHeight}
}}
templateFiles: {for Name, Source in exampleProjections["line"].files {"templates/marks/connected/\(Name)": Source}}
nativeExamples: [{id: "native-curve", mark: "line", kind: "d3-basis", target: "javascript", dependency: "d3"}]
_nativeTemplateFiles: {for example in nativeExamples {
	"\(example.id).js": """
import * as vg from '@uwdata/vgplot';
import { curveBasis } from 'd3';

await vg.coordinator().exec(vg.createTable('connected_data', \(json.Marshal(exampleQuery))));

export default vg.plot(
  vg.line(vg.from('connected_data'), {x: 'x', y: 'y', z: 'series', curve: curveBasis}),
  vg.width(\(exampleWidth)), vg.height(\(exampleHeight))
);

"""
}}
templateFiles: {for Name, Source in _nativeTemplateFiles {"templates/marks/connected/\(Name)": Source}}
