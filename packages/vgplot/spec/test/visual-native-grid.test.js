import { expect, test } from '@playwright/test';

test('native raster tiles render weighted Arrow grids and refresh on selection and viewport changes', async ({ page }) => {
  const errors = [];
  page.on('pageerror', error => errors.push(error.message));
  await page.goto('/packages/vgplot/spec/test/visual-native-grid.html');
  await page.waitForFunction(() => window['nativeGridReady'] !== undefined);
  await page.evaluate(async () => { await window['nativeGridReady']; });
  const mass = page.locator('#mass');
  await expect(mass).toHaveText('20');
  await expect(page.locator('#grid svg image')).toHaveCount(1);
  await expect(page.locator('#hexbin svg [aria-label="dot"] path')).toHaveCount(4);
  await page.locator('#filter').click();
  await expect(mass).toHaveText('6');
  await page.locator('#zoom').click();
  await expect(mass).toHaveText('12');
  expect(await page.evaluate(async () => {
    const { errors, mark } = await window['nativeGridReady'];
    return { errors, finite: !/NaN|Infinity/.test(mark.plot.element.outerHTML), source: mark.data.columns.src[0] };
  })).toMatchObject({ errors: [], finite: true, source: expect.stringMatching(/^data:image\/png/) });
  expect(errors).toEqual([]);
  await page.evaluate(async () => (await window['nativeGridReady']).coordinator.clear());
});
