// @vitest-environment jsdom
import { Coordinator, Param } from '@uwdata/mosaic-core';
import { NodeConnector } from '@uwdata/mosaic-core/node-connector';
import * as sql from '@uwdata/mosaic-sql';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { Mark, markQuery } from '../src/marks/Mark.js';
import { Plot } from '../src/plot.js';

class Database extends NodeConnector {
  close() { this._db.close(); }
}

const database = new Database();
beforeAll(() => database.query({ type: 'exec', sql: `
  CREATE TABLE scope_stocks AS SELECT Date,Close::DOUBLE AS Close,Symbol FROM (VALUES
    (DATE '2013-05-13',10.0,'A'),(DATE '2013-05-14',15.0,'A'),
    (DATE '2013-05-13',20.0,'B'),(DATE '2013-05-14',10.0,'B')
  ) t(Date,Close,Symbol);
  CREATE TABLE scope_labels AS
    SELECT MAX(Date) AS Date,ARGMAX(Close,Date) AS Close,Symbol FROM scope_stocks GROUP BY Symbol;
` }));
afterAll(() => database.close());

async function setup(table, encodings) {
  const coordinator = new Coordinator(database, { logger: null, cache: false, consolidate: false });
  const plot = new Plot();
  const mark = new Mark('dot', { table }, encodings, { y: ['min', 'max'] });
  plot.addMark(mark);
  coordinator.connect(mark);
  await mark.pending;
  return {
    coordinator, mark,
    rows: async () => Array.from(await coordinator.query(mark.query().orderby('Symbol'))),
    close() { mark.destroy(); coordinator.clear(); }
  };
}

describe('mark source scope', () => {
  it('shares the source correlation alias across metadata, statistics and live Date queries', async () => {
    const point = Param.value(new Date('2013-05-13T00:00:00Z'));
    const expression = sql.sql`Close / (SELECT max(Close) FROM scope_stocks WHERE Symbol = source.Symbol AND Date = ${point})`;
    const state = await setup('scope_labels', { x: 'Symbol', y: expression });
    try {
      expect(state.mark.channel('y')).toMatchObject({ type: 'number', min: 0.5, max: 1.5 });
      expect(state.mark.channel('y').field).toBe(expression.expression);
      expect(sql.rootExpression(state.mark.channel('y').table)).toEqual(sql.from('scope_labels', 'source').expression);
      expect(await state.rows()).toEqual([{ Symbol: 'A', y: 1.5 }, { Symbol: 'B', y: 0.5 }]);
      point.update(new Date('2013-05-14T00:00:00Z'));
      await point.pending('value');
      await state.mark.pending;
      expect(state.mark.channel('y')).toMatchObject({ min: 1, max: 1 });
      expect(await state.rows()).toEqual([{ Symbol: 'A', y: 1 }, { Symbol: 'B', y: 1 }]);
    } finally { state.close(); }
  });

  it('retains physically qualified fields without introducing a relation alias', async () => {
    const table = sql.tableRef('main', 'scope_labels');
    const x = sql.column('Symbol', table);
    const y = sql.column('Close', table);
    const state = await setup(table, { x, y });
    try {
      expect(sql.inspectSelect(state.mark.query()).from.expressions[0]).toBe(table);
      expect(state.mark.channel('x').field).toBe(x);
      expect(state.mark.channel('y').field).toBe(y);
      expect(await state.rows()).toEqual([{ Symbol: 'A', Close: 15 }, { Symbol: 'B', Close: 10 }]);
    } finally { state.close(); }
  });

  it('retains explicitly authored relation aliases in metadata and queries', async () => {
    const table = sql.from('scope_labels', 'chosen');
    const x = sql.column('Symbol', 'chosen');
    const y = sql.column('Close', 'chosen');
    const state = await setup(table, { x, y });
    try {
      expect(sql.inspectSelect(state.mark.query()).from.expressions[0]).toBe(table.expression);
      expect(state.mark.channel('y').table).toBe(table);
      expect(await state.rows()).toEqual([{ Symbol: 'A', Close: 15 }, { Symbol: 'B', Close: 10 }]);
    } finally { state.close(); }
  });

  it('keeps source aliases local to nested subqueries while retaining physical outer references', async () => {
    const table = sql.tableRef('main', 'scope_labels');
    const point = Param.value(new Date('2013-05-13T00:00:00Z'));
    const symbol = sql.column('Symbol', table);
    const close = sql.column('Close', table);
    const denominator = sql.sql`(SELECT max(Close) FROM scope_stocks AS source WHERE source.Symbol = ${symbol} AND Date = ${point})`;
    const state = await setup(table, { x: symbol, y: sql.div(close, denominator) });
    try {
      expect(sql.inspectSelect(state.mark.query()).from.expressions[0]).toBe(table);
      expect(state.mark.channel('y')).toMatchObject({ min: 0.5, max: 1.5 });
      expect(await state.rows()).toEqual([{ Symbol: 'A', y: 1.5 }, { Symbol: 'B', y: 0.5 }]);
    } finally { state.close(); }
  });

  it('recognizes source-qualified identifier bindings without reading their values', () => {
    let reads = 0;
    const parameter = { get value() { ++reads; return 'Close'; }, addEventListener() {}, removeEventListener() {} };
    const field = sql.column(parameter, 'source');
    const query = markQuery([{ channel: 'y', as: 'value', field }], 'scope_labels');
    expect(reads).toBe(0);
    expect(sql.inspectSelect(query).from.expressions[0]).toEqual(sql.from('scope_labels', 'source').expression);
    expect(sql.selectEntries(query)[0].expr).toBe(field);
  });
});
