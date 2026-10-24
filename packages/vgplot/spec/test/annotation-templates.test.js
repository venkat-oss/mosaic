// @vitest-environment jsdom
import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { test } from 'vitest';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { parse as parseYAML } from 'yaml';
import { NodeConnector } from '@uwdata/mosaic-core/node-connector';
import { astToDOM, astToESM, astToPython, parseSpec } from '../src/index.js';
import * as vg from '@uwdata/vgplot';

const root = resolve(import.meta.dirname, '../../../..');
const stage = root;
const directory = resolve(stage, 'templates/marks/annotation');
const cases = ['multiline-text'];
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
      const result = execFileSync(process.env.MOSAIC_PYTHON, ['-c', 'import json,sys;ns={};exec(sys.stdin.read(),ns);view=ns["view"];print(json.dumps(view.to_dict(_context=ns) if hasattr(view,"_build_spec") else view.to_dict()))'], {
        input: code, encoding: 'utf8', env: { ...process.env, PYTHONPATH: resolve(root, 'packages/vgplot/vgplot-python'), PYTHONDONTWRITEBYTECODE: '1' }
      });
      assert.deepEqual(JSON.parse(result), spec);
    }
  });
  for (const mode of ['native', 'esm', 'ast']) test(name + (name === 'vectorX' ? ' preserves known rendering failure for ' : ' executes through DuckDB and SVG for ') + mode, async () => {
    const coordinator = new vg.Coordinator(await database, { logger: null });
    const errors = [];
    coordinator.logger({ ...coordinator.logger(), error: error => errors.push(error) });
    const api = vg.createAPIContext({ coordinator });
    try {
      await coordinator.exec('DROP TABLE IF EXISTS annotation_data');
      const spec = JSON.parse(await source(name, 'json'));
      if (name === 'vectorX') {
        const code = mode === 'native' ? await source(name, 'js') : astToESM(parseSpec(spec), {imports: new Map()});
        const worker = resolve(import.meta.dirname, 'fixtures/vector-x-failure.mjs');
        const result = JSON.parse(execFileSync(process.execPath, [worker], {input: JSON.stringify({root, mode, code, spec}), encoding: 'utf8'}));
        assert.deepEqual(result, {name: 'TypeError', message: 'Plot[type] is not a function', type: 'vectoX'});
        return;
      }
      let element;
      if (mode === 'ast') element = (await astToDOM(parseSpec(spec), { api })).element;
      else {
        const code = mode === 'native' ? await source(name, 'js') : astToESM(parseSpec(spec), { imports: new Map() });
        const body = code.replace(/^import .*$/gm, '').replace(/^export const /gm, 'const ').replace('export default ', 'const element = ');
        element = await new Function('vg', 'return (async () => {' + body + '\nreturn element;})();')(api);
      }
      const markName = spec.plot[0].mark;
      const outcomes = await Promise.allSettled(element.value.marks.map(mark => mark.pending));
        assert.deepEqual(outcomes.map(result => result.status), ['fulfilled']);
        assert.deepEqual(errors, []);
        const aria = markName.startsWith('text') ? 'text' : markName.startsWith('waffle') ? 'waffle' : markName === 'image' ? 'image' : 'vector';
        const tag = aria === 'text' ? 'text' : aria === 'image' ? 'image' : 'path';
        const shapes = [...element.querySelectorAll('g[aria-label="' + aria + '"] ' + tag)];
        assert.equal(shapes.length, 2);
        for (const shape of shapes) assert.doesNotMatch(shape.outerHTML, /NaN|Infinity/);
        assert.equal(element.value.marks[0].data.numRows, 2);
    } finally { coordinator.clear(); }
  });
}
