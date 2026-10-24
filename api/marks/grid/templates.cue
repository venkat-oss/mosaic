package gridmarks

import (
	starter "idl.uw.edu/mosaic/api/marks/render:markrender"
	"encoding/json"
)

exampleWidth:      number & >0 & 180
exampleHeight:     number & >0 & 160
exampleResolution: int & >=2 & 5
exampleBandwidth:  number & >=0 & 8
exampleQuery:      "SELECT * FROM (VALUES (0,0,'A',1),(1,1,'A',2),(2,2,'A',3),(3,3,'A',4),(4,4,'A',5),(0,4,'B',2),(1,3,'B',3),(2,2,'B',4),(3,1,'B',5),(4,0,'B',6)) AS t(x,y,series,value)"
examples: [{id: "raster", mark: "raster", kind: "default"}]
exampleProjections: {"raster": starter.#PlotStarter & {name: "raster"
	table: "grid_data", query: exampleQuery
	marks: [{name: "raster", data: "table", options: {x: "x", y: "y", fill: "density", width: exampleResolution, height: exampleResolution, bandwidth: exampleBandwidth}}]
	attributes: {xDomain: [0, 4], yDomain: [0, 4], width: exampleWidth, height: exampleHeight}
}}
templateFiles: {for Name, Source in exampleProjections["raster"].files {"templates/marks/grid/\(Name)": Source}}
nativeExamples: [{id: "native-interpolator", mark: "raster", kind: "native-interpolator", target: "javascript", limitation: "JavaScript-only interpolation callback; functions have no declarative or Python representation."}]
templateFiles: "templates/marks/grid/native-interpolator.js": """
import * as vg from '@uwdata/vgplot';
import { \(nativeInterpolation.name) } from '\(nativeInterpolation.module)';

await vg.coordinator().exec(vg.createTable('grid_data', \(json.Marshal(exampleQuery))));
export default vg.plot(
  vg.raster(vg.from('grid_data'), {x:'x', y:'y', fill:'density', width:\(exampleResolution), height:\(exampleResolution), bandwidth:\(exampleBandwidth), interpolate:\(nativeInterpolation.name)}),
  vg.xDomain([0,4]), vg.yDomain([0,4]), vg.width(\(exampleWidth)), vg.height(\(exampleHeight))
);

"""
