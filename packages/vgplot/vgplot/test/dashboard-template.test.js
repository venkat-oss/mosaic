// @vitest-environment jsdom
import { pythonExecutable } from './util/python.js';
import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { test } from 'vitest';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { parse as parseYAML } from 'yaml';
import { NodeConnector } from '@uwdata/mosaic-core/node-connector';
import { parseSpec, astToPython, astToDOM, astToESM } from '@uwdata/mosaic-spec';
import * as vg from '../src/index.js';
import { clientsReady } from './util/clients-ready.js';

const root = resolve(import.meta.dirname, '../../../..');
const schema = JSON.parse(await readFile(resolve(root, 'packages/vgplot/spec/dist/mosaic-schema.json'), 'utf8'));
const ajv = new Ajv({allowUnionTypes: true, allErrors: true});
addFormats.default(ajv);
const validate = ajv.compile(schema);
const connector = await NodeConnector.make();
async function source(format) {
  const path = 'templates/spec/dashboard.' + format;
  const text = await readFile(resolve(root, path), 'utf8');

  return text;
}
async function ready(element) {
  await new Promise(resolve => requestAnimationFrame(resolve));
  assert.ok((await clientsReady(element)).every(result => result.status === 'fulfilled'));
  for (const node of element.querySelectorAll('.plot')) await node['value'].render();
}

test('dashboard source formats validate and round trip through public Python authoring', async () => {
  const spec = JSON.parse(await source('json'));
  assert.deepEqual(parseYAML(await source('yaml')), spec);
  assert.equal(validate(spec), true, JSON.stringify(validate.errors));
  const ast = parseSpec(spec);
  assert.deepEqual(ast.toJSON(), spec);
  for (const code of [await source('py'), astToPython(ast)]) {
    const result = execFileSync(pythonExecutable, ['-c', 'import json,sys;ns={};exec(sys.stdin.read(),ns);v=ns["view"];print(json.dumps(v.to_dict(_context=ns) if hasattr(v,"_build_spec") else v.to_dict()))'], {
      input: code, encoding: 'utf8', env: {...process.env, PYTHONDONTWRITEBYTECODE: '1'},
    });
    assert.deepEqual(JSON.parse(result), spec);
  }
});

for (const mode of ['native', 'esm', 'ast']) test('dashboard links real SQL clients through ' + mode, async () => {
  const coordinator = new vg.Coordinator(connector, {logger: null});
  const errors = [];
  coordinator.logger({...coordinator.logger(), error: error => errors.push(error)});
  const previous = vg.coordinator();
  vg.coordinator(coordinator);
  const api = vg.createAPIContext({coordinator});
  try {
    await coordinator.exec('DROP TABLE IF EXISTS dashboard_rows');
    const spec = JSON.parse(await source('json'));
    let element, brush, offset;
    if (mode === 'ast') {
      const result = await astToDOM(parseSpec(spec), {api});
      element = result.element;
      brush = result.params.get('brush');
      offset = result.params.get('offset');
    } else {
      const code = mode === 'native' ? await source('js') : astToESM(parseSpec(spec), {imports: new Map()});
      const body = code.replace(/^import .*$/gm, '').replace(/^export const /gm, 'const ').replace('export default ', 'const element = ');
      ({element, brush, offset} = await new Function('vg', 'return(async()=>{' + body + '\nreturn {element,brush:' + (mode === 'native' ? 'brush' : '$brush') + ',offset:' + (mode === 'native' ? 'offset' : '$offset') + '};})();')(api));
    }
    document.body.replaceChildren(element);
    await ready(element);
    const [scatter, bars] = [...element.querySelectorAll('.plot')].map(node => node['value']);
    const table = element.querySelector('table').parentElement['value'];
    const dot = scatter.marks[0];
    const bar = bars.marks[0];
    assert.equal(dot.data.numRows, 6);
    assert.equal(bar.data.numRows, 3);
    assert.equal(table.body.rows.length, 6);
    assert.equal(scatter.legends.length, 1);
    for (const plot of [scatter, bars]) {
      assert.equal(plot.getAttribute('width'), 360);
      assert.equal(plot.getAttribute('height'), 220);
    }
    const interactor = scatter.interactors[0];
    assert.equal(interactor.selection, brush);
    brush.update(interactor.clause([1.5, 4.5]));
    await brush.pending('value');
    await ready(element);
    assert.equal(dot.data.numRows, 6);
    assert.equal(table.body.rows.length, 3);
    const categories = bar.data.columns[bar.channelField('x').as];
    const counts = bar.data.columns[bar.channelField('y').as];
    assert.deepEqual([...categories].map((category, index) => [category, Number(counts[index])]).sort(), [['A', 1], ['B', 2]]);
    const oldY = [...dot.data.columns[dot.channelField('y').as]].map(Number);
    offset.update(2);
    await offset.pending('value');
    await ready(element);
    const newY = [...dot.data.columns[dot.channelField('y').as]].map(Number);
    assert.deepEqual(newY, oldY.map(value => value + 2));
    assert.deepEqual(errors, []);
  } finally {
    coordinator.clear();
    vg.coordinator(previous);
  }
});

test('retained parser normalization and Python metadata omission stay explicit', () => {
  const spec = {meta: {title: 'Metadata'}, plot: []};
  assert.throws(() => parseSpec(/** @type {any} */ (JSON.stringify(spec))), /Invalid specification/);
  const ast = parseSpec(spec);
  assert.equal(Array.isArray(ast.data), false);
  assert.equal(Array.isArray(ast.params), false);
  assert.deepEqual(ast.toJSON().meta, spec.meta);
  assert.equal(astToPython(ast), astToPython(parseSpec({plot: []})));
});
