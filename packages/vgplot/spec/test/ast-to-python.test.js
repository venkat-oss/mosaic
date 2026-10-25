import { execFileSync } from 'node:child_process';
import { readFile } from 'node:fs/promises';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { describe, it, expect } from 'vitest';
import { astToESM } from '../src/ast-to-esm.js';
import { astToPython } from '../src/ast-to-python.js';
import { parseSpec } from '../src/index.js';

// Build a minimal AST stand-in: astToPython only calls ast.toJSON().
const ast = json => ({ toJSON: () => json });

describe('astToPython literals', () => {
  it('round trips raw SQL, identifier parameters and window frames through Python', async () => {
    const parsed = await validatedAST({
      params: { field: 'x', offset: 2 },
      plot: [{ mark: 'dot', data: { from: 'rows' },
        x: { sql: "$$field + $offset + length('a` ${literal} \\ c')" },
        y: { avg: 'x', orderby: 'x', rows: [1, 0] } }]
    });
    expect(pythonJSON(parsed)).toEqual(parsed.toJSON());
  });

  it('round trips quotes, backslashes and control characters through Python', () => {
    const parsed = parseSpec({
      input: 'menu',
      label: 'Choose "quoted"',
      options: [
        'plain',
        'say "hello"',
        '"first line"\nsecond line',
        '"carriage"\rreturn',
        '"tab"\there',
        '"path" C:\\new\\test',
        '"trailing"\\',
        '"slash quote" \\"',
        '"controls"\u0000\b\f',
        'both "double" and \'single\'',
        '"Unicode" café 😀'
      ]
    });
    const code = astToPython(parsed);
    expect(code).toContain('label=\'Choose "quoted"\'');
    const output = execFileSync(process.env.MOSAIC_PYTHON, [
      '-c',
      'import json,sys;ns={};exec(sys.stdin.read(),ns);print(json.dumps(ns["view"].to_dict()))'
    ], { input: code, encoding: 'utf8', stdio: 'pipe', timeout: 30000 });
    expect(JSON.parse(output)).toEqual(parsed.toJSON());
  });

  it.each([
    { lower: 1, scalar: '$lower' },
    { scalar: '$lower', lower: 1 }
  ])('keeps scalar dollar strings literal regardless of parameter order', async params => {
    const parsed = await validatedAST({ params, plot: [] });
    expect(pythonJSON(parsed)).toEqual(parsed.toJSON());
  });

  it('keeps dollar strings in data and literal containers while retaining real references', async () => {
    const rows = [{ label: '$lower', nested: { value: '$lower' }, values: ['$lower'] }];
    const parsed = await validatedAST({
      data: { source: rows, csv: { type: 'csv', file: '$lower' } },
      params: {
        lower: 1,
        bounds: ['$lower', 2],
        click: { select: 'single' },
        linked: { select: 'union', include: ['$click'] }
      },
      hconcat: [
        { plot: [
          { mark: 'dot', data: { from: 'source' }, x: '$lower' },
          { mark: 'dot', data: rows, x: 'label', channels: { extra: '$lower' } }
        ], xDomain: ['$lower', 'plain'] },
        { input: 'menu', options: ['$lower', 'plain'] }
      ]
    });
    expect(pythonJSON(parsed)).toEqual(parsed.toJSON());
    const code = astToPython(parsed) + `
assert bounds.param_def(param_names={id(lower): "renamed"}) == ["$renamed", 2]
assert linked.param_def(param_names={id(click): "renamed"}) == {"select": "union", "include": ["$renamed"]}
`;
    execFileSync(process.env.MOSAIC_PYTHON, ['-c', code], { stdio: 'pipe', timeout: 30000 });
  });

  it('emits valid Python for non-finite numbers', () => {
    const code = astToPython(ast({ params: { a: NaN, b: Infinity, c: -Infinity } }));
    expect(code).toContain("a = vg.param(float('nan'))");
    expect(code).toContain("b = vg.param(float('inf'))");
    expect(code).toContain("c = vg.param(float('-inf'))");
    // The bare JS tokens NaN/Infinity would be a NameError in Python.
    expect(code).not.toMatch(/vg\.param\((NaN|Infinity|-Infinity)\)/);
  });

  it('escapes keyword-named kwargs via dict unpacking', () => {
    const code = astToPython(
      ast({ plot: [{ mark: 'dot', channels: { class: 'c', id: 'i' } }] })
    );
    // `class=...` is a SyntaxError; emit **{'class': ...} instead.
    expect(code).toContain('**{"class": "c"}');
    expect(code).toContain('id="i"');
  });

  it('emits ordinary numbers unchanged', () => {
    const code = astToPython(ast({ params: { a: 42, b: 1.5, c: -3 } }));
    expect(code).toContain('a = vg.param(42)');
    expect(code).toContain('b = vg.param(1.5)');
    expect(code).toContain('c = vg.param(-3)');
  });
});

describe('astToPython transforms', () => {
  const lineY = y => ast({ plot: [{ mark: 'lineY', x: 'day', y }] });

  it('emits nested transforms and transform-valued orderby as calls', () => {
    const code = astToPython(lineY({
      sum: { sum: 'precipitation' },
      orderby: { dateMonth: 'date' },
    }));
    expect(code).toContain(
      'y=vg.sum(vg.sum("precipitation"), orderby=vg.date_month("date"))'
    );
  });

  it('emits sql expressions inside transform arguments', () => {
    const code = astToPython(lineY({ sum: { sql: 'amount' } }));
    expect(code).toContain('y=vg.sum(vg.sql("amount"))');
  });

  it('emits orderby lists mixing transforms and columns', () => {
    const code = astToPython(lineY({
      sum: 'amount',
      orderby: [{ dateMonth: 'date' }, 'day'],
      partitionby: 'region',
    }));
    expect(code).toContain(
      'y=vg.sum("amount", orderby=[vg.date_month("date"), "day"], partitionby="region")'
    );
  });

  it('emits nested transforms from a parsed spec', () => {
    const spec = parseSpec({
      plot: [{
        mark: 'lineY',
        data: { from: 'weather' },
        x: 'day',
        y: { sum: { sum: 'precipitation' }, orderby: { dateMonth: 'date' } },
      }],
    });
    expect(astToPython(spec)).toContain(
      'y=vg.sum(vg.sum("precipitation"), orderby=vg.date_month("date"))'
    );
  });
});

const validateSpec = await readFile(new URL('../dist/mosaic-schema.json', import.meta.url), 'utf8').then(text => {
  const validator = new Ajv({ strict: false });
  addFormats.default(validator);
  return validator.compile(JSON.parse(text));
});

async function validatedAST(value) {
  expect((await validateSpec)(value)).toBe(true);
  return parseSpec(value);
}

function pythonJSON(parsed) {
  const code = astToPython(parsed) + '\nimport json\nprint(json.dumps(view.to_dict()))\n';
  return JSON.parse(execFileSync(process.env.MOSAIC_PYTHON, ['-c', code], {
    encoding: 'utf8', stdio: 'pipe', timeout: 30000
  }));
}

describe('codegen names and headers', () => {
  it('preserves distinct wire names across Python identifiers, imports and data', async () => {
    const names = ['vg', 'view', 'date', 'a-b', 'a_b', 'class', 'class_', '1start', '_private', 'café'];
    const data = Object.fromEntries(names.map((name, x) => [name, [{ x }]]));
    const params = Object.fromEntries(names.map((name, x) => [name, x]));
    const parsed = await validatedAST({
      data,
      params: { ...params, when: { date: '2026-10-23' } },
      plot: names.map(name => ({ mark: 'dot', data: { from: name }, x: '$' + name }))
    });
    expect(pythonJSON(parsed)).toEqual(parsed.toJSON());
  });

  it('retains an external table name without a local dataset definition', async () => {
    const parsed = await validatedAST({ plot: [{ mark: 'dot', data: { from: 'external-table' }, x: 'x' }] });
    expect(pythonJSON(parsed)).toEqual(parsed.toJSON());
  });

  it.each([
    { input: 'menu', options: ['one', 'two'] },
    { legend: 'color', for: 'points' },
    { hspace: 20 },
    { vspace: 20 }
  ])('retains configuration for root $input$legend$hspace$vspace', async component => {
    const parsed = await validatedAST({ ...component, config: { extensions: ['spatial'] } });
    expect(pythonJSON(parsed)).toEqual(parsed.toJSON());
  });

  it('retains named data and params, and plot defaults around a root input', async () => {
    const parsed = await validatedAST({
      input: 'menu', from: 'view', column: 'x', as: '$class',
      data: { view: [{ x: 1 }] },
      params: { class: 1 },
      plotDefaults: { width: 400 },
      config: { extensions: ['spatial'] }
    });
    expect(pythonJSON(parsed)).toEqual(parsed.toJSON());
  });

  it('preserves arbitrary channel keys in Python and executed ESM', async () => {
    const channels = Object.fromEntries(['x-title', 'with space', 'class', '$extra', '__proto__'].map(key => [key, 'x']));
    const parsed = await validatedAST({ plot: [{ mark: 'dot', data: [{ x: 1 }], channels }] });
    expect(pythonJSON(parsed)).toEqual(parsed.toJSON());
    const code = astToESM(parsed, { imports: new Map() });
    execFileSync(process.execPath, ['--check', '--input-type=module'], { input: code, stdio: 'pipe' });
    const execute = new Function('vg', code.replace('export default ', 'return '));
    const api = { dot: (data, options) => ({ data, ...options }), plot: (...plot) => ({ plot }) };
    expect(execute(api).plot[0].channels).toEqual(channels);
  });

  it('keeps ESM references distinct from sanitized names and imported bindings', async () => {
    const names = ['a-b', 'a_b', '1start', 'with space', 'vg', 'defaultAttributes'];
    const parsed = await validatedAST({
      params: Object.fromEntries(names.map((name, value) => [name, value])),
      plotDefaults: { width: 100 },
      plot: names.map(name => ({ mark: 'dot', data: [{ x: 1 }], x: '$' + name }))
    });
    const imports = new Map();
    imports.set('@uwdata/vgplot', '* as $vg');
    imports.set('example', ['value as $a_b', 'defaultAttributes']);
    const code = astToESM(parsed, { namespace: '$vg', imports });
    execFileSync(process.execPath, ['--check', '--input-type=module'], { input: code, stdio: 'pipe' });
    const body = code.replace(/^import .*;\n/gm, '').replace('export default ', 'return ');
    const execute = new Function('$vg', '$a_b', 'defaultAttributes', body);
    const api = {
      Param: { value: value => ({ value }) },
      dot: (data, options) => ({ data, ...options }),
      width: value => ({ width: value }),
      plot: (...plot) => ({ plot })
    };
    expect(execute(api, 'imported', 'imported').plot.slice(0, names.length).map(mark => mark.x.value))
      .toEqual(names.map((_, index) => index));
  });

  it('preserves dataset names containing quotes and template delimiters in ESM', async () => {
    const name = 'source"`${value}\\';
    const parsed = await validatedAST({
      data: { [name]: { type: 'parquet', file: 'data.parquet' } },
      plot: [{ mark: 'dot', data: { from: name }, x: 'x' }]
    });
    const code = astToESM(parsed, { imports: new Map() });
    execFileSync(process.execPath, ['--check', '--input-type=module'], { input: code, stdio: 'pipe' });
    const loads = [];
    const api = {
      coordinator: () => ({ exec: async values => { loads.push(...values); } }),
      loadParquet: (name, file) => ({ name, file }),
      from: name => ({ from: name }),
      dot: (data, options) => ({ data, ...options }),
      plot: (...plot) => ({ plot })
    };
    const execute = new Function('vg', 'return (async () => {\n' + code.replace('export default ', 'return ') + '\n})()');
    expect((await execute(api)).plot[0].data).toEqual({ from: name });
    expect(loads).toEqual([{ name, file: 'data.parquet' }]);
  });
});
