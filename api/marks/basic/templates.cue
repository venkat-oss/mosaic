package basicmarks

import (
	starter "idl.uw.edu/mosaic/api/marks/render:markrender"
)

exampleWidth:  number & >0 & 420
exampleHeight: number & >0 & 260
exampleRadius: number & >0 & 4
exampleRows: [
	{t: 1, u: 2, v: 3, w: 4, category: "A", row: "first", keep: true, radius: 3},
	{t: 3, u: 4, v: 5, w: 6, category: "B", row: "first", keep: false, radius: 0},
	{t: 5, u: 6, v: 2, w: 3, category: "A", row: "second", keep: true, radius: -1},
	{t: 7, u: 8, v: 4, w: 5, category: "B", row: "second", keep: false, radius: 4},
]
examples: [{id: "dot", mark: "dot", kind: "base"}]
exampleProjections: {"dot": starter.#PlotStarter & {name: "dot"
	rows: exampleRows
	marks: [{name: "dot", data: "inline", options: {x: "t", y: "v", r: exampleRadius}}]
	attributes: {width: exampleWidth, height: exampleHeight}
}}
nativeExamples: []
templateFiles: {for Name, Source in exampleProjections["dot"].files {"templates/marks/basic/\(Name)": Source}}
