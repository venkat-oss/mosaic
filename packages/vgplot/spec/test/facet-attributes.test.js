import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { describe, expect, it } from 'vitest';
import { parseSpec } from '../src/index.js';

const schema = JSON.parse(await readFile(resolve(import.meta.dirname, '../dist/mosaic-schema.json'), 'utf8'));
const ajv = new Ajv({ allowUnionTypes: true, allErrors: true });
addFormats.default(ajv);
ajv.addSchema(schema, 'facet-attributes');
const validate = ajv.getSchema('facet-attributes');
const suffixes = [
  ['Domain', [[], [1, 2], 'Fixed', 'wire-only'], [null, false, 1]],
  ['Range', [[20, 180], 'Fixed', '$range'], [null, true, {}]],
  ['Inset', [0, -2, '$inset'], [null, false]],
  ['Round', [false, '$round'], [null, 1]],
  ['Align', [0.5, 'wire-only'], [null, false]],
  ['Padding', [0.2, '$padding'], [null, []]],
  ['PaddingInner', [0, '$padding'], [null, false]],
  ['PaddingOuter', [0.1, '$padding'], [null, {}]],
  ['Axis', ['both', false, null, 'wire-only'], [1, {}]],
  ['Ticks', [4, 'day', [1, 2], '$ticks'], [null, false, { days: 1 }]],
  ['TickSize', [4, '$size'], [null, true]],
  ['TickSpacing', [40, '$spacing'], [null, []]],
  ['TickPadding', [4, '$padding'], [null, {}]],
  ['TickFormat', ['.1f', null], [false, 1]],
  ['TickRotate', [30, '$angle'], [null, false]],
  ['Grid', [true, 'day', [1, 2], '$grid'], [null, 4, { days: 1 }]],
  ['Line', [false, '$line'], [null, {}]],
  ['Label', ['Groups', null], [false, 1]],
  ['LabelAnchor', ['top', 'left', 'center', 'wire-only'], [null, true]],
  ['LabelOffset', [30, '$offset'], [null, false]],
  ['FontVariant', ['normal', '$font'], [null, 1]],
  ['AriaLabel', ['Groups', '$label'], [null, false]],
  ['AriaDescription', ['The grouping', '$description'], [null, []]],
  ['Reverse', [true, '$reverse'], [null, 1]]
];
const cases = [];
for (const axis of ['fx', 'fy']) {
  for (const [suffix, accepted, rejected] of suffixes) cases.push([axis + suffix, accepted, rejected]);
  for (const suffix of axis === 'fx' ? ['InsetLeft', 'InsetRight'] : ['InsetTop', 'InsetBottom']) cases.push([axis + suffix, [4, '$inset'], [null, false]]);
}
for (const suffix of ['Margin', 'MarginTop', 'MarginBottom', 'MarginLeft', 'MarginRight']) cases.push(['facet' + suffix, [12, '$margin'], [null, false]]);
cases.push(['facetGrid', [true, 'day', [1, 2]], [null, 4, {}]]);
cases.push(['facetLabel', ['Groups', null], [true, 1]]);

describe('facet attribute wire boundaries', () => {
  it.each(cases)('%s preserves definition and whole-spec admission', (name, accepted, rejected) => {
    const definition = ajv.getSchema(`facet-attributes#/definitions/PlotAttributes/properties/${name}`);
    for (const [values, expected] of [[accepted, true], [rejected, false]]) for (const value of values) {
      expect(definition(value), `${name}: ${JSON.stringify(value)}`).toBe(expected);
      expect(validate({ plot: [], [name]: value }), `${name}: ${JSON.stringify(value)}`).toBe(expected);
    }
  });

  it('preserves ordered scalar axis and anchor branches rather than merging their enums', () => {
    const properties = schema.definitions.PlotAttributes.properties;
    expect(properties.fxAxis.anyOf).toEqual([
      { type: 'string', const: 'top' }, { type: 'string', const: 'bottom' }, { type: 'string', const: 'both' },
      { type: 'boolean' }, { type: 'null' }, { $ref: '#/definitions/ParamRef' }
    ]);
    expect(properties.fyAxis.anyOf.slice(0, 3)).toEqual([{ type: 'string', const: 'left' }, { type: 'string', const: 'right' }, { type: 'string', const: 'both' }]);
    expect(properties.fxLabelAnchor.anyOf.slice(0, 5).map(value => value.const)).toEqual(['top', 'right', 'bottom', 'left', 'center']);
    expect(properties.fyLabelAnchor).toEqual(properties.fxLabelAnchor);
  });

  it('keeps explicit nulls and nested literal arrays while rejecting an invented facet scale attribute', () => {
    const spec = /** @type {import('../src/index.js').Spec} */ ({ params: { first: 1, domain: [1, 2] }, plot: [], fxAxis: null, fyLabel: null, fxDomain: '$domain', fyTicks: ['$first', 2] });
    const ast = parseSpec(spec);
    expect(ast.toJSON()).toEqual(spec);
    expect(ast.root.attributes.find(attribute => attribute.name === 'fyTicks').value.instantiate()).toEqual(['$first', 2]);
    expect(validate({ plot: [], fxScale: 'band' })).toBe(false);
    expect(() => parseSpec(/** @type {any} */ ({ plot: [], fxScale: 'band' }))).toThrow('Unrecognized attribute: fxScale');
  });
});
