// @vitest-environment jsdom
import { pythonExecutable } from './util/python.js';
import { execFileSync } from 'node:child_process';
import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { NodeConnector } from '@uwdata/mosaic-core/node-connector';
import { astToDOM, astToESM, astToPython, parseSpec } from '@uwdata/mosaic-spec';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { describe, expect, it } from 'vitest';
import { parse as parseYAML } from 'yaml';
import * as vg from '../src/index.js';
import { clientsReady } from './util/clients-ready.js';

const cases = /** @type {Array<[string,number[]]>} */ ([['frame-parameter', [10,30,50,70]]]);
const directory = resolve(import.meta.dirname, '../../../../templates/transforms/window');
const schema = JSON.parse(await readFile(resolve(import.meta.dirname, '../../spec/dist/mosaic-schema.json'), 'utf8'));
const ajv = new Ajv({ allowUnionTypes: true, allErrors: true });
addFormats.default(ajv);
const validate = ajv.compile(schema);
const database = NodeConnector.make();

async function sourceFile(name, extension) {
  const source = await readFile(resolve(directory, `${name}.${extension}`), 'utf8');

  return source;
}

function pythonSpec(source) {
  return JSON.parse(execFileSync(pythonExecutable, ['-c',
    'import json,sys; ns={}; exec(sys.stdin.read(),ns); view=ns["view"]; print(json.dumps(view.to_dict(_context=ns) if hasattr(view,"_build_spec") else view.to_dict()))'
  ], { input: source, encoding: 'utf8' }));
}

function execute(source, api, binding = 'undefined') {
  const body = source.replace(/^import \* as vg from ['"]@uwdata\/vgplot['"];?$/m, '')
    .replace('export default ', 'const element = ');
  return new Function('vg', `return (async () => {${body}\nreturn {element, frame:${binding}};})();`)(api);
}

function outputValues(element) {
  const mark = element.value.marks[0];
  expect(mark.data.numRows).toBe(4);
  const id = mark.data.columns[mark.channelField('x').as];
  const value = mark.data.columns[mark.channelField('y').as];
  return Array.from(id, (key, index) => [Number(key), Number(value[index])])
    .sort((a, b) => a[0] - b[0]).map(row => row[1]);
}

describe.each(cases)('%s window starter', (name, expected) => {
  it('admits JSON/YAML, pins parser normalization and executes both Python paths', async () => {
    const spec = JSON.parse(await sourceFile(name, 'json'));
    expect(parseYAML(await sourceFile(name, 'yaml'))).toEqual(spec);
    expect(validate(spec), JSON.stringify(validate.errors)).toBe(true);
    const expression = spec.plot[0].y;
    expect(expression.rows).toBe('$frame');
    expect(spec.params).toEqual({ frame: [1, 0] });
    const ast = parseSpec(spec);
    expect(ast.toJSON()).toEqual(spec);
    expect(pythonSpec(await sourceFile(name, 'py'))).toEqual(spec);
    expect(pythonSpec(astToPython(ast))).toEqual(spec);
  });

  it.each(['module', 'esm', 'ast'])('executes %s through DuckDB and real SVG', async mode => {
    const errors = [];
    const mc = new vg.Coordinator(await database, { logger: null });
    mc.logger({ ...mc.logger(), error: error => errors.push(error) });
    const api = vg.createAPIContext({ coordinator: mc });
    try {
      await mc.exec('DROP TABLE IF EXISTS window_data');
      const spec = JSON.parse(await sourceFile(name, 'json'));
      let element;
      let frame;
      if (mode === 'ast') {
        const result = await astToDOM(parseSpec(spec), { api });
        element = result.element;
        frame = result.params.get('frame');
      } else {
        const source = mode === 'module' ? await sourceFile(name, 'js') : astToESM(parseSpec(spec), { imports: new Map() });
        ({ element, frame } = await execute(source, api, mode === 'module' ? 'frame' : '$frame'));
      }
      expect((await clientsReady(element)).map(result => result.status)).toEqual(['fulfilled']);
      expect(errors).toEqual([]);
      expect(element.querySelector('svg'), element.outerHTML).not.toBeNull();
      const values = outputValues(element);
      values.forEach((value, index) => expect(value).toBeCloseTo(expected[index]));
      expect(frame).toBeInstanceOf(vg.Param);
      frame.update([null, 0]);
      await frame.pending('value');
      expect((await clientsReady(element)).map(result => result.status)).toEqual(['fulfilled']);
      expect(outputValues(element)).toEqual([10, 30, 60, 100]);
      expect(errors).toEqual([]);
    } finally {
      mc.clear();
    }
  });
});

it('executes the native interval utility through DuckDB and SVG', async () => {
  const source = await sourceFile('generic-interval', 'js');
  const errors = [];
  const mc = new vg.Coordinator(await database, { logger: null });
  mc.logger({ ...mc.logger(), error: error => errors.push(error) });
  const api = vg.createAPIContext({ coordinator: mc });
  try {
    await mc.exec('DROP TABLE IF EXISTS window_data');
    const { element } = await execute(source, api);
    expect((await clientsReady(element)).map(result => result.status)).toEqual(['fulfilled']);
    expect(errors).toEqual([]);
    expect(element.querySelector('svg')).not.toBeNull();
    expect(outputValues(element)).toEqual([10, 30, 60, 100]);
  } finally {
    mc.clear();
  }
});
