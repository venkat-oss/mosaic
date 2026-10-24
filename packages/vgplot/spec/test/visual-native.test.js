import { expect, test } from '@playwright/test';

test('native histogram prepares bins and preserves preaggregation through SVG updates', async ({ page }) => {
  const errors = [];
  page.on('pageerror', error => errors.push(error.message));
  await page.goto('/packages/vgplot/spec/test/visual-native-histogram.html');
  await page.evaluate(async () => { await window['nativeHistogramReady']; });
  const result = page.locator('#bins');
  const bars = page.locator('#histogram svg [data-index="0"] rect');
  await expect(result).toHaveText('[[0,1,2],[1,2,2]]');
  await expect(bars).toHaveCount(2);
  await page.locator('#left').click();
  await expect(result).toHaveText('[[0,1,2]]');
  await expect(bars).toHaveCount(1);
  await page.locator('#right').click();
  await expect(result).toHaveText('[[1,2,2]]');
  expect(await page.evaluate(async () => (await window['nativeHistogramReady']).calls.some(sql => /CREATE TABLE.*preagg_/i.test(sql)))).toBe(true);
  await page.locator('#reset').click();
  await expect(result).toHaveText('[[0,1,2],[1,2,2]]');
  const points = await page.evaluate(async () => {
    const { brush } = await window['nativeHistogramReady'];
    const bounds = brush.mark.plot.element.getBoundingClientRect();
    return { left: bounds.left + brush.scale.apply(0.1), right: bounds.left + brush.scale.apply(0.9), y: bounds.top + 80 };
  });
  await page.mouse.move(points.left, points.y);
  await page.mouse.down();
  await page.mouse.move(points.right, points.y, { steps: 6 });
  await page.mouse.up();
  await expect(result).toHaveText('[[0,1,2]]');
  await expect(bars).toHaveCount(1);
  const selected = await page.evaluate(async () => {
    const { selection, mark, brush } = await window['nativeHistogramReady'];
    return { value: selection.value, source: selection.active.source === brush, rows: mark.data.numRows, count: Number(mark.data.columns.y[0]) };
  });
  expect(selected.source).toBe(true);
  expect(selected.rows).toBe(1);
  expect(selected.count).toBe(2);
  expect(selected.value[0]).toBeCloseTo(0.1, 1);
  expect(selected.value[1]).toBeCloseTo(0.9, 1);
  expect(errors).toEqual([]);
  await page.evaluate(async () => {
    const { coordinator, mark } = await window['nativeHistogramReady'];
    mark.destroy();
    coordinator.clear();
  });
});

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
