import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { test } from '@playwright/test';

const root = resolve(import.meta.dirname, '../../../..');
const specification = JSON.parse(await readFile(resolve(root, 'templates/spec/dashboard.json'), 'utf8'));
const javascript = await readFile(resolve(root, 'templates/spec/dashboard.js'), 'utf8');

for (const mode of ['native', 'esm', 'ast']) test('dashboard starter links pointer brush and slider through ' + mode, async ({page}) => {
  await page.goto('/packages/vgplot/spec/test/visual-harness.html');
  const errors = [];
  page.on('pageerror', error => errors.push(error.message));
  await page.evaluate(async ({mode, specification, javascript, databasePort}) => {
    const vgURL = '/packages/vgplot/vgplot/src/index.js';
    const specURL = '/packages/vgplot/spec/src/index.ts';
    const vg = await import(vgURL);
    const {parseSpec, astToDOM, astToESM} = await import(specURL);
    const coordinator = vg.coordinator();
    coordinator.databaseConnector(new vg.RestConnector({uri: window.location.protocol + '//' + window.location.hostname + ':' + databasePort}));
    coordinator.logger({...coordinator.logger(), error: error => { throw error; }});
    const api = vg.createAPIContext({coordinator});
    let element, brush, offset;
    if (mode === 'ast') {
      const result = await astToDOM(parseSpec(specification), {api});
      element = result.element;
      brush = result.params.get('brush');
      offset = result.params.get('offset');
    } else {
      const code = mode === 'native' ? javascript : astToESM(parseSpec(specification), {imports: new Map()});
      const body = code.replace(/^import .*$/gm, '').replace(/^export const /gm, 'const ').replace('export default ', 'const element = ');
      ({element, brush, offset} = await new Function('vg', 'return(async()=>{' + body + '\nreturn {element,brush:' + (mode === 'native' ? 'brush' : '$brush') + ',offset:' + (mode === 'native' ? 'offset' : '$offset') + '};})();')(api));
    }
    document.querySelector('#container').replaceChildren(element);
    window['dashboardElement'] = element;
    window['dashboardBrush'] = brush;
    window['dashboardOffset'] = offset;
    window['dashboardCoordinator'] = coordinator;
    window['dashboardReady'] = async () => {
      await new Promise(resolve => requestAnimationFrame(resolve));
      await Promise.all([...coordinator.clients].map(client => client.pending));
      for (const node of element.querySelectorAll('.plot')) await node['value'].render();
    };
    await window['dashboardReady']();
  }, {mode, specification, javascript, databasePort: Number(process.env.MOSAIC_TEST_DATABASE_PORT || 3000)});
  const initial = await page.evaluate(() => {
    const element = window['dashboardElement'];
    const [scatter, bars] = [...element.querySelectorAll('.plot')].map(node => node['value']);
    const dot = scatter.marks[0];
    return {rows: dot.data.numRows, groups: bars.marks[0].data.numRows, table: element.querySelector('tbody').rows.length, y: [...dot.data.columns[dot.channelField('y').as]].map(Number), legend: scatter.legends.length};
  });
  assert.deepEqual({rows: initial.rows, groups: initial.groups, table: initial.table, legend: initial.legend}, {rows: 6, groups: 3, table: 6, legend: 1});
  const points = await page.evaluate(() => {
    const scatter = window['dashboardElement'].querySelector('.plot')['value'];
    const interactor = scatter.interactors[0];
    const bounds = scatter.element.getBoundingClientRect();
    return {left: bounds.left + interactor.scale.apply(1.5), right: bounds.left + interactor.scale.apply(4.5), y: bounds.top + 90};
  });
  await page.mouse.move(points.left, points.y);
  await page.mouse.down();
  await page.mouse.move(points.right, points.y, {steps: 6});
  await page.mouse.up();
  await page.waitForFunction(() => window['dashboardElement'].querySelector('tbody').rows.length === 3);
  await page.evaluate(() => window['dashboardReady']());
  const selected = await page.evaluate(() => {
    const plots = [...window['dashboardElement'].querySelectorAll('.plot')].map(node => node['value']);
    const bar = plots[1].marks[0];
    const categories = bar.data.columns[bar.channelField('x').as];
    const counts = bar.data.columns[bar.channelField('y').as];
    return {scatter: plots[0].marks[0].data.numRows, counts: [...categories].map((category, index) => [category, Number(counts[index])]).sort()};
  });
  assert.deepEqual(selected, {scatter: 6, counts: [['A', 1], ['B', 2]]});
  await page.locator('input[type="range"]').fill('2');
  await page.evaluate(() => window['dashboardReady']());
  const shifted = await page.evaluate(() => {
    const dot = window['dashboardElement'].querySelector('.plot')['value'].marks[0];
    return {offset: window['dashboardOffset'].value, y: [...dot.data.columns[dot.channelField('y').as]].map(Number)};
  });
  assert.equal(shifted.offset, 2);
  assert.deepEqual(shifted.y, initial.y.map(value => value + 2));
  assert.deepEqual(errors, []);
  await page.evaluate(() => window['dashboardCoordinator'].clear());
});
