import { compile, createExecutionContext } from '@uwdata/mosaic-sql';
import { execFileSync } from 'node:child_process';
import { readFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { expect, it } from 'vitest';
import { avg, Selection } from '@uwdata/vgplot';
import { astToESM, astToPython, parseSpec } from '../src/index.js';

const ROOT = fileURLToPath(new URL('../../../../', import.meta.url));

it('round trips a mixed nested specification through public JavaScript and Python authoring contracts', async () => {
  const rows = [{ x: 1, y: 2, category: 'A' }, { x: 2, y: 4, category: 'B' }];
  const value = {
    data: { points: rows },
    params: { brush: { select: 'crossfilter' } },
    hconcat: [{ plot: [
      { mark: 'dot', data: { from: 'points' }, x: { avg: 'x' }, y: 'y', fill: 'category' },
      { legend: 'color', as: '$brush' }
    ] }]
  };
  const schema = JSON.parse(await readFile(new URL('../dist/mosaic-schema.json', import.meta.url), 'utf8'));
  const ajv = new Ajv({ allErrors: true, allowUnionTypes: true });
  addFormats.default(ajv);
  expect(ajv.compile(schema)(value)).toBe(true);
  const ast = parseSpec(/** @type {import('../src/spec/Spec.js').Spec} */ (value));
  const normalized = {
    ...value,
    data: { points: { type: 'json', data: rows } }
  };
  expect(ast.toJSON()).toEqual(normalized);
  expect(parseSpec(ast.toJSON()).toJSON()).toEqual(normalized);

  const loads = [];
  const api = {
    Selection,
    avg,
    coordinator: () => ({ exec: async queries => { loads.push(...queries); } }),
    loadObjects: (name, data) => ({ name, data }),
    from: name => ({ from: name }),
    dot: (data, options) => ({ mark: 'dot', data, ...options }),
    colorLegend: options => ({ legend: 'color', ...options }),
    plot: (...plot) => ({ plot }),
    hconcat: (...hconcat) => ({ hconcat })
  };
  const javascript = astToESM(ast, { imports: new Map() });
  const execute = new Function('vg', 'return (async () => {\n' + javascript.replace('export default ', 'return ') + '\n})()');
  const result = await execute(api);
  expect(loads).toEqual([{ name: 'points', data: rows }]);
  const [dot, legend] = result.hconcat[0].plot;
  expect(dot.data).toEqual({ from: 'points' });
  expect(compile([dot.x], createExecutionContext()).join(';\n')).toBe('AVG("x")');
  expect(legend.as).toBeInstanceOf(Selection);
  expect(legend.legend).toBe('color');

  const python = astToPython(ast) + '\nimport json\nprint(json.dumps(view.to_dict()))\n';
  const output = execFileSync(process.env.MOSAIC_PYTHON, ['-c', python], {
    cwd: ROOT,
    encoding: 'utf8',
    stdio: 'pipe',
    timeout: 30000
  });
  expect(JSON.parse(output)).toEqual(normalized);
}, 30000);
