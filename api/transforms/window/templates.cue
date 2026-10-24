package window

import (
	"encoding/json"
	"encoding/yaml"
	"strings"
	"idl.uw.edu/mosaic/api/render"
)

frameParameterDefault: [number, number] & [1, 0]
frameParameterLiteral: "[" + strings.Join([for Value in frameParameterDefault {(render.#TypeScriptLiteral & {value: Value}).text}], ", ") + "]"

windowExampleQuery: "SELECT id, x, y, category, TIMESTAMP '2024-01-01' + id * INTERVAL 1 MICROSECOND AS time FROM (VALUES (1, 1, 10, 'A'), (2, 2, 20, 'A'), (3, 2, 30, 'A'), (4, 3, 40, 'A')) AS t(id, x, y, category)"

windowStarters: [{name: "frame-parameter", kind: "parameter"}]
#WindowStarterProjection: {
	starter!: {name: "frame-parameter", kind: "parameter"}
	parameter: true
	expression: {sum: "y", orderby: "id", partitionby: "category", rows: "$frame"}
	spec: {
		data: window_data: {type: "table", query: windowExampleQuery}
		params: frame: frameParameterDefault
		plot: [{mark: "dot", data: {from: "window_data"}, x: "id", y: expression, r: 4}]
	}
	jsExpression:     "vg.sum('y').orderby('id').partitionby('category').frame(vg.frameRows(frame))"
	pythonExpression: "vg.sum('y', orderby='id', partitionby='category', rows=frame)"
}
windowStarterProjections: {for Starter in windowStarters {(Starter.name): #WindowStarterProjection & {starter: Starter}}}

#GenericIntervalExample: {target: "javascript", unit!: string & or([for api in intervalAPIs {strings.ToUpper(api.key)}]), steps!: number & >0}
genericIntervalExample: #GenericIntervalExample & {unit: "DAYS", steps: 1}

_windowTemplateFiles: {
	for starter in windowStarters {
		let Projection = windowStarterProjections[starter.name]
		"\(starter.name).json": json.Indent(json.Marshal(Projection.spec), "", "  ") + "\n"
		"\(starter.name).yaml": yaml.Marshal(Projection.spec)
		"\(starter.name).js":   """
   import * as vg from '@uwdata/vgplot';

   await vg.coordinator().exec(vg.createTable('window_data', \((render.#TypeScriptLiteral & {value: windowExampleQuery}).text)));
   \(strings.Join([if Projection.parameter {"const frame = vg.Param.value(\(frameParameterLiteral));\n"}], ""))
   export default vg.plot(
     vg.dot(vg.from('window_data'), {x: 'id', y: \(Projection.jsExpression), r: 4})
   );

   """
		"\(starter.name).py":   """
   from __future__ import annotations

   \(strings.Join([if Projection.parameter == false {"import json\n\n"}], ""))import vgplot as vg

   \(strings.Join([if Projection.parameter {"frame = vg.param(\(frameParameterLiteral))\n"}], ""))view = vg.spec(
       data={"window_data": vg.table(\(json.Marshal(windowExampleQuery)))},
   \(strings.Join([if Projection.parameter {"    params={\"frame\": frame},\n"}], ""))    view=vg.plot(vg.dot("window_data", x="id", y=\(Projection.pythonExpression), r=4)),
   )

   """
	}
	"generic-interval.js": """
  import * as vg from '@uwdata/vgplot';

  await vg.coordinator().exec(vg.createTable('window_data', \((render.#TypeScriptLiteral & {value: windowExampleQuery}).text)));

  export default vg.plot(
    vg.dot(vg.from('window_data'), {
      x: 'id',
      y: vg.sum('y').orderby('time').partitionby('category').frame(vg.frameRange([vg.interval(\((render.#TypeScriptLiteral & {value: genericIntervalExample.unit}).text), \(genericIntervalExample.steps)), 0])),
      r: 4
    })
  );

  """
}
templateFiles: {
	for name, content in _windowTemplateFiles {
		"templates/transforms/window/\(name)": content
	}
}
