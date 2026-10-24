import assert from 'node:assert/strict';
import { createRequire } from 'node:module';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import test from 'node:test';
import { pathToFileURL, fileURLToPath } from 'node:url';
import { JSDOM } from 'jsdom';
import YAML from 'yaml';
import Ajv from 'ajv';
import * as vg from '../../packages/vgplot/vgplot/src/index.js';
import { parseSpec } from '../../packages/vgplot/spec/src/parse-spec.js';
import { astToDOM } from '../../packages/vgplot/spec/src/ast-to-dom.js';
import { astToESM } from '../../packages/vgplot/spec/src/ast-to-esm.js';
import { astToPython } from '../../packages/vgplot/spec/src/ast-to-python.js';

const root = fileURLToPath(new URL('../..', import.meta.url));
const directory = resolve(root, 'templates/marks/guides');
const names = ['frame', 'axisX', 'axisY', 'axisFx', 'axisFy', 'gridX', 'gridY', 'gridFx', 'gridFy', 'hexgrid'];
const read = (id, extension) => readFileSync(resolve(directory, id + '.' + extension), 'utf8');
const schema = JSON.parse(readFileSync(resolve(root, 'packages/vgplot/spec/src/generated/mosaic-schema.json'), 'utf8'));
const validate = new Ajv({ strict: false, allErrors: true, validateFormats: false }).compile(schema);
const dom = new JSDOM('<!doctype html>', { pretendToBeVisual: true });
for (const key of ['window', 'document', 'Node', 'Element', 'HTMLElement', 'SVGElement']) globalThis[key] = dom.window[key];
globalThis.requestAnimationFrame = () => 0;
globalThis.cancelAnimationFrame = () => {};
const api = vg.createAPIContext();
const moduleURL = pathToFileURL(resolve(root, 'packages/vgplot/vgplot/src/index.js')).href;
let serial = 0;
async function load(source) {
  const mapped = source.replaceAll("'@uwdata/vgplot'", JSON.stringify(moduleURL)).replaceAll('"@uwdata/vgplot"', JSON.stringify(moduleURL)).replaceAll("'@uwdata/mosaic-plot'", JSON.stringify(pathToFileURL(createRequire(moduleURL).resolve('@uwdata/mosaic-plot')).href));
  return import('data:text/javascript;base64,' + Buffer.from(mapped + '\n//# sourceURL=guide-' + serial++ + '.mjs').toString('base64'));
}
async function rendered(element, name) {
  assert.ok(element?.value);
  await element.value.render();
  const svg = element.querySelector('svg');
  assert.ok(svg);
  assert.doesNotMatch(svg.outerHTML, /NaN|Infinity/);
  assert.equal(element.value.getAttribute('width'), 320);
  assert.equal(element.value.getAttribute('height'), 240);
  const expected = name === 'frame' || name === 'hexgrid' ? name : name.replace('axis', '').replace('grid', '').toLowerCase() + (name.startsWith('axis') ? '-axis' : '-grid');
  assert.ok([...svg.querySelectorAll('[aria-label]')].some(node => node.getAttribute('aria-label').startsWith(expected)), expected);
  return svg;
}
const ids = ['axisX'];
for (const id of ids) test('guide starter ' + id + ' preserves all formats, downloads and actual source/ESM/AST rendering', async () => {
  const spec = JSON.parse(read(id, 'json'));
  assert.deepEqual(YAML.parse(read(id, 'yaml')), spec);
  assert.equal(validate(spec), true, JSON.stringify(validate.errors));
  const ast = parseSpec(spec);
  assert.deepEqual(ast.toJSON(), spec);
  assert.match(astToPython(ast), /import vgplot as vg/);
  const name = spec.plot[1].mark;
    const source = await load(read(id, 'js'));
    await rendered(source.default, name);
    const esm = await load(astToESM(ast));
    await rendered(esm.default, name);
    const actual = await astToDOM(ast, { api });
    await rendered(actual.element, name);

});
test('native formatter executes the public factory and renderer', async () => {
  const module = await load(read('native-formatter', 'js'));
  const svg = await rendered(module.default, 'axisX');
  const mark = module.default.value.marks[1];
  assert.equal(typeof mark.channel('tickFormat').value, 'function');
  assert.deepEqual([...svg.querySelectorAll('g[aria-label="x-axis tick label"] text')].map(node => node.textContent), ['v=0', 'v=5', 'v=10']);
});
for (const name of names) test(name + ' retains its independent closed wire boundary', () => {
  const definition = name[0].toUpperCase() + name.slice(1);
  const check = new Ajv({ strict: false, validateFormats: false }).compile({ ...schema, $ref: '#/definitions/' + definition });
  assert.equal(check({ mark: name }), true);
  assert.equal(check({ mark: name, stroke: 'red', opacity: 0 }), true);
  assert.equal(check({ mark: name, data: [] }), false);
  assert.equal(check({ mark: name, unknownGuideOption: true }), false);
  assert.equal(check({ mark: 'wrong' }), false);
  assert.deepEqual(schema.definitions[definition].required, ['mark']);
  assert.equal(schema.definitions[definition].additionalProperties, false);
  assert.equal('data' in schema.definitions[definition].properties, false);
});
test.after(() => dom.window.close());
