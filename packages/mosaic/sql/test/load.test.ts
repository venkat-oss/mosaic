import { expect, describe, it } from 'vitest';
import { loadCSV, loadObjects } from '../src/index.js';
import { queryFixture } from './util/validate.js';

describe('loadCSV', () => {
  it('accepts query options', () => {
    const base = {
      select: ['colA', 'colB'],
      where: 'colX > 5'
    };
    expect(loadCSV('table', 'data.csv', base).toString()).toBe(
      'CREATE TABLE IF NOT EXISTS "table" AS SELECT colA, colB FROM read_csv(\'data.csv\', auto_detect=true, sample_size=-1) WHERE colX > 5'
    );

    const ext = {
      ...base,
      view: true,
      replace: true
    };
    expect(loadCSV('table', 'data.csv', ext).toString()).toBe(
      'CREATE OR REPLACE VIEW "table" AS SELECT colA, colB FROM read_csv(\'data.csv\', auto_detect=true, sample_size=-1) WHERE colX > 5'
    );
  });

  it('accepts DuckDB options', () => {
    const opt = {
      auto_detect: false,
      all_varchar: true,
      columns: {line: 'VARCHAR'},
      force_not_null: ['line'],
      new_line: '\\n',
      header: false,
      skip: 2
    };
    expect(loadCSV('table', 'data.csv', opt).toString()).toBe(
      'CREATE TABLE IF NOT EXISTS "table" AS SELECT * FROM read_csv(\'data.csv\', auto_detect=false, sample_size=-1, all_varchar=true, columns={\'line\': \'VARCHAR\'}, force_not_null=[\'line\'], new_line=\'\\n\', header=false, skip=2)'
    );
  });
});

it('loads quoted file paths, option values and nested option keys', async () => {
  const path = "test/O'Reilly.csv";
  await queryFixture(String(loadCSV('quoted_csv_null', path, {nullstr: "can't"})));
  expect(await queryFixture('SELECT * FROM quoted_csv_null')).toEqual([{"author's name": null}]);
  await queryFixture(String(loadCSV('quoted_csv_text', path, {
    columns: {"author's name": 'VARCHAR'},
    force_not_null: ["author's name"]
  })));
  expect(await queryFixture('SELECT * FROM quoted_csv_text')).toEqual([{"author's name": "can't"}]);
});

describe('loadObjects', () => {
  const data = [{a: 1, b: 2}, {a: 3, b: 4}];

  it('selects a subset from every input row', async () => {
    await queryFixture(String(loadObjects('object_subset', data, {select: ['a']})));
    expect(await queryFixture('SELECT * FROM object_subset ORDER BY a')).toEqual([{a: 1}, {a: 3}]);
  });

  it('reorders and computes projected columns for every input row', async () => {
    await queryFixture(String(loadObjects('object_projection', data, {select: ['b', 'a', 'a + b AS total']})));
    expect(await queryFixture('SELECT * FROM object_projection ORDER BY a')).toEqual([
      {b: 2, a: 1, total: 3}, {b: 4, a: 3, total: 7}
    ]);
    await queryFixture(String(loadObjects('object_reordered', data, {select: ['b', 'a']})));
    expect(await queryFixture('SELECT * FROM object_reordered ORDER BY a')).toEqual([{b: 2, a: 1}, {b: 4, a: 3}]);
  });

  it('preserves quoted and prototype-named columns and string values', async () => {
    const data = [Object.fromEntries([['a"b', "O'Reilly"], ['__proto__', 2]])];
    await queryFixture(String(loadObjects('object_quoted_columns', data)));
    expect(await queryFixture('SELECT "a""b" AS quoted, "__proto__" AS prototype FROM object_quoted_columns')).toEqual([{quoted: "O'Reilly", prototype: 2}]);
  });
});
