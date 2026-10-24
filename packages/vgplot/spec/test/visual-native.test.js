import { expect, test } from '@playwright/test';

test('native Slider filters count and sum through DuckDB and Arrow', async ({ page }) => {
  const errors = [];
  page.on('pageerror', error => errors.push(error.message));
  await page.goto('/packages/vgplot/spec/test/visual-native-harness.html');
  await page.evaluate(async () => { await window['nativeReady']; });
  const slider = page.locator('input[type=range]');
  const result = page.locator('#result');
  await expect(slider).toHaveAttribute('min', '0');
  await expect(slider).toHaveAttribute('max', '4');
  await expect(slider).toHaveValue('2');
  await expect(result).toHaveText('[3,3,0,2]');

  await slider.focus();
  await slider.press('ArrowRight');
  await expect(result).toHaveText('[4,6,0,3]');
  expect(await page.evaluate(async () => (await window['nativeReady']).events)).toEqual(['3']);
  expect(await page.evaluate(async () => (await window['nativeReady']).selection.value)).toEqual([0, 3]);

  await page.locator('#clear').click();
  await expect(result).toHaveText('[6,10,0,4]');
  await page.locator('#null').click();
  await expect(result).toHaveText('[1,null,null,null]');
  expect(errors).toEqual([]);
  await page.evaluate(async () => (await window['nativeReady']).coordinator.clear());
});
