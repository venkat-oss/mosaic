import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { test } from 'vitest';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { parse as parseYAML } from 'yaml';
import { astToPython, parseSpec } from '../src/index.js';

const root = resolve(import.meta.dirname, '../../../..');
const cases = ['raster'];
const schema = JSON.parse(await readFile(resolve(root, 'packages/vgplot/spec/dist/mosaic-schema.json'), 'utf8'));
const ajv = new Ajv({allowUnionTypes: true, allErrors: true});
addFormats.default(ajv);
const validate = ajv.compile(schema);
for (const name of cases) test(name + ' validates and round trips both Python authoring paths', async () => {
  const source = async extension => {
    const text = await readFile(resolve(root, 'templates/marks/grid', name + '.' + extension), 'utf8');

    return text;
  };
  const spec = JSON.parse(await source('json'));
  assert.deepEqual(parseYAML(await source('yaml')), spec);
  assert.equal(validate(spec), true, JSON.stringify(validate.errors));
  const ast = parseSpec(spec);
  assert.deepEqual(ast.toJSON(), spec);
  for (const code of [await source('py'), astToPython(ast)]) {
    const result = execFileSync(process.env.MOSAIC_PYTHON, ['-c', 'import json,sys;ns={};exec(sys.stdin.read(),ns);view=ns["view"];print(json.dumps(view.to_dict(_context=ns) if hasattr(view,"_build_spec") else view.to_dict()))'], {
      input: code, encoding: 'utf8', env: {...process.env, PYTHONPATH: resolve(root, 'packages/vgplot/vgplot-python'), PYTHONDONTWRITEBYTECODE: '1'},
    });
    assert.deepEqual(JSON.parse(result), spec);
  }
});
