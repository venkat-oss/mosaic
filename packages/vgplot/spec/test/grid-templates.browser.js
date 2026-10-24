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

for (const defect of ['tile','null']) test('grid preserves ' + defect + ' interpolation/rendering failure', async ({page}) => {
  await page.goto('/packages/vgplot/spec/test/visual-harness.html');
  const spec = JSON.parse(await readFile(resolve(directory, 'raster.json'), 'utf8'));
  if (defect === 'tile') Object.assign(spec.plot[0], {mark:'rasterTile',origin:[0,0]});
  else spec.plot[0].interpolate = null;
  const result = await page.evaluate(renderGridStarter, {spec,code:'',mode:'ast',reactive:null});
  if (defect === 'tile') {
    expect(result.errors).toEqual([]);
    expect(result.statuses).toEqual(['rejected']);
    expect(result.failures).toEqual([{name:'TypeError',message:"Cannot read properties of undefined (reading '20')"}]);
  } else {
    expect(result.errors).toEqual([{name:'TypeError',message:"Cannot read properties of null (reading 'toLowerCase')"}]);
    expect(result.statuses).toEqual(['fulfilled']);
    expect(result.before.images).toBe(0);
  }
});
