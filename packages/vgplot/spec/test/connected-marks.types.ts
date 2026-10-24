import type { Area, AreaOptions, AreaX, AreaXOptions, AreaY, AreaYOptions, Arrow, ArrowOptions, Line, LineOptions, LineX, LineXOptions, LineY, LineYOptions, Link, LinkOptions } from '../src/spec/index.js';

export const areaOptions = { x1: 'x', x2: 'u', y1: 0, y2: 'y', z: 'series', curve: 'linear' } satisfies AreaOptions;
export const areaXOptions = { x: 'value', y: 'date', x1: 0, x2: 'value' } satisfies AreaXOptions;
export const areaYOptions = { x: 'date', y: 'value', y1: 0, y2: 'value' } satisfies AreaYOptions;
export const lineOptions = { x: 'date', y: 'value', z: 'series', curve: 'auto' } satisfies LineOptions;
export const lineXOptions = { x: 'value', y: 'date' } satisfies LineXOptions;
export const lineYOptions = { x: 'date', y: 'value' } satisfies LineYOptions;
export const arrowOptions = {
  x: 'x', y: 'y', x1: 'x', x2: 'u', y1: 'y', y2: 'v',
  bend: true, headAngle: 45, headLength: 8, inset: 2, insetStart: 1, insetEnd: 3, sweep: '+y'
} satisfies ArrowOptions;
export const linkOptions = { x: 'x', y: 'y', x1: 'x', x2: 'u', y1: 'y', y2: 'v', curve: '$curve' } satisfies LinkOptions;
export const connectedContracts = [
  { mark: 'area', data: { from: 'records' }, ...areaOptions } satisfies Area,
  { mark: 'areaX', data: { from: 'records' }, ...areaXOptions } satisfies AreaX,
  { mark: 'areaY', data: { from: 'records' }, ...areaYOptions } satisfies AreaY,
  { mark: 'line', data: { from: 'records' }, ...lineOptions } satisfies Line,
  { mark: 'lineX', data: { from: 'records' }, ...lineXOptions } satisfies LineX,
  { mark: 'lineY', data: { from: 'records' }, ...lineYOptions } satisfies LineY,
  { mark: 'arrow', data: { from: 'records' }, ...arrowOptions } satisfies Arrow,
  { mark: 'link', data: { from: 'records' }, ...linkOptions } satisfies Link
];

// @ts-expect-error Areas retain their declared curve narrowing.
export const areaAutoCurve: AreaOptions = { curve: 'auto' };
// @ts-expect-error AreaX omits the inherited vertical endpoints.
export const areaXEndpoint: AreaXOptions = { y1: 0 };
// @ts-expect-error AreaY omits the inherited horizontal endpoints.
export const areaYEndpoint: AreaYOptions = { x1: 0 };
// @ts-expect-error Indexed link curves keep their declared vocabulary.
export const unknownLinkCurve: LinkOptions = { curve: 'unknown' };
// @ts-expect-error Arrow sweeps have a closed directional vocabulary.
export const unknownArrowSweep: ArrowOptions = { sweep: 'up' };
// @ts-expect-error Endpoint pairs retain channel-value types.
export const unknownLinkEndpoint: LinkOptions = { x1: { arbitrary: true } };
// @ts-expect-error Concrete mark data stays required in the wire contract.
export const missingLineData: Line = { mark: 'line', x: 'x', y: 'y' };
