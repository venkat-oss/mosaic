import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import test from 'node:test';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { validateSpec } from './util/spec-admission.js';

const root = resolve(import.meta.dirname, '../..');
const schema = JSON.parse(readFileSync(root + '/packages/vgplot/spec/dist/mosaic-schema.json', 'utf8'));
const ajv = new Ajv({ allowUnionTypes: true });
addFormats.default(ajv);
const validate = ajv.compile(schema);
const checks = [];
for (const mark of ['area', 'areaX', 'areaY', 'line', 'lineX', 'lineY', 'arrow', 'link']) {
  checks.push([mark + ' requires declared data', { plot: [{ mark }] }, false]);
  checks.push([mark + ' accepts inline data', { plot: [{ mark, data: [] }] }, true]);
  checks.push([mark + ' accepts parameter data', { plot: [{ mark, data: { from: '$source' } }] }, true]);
  checks.push([mark + ' rejects malformed data', { plot: [{ mark, data: 42 }] }, false]);
}
for (const [name, mark, options, accepted] of [
  ['wire retains auto area curves', 'area', { curve: 'auto' }, true],
  ['area wire retains unrestricted string references', 'area', { curve: 'unknown' }, true],
  ['line accepts nullable coordinate', 'line', { y: null }, true],
  ['line rejects unknown channel object', 'line', { y: { arbitrary: true } }, false],
  ['arrow accepts boolean bend', 'arrow', { bend: true }, true],
  ['arrow rejects object bend', 'arrow', { bend: {} }, false],
  ['arrow accepts directional sweep despite retained SQL limitation', 'arrow', { sweep: '+y' }, true],
  ['arrow wire retains unrestricted string references', 'arrow', { sweep: 'up' }, true],
  ['arrow accepts referenced head length', 'arrow', { headLength: '$length' }, true],
  ['arrow rejects false head length', 'arrow', { headLength: false }, false],
  ['link indexed curve accepts auto', 'link', { curve: 'auto' }, true],
  ['link indexed curve accepts a parameter', 'link', { curve: '$curve' }, true],
  ['link indexed curve retains unrestricted string references', 'link', { curve: 'unknown' }, true],
  ['wire rejects unknown mark options', 'areaX', { futureOption: true }, false]
]) checks.push([name, { plot: [{ mark, data: [], ...options }] }, accepted]);

test('connected wire boundaries agree with AJV and the native root', () => {
  assert.deepEqual(checks.map(([name, value]) => [name, validate(value)]), checks.map(([name, , expected]) => [name, expected]));
  const native = validateSpec(checks.map(([, value]) => value));
  for (let i = 0; i < checks.length; i++) {
    const [name, value, expected] = checks[i];
    assert.equal(validate(value), expected, name + ': ' + JSON.stringify(validate.errors).slice(0, 1200));
    assert.equal(native[i].accepted, expected, name + ': ' + native[i].diagnostics);
  }
});
