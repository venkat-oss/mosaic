import { defineConfig } from 'vite';
import viteConfig from '../../../vite.config.js';

export default defineConfig({
  resolve: viteConfig.resolve,
  test: {
    setupFiles: ['../../../build/vitest-env.js', './test/util/matchers.ts'],
  },
});
