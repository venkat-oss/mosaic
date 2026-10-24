import assert from 'node:assert/strict';
import { execFileSync, spawnSync } from 'node:child_process';
import { cpSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { resolve } from 'node:path';
import { after, test } from 'node:test';
import { fileURLToPath } from 'node:url';
import { validateSpec } from './util/spec-admission.js';

const ROOT = fileURLToPath(new URL('../..', import.meta.url));
const cue = process.env.CUE_BIN;
const workspaces = [];

function workspace() {
  const root = mkdtempSync(resolve(tmpdir(), 'mosaic-layouts-'));
  workspaces.push(root);
  for (const path of ['cue.mod', 'api']) {
    cpSync(resolve(ROOT, path), resolve(root, path), { recursive: true, dereference: true, filter: () => true });
  }
  return root;
}

after(() => workspaces.forEach(root => rmSync(root, { recursive: true, force: true })));

for (const name of ['HSpace', 'VSpace']) {
  test(`standalone native #${name} preserves unrestricted number|string spacing`, () => {
    const directory = mkdtempSync(resolve(tmpdir(), 'mosaic-layout-native-'));
    workspaces.push(directory);
    const path = resolve(directory, 'candidate.json');
    const key = name === 'HSpace' ? 'hspace' : 'vspace';
    for (const [value, expected] of [[{ [key]: -1.5 }, 0], [{ [key]: '' }, 0], [{ [key]: '$literal' }, 0], [{ [key]: 'not CSS' }, 0], [{ [key]: null }, 1], [{ [key]: 3, extra: true }, 1]]) {
      writeFileSync(path, JSON.stringify(value));
      const result = spawnSync(cue, ['vet', '-c', resolve(ROOT, 'packages/vgplot/spec/src/generated/layouts.cue'), path, '-d', `#${name}`], { encoding: 'utf8' });
      assert.equal(result.error, undefined);
      assert.equal(result.status, expected, result.stderr);
    }
  });
}

test('native root admits real recursive components and rejects nested malformed layouts', () => {
  const valid = JSON.parse(readFileSync(resolve(ROOT, 'templates/layouts/hconcat.json'), 'utf8'));
  const unknown = structuredClone(valid);
  unknown.hconcat[2].vconcat[0] = { diagonal: [] };
  const extra = structuredClone(valid);
  extra.hconcat[1].extra = true;
  const nestedArray = structuredClone(valid);
  nestedArray.hconcat = [[{ plot: [] }]];
  const badSpace = structuredClone(valid);
  badSpace.hconcat[1].hspace = false;
  assert.deepEqual(validateSpec([valid, unknown, extra, nestedArray, badSpace]).map(result => result.accepted), [true, false, false, false, false]);
});

for (const [name, declaration] of [
  ['missing prose', 'unused: #Layout & {name:"unused",type:"Unused",constant:"UNUSED",kind:"space",dimension:"width",parserOrder:0,codegenOrder:0,docOrder:0}'],
  ['unknown layout options', 'unused: #Layout & {name:"unused",type:"Unused",constant:"UNUSED",kind:"space",dimension:"width",parserOrder:0,codegenOrder:0,docOrder:0,description:"Space",propertyDescription:"Space",rawCode:"exec()"}'],
  ['unknown template variant', 'unused: #LayoutExample & {name:"diagonal",gap:12}'],
  ['invalid template size', 'unused: #LayoutExample & {name:"hspace",gap:{value:12}}'],
  ['duplicate parser priority', 'layouts: [_, {parserOrder:0}, ...]']
]) {
  test(`complete owning admission rejects ${name} before a projection with no writes`, () => {
    const root = workspace();
    writeFileSync(resolve(root, 'api/layouts/invalid.cue'), `package layouts\n${declaration}\n`);
    assert.throws(() => execFileSync(cue, ['vet', '-c', './api/layouts'], { cwd: root, stdio: 'pipe' }), /required|not allowed|conflicting values|empty disjunction|false|diagonal|gap/);
  });
}
