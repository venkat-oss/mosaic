import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { createServer } from 'node:http';
import { extname, relative, resolve } from 'node:path';
import { chromium, expect } from '@playwright/test';

const types = { '.html': 'text/html', '.js': 'text/javascript', '.css': 'text/css', '.json': 'application/json', '.csv': 'text/csv', '.wasm': 'application/wasm' };
const [docs, ...examples] = process.argv.slice(2);
const browser = await chromium.launch();
try {
  for (const bundle of [docs, ...examples]) {
    const root = resolve(process.env.RUNFILES_DIR || process.env.JS_BINARY__RUNFILES, bundle);
    const server = createServer(async (request, response) => {
      try {
        let pathname = decodeURIComponent(new URL(request.url, 'http://localhost').pathname);
        if (bundle === docs && pathname.startsWith('/mosaic/')) pathname = pathname.slice('/mosaic'.length);
        if (pathname.endsWith('/')) pathname += 'index.html';
        const file = resolve(root, '.' + pathname);
        if (relative(root, file).startsWith('..')) {
          response.writeHead(400).end();
          return;
        }
        response.setHeader('Content-Type', types[extname(file)] || 'application/octet-stream');
        response.end(await readFile(file));
      } catch (error) {
        response.writeHead(error.code === 'ENOENT' ? 404 : 500).end(error.message);
      }
    });
    await new Promise(done => server.listen(0, '127.0.0.1', done));
    const page = await browser.newPage();
    const errors = [];
    page.on('pageerror', error => errors.push(error.message));
    try {
      const origin = 'http://127.0.0.1:' + server.address().port;
      if (bundle === docs) {
        await page.goto(origin + '/mosaic/development/polyglot/', { waitUntil: 'domcontentloaded' });
        await expect(page.locator('[data-native-compiler]')).toHaveText('SELECT 42 AS value', { timeout: 90_000 });
      } else {
        await page.goto(origin, { waitUntil: 'domcontentloaded' });
        await page.locator('svg').first().waitFor({ state: 'visible', timeout: 90_000 });
      }
      if (bundle.includes('svelte-example')) {
        await expect(page.locator('body')).toContainText(/Count component\s+1461 \/ 1461\s+Count component \(React\)\s+1461 \/ 1461\s+Histogram/, { timeout: 30_000 });
      }
      if (bundle.includes('vanilla-example')) {
        await page.goto(origin + '/native.html', { waitUntil: 'domcontentloaded' });
        await expect(page.locator('#native-query')).toHaveText('SELECT 42 AS value', { timeout: 90_000 });
      }
      assert.deepEqual(errors, [], bundle);
    } finally {
      await page.close();
      await new Promise(done => server.close(done));
    }
  }
} finally {
  await browser.close();
}
