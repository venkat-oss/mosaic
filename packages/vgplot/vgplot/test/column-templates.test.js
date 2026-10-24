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

const cases = /** @type {Array<[string,string,{bin?:string,steps?:number,sql?:string}]>} */ ([['bin','x',{bin:'x',steps:4}],['sql','x',{sql:'x + $offset'}]]);
const directory = resolve(import.meta.dirname, '../../../../templates/transforms/column');
const schema = JSON.parse(await readFile(resolve(import.meta.dirname, '../../spec/dist/mosaic-schema.json'), 'utf8'));
const ajv = new Ajv({ allowUnionTypes: true, allErrors: true });
addFormats.default(ajv);
const validate = ajv.compile(schema);
const database = NodeConnector.make();

describe.each(cases)('%s column starter', (name, channel, expression) => {
  it('admits JSON/YAML and round trips source Python and parser-generated Python', async () => {
    const spec = JSON.parse(await readFile(resolve(directory, `${name}.json`), 'utf8'));
    for (const extension of ['json', 'yaml']) {
      const source = await readFile(resolve(directory, `${name}.${extension}`), 'utf8');

      const value = extension === 'json' ? JSON.parse(source) : parseYAML(source);
      expect(validate(value), JSON.stringify(validate.errors)).toBe(true);
      expect(value.plot[0][channel]).toEqual(expression);
      expect(parseSpec(value).toJSON()).toEqual(value);
    }
    const python = await readFile(resolve(directory, `${name}.py`), 'utf8');

    for (const source of [python, astToPython(parseSpec(spec))]) {
      const result = JSON.parse(execFileSync(pythonExecutable, ['-c',
        'import json,sys; ns={}; exec(sys.stdin.read(),ns); view=ns["view"]; print(json.dumps(view.to_dict(_context=ns) if hasattr(view,"_build_spec") else view.to_dict()))'
      ], { input: source, encoding: 'utf8' }));
      expect(result).toEqual(spec);
    }
  });

  it.each(['module', 'esm', 'ast'])('executes %s through DuckDB and the renderer', async mode => {
    const errors = [];
    const mc = new vg.Coordinator(await database, { logger: null });
    mc.logger({ ...mc.logger(), error: error => errors.push(error) });
    const api = vg.createAPIContext({ coordinator: mc });
    try {
      await mc.exec('DROP TABLE IF EXISTS column_data');
      const spec = JSON.parse(await readFile(resolve(directory, `${name}.json`), 'utf8'));
      let element;
      let offset;
      if (mode === 'ast') {
        const result = await astToDOM(parseSpec(spec), { api });
        element = result.element;
        offset = result.params.get('offset');
      } else {
        let source;
        let binding;
        if (mode === 'module') {
          source = await readFile(resolve(directory, `${name}.js`), 'utf8');

          source = source.replace(/^import \* as vg from ['"]@uwdata\/vgplot['"];?$/m, '');
          binding = 'offset';
        } else {
          source = astToESM(parseSpec(spec), { imports: new Map() });
          binding = '$offset';
        }
        const body = source.replace('export default ', 'const element = ');
        ({ element, offset } = await new Function('vg', `return (async () => {${body}\nreturn {element, offset:${name === 'sql' ? binding : 'undefined'}};})();`)(api));
      }
      expect((await clientsReady(element)).map(result => result.status)).toEqual(['fulfilled']);
      expect(errors).toEqual([]);
      expect(element.querySelector('svg'), element.outerHTML).not.toBeNull();
      const mark = element.value.marks[0];
      expect(mark.data.numRows).toBe(3);
      const outputName = mark.channelField(channel).as;
      const values = Array.from(mark.data.columns[outputName]);
      if (name === 'bin') expect(values).toEqual([1, 2, 3]);
      if (name === 'sql') {
        expect(values).toEqual([2, 3, 4]);
        offset.update(3);
        await offset.pending('value');
        await clientsReady(element);
        expect(Array.from(mark.data.columns[outputName])).toEqual([4, 5, 6]);
        expect(errors).toEqual([]);
      }
    } finally {
      mc.clear();
    }
  });
});
