package colorattributes

import "encoding/json"

templateFiles: "templates/attributes/color/native-sequential.js": """
import * as vg from '@uwdata/vgplot';
import { interpolateBlues } from 'd3';

export default vg.plot(
  vg.dot(\(json.Marshal(exampleRows)), {x:'x', y:'y', fill:'value', r:5}),
  vg.colorScale('linear'), vg.colorDomain([0,3]), vg.colorInterpolate(interpolateBlues)
);

"""
