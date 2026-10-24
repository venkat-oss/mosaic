import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { describe, expect, it } from 'vitest';
import { astToESM, astToPython, parseSpec } from '../src/index.js';

const schema = JSON.parse(await readFile(resolve(import.meta.dirname, '../dist/mosaic-schema.json'), 'utf8'));
const ajv = new Ajv({ allowUnionTypes: true, allErrors: true });
addFormats.default(ajv);
ajv.addSchema(schema, 'plot-attributes');
const validate = ajv.getSchema('plot-attributes');
const cases = /** @type {Array<[string, any[], any[]]>} */ ([
  ['name', ['chart', ''], [null, 1, true]],
  ['width', [320, 0, '$dimension', 'wire-only'], [null, true, {}]],
  ['height', [200, -1.5, '$dimension'], [null, false, []]],
  ['aspectRatio', [1.5, false, null, 'wire-only'], [{}, []]],
  ['margin', [18, '$spacing'], [null, false]],
  ['marginTop', [24, '$spacing'], [null, {}]],
  ['marginRight', [16, '$spacing'], [false, []]],
  ['marginBottom', [28, '$spacing'], [null, true]],
  ['marginLeft', [36, '$spacing'], [{}, false]],
  ['margins', [{}, { top: 0, right: '$spacing' }], [null, 3, { unknown: 1 }, { top: false }]],
  ['inset', [4, '$spacing'], [null, false]],
  ['style', [null, 'color: red;', { color: 'red', length: 2 }, { custom: 'wire-only' }], [{ color: 2 }, { length: '2' }]],
  ['align', [0.5, 'wire-only'], [null, false]],
  ['padding', [0.2, '$padding'], [null, {}]],
  ['axis', ['both', false, null, 'wire-only'], [1, {}]],
  ['grid', [true, '#ccc', '$grid'], [null, 1, {}]],
  ['ariaLabel', ['Container', null], [true, {}]],
  ['ariaDescription', ['Three points', null], [1, []]],
  ['clip', ['frame', 'sphere', true, null, 'wire-only'], [1, {}]]
]);
const definitions = new Map(cases.map(([name]) => [name, ajv.getSchema(`plot-attributes#/definitions/PlotAttributes/properties/${name}`)]));

describe('plot/container attribute contracts', () => {
  it.each(cases)('%s keeps its current definition and complete-spec boundaries', (name, accepted, rejected) => {
    const definition = definitions.get(name);
    for (const value of accepted) {
      expect(definition(value), JSON.stringify(value)).toBe(true);
      expect(validate({ plot: [], [name]: value }), JSON.stringify(value)).toBe(true);
    }
    for (const value of rejected) {
      expect(definition(value), JSON.stringify(value)).toBe(false);
      expect(validate({ plot: [], [name]: value }), JSON.stringify(value)).toBe(false);
    }
  });

  it('preserves margin keyword codegen and its admitted-but-literal nested parameter refs', () => {
    const spec = /** @type {import('../src/index.js').Spec} */ ({ params: { spacing: 8 }, plot: [], margins: { top: '$spacing', right: 12 } });
    const ast = parseSpec(spec);
    expect(ast.toJSON()).toEqual(spec);
    expect(ast.root.attributes[0].value.instantiate()).toEqual({ top: '$spacing', right: 12 });
    expect(astToESM(ast)).toContain('vg.margins({top: "$spacing", right: 12})');
    expect(astToPython(ast)).toContain('vg.margins(top=spacing, right=12)');
  });

  it('accepts the three missing-route attributes without inventing a public label attribute', () => {
    for (const [name, value] of [['ariaLabel', 'Chart'], ['ariaDescription', 'Description'], ['clip', 'frame']]) {
      const spec = { plot: [], [name]: value };
      expect(validate(spec)).toBe(true);
      expect(parseSpec(spec).toJSON()).toEqual(spec);
    }
    expect(validate({ plot: [], label: 'Measure' })).toBe(false);
    expect(() => parseSpec(/** @type {any} */ ({ plot: [], label: 'Measure' }))).toThrow('Unrecognized attribute: label');
  });
});
