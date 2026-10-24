import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import test from 'node:test';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { validateSpec } from './util/spec-admission.js';

const schema = JSON.parse(readFileSync('packages/vgplot/spec/dist/mosaic-schema.json', 'utf8'));
const ajv = new Ajv({ allowUnionTypes: true, inlineRefs: false });
addFormats.default(ajv);
const validate = ajv.compile(schema);

const cases = [
  ['empty plot', { plot: [] }, true],
  ['absolute schema URI', { $schema: 'https://example.com/schema.json', plot: [] }, true],
  ['URN schema URI', { $schema: 'urn:foo:bar', plot: [] }, true],
  ['invalid schema URI', { $schema: 'not a uri', plot: [] }, false],
  ['open metadata and configuration', { plot: [], meta: { title: 'Dashboard', custom: { x: 1 } }, config: { extensions: ['spatial'], custom: 3 } }, true],
  ['metadata known field type', { plot: [], meta: { title: 4 } }, false],
  ['configuration extension type', { plot: [], config: { extensions: 4 } }, false],
  ['plot defaults', { plot: [], plotDefaults: { width: 320, colorScheme: 'blues' } }, true],
  ['unknown default', { plot: [], plotDefaults: { futureWidth: 320 } }, false],
  ['repeated recursive layout', { hconcat: [{ vconcat: [{ plot: [] }, { hspace: '1em' }] }, { vconcat: [{ plot: [] }, { hspace: '1em' }] }] }, true],
  ['closed nested component', { hconcat: [{ plot: [], futureView: 1 }] }, false],
  ['closed root', { plot: [], futureView: 1 }, false],
  ['missing component', {}, false],
  ['mixed components', { hconcat: [], vconcat: [] }, false],
  ['standalone legend', { legend: 'color', for: 'main' }, true],
  ['standalone legend required target', { legend: 'color' }, false],
  ['standalone mark is not a root component', { mark: 'dot', data: {} }, false],
  ['top-level mark requires data', { mark: 'dot' }, false],
  ['top-level mark root data is not inline plot data', { mark: 'dot', data: [] }, false],
];

test('native root preserves recursive composition, head merging, and closed boundaries', () => {
  for (const [name, value, expected] of cases) {
    assert.equal(validate(value), expected, name + ': ' + JSON.stringify(validate.errors));
  }
  const native = validateSpec(cases.map(([, value]) => value));
  for (const [index, [name, , expected]] of cases.entries()) {
    assert.equal(native[index].accepted, expected, name + ': ' + native[index].diagnostics);
  }
});

test('native admission preserves omitted keys during export', () => {
  const directory = mkdtempSync(join(tmpdir(), 'mosaic-root-native-export-'));
  try {
    const candidate = join(directory, 'candidate.json');
    const value = { plot: [{ mark: 'densityY', data: { from: 'records' } }] };
    writeFileSync(candidate, JSON.stringify(value));
    const output = execFileSync(process.env.CUE_BIN, [
      'export', resolve('packages/vgplot/spec/src/generated/spec.cue'), candidate, '-d', '#Spec'
    ], { encoding: 'utf8' });
    assert.deepEqual(JSON.parse(output), value);
  } finally {
    rmSync(directory, { recursive: true, force: true });
  }
});
