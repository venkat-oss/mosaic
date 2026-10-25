// @vitest-environment jsdom
import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { test } from 'vitest';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { parse as parseYAML } from 'yaml';
import { QueryError } from '@uwdata/mosaic-core';
import { NodeConnector } from '@uwdata/mosaic-core/node-connector';
import { astToDOM, astToESM, astToPython, parseSpec } from '../src/index.js';
import * as vg from '@uwdata/vgplot';

const root = resolve(import.meta.dirname, '../../../..');
const stage = root;
const directory = resolve(stage, 'templates/marks/density1d');
const projection = {caseData:[{id:'densityY',mark:'densityY'}],nativeData:[],defectData:{expectedFailure:{name:'Error',constructorName:'QueryError',causeName:'Error'}}};
const cases = [...projection.caseData,...projection.nativeData].map(item => item.id);
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
  const nativeOnly = projection.nativeData.some(item => item.id === name);
  if (!nativeOnly) test(name + ' validates and round trips both Python authoring paths', async () => {
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
  for (const mode of nativeOnly ? ['native'] : ['native', 'esm', 'ast']) test(name + (projection.caseData.find(item => item.id === name)?.type ? ' preserves the known explicit-type query failure for ' : ' executes through DuckDB and SVG for ') + mode, async () => {
    const coordinator = new vg.Coordinator(await database, { logger: null });
    const errors = [];
    coordinator.logger({ ...coordinator.logger(), error: error => errors.push(error) });
    const api = vg.createAPIContext({ coordinator });
    try {
      await coordinator.exec('DROP TABLE IF EXISTS density1d_data');
      const spec = nativeOnly ? null : JSON.parse(await source(name, 'json'));
      let element;
      if (mode === 'ast') element = (await astToDOM(parseSpec(spec), { api })).element;
      else {
        const code = mode === 'native' ? await source(name, 'js') : astToESM(parseSpec(spec), { imports: new Map() });
        const body = code.replace(/^import .*$/gm, '').replace(/^export const /gm, 'const ').replace('export default ', 'const element = ');
        element = await new Function('vg', 'return (async () => {' + body + '\nreturn element;})();')(api);
      }
      const item = [...projection.caseData,...projection.nativeData].find(item => item.id === name);
      const type = item.type ?? (item.mark === 'densityX' ? 'areaX' : 'areaY');
      const outcomes = await Promise.allSettled(element.value.marks.map(mark => mark.pending));
      assert.deepEqual(outcomes.map(result => result.status), ['fulfilled']);
      if (item.type) {
        assert.equal(errors.length, 1);
        assert.equal(errors[0].name, projection.defectData.expectedFailure.name);
        assert.equal(errors[0].constructor.name, projection.defectData.expectedFailure.constructorName);
        assert.equal(errors[0].cause.name, projection.defectData.expectedFailure.causeName);
        assert.ok(errors[0].message.includes('Referenced column "' + type + '" not found'));
        assert.equal(element.value.marks[0].type, item.mark === 'densityX' ? 'areaX' : 'areaY');
        return;
      }
      assert.deepEqual(errors, []);
      const aria = type.startsWith('area') ? 'area' : type.startsWith('line') ? 'line' : type.startsWith('text') ? 'text' : 'dot';
      const tag = aria === 'text' ? 'text' : aria === 'dot' ? 'circle, g[aria-label="dot"] path' : 'path';
      const group = element.querySelector('g[aria-label="' + aria + '"]');
      assert.ok(group, type + ': ' + element.outerHTML.slice(-1500));
      const shapes = [...group.querySelectorAll(aria === 'dot' ? 'circle,path' : tag)];
      assert.equal(shapes.length, aria === 'area' || aria === 'line' ? 2 : 64, type);
      for (const shape of shapes) assert.doesNotMatch(shape.outerHTML, /NaN|Infinity/);
      assert.equal(element.value.marks[0].data.numRows, 64);
    } finally { coordinator.clear(); }
  });
}


for (const [name, types] of /** @type {Array<[string,string[]]>} */ ([
  ['densityX', ['areaX','lineX','dotX','textX']],
  ['densityY', ['areaY','lineY','dot','dotY','circle','hexagon','text','textY']]
])) for (const type of types) test(name + ' preserves the explicit ' + type + ' query failure', async () => {
  const coordinator = new vg.Coordinator(await database, {logger:null});
  const errors = [];
  coordinator.logger({...coordinator.logger(), error:error=>errors.push(error)});
  const api = vg.createAPIContext({coordinator});
  try {
    await coordinator.exec(vg.createTable('density_type_failure', "SELECT * FROM (VALUES (0,'A'),(1,'A'),(2,'B'),(3,'B')) AS t(value,series)"));
    const element = api.plot(api[name](api.from('density_type_failure'), {
      [name === 'densityX' ? 'y' : 'x']:'value', fill:'series', type, bins:32, bandwidth:8
    }));
    await assert.rejects(element.value.marks[0].pending, error => {
      assert.ok(error instanceof QueryError);
      assert.ok(error.message.includes('Referenced column "' + type + '" not found'));
      assert.match(error.sql, /^DESCRIBE SELECT /);
      assert.ok(error.sql.includes('"' + type + '"'));
      assert.ok(error.sql.includes('"density_type_failure"'));
      return true;
    });
    assert.deepEqual(errors, []);
    assert.equal(element.value.marks[0].type, name === 'densityX' ? 'areaX' : 'areaY');
  } finally {
    coordinator.clear();
  }
});
