import assert from 'node:assert/strict';
import { test } from '@playwright/test';

async function setup(page, name, options = {}) {
  await page.goto('/packages/vgplot/spec/test/visual-harness.html');
  await page.evaluate(async ({name, options}) => {
    const moduleURL = '/packages/vgplot/vgplot/src/index.js';
    const vg = await import(moduleURL);
    const x = window['navigationX'] = vg.Selection.intersect();
    const y = window['navigationY'] = vg.Selection.intersect();
    const rows = [{a: 1, b: 2}, {a: 5, b: 6}, {a: 9, b: 8}];
    const element = vg.plot(
      vg.dot(rows, {x: 'a', y: 'b'}), vg[name]({x, y, ...options}),
      vg.xDomain([0, 10]), vg.yDomain([0, 10]), vg.width(500), vg.height(300)
    );
    document.querySelector('#container').replaceChildren(element);
    window['navigationPlot'] = element.value;
    await window['navigationPlot'].render();
  }, {name, options});
}

async function domains(page) {
  return page.evaluate(() => ({
    x: window['navigationPlot'].getAttribute('xDomain'),
    y: window['navigationPlot'].getAttribute('yDomain'),
    xvalue: window['navigationX'].value,
    yvalue: window['navigationY'].value,
    source: window['navigationX'].active?.source === window['navigationPlot'].interactors[0],
    predicate: String(window['navigationX'].active?.predicate),
    clients: window['navigationX'].active?.clients === window['navigationPlot'].markSet,
  }));
}

for (const name of ['pan', 'panX', 'panY', 'panZoom', 'panZoomX', 'panZoomY']) {
  test(name + ' preserves actual pointer drag, wheel policy and selection feedback', async ({page}) => {
    await setup(page, name);
    const box = await page.locator('#container').boundingBox();
    const x = box.x + 230, y = box.y + 140;
    await page.mouse.move(x, y);
    await page.mouse.down();
    await page.mouse.move(x + 40, y + 20, {steps: 4});
    await page.mouse.up();
    await page.waitForFunction(() => window['navigationX'].value || window['navigationY'].value);
    const panned = await domains(page);
    const xEnabled = !name.endsWith('Y'), yEnabled = !name.endsWith('X');
    assert.equal(panned.x[0] < 0, xEnabled);
    assert.equal(panned.y[0] > 0, yEnabled);
    if (xEnabled) {
      assert.deepEqual(panned.x, panned.xvalue);
      assert.equal(panned.source, true);
      assert.equal(panned.clients, true);
      assert.match(panned.predicate, /a.*BETWEEN/);
    } else assert.deepEqual(panned.x, [0, 10]);
    if (yEnabled) assert.deepEqual(panned.y, panned.yvalue);
    else assert.deepEqual(panned.y, [0, 10]);
    await page.mouse.wheel(0, -200);
    await page.waitForTimeout(220);
    const zoomed = await domains(page);
    const zoom = name.startsWith('panZoom');
    const span = domain => Math.abs(domain[1] - domain[0]);
    assert.equal(span(zoomed.x) < span(panned.x) - 0.01, zoom && xEnabled);
    assert.equal(span(zoomed.y) < span(panned.y) - 0.01, zoom && yEnabled);
  });
}

test('navigation selections drive peer plots and explicit fields without moving another API context', async ({page}) => {
  await setup(page, 'panZoomX', {xfield: 'explicit_x'});
  await page.evaluate(async () => {
    const moduleURL = '/packages/vgplot/vgplot/src/index.js';
    const vg = await import(moduleURL);
    const rows = [{a: 1, b: 2}, {a: 5, b: 6}];
    const peer = vg.plot(vg.dot(rows, {x: 'a', y: 'b'}), vg.panZoomX({x: window['navigationX']}), vg.xDomain([0, 10]), vg.yDomain([0, 10]));
    const isolatedAPI = vg.createAPIContext({coordinator: new vg.Coordinator()});
    const isolated = isolatedAPI.plot(isolatedAPI.dot(rows, {x: 'a', y: 'b'}), isolatedAPI.panZoomX(), isolatedAPI.xDomain([0, 10]), isolatedAPI.yDomain([0, 10]));
    document.body.append(isolated);
    window['navigationIsolated'] = isolated.value;
    await window['navigationIsolated'].render();
    document.body.append(peer);
    window['navigationPeer'] = peer.value;
    await window['navigationPeer'].render();
    window['navigationX'].update(window['navigationPlot'].interactors[0].clause([2, 7], 'explicit_x', window['navigationPlot'].interactors[0].xscale));
    await window['navigationPlot'].render();
    await window['navigationPeer'].render();
  });
  const state = await domains(page);
  assert.deepEqual(state.x, [2, 7]);
  assert.deepEqual(await page.evaluate(() => window['navigationPeer'].getAttribute('xDomain')), [2, 7]);
  assert.match(state.predicate, /explicit_x.*BETWEEN/);
  assert.deepEqual(await page.evaluate(() => window['navigationIsolated'].getAttribute('xDomain')), [0, 10]);
});

test('native zoom extent clamps wheel scaling while strict wire options remain separate', async ({page}) => {
  await setup(page, 'panZoom', {zoom: [1, 2]});
  const box = await page.locator('#container').boundingBox();
  await page.mouse.move(box.x + 230, box.y + 140);
  await page.mouse.wheel(0, -5000);
  await page.waitForTimeout(220);
  const zoomed = await domains(page);
  assert.ok(Math.abs(zoomed.x[1] - zoomed.x[0] - 5) < 1e-8);
  await page.mouse.wheel(0, 5000);
  await page.waitForTimeout(220);
  const reset = await domains(page);
  assert.ok(Math.abs(reset.x[1] - reset.x[0] - 5) < 1e-8);
  await page.mouse.wheel(0, -5000);
  await page.waitForTimeout(220);
  const repeated = await domains(page);
  assert.ok(Math.abs(repeated.x[1] - repeated.x[0] - 2.5) < 1e-8);
});
