import config from './vitest.config.js';

export default {
  ...config,
  test: {
    ...config.test,
    include: ['test/**/*.integration.ts'],
    testTimeout: 30000,
    hookTimeout: 180000,
    maxWorkers: 1
  }
};
