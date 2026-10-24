// @vitest-environment jsdom
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { Coordinator, NativeSqlContext, Param } from '@uwdata/mosaic-core';
import { NodeConnector } from '@uwdata/mosaic-core/node-connector';
import * as sql from '@uwdata/mosaic-sql/native';
import { column as legacyColumn } from '@uwdata/mosaic-sql';
import { Mark } from '../src/marks/Mark.js';
import { Plot } from '../src/plot.js';
import { bin } from '../src/transforms/bin.js';
import { Interval1D } from '../src/interactors/Interval1D.js';
import { Toggle } from '../src/interactors/Toggle.js';
import { getField } from '../src/interactors/util/get-field.js';
import { filteredExtent } from '../src/marks/util/extent.js';
import { nativeBinExpr } from '../src/marks/util/bin-expr.js';

class RecordingConnector extends NodeConnector {
  constructor() {
    super();
    this.calls = [];
    /** @type {Promise<void> | undefined} */
    this.gate = undefined;
  }

  hold() {
    let release = () => {};
    this.gate = new Promise(resolve => { release = () => resolve(undefined); });
    return () => { this.gate = undefined; release(); };
  }

  close() {
    this._db.close();
  }

  /**
   * @overload
   * @param {import('@uwdata/mosaic-core').ArrowQueryRequest} request
   * @returns {Promise<Uint8Array[]>}
   */
  /**
   * @overload
   * @param {import('@uwdata/mosaic-core').ExecQueryRequest} request
   * @returns {Promise<void>}
   */
  /**
   * @param {import('@uwdata/mosaic-core').ArrowQueryRequest | import('@uwdata/mosaic-core').ExecQueryRequest} request
   * @returns {Promise<Uint8Array[] | void>}
   */
  query(request) {
    this.calls.push(request);
    const response = request.type === 'exec' ? super.query(request) : super.query(request);
    return this.gate && request.type === 'exec' && request.sql === 'SELECT 1'
      ? Promise.all([response, this.gate]).then(([value]) => value)
      : response;
  }
}

const database = new RecordingConnector;
beforeAll(async () => {
  await database.query({ type: 'exec', sql: 'CREATE TABLE native_histogram(x DOUBLE,y DOUBLE); INSERT INTO native_histogram VALUES (0.25,100),(0.75,110),(1.25,120),(1.75,130)' });
  await database.query({ type: 'exec', sql: 'CREATE TABLE native_histogram_changed(x DOUBLE); INSERT INTO native_histogram_changed VALUES (100),(110),(120),(130)' });
});
afterAll(() => database.close());

/** @param {{field?: import('@uwdata/mosaic-sql/native').ExprValue, table?: import('@uwdata/mosaic-sql/native').TableArg | Param<string>, options?: import('@uwdata/mosaic-sql/native').BinHistogramOptions, reqs?: Record<string, import('@uwdata/mosaic-core').Stat[]>}} [settings] */
async function setup({ field = 'x', table = 'native_histogram', options = { step: 1 }, reqs = {} } = {}) {
  const native = new NativeSqlContext();
  const connector = database;
  connector.calls.length = 0;
  const errors = [];
  const coordinator = new Coordinator(connector, { native, cache: false, consolidate: false, logger: null });
  coordinator.logger({ ...coordinator.logger(), error: error => errors.push(error) });
  const selection = native.selection();
  const plot = new Plot(undefined, native);
  plot.setAttribute('height', 180);
  const mark = new Mark('rectY', { table, options: { filterBy: selection } }, {
    x: bin(field, options), y: sql.float64(sql.count())
  }, reqs, native);
  plot.addMark(mark);
  const brush = new Interval1D(mark, { channel: 'x', selection, peers: false });
  plot.addInteractor(brush);
  coordinator.connect(mark);
  await mark.pending;
  const rows = () => {
    const data = mark.data;
    if (!('columns' in data)) throw new TypeError('Expected columnar histogram results.');
    const { columns, numRows } = data;
    return Array.from({ length: numRows }, (_, i) => [Number(columns.x1[i]), Number(columns.x2[i]), Number(columns.y[i])])
      .sort((a, b) => a[0] - b[0]);
  };
  return {
    native, coordinator, selection, plot, mark, brush, errors, calls: connector.calls, rows,
    hold: () => connector.hold(),
    close() { mark.destroy(); coordinator.clear(); }
  };
}

/** @returns {clause is import('@uwdata/mosaic-core').NativeSelectionClause} */
function isNativeClause(clause) {
  return clause.context !== undefined && clause.fields.every(sql.isExpression)
    && (clause.predicate == null || sql.isExpression(clause.predicate));
}

describe('native Mark queries', () => {
  it.each([false, true])('preserves tooltip and sort options with native context %s', native => {
    const context = native ? new NativeSqlContext() : null;
    const tip = { format: { x: false, y: false } };
    const sort = { limit: 10 };
    const mark = new Mark('dot', null, { tip, sort }, {}, context);
    expect(mark.channel('tip').value).toBe(tip);
    expect(mark.channel('sort').value).toBe(sort);
    const options = Reflect.get(mark.plotSpecs()[0], 'options');
    expect(options.tip).toBe(tip);
    expect(options.sort).toBe(sort);
  });

  it('rejects native fields and handles in legacy marks and legacy fields in native marks', () => {
    expect(() => new Mark('dot', null, { x: sql.column('x') })).toThrow(/native plot context/);
    expect(() => new Mark('dot', null, { tip: sql.sum('x') })).toThrow(/native plot context/);
    expect(() => new Mark('dot', null, { x: legacyColumn('x') }, {}, new NativeSqlContext())).toThrow(/require native SQL expressions/);
  });

  it('shares native pixel binning with padding, direction and original fields', async () => {
    const state = await setup();
    try {
      const field = sql.column('x');
      const [index, value] = nativeBinExpr(state.mark, 'x', 11, [0, 2], 1, field);
      expect(value).toBe(field);
      const query = sql.Query.from('native_histogram').select({ index, value }).orderby('x');
      expect(Array.from(await state.coordinator.query(query), row => Number(row.index))).toEqual([1.25, 3.75, 6.25, 8.75]);
      state.plot.setAttribute('xReverse', true);
      const [reverse] = nativeBinExpr(state.mark, 'x', 11, [0, 2], 1, field);
      expect(Array.from(await state.coordinator.query(query.clone().setSelect({ index: reverse })), row => Number(row.index)))
        .toEqual([8.75, 6.25, 3.75, 1.25]);
      expect(state.errors).toEqual([]);
    } finally { state.close(); }
  });

  it('prepares bin metadata, materializes interactive aggregates and renders SVG', async () => {
    const state = await setup({ reqs: { y: ['max'] } });
    try {
      expect(state.mark.sqlOwner).toBe(state.native);
      expect(state.mark.channelField('x').min).toBe(0.25);
      expect(state.mark.channelField('x').max).toBe(1.75);
      expect(Number(state.mark.channelField('y').max)).toBe(2);
      expect(state.rows()).toEqual([[0, 1, 2], [1, 2, 2]]);
      expect(state.plot.element.querySelectorAll('svg [data-index="0"] rect')).toHaveLength(2);
      expect(state.plot.element.textContent).not.toContain('[object Object]');
      const clause = state.brush.clause([0, 1]);
      if (!isNativeClause(clause)) throw new TypeError('Expected a native interval clause.');
      expect(clause.context).toBe(state.native);
      expect(clause.fields[0]).toBe(getField(state.mark, 'x'));
      expect(filteredExtent(clause.predicate, clause.fields[0])).toEqual([0, 1]);
      state.selection.update(clause);
      await state.selection.pending('value');
      expect(state.rows()).toEqual([[0, 1, 2]]);
      const plan = state.coordinator.preaggregator.entries.get(state.mark);
      if (!plan || !('result' in plan)) throw new TypeError('Expected a materialized histogram plan.');
      expect(plan.result).toBeTruthy();
      expect(state.calls.some(request => /CREATE TABLE.*preagg_/i.test(request.sql))).toBe(true);
      expect(state.plot.element.querySelectorAll('svg [data-index="0"] rect')).toHaveLength(1);
      const next = state.brush.clause([1, 2]);
      if (!isNativeClause(next)) throw new TypeError('Expected a native interval clause.');
      state.selection.update(next);
      await state.selection.pending('value');
      expect(state.rows()).toEqual([[1, 2, 2]]);
      const toggle = new Toggle(state.mark, { channels: ['x'], selection: state.selection });
      expect(toggle.clause([[1]]).context).toBe(state.native);
      expect(state.errors).toEqual([]);
    } finally { state.close(); }
  });

  it('rebuilds known bins after source metadata changes and keeps standalone bindings live', async () => {
    const table = Param.value('native_histogram');
    const state = await setup({ table, options: { steps: 2 } });
    try {
      const binding = state.mark.channelField('x').field;
      const query = sql.Query.from('native_histogram_changed').select({ lower: binding }).orderby('x');
      table.update('native_histogram_changed');
      await table.pending('value');
      await state.mark.pending;
      expect(state.rows()).toEqual([[100, 120, 2], [120, 140, 2]]);
      expect(Array.from(await state.coordinator.query(query), row => Number(row.lower))).toEqual([100, 100, 120, 120]);
      expect(state.mark.channelField('x').min).toBe(100);
      expect(state.errors).toEqual([]);
    } finally { state.close(); }
  });

  it('retains qualified native field paths and source table arrays', async () => {
    const field = sql.column('x', sql.tableRef('main', 'native_histogram'));
    const state = await setup({ field, table: ['main', 'native_histogram'] });
    try {
      expect(state.brush.field).toBe(field);
      expect(state.rows()).toEqual([[0, 1, 2], [1, 2, 2]]);
      expect(state.errors).toEqual([]);
    } finally { state.close(); }
  });

  it('cancels a queued bin query when its identifier needs new metadata', async () => {
    const field = Param.value('x');
    const state = await setup({ field: sql.column(field), options: { steps: 2 } });
    const release = state.hold();
    try {
      const retained = sql.Query.from('native_histogram').select({ lower: state.mark.channelField('x').field }).orderby('x');
      const barrier = state.coordinator.exec('SELECT 1');
      state.mark.requestQuery();
      field.update('y');
      await field.pending('value');
      expect(() => sql.compile([retained], state.native.execution)).toThrow(/prepared channel statistics/);
      release();
      await barrier;
      await state.mark.pending;
      expect(state.rows()).toEqual([[100, 120, 2], [120, 140, 2]]);
      expect(Array.from(await state.coordinator.query(retained), row => Number(row.lower))).toEqual([100, 100, 120, 120]);
      expect(state.mark.channelField('x').column).toBe(getField(state.mark, 'x'));
      expect(state.errors).toEqual([]);
    } finally { release(); state.close(); }
  });
});
