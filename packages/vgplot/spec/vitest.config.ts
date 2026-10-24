import { defineConfig, configDefaults } from 'vitest/config';
import viteConfig from '../../../vite.config.js';
import '../../../build/vitest-env.js';

export default defineConfig({
  resolve: { ...viteConfig.resolve, preserveSymlinks: true },
  test: {
    hookTimeout: 120000,
    exclude: [...configDefaults.exclude, 'test/visual*.test.js'],
  },
});
