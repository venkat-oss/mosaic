import { pythonExecutable } from './util/python.js';
import { Plot } from '@uwdata/mosaic-plot';
import assert from 'node:assert/strict';
import { readFile, readdir } from 'node:fs/promises';
import { resolve } from 'node:path';
import { execFileSync } from 'node:child_process';
import { it as test, afterAll } from 'vitest';
import { JSDOM } from 'jsdom';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { parse as yaml } from 'yaml';
import * as vg from '../src/index.js';
import { astToDOM, astToESM, astToPython, parseSpec } from '@uwdata/mosaic-spec';
import { NodeConnector } from '@uwdata/mosaic-core/node-connector';

const root = resolve(import.meta.dirname, '../../../..');
const workspace = root;
const files = await readdir(resolve(root, 'templates/interactors/point'));
const caseData = await Promise.all(files.filter(name => name.endsWith('.json')).map(async (name) => { const id = name.slice(0, -5); const spec = JSON.parse(await readFile(resolve(root, 'templates/interactors/point', name), 'utf8')); const producer = spec.plot.find(item => item.select && item.select !== 'highlight').select; return { id, interactor: id.startsWith('highlight') ? 'highlight' : producer, kind: id === 'toggle-compound' ? 'compound' : id === 'nearest-series' ? 'channels' : id === 'highlight-styles' ? 'styles' : spec.params.selection?.empty ? 'empty-selection' : typeof spec.params.selection === 'number' ? 'parameter' : 'base' }; }));
const dom = new JSDOM('<!DOCTYPE html>', { pretendToBeVisual: true });
for (const key of ['window', 'document', 'Node', 'Element', 'HTMLElement', 'SVGElement'])
  globalThis[key] = dom.window[key];
globalThis.requestAnimationFrame = dom.window.requestAnimationFrame.bind(dom.window);
globalThis.cancelAnimationFrame = dom.window.cancelAnimationFrame.bind(dom.window);
async function ready(element, errors) { const plot = element['value']; const results = await Promise.allSettled(plot.marks.map(mark => mark.pending)); assert.deepEqual(errors, []); await plot.render(); return results; }
const schema = JSON.parse(await readFile(resolve(workspace, 'packages/vgplot/spec/src/generated/mosaic-schema.json'), 'utf8'));
const ajv = new Ajv({ allowUnionTypes: true, allErrors: true });
addFormats.default(ajv);
const validate = ajv.compile(schema);
const database = NodeConnector.make();
async function source(id, format) { const text = await readFile(resolve(workspace, 'templates/interactors/point', id + '.' + format), 'utf8'); return text; }
function expected(item) { if (item.kind === 'compound')
  return [[1, 2]]; if (item.kind === 'channels')
  return 'A'; const name = item.interactor; return name === 'nearest' ? [[1, 2]] : name === 'nearestY' ? 2 : name === 'nearestX' || name === 'highlight' ? 1 : name === 'toggleY' ? [[2]] : name === 'toggleZ' ? [['A']] : name === 'toggleColor' ? [['red']] : [[1]]; }
for (const example of caseData) {
  test(example.id + ' admits JSON/YAML and round trips both Python paths', async () => { const spec = JSON.parse(await source(example.id, 'json')); assert.deepEqual(yaml(await source(example.id, 'yaml')), spec); assert.equal(validate(spec), true, JSON.stringify(validate.errors)); const ast = parseSpec(spec); assert.deepEqual(ast.toJSON(), spec); for (const code of [await source(example.id, 'py'), astToPython(ast)]) {
    const result = execFileSync(pythonExecutable, ['-c', 'import json,sys;ns={};exec(sys.stdin.read(),ns);v=ns["view"];print(json.dumps(v.to_dict(_context=ns) if hasattr(v,"_build_spec") else v.to_dict()))'], { input: code, encoding: 'utf8', env: { ...process.env, PYTHONDONTWRITEBYTECODE: '1' } });
    assert.deepEqual(JSON.parse(result), spec);
  } });
  for (const mode of ['native', 'esm', 'ast'])
    test(example.id + ' executes ' + mode + ' selection events, actual SQL and SVG highlighting', async () => { const coordinator = new vg.Coordinator(await database, { logger: null }); const errors = []; coordinator.logger({ ...coordinator.logger(), error: e => errors.push(e) }); const api = vg.createAPIContext({ coordinator }); try {
      await coordinator.exec('DROP TABLE IF EXISTS point_rows');
      const spec = JSON.parse(await source(example.id, 'json'));
      let element, selection;
      if (mode === 'ast') {
        const result = await astToDOM(parseSpec(spec), { api });
        element = result.element;
        selection = result.params.get('selection');
      }
      else {
        const code = mode === 'native' ? await source(example.id, 'js') : astToESM(parseSpec(spec), { imports: new Map() });
        const body = code.replace(/^import .*$/gm, '').replace(/^export const /gm, 'const ').replace('export default ', 'const element = ');
        ({ element, selection } = await new Function('vg', 'return(async()=>{' + body + '\nreturn{element,selection: ' + (mode === 'esm' ? '$selection' : 'selection') + '};})();')(api));
      }
      assert.deepEqual((await ready(element, errors)).map(r => r.status), ['fulfilled']);
      assert.deepEqual(errors, []);
      const plot = element['value'];
      const nodes = [...element.querySelectorAll('g[data-index="0"] circle')];
      assert.equal(nodes.length, 3);
      if (example.kind === 'empty-selection')
        assert.deepEqual(nodes.map(n => n.getAttribute('opacity')), ['0.15', '0.15', '0.15']);
      const [interactor, highlight] = plot.interactors;
      assert.equal(interactor.mark, plot.marks[0]);
      assert.equal(interactor.selection, selection);
      const svg = element.querySelector('svg');
      if (interactor.constructor.name === 'Toggle')
        nodes[0].dispatchEvent(new dom.window.MouseEvent('pointerdown', { bubbles: true }));
      else
        svg.dispatchEvent(new dom.window.MouseEvent('pointermove', { clientX: svg.scale('x').apply(1), clientY: svg.scale('y').apply(2) }));
      await selection.pending('value');
      assert.deepEqual(selection.value, expected(example));
      if (highlight) {
        await highlight.update();
        assert.deepEqual(nodes.map(n => n.getAttribute('opacity')), example.kind === 'channels' || example.interactor === 'toggleZ' || example.interactor === 'toggleColor' ? ['null', '0.15', 'null'] : ['null', '0.15', '0.15']);
        if (example.kind === 'styles') {
          assert.equal(nodes[1].getAttribute('fill'), '#ccc');
          assert.equal(nodes[1].getAttribute('stroke'), 'black');
        }
      }
      if (interactor.constructor.name === 'Toggle')
        nodes[0].dispatchEvent(new dom.window.MouseEvent('pointerdown', { bubbles: true }));
      else
        svg.dispatchEvent(new dom.window.MouseEvent('pointerleave'));
      await selection.pending('value');
      assert.deepEqual(selection.value, example.kind === 'parameter' ? 1 : interactor.constructor.name === 'Toggle' ? null : undefined);
      if (highlight) {
        await highlight.update();
        assert.deepEqual(nodes.map(n => n.getAttribute('opacity')), example.kind === 'empty-selection' ? ['0.15', '0.15', '0.15'] : ['null', 'null', 'null']);
      }
      assert.deepEqual(errors, []);
    }
    finally {
      coordinator.clear();
    } });
}
test('highlight keeps stable group ordering in an actual aggregate SQL query', async () => {
  const coordinator = new vg.Coordinator(await database, { logger: null });
  const api = vg.createAPIContext({ coordinator });
  try {
    await coordinator.exec("CREATE OR REPLACE TABLE point_groups AS SELECT * FROM (VALUES ('A',1),('A',2),('B',3)) t(g,v)");
    const element = api.plot(api.dot(api.from('point_groups'), { x: 'g', y: api.count() }), api.highlight({ by: vg.Selection.intersect() }));
    await ready(element, []);
    const mark = element['value'].marks[0];
    assert.deepEqual(mark.channel('orderby').value, ['g']);
    assert.match(String(mark.query()), /ORDER BY "g"/);
    assert.equal(element.querySelectorAll('circle').length, 2);
  }
  finally {
    coordinator.clear();
  }
});
test('empty native coordinate columns retain their nearest initialization error', async () => {
  const plot = new Plot();
  vg.dot([], { x: 'x', y: 'y' })(plot);
  vg.nearestX({ as: vg.Selection.intersect() })(plot);
  await assert.rejects(plot.render(), /Cannot read properties of undefined \(reading 'x'\)/);
});
afterAll(async () => { (await database)['_db'].close(); dom.window.close(); });
