import assert from 'node:assert/strict';
import { mkdirSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { spawnSync } from 'node:child_process';

export function installPackages(pnpm, packages, links) {
  const directory = join(process.env.TEST_TMPDIR, 'consumer');
  const home = join(directory, 'home');
  mkdirSync(home, { recursive: true });
  const env = { ...process.env, BAZEL_BINDIR: '.', HOME: home, XDG_CONFIG_HOME: join(home, '.config'), XDG_CACHE_HOME: join(home, '.cache') };
  const run = (command, args) => {
    const result = spawnSync(command, args, { cwd: directory, env, encoding: 'utf8', timeout: 120000 });
    assert.equal(result.status, 0, `${command} ${args.join(' ')}\n${result.stdout}\n${result.stderr}\n${result.error ?? ''}`);
    return result.stdout;
  };
  writeFileSync(join(directory, 'package.json'), JSON.stringify({
    private: true,
    type: 'module',
    dependencies: Object.fromEntries(Object.entries(packages).map(([name, path]) => [name, `file:${path}`]))
  }));
  writeFileSync(join(directory, 'pnpm-workspace.yaml'), JSON.stringify({
    overrides: {
      ...Object.fromEntries(Object.entries(packages).map(([name, path]) => [name, `file:${path}`])),
      ...Object.fromEntries(Object.entries(links).map(([name, path]) => [name, `link:${path}`]))
    }
  }));
  run(pnpm, ['install', '--offline', '--ignore-scripts', '--no-frozen-lockfile', '--store-dir', join(directory, 'store')]);
  return { directory, run };
}
