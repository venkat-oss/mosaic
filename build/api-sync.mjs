import { existsSync, mkdirSync, readFileSync, realpathSync, unlinkSync, writeFileSync } from 'node:fs';
import { dirname, isAbsolute, relative, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

export function artifactPath(root, name) {
  const path = resolve(root, name);
  const rel = relative(root, path);
  if (!rel || rel.startsWith('..') || isAbsolute(rel)) throw new Error('Invalid API artifact path: ' + name);
  return path;
}

function previousArtifacts(root) {
  const path = resolve(root, 'api/generated.json');
  return existsSync(path) ? JSON.parse(readFileSync(path, 'utf8')) : [];
}

export function writeAPIPlan({ root, files, check = false, previous = previousArtifacts(root) }) {
  const stale = [];
  for (const name of [...previous, ...Object.keys(files)]) artifactPath(root, name);
  for (const [name, contents] of Object.entries(files)) {
    if (typeof contents !== 'string') throw new Error('API artifact content must be text: ' + name);
  }
  for (const name of previous.filter(name => !Object.hasOwn(files, name))) {
    const path = artifactPath(root, name);
    if (check) {
      if (existsSync(path)) stale.push(name);
    } else {
      try {
        unlinkSync(path);
      } catch (error) {
        if (error.code !== 'ENOENT') throw error;
      }
    }
  }
  for (const [name, contents] of Object.entries(files)) {
    const path = artifactPath(root, name);
    if (check) {
      let actual;
      try {
        actual = readFileSync(path, 'utf8');
      } catch (error) {
        if (error.code !== 'ENOENT') throw error;
      }
      if (actual !== contents) stale.push(name);
    } else {
      mkdirSync(dirname(path), { recursive: true });
      writeFileSync(path, contents);
    }
  }
  if (stale.length) throw new Error('Generated API files are stale. Run bazel run //:generate:\n' + stale.join('\n'));
  return Object.keys(files);
}

export function readArtifacts(root) {
  const manifest = JSON.parse(readFileSync(artifactPath(root, 'api/generated.json'), 'utf8'));
  return Object.fromEntries([...manifest, 'api/generated.json'].map(name => [name, readFileSync(artifactPath(root, name), 'utf8')]));
}

function runfile(name) {
  return resolve(process.env.RUNFILES_DIR || process.env.JS_BINARY__RUNFILES || process.cwd(), name);
}

if (process.argv[1] && existsSync(process.argv[1]) && realpathSync(process.argv[1]) === realpathSync(fileURLToPath(import.meta.url))) {
  const args = process.argv.slice(2);
  const check = args[0] === '--check';
  if (check) args.shift();
  if (args.length !== (check ? 2 : 1)) throw new Error('Usage: api-sync [--check] artifacts [mirror-manifest]');
  const root = check ? dirname(dirname(runfile(args[1]))) : process.env.BUILD_WORKSPACE_DIRECTORY;
  if (!root) throw new Error('Run mirror generation with bazel run //:generate.');
  writeAPIPlan({ root, files: readArtifacts(runfile(args[0])), check });
}
