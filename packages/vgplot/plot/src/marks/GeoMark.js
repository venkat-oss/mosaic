import { geojson } from '@uwdata/mosaic-sql';
import { geojson as nativeGeoJSON } from '@uwdata/mosaic-sql/native';
import { NativeSqlContext } from '@uwdata/mosaic-core';
import { Mark, isDataArray } from './Mark.js';

// default geometry column created by st_read
// warning: if another "geom" column exists this default
// will shift, for example to "geom_1" and so on.
const DEFAULT_GEOMETRY_COLUMN = 'geom';

export class GeoMark extends Mark {
  constructor(source, encodings = {}, reqs, sqlContext = null) {
    if (reqs instanceof NativeSqlContext) {
      sqlContext = reqs;
      reqs = undefined;
    }
    if (!isDataArray(source) && !encodings?.geometry) {
      // if issuing queries and no geometry channel specified
      // then request default geometry column as GeoJSON
      encodings = { ...encodings, geometry: (sqlContext ? nativeGeoJSON : geojson)(DEFAULT_GEOMETRY_COLUMN) };
    }

    super('geo', source, encodings, reqs ?? undefined, sqlContext);
  }

  queryResult(data) {
    super.queryResult(data); // map to columns, set this.data

    // look for an explicit geometry field
    const geom = this.channelField('geometry')?.as;
    if (geom) {
      // @ts-expect-error Correct the data column type
      const { columns } = this.data;
      if (typeof columns[geom][0] === 'string') {
        columns[geom] = columns[geom].map(s => JSON.parse(s));
      }
    }

    return this;
  }
}
