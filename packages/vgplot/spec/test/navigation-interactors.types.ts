import type { PanZoomOptions, Pan, PanX, PanY, PanZoom, PanZoomX, PanZoomY } from '../src/spec/interactors/PanZoom.js';

const options: PanZoomOptions = {x: '$x', y: '$y', xfield: 'a', yfield: 'b'};
const interactors: [Pan, PanX, PanY, PanZoom, PanZoomX, PanZoomY] = [
  {select: 'pan', ...options}, {select: 'panX', ...options}, {select: 'panY', ...options},
  {select: 'panZoom', ...options}, {select: 'panZoomX', ...options}, {select: 'panZoomY', ...options},
];
// @ts-expect-error references use dollar-prefixed names in TypeScript
const bare: PanZoomOptions = {x: 'x'};
// @ts-expect-error fields are strings
const badField: PanZoomOptions = {xfield: 1};
// @ts-expect-error native extent controls are outside the declarative type
const native: PanZoomOptions = {zoom: [1, 2]};
// @ts-expect-error selection discriminator is variant-specific
const other: PanX = {select: 'panY'};
void [interactors, bare, badField, native, other];
