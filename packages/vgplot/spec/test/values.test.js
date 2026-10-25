// @vitest-environment jsdom
import { columnParts } from '@uwdata/mosaic-sql';
import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { describe, expect, it } from 'vitest';
import * as vg from '@uwdata/vgplot';
import { astToDOM, astToESM, parseSpec } from '../src/index.js';

const schema = JSON.parse(await readFile(resolve(import.meta.dirname, '../dist/mosaic-schema.json'), 'utf8'));
const validator = new Ajv({ allowUnionTypes: true });
addFormats.default(validator);
validator.addSchema(schema, 'current-values');

const cases = [
  ['Fixed', ['Fixed'], ['fixed', null, 0]],
  ['TimeIntervalName', ['half', 'sunday'], ['halfs', 'SUNDAY', 'millisecond']],
  ['LiteralTimeInterval', ['3 months', '-1.5 months', 'a custom wire interval', ''], [3, null, {}]],
  ['Interval', ['month', 'a custom wire interval'], [3, null]],
  ['ScaleName', ['fx', 'length'], ['area', 'X']],
  ['PositionScaleType', ['band', 'quantile'], ['ordinal', 'categorical']],
  ['ColorScaleType', ['diverging-symlog', 'categorical'], ['cyclic', 'logarithmic']],
  ['ContinuousScaleType', ['utc', 'symlog'], ['band', 'ordinal']],
  ['DiscreteScaleType', ['ordinal', 'identity'], ['linear', 'band']],
  ['ProjectionName', ['reflect-y', 'albers-usa'], ['natural-earth', 'Mercator']],
  ['Interpolate', ['hcl', 'number'], ['turbo', 'RGB']],
  ['ColorScheme', ['YlGnBu', 'Observable10', {}, { arbitrary: true }], ['ylgnbu', 'YLGNBU', null]],
  ['SymbolType', ['triangle2', 'wye'], ['triangle3', 'Circle']],
  ['FrameAnchor', ['middle', 'bottom-left'], ['center', 'left-top']],
  ['ReducerPercentile', ['p00', 'p01', 'p99'], ['p0', 'p100', 'p-1', 'P50']],
  ['Reducer', ['proportion-facet', 'p00', 'p99'], ['p100', 'average']],
  ['CurveName', ['catmull-rom-closed', 'step-before'], ['bezier', 'STEP']],
  ['CSSStyles', [{ color: 'purple', length: 2 }, { mosaicUnknown: 'wire-only' }, { '0': 'color' }],
    [{ color: 3 }, { length: '2' }, { mosaicUnknown: 3 }, null]]
];
const validateSpec = validator.getSchema('current-values');
const definitions = new Map(cases.map(([name]) => [name, validator.getSchema(`current-values#/definitions/${name}`)]));

describe('shared value wire contracts', () => {
  it.each(cases)('%s preserves independent positive and negative definition cases', (name, accepted, rejected) => {
    const validate = definitions.get(name);
    expect(validate, `Missing public value definition ${name}`).toBeTypeOf('function');
    for (const value of accepted) expect(validate(value), JSON.stringify(value)).toBe(true);
    for (const value of rejected) expect(validate(value), JSON.stringify(value)).toBe(false);
  });

  it('preserves complete specification admission separately from value definitions', () => {
    const validate = validateSpec;
    expect(validate({ plot: [], style: { mosaicUnknown: 'wire-only', length: 2 } })).toBe(true);
    expect(validate({ plot: [], style: { length: '2' } })).toBe(false);
    expect(validate({ plot: [], colorScheme: 'ylgnbu' })).toBe(true);
    expect(validate({ plot: [], colorScheme: 'YLGNBU' })).toBe(true);
    expect(validate({ plot: [{ mark: 'ruleX', interval: 'a custom wire interval' }] })).toBe(true);
    expect(validate({ plot: [{ mark: 'ruleX', interval: 3 }] })).toBe(false);
  });

  it('uses the symbol vocabulary in the runtime while preserving case-insensitive constant lookup', () => {
    const marks = [];
    const plot = { addMark: mark => marks.push(mark) };
    vg.dot([{}], { symbol: 'TRIANGLE2' })(plot);
    vg.dot([{}], { symbol: 'triangle3' })(plot);
    expect(marks[0].channel('symbol')).toEqual({ channel: 'symbol', value: 'TRIANGLE2' });
    expect(columnParts(marks[1].channel('symbol').field).at(-1)).toBe('triangle3');
    expect(definitions.get('SymbolType')('TRIANGLE2')).toBe(false);
  });

  it('keeps bare interval strings as fields and explicit parameters as constant interval values', () => {
    const marks = [];
    const plot = { addMark: mark => marks.push(mark) };
    vg.dotX(vg.from('data'), { interval: 'day' })(plot);
    vg.dotX(vg.from('data'), { interval: vg.Param.value('day') })(plot);
    expect(columnParts(marks[0].channel('interval').field).at(-1)).toBe('day');
    expect(marks[0].channel('interval')).not.toHaveProperty('value');
    expect(marks[1].channel('interval')).toEqual({ channel: 'interval', value: 'day' });
    expect(marks[1].channel('interval')).not.toHaveProperty('field');
  });

  it('passes parsed dates, Fixed identity and CSS styles through a real rendered plot', async () => {
    const spec = /** @type {import('../src/index.js').Spec} */ ({
      params: { when: { date: '2024-01-02T03:04:05Z' } },
      plot: [{ mark: 'dot', data: [{}], x: '$when', y: 2 }],
      xScale: 'utc',
      xDomain: 'Fixed',
      style: { color: 'purple', fontSize: '13px' }
    });
    const ast = parseSpec(spec);
    expect(ast.toJSON()).toEqual(spec);
    expect(astToESM(ast)).toContain('new Date("2024-01-02T03:04:05Z")');
    const coordinator = new vg.Coordinator();
    try {
      const { element, params } = await astToDOM(ast, { api: vg.createAPIContext({ coordinator }) });
      const plot = /** @type {any} */ (element).value;
      expect(plot.getAttribute('xDomain')).toBe(vg.Fixed);
      expect(params.get('when').value).toBeInstanceOf(Date);
      expect(params.get('when').value.toISOString()).toBe('2024-01-02T03:04:05.000Z');
      await plot.synch.promise;
      const svg = element.querySelector('svg');
      expect(svg).not.toBeNull();
      expect(svg.style.color).toBe('purple');
      expect(svg.style.fontSize).toBe('13px');
      expect(plot.getAttribute('xDomain').every(value => value instanceof Date)).toBe(true);
      expect(plot.marks[0].channel('x').value).toBe(params.get('when').value);
    } finally {
      coordinator.clear();
    }
  });
});
