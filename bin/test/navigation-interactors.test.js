import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { readFileSync, mkdtempSync, cpSync, writeFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import test from 'node:test';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { validateSpec } from './util/spec-admission.js';

const schema = JSON.parse(readFileSync(resolve('packages/vgplot/spec/src/generated/mosaic-schema.json'), 'utf8'));
const ajv = new Ajv({allowUnionTypes: true});
addFormats.default(ajv);
const validate = ajv.compile(schema);
const names = ['pan', 'panX', 'panY', 'panZoom', 'panZoomX', 'panZoomY'];
const cases = names.flatMap(select => [
  [{select}, true],
  [{select, x: '$x', y: '$y', xfield: 'a', yfield: 'b'}, true],
  [{select, x: 'plain-reference'}, true],
  [{select, x: null}, false],
  [{select, x: 1}, false],
  [{select, xfield: 1}, false],
  [{select, zoom: [1, 2]}, false],
  [{select, panx: false}, false],
  [{select, as: '$selection'}, false],
]);
for (const [directive, expected] of cases) test(JSON.stringify(directive) + ' retains wire admission', () => {
  assert.equal(validate({plot: [directive]}), expected, JSON.stringify(validate.errors));
});

test('navigation wire values agree with the native root', () => {
  assert.deepEqual(validateSpec(cases.map(([directive]) => ({plot: [directive]}))).map(result => result.accepted), cases.map(([, expected]) => expected));
});

test('navigation rejects unsupported contracts and adapters at its owning boundary', () => {
  const directory = mkdtempSync(join(tmpdir(), 'mosaic-navigation-'));
  try {
    cpSync(resolve('api'), join(directory, 'api'), {recursive: true, dereference: true, filter: () => true});
    cpSync(resolve('cue.mod'), join(directory, 'cue.mod'), {recursive: true, dereference: true, filter: () => true});
    for (const source of [
      'invalid: interactorRender.#Interactor & {contract:"Pan",wrapperSlot:"x",group:"navigation",javascript:{runtimeClass:"PanZoom",profile:"selection"},python:{arguments:[],extras:false}}',
      'invalid: interactorRender.#Interactor & {contract:"Pan",wrapperSlot:"x",group:"navigation",javascript:{runtimeClass:"PanZoom",profile:"navigation",forced:pointer:"x"},python:{arguments:[],extras:false}}',
    ]) {
      writeFileSync(join(directory, 'api/interactors/navigation/invalid.cue'), 'package navigationinteractors\n' + (source.includes('interactorRender.') ? 'import interactorRender "idl.uw.edu/mosaic/api/interactors/render:interactorrender"\n' : '') + source + '\n');
      const result = spawnSync(process.env.CUE_BIN, ['vet', '-c', './api/interactors/navigation'], {cwd: directory, encoding: 'utf8'});
      assert.equal(result.status, 1, result.stderr);
    }
  } finally {
    rmSync(directory, {recursive: true, force: true});
  }
});
