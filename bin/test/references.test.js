import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';

function reference(sections) {
  const directory = mkdtempSync(join(tmpdir(), 'mosaic-reference-'));
  try {
    const input = join(directory, 'input.json');
    writeFileSync(input, JSON.stringify({ sections }));
    const args = ['./api/compose', input, '-d', '#TransformReference'];
    const cue = process.env.CUE_BIN;
    execFileSync(cue, ['vet', '-c', ...args], { stdio: 'pipe' });
    return JSON.parse(execFileSync(cue, ['export', ...args, '-e', 'files'], { stdio: 'pipe', encoding: 'utf8' }));
  } finally {
    rmSync(directory, { recursive: true, force: true });
  }
}

test('one composer orders transform reference contributions independently of arrival', () => {
  const files = reference([
    { id: 'window', order: 6, content: '## Windows\n\nWindow descriptions.' },
    { id: 'column', order: 4, content: '## Columns\n\nColumn descriptions.' },
    { id: 'aggregate', order: 5, content: '## Aggregates\n\nAggregate descriptions.' }
  ]);
  assert.deepEqual(Object.keys(files), ['docs/api/spec/transforms.md']);
  const text = files['docs/api/spec/transforms.md'];
  assert.ok(text.indexOf('## Columns') < text.indexOf('## Aggregates'));
  assert.ok(text.indexOf('## Aggregates') < text.indexOf('## Windows'));
  assert.deepEqual(reference([]), {});
});

test('reference composition rejects duplicate ownership and incomplete source prose', () => {
  const section = { id: 'column', order: 4, content: '## Columns' };
  for (const sections of [
    [section, section],
    [section, { ...section, id: 'aggregate' }],
    [section, { ...section, order: 5 }],
    [{ ...section, content: '' }],
    [{ id: 'column', order: 4 }],
    [{ ...section, source: 'arbitrary source' }]
  ]) assert.throws(() => reference(sections));
});
