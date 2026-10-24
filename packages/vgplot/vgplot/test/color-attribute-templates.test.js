// @vitest-environment jsdom
import { pythonExecutable } from './util/python.js';
import { execFileSync } from 'node:child_process';
import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { Plot } from '@uwdata/mosaic-plot';
import { astToESM, astToPython, parseSpec } from '@uwdata/mosaic-spec';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { interpolateBlues } from 'd3';
import { describe, expect, it } from 'vitest';
import { parse as parseYAML } from 'yaml';
import * as vg from '../src/index.js';

const names = ['colorScheme'];
const root = resolve(import.meta.dirname, '../../../..');
const directory = resolve(root, 'templates/attributes/color');
const schema = JSON.parse(await readFile(resolve(root, 'packages/vgplot/spec/dist/mosaic-schema.json'), 'utf8'));
const ajv = new Ajv({ allowUnionTypes: true, allErrors: true });
addFormats.default(ajv);
const validate = ajv.compile(schema);

async function source(name, extension) {
  const text = await readFile(resolve(directory, `${name}.${extension}`), 'utf8');

  return text;
}

function execute(text, api) {
  const body = text.replace(/^import .*;$/gm, '').replace(/^export const /gm, 'const ').replace('export default ', 'const element = ');
  return new Function('vg', 'interpolateBlues', `return (async () => {${body}\nreturn {element, setting: typeof setting === 'undefined' ? undefined : setting};})();`)(api, interpolateBlues);
}

async function renderCaptured(name, text) {
  const plot = new Plot();
  const api = { ...vg.createAPIContext(), plot: (...directives) => { directives.forEach(directive => directive(plot)); return plot; } };
  const { setting } = await execute(text, api);
  if (setting) {
    const attribute = name;
    expect(setting).toBeInstanceOf(vg.Param);
    expect(plot.getAttribute(attribute)).toBe(setting.value);
  }
  await plot.render();
  const svg = plot.element.querySelector('svg');
  expect(svg.tagName).toBe('svg');
  expect(plot.marks[0].data.numRows).toBe(3);
}

describe.each(names)('%s color/opacity/symbol starter', name => {
  it('admits both declarative forms, preserves AST and executes emitted Python', async () => {
    let json;
    for (const extension of ['json', 'yaml']) {
      const text = await source(name, extension);
      const spec = extension === 'json' ? JSON.parse(text) : parseYAML(text);
      expect(validate(spec), JSON.stringify(validate.errors)).toBe(true);
      expect(parseSpec(spec).toJSON()).toEqual(spec);
      if (json) expect(spec).toEqual(json);
      json = spec;
    }
    const emitted = astToPython(parseSpec(json));
    const output = execFileSync(pythonExecutable, ['-c',
      'import json,sys; ns={}; exec(sys.stdin.read(),ns); print(json.dumps(ns["view"].to_dict(_context=ns)))'
    ], { input: emitted, encoding: 'utf8' });
    expect(JSON.parse(output)).toEqual(json);
  });

  it.each(['source', 'esm'])('executes its %s through actual channels', async mode => {
    const text = mode === 'source' ? await source(name, 'js') : astToESM(parseSpec(JSON.parse(await source(name, 'json'))), { imports: new Map() });
    await renderCaptured(name, text);
  });
});

it.each(['native-sequential'])('renders the JavaScript-only %s adapter', async name => {
  await renderCaptured(name, await source(name, 'js'));
});
