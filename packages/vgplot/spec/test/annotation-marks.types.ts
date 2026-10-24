import type { Image } from '../src/spec/marks/Image.js';
import type { Text, TextX, TextY } from '../src/spec/marks/Text.js';
import type { Spike, Vector, VectorShape, VectorShapeName, VectorX, VectorY } from '../src/spec/marks/Vector.js';
import type { WaffleX, WaffleY } from '../src/spec/marks/Waffle.js';

export const text: Text = { mark: 'text', text: 'hello', frameAnchor: 'middle', lineAnchor: 'top', fontSize: 14 };
export const textX: TextX = { mark: 'textX', data: [], interval: '$interval', y: { value: 'y', interval: 2 } };
export const textY: TextY = { mark: 'textY', data: [], interval: 2, x: { value: 'x', interval: 2 } };
export const image: Image = { mark: 'image', data: [], src: 'https://example.com/image.png', width: 20, height: 10, preserveAspectRatio: 'xMidYMid slice' };
export const shape: VectorShape = 'spike';
export const shapeName: VectorShapeName = 'arrow';
export const vector: Vector = { mark: 'vector', data: [], x: 'x', y: 'y', length: 'value', rotate: 'angle', shape, anchor: 'start' };
export const vectorX: VectorX = { ...vector, mark: 'vectorX' };
export const vectorY: VectorY = { ...vector, mark: 'vectorY' };
export const spike: Spike = { ...vector, mark: 'spike' };
export const waffleX: WaffleX = { mark: 'waffleX', data: [], x: 'value', y: 'label', x1: 0, multiple: 4, unit: 1, gap: 1, round: true };
export const waffleY: WaffleY = { mark: 'waffleY', data: [], y: 'value', x: 'label', y1: 0, multiple: 4, unit: 1, gap: 1, round: false };
// @ts-expect-error Image data remains required.
export const missingImageData: Image = { mark: 'image', src: 'url' };
// @ts-expect-error Shape names retain the closed declared vocabulary.
export const unknownVectorShape: VectorShape = 'triangle';
// @ts-expect-error Constant vector radius rejects boolean.
export const booleanVectorRadius: Vector = { mark: 'vector', data: [], r: true };
// @ts-expect-error Waffle layout options retain their scalar type.
export const invalidWaffleGap: WaffleX = { mark: 'waffleX', data: [], gap: {} };
// @ts-expect-error TextY retains Interval without ParamRef.
export const referencedTextYInterval: TextY = { mark: 'textY', interval: '$interval' };
