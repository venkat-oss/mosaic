import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { cpSync, mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { resolve } from 'node:path';
import { after, test } from 'node:test';
import { fileURLToPath } from 'node:url';

const ROOT = fileURLToPath(new URL('../..', import.meta.url));
const cue = process.env.CUE_BIN;
const workspaces = [];
function workspace(copy = false) {
  const root = mkdtempSync(resolve(tmpdir(), 'mosaic-data-'));
  workspaces.push(root);
  if (copy) for (const path of ['cue.mod', 'api']) cpSync(resolve(ROOT, path), resolve(root, path), { recursive: true, dereference: true, filter: () => true });
  return root;
}
after(() => workspaces.forEach(root => rmSync(root, { recursive: true, force: true })));

for (const [name, accepted, rejected] of [
  ['DataBaseOptions', [{}, {select:[],where:['x=1'],view:false,temp:false,replace:false}], [{temp:null},{unknown:true}]],
  ['DataQuery', ['', 'SELECT 1'], [1, null]],
  ['DataArray', [[], [{}], [{ nested: [1, null] }]], [[1], [null]]],
  ['DataFile', [{ file: 'arbitrary' }, { file: 'rows.csv', select: [], temp: false }], [{}, { file: 3 }, { file: 'rows', unknown: true }]],
  ['DataTable', [{ type: 'table', query: '' }], [{ type: 'table' }, { query: 'SELECT 1' }]],
  ['DataCSV', [{ type: 'csv', file: 'f', sample_size: -1 }], [{file:'f'}, { type: 'csv', file: 'f', sample_size: 'all' }]],
  ['DataParquet', [{ type: 'parquet', file: 'f', where: ['x=1'] }], [{file:'f'}, { type: 'parquet', file: 'f', select: 'x' }]],
  ['DataSpatial', [{ type: 'spatial', file: 'f', layer: '' }], [{file:'f'}, { type: 'spatial', file: 'f', layer: 3 }]],
  ['DataJSON', [{ type: 'json', file: 'f' }], [{file:'f'}, { type: 'json', data: [] }, { type: 'json', file: 'f', data: [] }]],
  ['DataJSONObjects', [{ data: [] }, { type: 'json', data: [{}] }], [{ data: [1] }, { data: [], file: 'f' }]],
  ['DataDefinition', ['SELECT 1', [], {file:'arbitrary'}, {type:'table',query:''}, {type:'parquet',file:'f'}, {type:'csv',file:'f'}, {type:'spatial',file:'f'}, {type:'json',file:'f'}, {data:[{}]}], [null,3,{type:'unknown',file:'f'},{data:[1]}]],
  ['PlotMarkData', [[null,1],{from:'rows'}], [null,{from:3},{from:'rows',unnest:['items']}]],
  ['PlotDataInline', [[null, 1, 'x', {}]], [{}]],
  ['PlotFrom', [{ from: 'rows' }, { from: '$table', filterBy: 'plain-wire-reference', optimize: false }], [{ from: 3 }, { from: 'rows', unnest: ['items'] }]]
]) {
  test(`native #${name} preserves independent data and source boundaries`, () => {
    const root = workspace();
    const candidate = resolve(root, 'candidate.json');
    for (const [value, expected] of [...accepted.map(value => [value, 0]), ...rejected.map(value => [value, 1])]) {
      writeFileSync(candidate, JSON.stringify(value));
      const result = spawnSync(cue, ['vet', '-c', resolve(ROOT, 'packages/vgplot/spec/src/generated/data.cue'), candidate, '-d', `#${name}`], { cwd: ROOT, encoding: 'utf8' });
      assert.equal(result.error, undefined);
      assert.equal(result.status, expected, `${name}: ${JSON.stringify(value)}\n${result.stderr}`);
    }
  });
}

for (const [name, declaration] of [
  ['raw Python annotation expressions', 'unused: #PythonParameter & {name:"file",annotation:"eval(unsafe)",kind:"positional-or-keyword"}'],
]) {
  test(`owning data admission rejects ${name}`, () => {
    const root = workspace(true);
    writeFileSync(resolve(root, 'api/data/invalid.cue'), `package data\n${declaration}\n`);

    const result = spawnSync(cue, ['vet', '-c', './api/data'], { cwd: root, encoding: 'utf8' });
    assert.equal(result.error, undefined);
    assert.equal(result.status, 1, result.stderr);
    assert.match(result.stderr, /annotation|targets|conflicting values|empty disjunction/);
  });
}

test('DataDefinition native file preference preserves every applicable branch and exports unchanged values', () => {
  const accepted = [
    { file: 'arbitrary' }, { file: 'rows.csv', select: ['x'], temp: false },
    { data: [{ x: 1 }] }, { data: [] },
    { type: 'table', query: 'SELECT 1' }, { type: 'parquet', file: 'f' },
    { type: 'csv', file: 'f' }, { type: 'spatial', file: 'f' },
    { type: 'json', file: 'f' }, { type: 'json', data: [{}] },
    'SELECT 1', [], [{ x: 1 }]
  ];
  const rejected = [
    {}, { temp: false }, { query: 'SELECT 1' }, { select: ['x'], view: true },
    { type: 'table' }, { type: 'parquet' }, { type: 'csv' }, { type: 'json' }, { type: 'spatial' },
    { file: 'f', unknown: true }, { type: 'unknown', file: 'f' },
    { data: [1] }, { file: 'f', data: [] }, null, 3
  ];
  const root = workspace();
  const candidate = resolve(root, 'candidate.json');
  const args = [resolve(ROOT, 'packages/vgplot/spec/src/generated/data.cue'), candidate, '-d', '#DataDefinition'];
  for (const value of accepted) {
    writeFileSync(candidate, JSON.stringify(value));
    const exported = spawnSync(cue, ['export', ...args], { cwd: ROOT, encoding: 'utf8' });
    assert.equal(exported.error, undefined);
    assert.equal(exported.status, 0, `${JSON.stringify(value)}\n${exported.stderr}`);
    assert.deepEqual(JSON.parse(exported.stdout), value);
  }
  for (const value of rejected) {
    writeFileSync(candidate, JSON.stringify(value));
    const checked = spawnSync(cue, ['vet', '-c', ...args], { cwd: ROOT, encoding: 'utf8' });
    assert.equal(checked.status, 1, JSON.stringify(value));
  }
});
