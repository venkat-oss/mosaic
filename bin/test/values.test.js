import assert from 'node:assert/strict';
import { execFileSync, spawnSync } from 'node:child_process';
import { cpSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { resolve } from 'node:path';
import { after, test } from 'node:test';
import { fileURLToPath } from 'node:url';

const ROOT = fileURLToPath(new URL('../..', import.meta.url));
const cue = process.env.CUE_BIN;
const workspaces = [];
const nativeCases = [
  ['Fixed', ['Fixed'], ['fixed', false]],
  ['LiteralTimeInterval', ['2 months', 'custom wire interval'], [2, {}]],
  ['TimeIntervalName', ['half', 'monday'], ['halfs', 'Monday']],
  ['Interval', ['week', 'custom wire interval'], [2, null]],
  ['ScaleName', ['fx', 'length'], ['area', 'X']],
  ['PositionScaleType', ['band', 'quantize'], ['ordinal', 'categorical']],
  ['ColorScaleType', ['diverging-sqrt', 'cyclical'], ['cyclic', 'logarithmic']],
  ['ContinuousScaleType', ['time', 'sqrt'], ['band', 'ordinal']],
  ['DiscreteScaleType', ['ordinal', 'identity'], ['linear', 'band']],
  ['ProjectionName', ['albers-usa', 'reflect-y'], ['natural-earth', 'Mercator']],
  ['Interpolate', ['hcl', 'number'], ['RGB', 'viridis']],
  ['ColorScheme', ['YlGnBu', {}, { extension: 1 }], ['ylgnbu', 'YLGNBU', null]],
  ['SymbolType', ['triangle2', 'wye'], ['triangle3', 'Circle']],
  ['FrameAnchor', ['middle', 'bottom-left'], ['center', 'left-top']],
  ['ReducerPercentile', ['p00', 'p99'], ['p0', 'p100', 'p-1']],
  ['Reducer', ['proportion-facet', 'p00', 'p99'], ['p100', 'average']],
  ['CurveName', ['catmull-rom-closed', 'step-before'], ['bezier', 'STEP']],
  ['CSSStyles', [{ color: 'purple', length: 2 }, { mosaicUnknown: 'wire-only' }],
    [{ length: '2' }, { color: 3 }, { mosaicUnknown: 3 }, null]]
];

function workspace({ sources = false } = {}) {
  const root = mkdtempSync(resolve(tmpdir(), 'mosaic-values-'));
  workspaces.push(root);
  for (const path of sources ? ['cue.mod', 'api'] : []) {
    cpSync(resolve(ROOT, path), resolve(root, path), { recursive: true, dereference: true, filter: () => true });
  }
  return root;
}

function edit(root, path, pattern, replacement) {
  const target = resolve(root, path);
  const source = readFileSync(target, 'utf8');
  assert.match(source, pattern);
  writeFileSync(target, source.replace(pattern, replacement));
}

after(() => workspaces.forEach(root => rmSync(root, { recursive: true, force: true })));

for (const [name, accepted, rejected] of nativeCases) {
  test(`native #${name} admits independent wire values and rejects invalid boundaries`, () => {
    const root = workspace();
    const path = resolve(root, 'candidate.json');
    for (const [value, expected] of [
      ...accepted.map(value => [value, 0]),
      ...rejected.map(value => [value, 1])
    ]) {
      writeFileSync(path, JSON.stringify(value));
      const result = spawnSync(cue, [
        'vet', '-c', resolve(ROOT, 'packages/vgplot/spec/src/generated/values.cue'), path, '-d', `#${name}`
      ], { cwd: ROOT, encoding: 'utf8' });
      assert.equal(result.error, undefined);
      assert.equal(result.status, expected, `${name} ${JSON.stringify(value)}: ${result.stderr}`);
    }
  });
}

test('value metadata requires complete admission', () => {
  const root = workspace({ sources: true });
  writeFileSync(resolve(root, 'api/values/invalid.cue'), `package values
import shared "idl.uw.edu/mosaic/api/model"
unused: shared.#ValueContract & {
  name: "Unused"
  file: "PlotTypes.ts"
  kind: "literal"
  value: "unused"
  exported: false
}
`);

  assert.throws(() => execFileSync(cue, ['vet', '-c', './api/values'], { cwd: root, stdio: 'pipe' }), /description.*required|required.*description/s);

});

test('unsupported value adapters fail before an artifact can be projected', () => {
  const root = workspace({ sources: true });
  edit(root, 'api/values/model.cue', /adapter:\s*"dom-css"/, 'adapter: "arbitrary-host-code"');

  assert.throws(() => execFileSync(cue, ['vet', '-c', './api/values'], { cwd: root, stdio: 'pipe' }), /adapter|arbitrary-host-code/);

});

for (const [name, record, diagnostic] of [
  ['unknown host reference', { name: 'ChannelValue', description: 'Unsupported host reference.', type: { kind: 'ref', name: 'UntrustedHost' } }, /UntrustedHost|name/],
  ['missing description', { name: 'ChannelValue', type: { kind: 'ref', name: 'str' } }, /description.*required|required.*description/s]
]) {
  test(`unprojected Python aliases reject ${name}`, () => {
    const root = workspace({ sources: true });
    writeFileSync(resolve(root, 'api/values/invalid.cue'),
      `package values\nunusedAlias: #PythonAlias & ${JSON.stringify(record)}\n`);
    assert.throws(() => execFileSync(cue, ['vet', '-c', './api/values'], { cwd: root, stdio: 'pipe' }), diagnostic);
  });
}
