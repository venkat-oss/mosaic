import { expect, it } from 'vitest';
import { Coordinator, NativeSqlContext } from '@uwdata/mosaic-core';
import { NodeConnector } from '@uwdata/mosaic-core/node-connector';
import { Query, isQuery } from '@uwdata/mosaic-sql/native';
import { createAPIContext } from '@uwdata/vgplot';
import { astToESM, parseSpec } from '../src/index.js';

class TestConnector extends NodeConnector {
  close() { this._db.close(); }
}

it('instantiates spec table queries and inline objects in a native API context', async () => {
  const connector = new TestConnector;
  const coordinator = new Coordinator(connector, { native: new NativeSqlContext(), logger: null });
  const api = createAPIContext({ coordinator });
  try {
    const ast = parseSpec({
      data: {
        "quoted' rows": 'SELECT 1 AS x UNION ALL SELECT 2',
        objects: { type: 'json', data: [{ x: 3, label: "O'Reilly" }, { x: 4, label: null }], select: ['label', 'x + 1 AS value'] }
      },
      plot: []
    });
    const queries = Object.values(ast.data).map(node => node.instantiate({ api }));
    expect(queries.every(isQuery)).toBe(true);
    await coordinator.exec(queries);
    expect(Array.from(await coordinator.query(Query.from("quoted' rows").orderby('x')), row => row.x)).toEqual([1, 2]);
    expect(Array.from(await coordinator.query(Query.from('objects').orderby('value')))).toEqual([
      { label: "O'Reilly", value: 4 }, { label: null, value: 5 }
    ]);
    expect(astToESM(ast)).toContain('vg.createTable("quoted\' rows", "SELECT 1 AS x UNION ALL SELECT 2")');
  } finally {
    coordinator.clear();
    connector.close();
  }
});

it('generates table setup through the runtime API with literal-safe SQL and names', () => {
  const query = "SELECT 'a` ${b} \\ c' AS text";
  const ast = parseSpec({ data: { ['a"b']: { type: 'table', query, temp: true } }, plot: [] });
  const code = astToESM(ast);
  expect(code).toContain(`vg.createTable(${JSON.stringify('a"b')}, ${JSON.stringify(query)}, {temp: true})`);
});
