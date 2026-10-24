import type { GridInterpolate, Grid2DOptions, RasterOptions, Raster, Heatmap, RasterTile } from '../src/spec/marks/Raster.js';
import type { ContourOptions, Contour } from '../src/spec/marks/Contour.js';
import type { DenseLineOptions, DenseLine } from '../src/spec/marks/DenseLine.js';
import type { Density2DOptions, Density } from '../src/spec/marks/Density.js';

const interpolation: GridInterpolate[] = ['none', 'linear', 'nearest', 'barycentric', 'random-walk'];
const grid: Grid2DOptions = {x: 'x', y: 'y', width: '$resolution', interpolate: null};
const rasterOptions: RasterOptions = {...grid, fill: 'density', imageRendering: 'pixelated'};
const raster: Raster = {mark: 'raster', data: {from: 'records'}, ...rasterOptions};
const heatmap: Heatmap = {mark: 'heatmap', data: [], bandwidth: '$bandwidth'};
const tile: RasterTile = {mark: 'rasterTile', data: [], origin: [0, 0]};
const contourOptions: ContourOptions = {...grid, thresholds: [0.1, 0.5]};
const contour: Contour = {mark: 'contour', data: [], ...contourOptions};
const lineOptions: DenseLineOptions = {...rasterOptions, z: 'series', normalize: false};
const line: DenseLine = {mark: 'denseLine', data: [], ...lineOptions};
const densityOptions: Density2DOptions[] = ['dot', 'circle', 'hexagon', 'cell', 'text', '$type'].map(type => ({type: type as Density2DOptions['type']}));
const density: Density = {mark: 'density', data: [], type: 'text', fontSize: 12, fill: 'density'};
// @ts-expect-error interpolation vocabulary is closed
const badInterpolation: GridInterpolate = 'cubic';
// @ts-expect-error origin has two coordinates
const badTile: RasterTile = {mark: 'rasterTile', data: [], origin: [0]};
// @ts-expect-error thresholds contain numbers
const badContour: ContourOptions = {thresholds: ['high']};
// @ts-expect-error normalize is boolean or a parameter reference
const badNormalize: DenseLineOptions = {normalize: 1};
// @ts-expect-error density type is a declared literal or dollar-prefixed reference
const badDensity: Density2DOptions = {type: 'line'};
// @ts-expect-error native weight channel is outside the declaration
const nativeWeight: RasterOptions = {weight: 'value'};
// @ts-expect-error text styles do not add a density text channel
const nativeText: Density2DOptions = {type: 'text', text: 'density'};
void [interpolation, raster, heatmap, tile, contour, line, densityOptions, density, badInterpolation, badTile, badContour, badNormalize, badDensity, nativeWeight, nativeText];
