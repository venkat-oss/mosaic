import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import test from 'node:test';
import { fileURLToPath } from 'node:url';
import { createMarkdownRenderer } from 'vitepress';

const root = fileURLToPath(new URL('../..', import.meta.url));
test('generated guide references render actual JavaScript and Python signatures and the curated starter links', async () => {
  const source = readFileSync(resolve(root, 'docs/api/vgplot/marks.md'), 'utf8');
  const renderer = await createMarkdownRenderer(resolve(root, 'docs'), {}, '/mosaic/');
  const html = renderer.render(source);
  for (const [javascript, python] of [
    ['frame', 'frame'], ['axisX', 'axis_x'], ['axisY', 'axis_y'], ['axisFx', 'axis_fx'], ['axisFy', 'axis_fy'],
    ['gridX', 'grid_x'], ['gridY', 'grid_y'], ['gridFx', 'grid_fx'], ['gridFy', 'grid_fy'], ['hexgrid', 'hexgrid'],
  ]) {
    assert.ok(html.includes('<code>' + javascript + '(options)</code>'));
    assert.ok(html.includes('<code>' + python + '(data=None, **options)</code>'));
  }
  assert.match(html, /Formatting functions are JavaScript-only/);
  assert.match(html, /stroke-only outlines and defaults binWidth to 20/);
  assert.match(html, /retained renderer rejects them with invalid anchor/);
  assert.match(html, /closed declarative contracts omit the data property/);
  for (const format of ['json', 'yaml', 'js', 'py']) {
    assert.ok(source.includes('/templates/marks/guides/axisX.' + format));
  }
});
