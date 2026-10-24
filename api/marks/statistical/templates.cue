package statisticalmarks

import (
	starter "idl.uw.edu/mosaic/api/marks/render:markrender"
	"encoding/json"
	"strings"
)

exampleWidth:  number & >0 & 320
exampleHeight: number & >0 & 240
exampleMargin: number & >=0 & 40
noisyRows: [{g: "A", x: 1, y: 1}, {g: "A", x: 2, y: 3}, {g: "A", x: 3, y: 2}, {g: "A", x: 4, y: 5}, {g: "A", x: 5, y: 4}, {g: "A", x: 6, y: 6.5}]
exampleQuery: "SELECT g, CAST(x AS DOUBLE) AS x, CAST(y AS DOUBLE) AS y FROM (VALUES " + strings.Join([for Row in noisyRows {"('" + Row.g + "'," + json.Marshal(Row.x) + "," + json.Marshal(Row.y) + ")"}], ",") + ") AS t(g,x,y)"
examples: [{id: "regressionY", mark: "regressionY", kind: "base"}]
exampleProjections: {"regressionY": starter.#PlotStarter & {name: "regressionY"
	table: "statistical_regressionY", query: exampleQuery
	marks: [{name: "regressionY", data: "table", options: {x: "x", y: "y", stroke: "g"}}]
	attributes: {width: exampleWidth, height: exampleHeight, margin: exampleMargin, axis: null, xDomain: [1, 6], yDomain: [0, 8]}
}}
nativeExamples: []
templateFiles: {for Name, Source in exampleProjections["regressionY"].files {"templates/marks/statistical/\(Name)": Source}}
let StatisticalMarks = marks
compatibilityNotes: [
	{marks: [for Mark in StatisticalMarks {Mark.name}], text: "These statistical marks use SQL-backed sources. The starters create a small table through the configured Mosaic DuckDB connector. Native JavaScript calls require both the data/source argument and an options object; Python helpers retain their permissive serialization defaults."},
	{marks: ["regressionY"], text: "The retained regression engine groups by stroke, z, fx, or fy. Fill alone does not create separate regressions. A confidence value of zero hides the band; confidence and precision parameters recompute the existing fit. SQL-backed regression requires explicit x and y fields despite the optional declarative types."},
	{marks: ["errorbarX", "errorbarY"], text: "errorbarX computes horizontal confidence bounds and renders ruleY; errorbarY computes vertical bounds and renders ruleX. Bounds use the normal quantile and standard error of the mean. The dependent x or y channel is required."},
	{marks: ["hexbin"], text: "Hexbin aggregates in screen coordinates and excludes null x/y positions. Its retained constructor supports hexagon, dot, circle, and text. Text without a native text channel displays row indexes. SQL-backed binning requires explicit x and y fields."},
	{marks: ["hexbin"], text: "Known parameter limitations: a Param type reaches the renderer as an object and throws Plot[type] is not a function; a Param binWidth computes a NaN default radius before unwrapping. An explicit radius avoids that default-radius issue. Confidence and precision parameters on the other statistical marks remain supported."},
]
