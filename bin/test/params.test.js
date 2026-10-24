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
  const root = mkdtempSync(resolve(tmpdir(), 'mosaic-params-'));
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
  ['ParamRef', ['$value', 'wire permits plain strings', '$$column'], [12, null, { param: 'x' }]],
  ['ParamBase', [{}, { select: 'value' }], [{ value: 1 }, { select: 'intersect' }]],
  ['Param', [{ value: null }, { value: ['$lower', 4], select: 'value' }], [{}, { value: {} }, { value: 1, extra: true }]],
  ['ParamDate', [{ date: '2024-01-01' }, { date: 'not a date', select: 'value' }], [{ date: 2024 }, { date: '2024', value: 1 }]],
  ['ParamLiteral', [null, 'a', 0, false], [[], {}]],
  ['ParamValue', [null, ['$lower', 4, false, null], []], [[[]], [{}], {}]],
  ['Selection', [{ select: 'single' }, { select: 'crossfilter', cross: false, empty: true, include: ['plain wire string', '$upstream'] }], [{}, { select: 'value' }, { select: 'union', include: {} }, { select: 'single', extra: 1 }]],
  ['ParamDefinition', [false, [1, '$lower'], { value: 2 }, { date: 'not a date' }, { select: 'intersect' }], [{}, { value: [] , date: '2024' }, { select: 'unknown' }]]
]) {
  test(`native #${name} preserves independent parameter admission boundaries`, () => {
    const root = workspace();
    const candidate = resolve(root, 'candidate.json');
    for (const [value, expected] of [...accepted.map(value => [value, 0]), ...rejected.map(value => [value, 1])]) {
      writeFileSync(candidate, JSON.stringify(value));
      const result = spawnSync(cue, ['vet', '-c', resolve(ROOT, 'packages/vgplot/spec/src/generated/params.cue'), candidate, '-d', `#${name}`], { cwd: ROOT, encoding: 'utf8' });
      assert.equal(result.error, undefined);
      assert.equal(result.status, expected, `${name}: ${JSON.stringify(value)}\n${result.stderr}`);
    }
  });
}

for (const [name, declaration, diagnostic] of [
  ['required contract descriptions', 'unused: model.#ShapeContract & {name:"Unused",wire:false,kind:"alias",expression:"unused"}', /description.*required|required.*description/s],
  ['nonempty contract descriptions', 'unused: model.#ShapeContract & {name:"Unused",description:"",wire:false,kind:"alias",expression:"unused"}', /description|empty disjunction/],
  ['closed expression kinds', 'unused: model.#ShapeExpression & {kind:"raw-code",text:"exec()"}', /kind|raw-code/],
  ['closed expression members', 'unused: model.#ShapeExpression & {kind:"array",items:"Value",source:"arbitrary code"}', /source|field not allowed/],
  ['required Python factory descriptions', 'unused: #PythonFactory & {}', /description.*required|required.*description/s]
]) {
  test(`unprojected parameter metadata rejects ${name}`, () => {
    const root = workspace(true);
    const imports = declaration.includes('model.') ? 'import "idl.uw.edu/mosaic/api/model"\n' : '';
    writeFileSync(resolve(root, 'api/params/invalid.cue'), `package params\n${imports}${declaration}\n`);
    assert.throws(() => execFileSync(cue, ['vet', '-c', './api/params'], { cwd: root, stdio: 'pipe' }), diagnostic);
  });
}

for (const [name, expression, diagnostic] of [
  ['missing contract references', '{kind:"named",name:"Missing"}', /Missing|reference/],
  ['missing array dependencies', '{kind:"array",items:"Missing"}', /Missing|undefined|dependencies/],
  ['cyclic expression dependencies', '{kind:"array",items:"Unused"}', /resolved|dependencies|conflicting values|cycle|incomplete/]
]) {
  test(`unused parameter projection rejects ${name}`, () => {
    const root = workspace(true);
    writeFileSync(resolve(root, 'api/params/invalid.cue'), `package params\nimport "idl.uw.edu/mosaic/api/render"\nunused: render.#ShapeProjection & {expressions:{Unused:${expression}},contracts:[]}\n`);
    assert.throws(() => execFileSync(cue, ['vet', '-c', './api/params'], { cwd: root, stdio: 'pipe' }), diagnostic);
  });
}
