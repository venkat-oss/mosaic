package common

import (
	"encoding/json"
	"encoding/yaml"
	"strings"
)

authoringStarters: [{name: "parameter-channel"}]
authoringProjections: "parameter-channel": {
	options: {x: "x", y: "y", fill: "$fill"}
	spec: {
		data: common_data: {type: "table", query: exampleQuery}
		params: fill: "steelblue"
		plot: [{mark: "dot", data: {from: "common_data"}, for Key, Value in options {(Key): Value}}]
		width: exampleWidth
	}
	javascript: """
import * as vg from '@uwdata/vgplot';

await vg.coordinator().exec(vg.createTable('common_data', \(json.Marshal(exampleQuery))));
const fill = vg.Param.value('steelblue');
export default vg.plot(
  vg.dot(vg.from('common_data'), {x:'x', y:'y', fill}),
  vg.width(\(exampleWidth))
);

"""
	python:     """
from __future__ import annotations

import vgplot as vg

fill = vg.param('steelblue')
view = vg.Spec(
    data={'common_data': vg.table(\(json.Marshal(exampleQuery)))},
    params={'fill': fill},
    view=vg.plot(vg.dot(vg.source('common_data'), x='x', y='y', fill=fill), vg.width(\(exampleWidth))),
)

"""
}
authoringFiles: {
	for Item in authoringStarters {
		let P = authoringProjections[Item.name]
		"templates/marks/common/\(Item.name).json": json.Indent(json.Marshal(P.spec), "", "  ") + "\n"
		"templates/marks/common/\(Item.name).yaml": yaml.Marshal(P.spec)
		"templates/marks/common/\(Item.name).js":   P.javascript
		"templates/marks/common/\(Item.name).py":   P.python
	}
}
authoringReference: strings.Join([for Item in authoringStarters {"- `" + Item.name + "`: " + strings.Join([for Format in ["json", "yaml", "js", "py"] {(#CommonDownload & {name: Item.name, extension: Format}).text}], " · ")}], "\n")
