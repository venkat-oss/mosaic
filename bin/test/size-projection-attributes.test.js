import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { cpSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { resolve } from 'node:path';
import { after, test } from 'node:test';
import { fileURLToPath } from 'node:url';

const ROOT = fileURLToPath(new URL('../..', import.meta.url));
const cue = process.env.CUE_BIN;
const workspaces = [];
function workspace(copy = false) {
  const root = mkdtempSync(resolve(tmpdir(), 'mosaic-size-projection-'));
  workspaces.push(root);
  if (copy) for (const path of ['cue.mod', 'api']) {
    cpSync(resolve(ROOT, path), resolve(root, path), { recursive: true, dereference: true, filter: () => true });
  }
  return root;
}
after(() => workspaces.forEach(root => rmSync(root, { recursive: true, force: true })));

const sizeCases = [
  ['rScale', ['log', null, 'ordinary-reference'], [3, false]],
  ['rDomain', [[1, {}], 'Fixed', 'ordinary-reference'], [null, {}]],
  ['rRange', [[2, 12], 'Fixed'], [false, {}]],
  ['rClamp', [false, null, {}, []], []],
  ['rNice', [true, 4, 'month', 'ordinary-reference'], [null, {}, []]],
  ['rLabel', ['Magnitude', null], [1, false]],
  ['rPercent', [false, '$percent'], [0, null]],
  ['rZero', [true, '$zero'], [[], 0]],
  ['rExponent', [0.5, '$exponent'], [false, {}]],
  ['rBase', [2, '$base'], [null, {}]],
  ['rConstant', [-1, '$constant'], [false, []]],
  ['lengthScale', ['linear', null], [4, {}]],
  ['lengthDomain', [[0, 4], 'Fixed'], [false, null]],
  ['lengthRange', [[0, 40], 'ordinary-reference'], [0, {}]],
  ['lengthClamp', [false, 3, {}, null], []],
  ['lengthNice', [false, 2, 'month'], [null, {}, []]],
  ['lengthPercent', [true, '$percent'], [null, []]],
  ['lengthZero', [false, '$zero'], [0, {}]],
  ['lengthExponent', [2, '$exponent'], [true, []]],
  ['lengthBase', [2, '$base'], [false, {}]],
  ['lengthConstant', [0, '$constant'], [null, false]]
];
const projectionCases = [
  ['projectionType', ['mercator', null, 'ordinary-reference'], [false, 3, {}]],
  ['projectionDomain', [{ type: 'Sphere' }, { arbitrary: true }, '$domain'], [null, [], 3]],
  ['projectionRotate', [[10, 20, 0], ['$x', 20, 'ordinary-reference'], '$rotation'], [[10, 20], [10, 20, 0, 0], [10, {}, 0]]],
  ['projectionParallels', [[29.5, 45.5], ['$first', '$second'], '$parallels'], [[1], [1, 2, 3], [1, false]]],
  ['projectionPrecision', [0, 0.2, '$precision'], [false, null]],
  ['projectionClip', [false, null, 120, 'frame', 'ordinary-reference'], [{}, []]],
  ['projectionInset', [-1, '$inset'], [false, null]],
  ['projectionInsetTop', [0, '$inset'], [[], {}]],
  ['projectionInsetRight', [10, '$inset'], [true, null]],
  ['projectionInsetBottom', [2.5, '$inset'], [[], false]],
  ['projectionInsetLeft', [4, '$inset'], [{}, null]]
];

for (const [family, definition, cases] of [['size', 'SizeAttributes', sizeCases], ['projection', 'ProjectionAttributes', projectionCases]]) {
  for (const [name, accepted, rejected] of cases) {
    test(`native ${family} ${name} preserves independent wire boundaries`, () => {
      const root = workspace();
      const candidate = resolve(root, 'candidate.json');
      const native = resolve(ROOT, `packages/vgplot/spec/src/generated/${family}-attributes.cue`);
      for (const [value, expected] of [...accepted.map(value => [value, 0]), ...rejected.map(value => [value, 1])]) {
        writeFileSync(candidate, JSON.stringify({ [name]: value }));
        const result = spawnSync(cue, ['vet', '-c', native, candidate, '-d', `#${definition}`], { encoding: 'utf8' });
        assert.equal(result.status, expected, `${name}: ${JSON.stringify(value)}\n${result.stderr}`);
        if (expected === 0) {
          const output = spawnSync(cue, ['export', native, candidate, '-d', `#${definition}`, '--out', 'json'], { encoding: 'utf8' });
          assert.equal(output.status, 0, output.stderr);
          assert.deepEqual(JSON.parse(output.stdout), { [name]: value });
        }
      }
      writeFileSync(candidate, JSON.stringify({ [name]: accepted[0], unknownAttribute: 1 }));
      assert.notEqual(spawnSync(cue, ['vet', '-c', native, candidate, '-d', `#${definition}`], { encoding: 'utf8' }).status, 0);
    });
  }
}

function edit(root, path, pattern, replacement) {
  const target = resolve(root, path);
  const source = readFileSync(target, 'utf8');
  assert.match(source, pattern);
  writeFileSync(target, source.replace(pattern, replacement));
}

for (const [name, family, path, pattern, replacement] of [
  ['the unrestricted clamp factory acquires a True default', 'size', 'model.cue', /(name:\s*"rClamp"[\s\S]*?default:\s*)"required"/, '$1"true"'],
]) {
  test(`owning ${family} admission rejects when ${name}`, () => {
    const root = workspace(true);
    edit(root, `api/attributes/${family}/${path}`, pattern, replacement);

    const result = spawnSync(cue, ['vet', '-c', `./api/attributes/${family}`], { cwd: root, encoding: 'utf8' });
    assert.notEqual(result.status, 0);
    assert.match(result.stderr, /conflicting values|out of bound|empty disjunction/);
  });
}
