/** @type {import('vite').UserConfig} */
export default {
  optimizeDeps: {
    exclude: ['@polyglot-sql/sdk'],
  },
  build: {
    target: 'es2022',
  },
};
