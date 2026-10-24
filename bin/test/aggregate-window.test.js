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
function workspace(sources = false) {
  const root = mkdtempSync(resolve(tmpdir(), 'mosaic-aggregate-window-'));
  workspaces.push(root);
  if (sources) for (const path of ['cue.mod', 'api']) cpSync(resolve(ROOT, path), resolve(root, path), { recursive: true, dereference: true, filter: () => true });
  return root;
}
function edit(root, path, pattern, replacement) {
  const target = resolve(root, path);
  const source = readFileSync(target, 'utf8');
  assert.match(source, pattern);
  writeFileSync(target, source.replace(pattern, replacement));
}
after(() => workspaces.forEach(root => rmSync(root, { recursive: true, force: true })));

for (const [name, accepted, rejected] of [
  ['AggregateOptions', [{}, { distinct: true }, { distinct: false }], [{ distinct: 'true' }, { unknown: true }]],
  ...['Years', 'Months', 'Days', 'Hours', 'Minutes', 'Seconds', 'Milliseconds', 'Microseconds'].map(name => [name, [{ [name.toLowerCase()]: 1 }, { [name.toLowerCase()]: -2.5 }], [{}, { [name.toLowerCase()]: '2' }, { [name.toLowerCase()]: 2, unknown: true }]]),
  ['IntervalTransform', [{ years: 1 }, { days: 2 }, { microseconds: 3 }], [{}, { days: 2, hours: 1 }, { day: 1 }]]
]) {
  test(`native #${name} admits only its complete closed contract`, () => {
    const root = workspace();
    const path = resolve(root, 'candidate.json');
    const family = name === 'AggregateOptions' ? 'aggregate' : 'window';
    for (const [value, expected] of [...accepted.map(value => [value, 0]), ...rejected.map(value => [value, 1])]) {
      writeFileSync(path, JSON.stringify(value));
      const result = spawnSync(cue, ['vet', '-c', resolve(ROOT, `packages/vgplot/spec/src/generated/${family}.cue`), path, '-d', `#${name}`], { cwd: ROOT, encoding: 'utf8' });
      assert.equal(result.error, undefined);
      assert.equal(result.status, expected, `${name}: ${JSON.stringify(value)}\n${result.stderr}`);
    }
  });
}

for (const family of ['aggregate', 'window']) {
  test(`unprojected ${family} metadata rejects altered contract references`, () => {
    const root = workspace(true);
    const target = resolve(root, `api/transforms/${family}/invalid.cue`);
    const apis = JSON.parse(execFileSync(cue, ['export', `./api/transforms/${family}`, '-e', 'apis'], { cwd: ROOT, encoding: 'utf8' }));
    const api = { ...apis.find(api => api.signature === 'unary'), argumentExpression: 'MissingExpression' };
    writeFileSync(target, `package ${family}\nunused: #TransformAPI & ${JSON.stringify(api)}\n`);
    edit(root, `api/transforms/${family}/contribution.cue`, /let FamilyFiles = files/, 'let FamilyFiles = {}');
    assert.throws(() => execFileSync(cue, ['vet', '-c', `./api/transforms/${family}`], { cwd: root, stdio: 'pipe' }), /MissingExpression|argumentExpression/);
  });
}

test('native root preserves recursive aggregate and window closure', () => {
  const spec = x => ({ plot: [{ mark: 'dot', data: [], x }] });
  const values = [
    { sum: { avg: 'x' }, rows: [-1, 0], distinct: true },
    { argmax: ['x', { sql: 'y + 1' }] },
    { lag: ['x', 2, null], orderby: 'x', range: [{ days: 2 }, 0] },
    { ntile: { sql: '2' } },
    { row_number: null },
    { argmax: ['x'] },
    { avg: 1 },
    { lag: ['x', 2] },
    { ntile: 2 },
    { rank: '' },
    { covariance: ['x', 'y'] }
  ];
  const results = validateSpec(values.map(spec));
  assert.deepEqual(results.map(result => result.accepted), [true, true, true, true, true, false, false, false, false, false, false], results.map(result => result.diagnostics).join('\n'));
});

test('frame kinds derive checked host names and sort by unique precedence', () => {
  const expected = [
    { key: 'rows', type: 'ROWS', javascript: 'frameRows', precedence: 0 },
    { key: 'range', type: 'RANGE', javascript: 'frameRange', precedence: 1 },
    { key: 'groups', type: 'GROUPS', javascript: 'frameGroups', precedence: 2 }
  ];
  const model = resolve(ROOT, 'api/transforms/window/model.cue');
  const root = workspace();
  const path = resolve(root, 'input.cue');
  for (const value of [{ key: 'rows', javascript: 'arbitrary', precedence: 0 }, { key: 'custom', precedence: 0 }, { key: 'rows', precedence: 3 }]) {
    writeFileSync(path, `package window\nunused: #FrameKind & ${JSON.stringify(value)}\n`);
    assert.throws(() => execFileSync(cue, ['vet', '-c', model, path], { cwd: ROOT, stdio: 'pipe' }));
  }
  const source = readFileSync(model, 'utf8');
  for (const replacement of ['{key: "rows", precedence: 1}', '{key: "range", precedence: 0}']) {
    writeFileSync(path, source.replace('{key: "range", precedence: 1}', replacement));
    assert.throws(() => execFileSync(cue, ['vet', '-c', path], { cwd: ROOT, stdio: 'pipe' }));
  }
  const pattern = /frameKindContracts: \[\.\.\.#FrameKind\] & \[\{key: "rows", precedence: 0\}, \{key: "range", precedence: 1\}, \{key: "groups", precedence: 2\}\]/;
  assert.match(source, pattern);
  writeFileSync(path, source.replace(pattern, 'frameKindContracts: [...#FrameKind] & [{key:"groups",precedence:2},{key:"rows",precedence:0},{key:"range",precedence:1}]'));
  const output = execFileSync(cue, ['export', path, '-e', 'frameKinds'], { cwd: ROOT, encoding: 'utf8' });
  assert.deepEqual(JSON.parse(output), expected);
});
