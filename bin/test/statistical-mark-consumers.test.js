import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import test from 'node:test';
import { fileURLToPath, pathToFileURL } from 'node:url';
import Ajv from 'ajv';
import YAML from 'yaml';
import { JSDOM } from 'jsdom';
import * as vg from '../../packages/vgplot/vgplot/src/index.js';
import { Coordinator } from '@uwdata/mosaic-core';
import { NodeConnector } from '@uwdata/mosaic-core/node-connector';
import { DuckDB } from '../../packages/server/duckdb/src/DuckDB.js';
import { parseSpec } from '../../packages/vgplot/spec/src/parse-spec.js';
import { astToDOM } from '../../packages/vgplot/spec/src/ast-to-dom.js';
import { astToESM } from '../../packages/vgplot/spec/src/ast-to-esm.js';

const root = fileURLToPath(new URL('../..', import.meta.url));
const templates = resolve(root, 'templates/marks/statistical');
const read = (name, extension) => readFileSync(resolve(templates, name + '.' + extension), 'utf8');
const schema = JSON.parse(readFileSync(resolve(root, 'packages/vgplot/spec/src/generated/mosaic-schema.json'), 'utf8'));
const validate = new Ajv({ strict: false, validateFormats: false }).compile(schema);
const dom = new JSDOM('<!doctype html>');
for (const key of ['window', 'document', 'Node', 'Element', 'HTMLElement', 'SVGElement']) globalThis[key] = dom.window[key];
const pending = [];
globalThis.requestAnimationFrame = callback => pending.push(callback);
globalThis.cancelAnimationFrame = () => {};
const database = new DuckDB(':memory:', {}, 'INSTALL nanoarrow FROM community; LOAD nanoarrow');
const publicURL = pathToFileURL(resolve(root, 'packages/vgplot/vgplot/src/index.js')).href;
let serial = 0;

async function render(element) {
  const end = Date.now() + 10000;
  while (!pending.length && Date.now() < end) await new Promise(resolve => setTimeout(resolve, 2));
  assert.ok(pending.length, 'The actual coordinator did not schedule a render.');
  while (pending.length) await pending.shift()();
  assert.ok(element.querySelector('svg'));
  return element.querySelector('svg');
}

async function load(source) {
  const mapped = source.replaceAll("'@uwdata/vgplot'", JSON.stringify(publicURL)).replaceAll('"@uwdata/vgplot"', JSON.stringify(publicURL));
  return import('data:text/javascript;base64,' + Buffer.from(mapped + '\n//# sourceURL=statistical-' + serial++ + '.mjs').toString('base64'));
}

for (const name of ['regressionY']) {
  test('statistical starter ' + name + ' executes source, ESM and AST through actual DuckDB', async () => {
    const spec = JSON.parse(read(name, 'json'));
    assert.deepEqual(YAML.parse(read(name, 'yaml')), spec);
    assert.equal(validate(spec), true, JSON.stringify(validate.errors));
    const ast = parseSpec(spec);
    assert.deepEqual(ast.toJSON(), spec);
    for (const mode of ['source', 'esm', 'ast']) {
      pending.length = 0;
      const coordinator = new Coordinator(new NodeConnector(database), { cache: false, consolidate: false, logger: null });
      vg.coordinator(coordinator);
      const api = vg.createAPIContext({ coordinator });
      try {
        const result = mode === 'ast' ? await astToDOM(ast, { api }) : await load(mode === 'source' ? read(name, 'js') : astToESM(ast));
        const element = mode === 'ast' ? result.element : result.default;
        const svg = await render(element);
        assert.doesNotMatch(svg.outerHTML, /NaN|Infinity/);
        assert.equal(svg.querySelectorAll('g[aria-label="line"] > path').length, 1);
        assert.equal(svg.querySelectorAll('g[aria-label="area"] > path').length, 1);
      } finally {
        for (const client of [...coordinator.clients]) coordinator.disconnect(client);
        pending.length = 0;
      }
    }
  });
}

for (const [name, entries] of [
  ['Hexbin', [[{ mark: 'hexbin', data: { from: 'rows' }, x: 'x', y: 'y', type: 'text', binWidth: '$width' }, true], [{ mark: 'hexbin', data: { from: 'rows' }, binWidth: {} }, false]]],
  ['RegressionY', [[{ mark: 'regressionY', data: { from: 'rows' }, ci: 0 }, true], [{ mark: 'regressionY', data: { from: 'rows' }, ci: null }, false]]],
  ['ErrorBarX', [[{ mark: 'errorbarX', data: { from: 'rows' }, x: 'value', ci: '$confidence' }, true], [{ mark: 'errorbarX', data: { from: 'rows' } }, false]]],
  ['ErrorBarY', [[{ mark: 'errorbarY', data: { from: 'rows' }, y: 'value' }, true], [{ mark: 'errorbarY', data: { from: 'rows' } }, false]]],
]) test(name + ' preserves its independent wire boundary', () => {
  const check = new Ajv({ strict: false, validateFormats: false }).compile({ ...schema, $ref: '#/definitions/' + name });
  for (const [value, expected] of entries) assert.equal(check(value), expected, JSON.stringify(value));
  const first = entries[0][0];
  assert.equal(check({ ...first, arbitraryStatisticalOption: true }), false);
  const missing = { ...first };
  delete missing.data;
  assert.equal(check(missing), false);
});

test.after(() => { database.close(); dom.window.close(); });
