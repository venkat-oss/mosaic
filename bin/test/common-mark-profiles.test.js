import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';

const cue = process.env.CUE_BIN;
function admit(source) {
  const directory = mkdtempSync(join(tmpdir(), 'mosaic-mark-profile-'));
  try {
    const input = join(directory, 'unused.cue');
    writeFileSync(input, source);
    execFileSync(cue, ['vet', '-c', input], { stdio: 'pipe' });
  } finally {
    rmSync(directory, { recursive: true, force: true });
  }
}
const profile = 'package probe\nimport p "idl.uw.edu/mosaic/api/marks/profile"\nfiles:{}\n';

test('unused Python factories preserve each helper ABI at the definition boundary', () => {
  admit(profile + 'unused:p.#PythonFactory & {name:"directive",description:"Create a directive."}');
  for (const value of [
    '{name:"directive",description:"X",module:"vgplot.encodings"}',
    '{name:"directive",description:"X",returns:"Mark"}',
    '{name:"channels",description:"X",operation:"directive"}',
    '{name:"mark",description:"X",parameters:[{name:"data"}]}',
    '{name:"channels",description:"X",parameters:[{name:"kwargs",kind:"positional-or-keyword"}]}',
    '{name:"channels",description:"X",parameters:[{name:"kwargs",annotation:"exec()"}]}',
    '{name:"mark",description:"X",parameters:[{}, {default:"UNSET"},{}]}',
    '{name:"directive",description:"X",unknown:true}',
    '{name:"channels",description:""}',
  ]) assert.throws(() => admit(profile + 'unused:p.#PythonFactory & ' + value));
});

test('owned mark profiles may preserve only the historical public pickle module', () => {
  const marks='marks:[{key:"dot",name:"dot",description:"Draw points.",channels:["x"]}]';
  admit(profile + 'unused:p.#PythonMarks & {'+marks+',publicModule:"vgplot._generated.marks"}');
  assert.throws(() => admit(profile + 'unused:p.#PythonMarks & {'+marks+',publicModule:"vgplot.plot"}'));
});
