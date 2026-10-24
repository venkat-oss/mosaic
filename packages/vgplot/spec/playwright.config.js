import { defineConfig } from '@playwright/test';

export default defineConfig({
  workers: 1,
  updateSnapshots: 'none',
  use: {baseURL: process.env.MOSAIC_TEST_BASE_URL},

  retries: process.env.CI ? 2 : 0,

  testMatch: '**/visual*.test.js',
  outputDir: process.env.MOSAIC_BROWSER_OUTPUT,
  snapshotPathTemplate: process.env.MOSAIC_SNAPSHOT_ROOT + '/packages/vgplot/spec/test/{testFileName}-snapshots/{arg}{-snapshotSuffix}{ext}',
});
