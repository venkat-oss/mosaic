import { chmodSync, cpSync, existsSync, mkdtempSync, readdirSync, realpathSync, rmSync, symlinkSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join, relative, resolve } from 'node:path';
import { build, createServer, preview } from 'vite';
import { parseArgs } from 'node:util';
import { pathToFileURL } from 'node:url';

const [packagePath, outputPath, mode = 'build', ...args] = process.argv.slice(2);
const source = resolve(packagePath);
const output = resolve(process.env.JS_BINARY__EXECROOT || process.cwd(), outputPath);
const workspace = mkdtempSync(join(tmpdir(), 'mosaic-example-'));
const root = join(workspace, 'app');
try {
  if (packagePath !== '.') {
    cpSync(source, root, {
      recursive: true,
      dereference: true,
      filter: path => !['node_modules', 'dist'].includes(relative(source, path).split('/')[0]),
    });
    for (const entry of readdirSync(workspace, { recursive: true, withFileTypes: true })) {
      if (entry.isDirectory()) chmodSync(join(entry.parentPath, entry.name), 0o755);
    }
    symlinkSync(join(source, 'node_modules'), join(root, 'node_modules'), 'dir');
  }
  const config = { root, configLoader: 'runner', cacheDir: join(workspace, 'cache') };
  if (mode === 'build') {
    await build({ ...config, build: { outDir: output, emptyOutDir: true } });
  } else {
    const { values } = parseArgs({ args, options: { port: { type: 'string' }, host: { type: 'string' } } });
    const serverOptions = { port: values.port && Number(values.port), host: values.host };
    if (mode === 'dev') {
      for (const name of packagePath === '.' ? [] : ['src', 'public']) {
        const live = join(process.env.BUILD_WORKSPACE_DIRECTORY, packagePath, name);
        if (existsSync(live)) {
          rmSync(join(root, name), { recursive: true, force: true });
          symlinkSync(live, join(root, name), 'dir');
        }
      }
      const live = join(process.env.BUILD_WORKSPACE_DIRECTORY, packagePath);
      if (packagePath === '.') {
        const { default: rootConfig } = await import(pathToFileURL(join(source, 'vite.config.js')));
        const base = dirname(realpathSync(join(source, 'vite.config.js')));
        Object.assign(config, rootConfig, { root: live, configFile: false, optimizeDeps: { entries: ['dev/*.html'] } });
        config.server = { ...rootConfig.server, watch: { ignored: ['**/bazel-*/**'] } };
        config.resolve = { ...rootConfig.resolve, alias: Object.fromEntries(Object.entries(rootConfig.resolve.alias).map(([name, path]) => [name, join(live, relative(base, path))])) };
      }
      const server = await createServer({
        ...config,
        plugins: [{
          name: 'mosaic-live-dependencies',
          enforce: 'pre',
          resolveId(id, importer) {
            if (importer?.startsWith(live + '/')) {
              if (!id.startsWith('.') && !id.startsWith('/')) {
                return this.resolve(id, source + importer.slice(live.length), { skipSelf: true });
              }
              const path = resolve(dirname(importer), id);
              if (path.startsWith(join(live, 'node_modules') + '/')) {
                return this.resolve(source + path.slice(live.length), undefined, { skipSelf: true });
              }
            }
          },
        }],
        server: { ...config.server, ...serverOptions, fs: { allow: [root, live, source] } },
      });
      await server.listen();
      server.printUrls();
      await new Promise(done => ['SIGINT', 'SIGTERM'].forEach(signal => process.once(signal, done)));
      await server.close();
    } else {
      const server = await preview({ ...config, build: { outDir: join(source, 'dist') }, preview: serverOptions });
      server.printUrls();
      await new Promise(done => ['SIGINT', 'SIGTERM'].forEach(signal => process.once(signal, done)));
      await new Promise(done => server.httpServer.close(done));
    }
  }
} finally {
  rmSync(workspace, { recursive: true, force: true });
}
