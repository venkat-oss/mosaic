package spatialmarks

import (
	starter "idl.uw.edu/mosaic/api/marks/render:markrender"
	"encoding/json"
)

exampleWidth:     number & >0 & 420
exampleHeight:    number & >0 & 260
exampleRadius:    number & >0 & 4
initializerScale: number & >0 & 50
examplePolygons: [
	{geometry: {type: "Polygon", coordinates: [[[-25, -10], [-25, 10], [-5, 10], [-5, -10], [-25, -10]]]}, name: "West"},
	{geometry: {type: "Polygon", coordinates: [[[5, -10], [5, 10], [25, 10], [25, -10], [5, -10]]]}, name: "East"},
]
exampleGeometries: [
	{geometry: {type: "Point", coordinates: [-20, 0]}, name: "West", radius: 3},
	{geometry: {type: "Point", coordinates: [0, 10]}, name: "North", radius: 0},
	{geometry: {type: "Point", coordinates: [20, -5]}, name: "East", radius: -1},
]
examples: [{id: "geo-polygons", mark: "geo", kind: "polygons"}]
exampleProjections: {"geo-polygons": starter.#PlotStarter & {name: "geo-polygons"
	rows: examplePolygons
	marks: [{name: "geo", data: "inline", options: {stroke: "steelblue", geometry: "geometry", r: exampleRadius}}]
	attributes: {width: exampleWidth, height: exampleHeight, projectionType: "equirectangular", projectionDomain: {type: "Sphere"}}
}}
templateFiles: {for Name, Source in exampleProjections["geo-polygons"].files {"templates/marks/spatial/\(Name)": Source}}
nativeExamples: [{id: "native-projection-initializer", kind: "projection-initializer", mark: "geo", target: "javascript"}]
templateFiles: "templates/marks/spatial/native-projection-initializer.js": """
import * as vg from '@uwdata/vgplot';
import { geoMercator } from 'd3';

const projection = ({width, height}) => geoMercator().scale(\(initializerScale)).translate([width / 2, height / 2]);
export default vg.plot(
  vg.geo(\(json.Marshal(exampleGeometries)), {geometry:'geometry', r:\(exampleRadius), stroke:'steelblue'}),
  vg.projectionType(projection), vg.width(\(exampleWidth)), vg.height(\(exampleHeight))
);

"""
