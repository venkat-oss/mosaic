import assert from 'node:assert/strict';
import { execFileSync, spawnSync } from 'node:child_process';
import { cpSync, mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { resolve } from 'node:path';
import { after, test } from 'node:test';
import { fileURLToPath } from 'node:url';
import { validateSpec } from './util/spec-admission.js';

const ROOT = fileURLToPath(new URL('../..', import.meta.url));
const cue = process.env.CUE_BIN;
const workspaces = [];

function workspace(sources = false) {
  const root = mkdtempSync(resolve(tmpdir(), 'mosaic-column-'));
  workspaces.push(root);
  if (sources) {
    for (const path of ['cue.mod', 'api']) {
      cpSync(resolve(ROOT, path), resolve(root, path), { recursive: true, dereference: true, filter: () => true });
    }
  }
  return root;
}

after(() => workspaces.forEach(root => rmSync(root, { recursive: true, force: true })));

test('public transform declarations preserve nullary and unary argument arity', () => {
  const root = workspace();
  const path = resolve(root, 'input.mts');
  writeFileSync(path, `import type { Bin, Count, DateDay } from '${resolve(ROOT, 'packages/vgplot/spec/src/spec/Transform.js')}';
const counts: Count[] = [{count: null}, {count: []}, {count: 'x'}, {count: ['x']}];
const bins: Bin[] = [{bin: 'x'}, {bin: ['x']}, {bin: {sql: 'x + 1'}}];
const date: DateDay = {dateDay: new Date()};
// @ts-expect-error nullary arguments cannot carry two fields
const tooMany: Count = {count: ['x', 'y']};
// @ts-expect-error unary arguments require one field
const empty: Bin = {bin: []};
// @ts-expect-error unary arguments cannot carry two fields
const pair: Bin = {bin: ['x', 'y']};
// @ts-expect-error date transforms require an argument
const noDate: DateDay = {dateDay: []};
void [counts, bins, date, tooMany, empty, pair, noDate];
`);
  const config = resolve(root, 'tsconfig.json');
  writeFileSync(config, JSON.stringify({
    extends: resolve(ROOT, 'tsconfig.base.json'),
    files: [path],
    compilerOptions: { noEmit: true, composite: false, incremental: false, checkJs: false }
  }));
  execFileSync(process.env.TSC_BIN, ['--project', config], { cwd: root, stdio: 'pipe', env: { ...process.env, BAZEL_BINDIR: '.' } });
});

for (const [name, accepted, rejected] of [
  ['Expression', [{ sql: 'x + 1' }, { agg: 'AVG(x)' }], [{}, { sql: 'x', agg: 'AVG(x)' }]],
  ['SQLExpression', [{ sql: 'x + $offset', label: 'Position' }], [{ sql: 1 }, { sql: 'x', extra: true }]],
  ['AggregateExpression', [{ agg: 'AVG(x)', label: 'Average' }], [{ agg: null }, { agg: 'AVG(x)', sql: 'x' }]],
  ['FrameExclude', ['CURRENT ROW', 'NO OTHERS'], ['current row', 'Current Row', null]],
  ['BinInterval', ['date', 'number', 'millisecond', 'year'], ['week', 'DAY', 1]],
  ['Column', [{ column: 'x' }, { column: ['$field'] }], [{ column: [] }, { column: ['x', 'y'] }, { column: { sql: 'x' } }]]
]) {
  test(`native #${name} preserves its complete local closure`, () => {
    const root = workspace();
    const candidate = resolve(root, 'candidate.json');
    for (const [value, expected] of [...accepted.map(value => [value, 0]), ...rejected.map(value => [value, 1])]) {
      writeFileSync(candidate, JSON.stringify(value));
      const result = spawnSync(cue, ['vet', '-c', resolve(ROOT, 'packages/vgplot/spec/src/generated/column.cue'), candidate, '-d', `#${name}`], { cwd: ROOT, encoding: 'utf8' });
      assert.equal(result.error, undefined);
      assert.equal(result.status, expected, `${name}: ${JSON.stringify(value)}\n${result.stderr}`);
    }
  });
}

for (const [name, declaration, diagnostic] of [
  ['unsupported Python expression factories', 'unused: #PythonExpressionAdapter & {name:"execute"}', /name|execute/],
  ['unknown native hosts', 'unused: model.#ShapeExpression & {kind:"host",adapter:"Date.parse"}', /adapter|Date.parse/],
  ['injected tuple labels', 'unused: model.#ShapeExpression & {kind:"tuple",elements:[{type:"String",label:"exec()"}]}', /label|exec/]
]) {
  test(`unprojected column metadata rejects ${name}`, () => {
    const root = workspace(true);
    const imports = declaration.includes('model.') ? 'import "idl.uw.edu/mosaic/api/model"\n' : '';
    writeFileSync(resolve(root, 'api/transforms/column/invalid.cue'), `package column\n${imports}${declaration}\n`);
    assert.throws(() => execFileSync(cue, ['vet', '-c', './api/transforms/column'], { cwd: root, stdio: 'pipe' }), diagnostic);
  });
}

test('native root admits recursive column closure and rejects nested tuple and key errors', () => {
  const spec = x => ({ params: { offset: 1 }, plot: [{ mark: 'dot', data: [], x, y: 'y' }] });
  const examples = [
    spec({ bin: { sql: 'x + $offset' }, steps: 4 }),
    spec({ dateMonth: [{ bin: 'time', interval: 'day' }] }),
    spec({ geojson: { centroid: 'geometry' } }),
    spec({ bin: ['x', 'y'] }),
    spec({ bin: 'x', extra: true }),
    spec({ dateDay: [] })
  ];
  const results = validateSpec(examples);
  assert.deepEqual(results.map(result => result.accepted), [true, true, true, false, false, false], results.map(result => result.diagnostics).join('\n'));
});
