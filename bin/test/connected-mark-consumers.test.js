import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import test from 'node:test';
import { JSDOM } from 'jsdom';
import { curveBasis } from 'd3';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { parse as parseYAML } from 'yaml';
import { NodeConnector } from '@uwdata/mosaic-core/node-connector';
import { QueryError } from '@uwdata/mosaic-core';
import { astToDOM, astToESM, astToPython, parseSpec } from '@uwdata/mosaic-spec';
import * as vg from '../../packages/vgplot/vgplot/src/index.js';
import { clientsReady } from '../../packages/vgplot/vgplot/test/util/clients-ready.js';

const root = resolve(import.meta.dirname, '../..');
const directory = resolve(root, 'templates/marks/connected');
const cases = ['line'];
const dom = new JSDOM('<!DOCTYPE html>', { pretendToBeVisual: true });
for (const key of ['window', 'document', 'Node', 'Element', 'HTMLElement', 'SVGElement']) globalThis[key] = dom.window[key];
globalThis.requestAnimationFrame = dom.window.requestAnimationFrame.bind(dom.window);
globalThis.cancelAnimationFrame = dom.window.cancelAnimationFrame.bind(dom.window);
const schema = JSON.parse(await readFile(resolve(root, 'packages/vgplot/spec/dist/mosaic-schema.json'), 'utf8'));
const ajv = new Ajv({ allowUnionTypes: true, allErrors: true });
addFormats.default(ajv);
const validate = ajv.compile(schema);
const database = NodeConnector.make();

async function source(name, extension) {
  const text = await readFile(resolve(directory, name + '.' + extension), 'utf8');
  return text;
}

for (const name of cases) {
  test(name + ' validates and round trips both Python authoring paths', async () => {
    const spec = JSON.parse(await source(name, 'json'));
    assert.deepEqual(parseYAML(await source(name, 'yaml')), spec);
    assert.equal(validate(spec), true, JSON.stringify(validate.errors));
    const ast = parseSpec(spec);
    assert.deepEqual(ast.toJSON(), spec);
    for (const code of [await source(name, 'py'), astToPython(ast)]) {
      const result = execFileSync(process.env.PYTHON_BIN, ['-c', 'import json,sys;ns={};exec(sys.stdin.read(),ns);view=ns["view"];print(json.dumps(view.to_dict(_context=ns) if hasattr(view,"_build_spec") else view.to_dict()))'], {
        input: code, encoding: 'utf8', env: { ...process.env, PYTHONDONTWRITEBYTECODE: '1' }
      });
      assert.deepEqual(JSON.parse(result), spec);
    }
  });
  for (const mode of ['native', 'esm', 'ast']) test(name + ' executes ' + mode + ' through DuckDB and SVG', async () => {
    const coordinator = new vg.Coordinator(await database, { logger: null });
    const errors = [];
    coordinator.logger({ ...coordinator.logger(), error: error => errors.push(error) });
    const api = vg.createAPIContext({ coordinator });
    try {
      await coordinator.exec('DROP TABLE IF EXISTS connected_data');
      const spec = JSON.parse(await source(name, 'json'));
      let element;
      if (mode === 'ast') element = (await astToDOM(parseSpec(spec), { api })).element;
      else {
        const code = mode === 'native' ? await source(name, 'js') : astToESM(parseSpec(spec), { imports: new Map() });
        const body = code.replace(/^import .*$/gm, '').replace('export default ', 'const element = ');
        element = await new Function('vg', 'return (async () => {' + body + '\nreturn element;})();')(api);
      }
      assert.deepEqual((await clientsReady(element)).map(result => result.status), ['fulfilled']);
      assert.deepEqual(errors, []);
      const paths = [...element.querySelectorAll('g[aria-label="line"] path')];
      assert.equal(paths.length, 2);
      for (const path of paths) {
        const d = path.getAttribute('d');
        assert.ok(d?.startsWith('M'));
        assert.doesNotMatch(d, /NaN|Infinity/);
      }
      assert.equal(element.value.marks[0].data.numRows, 6);
    } finally { coordinator.clear(); }
  });
}

test('native D3 curve executes through its explicit host boundary', async () => {
  for (const extension of ['json', 'yaml', 'py']) await assert.rejects(source('native-curve', extension), { code: 'ENOENT' });
  const coordinator = new vg.Coordinator(await database, { logger: null });
  const api = vg.createAPIContext({ coordinator });
  try {
    await coordinator.exec('DROP TABLE IF EXISTS connected_data');
    const code = await source('native-curve', 'js');
    const body = code.replace(/^import .*$/gm, '').replace(/^export const /gm, 'const ').replace('export default ', 'const element = ');
    const element = await new Function('vg', 'curveBasis', 'return (async () => {' + body + '\nreturn element;})();')(api, curveBasis);
    assert.deepEqual((await clientsReady(element)).map(result => result.status), ['fulfilled']);
    assert.equal(element.value.marks[0].channel('curve').value, curveBasis);
    const paths = [...element.querySelectorAll('g[aria-label="line"] path')];
    assert.equal(paths.length, 2);
    for (const path of paths) assert.match(path.getAttribute('d'), /C/);
  } finally { coordinator.clear(); }
});

test('directional sweep retains the existing SQL field interpretation', async () => {
  const spec = JSON.parse(await source('line', 'json'));
  Object.assign(spec.plot[0], {mark: 'arrow', x1: 'x', y1: 'y', x2: 'u', y2: 'v', sweep: '+y'});
  for (const name of ['curve', 'z', 'x', 'y']) delete spec.plot[0][name];
  assert.equal(validate(spec), true, JSON.stringify(validate.errors));
  const coordinator = new vg.Coordinator(await database, { logger: null });
  const errors = [];
  coordinator.logger({ ...coordinator.logger(), error: error => errors.push(error) });
  const api = vg.createAPIContext({ coordinator });
  try {
    await coordinator.exec('DROP TABLE IF EXISTS connected_data');
    const element = (await astToDOM(parseSpec(spec), { api })).element;
    await assert.rejects(element.value.marks[0].pending, error => {
      assert.ok(error instanceof QueryError);
      assert.match(error.message, /Referenced column "\+y" not found/);
      assert.match(error.sql, /^DESCRIBE SELECT "\+y" AS "__mosaic_field" FROM "connected_data"$/);
      return true;
    });
    assert.deepEqual((await clientsReady(element)).map(result => result.status), ['rejected']);
    assert.deepEqual(errors, []);
  } finally { coordinator.clear(); }
});
test.after(() => dom.window.close());
