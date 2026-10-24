import assert from 'node:assert/strict';
import { execFileSync, spawnSync } from 'node:child_process';
import { cpSync, mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { resolve } from 'node:path';
import { after, test } from 'node:test';
import { fileURLToPath } from 'node:url';

const ROOT = fileURLToPath(new URL('../..', import.meta.url));
const cue = process.env.CUE_BIN;
const workspaces = [];
function workspace(copy = false) {
  const root = mkdtempSync(resolve(tmpdir(), 'mosaic-table-input-'));
  workspaces.push(root);
  if (copy) for (const path of ['cue.mod', 'api']) {
    cpSync(resolve(ROOT, path), resolve(root, path), { recursive: true, dereference: true, filter: () => true });
  }
  return root;
}
after(() => workspaces.forEach(root => rmSync(root, { recursive: true, force: true })));

test('standalone native Table preserves dictionary keys, required options, numeric breadth and wire boundaries', () => {
  const root = workspace();
  const candidate = resolve(root, 'candidate.json');
  const native = resolve(ROOT, 'packages/vgplot/spec/src/generated/table-input.cue');
  const accepted = [
    { input: 'table', from: 'rows' },
    { input: 'table', from: 'ordinary-reference', align: { 'column.with space': 'justify' }, width: { 'column.with space': -2.5 } },
    { input: 'table', from: '$source', rowBatch: 0, height: -1, maxWidth: 0, width: 2.5 }
  ];
  const rejected = [
    {}, { input: 'table' }, { from: 'rows' }, { input: 'custom', from: 'rows' },
    { input: 'table', from: 3 }, { input: 'table', from: 'rows', columns: [3] },
    { input: 'table', from: 'rows', align: { x: 'start' } },
    { input: 'table', from: 'rows', width: { x: '30' } },
    { input: 'table', from: 'rows', height: null },
    { input: 'table', from: 'rows', format: {} }, { input: 'table', from: 'rows', element: {} }
  ];
  for (const [value, expected] of [...accepted.map(value => [value, 0]), ...rejected.map(value => [value, 1])]) {
    writeFileSync(candidate, JSON.stringify(value));
    const result = spawnSync(cue, ['vet', '-c', native, candidate, '-d', '#Table'], { encoding: 'utf8' });
    assert.equal(result.status, expected, result.stderr);
    if (expected === 0) {
      const exported = spawnSync(cue, ['export', native, candidate, '-d', '#Table', '--out', 'json'], { encoding: 'utf8' });
      assert.equal(exported.status, 0, exported.stderr);
      assert.deepEqual(JSON.parse(exported.stdout), value);
    }
  }
});

for (const [name, declaration] of [
  ['raw Python annotation text', 'unused: #PythonParameter & {name:"source",annotation:"execute()",kind:"positional-or-keyword",default:"required"}'],
  ['a non-final variadic Python parameter', 'pythonFactory:parameters:[{name:"opts",kind:"keyword-variadic",default:"required"},...]']
]) {
  test(`owning Table admission rejects ${name} `, () => {
    const root = workspace(true);
    writeFileSync(resolve(root, 'api/inputs/table/invalid.cue'), `package tableinput\n${declaration}\n`);
    assert.throws(() => execFileSync(cue, ['vet', '-c', './api/inputs/table'], { cwd: root, stdio: 'pipe' }), /conflicting values|not allowed|false|required|empty disjunction/);
  });
}
