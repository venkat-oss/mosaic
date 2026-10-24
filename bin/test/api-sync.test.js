import assert from 'node:assert/strict';
import { existsSync, mkdirSync, mkdtempSync, readdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { resolve } from 'node:path';
import { after, test } from 'node:test';
import { readArtifacts, writeAPIPlan } from '../../build/api-sync.mjs';

const workspaces = [];
function workspace() {
  const root = mkdtempSync(resolve(tmpdir(), 'mosaic-api-sync-'));
  workspaces.push(root);
  return root;
}
after(() => workspaces.forEach(root => rmSync(root, { recursive: true, force: true })));

function contents(root) {
  const state = {};
  function visit(directory) {
    for (const entry of readdirSync(resolve(root, directory), { withFileTypes: true })) {
      const name = directory ? `${directory}/${entry.name}` : entry.name;
      if (entry.isDirectory()) visit(name);
      else state[name] = readFileSync(resolve(root, name), 'utf8');
    }
  }
  visit('');
  return state;
}

function write(root, path, text) {
  const target = resolve(root, path);
  mkdirSync(resolve(target, '..'), { recursive: true });
  writeFileSync(target, text);
}

for (const previous of [
  ['old-only.txt', 'transferred.txt', 'new-only.txt'],
  ['new-only.txt', 'transferred.txt', 'old-only.txt']
]) {
  test(`writeAPIPlan preserves globally transferred paths for previous order ${previous[0]}`, () => {
    const root = workspace();
    write(root, 'transferred.txt', 'old owner\n');
    write(root, 'old-only.txt', 'obsolete\n');
    const files = { 'transferred.txt': 'new owner\n', 'new-only.txt': 'new artifact\n' };
    writeAPIPlan({ root, files, previous });
    assert.equal(readFileSync(resolve(root, 'transferred.txt'), 'utf8'), 'new owner\n');
    assert.equal(readFileSync(resolve(root, 'new-only.txt'), 'utf8'), 'new artifact\n');
    assert.equal(existsSync(resolve(root, 'old-only.txt')), false);
    assert.deepEqual(writeAPIPlan({ root, files, previous, check: true }), Object.keys(files));
  });
}

test('writeAPIPlan reports missing, modified, obsolete and newly required untracked outputs without mutation', () => {
  const root = workspace();
  write(root, 'modified.txt', 'modified');
  write(root, 'obsolete.txt', 'obsolete');
  const files = { 'modified.txt': 'expected', 'missing.txt': 'missing', 'untracked.txt': 'new' };
  const before = contents(root);
  assert.throws(() => writeAPIPlan({
    root, files, previous: ['modified.txt', 'missing.txt', 'obsolete.txt'], check: true
  }), error => {
    for (const name of ['modified.txt', 'missing.txt', 'obsolete.txt', 'untracked.txt']) {
      assert.ok(error.message.includes(name), error.message);
    }
    return true;
  });
  assert.deepEqual(contents(root), before);
  writeAPIPlan({ root, files, previous: ['modified.txt', 'missing.txt', 'obsolete.txt'] });
  const generated = contents(root);
  writeAPIPlan({ root, files, previous: Object.keys(files), check: true });
  assert.deepEqual(contents(root), generated);
});

test('writeAPIPlan rejects paths outside the root for outputs and obsolete artifacts', () => {
  const root = workspace();
  for (const path of ['', '..', '../escape.txt', resolve(root, '../absolute-escape.txt')]) {
    const before = contents(root);
    assert.throws(() => writeAPIPlan({ root, files: { [path]: 'escape' }, previous: [] }), /Invalid API artifact path/);
    assert.throws(() => writeAPIPlan({ root, files: {}, previous: [path] }), /Invalid API artifact path/);
    assert.deepEqual(contents(root), before);
  }
});

test('readArtifacts loads only files owned by the generated manifest', () => {
  const root = workspace();
  write(root, 'output.ts', 'export {};\n');
  write(root, 'unowned.txt', 'leave alone');
  write(root, 'api/generated.json', JSON.stringify(['output.ts']));
  const files = readArtifacts(root);
  assert.deepEqual(Object.keys(files), ['output.ts', 'api/generated.json']);
  assert.equal(files['output.ts'], 'export {};\n');
  write(root, 'api/generated.json', JSON.stringify(['../escape.ts']));
  assert.throws(() => readArtifacts(root), /Invalid API artifact path/);
});
