// @vitest-environment jsdom
import { describe, expect, it } from 'vitest';
import { Coordinator, NativeSqlContext } from '@uwdata/mosaic-core';
import { NodeConnector } from '@uwdata/mosaic-core/node-connector';
import { count, float64, isExpression } from '@uwdata/mosaic-sql/native';
import { createAPIContext } from '../src/context.js';
import { clientsReady } from './util/clients-ready.js';

/** @returns {clause is import('@uwdata/mosaic-core').NativeSelectionClause} */
function isNativeClause(clause) {
  return clause.context !== undefined && clause.fields.every(isExpression)
    && (clause.predicate == null || isExpression(clause.predicate));
}

class TestConnector extends NodeConnector {
  close() { this._db.close(); }
}

describe('native vgplot histogram', () => {
  it('passes context ownership through factories and updates real SVG bins', async () => {
    const connection = new TestConnector;
    const native = new NativeSqlContext();
    const coordinator = new Coordinator(connection, { native, logger: null, cache: false, consolidate: false });
    const api = createAPIContext({ coordinator });
    const selection = native.selection();
    let element;
    try {
      await coordinator.exec('CREATE OR REPLACE TEMP TABLE native_vgplot_histogram("a""b" DOUBLE); INSERT INTO native_vgplot_histogram VALUES (0.25),(0.75),(1.25),(1.75)');
      element = api.plot(
        api.rectY(api.from('native_vgplot_histogram', { filterBy: selection }), {
          x: api.bin('a"b', { step: 1 }), y: float64(count())
        }),
        api.intervalX({ as: selection, peers: false }),
        api.width(320), api.height(180)
      );
      expect((await clientsReady(element)).map(result => result.status)).toEqual(['fulfilled']);
      const plot = element.value;
      const mark = plot.marks[0];
      expect(plot.sqlContext).toBe(native);
      expect(mark.sqlOwner).toBe(native);
      expect(mark.filterBy).toBe(selection);
      expect(mark.data.numRows).toBe(2);
      expect(element.querySelectorAll('svg [data-index="0"] rect')).toHaveLength(2);
      expect(element.textContent).toContain('a"b');
      const brush = plot.interactors[0];
      const clause = brush.clause([0, 1]);
      if (!isNativeClause(clause)) throw new TypeError('Expected a native interval clause.');
      selection.update(clause);
      await selection.pending('value');
      expect(mark.data.numRows).toBe(1);
      const data = mark.data;
      if (!('columns' in data)) throw new TypeError('Expected columnar histogram data.');
      expect(Number(data.columns.y[0])).toBe(2);
      expect(element.querySelectorAll('svg [data-index="0"] rect')).toHaveLength(1);
    } finally {
      element?.value.marks.forEach(mark => mark.destroy());
      coordinator.clear();
      connection.close();
    }
  });
});
