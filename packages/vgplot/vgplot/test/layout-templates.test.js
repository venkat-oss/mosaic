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

const cases = /** @type {Array<[string,string,string,string,number]>} */ ([['hconcat','hconcat','width','12px',3]]);
const directory = resolve(import.meta.dirname, '../../../../templates/layouts');
const schema = JSON.parse(await readFile(resolve(import.meta.dirname, '../../spec/dist/mosaic-schema.json'), 'utf8'));
const ajv = new Ajv({ allowUnionTypes: true, allErrors: true });
addFormats.default(ajv);
const validate = ajv.compile(schema);
const database = NodeConnector.make();

function plotsIn(element) {
  return element.value?.marks
    ? [element.value]
    : [...element.children].flatMap(plotsIn);
}

describe.each(cases)('%s layout starter', (name, rootKey, dimension, gap, count) => {
  it('admits both declarative formats and round trips executable Python codegen', async () => {
    const json = JSON.parse(await readFile(resolve(directory, `${name}.json`), 'utf8'));
    const chart = { plot: [{ mark: 'dot', data: { from: 'layout_data' }, x: 'x', y: 'y', r: '$radius' }] };
    const layouts = {
      hconcat: { hconcat: [chart, { hspace: 12 }, { vconcat: [chart, { vspace: 8 }, chart] }] }
    };
    for (const extension of ['json', 'yaml']) {
      const source = await readFile(resolve(directory, `${name}.${extension}`), 'utf8');

      const spec = extension === 'json' ? JSON.parse(source) : parseYAML(source);
      expect(validate(spec), JSON.stringify(validate.errors)).toBe(true);
      expect(spec[rootKey]).toEqual(layouts[name][rootKey]);
      expect(spec.params).toEqual({ radius: 4 });
      expect(spec.plotDefaults).toEqual({ width: 180, height: 140 });
      expect(parseSpec(spec).toJSON()).toEqual(spec);
    }
    const code = astToPython(parseSpec(json));
    const result = JSON.parse(execFileSync(pythonExecutable, ['-c',
      'import json,sys; ns={}; exec(sys.stdin.read(),ns); print(json.dumps(ns["view"].to_dict(_context=ns)))'
    ], { input: code, encoding: 'utf8' }));
    expect(result).toEqual(json);
  });

  it.each(['module', 'esm', 'ast'])('renders %s with ordered DOM, plot defaults and a shared live parameter', async mode => {
    const errors = [];
    const mc = new vg.Coordinator(await database, { logger: null });
    mc.logger({ ...mc.logger(), error: error => errors.push(error) });
    const api = vg.createAPIContext({ coordinator: mc });
    try {
      let element;
      let radius;
      const spec = JSON.parse(await readFile(resolve(directory, `${name}.json`), 'utf8'));
      if (mode === 'ast') {
        const result = await astToDOM(parseSpec(spec), { api });
        element = result.element;
        radius = result.params.get('radius');
      } else {
        let source;
        let local;
        if (mode === 'module') {
          source = await readFile(resolve(directory, `${name}.js`), 'utf8');

          source = source.replace(/^import \* as vg from ['"]@uwdata\/vgplot['"];?$/m, '');
          local = 'radius';
        } else {
          source = astToESM(parseSpec(spec), { imports: new Map() });
          local = '$radius';
        }
        const body = source.replace('export default ', 'const element = ');
        ({ element, radius } = await new Function('vg', `return (async () => {${body}\nreturn {element, radius:${local}};})();`)(api));
      }
      expect((await clientsReady(element)).map(result => result.status)).toEqual(Array(count).fill('fulfilled'));
      expect(errors).toEqual([]);
      expect(element.style.flexDirection).toBe(rootKey === 'hconcat' ? 'row' : 'column');
      expect(element.children).toHaveLength(3);
      expect(element.children[1].tagName).toBe('SPAN');
      expect(element.children[1].style[dimension]).toBe(gap);
      if (count === 3) {
        const nested = element.children[2];
        expect(nested.style.flexDirection).toBe(rootKey === 'hconcat' ? 'column' : 'row');
        expect(nested.children[1].style[dimension === 'width' ? 'height' : 'width']).toBe('8px');
      }
      expect(element.querySelectorAll('svg')).toHaveLength(count);
      const plots = plotsIn(element);
      expect(plots).toHaveLength(count);
      expect(plots.map(plot => plot.marks[0].data?.numRows)).toEqual(Array(count).fill(3));
      expect(plots.map(plot => plot.getAttribute('width'))).toEqual(Array(count).fill(180));
      expect(plots.map(plot => plot.getAttribute('height'))).toEqual(Array(count).fill(140));
      expect(plots.map(plot => plot.marks[0].channel('r').value)).toEqual(Array(count).fill(4));
      radius.update(7);
      await radius.pending('value');
      await clientsReady(element);
      expect(errors).toEqual([]);
      expect(plots.map(plot => plot.marks[0].channel('r').value)).toEqual(Array(count).fill(7));
      expect(element.querySelectorAll('svg')).toHaveLength(count);
    } finally {
      mc.clear();
    }
  });
});
