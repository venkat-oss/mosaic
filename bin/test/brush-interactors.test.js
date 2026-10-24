import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import test from 'node:test';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';

const root = resolve(import.meta.dirname, '../..');
const cue = process.env.CUE_BIN;
const directory = mkdtempSync(join(tmpdir(), 'mosaic-brush-'));
const schema = JSON.parse(readFileSync(resolve(root, 'packages/vgplot/spec/src/generated/mosaic-schema.json')));
const ajv = new Ajv({ allowUnionTypes: true });
addFormats.default(ajv);
const cases = [
  ['IntervalX', { select: 'intervalX', as: '$selection', field: 'time', pixelSize: 8, brush: { fillOpacity: 0.4 } }],
  ['IntervalY', { select: 'intervalY', as: '$selection', peers: false }],
  ['IntervalXY', { select: 'intervalXY', as: '$selection', xfield: 'a', yfield: 'b' }],
  ['Region', { select: 'region', as: '$selection', channels: ['x', 'z'] }],
  ['BrushStyles', { opacity: 0, fillOpacity: 0.2, strokeOpacity: 1, fill: 'none', stroke: 'navy', strokeDasharray: '2,3' }]
];
for (const [name, value] of cases)
  test(name + ' keeps its native and wire value boundaries', () => {
    const validate = ajv.compile({ $ref: '#/definitions/' + name, definitions: schema.definitions });
    const candidate = join(directory, name + '.json');
    writeFileSync(candidate, JSON.stringify(value));
    execFileSync(cue, ['vet', '-c', resolve(root, 'packages/vgplot/spec/src/generated/brush-interactors.cue'), candidate, '-d', '#' + name], { cwd: root, stdio: 'pipe' });
    assert.equal(validate(value), true, JSON.stringify(validate.errors));
    const invalid = { ...value, unknown: true };
    assert.equal(validate(invalid), false);
    writeFileSync(candidate, JSON.stringify(invalid));
    assert.throws(() => execFileSync(cue, ['vet', '-c', resolve(root, 'packages/vgplot/spec/src/generated/brush-interactors.cue'), candidate, '-d', '#' + name], { cwd: root, stdio: 'pipe' }));
  });
for (const record of [
  'r.#PythonOptionHelper & {name:"brush",policy:"omit-none"}',
  'r.#PythonOptionHelper & {name:"sort",policy:"camelize-omit-none"}',
  'r.#Interactor & {contract:"IntervalX",wrapperSlot:"slot",group:"interval",javascript:{runtimeClass:"Interval1D",profile:"selection",forced:{channel:"z"}},python:{arguments:[],extras:false}}',
  'r.#Interactor & {contract:"Region",wrapperSlot:"slot",group:"region",javascript:{runtimeClass:"Region",profile:"highlight"},python:{arguments:[],extras:false}}'
])
  test('unused malformed interactor policy rejects ' + record.split(' & ')[0], () => {
    const candidate = join(directory, 'invalid.cue');
    writeFileSync(candidate, 'package policies\nimport r "idl.uw.edu/mosaic/api/interactors/render:interactorrender"\nunused: ' + record + '\n');
    assert.throws(() => execFileSync(cue, ['vet', '-c', candidate], { cwd: root, stdio: 'pipe' }));
  });
test('generated declarations preserve public interval and region option types', () => {
  const path = join(directory, 'consumer.mts');
  const base = resolve(root, 'packages/vgplot/spec/src/spec/interactors');
  const source = 'import type {IntervalX} from ' + JSON.stringify(base + '/Interval1D.js') + ';\n' +
    'import type {IntervalXY} from ' + JSON.stringify(base + '/Interval2D.js') + ';\n' +
    'import type {Region} from ' + JSON.stringify(base + '/Region.js') + ';\n';
  writeFileSync(path, source + 'const x: IntervalX = {select:"intervalX",as:"$s",pixelSize:8,brush:{strokeDasharray:"2,3"}};\nconst xy: IntervalXY = {select:"intervalXY",as:"$s",xfield:"x",yfield:"y"};\nconst region: Region = {select:"region",as:"$s",channels:["x"]};\n');
  const args = ['--ignoreConfig', '--noEmit', '--skipLibCheck', '--module', 'nodenext', '--moduleResolution', 'nodenext', '--target', 'es2022', path];
  execFileSync(process.env.TSC_BIN, args, { cwd: root, stdio: 'pipe' });
  writeFileSync(path, source + 'const invalid: IntervalX = {select:"intervalY",as:"$s",pixelSize:"8"};\n');
  assert.throws(() => execFileSync(process.env.TSC_BIN, args, { cwd: root, stdio: 'pipe' }));
});
test.after(() => rmSync(directory, { recursive: true, force: true }));
