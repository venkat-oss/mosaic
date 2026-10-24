import assert from 'node:assert/strict';
import { test } from '@playwright/test';

async function setup(p, name, options = {}) {
  await p.goto('/packages/vgplot/spec/test/visual-harness.html');
  await p.evaluate(async ({ name, options }) => {
    const apiModule = '/packages/vgplot/vgplot/src/api.js';
    const vg = await import(apiModule);
        const selection = window['brushSelection'] = vg.Selection.intersect();
    const rows = [{ a: 1, b: 2, g: 'A', f: 'U' }, { a: 3, b: 4, g: 'B', f: 'V' }, { a: 5, b: 6, g: 'A', f: 'U' }];
    const mark = { x: 'a', y: 'b', z: 'g', ...options['mark'] };
    const element = vg.plot(vg.dot(rows, mark), vg[name]({ as: selection, channels: ['z'], brush: { fill: 'red', fillOpacity: 0.3 }, ...options['interactor'] }), vg.width(500), vg.height(300));
    document.body.append(element);
    window['brushPlot'] = element.value;
    await window['brushPlot'].render();
  }, { name, options });
  return p;
}
for (const name of ['intervalX', 'intervalY', 'intervalXY'])
  test(name + ' actual pointer drag publishes a domain selection and a second empty drag clears', async ({ page: p }) => {
    await setup(p, name);
    try {
      const coords = await p.evaluate(() => { const svg = document.querySelector('svg'), bounds = svg.getBoundingClientRect(); return { left: bounds.left, top: bounds.top, x1: svg['scale']('x').apply(1.5), x2: svg['scale']('x').apply(4), y1: svg['scale']('y').apply(5), y2: svg['scale']('y').apply(2.5), clearX: svg['scale']('x').apply(1.1), clearY: svg['scale']('y').apply(5.8) }; });
      await p.mouse.move(coords.left + coords.x1, coords.top + coords.y1);
      await p.mouse.down();
      await p.mouse.move(coords.left + coords.x2, coords.top + coords.y2, { steps: 4 });
      await p.mouse.up();
      const selected = await p.evaluate(() => ({ value: window['brushSelection'].value, predicate: String(window['brushSelection'].active.predicate), rect: document.querySelector('rect.selection').getAttribute('fill-opacity') }));
      assert.ok(Array.isArray(selected.value));
      assert.match(selected.predicate, /BETWEEN/);
      assert.equal(selected.rect, '0.3');
      await p.mouse.click(coords.left + coords.clearX, coords.top + coords.clearY);
      assert.equal(await p.evaluate(() => window['brushSelection'].value), undefined);
    }
    finally {
      await p.close();
    }
  });
test('region pointer brush selects actual SVG geometry and publishes backing values', async ({ page: p }) => {
  await setup(p, 'region');
  try {
    const box = await p.locator('[data-index="0"] circle').first().boundingBox();
    await p.mouse.move(box.x - 3, box.y - 3);
    await p.mouse.down();
    await p.mouse.move(box.x + box.width + 3, box.y + box.height + 3, { steps: 4 });
    await p.mouse.up();
    const selected = await p.evaluate(() => ({ value: window['brushSelection'].value, predicate: String(window['brushSelection'].active.predicate), source: window['brushSelection'].active.source === window['brushPlot'].interactors[0] }));
    assert.deepEqual(selected.value, [['A']]);
    assert.match(selected.predicate, /g.*IN/);
    assert.equal(selected.source, true);
    await p.mouse.click(box.x + box.width + 12, box.y + box.height + 12);
    assert.equal(await p.evaluate(() => window['brushSelection'].value), undefined);
  }
  finally {
    await p.close();
  }
});
test('region uses facet translations when selecting actual rendered elements', async ({ page: p }) => {
  await setup(p, 'region', { mark: { fx: 'g', fy: 'f' } });
  try {
    const box = await p.locator('[data-index="0"] circle').first().boundingBox();
    await p.mouse.move(box.x - 3, box.y - 3);
    await p.mouse.down();
    await p.mouse.move(box.x + box.width + 3, box.y + box.height + 3, { steps: 4 });
    await p.mouse.up();
    assert.deepEqual(await p.evaluate(() => window['brushSelection'].value), [['A']]);
  }
  finally {
    await p.close();
  }
});
