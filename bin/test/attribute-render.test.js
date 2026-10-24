import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { cpSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { resolve } from 'node:path';
import { after, test } from 'node:test';
import { fileURLToPath } from 'node:url';

const ROOT = fileURLToPath(new URL('../..', import.meta.url));
const cue = process.env.CUE_BIN;
const original = readFileSync(new URL('./fixtures/attribute-family.cue', import.meta.url), 'utf8');
const roots = [];

function workspace() {
  const root = mkdtempSync(resolve(tmpdir(), 'mosaic-attribute-render-'));
  roots.push(root);
  for (const name of ['cue.mod', 'api']) cpSync(resolve(ROOT, name), resolve(root, name), { recursive: true, dereference: true, filter: () => true });
  return root;
}

function run(root, args) {
  const result = spawnSync(cue, args, { cwd: root, encoding: 'utf8' });
  assert.equal(result.error, undefined);
  return result;
}

function edit(source, before, after) {
  assert.equal(source.split(before).length - 1, 1, before);
  return source.replace(before, after);
}

after(() => roots.forEach(root => rmSync(root, { recursive: true, force: true })));

test('attribute family projection preserves actual native dependency closure and Python defaults', () => {
  const root = workspace();
  const file = resolve(root, 'candidate.cue');
  writeFileSync(file, original);
  let result = run(root, ['vet', '-c', file]);
  assert.equal(result.status, 0, result.stderr);
  result = run(root, ['export', file, '-e', 'candidate']);
  assert.equal(result.status, 0, result.stderr);
  const projection = JSON.parse(result.stdout);
  for (const name of ['Interval', 'LiteralTimeInterval', 'TimeIntervalName']) assert.match(projection.nativeSource, new RegExp(`#${name}:`));
  const python = projection.files['packages/vgplot/vgplot-python/vgplot/_generated/size_attributes.py'];
  assert.match(python, /def a_nice\(value: AttrValue = True\)/);
  assert.match(python, /def b_nice\(value: AttrValue\)/);
  writeFileSync(resolve(root, 'contracts.cue'), projection.nativeSource);
  writeFileSync(resolve(root, 'payload.json'), JSON.stringify({ aNice: 'day', bNice: 2 }));
  result = run(root, ['vet', '-c', 'contracts.cue', 'payload.json', '-d', '#TestAttributes']);
  assert.equal(result.status, 0, result.stderr);
});

for (const [name, mutate] of [
  ['duplicate route orders', source => edit(source, 'path: "b.nice", order: 1', 'path: "b.nice", order: 0')],
  ['duplicate route paths', source => edit(source, 'path: "b.nice"', 'path: "a.nice"')],
  ['missing native external reference', source => edit(source, 'ParamRef: paramFamily.nativeDefinitions.ParamRef', 'UnusedNative: paramFamily.nativeDefinitions.ParamRef')],
  ['missing helper property', source => edit(source, '{name: "bNice", description: "B sample attribute.", required: false, type: "niceValue"},', '')],
  ['wrong helper property type', source => edit(source, 'description: "B sample attribute.", required: false, type: "niceValue"', 'description: "B sample attribute.", required: false, type: "numberValue"')],
  ['required helper property', source => edit(source, 'description: "B sample attribute.", required: false', 'description: "B sample attribute.", required: true')],
  ['duplicate document coverage', source => edit(source, 'attributes: ["aNice", "bNice"]', 'attributes: ["aNice", "aNice"]')],
  ['unknown document attribute', source => edit(source, 'attributes: ["aNice", "bNice"]', 'attributes: ["aNice", "unknown"]')],
  ['alias mismatch', source => edit(source, 'aliasSections: [{name: "ValueAlias"', 'aliasSections: [{name: "TestAttributes"')],
  ['unknown paired target', source => edit(edit(source, 'jsKind: "simple", python: {name: "b_nice"', 'jsKind:"paired",targets:["aNice","unknown"],python:{name:"b_nice"'), 'route: {kind: "mapped", path: "b.nice", order: 1}', 'route:{kind:"wrapper-only"}')],
  ['duplicate paired targets', source => edit(edit(source, 'jsKind: "simple", python: {name: "b_nice"', 'jsKind:"paired",targets:["aNice","aNice"],python:{name:"b_nice"'), 'route: {kind: "mapped", path: "b.nice", order: 1}', 'route:{kind:"wrapper-only"}')]
]) {
  test(`attribute family rejects ${name} despite an empty selected file map`, () => {
    const root = workspace();
    const file = resolve(root, 'candidate.cue');
    writeFileSync(file, mutate(original));
    const result = run(root, ['vet', '-c', file]);
    assert.notEqual(result.status, 0);
    assert.match(result.stderr, /api\/attributes\/(?:render\/family|model)\.cue/);
  });
}

for (const [name, expressions] of [
  ['non-literal members', 'bad:{kind:"union",schemaAdapter:"literal-enum",members:["numberValue","ParamRef"]}'],
  ['duplicate literal members', 'a:{kind:"literal",value:"auto"}, b:{kind:"literal",value:"auto"}, bad:{kind:"union",schemaAdapter:"literal-enum",members:["a","b"]}']
]) {
  test(`the mixed literal enum adapter rejects ${name} even when unused`, () => {
    const root = workspace();
    const file = resolve(root, 'candidate.cue');
    writeFileSync(file, `${original}\ncandidate: typeExpressions: {${expressions}}\n`);
    const result = run(root, ['vet', '-c', file]);
    assert.notEqual(result.status, 0);
    assert.match(result.stderr, /api\/render\/shapes\.cue/);
  });
}


test('Python first-sentence prose preserves link and numeric-footnote normalization', () => {
  const root = workspace();
  const file = resolve(root, 'prose.cue');
  const cases = [
    ['Draw [points](https://example.com/points). More details.', 'Draw points.'],
    ['Use [named](https://example.com) [reference][id] [shortcut] [12] values.', 'Use named reference shortcut values.'],
    ['Ticks [1]\n\n[1]: https://example.com/ticks', 'Ticks : https://example.com/ticks'],
    ['A sentence without a full stop', 'A sentence without a full stop']
  ];
  writeFileSync(file, `package prose\nimport attributeRender "idl.uw.edu/mosaic/api/attributes/render:attributerender"\ncases: ${JSON.stringify(cases.map(([description]) => description))}\nresults: [for Description in cases {(attributeRender.#PythonDescription & {description:Description}).text}]\n`);
  const result = run(root, ['export', file, '-e', 'results']);
  assert.equal(result.status, 0, result.stderr);
  assert.deepEqual(JSON.parse(result.stdout), cases.map(([, expected]) => expected));
});
