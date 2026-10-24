import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { describe, expect, it } from 'vitest';
import { parseSpec } from '../src/index.js';

const schema = JSON.parse(await readFile(resolve(import.meta.dirname, '../dist/mosaic-schema.json'), 'utf8'));
const ajv = new Ajv({ allowUnionTypes: true, allErrors: true });
addFormats.default(ajv);
ajv.addSchema(schema, 'cartesian-attributes');
const validate = ajv.getSchema('cartesian-attributes');
const suffixes = [
  ['Scale', ['utc', null, 'wire-only'], [false, 1]],
  ['Domain', [[], [1, 2], 'Fixed', '$domain'], [false, 1, null]],
  ['Range', [[20, 180], 'Fixed', '$range'], [true, null]],
  ['Nice', [true, 5, '2 weeks', 'wire-only'], [null, {}]],
  ['Inset', [0, -2, '$size'], [false, null]],
  ['Clamp', [false, '$clamp', 'wire-only'], [null, 1]],
  ['Round', [true, '$round'], [null, []]],
  ['Align', [0.5, 'wire-only'], [true, null]],
  ['Padding', [0, '$padding'], [false, null]],
  ['PaddingInner', [0.2, '$padding'], [null, {}]],
  ['PaddingOuter', [0.1, '$padding'], [false, []]],
  ['Axis', ['both', false, null, 'wire-only'], [1, {}]],
  ['Ticks', [4, 'day', [1, 2], '$ticks'], [false, null, { days: 1 }]],
  ['TickSize', [0, '$size'], [false, null]],
  ['TickSpacing', [30, '$size'], [true, {}]],
  ['TickPadding', [4, '$size'], [null, []]],
  ['TickFormat', ['.2f', null], [true, 1, {}]],
  ['TickRotate', [45, '$angle'], [false, null]],
  ['Grid', [false, 'day', [1, 2], '$grid'], [null, 4, { days: 1 }]],
  ['Line', [true, '$line'], [null, 1]],
  ['Label', ['Values', null], [false, {}]],
  ['LabelAnchor', ['top', 'left', 'center', 'wire-only'], [null, true]],
  ['LabelArrow', ['auto', true, false, null, 'wire-only'], [1, {}]],
  ['LabelOffset', [8, '$offset'], [null, false]],
  ['FontVariant', ['normal', '$font'], [null, 1]],
  ['AriaLabel', ['Values', '$label'], [null, false]],
  ['AriaDescription', ['A scale', '$description'], [null, {}]],
  ['Percent', [true, '$percent'], [null, []]],
  ['Reverse', [false, '$reverse'], [null, 1]],
  ['Zero', [true, '$zero'], [null, {}]],
  ['Exponent', [2, '$exponent'], [null, false]],
  ['Base', [10, '$base'], [null, {}]],
  ['Constant', [1, '$constant'], [null, []]]
];
const cases = [];
for (const axis of ['x', 'y']) {
  for (const [suffix, accepted, rejected] of suffixes) cases.push([axis + suffix, accepted, rejected]);
  for (const suffix of axis === 'x' ? ['InsetLeft', 'InsetRight'] : ['InsetTop', 'InsetBottom']) cases.push([axis + suffix, [2, '$inset'], [null, false]]);
}
cases.push(['xyDomain', [[0, 3], 'Fixed', '$domain'], [null, false, 1]]);

describe('Cartesian contract boundaries', () => {
  it.each(cases)('%s preserves definition admission and whole-schema admission', (name, accepted, rejected) => {
    const definition = ajv.getSchema(`cartesian-attributes#/definitions/PlotAttributes/properties/${name}`);
    for (const [values, expected] of [[accepted, true], [rejected, false]]) for (const value of values) {
      expect(definition(value), `${name}: ${JSON.stringify(value)}`).toBe(expected);
      expect(validate({ plot: [], [name]: value }), `${name}: ${JSON.stringify(value)}`).toBe(expected);
    }
  });

  it('keeps the mixed LabelArrow enum independent of ParamRef string widening', () => {
    const definition = ajv.getSchema('cartesian-attributes#/definitions/LabelArrow');
    expect(schema.definitions.LabelArrow).toEqual({ enum: ['auto', 'up', 'right', 'down', 'left', 'none', true, false, null], type: ['string', 'boolean', 'null'] });
    for (const value of ['auto', 'up', 'right', 'down', 'left', 'none', true, false, null]) expect(definition(value)).toBe(true);
    for (const value of ['middle', 'wire-only', 1, {}, []]) expect(definition(value)).toBe(false);
    expect(validate({ plot: [], xLabelArrow: 'wire-only' })).toBe(true);
  });

  it('keeps explicit nulls, paired directive identity and nested literal arrays in the parser', () => {
    const spec = /** @type {import('../src/index.js').Spec} */ ({ params: { first: 1, domain: [0, 4] }, plot: [], xAxis: null, yScale: null, xyDomain: '$domain', xTicks: ['$first', 2] });
    const ast = parseSpec(spec);
    expect(ast.toJSON()).toEqual(spec);
    expect(ast.root.attributes.map(attribute => attribute.name)).toEqual(['xAxis', 'yScale', 'xyDomain', 'xTicks']);
    expect(ast.root.attributes.find(attribute => attribute.name === 'xTicks').value.instantiate()).toEqual(['$first', 2]);
  });
});
