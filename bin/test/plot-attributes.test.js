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

function workspace(sources = false) {
  const root = mkdtempSync(resolve(tmpdir(), 'mosaic-plot-attributes-'));
  workspaces.push(root);
  if (sources) {
    for (const path of ['cue.mod', 'api']) {
      cpSync(resolve(ROOT, path), resolve(root, path), { recursive: true, dereference: true, filter: () => true });
    }
  }
  return root;
}

after(() => workspaces.forEach(root => rmSync(root, { recursive: true, force: true })));

for (const [name, accepted, rejected] of [
  ['name', ['chart', ''], [null]],
  ['width', [320, 'wire-only'], [false]],
  ['height', [-1.5, '$dimension'], [null]],
  ['aspectRatio', [false, null], [{}]],
  ['margin', [0, '$spacing'], [false]],
  ['marginTop', [2, '$spacing'], [null]],
  ['marginRight', [0, '$spacing'], [[]]],
  ['marginBottom', [4, '$spacing'], [false]],
  ['marginLeft', [5, '$spacing'], [{}]],
  ['margins', [{}, { top: '$spacing', right: 0 }], [{ extra: 1 }, { top: false }]],
  ['inset', [-1, '$spacing'], [null]],
  ['style', [null, { color: 'red', length: 2 }, { custom: 'wire-only' }], [{ color: 2 }, { length: '2' }]],
  ['align', [0.5, 'wire-only'], [false]],
  ['padding', [0.2, '$padding'], [null]],
  ['axis', ['both', null, 'wire-only'], [1]],
  ['grid', [true, '#ccc'], [null]],
  ['ariaLabel', ['Chart', null], [false]],
  ['ariaDescription', ['Description', null], [1]],
  ['clip', ['frame', true, null, 'wire-only'], [1]]
]) {
  test(`native plot/container ${name} preserves independent admission cases`, () => {
    const root = workspace();
    const candidate = resolve(root, 'candidate.json');
    for (const [value, expected] of [...accepted.map(value => [value, 0]), ...rejected.map(value => [value, 1])]) {
      writeFileSync(candidate, JSON.stringify({ [name]: value }));
      const result = spawnSync(cue, ['vet', '-c', resolve(ROOT, 'packages/vgplot/spec/src/generated/plot-attributes.cue'), candidate, '-d', '#PlotContainerAttributes'], { cwd: ROOT, encoding: 'utf8' });
      assert.equal(result.error, undefined);
      assert.equal(result.status, expected, `${name}: ${JSON.stringify(value)}\n${result.stderr}`);
    }
  });
}

for (const [name, fields] of [
  ['missing prose', 'name:"unused",type:"numberReference",tsSection:"unused",jsSection:"unused",jsKind:"simple",python:{name:"unused",default:"required",kind:"value"},route:{kind:"wrapper-only"}'],
  ['raw code fields', 'name:"unused",type:"numberReference",description:"Unused",tsSection:"unused",jsSection:"unused",jsKind:"simple",python:{name:"unused",default:"required",kind:"value"},route:{kind:"wrapper-only"},code:"exec()"'],
  ['duplicate paired targets', 'name:"unused",type:"numberReference",description:"Unused",tsSection:"unused",jsSection:"unused",jsKind:"paired",targets:["xDomain","xDomain"],python:{name:"unused",default:"required",kind:"value"},route:{kind:"wrapper-only"}'],
  ['missing second paired target', 'name:"unused",type:"numberReference",description:"Unused",tsSection:"unused",jsSection:"unused",jsKind:"paired",targets:["xDomain"],python:{name:"unused",default:"required",kind:"value"},route:{kind:"wrapper-only"}']
]) {
  test(`closed shared attribute metadata rejects ${name} before projection`, () => {
    const root = workspace(true);
    writeFileSync(resolve(root, 'api/attributes/plot/invalid.cue'), `package plotattributes\nimport attributeModel "idl.uw.edu/mosaic/api/attributes"\nunused: attributeModel.#Attribute & {${fields}}\n`);
    assert.throws(() => execFileSync(cue, ['vet', '-c', './api/attributes/plot'], { cwd: root, stdio: 'pipe' }), /required|not allowed|_targetsDistinct|incompatible list lengths/);
  });
}
