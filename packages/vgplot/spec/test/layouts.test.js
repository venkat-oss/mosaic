import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { describe, expect, it, vi } from 'vitest';
import { astToESM, astToPython, parseSpec } from '../src/index.js';
import { componentMap } from '../src/config/components.js';

const schema = JSON.parse(await readFile(resolve(import.meta.dirname, '../dist/mosaic-schema.json'), 'utf8'));
const ajv = new Ajv({ allowUnionTypes: true, allErrors: true });
addFormats.default(ajv);
ajv.addSchema(schema, 'layouts');
const validate = ajv.getSchema('layouts');
const cases = /** @type {Array<[string, any[], any[]]>} */ ([
  ['HConcat', [{ hconcat: [] }, { hconcat: [{ hspace: 12 }, { vconcat: [{ plot: [] }] }] }], [{}, { hconcat: [[{ plot: [] }]] }, { hconcat: [], wrap: true }, { hconcat: [{ unknown: [] }] }]],
  ['VConcat', [{ vconcat: [] }, { vconcat: [{ vspace: '2em' }] }], [{ vconcat: null }, { vconcat: [{ vspace: null }] }, { vconcat: [], width: 300 }]],
  ['HSpace', [{ hspace: 0 }, { hspace: -1.5 }, { hspace: '' }, { hspace: '$literal' }], [{ hspace: null }, { hspace: {} }, { hspace: true }, { hspace: 3, extra: true }]],
  ['VSpace', [{ vspace: 2.5 }, { vspace: '1.5em' }, { vspace: 'not CSS' }], [{}, { vspace: [] }, { vspace: false }]]
]);
const definitions = new Map(cases.map(([name]) => [name, ajv.getSchema(`layouts#/definitions/${name}`)]));

describe('layout wire and parser contracts', () => {
  it.each(cases)('%s preserves independent positive and negative cases', (name, accepted, rejected) => {
    const definition = definitions.get(name);
    for (const value of accepted) expect(definition(value), JSON.stringify(value)).toBe(true);
    for (const value of rejected) expect(definition(value), JSON.stringify(value)).toBe(false);
  });

  it('preserves recursive child order, defaults, named params and generated code in both languages', () => {
    const spec = /** @type {import('../src/index.js').Spec} */ ({
      params: { radius: 4 },
      plotDefaults: { width: 180 },
      hconcat: [{ hspace: 0 }, { vconcat: [{ plot: [{ mark: 'dot', data: [{}], r: '$radius' }] }, { vspace: '2em' }] }]
    });
    expect(validate(spec)).toBe(true);
    const ast = parseSpec(spec);
    expect(ast.toJSON()).toEqual(spec);
    expect(parseSpec(ast.toJSON()).toJSON()).toEqual(spec);
    const js = astToESM(ast);
    const py = astToPython(ast);
    expect(js).toContain('vg.hspace(0)');
    expect(js).toContain('vg.vspace("2em")');
    expect(js.indexOf('vg.hspace(0)')).toBeLessThan(js.indexOf('vg.vconcat('));
    expect(py).toContain('vg.hspace(0)');
    expect(py).toContain('vg.vspace("2em")');
    expect(py).toContain('plot_defaults=');
    expect(py).toContain('r=radius');
  });

  it('keeps dollar-prefixed spacer strings literal and does not allocate a parameter', () => {
    const ast = parseSpec({ hspace: '$size' });
    expect(ast.toJSON()).toEqual({ hspace: '$size' });
    expect(ast.params).toEqual({});
    expect(astToESM(ast)).toContain('vg.hspace("$size")');
  });

  it('preserves parser registration precedence and final overrides', () => {
    expect([...componentMap().keys()]).toEqual(['plot', 'mark', 'legend', 'input', 'hconcat', 'vconcat', 'hspace', 'vspace']);
    const node = { toJSON: () => ({ custom: true }) };
    const override = vi.fn(() => node);
    const ast = parseSpec({ hconcat: [], vconcat: [] }, { components: componentMap([['hconcat', override]]) });
    expect(ast.root).toBe(node);
    expect(override).toHaveBeenCalledExactlyOnceWith({ hconcat: [], vconcat: [] }, expect.anything());
    expect(parseSpec({ hconcat: [], vconcat: [] }).toJSON()).toEqual({ hconcat: [] });
  });
});
