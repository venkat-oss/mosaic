import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { cpSync, mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { resolve } from 'node:path';
import test from 'node:test';

const root = resolve(import.meta.dirname, '../..');
const cue = process.env.CUE_BIN;
const families = [
  ['common', 'common', 'commonmodel'],
  ['basic', 'basicmarks', 'basicmodel'],
  ['connected', 'connected', 'connectedmodel'],
  ['annotation', 'annotation', 'annotationmodel']
];

function fixture(run) {
  const directory = mkdtempSync(resolve(tmpdir(), 'mosaic-mark-models-'));
  try {
    for (const path of ['cue.mod', 'api']) {
      cpSync(resolve(root, path), resolve(directory, path), { recursive: true, dereference: true, filter: () => true });
    }
    run(directory);
  } finally {
    rmSync(directory, { recursive: true, force: true });
  }
}

test('canonical mark models load independently of their producer packages', () => fixture(directory => {
  for (const [family, producer] of families) {
    writeFileSync(resolve(directory, `api/marks/${family}/invalid.cue`),
      `package ${producer}\nbroken: _|_("producer must not load")\n`);
  }
  const imports = families.map(([family, , canonical]) =>
    `${canonical} "idl.uw.edu/mosaic/api/marks/${family}/model:${canonical}"`).join('\n');
  const values = families.map(([family, , canonical]) => `${family}:len(${canonical}.contracts)`).join('\n');
  writeFileSync(resolve(directory, 'probe.cue'), `package probe\nimport (\n${imports}\n)\n${values}\n`);
  const result = spawnSync(cue, ['export', './probe.cue'], { cwd: directory, encoding: 'utf8' });
  assert.equal(result.status, 0, result.stderr);
  const counts = JSON.parse(result.stdout);
  for (const [family] of families) assert.ok(counts[family] > 0);
}));

for (const [family, , canonical] of families) {
  test(`${family} canonical model rejects an unused malformed expression`, () => fixture(directory => {
    writeFileSync(resolve(directory, `api/marks/${family}/model/invalid.cue`),
      `package ${canonical}\ntypeExpressions: unused: {kind:"reference",name:"ChannelName"}\n`);
    const result = spawnSync(cue, ['vet', '-c', `./api/marks/${family}/model`], {
      cwd: directory, encoding: 'utf8'
    });
    assert.equal(result.status, 1, result.stderr);
    assert.match(result.stderr, /typeExpressions\.unused\.expression/);
  }));

  test(`${family} producer rejects an unused incomplete canonical record`, () => fixture(directory => {
    writeFileSync(resolve(directory, `api/marks/${family}/model/invalid.cue`),
      `package ${canonical}\nunused: {description!: string}\n`);
    const result = spawnSync(cue, ['vet', '-c', `./api/marks/${family}`], {
      cwd: directory, encoding: 'utf8'
    });
    assert.equal(result.status, 1, result.stderr);
    assert.match(result.stderr, /modelAdmission\.unused\.description/);
  }));
}
