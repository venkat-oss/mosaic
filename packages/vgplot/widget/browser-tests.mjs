import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { createServer } from 'node:http';
import { resolve } from 'node:path';
import { chromium } from '@playwright/test';
import { DuckDB } from '../../server/duckdb/src/index.js';
import { exerciseWidget } from './test/render.js';

const root = process.env.RUNFILES_DIR || process.env.JS_BINARY__RUNFILES;
const [widgetPath, compilerPath] = process.argv.slice(2);
const widget = await readFile(resolve(root, widgetPath), 'utf8');
const compiler = await readFile(resolve(root, compilerPath), 'utf8');
const server = createServer((request, response) => {
  response.setHeader('Content-Type', 'text/html');
  response.end('<!doctype html><html><body></body></html>');
});
await new Promise(done => server.listen(0, '127.0.0.1', done));
const browser = await chromium.launch();
const database = new DuckDB(':memory:', {}, 'INSTALL nanoarrow FROM community; LOAD nanoarrow');
let databaseQueue = Promise.resolve();
try {
  await database._init;
  for (const [source, kind] of [[widget, 'widget'], [compiler, 'compiler']]) {
    const page = await browser.newPage();
    const errors = [];
    page.on('pageerror', error => errors.push(error.message));
    try {
      await page.goto(`http://127.0.0.1:${server.address().port}`);
      const result = await page.evaluate(async ({ source, kind }) => {
        const instantiate = WebAssembly.instantiate;
        const streaming = WebAssembly.instantiateStreaming;
        const fetch = globalThis.fetch;
        let instances = 0;
        const requests = [];
        const initialized = result => {
          instances += 1;
          return result;
        };
        WebAssembly.instantiate = (...args) => instantiate(...args).then(initialized);
        WebAssembly.instantiateStreaming = (...args) => streaming(...args).then(initialized);
        globalThis.fetch = (input, ...args) => {
          requests.push(String(input));
          return fetch(input, ...args);
        };
        const url = URL.createObjectURL(new Blob([source], { type: 'text/javascript' }));
        try {
          const module = await import(url);
          const queries = kind === 'compiler' ? [module.compilePredicate(), module.compileBatch()] : [];
          return {
            instances,
            embedded: requests.every(url => url.startsWith('data:')),
            queries,
            render: kind === 'widget' ? typeof module.default.render : null
          };
        } finally {
          URL.revokeObjectURL(url);
          globalThis.fetch = fetch;
          WebAssembly.instantiate = instantiate;
          WebAssembly.instantiateStreaming = streaming;
        }
      }, { source, kind });
      assert.equal(result.instances, 1, `${kind} must use one compiler instance`);
      assert.equal(result.embedded, true, `${kind} must load embedded compiler assets`);
      if (kind === 'widget') {
        assert.equal(result.render, 'function');
      } else {
        assert.deepEqual(result.queries, [['"amount" >= 10'], ['SELECT 42 AS value', 'SELECT 7 AS value']]);
      }
      assert.deepEqual(errors, []);
    } finally {
      await page.close();
    }
  }

  const rendered = await browser.newPage();
  const renderErrors = [];
  rendered.on('pageerror', error => renderErrors.push(error.message));
  await rendered.exposeFunction('widgetQuery', query => {
    const response = databaseQueue.then(async () => {
      if (query.type === 'exec') {
        await database.exec(query.sql);
        return {};
      }
      const buffers = await database.arrowBuffer(query.sql);
      assert.equal(buffers.length, 1);
      return { bytes: Array.from(buffers[0]) };
    });
    databaseQueue = response.catch(() => {});
    return response;
  });
  try {
    await rendered.goto(`http://127.0.0.1:${server.address().port}`);
    const result = await rendered.evaluate(exerciseWidget, widget);
    assert.deepEqual(result.initial, { rows: 3, x: [1, 2, 3], predicate: '', ownParam: 7, isolated: true });
    assert.deepEqual(result.filtered, { rows: 1, circles: 1, rowsInOtherWidget: 3 });
    assert.deepEqual(await database.query(`SELECT count(*) AS n FROM widget_first WHERE ${result.predicate}`), [{ n: '1' }]);
    assert.equal(result.empty, '');
    assert.notEqual(result.activeScalarPredicate, result.predicate);
    assert.match(result.activeScalarPredicate, /\+\s*2/);
    assert.deepEqual(await database.query(`SELECT count(*) AS n FROM widget_first WHERE ${result.activeIdentifierPredicate}`), [{ n: '0' }]);
    assert.equal(result.activeIdentifierRows, 0);
    assert.deepEqual(result.bindings, { x: 62, rows: 1, otherX: 1 });
    assert.deepEqual(result.cleanup, { handlers: 0, unchanged: true });
    assert.equal(result.otherRows, 1);
    assert.deepEqual(result.repeated, { rows: 3, aExecutions: 2, bExecutions: 0, saves: 1 });
    assert.deepEqual(result.replacement, { rows: 1, x: 101, oldDisconnected: true });
    assert.deepEqual(result.recovered, { failures: 1, rows: 3 });
    assert.deepEqual(result.finalHandlers, [0, 0, 0, 0]);
    assert.equal(result.closedBeforeRender, true);
    assert.ok(result.padded > 0);
    assert.deepEqual(renderErrors, []);
  } finally {
    await rendered.close();
  }

  const page = await browser.newPage();
  try {
    await page.goto(`http://127.0.0.1:${server.address().port}`);
    const result = await page.evaluate(async source => {
      const fetch = globalThis.fetch;
      const load = async () => {
        const url = URL.createObjectURL(new Blob([source], { type: 'text/javascript' }));
        try {
          return await import(url);
        } finally {
          URL.revokeObjectURL(url);
        }
      };
      globalThis.fetch = () => Promise.reject(new Error('blocked compiler asset'));
      let failure;
      try {
        await load();
      } catch (error) {
        failure = error.message;
      } finally {
        globalThis.fetch = fetch;
      }
      const recovered = await load();
      return { failure, queries: recovered.compilePredicate() };
    }, compiler);
    assert.match(result.failure, /Mosaic SQL compiler initialization failed/);
    assert.deepEqual(result.queries, ['"amount" >= 10']);
  } finally {
    await page.close();
  }
} finally {
  await browser.close();
  await databaseQueue;
  database.close();
  await new Promise(done => server.close(done));
}
