package density1d

import (
	starter "idl.uw.edu/mosaic/api/marks/render:markrender"
)

exampleWidth:     number & >0 & 360
exampleHeight:    number & >0 & 220
exampleBins:      int & >=2 & 32
exampleBandwidth: number & >0 & 8
exampleQuery:     "SELECT * FROM (VALUES (0,'A',1),(1,'A',2),(2,'A',3),(3,'A',2),(4,'A',1),(0,'B',2),(1,'B',1),(2,'B',2),(3,'B',1),(4,'B',2)) AS t(value,series,weight)"
examples: [{id: "densityY", mark: "densityY", kind: "default"}]
exampleProjections: {"densityY": starter.#PlotStarter & {name: "densityY"
	table: "density_data", query: exampleQuery
	marks: [{name: "densityY", data: "table", options: {x: "value", fill: "series", bins: exampleBins, normalize: false, bandwidth: exampleBandwidth}}]
	attributes: {xDomain: [0, 4], width: exampleWidth, height: exampleHeight}
}}
nativeExamples: []
templateFiles: {for Name, Source in exampleProjections["densityY"].files {"templates/marks/density1d/\(Name)": Source}}
