package annotation

import (
	starter "idl.uw.edu/mosaic/api/marks/render:markrender"
)

exampleWidth:  number & >0 & 360
exampleHeight: number & >0 & 220
exampleQuery:  "SELECT * FROM (VALUES (1,2,'First',3.5,90,'https://example.com/image.png'),(2,3,'Second',5.5,180,'https://example.com/other.png')) AS t(x,y,label,value,angle,src)"
examples: [{id: "multiline-text", mark: "text", kind: "multiline"}]
exampleProjections: {"multiline-text": starter.#PlotStarter & {name: "multiline-text"
	table: "annotation_data", query: exampleQuery
	marks: [{name: "text", data: "table", options: {x: "x", y: "y", text: "label", fontSize: 14, textAnchor: "start", lineAnchor: "top", lineWidth: 5, textOverflow: "ellipsis", rotate: 15}}]
	attributes: {width: exampleWidth, height: exampleHeight}
}}
nativeExamples: []
templateFiles: {for Name, Source in exampleProjections["multiline-text"].files {"templates/marks/annotation/\(Name)": Source}}
