import { coordinator as _coordinator } from '@uwdata/mosaic-core';
import { NamedPlots } from './plot/named-plots.js';
import * as vgplot from './api.js';
import { createSchema, createTable, loadCSV, loadJSON, loadObjects, loadParquet, loadSpatial, geojson, centroid, centroidX, centroidY } from '@uwdata/mosaic-sql/native';

export function createAPIContext({
  coordinator = _coordinator(),
  namedPlots = new NamedPlots,
  extensions = null,
  ...options
} = {}) {
  return {
    ...vgplot,
    ...(coordinator.nativeContext ? { createSchema, createTable, loadCSV, loadJSON, loadObjects, loadParquet, loadSpatial, geojson, centroid, centroidX, centroidY } : null),
    ...extensions,
    coordinator: () => coordinator,
    context: {
      coordinator,
      namedPlots,
      ...options
    }
  };
}
