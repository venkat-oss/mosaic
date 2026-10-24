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

const expected = {avg: [17/6,23/6]};
const cases = Object.keys(expected);
const directory = resolve(import.meta.dirname, '../../../../templates/transforms/aggregate');
const schema = JSON.parse(await readFile(resolve(import.meta.dirname, '../../spec/dist/mosaic-schema.json'), 'utf8'));
const ajv = new Ajv({ allowUnionTypes: true, allErrors: true });
addFormats.default(ajv);
const validate = ajv.compile(schema);
const database = NodeConnector.make();

function executePython(source) {
  return JSON.parse(execFileSync(pythonExecutable, ['-c',
    'import json,sys; ns={}; exec(sys.stdin.read(),ns); view=ns["view"]; print(json.dumps(view.to_dict(_context=ns) if hasattr(view,"_build_spec") else view.to_dict()))'
  ], { input: source, encoding: 'utf8' }));
}

describe.each(cases)('%s aggregate starter', name => {
  it('admits both wire formats and executes authored and emitted Python', async () => {
    const spec = JSON.parse(await readFile(resolve(directory, `${name}.json`), 'utf8'));
    for (const extension of ['json', 'yaml']) {
      const source = await readFile(resolve(directory, `${name}.${extension}`), 'utf8');

      const value = extension === 'json' ? JSON.parse(source) : parseYAML(source);
      expect(value).toEqual(spec);
      expect(validate(value), JSON.stringify(validate.errors)).toBe(true);
    }
    const normalized = JSON.parse(JSON.stringify(parseSpec(spec).toJSON()));
    expect(normalized).toEqual(spec);
    const source = await readFile(resolve(directory, `${name}.py`), 'utf8');

    expect(executePython(source)).toEqual(spec);
    expect(executePython(astToPython(parseSpec(spec)))).toEqual(normalized);
  });

  it.each(['module', 'esm', 'ast'])('executes %s with independent numerical results and SVG', async mode => {
    const errors = [];
    const mc = new vg.Coordinator(await database, { logger: null });
    mc.logger({ ...mc.logger(), error: error => errors.push(error) });
    const api = vg.createAPIContext({ coordinator: mc });
    try {
      await mc.exec('DROP TABLE IF EXISTS aggregate_data');
      let element;
      if (mode === 'ast') {
        const spec = JSON.parse(await readFile(resolve(directory, `${name}.json`), 'utf8'));
        ({ element } = await astToDOM(parseSpec(spec), { api }));
      } else {
        let source;
        if (mode === 'module') {
          source = await readFile(resolve(directory, `${name}.js`), 'utf8');

          source = source.replace(/^import \* as vg from ['"]@uwdata\/vgplot['"];?$/m, '');
        } else {
          const spec = JSON.parse(await readFile(resolve(directory, `${name}.json`), 'utf8'));
          source = astToESM(parseSpec(spec), { imports: new Map() });
        }
        const body = source.replace('export default ', 'return ');
        element = await new Function('vg', `return (async () => {${body}})();`)(api);
      }
      expect((await clientsReady(element)).map(result => result.status)).toEqual(['fulfilled']);
      expect(errors).toEqual([]);
      expect(element.querySelector('svg'), element.outerHTML).not.toBeNull();
      const mark = element.value.marks[0];
      const groups = Array.from(mark.data.columns[mark.channelField('x').as]);
      const values = Array.from(mark.data.columns[mark.channelField('y').as]);
      expect(mark.data.numRows).toBe(2);
      for (const [index, category] of ['A', 'B'].entries()) {
        const actual = values.filter((_, row) => groups[row] === category);
        expect(actual).toHaveLength(1);
        expect(Number(actual[0])).toBeCloseTo(expected[name][index], 10);
      }
    } finally {
      mc.clear();
    }
  });
});
