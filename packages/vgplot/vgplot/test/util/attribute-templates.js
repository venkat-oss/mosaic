import { pythonExecutable } from './python.js';
import { execFileSync } from 'node:child_process';
import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { astToDOM, astToESM, astToPython, parseSpec } from '@uwdata/mosaic-spec';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { expect } from 'vitest';
import { parse as parseYAML } from 'yaml';
import * as vg from '../../src/index.js';

const schema = JSON.parse(await readFile(resolve(import.meta.dirname, '../../../spec/dist/mosaic-schema.json'), 'utf8'));
const ajv = new Ajv({ allowUnionTypes: true, allErrors: true });
addFormats.default(ajv);
const validate = ajv.compile(schema);

export function templatePath(slug, name, extension) {
  return resolve(import.meta.dirname, '../../../../../',
    'templates/attributes',
    slug, name + '.' + extension);
}

export async function templateSource(slug, name, extension) {
  const source = await readFile(templatePath(slug, name, extension), 'utf8');

  return source;
}

export async function templateSpec(slug, name) {
  return JSON.parse(await templateSource(slug, name, 'json'));
}

export async function verifyWireAndPython(slug, name) {
  const spec = await templateSpec(slug, name);
  const yaml = parseYAML(await templateSource(slug, name, 'yaml'));
  expect(yaml).toEqual(spec);
  expect(validate(spec), JSON.stringify(validate.errors)).toBe(true);
  const ast = parseSpec(spec);
  expect(ast.toJSON()).toEqual(spec);
  for (const source of [await templateSource(slug, name, 'py'), astToPython(ast)]) {
    const result = execFileSync(pythonExecutable, ['-c',
      'import json,sys; ns={}; exec(sys.stdin.read(),ns); view=ns["view"]; print(json.dumps(view.to_dict(_context=ns) if hasattr(view,"_build_spec") else view.to_dict()))'
    ], { input: source, encoding: 'utf8' });
    expect(JSON.parse(result)).toEqual(spec);
  }
  return spec;
}

function executeSource(source, api, bindings) {
  const body = source.replace(/^import .*$/gm, '')
    .replace(/^export const /gm, 'const ')
    .replace('export default ', 'const element = ');
  return new Function('vg', ...Object.keys(bindings),
    'return (async () => {' + body + '\nreturn element;})();'
  )(api, ...Object.values(bindings));
}

export async function renderTemplate(slug, name, mode, bindings = {}) {
  const coordinator = new vg.Coordinator();
  const errors = [];
  coordinator.logger({ ...coordinator.logger(), error: error => errors.push(error) });
  const api = vg.createAPIContext({ coordinator });
  try {
    const spec = mode === 'host' ? undefined : await templateSpec(slug, name);
    const ast = spec && parseSpec(spec);
    let element;
    if (mode === 'ast') {
      element = (await astToDOM(ast, { api })).element;
    } else {
      const source = mode === 'esm'
        ? astToESM(ast, { imports: new Map() })
        : await templateSource(slug, name, 'js');
      element = await executeSource(source, api, bindings);
    }
    if (mode !== 'host') await element.value.synch.promise;
    expect(errors).toEqual([]);
    return element;
  } finally {
    coordinator.clear();
  }
}
