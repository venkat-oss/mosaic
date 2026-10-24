// @vitest-environment jsdom
import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { NodeConnector } from '@uwdata/mosaic-core/node-connector';
import { astToDOM, parseSpec } from '@uwdata/mosaic-spec';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { describe, expect, it } from 'vitest';
import { parse as parseYAML } from 'yaml';
import * as vg from '../src/index.js';
import { clientsReady } from './util/clients-ready.js';

const root = resolve(import.meta.dirname, '../../../..');
const directories = ['templates/inputs/table'];
const names = ['filtered'];
const schema = JSON.parse(await readFile(resolve(root, 'packages/vgplot/spec/dist/mosaic-schema.json'), 'utf8'));
const ajv = new Ajv({ allowUnionTypes: true, allErrors: true });
addFormats.default(ajv);
const validate = ajv.compile(schema);
const database = NodeConnector.make();

async function context() {
  const connector = await database;
  await connector.query({ type: 'exec', sql: 'DROP TABLE IF EXISTS table_data; DROP TABLE IF EXISTS table_other' });
  const errors = [];
  const coordinator = new vg.Coordinator(connector, { logger: null });
  coordinator.logger({ ...coordinator.logger(), error: error => errors.push(error) });
  return { coordinator, errors, api: vg.createAPIContext({ coordinator }) };
}

async function cleanup(coordinator) {
  await Promise.allSettled([...coordinator.manager.pendingResults]);
  coordinator.clear();
}

function tableOf(element) {
  return /** @type {any} */ (element.querySelector('table').parentElement).value;
}

async function assertTable(element, errors, name) {
  expect((await clientsReady(element)).every(result => result.status === 'fulfilled')).toBe(true);
  const table = tableOf(element);
  expect(table.constructor.name).toBe('Table');
  expect(table.schema.map(field => field.column)).toEqual(['x', 'category']);
  expect(table.body.rows).toHaveLength(['paged', 'selection', 'filtered'].includes(name) ? 2 : 5);
  expect(table.body.rows[0].cells[0].innerText).toBe('1');
  if (name === 'projection') {
    expect(table.element.style.maxWidth).toBe('500px');
    expect(table.element.style.maxHeight).toBe('220px');
    expect(table.style.innerText).toContain('text-align:justify');
    expect(table.style.innerText).toContain('width:70px');
  }
  expect(errors).toEqual([]);
}

async function execute(source, api) {
  const body = source.replace(/^import \* as vg from ['"]@uwdata\/vgplot['"];?$/m, '').replace('export default ', 'return ');
  return new Function('vg', `return (async () => {${body}})();` )({ ...vg, ...api });
}

describe.each(names)('%s table starter', name => {
  it('admits JSON/YAML and executes the actual parser/database/DOM consumer', async () => {
    for (const extension of ['json', 'yaml']) {
      const source = await readFile(resolve(root, directories[0], `${name}.${extension}`), 'utf8');

      const spec = extension === 'json' ? JSON.parse(source) : parseYAML(source);
      expect(validate(spec), JSON.stringify(validate.errors)).toBe(true);
      const ast = parseSpec(spec);
      expect(ast.toJSON()).toEqual(spec);
      const { coordinator, errors, api } = await context();
      try {
        const { element } = await astToDOM(ast, { api });
        await assertTable(element, errors, name);
      } finally { await cleanup(coordinator); }
    }
  }, 30000);

  it('executes both source JavaScript downloads against real table queries', async () => {
    for (const directory of directories) {
      const { coordinator, errors, api } = await context();
      try {
        const source = await readFile(resolve(root, directory, `${name}.js`), 'utf8');
        const element = await execute(source, api);
        await assertTable(element, errors, name);
      } finally { await cleanup(coordinator); }
    }
  }, 30000);
});

it('executes the JavaScript-only native container and text/element formatters', async () => {
  for (const directory of directories) {
    const { coordinator, errors, api } = await context();
    try {
      const element = await execute(await readFile(resolve(root, directory, 'native-format.js'), 'utf8'), api);
      await clientsReady(element);
      expect(element.tagName).toBe('SECTION');
      expect(tableOf(element).body.rows[0].cells[0].innerText).toBe('Value 1');
      expect(element.querySelector('tbody td strong').textContent).toBe('A');
      expect(errors).toEqual([]);
    } finally { await cleanup(coordinator); }
  }
}, 30000);

it('pages and sorts actual rows while preserving the labelled global prefetch boundary', async () => {
  const previous = vg.coordinator();
  const { coordinator, errors, api } = await context();
  vg.coordinator(coordinator);
  try {
    await coordinator.exec(vg.createTable('table_data', "SELECT * FROM (VALUES (1,'A'),(2,'B'),(3,'A'),(4,'B'),(5,'C')) AS t(x,category)"));
    const element = api.table({from:'table_data',columns:['x','category'],rowBatch:2});
    const table = tableOf(element);
    await table.pending;
    Object.defineProperties(element, { scrollHeight: { value: 300 }, clientHeight: { value: 100 }, scrollTop: { value: 150 } });
    element.dispatchEvent(new Event('scroll'));
    await table.pending;
    expect([...table.body.rows].map(row => row.cells[0].innerText)).toEqual(['1', '2', '3', '4']);
    element.dispatchEvent(new Event('scroll'));
    await table.pending;
    expect([...table.body.rows].map(row => row.cells[0].innerText)).toEqual(['1', '2', '3', '4', '5']);
    expect(table.loaded).toBe(true);
    table.head.querySelector('th').dispatchEvent(new MouseEvent('click'));
    await table.pending;
    expect([...table.body.rows].map(row => row.cells[0].innerText)).toEqual(['1', '2']);
    table.head.querySelector('th').dispatchEvent(new MouseEvent('click'));
    await table.pending;
    expect([...table.body.rows].map(row => row.cells[0].innerText)).toEqual(['5', '4']);
    table.head.querySelector('th').dispatchEvent(new MouseEvent('click', { metaKey: true }));
    await table.pending;
    expect(table.sortColumn).toBeNull();
    expect([...table.body.rows].map(row => row.cells[0].innerText)).toEqual(['1', '2']);
    expect(errors).toEqual([]);
  } finally { await cleanup(coordinator); vg.coordinator(previous); }
}, 30000);

it('reinitializes a Param-backed source and filters rows through a linked menu', async () => {
  const { coordinator, errors, api } = await context();
  try {
    await coordinator.exec(vg.createTable('table_data', "SELECT * FROM (VALUES (1,'A'),(2,'B'),(3,'A')) AS t(x,category)"));
    await coordinator.exec(vg.createTable('table_other', "SELECT * FROM (VALUES (10,'C'),(20,'D')) AS t(x,category)"));
    const source = vg.Param.value('table_data');
    const element = api.table({ from: source });
    const table = /** @type {any} */ (element).value;
    await table.pending;
    source.update('table_other');
    await source.pending('value');
    await table.pending;
    expect([...table.body.rows].map(row => row.cells[0].innerText)).toEqual(['10', '20']);
    const filter = vg.Selection.intersect();
    const menu = api.menu({ as: filter, field: 'category', options: ['A', 'B'] });
    const filtered = api.table({ from: 'table_data', filterBy: filter });
    const filteredTable = /** @type {any} */ (filtered).value;
    await filteredTable.pending;
    const control = /** @type {any} */ (menu).value;
    control.select.value = 'A';
    control.select.dispatchEvent(new Event('input'));
    await filter.pending('value');
    await filteredTable.pending;
    expect([...filteredTable.body.rows].map(row => row.cells[0].innerText)).toEqual(['1', '3']);
    expect(errors).toEqual([]);
  } finally { await cleanup(coordinator); }
}, 30000);

it('publishes hover rows across query chunks and clears on leave through the actual output selection', async () => {
  const previous = vg.coordinator();
  const { coordinator, errors, api } = await context();
  vg.coordinator(coordinator);
  try {
    await coordinator.exec(vg.createTable('table_data', "SELECT * FROM (VALUES (1,'A'),(2,'B')) AS t(x,category)"));
    const selection = vg.Selection.crossfilter();
    const element = api.table({ from: 'table_data', as: selection, rowBatch: 1 });
    const table = /** @type {any} */ (element).value;
    await table.pending;
    table.body.rows[0].cells[0].dispatchEvent(new Event('pointerover', { bubbles: true }));
    await selection.pending('value');
    expect(table.currentRow).toBe(0);
    expect(selection.active.source).toBe(table);
    expect(String(selection.predicate())).toContain('"x"');
    expect(String(selection.predicate())).toContain("'A'");
    Object.defineProperties(element, { scrollHeight: { value: 300 }, clientHeight: { value: 100 }, scrollTop: { value: 150 } });
    element.dispatchEvent(new Event('scroll'));
    await table.pending;
    table.body.rows[1].cells[0].dispatchEvent(new Event('pointerover', { bubbles: true }));
    await selection.pending('value');
    expect(table.currentRow).toBe(1);
    expect(String(selection.predicate())).toContain("'B'");
    table.body.dispatchEvent(new Event('pointerleave'));
    await selection.pending('value');
    expect(table.currentRow).toBe(-1);
    expect(selection.value).toEqual([]);
    expect(errors).toEqual([]);
  } finally { await cleanup(coordinator); vg.coordinator(previous); }
}, 30000);


it('preserves native alignment and selects rows through nested HTML and SVG formatters', async () => {
  const { coordinator, errors, api } = await context();
  try {
    await coordinator.exec(vg.createTable('table_data', 'SELECT 1 AS l,2 AS r,3 AS c,4 AS j'));
    const selection = vg.Selection.crossfilter();
    const element = api.table({
      from: 'table_data', as: selection, align: { l: 'left', r: 'right', c: 'center', j: 'justify' },
      format: {
        l: value => {
          const strong = document.createElement('strong');
          const span = document.createElement('span');
          Object.assign(span, { __row__: 99 });
          span.textContent = String(value);
          strong.appendChild(span);
          return strong;
        },
        r: () => {
          const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
          svg.appendChild(document.createElementNS(svg.namespaceURI, 'circle'));
          return svg;
        }
      }
    });
    const table = /** @type {any} */ (element).value;
    await table.pending;
    expect(table.style.innerText).not.toContain('nth-child(1)');
    expect(table.style.innerText).toContain('nth-child(2) {text-align:right;');
    expect(table.style.innerText).toContain('nth-child(3) {text-align:center;');
    expect(table.style.innerText).toContain('nth-child(4) {text-align:justify;');
    for (const target of [table.body.querySelector('span'), table.body.querySelector('circle')]) {
      target.dispatchEvent(new Event('pointerover', { bubbles: true }));
      await selection.pending('value');
      expect(table.currentRow).toBe(0);
      expect(selection.active.source).toBe(table);
      expect(selection.value).toEqual([[1, 2, 3, 4]]);
      table.body.dispatchEvent(new Event('pointerleave'));
      await selection.pending('value');
      expect(table.currentRow).toBe(-1);
      expect(selection.value).toEqual([]);
    }
    table.body.dispatchEvent(new Event('pointerover', { bubbles: true }));
    expect(table.currentRow).toBe(-1);
    table.body.rows[0].cells[0].dispatchEvent(new Event('pointerover', { bubbles: true }));
    await selection.pending('value');
    expect(table.currentRow).toBe(0);
    expect(errors).toEqual([]);
  } finally { await cleanup(coordinator); }
}, 30000);
