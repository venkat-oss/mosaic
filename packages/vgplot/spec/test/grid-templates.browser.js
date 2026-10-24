import {test, expect} from '@playwright/test';
import {readFile} from 'node:fs/promises';
import {resolve} from 'node:path';
import {renderGridStarter} from './util/grid-browser.js';

const directory = resolve(import.meta.dirname, '../../../../templates/marks/grid');
for (const mode of ['native','esm','ast']) test('grid starter raster through ' + mode, async ({page}) => {
  await page.goto('/packages/vgplot/spec/test/visual-harness.html');
  const code = await readFile(resolve(directory, 'raster.js'), 'utf8');
  const spec = JSON.parse(await readFile(resolve(directory, 'raster.json'), 'utf8'));
  const result = await page.evaluate(renderGridStarter, {spec,code,mode,reactive:null});
  expect(result.errors).toEqual([]);
  expect(result.statuses).toEqual(['fulfilled']);
  expect(result.before.finite).toBe(true);
  expect(result.before.images).toBe(1);
  expect(result.before.painted).toBe(true);
});

test('grid starter executes native interpolation', async ({page}) => {
  await page.goto('/packages/vgplot/spec/test/visual-harness.html');
  const code = await readFile(resolve(directory, 'native-interpolator.js'), 'utf8');
  const result = await page.evaluate(renderGridStarter, {spec:null,code,mode:'native',reactive:null});
  expect(result.errors).toEqual([]);
  expect(result.statuses).toEqual(['fulfilled']);
  expect(result.nativeInterpolation).toBe(true);
  expect(result.before.painted).toBe(true);
});

test('raster tiles render through the spec runtime', async ({page}) => {
  await page.goto('/packages/vgplot/spec/test/visual-harness.html');
  const spec = JSON.parse(await readFile(resolve(directory, 'raster.json'), 'utf8'));
  Object.assign(spec.plot[0], {mark:'rasterTile',origin:[0,0]});
  const result = await page.evaluate(renderGridStarter, {spec,code:'',mode:'ast',reactive:null});
  expect(result.errors).toEqual([]);
  expect(result.statuses).toEqual(['fulfilled']);
  expect(result.before.images).toBe(1);
  expect(result.before.painted).toBe(true);
  expect(result.before.finite).toBe(true);
});

test('grid preserves null interpolation failure', async ({page}) => {
  await page.goto('/packages/vgplot/spec/test/visual-harness.html');
  const spec = JSON.parse(await readFile(resolve(directory, 'raster.json'), 'utf8'));
  spec.plot[0].interpolate = null;
  const result = await page.evaluate(renderGridStarter, {spec,code:'',mode:'ast',reactive:null});
  expect(result.errors).toEqual([{name:'TypeError',message:"Cannot read properties of null (reading 'toLowerCase')"}]);
  expect(result.statuses).toEqual(['fulfilled']);
  expect(result.before.images).toBe(0);
});
