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
const directory = mkdtempSync(join(tmpdir(), 'mosaic-point-'));
const schema = JSON.parse(readFileSync(resolve(root, 'packages/vgplot/spec/src/generated/mosaic-schema.json')));
const ajv = new Ajv({ allowUnionTypes: true });
addFormats.default(ajv);
const cases = [
  ['Toggle', { select: 'toggle', as: '$selection', channels: ['x', 'z'] }],
  ...['X', 'Y', 'Z', 'Color'].map(suffix => ['Toggle' + suffix, { select: 'toggle' + suffix, as: '$selection', peers: false }]),
  ...['', 'X', 'Y'].map(suffix => ['Nearest' + suffix, { select: 'nearest' + suffix, as: '$selection', fields: ['x'], channels: ['x'], maxRadius: 18 }]),
  ['Highlight', { select: 'highlight', by: '$selection', opacity: 0.15, fillOpacity: 0.4, stroke: 'black' }]
];
for (const [name, value] of cases)
  test(name + ' keeps its native and wire value boundaries', () => {
    const validate = ajv.compile({ $ref: '#/definitions/' + name, definitions: schema.definitions });
    const candidate = join(directory, name + '.json');
    writeFileSync(candidate, JSON.stringify(value));
    execFileSync(cue, ['vet', '-c', resolve(root, 'packages/vgplot/spec/src/generated/point-interactors.cue'), candidate, '-d', '#' + name], { cwd: root, stdio: 'pipe' });
    assert.equal(validate(value), true, JSON.stringify(validate.errors));
    const invalid = { ...value, unknown: true };
    assert.equal(validate(invalid), false);
    writeFileSync(candidate, JSON.stringify(invalid));
    assert.throws(() => execFileSync(cue, ['vet', '-c', resolve(root, 'packages/vgplot/spec/src/generated/point-interactors.cue'), candidate, '-d', '#' + name], { cwd: root, stdio: 'pipe' }));
  });
for (const record of [
  'r.#PythonArgument & {wire:"as",name:"as"}',
  'r.#PythonArgument & {adapter:"singular-field",wire:"field",name:"field"}',
  'r.#Interactor & {contract:"Nearest",wrapperSlot:"slot",group:"nearest",javascript:{runtimeClass:"Nearest",profile:"selection",forced:{pointer:"z"}},python:{arguments:[],extras:false}}',
  'r.#Interactor & {contract:"Nearest",wrapperSlot:"slot",group:"nearest",javascript:{runtimeClass:"Nearest",profile:"highlight"},python:{arguments:[],extras:false}}'
])
  test('unused malformed point interactor policy rejects ' + record.split(' & ')[0], () => {
    const candidate = join(directory, 'invalid.cue');
    writeFileSync(candidate, 'package policies\nimport r "idl.uw.edu/mosaic/api/interactors/render:interactorrender"\nunused: ' + record + '\n');
    assert.throws(() => execFileSync(cue, ['vet', '-c', candidate], { cwd: root, stdio: 'pipe' }));
  });
test('generated point declarations preserve native fields while excluding the historical Python singular alias', () => {
  const path = join(directory, 'consumer.mts');
  const base = resolve(root, 'packages/vgplot/spec/src/spec/interactors');
  const imports = 'import type {NearestX} from ' + JSON.stringify(base + '/Nearest.js') + ';\nimport type {Toggle} from ' + JSON.stringify(base + '/Toggle.js') + ';\nimport type {Highlight} from ' + JSON.stringify(base + '/Highlight.js') + ';\n';
  const args = ['--ignoreConfig', '--noEmit', '--skipLibCheck', '--module', 'nodenext', '--moduleResolution', 'nodenext', '--target', 'es2022', path];
  writeFileSync(path, imports + 'const nearest:NearestX={select:"nearestX",as:"$s",fields:["x"],channels:["x"],maxRadius:18};\nconst toggle:Toggle={select:"toggle",as:"$s",channels:["x","z"]};\nconst highlight:Highlight={select:"highlight",by:"$s",opacity:0.2};\n');
  execFileSync(process.env.TSC_BIN, args, { cwd: root, stdio: 'pipe' });
  writeFileSync(path, imports + 'const wrong:NearestX={select:"nearestX",as:"$s",field:"x"};\n');
  assert.throws(() => execFileSync(process.env.TSC_BIN, args, { cwd: root, stdio: 'pipe' }));
});
test.after(() => rmSync(directory, { recursive: true, force: true }));
