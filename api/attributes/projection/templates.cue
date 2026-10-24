package projectionattributes

import "encoding/json"

import starter "idl.uw.edu/mosaic/api/marks/render:markrender"

sampleProjections: {"projectionType": starter.#PlotStarter & {name: "projectionType", rows: sampleRows, marks: [{name: "dot", data: "inline", options: {x: "lon", y: "lat", r: 4}}], attributes: {width: 300, height: 200, projectionType: samples[0].value}, parameters: {}}}
templateFiles: {for Name, Source in sampleProjections["projectionType"].files {"templates/attributes/projection/\(Name)": Source}}
nativeSamples: [{id: "native-initializer", kind: "mercator-initializer", scale: 50}]
templateFiles: "templates/attributes/projection/native-initializer.js": """
import * as vg from '@uwdata/vgplot';
import { geoMercator } from 'd3';

const projection = ({width, height}) => geoMercator().scale(\(nativeSamples[0].scale)).translate([width / 2, height / 2]);
export default vg.plot(
  vg.dot(\(json.Marshal(sampleRows)), {x:'lon', y:'lat', r:4}),
  vg.projectionType(projection), vg.width(300), vg.height(200)
);

"""
