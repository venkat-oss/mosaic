// @vitest-environment jsdom
import { expect, it } from 'vitest';
import { parse as parseYAML, stringify as stringifyYAML } from 'yaml';
import { Coordinator, NativeSqlContext, Param, Selection } from '@uwdata/mosaic-core';
import { NodeConnector } from '@uwdata/mosaic-core/node-connector';
import { Query, isQuery } from '@uwdata/mosaic-sql/native';
import { createAPIContext } from '@uwdata/vgplot';
import { astToDOM, astToESM, CodegenContext, InstantiateContext, parseSpec } from '../src/index.js';

class TestConnector extends NodeConnector {
  close() { this._db.close(); }
}

it('instantiates raw expressions, live column parameters and window frames using the owning API', async () => {
  const connector = new TestConnector;
  const coordinator = new Coordinator(connector, { native: new NativeSqlContext(), logger: null });
  const api = createAPIContext({ coordinator });
  const field = Param.value('x');
  const offset = Param.value(2);
  const activeParams = new Map;
  activeParams.set('field', field);
  activeParams.set('offset', offset);
  const ctx = new InstantiateContext({ api, params: activeParams });
  const literal = 'a` ${literal} \\ c';
  /** @type {import('../src/index.js').Spec} */
  const spec = {
    params: { field: 'x', offset: 2 },
    plot: [{ mark: 'dot', data: { from: 'native_spec_expressions' },
      x: { sql: `$$field + $offset + length('${literal}')` },
      y: { avg: 'x', orderby: 'x', rows: [1, 0] } }]
  };
  const ast = parseSpec(spec);
  const options = ast.root.children[0].options.options;
  try {
    await coordinator.exec('CREATE OR REPLACE TEMP TABLE native_spec_expressions AS SELECT * FROM (VALUES (1,10),(3,30)) t(x,y)');
    for (const mode of ['ast', 'esm']) {
      const expressions = Object.fromEntries(['x', 'y'].map(name => {
        const node = options[name];
        return [name, mode === 'ast' ? node.instantiate(ctx)
          : new Function('vg', '$field', '$offset', 'return ' + node.codegen(new CodegenContext))(api, field, offset)];
      }));
      field.update('x');
      offset.update(2);
      const query = Query.from('native_spec_expressions').select(expressions).orderby('x');
      expect(Array.from(await coordinator.query(query))).toEqual([
        { x: 3 + literal.length, y: 1 }, { x: 5 + literal.length, y: 2 }
      ]);
      field.update('y');
      offset.update(5);
      expect(Array.from(await coordinator.query(query))).toEqual([
        { x: 15 + literal.length, y: 1 }, { x: 35 + literal.length, y: 2 }
      ]);
    }
    expect(parseSpec(ast.toJSON()).toJSON()).toEqual(ast.toJSON());
    expect(parseSpec(parseYAML(stringifyYAML(ast.toJSON()))).toJSON()).toEqual(ast.toJSON());
    const dom = await astToDOM(parseSpec({ params: { brush: { select: 'crossfilter' } }, plot: [] }), { coordinator });
    expect(dom.params.get('brush')).toBeInstanceOf(Selection);
    expect(/** @type {Selection} */ (dom.params.get('brush')).owner).toBe(coordinator.nativeContext);
    expect(api.from('native_spec_expressions')).toMatchObject({ table: 'native_spec_expressions' });
  } finally {
    coordinator.clear();
    connector.close();
  }
});

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
