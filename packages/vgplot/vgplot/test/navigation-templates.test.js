import { pythonExecutable } from './util/python.js';
import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { test } from 'vitest';
import { JSDOM } from 'jsdom';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { parse as parseYAML } from 'yaml';
import { ZoomTransform } from 'd3';
import { parseSpec, astToPython, astToESM, astToDOM } from '@uwdata/mosaic-spec';
import * as vg from '../src/index.js';

const root = resolve(import.meta.dirname, '../../../..');
const cases = ['linked-x-domains'];
const dom = new JSDOM('<!DOCTYPE html>', {pretendToBeVisual: true});
for (const key of ['window', 'document', 'Node', 'Element', 'HTMLElement', 'SVGElement']) globalThis[key] = dom.window[key];
globalThis.requestAnimationFrame = dom.window.requestAnimationFrame.bind(dom.window);
globalThis.cancelAnimationFrame = dom.window.cancelAnimationFrame.bind(dom.window);
const schema = JSON.parse(await readFile(resolve(root, 'packages/vgplot/spec/dist/mosaic-schema.json'), 'utf8'));
const ajv = new Ajv({allowUnionTypes: true, allErrors: true});
addFormats.default(ajv);
const validate = ajv.compile(schema);
async function source(id, format) {
  const path = 'templates/interactors/navigation/' + id + '.' + format;
  const text = await readFile(resolve(root, path), 'utf8');

  return text;
}

for (const id of cases) {
  test(id + ' validates and round trips both Python authoring paths', async () => {
    const spec = JSON.parse(await source(id, 'json'));
    assert.deepEqual(parseYAML(await source(id, 'yaml')), spec);
    assert.equal(validate(spec), true, JSON.stringify(validate.errors));
    const ast = parseSpec(spec);
    assert.deepEqual(ast.toJSON(), spec);
    for (const code of [await source(id, 'py'), astToPython(ast)]) {
      const result = execFileSync(pythonExecutable, ['-c', 'import json,sys;ns={};exec(sys.stdin.read(),ns);v=ns["view"];print(json.dumps(v.to_dict(_context=ns) if hasattr(v,"_build_spec") else v.to_dict()))'], {
        input: code, encoding: 'utf8', env: {...process.env, PYTHONDONTWRITEBYTECODE: '1'},
      });
      assert.deepEqual(JSON.parse(result), spec);
    }
  });
  for (const mode of ['native', 'esm', 'ast']) test(id + ' links domains through ' + mode, async () => {
    const coordinator = new vg.Coordinator();
    const api = vg.createAPIContext({coordinator});
    const spec = JSON.parse(await source(id, 'json'));
    let element;
    if (mode === 'ast') ({element} = await astToDOM(parseSpec(spec), {api}));
    else {
      const code = mode === 'native' ? await source(id, 'js') : astToESM(parseSpec(spec), {imports: new Map()});
      const body = code.replace(/^import .*$/gm, '').replace(/^export const /gm, 'const ').replace('export default ', 'const element = ');
      element = await new Function('vg', 'return(async()=>{' + body + '\nreturn element;})();')(api);
    }
    try {
      document.body.replaceChildren(element);
      const plots = [...element.querySelectorAll('.plot')].map(node => node.value);
      assert.equal(plots.length, 2);
      for (const plot of plots) await plot.render();
      const [plot, peer] = plots;
      const interactor = plot.interactors[0];
      assert.equal(interactor.constructor.name, 'PanZoom');
      assert.equal(interactor.mark, plot.marks[0]);
      interactor.publish(new ZoomTransform(1, 20, 10));
      await interactor.xsel.pending('value');
      await interactor.ysel.pending('value');
      for (const axis of ['x', 'y']) {
        const enabled = axis === 'x' ? interactor.panx : interactor.pany;
        assert.deepEqual(plot.getAttribute(axis + 'Domain'), peer.getAttribute(axis + 'Domain'));
        if (enabled) {
          const selection = axis === 'x' ? interactor.xsel : interactor.ysel;
          assert.deepEqual(plot.getAttribute(axis + 'Domain'), selection.value);
          assert.equal(selection.active.source, interactor);
          assert.equal(selection.active.clients, plot.markSet);
        } else assert.deepEqual(plot.getAttribute(axis + 'Domain'), [0, 10]);
      }
    } finally {
      coordinator.clear();
    }
  });
}
