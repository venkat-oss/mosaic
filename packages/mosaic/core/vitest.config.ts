import { defineConfig } from 'vite';
import viteConfig from '../../../vite.config.js';

export default defineConfig({
  resolve: viteConfig.resolve,
  test: {
    setupFiles: ['../../../build/vitest-env.js'],
    hookTimeout: 120000,
  },
});
