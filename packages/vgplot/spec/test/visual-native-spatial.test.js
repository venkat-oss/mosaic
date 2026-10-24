import { expect, test } from '@playwright/test';

test('native spec loading renders GeoJSON and preserves qualified spatial fields', async ({ page }) => {
  const errors = [];
  page.on('pageerror', error => errors.push(error.message));
  await page.goto('/packages/vgplot/spec/test/visual-native-spatial.html');
  await page.waitForFunction(() => window['nativeSpatialReady'] !== undefined);
  await page.evaluate(async () => { await window['nativeSpatialReady']; });
  await expect(page.locator('#result')).toHaveText('[["Ada",4,1,"Polygon"],["O\'Reilly",1,1,"Polygon"]]');
  await expect(page.locator('#map svg [data-index="0"] path')).toHaveCount(2);
  expect(await page.evaluate(async () => (await window['nativeSpatialReady']).errors)).toEqual([]);
  expect(errors).toEqual([]);
  await page.evaluate(async () => {
    const { coordinator } = await window['nativeSpatialReady'];
    [...coordinator.clients].forEach(client => client.destroy());
    coordinator.clear();
  });
});
