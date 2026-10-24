import { fileURLToPath } from 'node:url';

/** @type {import('vite').UserConfig} */
export default {
  optimizeDeps: {
    exclude: ['@polyglot-sql/sdk'],
  },
  build: {
    target: 'es2022',
    rolldownOptions: {
      input: {
        index: fileURLToPath(new URL('./index.html', import.meta.url)),
        native: fileURLToPath(new URL('./native.html', import.meta.url)),
      },
    },
  },
};
