import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import test from 'node:test';
import { fileURLToPath } from 'node:url';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { validateSpec } from './util/spec-admission.js';

const root = fileURLToPath(new URL('../..', import.meta.url));

test('the current schema and native root preserve recursive legend, mark and transform admission', () => {
  const schema = JSON.parse(readFileSync(resolve(root, 'packages/vgplot/spec/src/generated/mosaic-schema.json'), 'utf8'));
  const valid = { hconcat: [{ plot: [
    { mark: 'dot', data: { from: 'points' }, x: { avg: 'x' }, y: 'y' },
    { legend: 'color' }
  ] }] };
  const invalidLegend = structuredClone(valid);
  invalidLegend.hconcat[0].plot[1].legend = 'unknown';
  const invalidTuple = structuredClone(valid);
  invalidTuple.hconcat[0].plot[0].x = { avg: ['x', 'y'] };
  const invalidOption = structuredClone(valid);
  invalidOption.hconcat[0].plot[1].unknownOption = true;
  const cases = [valid, invalidLegend, invalidTuple, invalidOption];
  const ajv = new Ajv({ allErrors: true, allowUnionTypes: true, strict: false });
  addFormats.default(ajv);
  const expected = [true, false, false, false];
  assert.deepEqual(cases.map(ajv.compile(schema)), expected);
  assert.deepEqual(validateSpec(cases, { root }).map(result => result.accepted), expected);
});
