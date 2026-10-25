// @vitest-environment jsdom
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { Coordinator, Param } from '@uwdata/mosaic-core';
import { NodeConnector } from '@uwdata/mosaic-core/node-connector';
import * as sql from '@uwdata/mosaic-sql';
import { ErrorBarMark } from '../src/marks/ErrorBarMark.js';
import { RegressionMark } from '../src/marks/RegressionMark.js';
import { Plot } from '../src/plot.js';

class Database extends NodeConnector {
  close() { this._db.close(); }
}

const database = new Database;
beforeAll(() => database.query({ type: 'exec', sql: `
  CREATE TABLE native_statistics(series VARCHAR, x DOUBLE, y DOUBLE);
  INSERT INTO native_statistics VALUES
    ('a',1,2),('a',2,4),('a',3,6),('a',4,NULL),
    ('b',1,5),('b',2,7),('b',3,9),('b',NULL,NULL)
` }));
afterAll(() => database.close());

async function setup(create) {

  const coordinator = new Coordinator(database, { cache: false, consolidate: false, logger: null });
  const errors = [];
  coordinator.logger({ ...coordinator.logger(), error: error => errors.push(error) });
  const plot = new Plot();
  const mark = create();
  plot.addMark(mark);
  coordinator.connect(mark);
  await mark.pending;
  return { coordinator, plot, mark, errors, close() { mark.destroy(); coordinator.clear(); } };
}

describe('native statistical marks', () => {
  it('fits grouped regressions from qualified columns and excludes missing pairs', async () => {
    const ci = Param.value(0);
    const source = { table: ['main', 'native_statistics'] };
    const qualifier = sql.tableRef(source.table);
    const state = await setup(() => new RegressionMark(source, {
      x: sql.column('x', qualifier), y: sql.column('y', qualifier), stroke: 'series', ci
    }));
    try {
      const fit = state.mark.modelFit;
      const rows = Array.from({ length: fit.numRows }, (_, i) => ({
        group: fit.columns.series[i], slope: Number(fit.columns.slope[i]),
        intercept: Number(fit.columns.intercept[i]), count: Number(fit.columns.n[i]),
        min: fit.columns.x0[i], max: fit.columns.x1[i]
      })).sort((a, b) => a.group.localeCompare(b.group));
      expect(rows).toEqual([
        { group: 'a', slope: 2, intercept: 0, count: 3, min: 1, max: 3 },
        { group: 'b', slope: 2, intercept: 3, count: 3, min: 1, max: 3 }
      ]);
      expect(state.plot.element.querySelectorAll('svg [aria-label="line"] path')).toHaveLength(2);
      ci.update(0.95);
      await ci.pending('value');
      expect(state.mark.modelFit).toBe(fit);
      expect(state.mark.areaData.numRows).toBeGreaterThan(4);
      expect(state.plot.element.querySelectorAll('svg [aria-label="area"] path')).toHaveLength(2);
      expect(state.errors).toEqual([]);
    } finally { state.close(); }
  });

  it('aggregates confidence bounds and filters each source group', async () => {
    const ci = Param.value(0.95);
    const state = await setup(() => new ErrorBarMark('ruleX', { table: 'native_statistics' }, {
      x: 'series', y: 'y', stroke: 'series', ci
    }));
    try {
      const rows = Array.from(await state.coordinator.query(state.mark.query()), row => ({
        group: row.series, average: Number(row.__avg__), error: Number(row.__se__)
      })).sort((a, b) => a.group.localeCompare(b.group));
      expect(rows.map(row => [row.group, row.average])).toEqual([['a', 4], ['b', 7]]);
      rows.forEach(row => expect(row.error).toBeCloseTo(2 / Math.sqrt(3), 12));
      const filtered = await state.coordinator.query(state.mark.query([sql.eq('series', sql.literal('b'))]));
      expect(Array.from(filtered, row => row.__avg__)).toEqual([7]);
      expect(state.plot.element.querySelectorAll('svg [aria-label="rule"] line')).toHaveLength(2);
      ci.update(0);
      await ci.pending('value');
      const options = Reflect.get(state.mark.plotSpecs()[0], 'options');
      expect(Array.from(options.y1)).toEqual(Array.from(options.y2));
      expect(state.errors).toEqual([]);
    } finally { state.close(); }
  });
});
