import { chmodSync, cpSync, copyFileSync, mkdirSync, mkdtempSync, readdirSync, realpathSync, rmSync, symlinkSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join, relative, resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { parseArgs } from 'node:util';
import { build, createServer, serve } from 'vitepress';

const [galleryPath, outputPath, mode = 'build', ...args] = process.argv.slice(2);
const source = process.cwd();
const pathRoot = mode === 'build' ? process.env.JS_BINARY__EXECROOT || source : process.env.RUNFILES_DIR || process.env.JS_BINARY__RUNFILES;
const gallery = resolve(pathRoot, galleryPath);
const output = resolve(pathRoot, outputPath);
const workspace = mkdtempSync(join(tmpdir(), 'mosaic-docs-'));
const docs = join(workspace, 'docs');
try {
  // Node's cp fast path preserves nested sandbox links despite dereference.
  cpSync(join(source, 'docs'), docs, { recursive: true, dereference: true, filter: () => true });
  cpSync(join(gallery, 'docs'), docs, { recursive: true, dereference: true, filter: () => true });
  for (const entry of readdirSync(workspace, { recursive: true, withFileTypes: true })) {
    chmodSync(join(entry.parentPath, entry.name), entry.isDirectory() ? 0o755 : 0o644);
  }
  copyFileSync(join(source, 'vite.config.js'), join(workspace, 'vite.config.js'));
  copyFileSync(join(source, 'package.json'), join(workspace, 'package.json'));
  for (const name of ['node_modules', 'data', 'templates']) {
    symlinkSync(join(source, name), join(workspace, name), 'dir');
  }
  for (const name of ['data', 'templates']) {
    symlinkSync('../../' + name, join(docs, 'public', name), 'dir');
  }
  if (mode === 'dev') {
    const live = process.env.BUILD_WORKSPACE_DIRECTORY;
    for (const directory of ['', '.vitepress', 'public']) {
      for (const entry of readdirSync(join(live, 'docs', directory), { withFileTypes: true })) {
        if (['BUILD.bazel', 'site-builder.mjs', '.vitepress', 'examples', 'public', 'data', 'templates', 'specs', 'config.js', 'cache', 'dist', '.temp'].includes(entry.name)) continue;
        const target = join(docs, directory, entry.name);
        rmSync(target, { recursive: true, force: true });
        symlinkSync(join(live, 'docs', directory, entry.name), target, entry.isDirectory() ? 'dir' : 'file');
      }
    }
    const { default: viteConfig } = await import(pathToFileURL(join(source, 'vite.config.js')));
    const packages = new Set(Object.values(viteConfig.resolve.alias).map(path => relative(dirname(realpathSync(join(source, 'vite.config.js'))), path).split('/').slice(0, 3).join('/')));
    for (const path of packages) {
      const target = join(workspace, path);
      mkdirSync(target, { recursive: true });
      copyFileSync(join(source, path, 'package.json'), join(target, 'package.json'));
      symlinkSync(join(live, path, 'src'), join(target, 'src'), 'dir');
      symlinkSync(join(source, path, 'node_modules'), join(target, 'node_modules'), 'dir');
    }
  } else {
    symlinkSync(join(source, 'packages'), join(workspace, 'packages'), 'dir');
  }
  if (mode === 'build') {
    await build(docs, { outDir: output });
  } else {
    copyFileSync(join(docs, '.vitepress/config.js'), join(docs, '.vitepress/source-config.js'));
    writeFileSync(join(docs, '.vitepress/config.js'), `import config from './source-config.js';\nconfig.outDir = ${JSON.stringify(output)};\nexport default config;\n`);
    const { values } = parseArgs({ args, options: { port: { type: 'string' }, host: { type: 'string' } } });
    const port = values.port && Number(values.port);
    if (mode === 'dev') {
      const configPath = join(docs, '.vitepress/config.js');
      const live = process.env.BUILD_WORKSPACE_DIRECTORY;
      writeFileSync(configPath, `import config from './source-config.js';
config.vite.plugins.push({
  name: 'mosaic-live-dependencies',
  enforce: 'pre',
  resolveId(id, importer) {
    const live = ${JSON.stringify(live)};
    if (importer?.startsWith(live + '/') && !id.startsWith('.') && !id.startsWith('/')) {
      return this.resolve(id, ${JSON.stringify(source)} + importer.slice(live.length), { skipSelf: true });
    }
  }
});
export default config;
`);
    }
    const server = mode === 'dev'
      ? await createServer(docs, { port, host: values.host, fs: { allow: [workspace, source, process.env.BUILD_WORKSPACE_DIRECTORY] } })
      : await serve({ root: docs, port });
    if (mode === 'dev') {
      await server.listen();
      server.printUrls();
    }
    await new Promise(done => ['SIGINT', 'SIGTERM'].forEach(signal => process.once(signal, done)));
    if (mode === 'dev') await server.close();
    else await new Promise(done => server.server.close(done));
  }
} finally {
  rmSync(workspace, { recursive: true, force: true });
}
