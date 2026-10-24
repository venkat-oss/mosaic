import type { DataArray, DataBaseOptions, DataCSV, DataDefinition, DataFile, DataJSON, DataJSONObjects, DataParquet, DataQuery, DataSpatial, DataTable, PlotDataInline, PlotFrom, PlotMarkData } from '../src/index.js';

export const dataContracts = {
  options: { select: ['x'], where: ['x > 0'], temp: false, replace: true, view: false } satisfies DataBaseOptions,
  query: 'SELECT 1' satisfies DataQuery,
  array: [{ x: 1 }, {}] satisfies DataArray,
  file: { file: 'rows.csv' } satisfies DataFile,
  table: { type: 'table', query: 'SELECT 1' } satisfies DataTable,
  csv: { type: 'csv', file: 'arbitrary', delimiter: ';', sample_size: -1 } satisfies DataCSV,
  json: { type: 'json', file: 'arbitrary' } satisfies DataJSON,
  parquet: { type: 'parquet', file: 'arbitrary' } satisfies DataParquet,
  spatial: { type: 'spatial', file: 'arbitrary', layer: '' } satisfies DataSpatial,
  objects: { data: [{}] } satisfies DataJSONObjects,
  definition: [{ type: 'csv', file: 'arbitrary' }, 'SELECT 1', [], { data: [{}] }] satisfies DataDefinition[],
  inline: [null, 1, 'text', {}] satisfies PlotDataInline,
  source: { from: '$table', filterBy: '$brush', optimize: false } satisfies PlotFrom,
  mark: [{ from: 'rows' }, [1, 2]] satisfies PlotMarkData[]
};

// @ts-expect-error Inferred file types retain their suffix constraint.
export const arbitraryInferredFile: DataFile = { file: 'rows.unknown' };
// @ts-expect-error Data arrays contain objects, while inline mark arrays accept any values.
export const primitiveDataArray: DataArray = [1];
// @ts-expect-error CSV sample sizes are numeric.
export const stringSampleSize: DataCSV = { type: 'csv', file: 'rows.csv', sample_size: 'all' };
// @ts-expect-error The declarative source type does not own the native unnest option.
export const nativeUnnest: PlotFrom = { from: 'rows', unnest: ['items'] };
// @ts-expect-error TypeScript filter references retain the parameter prefix.
export const plainFilter: PlotFrom = { from: 'rows', filterBy: 'brush' };
