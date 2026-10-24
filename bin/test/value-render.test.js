import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';
import { runInNewContext } from 'node:vm';

const cue = process.env.CUE_BIN;
const named = expression => ({ name: 'Example', description: 'Independent example.', exported: true, file: 'PlotTypes.ts', ...expression });

function project(contract, index = {}, expression = 'schema') {
  const directory = mkdtempSync(join(tmpdir(), 'mosaic-value-render-'));
  try {
    const input = join(directory, 'input.json');
    writeFileSync(input, JSON.stringify({ contract, index }));
    execFileSync(cue, ['vet', '-c', './api/render', input, '-d', '#ValueProjection'], { stdio: 'pipe' });
    return JSON.parse(execFileSync(cue, ['export', './api/render', input, '-d', '#ValueProjection', '-e', expression], { encoding: 'utf8', stdio: 'pipe' }));
  } finally {
    rmSync(directory, { recursive: true, force: true });
  }
}

test('value renderer preserves string and numeric enum admission', () => {
  assert.deepEqual(project(named({ kind: 'enum', values: ['left', 'right'] })), {
    type: 'string', enum: ['left', 'right'], description: 'Independent example.'
  });
  assert.deepEqual(project(named({ kind: 'enum', values: [0, 1] })), {
    type: 'number', enum: [0, 1], description: 'Independent example.'
  });
});

test('TypeScript literal encoding uses single quotes and preserves escaped characters', () => {
  const value = 'apostrophe\' double" backslash\\ newline\n tab\t return\r nul\0 separator\u2028';
  const contract = named({ kind: 'literal', value });
  const literal = project(contract, {}, 'typescript');
  assert.equal(literal[0], "'");
  assert.equal(literal.at(-1), "'");
  assert.equal(runInNewContext(literal), value);
  assert.equal(project(contract).const, value);
  assert.equal(JSON.parse(project(contract, {}, 'native')), value);
});

test('declaration prose preserves blank paragraphs without trailing whitespace or comment termination', () => {
  const contract = { ...named({ kind: 'enum', values: ['left'] }), description: 'First paragraph.\n\nSecond */ paragraph.' };
  const declaration = project(contract, {}, 'declaration');
  assert.equal(declaration, '/**\n * First paragraph.\n *\n * Second *\\/ paragraph.\n */\nexport type Example = \'left\';\n');
  assert.equal(declaration.split('\n').some(line => /[ \t]$/.test(line)), false);
});

test('enumerated template expands all three admitted parts without dropping a component', () => {
  const digit = { name: 'Digit', description: '', exported: false, file: 'PlotTypes.ts', kind: 'enum', values: [0, 1] };
  const contract = named({ kind: 'union', schemaAdapter: 'unique-enum', members: [{
    kind: 'template', parts: [{ literal: 'p' }, { reference: 'Digit' }, { reference: 'Digit' }],
    completion: 'empty-record', schemaAdapter: 'enumerate'
  }] });
  assert.deepEqual(project(contract, { Digit: digit }), {
    type: 'string', enum: ['p00', 'p01', 'p10', 'p11'], description: 'Independent example.'
  });
});

test('open numeric template preserves its explicit wire adapter with four TypeScript parts', () => {
  const contract = named({ kind: 'union', members: [{
    kind: 'template', parts: [{ primitive: 'number' }, { literal: ' ' }, { literal: 'day' }, { literal: 's' }],
    completion: 'empty-record', schemaAdapter: 'open-string'
  }] });
  assert.deepEqual(project(contract), { anyOf: [{ type: 'string' }], description: 'Independent example.' });
});

test('complete owning admission rejects empty, truncated, ambiguous, and incompatible metadata', () => {
  const invalid = [
    named({ kind: 'enum', values: ['left', 1] }),
    named({ kind: 'enum', values: [] }),
    named({ kind: 'union', members: [] }),
    named({ kind: 'conditional', parameter: { name: 'T', default: 'any' }, branches: [], fallback: 'never', schemaAdapter: 'default-first-branch' }),
    ...[
      [],
      [{ literal: 'a' }, { literal: 'b' }, { literal: 'c' }, { literal: 'd' }],
      [{ primitive: 'number' }],
      [{ literal: 'a', reference: 'Other' }]
    ].map(parts => named({ kind: 'union', members: [{ kind: 'template', parts, completion: 'empty-record', schemaAdapter: 'enumerate' }] })),
    named({ kind: 'union', members: [{ kind: 'template', parts: [{ literal: 'a' }], completion: 'empty-record', schemaAdapter: 'raw-code' }] }),
    named({ kind: 'union', members: [{ kind: 'reference', name: 'Missing' }] })
  ];
  for (const contract of invalid) assert.throws(() => project(contract));
});
