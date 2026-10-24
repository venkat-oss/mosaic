import { expect, test } from '@playwright/test';

test('native connected and density marks render Arrow results and refresh normalized clipped rasters', async ({ page }) => {
  const errors = [];
  page.on('pageerror', error => errors.push(error.message));
  await page.goto('/packages/vgplot/spec/test/visual-native-marks.html');
  expect(errors).toEqual([]);
  await page.waitForFunction(() => window['nativeMarksReady'] !== undefined);
  await page.evaluate(async () => { await window['nativeMarksReady']; });
  const summary = async () => JSON.parse(await page.locator('#summary').textContent());
  const initial = await summary();
  expect(initial.points).toBeGreaterThan(0);
  expect(initial.points).toBeLessThan(1000);
  expect(initial.density).toBeCloseTo(35, 10);
  // Segment clipping omits the descending line's terminal point on the zero boundary.
  expect(initial.raster).toBe(9);
  expect(initial.domain).toEqual([0, 1]);
  await expect(page.locator('#connected svg g[aria-label="line"] path')).toHaveCount(2);
  await expect(page.locator('#density svg g[aria-label="area"] path')).toHaveCount(2);
  await expect(page.locator('#dense svg image')).toHaveCount(2);
  await page.locator('#normalize').click();
  await expect.poll(async () => (await summary()).raster).toBeCloseTo(4, 10);
  await page.locator('#clip').click();
  await expect.poll(async () => (await summary()).domain).toEqual([0.2, 0.8]);
  expect((await summary()).raster).toBeGreaterThan(0);
  expect(await page.evaluate(async () => {
    const { marks, errors } = await window['nativeMarksReady'];
    return {
      errors,
      optimized: 'union' in marks[0].query().expression,
      finite: marks.every(mark => !/NaN|Infinity/.test(mark.plot.element.outerHTML)),
      images: marks[2].data.columns.src.every(value => value.startsWith('data:image/png'))
    };
  })).toEqual({ errors: [], optimized: true, finite: true, images: true });
  expect(errors).toEqual([]);
  await page.evaluate(async () => {
    const { coordinator, marks } = await window['nativeMarksReady'];
    marks.forEach(mark => mark.destroy());
    coordinator.clear();
  });
});
