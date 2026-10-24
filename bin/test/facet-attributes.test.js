import assert from 'node:assert/strict';
import { execFileSync, spawnSync } from 'node:child_process';
import { cpSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { resolve } from 'node:path';
import { after, test } from 'node:test';
import { fileURLToPath } from 'node:url';

const ROOT = fileURLToPath(new URL('../..', import.meta.url));
const cue = process.env.CUE_BIN;
const roots = [];

function workspace(sources = false) {
  const root = mkdtempSync(resolve(tmpdir(), 'mosaic-facet-attributes-'));
  roots.push(root);
  if (sources) for (const name of ['cue.mod', 'api']) cpSync(resolve(ROOT, name), resolve(root, name), { recursive: true, dereference: true, filter: () => true });
  return root;
}

function edit(root, path, before, after) {
  const file = resolve(root, path);
  const source = readFileSync(file, 'utf8');
  assert.match(source, before);
  writeFileSync(file, source.replace(before, after));
}

after(() => roots.forEach(root => rmSync(root, { recursive: true, force: true })));

for (const [name, accepted, rejected] of [
  ['facetMarginBottom', [0, 12, '$margin'], [null, false]],
  ['facetGrid', [true, 'day', [1, 2]], [null, 4]],
  ['facetLabel', ['Groups', null], [false, 1]],
  ['fxDomain', [[1, 2], 'Fixed', 'wire-only'], [null, false]],
  ['fyRange', [[20, 300], 'Fixed', '$range'], [null, 1]],
  ['fyInset', [60, '$inset'], [null, false]],
  ['fxAxis', ['top', 'both', false, null, 'wire-only'], [1, []]],
  ['fyTicks', [4, 'day', [10, 20]], [null, false, { days: 1 }]],
  ['fxTickFormat', ['.0f', null], [false, {}]],
  ['fyGrid', [true, 'day', [10, 20]], [null, 4]],
  ['fxLabelAnchor', ['top', 'center', 'wire-only'], [null, false]],
  ['fyLabelAnchor', ['left', 'center'], [null, 1]],
  ['fyAriaDescription', ['Groups', '$description'], [null, []]]
]) {
  test(`native facet ${name} retains its independent wire boundary`, () => {
    const root = workspace();
    const file = resolve(root, 'payload.json');
    for (const [values, expected] of [[accepted, 0], [rejected, 1]]) for (const value of values) {
      writeFileSync(file, JSON.stringify({ [name]: value }));
      const result = spawnSync(cue, ['vet', '-c', resolve(ROOT, 'packages/vgplot/spec/src/generated/facet-attributes.cue'), file, '-d', '#FacetAttributes'], { cwd: ROOT, encoding: 'utf8' });
      assert.equal(result.error, undefined);
      assert.equal(result.status, expected, `${name}: ${JSON.stringify(value)}\n${result.stderr}`);
    }
  });
}

for (const [name, source] of [
  ['foreign family metadata', 'unused:#FacetAttribute & {name:"colorScale",type:"numberReference",description:"Unused",tsSection:"unused",jsSection:"unused",jsKind:"simple",python:{name:"unused",default:"required",kind:"value"},route:{kind:"mapped",path:"color.type",order:0}}'],
]) {
  test(`owning facet admission rejects ${name}`, () => {
    const root = workspace(true);
    writeFileSync(resolve(root, 'api/attributes/facet/invalid.cue'), `package facetattributes\n${source}\n`);
    assert.throws(() => execFileSync(cue, ['vet', '-c', './api/attributes/facet'], { cwd: root, stdio: 'pipe' }), /not allowed|empty disjunction|out of bound|conflicting values/);
  });
}

test('the exact retained comma route is enforced independently of selected artifacts', () => {
  const root = workspace(true);
  edit(root, 'api/attributes/facet/model.cue', /"fy,inset"/, '"fy.inset"');

  assert.throws(() => execFileSync(cue, ['vet', '-c', './api/attributes/facet'], { cwd: root, stdio: 'pipe' }), /commaRoute|conflicting values/);

});
