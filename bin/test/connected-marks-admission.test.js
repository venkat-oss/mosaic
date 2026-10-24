import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { cpSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { resolve } from 'node:path';
import test from 'node:test';

const base = resolve(import.meta.dirname, '../..');
const cue = process.env.CUE_BIN;

for (const [name, file, pattern, replacement] of [
  ['missing contract prose', 'model/model.cue', /\s*description:\s*"Options for the link mark\."/, ''],
  ['wrong indexed contract', 'model/model.cue', /(contract:\s*)"CurveAutoOptions"/, '$1"MarkData"'],
  ['wrong indexed property', 'model/model.cue', /(property:\s*)"curve"/, '$1"missing"']
]) test('owning admission rejects ' + name + '', () => {
  const root = mkdtempSync(resolve(tmpdir(), 'mosaic-connected-admission-'));
  try {
    for (const path of ['cue.mod', 'api']) cpSync(resolve(base, path), resolve(root, path), { recursive: true, dereference: true, filter: () => true });
    const path = resolve(root, 'api/marks/connected', file);
    const source = readFileSync(path, 'utf8');
    assert.match(source, pattern);
    writeFileSync(path, source.replace(pattern, replacement));
    const result = spawnSync(cue, ['vet', '-c', './api/marks/connected'], { cwd: root, encoding: 'utf8' });
    assert.equal(result.status, 1, result.stderr);
    assert.match(result.stderr, /conflicting values|incomplete value|out of bound|empty disjunction|undefined field|cannot reference|field is required but not present/);
  } finally { rmSync(root, { recursive: true, force: true }); }
});
