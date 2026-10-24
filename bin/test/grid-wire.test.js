import assert from 'node:assert/strict';
import { readFileSync, mkdtempSync, writeFileSync, rmSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import { tmpdir } from 'node:os';
import { resolve, join } from 'node:path';
import test from 'node:test';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { validateSpec } from './util/spec-admission.js';

const schema = JSON.parse(readFileSync(resolve('packages/vgplot/spec/dist/mosaic-schema.json'), 'utf8'));
const ajv = new Ajv({allowUnionTypes: true});
addFormats.default(ajv);
const validate = ajv.compile(schema);
const cases = [
  ['raster', {x: 'x', y: 'y', fill: 'density', width: 5, height: 5}, true],
  ['heatmap', {bandwidth: '$bandwidth', pixelSize: 2}, true],
  ['density', {type: 'text', fontSize: 12, r: 'density'}, true],
  ['density', {text: 'density'}, false],
  ['density', {type: '$base'}, true],
  ['density', {type: 'line'}, true],
  ['denseLine', {z: 'series', normalize: false}, true],
  ['denseLine', {normalize: 1}, false],
  ['contour', {thresholds: [0.1, 0.3]}, true],
  ['contour', {thresholds: 4}, true],
  ['contour', {thresholds: ['high']}, false],
  ['rasterTile', {origin: [0, 0]}, true],
  ['rasterTile', {origin: [0]}, false],
  ['rasterTile', {origin: [0, 0, 0]}, false],
  ['raster', {interpolate: null}, true],
  ['raster', {interpolate: 'arbitrary-reference'}, true],
  ['raster', {interpolate: {}}, false],
  ['raster', {width: 0, height: -1, pixelSize: 0, pad: 3}, true],
  ['raster', {weight: 'value'}, false],
  ['raster', {futureOption: 1}, false],
];
for (const mode of ['none', 'linear', 'nearest', 'barycentric', 'random-walk']) cases.push(['raster', {interpolate: mode}, true]);
for (const [mark, options, expected] of cases) test(mark + ' admission for ' + JSON.stringify(options), () => {
  assert.equal(validate({plot: [{mark, data: {from: 'records'}, ...options}]}), expected, JSON.stringify(validate.errors));
});
test('grid payloads agree with the native root', () => {
  assert.deepEqual(validateSpec(cases.map(([mark, options]) => ({plot: [{mark, data: {from: 'records'}, ...options}]}))).map(result => result.accepted), cases.map(([, , expected]) => expected));
});
test('standalone interpolation vocabulary retains its closed native contract', () => {
  const directory = mkdtempSync(join(tmpdir(), 'mosaic-grid-values-'));
  try {
    const input = join(directory, 'input.json');
    for (const value of ['none', 'linear', 'nearest', 'barycentric', 'random-walk', 'other', '$mode', null]) {
      writeFileSync(input, JSON.stringify(value));
      const result = spawnSync(process.env.CUE_BIN, ['vet', '-c', resolve('packages/vgplot/spec/src/generated/grid-values.cue'), input, '-d', '#GridInterpolate'], {encoding: 'utf8'});
      assert.equal(result.status === 0, typeof value === 'string' && !['other', '$mode'].includes(value), result.stderr);
    }
  } finally {
    rmSync(directory, {recursive: true, force: true});
  }
});
