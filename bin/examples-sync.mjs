import { existsSync, readdirSync, readFileSync, mkdirSync, unlinkSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { exampleDirectories } from './gallery-paths.mjs';

const args = process.argv.slice(2);
const check = args[0] === '--check';
if (check) args.shift();
if (args.length !== (check ? 2 : 1)) throw new Error('Usage: examples-sync [--check] generated [workspace-marker]');
const runfile = name => resolve(process.env.RUNFILES_DIR || process.env.JS_BINARY__RUNFILES, name);
const generated = runfile(args[0]);
const workspace = check ? dirname(runfile(args[1])) : process.env.BUILD_WORKSPACE_DIRECTORY;
if (!workspace) throw new Error('Run gallery generation with bazel run //:examples.');
const stale = [];
for (const directory of Object.values(exampleDirectories)) {
  const files = root => existsSync(join(root, directory))
    ? readdirSync(join(root, directory)).filter(name => name !== 'index.md')
    : [];
  const expected = new Set(files(generated));
  for (const name of files(workspace).filter(name => !expected.has(name))) {
    const path = join(workspace, directory, name);
    if (check) stale.push(join(directory, name));
    else unlinkSync(path);
  }
  for (const name of expected) {
    const content = readFileSync(join(generated, directory, name));
    const target = join(workspace, directory, name);
    if (check) {
      if (!existsSync(target) || !readFileSync(target).equals(content)) stale.push(join(directory, name));
    } else {
      mkdirSync(dirname(target), { recursive: true });
      writeFileSync(target, content);
    }
  }
}
if (stale.length) throw new Error('Gallery files are stale. Run bazel run //:examples:\n' + stale.join('\n'));
