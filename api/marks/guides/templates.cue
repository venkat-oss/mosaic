package guidemarks

import (
	starter "idl.uw.edu/mosaic/api/marks/render:markrender"
	"encoding/json"
	"strings"
)

let GuideMarks = marks

exampleWidth:          number & >0 & 320
exampleHeight:         number & >0 & 240
exampleMargin:         number & >=0 & 40
nativeFormatterPrefix: string & "v="
exampleRows: [{x: 2, y: 3, facet: "a", row: "c"}, {x: 7, y: 8, facet: "b", row: "d"}]
examples: [{id: "axisX", mark: "axisX", kind: "base"}]
exampleProjections: {"axisX": starter.#PlotStarter & {name: "axisX"
	rows: exampleRows
	marks: [{name: "dot", data: "inline", options: {x: "x", y: "y"}}, {name: "axisX", data: "none", options: {}}]
	attributes: {width: exampleWidth, height: exampleHeight, margin: exampleMargin, axis: null, xDomain: [0, 10], yDomain: [0, 10]}
}}
templateFiles: {for Name, Source in exampleProjections["axisX"].files {"templates/marks/guides/\(Name)": Source}}
nativeExamples: [{id: "native-formatter", kind: "formatter", mark: "axisX", target: "javascript"}]
_nativeFiles: {for Example in nativeExamples {
	"\(Example.id).js": """
import * as vg from '@uwdata/vgplot';

export default vg.plot(
  vg.dot(\(json.Marshal(exampleRows)), {x:'x', y:'y'}),
  vg.axisX({ticks:[0,5,10], tickFormat:value=>\(json.Marshal(nativeFormatterPrefix))+value}),
  vg.axis(null), vg.xDomain([0,10]), vg.yDomain([0,10]),
  vg.width(\(exampleWidth)), vg.height(\(exampleHeight)), vg.margin(\(exampleMargin))
);

"""
}}
templateFiles: {for Name, Source in _nativeFiles {"templates/marks/guides/\(Name)": Source}}
compatibilityNotes: [
	{marks: [for Mark in GuideMarks {Mark.name}], text: "These decorative marks support data-free, options-only JavaScript calls. JavaScript and Python helpers also accept native data/source arguments and extra options, while their closed declarative contracts omit the data property. The renderer retains that target difference."},
	{marks: [for Mark in GuideMarks if strings.HasPrefix(Mark.name, "axis") || strings.HasPrefix(Mark.name, "grid") {Mark.name}], text: "Axis and grid anchors follow scale orientation: top/bottom for x/fx, left/right for y/fy. Other sides are admitted by the broad wire and TypeScript contracts but the retained renderer rejects them with invalid anchor: side."},
	{marks: ["axisX", "axisY", "axisFx", "axisFy"], text: "Formatting functions are JavaScript-only. Numeric intervals remain native values beyond the default wire Interval alias. Numeric scales retain their default labels for an explicit null tickFormat. Use a named parameter for string-valued options that the retained mark runtime would otherwise classify as a field."},
	{marks: ["hexgrid"], text: "The retained hexgrid renderer uses stroke-only outlines and defaults binWidth to 20. Fill remains admitted by inherited mark options; use frame to fill a background."},
]
