import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { mkdtempSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';

function project(value) {
  const directory = mkdtempSync(join(tmpdir(), 'mosaic-markdown-'));
  try {
    const path = join(directory, 'input.json');
    writeFileSync(path, JSON.stringify({ value }));
    return JSON.parse(execFileSync(process.env.CUE_BIN, ['export', './api/render', path, '-d', '#MarkdownReferences', '-e', 'text'], { encoding: 'utf8', stdio: 'pipe' }));
  } finally {
    rmSync(directory, { recursive: true, force: true });
  }
}

test('numeric Markdown references resolve within their owning description', () => {
  assert.equal(project('Use [first][1] and [again][1].\n\n[1]: https://example.com/first'), 'Use [first](https://example.com/first) and [again](https://example.com/first).');
  assert.equal(project('Use [first][1].\n\n[1]: https://example.com/second'), 'Use [first](https://example.com/second).');
});

test('multiple definitions preserve each destination and remove definition lines', () => {
  assert.equal(project('[beta][1], [alpha][2], then [gamma][3].\n\n [1]: https://example.com/beta?a=$x\n[2]: https://example.com/alpha#anchor\n\t[3]: https://example.com/gamma'), '[beta](https://example.com/beta?a=$x), [alpha](https://example.com/alpha#anchor), then [gamma](https://example.com/gamma).');
});

test('multiple numeric definitions on one source line keep independent destinations', () => {
  assert.equal(project('[beta][1], [tension][2], [alpha][3].\n\n[1]: https://example.com/beta [2]: https://example.com/tension [3]: https://example.com/alpha'), '[beta](https://example.com/beta), [tension](https://example.com/tension), [alpha](https://example.com/alpha).');
});

test('ordinary prose, inline links, brackets and external named references remain intact', () => {
  const text = 'Use [0, 1], [direct](https://example.com/direct), [reference][guide] and `x[y]`.';
  assert.equal(project(text), text);
  assert.equal(project('An unfinished [reference]['), 'An unfinished [reference][');
});
