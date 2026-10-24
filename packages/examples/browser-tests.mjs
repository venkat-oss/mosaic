import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { createServer } from 'node:http';
import { extname, relative, resolve } from 'node:path';
import { chromium, expect } from '@playwright/test';

const types = { '.html': 'text/html', '.js': 'text/javascript', '.css': 'text/css', '.json': 'application/json', '.csv': 'text/csv', '.wasm': 'application/wasm' };
const browser = await chromium.launch();
try {
  for (const bundle of process.argv.slice(2)) {
    const root = resolve(process.env.RUNFILES_DIR || process.env.JS_BINARY__RUNFILES, bundle);
    const server = createServer(async (request, response) => {
      try {
        const pathname = decodeURIComponent(new URL(request.url, 'http://localhost').pathname);
        const file = resolve(root, '.' + (pathname === '/' ? '/index.html' : pathname));
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
      await page.goto('http://127.0.0.1:' + server.address().port, { waitUntil: 'domcontentloaded' });
      await page.locator('svg').first().waitFor({ state: 'visible', timeout: 90_000 });
      if (bundle.includes('svelte-example')) {
        await expect(page.locator('body')).toContainText(/Count component\s+1461 \/ 1461\s+Count component \(React\)\s+1461 \/ 1461\s+Histogram/, { timeout: 30_000 });
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
