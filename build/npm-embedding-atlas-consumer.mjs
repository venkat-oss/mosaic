import { cpSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { installPackages } from './npm-install.mjs';

const runfile = path => resolve(process.env.TEST_SRCDIR, path);
const workspaceFile = path => resolve(process.env.TEST_SRCDIR, process.env.TEST_WORKSPACE, path);
const packages = Object.fromEntries(Object.entries(JSON.parse(process.env.MOSAIC_PACKAGES)).map(([name, path]) => [name, runfile(path)]));
const links = Object.fromEntries(Object.entries(JSON.parse(process.env.MOSAIC_LINKS)).map(([name, path]) => [name, workspaceFile(path)]));
const atlas = join(process.env.TEST_TMPDIR, 'embedding-atlas');
cpSync(workspaceFile('node_modules/embedding-atlas'), atlas, { recursive: true, dereference: true, filter: () => true });
packages['embedding-atlas'] = atlas;
const { run } = installPackages(runfile(process.env.PNPM_BIN), packages, links);
const jsdom = pathToFileURL(workspaceFile('node_modules/jsdom/lib/api.js')).href;

run(process.execPath, ['--input-type=module', '-e', `
import assert from 'node:assert/strict';
import { createRequire } from 'node:module';
import { realpathSync } from 'node:fs';
import { JSDOM } from ${JSON.stringify(jsdom)};

const dom = new JSDOM('<!doctype html><body><div id="view"></div></body>', {
  pretendToBeVisual: true, url: 'http://localhost/'
});
for (const key of ['window', 'document', 'Node', 'Text', 'Comment', 'Document', 'DocumentFragment', 'Element', 'HTMLElement', 'HTMLDivElement', 'HTMLCanvasElement', 'HTMLMediaElement', 'HTMLInputElement', 'HTMLButtonElement', 'HTMLSelectElement', 'HTMLTextAreaElement', 'HTMLImageElement', 'HTMLVideoElement', 'HTMLAudioElement', 'HTMLOptionElement', 'HTMLFormElement', 'SVGElement', 'CustomEvent', 'Event', 'MouseEvent', 'KeyboardEvent', 'MutationObserver']) {
  globalThis[key] = dom.window[key];
}
Object.defineProperty(globalThis, 'navigator', { configurable: true, value: dom.window.navigator });
globalThis.requestAnimationFrame = dom.window.requestAnimationFrame.bind(dom.window);
globalThis.cancelAnimationFrame = dom.window.cancelAnimationFrame.bind(dom.window);
globalThis.getComputedStyle = dom.window.getComputedStyle.bind(dom.window);

const { Coordinator, MosaicClient, Param, Selection, clauseInterval } = await import('@uwdata/mosaic-core');
const { NodeConnector } = await import('@uwdata/mosaic-core/node-connector');
const { DuckDB } = await import('@uwdata/mosaic-duckdb');
const { Query, and, column } = await import('@uwdata/mosaic-sql');
const vg = await import('@uwdata/vgplot');
const { EmbeddingViewMosaic, defaultCharts } = await import('embedding-atlas');
assert.equal(vg.Coordinator, Coordinator);
assert.equal(vg.MosaicClient, MosaicClient);
assert.equal(vg.Param, Param);
assert.equal(vg.Selection, Selection);
assert.ok(vg.Param.value(7) instanceof Param);
const atlasRequire = createRequire(import.meta.resolve('embedding-atlas'));
const require = createRequire(import.meta.url);
for (const name of ['@uwdata/mosaic-core', '@uwdata/mosaic-sql', '@uwdata/mosaic-spec', '@uwdata/vgplot']) {
  assert.equal(realpathSync(atlasRequire.resolve(name)), realpathSync(require.resolve(name)), name);
}

const errors = [];
const received = [];
const calls = [];
const unhandled = error => errors.push(error);
process.on('unhandledRejection', unhandled);
dom.window.addEventListener('error', event => errors.push(event.error ?? event.message));
class ObservedCoordinator extends Coordinator {
  connect(client) {
    assert.ok(client instanceof MosaicClient);
    const queryResult = client.queryResult;
    const queryError = client.queryError;
    client.queryResult = function(table) {
      const x = table.getChild('x').toArray();
      const y = table.getChild('y').toArray();
      const category = table.getChild('c').toArray();
      assert.ok(x instanceof Float32Array);
      assert.ok(y instanceof Float32Array);
      assert.ok(category instanceof Uint8Array);
      received.push(Array.from(x, (value, index) => [value, y[index], category[index]]).sort((a, b) => a[0] - b[0]));
      return queryResult.call(this, table);
    };
    client.queryError = function(error) {
      errors.push(error);
      return queryError.call(this, error);
    };
    return super.connect(client);
  }
}
async function until(predicate) {
  const deadline = Date.now() + 20000;
  while (!predicate()) {
    assert.deepEqual(errors, []);
    assert.ok(Date.now() < deadline, 'Embedding Atlas did not update: ' + document.body.textContent);
    await new Promise(resolve => setTimeout(resolve, 10));
  }
}

const db = new DuckDB();
const connector = await NodeConnector.make(db);
const coordinator = new ObservedCoordinator({
  dialect: connector.dialect,
  query(request, options) {
    calls.push(request.sql);
    return connector.query(request, options);
  }
}, { logger: null });
const filter = vg.Selection.intersect();
assert.ok(filter instanceof Selection);
assert.ok(coordinator instanceof vg.Coordinator);
const source = {};
const element = document.querySelector('#view');
let view;
try {
  await coordinator.exec('CREATE TABLE atlas_points(id INTEGER,x DOUBLE,y DOUBLE,category INTEGER); INSERT INTO atlas_points VALUES (1,1,10,0),(2,2,20,1),(3,3,30,0)');
  view = new EmbeddingViewMosaic(element, {
    coordinator, table: 'atlas_points', x: 'x', y: 'y', category: 'category', identifier: 'id', filter,
    labels: [], config: { autoLabelEnabled: false }, width: 320, height: 200
  });
  await until(() => coordinator.clients.size === 1 && element.textContent.includes('3 points'));
  const [client] = coordinator.clients;
  assert.equal(client.coordinator, coordinator);
  assert.equal(client.filterBy, filter);
  assert.ok(client.query(null) instanceof Query);
  assert.deepEqual(received.at(-1), [[1,10,0],[2,20,1],[3,30,0]]);

  filter.update(clauseInterval('x', [2,3], { source }));
  await filter.pending('value');
  await until(() => element.textContent.includes('2 points'));
  assert.deepEqual(received.at(-1), [[2,20,1],[3,30,0]]);
  const predicate = filter.predicate(null);
  const exported = (Array.isArray(predicate) ? and(predicate) : predicate).toString().trim();
  const selected = await coordinator.query('SELECT id FROM atlas_points WHERE ' + exported + ' ORDER BY id');
  assert.deepEqual(Array.from(selected, row => row.id), [2,3]);
  filter.update(clauseInterval('x', null, { source }));
  await filter.pending('value');
  await until(() => element.textContent.includes('3 points'));
  assert.deepEqual(received.at(-1), [[1,10,0],[2,20,1],[3,30,0]]);

  view.destroy();
  view = null;
  await until(() => coordinator.clients.size === 0);
  assert.equal(coordinator.filterGroups.has(filter), false);
  const requests = calls.length;
  filter.update(clauseInterval('x', [2,3], { source }));
  await filter.pending('value');
  await new Promise(resolve => setTimeout(resolve, 20));
  assert.equal(calls.length, requests);
  assert.deepEqual(errors, []);

  const field = column('x');
  const payload = JSON.stringify(field);
  const fieldSQL = String(field);
  assert.equal(JSON.stringify(field), payload);
  const values = await coordinator.query('SELECT ' + fieldSQL + ' AS value FROM atlas_points ORDER BY id');
  assert.deepEqual(Array.from(values, row => row.value), [1,2,3]);
  const charts = await defaultCharts({
    coordinator, table: 'atlas_points', id: 'id', config: { include: ['category'], embedding: false, table: false }
  });
  assert.deepEqual(charts.map(chart => chart.type), ['predicates','count-plot']);
  assert.equal(charts[1].data.field, 'category');
  assert.ok(calls.every(query => !query.includes('[object Object]')));
} finally {
  view?.destroy();
  coordinator.clear();
  db.close();
  dom.window.close();
  process.removeListener('unhandledRejection', unhandled);
}
`]);
