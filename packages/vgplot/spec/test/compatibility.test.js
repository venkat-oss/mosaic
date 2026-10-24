import { readFile } from 'node:fs/promises';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { describe, expect, it, vi } from 'vitest';
import { Param, Selection } from '@uwdata/mosaic-core';
import * as vg from '@uwdata/vgplot';
import { parseSpec, ParamNode, SelectionNode, PlotFixedNode } from '../src/index.js';
import { componentMap } from '../src/config/components.js';
import { inputNames } from '../src/config/inputs.js';

const schema = JSON.parse(await readFile(
  new URL('../dist/mosaic-schema.json', import.meta.url), 'utf8'
));
const validator = new Ajv({ allowUnionTypes: true });
addFormats.default(validator);
validator.addSchema(schema, 'current');
const validate = validator.getSchema('current');
const colorScheme = validator.getSchema('current#/definitions/ColorScheme');

describe('declarative compatibility', () => {
  it('distinguishes ColorScheme definition admission from plot attribute admission', () => {
    expect(colorScheme('YlGnBu')).toBe(true);
    expect(colorScheme({})).toBe(true);
    expect(colorScheme('ylgnbu')).toBe(false);
    expect(colorScheme('YLGNBU')).toBe(false);
    expect(colorScheme(null)).toBe(false);
    expect(colorScheme(1)).toBe(false);

    for (const value of ['YlGnBu', 'ylgnbu', 'YLGNBU', {}]) {
      expect(validate({ plot: [], colorScheme: value })).toBe(true);
    }
  });

  it('admits RuleXOptions on ruleY rather than RuleYOptions', () => {
    const accepted = { plot: [{ mark: /** @type {const} */ ('ruleY'), y1: 1, y2: 2, insetTop: 3 }] };
    expect(validate(accepted)).toBe(true);
    expect(parseSpec(accepted).toJSON()).toEqual(accepted);
    expect(validate({ plot: [{ mark: 'ruleY', x1: 1 }] })).toBe(false);
    expect(validate({ plot: [{ mark: 'ruleY', insetLeft: 3 }] })).toBe(false);
  });

  it.each(/** @type {const} */ (['circle', 'hexagon']))('admits the symbol option on %s', mark => {
    const spec = { plot: [{ mark, data: [{}], symbol: 'star' }] };
    expect(validate(spec)).toBe(true);
    expect(parseSpec(spec).toJSON()).toEqual(spec);
    expect(validate({ plot: [{ mark, data: [{}], symbol: {} }] })).toBe(false);
  });

  it.each(['select', 'checkbox'])('requires an extension for the %s input', name => {
    const spec = /** @type {any} */ ({ input: name, label: 'Choose' });
    expect(() => parseSpec(spec)).toThrow(`Unrecognized input type: ${name}`);
    const ast = parseSpec(spec, { inputs: inputNames([name]) });
    const input = vi.fn().mockReturnValue('custom element');
    expect(ast.toJSON()).toEqual(spec);
    expect(ast.root.instantiate({ api: { [name]: input } })).toBe('custom element');
    expect(input).toHaveBeenCalledExactlyOnceWith({ label: 'Choose' });
  });

  it('keeps component override precedence and parser context', () => {
    const customNode = { toJSON: () => ({ custom: true }) };
    const override = vi.fn().mockReturnValue(customNode);
    const later = vi.fn();
    const components = componentMap([['plot', override], ['custom', later]]);
    const spec = { plot: [], custom: true };
    const ast = parseSpec(spec, { components });
    expect(ast.root).toBe(customNode);
    expect(override).toHaveBeenCalledExactlyOnceWith(
      spec, expect.objectContaining({ components })
    );
    expect(later).not.toHaveBeenCalled();
  });

  it('preserves native Param, Selection, and Fixed identities across the public API', () => {
    expect(vg.Param).toBe(Param);
    expect(vg.Selection).toBe(Selection);
    const ast = parseSpec({
      params: { value: 7, brush: { select: 'crossfilter' } },
      plot: [],
      xDomain: 'Fixed'
    });
    const context = { api: vg };
    expect(ast.params.value).toBeInstanceOf(ParamNode);
    expect(ast.params.brush).toBeInstanceOf(SelectionNode);
    expect(ast.params.value.instantiate(context)).toBeInstanceOf(Param);
    expect(ast.params.brush.instantiate(context)).toBeInstanceOf(Selection);
    const fixed = ast.root.attributes[0].value;
    expect(fixed).toBeInstanceOf(PlotFixedNode);
    expect(fixed.instantiate(context)).toBe(vg.Fixed);
    expect(fixed.toJSON()).toBe('Fixed');
  });
});
