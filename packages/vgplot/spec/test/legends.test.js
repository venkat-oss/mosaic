import { readFile } from 'node:fs/promises';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { createAPIContext } from '@uwdata/vgplot';
import { describe, expect, it } from 'vitest';
import { parse as parseYAML } from 'yaml';
import { astToESM, astToPython, parseSpec } from '../src/index.js';
import { InstantiateContext } from '../src/ast-to-dom.js';
import { plotNames } from '../src/config/plots.js';

const channels = /** @type {const} */ (['color','opacity','symbol']);
const schema = JSON.parse(await readFile(
  new URL('../dist/mosaic-schema.json', import.meta.url), 'utf8'
));
const ajv = new Ajv({ allowUnionTypes: true });
addFormats.default(ajv);
const validate = ajv.compile(schema);

describe.each(channels)('%s legend specifications', channel => {
  if (channel === 'color') it.each(['templates'])('consumes JSON and YAML templates in %s', async directory => {
    const root = new URL(`../../../../${directory}/legends/`, import.meta.url);
    const json = JSON.parse(await readFile(new URL(`${channel}.json`, root), 'utf8'));
    const yaml = parseYAML(await readFile(new URL(`${channel}.yaml`, root), 'utf8'));
    const data = [
      { x: 1, y: 2, category: 'A', alpha: 0.3 },
      { x: 2, y: 1, category: 'B', alpha: 0.7 },
      { x: 3, y: 3, category: 'A', alpha: 1 },
    ];
    const encoding = 'fill';
    const field = 'category';
    const expected = {
      data: { legend_data: data },
      params: { brush: { select: 'crossfilter' } },
      plot: [
        {
          mark: 'dot',
          data: { from: 'legend_data', filterBy: '$brush' },
          x: 'x',
          y: 'y',
          [encoding]: field,
        },
        { legend: channel, as: '$brush', field },
      ],
    };
    for (const spec of [json, yaml]) {
      expect(spec).toEqual(expected);
      expect(validate(spec)).toBe(true);
      const ast = parseSpec(spec);
      const normalized = {
        ...expected,
        data: { legend_data: { type: 'json', data } },
      };
      expect(ast.toJSON()).toEqual(normalized);
      expect(parseSpec(ast.toJSON()).toJSON()).toEqual(normalized);
      expect(astToESM(ast)).toContain(`vg.${channel}Legend(`);
    }
  });

  it.each([false, true])('round trips and generates executable JS (standalone=%s)', standalone => {
    const options = { as: /** @type {const} */ ('$brush'), field: 'category', label: 'Categories', columns: 2 };
    const legend = { legend: channel, ...options, ...(standalone ? { for: 'chart' } : {}) };
    const root = standalone ? legend : { plot: [legend] };
    const spec = { params: { brush: { select: /** @type {const} */ ('single') } }, ...root };
    const ast = parseSpec(/** @type {import('../src/spec/Spec.js').Spec} */ (spec));

    expect(ast.toJSON()).toEqual(spec);
    expect(parseSpec(ast.toJSON()).toJSON()).toEqual(spec);

    const selection = {};
    const api = {
      Selection: { single: () => selection },
      plot: (...items) => ({ plot: items }),
      [`${channel}Legend`]: opts => ({ legend: channel, ...opts }),
    };
    const code = astToESM(ast, { imports: new Map() });
    const result = new Function('vg', code.replace('export default ', 'return '))(api);
    const expected = { ...legend, as: selection };
    expect(result).toEqual(standalone ? expected : { plot: [expected] });

    const python = astToPython(ast);
    expect(python).toContain(`vg.${channel}_legend(`);
    expect(python).toContain('bind=brush');
    expect(python).toContain('field="category"');
    if (standalone) expect(python).toContain('plot="chart"');
    else expect(python).not.toContain('plot="chart"');
  });

  it('preserves the complete schema option surface', () => {
    const legend = {
      legend: channel,
      as: /** @type {const} */ ('$brush'),
      field: 'category',
      label: 'Categories',
      tickSize: 4,
      marginTop: 1,
      marginRight: 2,
      marginBottom: 3,
      marginLeft: 4,
      width: 180,
      height: 30,
      columns: 2,
    };
    expect(validate({ plot: [legend] })).toBe(true);
    expect(validate({ ...legend, for: 'chart' })).toBe(true);
    expect(parseSpec({ plot: [legend] }).toJSON()).toMatchObject({ plot: [legend] });
  });

  it('requires a named plot only for standalone schema components', () => {
    expect(validate({ legend: channel })).toBe(false);
    expect(validate({ legend: channel, for: 'chart' })).toBe(true);
    expect(validate({ legend: channel, for: { value: {} } })).toBe(false);
    expect(validate({ plot: [{ legend: channel }] })).toBe(true);
    expect(validate({ plot: [{ legend: channel, as: 'brush' }] })).toBe(true);
    expect(validate({ plot: [{ legend: channel, for: 'chart' }] })).toBe(false);
  });

  it.each([
    { label: null },
    { label: 1 },
    { field: 1 },
    { as: 1 },
    { columns: 'two' },
    { width: '180px' },
    { tickSize: false },
    { unknownOption: true },
  ])('rejects invalid schema options %j', options => {
    expect(validate({ plot: [{ legend: channel, ...options }] })).toBe(false);
    expect(validate({ legend: channel, for: 'chart', ...options })).toBe(false);
  });
});

describe('unknown legend types', () => {
  it('fails parsing and schema validation for inline and standalone legends', () => {
    for (const spec of [
      { plot: [{ legend: 'size' }] },
      { legend: 'size', for: 'chart' },
    ]) {
      expect(validate(spec)).toBe(false);
      expect(() => parseSpec(/** @type {any} */ (spec))).toThrow('Unrecognized legend type: size');
    }
  });

  it('supports explicitly registered custom legend APIs', () => {
    const spec = { legend: 'size', for: 'chart', label: 'Radius' };
    const ast = parseSpec(/** @type {any} */ (spec), {
      plot: plotNames({ legends: new Set(['sizeLegend']) }),
    });
    expect(ast.toJSON()).toEqual(spec);
    expect(astToESM(ast)).toContain('vg.sizeLegend({for: "chart", label: "Radius"})');

    const calls = [];
    const api = createAPIContext({
      extensions: {
        sizeLegend(options) {
          calls.push({ receiver: this, options });
          return 'custom legend';
        },
      },
    });
    expect(ast.root.instantiate(new InstantiateContext({ api }))).toBe('custom legend');
    expect(calls).toEqual([{ receiver: api, options: { for: 'chart', label: 'Radius' } }]);
  });
});
