// @vitest-environment jsdom
import { compile, asNode, createExecutionContext } from '@uwdata/mosaic-sql';
import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { describe, expect, it } from 'vitest';
import { Param, Selection } from '@uwdata/mosaic-core';
import * as vg from '@uwdata/vgplot';
import { astToDOM, astToESM, CodegenContext, ParamNode, ParamRefNode, parseSpec } from '../src/index.js';
import { ColumnParamRefNode } from '../src/ast/ColumnParamRefNode.js';

const schema = JSON.parse(await readFile(resolve(import.meta.dirname, '../dist/mosaic-schema.json'), 'utf8'));
const validator = new Ajv({ allowUnionTypes: true });
addFormats.default(validator);
validator.addSchema(schema, 'current-params');
const validateSpec = validator.getSchema('current-params');
const cases = [
  ['ParamRef', ['$value', '$$column', '$', 'ordinary'], [null, 1, { param: 'value' }]],
  ['ParamLiteral', [null, 'text', 0, false], [[], {}]],
  ['ParamValue', [null, '$literal', [], ['$value', 2, false, null]], [[[]], { value: 1 }]],
  ['Param', [{ value: null }, { select: 'value', value: ['$x', 4] }], [{}, { value: {} }, { value: 1, extra: true }]],
  ['ParamDate', [{ date: '' }, { date: 'not-a-date' }, { select: 'value', date: '2024-01-01' }], [{ date: 1 }, { date: '2024-01-01', value: 2 }]],
  ['Selection', [{ select: 'intersect' }, { select: 'crossfilter', cross: false }, { select: 'union', empty: true, include: ['plain', '$upstream'] }], [{}, { select: 'value' }, { select: 'single', include: { param: 'upstream' } }, { select: 'union', empty: 1 }]],
  ['ParamDefinition', [null, [1, '$x'], { value: 1 }, { date: '' }, { select: 'single' }], [{ select: 'unknown' }, { value: [[1]] }]]
];
const definitions = new Map(cases.map(([name]) => [name, validator.getSchema(`current-params#/definitions/${name}`)]));

describe('parameter wire boundaries', () => {
  it.each(cases)('%s preserves independent definition admission', (name, accepted, rejected) => {
    const validate = definitions.get(name);
    expect(validate).toBeTypeOf('function');
    for (const value of accepted) expect(validate(value), JSON.stringify(value)).toBe(true);
    for (const value of rejected) expect(validate(value), JSON.stringify(value)).toBe(false);
  });

  it('admits the existing broad reference and date strings in complete specifications', () => {
    expect(validateSpec({ params: { when: { date: '' }, brush: { select: 'union', include: 'plain' } }, plot: [] })).toBe(true);
    expect(validateSpec({ params: { value: { value: { arbitrary: true } } }, plot: [] })).toBe(false);
    expect(validateSpec({ params: { brush: { select: 'single', include: [1] } }, plot: [] })).toBe(false);
  });
});

describe('parameter parser and retained runtime', () => {
  it('keeps scalar dollar strings literal while array references remain linked to native Params', async () => {
    const ast = parseSpec({ params: { lower: 1, scalar: '$lower', array: ['$lower', 4] }, plot: [] });
    const { params } = await astToDOM(ast);
    expect(vg.Param).toBe(Param);
    expect(params.get('lower')).toBeInstanceOf(Param);
    expect(params.get('scalar').value).toBe('$lower');
    expect(params.get('array').value).toEqual([1, 4]);
    const lower = /** @type {Param<number>} */ (params.get('lower'));
    lower.update(2);
    await params.get('lower').pending('value');
    expect(params.get('array').value).toEqual([2, 4]);
    expect(astToESM(ast)).toContain('const $scalar = vg.Param.value("$lower");');
    expect(astToESM(ast)).toContain('const $array = vg.Param.array([$lower, 4]);');
  });

  it('normalizes explicit value wrappers and empty date fallbacks without changing their runtime values', () => {
    const ast = parseSpec({ params: {
      wrapped: { select: 'value', value: 7 },
      empty: { date: '' },
      emptyWithFallback: { date: '', value: 9 },
      invalid: { date: 'not-a-date', value: 11 },
      date: { select: 'value', date: '2024-01-02T03:04:05Z' }
    }, plot: [] });
    expect(ast.toJSON().params).toEqual({ wrapped: 7, empty: undefined, emptyWithFallback: 9, invalid: { date: 'not-a-date' }, date: { date: '2024-01-02T03:04:05Z' } });
    expect(ast.params.wrapped.instantiate({ api: vg }).value).toBe(7);
    expect(ast.params.empty.instantiate({ api: vg }).value).toBeUndefined();
    expect(ast.params.emptyWithFallback.instantiate({ api: vg }).value).toBe(9);
    expect(ast.params.invalid.instantiate({ api: vg }).value).toBe(11);
    expect(ast.params.date.instantiate({ api: vg }).value.toISOString()).toBe('2024-01-02T03:04:05.000Z');
    expect(astToESM(ast)).toContain('const $empty = vg.Param.value(undefined);');
    expect(astToESM(ast)).toContain('const $invalid = vg.Param.value(new Date("not-a-date"));');
  });

  it('accepts object references in the parser while retaining the stricter wire contract', () => {
    const spec = /** @type {any} */ ({ params: { value: 3 }, plot: [{ mark: 'dot', x: { param: 'value' }, y: '$value' }] });
    const ast = parseSpec(spec);
    const options = ast.root.children[0].options.options;
    expect(options.x).toBeInstanceOf(ParamRefNode);
    expect(options.x.toJSON()).toBe('$value');
    expect(ast.toJSON().plot[0]).toEqual({ mark: 'dot', x: '$value', y: '$value' });
    expect(definitions.get('ParamRef')({ param: 'value' })).toBe(false);
  });

  it('distinguishes SQL scalar and column references and ignores references inside quoted strings', () => {
    const ast = parseSpec({ params: { field: 'amount', offset: 2 }, plot: [{ mark: 'dot', data: [{}], x: { sql: "$$field + $offset + length('$ignored')" } }] });
    const expression = ast.root.children[0].options.options.x;
    const field = Param.value('amount');
    const offset = Param.value(2);
    const activeParams = new Map();
    activeParams.set('field', field);
    activeParams.set('offset', offset);
    const sql = expression.instantiate({ api: vg, activeParams });
    expect(compile([sql], createExecutionContext()).join(';\n')).toBe('"amount" + 2 + LENGTH(\'$ignored\')');
    field.update('total');
    offset.update(5);
    expect(compile([sql], createExecutionContext()).join(';\n')).toBe('"total" + 5 + LENGTH(\'$ignored\')');
    expect(Object.keys(ast.params)).toEqual(['field', 'offset']);
    expect(expression.codegen(new CodegenContext)).toBe('vg.sql`${vg.column($field)} + ${$offset} + length(\'$ignored\')`');
    expect(expression.toJSON()).toEqual({ sql: "$$field + $offset + length('$ignored')" });
  });

  it('serializes direct column references using the identifier parameter syntax', () => {
    const node = new ColumnParamRefNode(new ParamRefNode('field'));
    expect(node.codegen(new CodegenContext)).toBe('vg.column($field)');
    expect(node.toJSON()).toBe('$$field');
  });

  it('uses caller supplied parameter identities and keeps parser contexts local', async () => {
    const ast = parseSpec({ params: { value: 1, brush: { select: 'intersect' } }, plot: [] });
    const value = Param.value(42);
    const brush = Selection.single();
    const supplied = new Map();
    supplied.set('value', value);
    supplied.set('brush', brush);
    const first = await astToDOM(ast, { params: supplied });
    const second = await astToDOM(ast);
    expect(first.params).toBe(supplied);
    expect(first.params.get('value')).toBe(value);
    expect(first.params.get('brush')).toBe(brush);
    expect(second.params.get('value')).not.toBe(value);
    expect(second.params.get('value').value).toBe(1);
    expect(/** @type {Selection} */ (second.params.get('brush')).single).toBe(false);
    expect(parseSpec({ plot: [] }, { params: [['value', new ParamNode(5)]] }).params.value.toJSON()).toBe(5);
    expect(parseSpec({ params: { value: 6 }, plot: [] }, { params: [['value', new ParamNode(5)]] }).params.value.toJSON()).toBe(6);
  });

  it.each(/** @type {const} */ (['intersect', 'union', 'single', 'crossfilter']))('creates a native %s selection and relays upstream clauses', async select => {
    const ast = parseSpec({ params: { upstream: { select: 'single' }, brush: { select, cross: false, empty: true, include: '$upstream' } }, plot: [] });
    const { params } = await astToDOM(ast);
    const brush = /** @type {Selection} */ (params.get('brush'));
    expect(vg.Selection).toBe(Selection);
    expect(brush).toBeInstanceOf(Selection);
    expect(brush.resolver).toMatchObject({ union: select === 'union', single: select === 'single', cross: select === 'crossfilter', empty: true });
    expect(compile([brush.predicate()[0]], createExecutionContext()).join(';\n')).toBe('FALSE');
    expect(ast.toJSON().params.brush.include).toEqual(['$upstream']);
    const clause = { source: {}, fields: [vg.column('x')], value: 2, predicate: asNode(vg.sql`x = 2`) };
    params.get('upstream').update(clause);
    await params.get('upstream').pending('value');
    await brush.pending('value');
    expect(brush.clauses).toHaveLength(1);
    expect(brush.clauses[0]).toBe(clause);
    expect(brush.value).toBe(2);
  });
});
