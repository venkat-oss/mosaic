import { pythonExecutable } from './util/python.js';
import assert from 'node:assert/strict';
import { readFile, readdir } from 'node:fs/promises';
import { execFileSync } from 'node:child_process';
import { resolve } from 'node:path';
import { it as test, afterAll } from 'vitest';
import { JSDOM } from 'jsdom';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { parse as yaml } from 'yaml';
import * as vg from '../src/index.js';
import { parseSpec, astToPython, astToESM, astToDOM } from '@uwdata/mosaic-spec';
import { NodeConnector } from '@uwdata/mosaic-core/node-connector';

const root = resolve(import.meta.dirname, '../../../..');
const workspace = root;
const cases = await Promise.all((await readdir(resolve(root, 'templates/interactors/brush'))).filter(name => name.endsWith('.json')).map(async (name) => { const id = name.slice(0, -5); const spec = JSON.parse(await readFile(resolve(root, 'templates/interactors/brush', name), 'utf8')); return { example: { id, kind: id === 'region-compound' ? 'compound' : 'base' }, recordData: { name: spec.hconcat[0].plot[1].select } }; }));
const dom = new JSDOM('<!DOCTYPE html>', { pretendToBeVisual: true });
for (const key of ['window', 'document', 'Node', 'Element', 'HTMLElement', 'SVGElement'])
  globalThis[key] = dom.window[key];
globalThis.requestAnimationFrame = dom.window.requestAnimationFrame.bind(dom.window);
globalThis.cancelAnimationFrame = dom.window.cancelAnimationFrame.bind(dom.window);
for (const dimension of ['width', 'height'])
  Object.defineProperty(dom.window.SVGElement.prototype, dimension, { get() { return { baseVal: { value: Number(this.getAttribute(dimension)) } }; }, configurable: true });
const schema = JSON.parse(await readFile(resolve(workspace, 'packages/vgplot/spec/src/generated/mosaic-schema.json'), 'utf8'));
const ajv = new Ajv({ allowUnionTypes: true, allErrors: true });
addFormats.default(ajv);
const validate = ajv.compile(schema);
const database = NodeConnector.make();
async function source(id, format) { const name = 'templates/interactors/brush/' + id + '.' + format; const text = await readFile(resolve(workspace, name), 'utf8'); return text; }
async function ready(element) { for (const plot of [...element.querySelectorAll('.plot')].map(el => el['value'])) {
  await Promise.all(plot.marks.map(mark => mark.pending));
  await plot.render();
} }
for (const item of cases) {
  const id = item.example.id;
  test(id + ' admits JSON/YAML, parses and round trips generated Python', async () => {
    const spec = JSON.parse(await source(id, 'json'));
    assert.deepEqual(yaml(await source(id, 'yaml')), spec);
    assert.equal(validate(spec), true, JSON.stringify(validate.errors));
    const ast = parseSpec(spec);
    assert.deepEqual(ast.toJSON(), spec);
    for (const code of [await source(id, 'py'), astToPython(ast)]) {
      const out = execFileSync(pythonExecutable, ['-c', 'import json,sys;ns={};exec(sys.stdin.read(),ns);v=ns["view"];print(json.dumps(v.to_dict(_context=ns) if hasattr(v,"_build_spec") else v.to_dict()))'], { input: code, encoding: 'utf8', env: { ...process.env, PYTHONDONTWRITEBYTECODE: '1' } });
      assert.deepEqual(JSON.parse(out), spec);
    }
  });
  for (const mode of ['native', 'esm', 'ast'])
    test(id + ' runs ' + mode + ' linked SQL filtering through the generated wrapper', async () => {
      const coordinator = new vg.Coordinator(await database, { logger: null });
      const api = vg.createAPIContext({ coordinator });
      const errors = [];
      coordinator.logger({ ...coordinator.logger(), error: error => errors.push(error) });
      try {
        await coordinator.exec('DROP TABLE IF EXISTS brush_rows');
        let element, selection;
        const spec = JSON.parse(await source(id, 'json'));
        if (mode === 'ast') {
          const result = await astToDOM(parseSpec(spec), { api });
          element = result.element;
          selection = result.params.get('selection');
        }
        else {
          const code = mode === 'native' ? await source(id, 'js') : astToESM(parseSpec(spec), { imports: new Map() });
          const body = code.replace(/^import .*$/gm, '').replace(/^export const /gm, 'const ').replace('export default ', 'const element = ');
          ({ element, selection } = await new Function('vg', 'return(async()=>{' + body + '\nreturn{element,selection:' + (mode === 'esm' ? '$selection' : 'selection') + '};})();')(api));
        }
        await ready(element);
        assert.deepEqual(errors, []);
        const [plot, linked] = [...element.querySelectorAll('.plot')].map(el => el['value']);
        const interactor = plot.interactors[0];
        assert.equal(interactor.selection, selection);
        assert.equal(interactor.mark, plot.marks[0]);
        assert.equal(linked.marks[0].data.columns.x.length, 3);
        const value = item.recordData.name === 'intervalXY' ? [[0.5, 1.5], [1.5, 2.5]] : item.recordData.name === 'region' ? (item.example.kind === 'compound' ? [[1, 2, 'A']] : [['B']]) : [0.5, 3.5];
        selection.update(interactor.clause(value));
        await selection.pending('value');
        await linked.marks[0].pending;
        assert.equal(linked.marks[0].data.columns.x.length, item.recordData.name === 'intervalX' ? 2 : item.recordData.name === 'intervalY' ? 1 : 1);
        if (item.recordData.name === 'intervalX')
          assert.deepEqual([...linked.marks[0].data.columns.x], [1, 3]);
        else if (item.recordData.name === 'region' && item.example.kind !== 'compound')
          assert.deepEqual([...linked.marks[0].data.columns.x], [3]);
        else
          assert.deepEqual([...linked.marks[0].data.columns.x], [1]);
        assert.deepEqual(errors, []);
        selection.reset();
        await selection.pending('value');
        await linked.marks[0].pending;
        assert.equal(linked.marks[0].data.columns.x.length, 3);
      }
      finally {
        coordinator.clear();
      }
    });
}
afterAll(async () => { (await database)['_db'].close(); dom.window.close(); });
