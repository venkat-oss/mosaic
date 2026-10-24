import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';

function admit(contributions) {
  const directory = mkdtempSync(join(tmpdir(), 'mosaic-public-composition-'));
  try {
    const input = join(directory, 'input.json');
    writeFileSync(input, JSON.stringify({contributions, interactors: []}));
    return spawnSync(process.env.CUE_BIN, ['vet', '-c', './api/compose', input, '-d', '#PublicComposition'], {encoding: 'utf8'});
  } finally {
    rmSync(directory, {recursive: true, force: true});
  }
}

test('public composition admits extensions and rejects conflicting or malformed metadata', () => {
  const valid = admit([{python: [{name: 'sample', module: 'plot'}], inputNames: ['sample']}]);
  assert.equal(valid.status, 0, valid.stderr);
  for (const contributions of [
    [{python: [{name: 'plot', module: 'plot'}]}],
    [{python: [{name: 'sample', module: 'data'}]}, {python: [{name: 'sample', module: 'plot'}]}],
    [{inputNames: ['sample', 'sample']}],
    [{javascript: [{group: 'column', source: '@uwdata/mosaic-sql', name: 'Query'}]}],
    [{constantExports: [{source: './generated/params.js', names: [{name: 'execute()'}]}]}],
    [{javascript: [{group: 'unknown', source: './unknown.js', name: 'unknown'}]}],
  ]) {
    const result = admit(contributions);
    assert.equal(result.status, 1, JSON.stringify(contributions) + result.stderr);
  }
});
