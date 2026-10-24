import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { test } from '@playwright/test';

const root = resolve(import.meta.dirname, '../../../..');
const cases = ['linked-x-domains'];
for (const id of cases) {
  for (const mode of cases.includes(id) ? ['native', 'esm', 'ast'] : ['native']) test(id + ' generated navigation through ' + mode, async ({page}) => {
    const code = await readFile(resolve(root, 'templates/interactors/navigation', id + '.js'), 'utf8');
    const spec = cases.includes(id) ? JSON.parse(await readFile(resolve(root, 'templates/interactors/navigation', id + '.json'), 'utf8')) : null;
    await page.goto('/packages/vgplot/spec/test/visual-harness.html');
    await page.evaluate(async ({code, spec, mode}) => {
      const moduleURL = '/packages/vgplot/vgplot/src/index.js';
      const specURL = '/packages/vgplot/spec/src/index.ts';
      const vg = await import(moduleURL);
      const specAPI = await import(specURL);
      const coordinator = new vg.Coordinator();
      const api = vg.createAPIContext({coordinator});
      let element;
      if (mode === 'ast') ({element} = await specAPI.astToDOM(specAPI.parseSpec(spec), {api}));
      else {
        if (mode === 'esm') code = specAPI.astToESM(specAPI.parseSpec(spec), {imports: new Map()});
        const body = code.replace(/^import .*$/gm, '').replace(/^export const /gm, 'const ').replace('export default ', 'const element = ');
        element = await new Function('vg', 'return(async()=>{' + body + '\nreturn element;})();')(api);
      }
      document.querySelector('#container').replaceChildren(element);
      const plots = [...document.querySelectorAll('.plot')].map(node => node['value']);
      for (const plot of plots) await plot.render();
      window['navigationTemplate'] = {plots, coordinator};
    }, {code, spec, mode});
    const box = await page.locator('.plot').first().boundingBox();
    await page.mouse.move(box.x + 150, box.y + 120);
    await page.mouse.down();
    await page.mouse.move(box.x + 180, box.y + 140, {steps: 3});
    await page.mouse.up();
    const result = await page.evaluate(() => {
      const {plots} = window['navigationTemplate'];
      const [plot, peer] = plots;
      const i = plot.interactors[0];
      return {
        count: plots.length,
        x: plot.getAttribute('xDomain'), y: plot.getAttribute('yDomain'),
        peerX: peer?.getAttribute('xDomain'), peerY: peer?.getAttribute('yDomain'),
        panx: i.panx, pany: i.pany,
        xvalue: i.xsel.value, yvalue: i.ysel.value,
        finite: plots.every(plot => !/NaN|Infinity/.test(plot.element.outerHTML)),
      };
    });
    assert.equal(result.finite, true);
    assert.equal(result.count, cases.includes(id) ? 2 : 1);
    if (cases.includes(id)) {
      assert.deepEqual(result.x, result.peerX);
      assert.deepEqual(result.y, result.peerY);
      if (result.panx) {
        assert.deepEqual(result.x, result.xvalue);
        assert.notDeepEqual(result.x, [0, 10]);
      } else assert.deepEqual(result.x, [0, 10]);
      if (result.pany) {
        assert.deepEqual(result.y, result.yvalue);
        assert.notDeepEqual(result.y, [0, 10]);
      } else assert.deepEqual(result.y, [0, 10]);
    }
    await page.evaluate(() => window['navigationTemplate'].coordinator.clear());
  });
}
