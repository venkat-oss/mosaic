import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { describe, expect, it } from 'vitest';
import { astToESM, astToPython, parseSpec } from '../src/index.js';

const schema = JSON.parse(await readFile(resolve(import.meta.dirname, '../dist/mosaic-schema.json'), 'utf8'));
const ajv = new Ajv({ allowUnionTypes: true, allErrors: true });
addFormats.default(ajv);
ajv.addSchema(schema, 'size-projection');
const validate = ajv.getSchema('size-projection');
const cases = /** @type {Array<[string, any[], any[]]>} */ ([
  ['rScale', ['sqrt', null, '$scale', 'wire-only'], [false, 1, {}, []]],
  ['rDomain', [[0, 10], [{}], 'Fixed', 'wire-only'], [null, false, {}]],
  ['rRange', [[2, 12], [null], 'Fixed', '$range'], [null, true, {}]],
  ['rClamp', [null, true, 1, 'value', {}, []], []],
  ['rNice', [false, 5, 'month', '$nice'], [null, {}, []]],
  ['rLabel', ['Radius', null, '$label'], [false, 1, {}, []]],
  ['rPercent', [true, false, '$percent', 'wire-only'], [null, 1, {}]],
  ['rZero', [true, false, '$zero'], [null, 0, []]],
  ['rExponent', [2, -1, '$exponent', 'wire-only'], [null, true, {}]],
  ['rBase', [2, '$base'], [null, false, []]],
  ['rConstant', [0.5, '$constant'], [null, false, {}]],
  ['lengthScale', ['linear', null, '$scale', 'wire-only'], [false, 1, {}, []]],
  ['lengthDomain', [[-10, -1], [{}], 'Fixed', '$domain'], [null, false, {}]],
  ['lengthRange', [[4, 24], [null], 'Fixed', '$range'], [null, true, {}]],
  ['lengthClamp', [null, false, 0, 'value', {}, []], []],
  ['lengthNice', [true, 5, 'day', '$nice'], [null, {}, []]],
  ['lengthPercent', [true, false, '$percent'], [null, 1, {}]],
  ['lengthZero', [true, false, '$zero'], [null, 0, []]],
  ['lengthExponent', [2, -1, '$exponent'], [null, true, {}]],
  ['lengthBase', [2, '$base'], [null, false, []]],
  ['lengthConstant', [0.5, '$constant'], [null, false, {}]],
  ['projectionType', ['mercator', null, '$projection', 'wire-only'], [false, 1, {}, []]],
  ['projectionDomain', [{}, { type: 'Sphere' }, { custom: [1] }, '$domain'], [null, false, 1, []]],
  ['projectionRotate', [[10, 20, 0], ['$longitude', 20, 0], '$rotation'], [[10, 20], [0, 0, 0, 0], [false, 0, 0], null, {}]],
  ['projectionParallels', [[29.5, 45.5], ['$south', '$north'], '$parallels'], [[29.5], [0, 0, 0], [false, 0], null, {}]],
  ['projectionPrecision', [0.2, '$precision'], [null, true, {}]],
  ['projectionClip', ['frame', null, true, false, 120, '$clip', 'wire-only'], [{}, []]],
  ['projectionInset', [0, -5, '$inset'], [null, false, {}]],
  ['projectionInsetTop', [10, '$inset'], [null, false, []]],
  ['projectionInsetRight', [20, '$inset'], [null, false, {}]],
  ['projectionInsetBottom', [30, '$inset'], [null, false, []]],
  ['projectionInsetLeft', [40, '$inset'], [null, false, {}]]
]);

describe('size and projection attribute wire contracts', () => {
  it.each(cases)('%s preserves the field and complete-spec boundaries', (name, accepted, rejected) => {
    for (const owner of ['PlotAttributes', 'Plot']) {
      const field = ajv.getSchema(`size-projection#/definitions/${owner}/properties/${name}`);
      expect(field).toBeTypeOf('function');
      for (const value of accepted) expect(field(value), JSON.stringify(value)).toBe(true);
      for (const value of rejected) expect(field(value), JSON.stringify(value)).toBe(false);
    }
    for (const value of accepted) expect(validate({ plot: [], [name]: value }), JSON.stringify(value)).toBe(true);
    for (const value of rejected) expect(validate({ plot: [], [name]: value }), JSON.stringify(value)).toBe(false);
  });

  it('retains positional tuple titles and the existing three-item wire rotation', () => {
    const { projectionRotate, projectionParallels } = schema.definitions.PlotAttributes.properties;
    expect(projectionRotate.anyOf[0]).toMatchObject({
      type: 'array', minItems: 3, maxItems: 3,
      items: [{ title: 'x' }, { title: 'y' }, { title: 'z' }]
    });
    expect(projectionParallels.anyOf[0]).toMatchObject({
      type: 'array', minItems: 2, maxItems: 2,
      items: [{ title: 'y1' }, { title: 'y2' }]
    });
  });

  it('keeps scalar parameters, Fixed ranges and nested tuple references on their existing parser paths', () => {
    const spec = /** @type {import('../src/index.js').Spec} */ ({
      params: { spacing: 8, longitude: 10 }, plot: [],
      rRange: 'Fixed', lengthRange: '$spacing', projectionRotate: ['$longitude', 0, 0]
    });
    const ast = parseSpec(spec);
    expect(ast.toJSON()).toEqual(spec);
    expect(ast.root.attributes[1].value).toMatchObject({ type: 'paramref', name: 'spacing' });
    expect(ast.root.attributes[2].value.instantiate()).toEqual(['$longitude', 0, 0]);
    expect(astToESM(ast)).toContain('vg.rRange(vg.Fixed)');
    expect(astToESM(ast)).toContain('vg.lengthRange($spacing)');
    expect(astToESM(ast)).toContain('vg.projectionRotate(["$longitude", 0, 0])');
    expect(astToPython(ast)).toContain('vg.r_range("Fixed")');
    expect(astToPython(ast)).toContain('vg.length_range(spacing)');
    expect(astToPython(ast)).toContain('vg.projection_rotate([longitude, 0, 0])');
  });
});
