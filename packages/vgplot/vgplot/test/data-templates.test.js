// @vitest-environment jsdom
import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { NodeConnector } from '@uwdata/mosaic-core/node-connector';
import { astToDOM, parseSpec } from '@uwdata/mosaic-spec';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { describe, expect, it } from 'vitest';
import { parse as parseYAML } from 'yaml';
import * as vg from '../src/index.js';
import { clientsReady } from './util/clients-ready.js';

const root = resolve(import.meta.dirname, '../../../..');
const directories = ['templates/data'];
const names = ['source-filtered'];
const schema = JSON.parse(await readFile(resolve(root, 'packages/vgplot/spec/dist/mosaic-schema.json'), 'utf8'));
const ajv = new Ajv({ allowUnionTypes: true, allErrors: true });
addFormats.default(ajv);
const validate = ajv.compile(schema);
const database = NodeConnector.make();

async function context() {
  const errors = [];
  const connector = await database;
  await connector.query({type:'exec',sql:'DROP TABLE IF EXISTS data_rows; DROP TABLE IF EXISTS nested_rows'});
  const coordinator = new vg.Coordinator(connector, { logger: null });
  coordinator.logger({ ...coordinator.logger(), error: error => errors.push(error) });
  return { coordinator, errors, api: vg.createAPIContext({ coordinator }) };
}

async function assertRendered(element, errors) {
  expect((await clientsReady(element)).map(result => result.status)).toEqual(['fulfilled']);
  expect(errors).toEqual([]);
  expect(element.querySelector('svg')).not.toBeNull();
  expect(element.value.marks[0].data.numRows).toBeGreaterThan(0);
}

describe.each(names)('%s data starter', name => {
  it('admits JSON and YAML, loads real fixtures, and renders through the specification runtime', async () => {
    for (const extension of ['json', 'yaml']) {
      const source = await readFile(resolve(root, directories[0], `${name}.${extension}`), 'utf8');

      const value = extension === 'json' ? JSON.parse(source) : parseYAML(source);
      expect(validate(value), JSON.stringify(validate.errors)).toBe(true);
      const ast = parseSpec(value);
      expect(parseSpec(ast.toJSON()).toJSON()).toEqual(ast.toJSON());
      const { coordinator, errors, api } = await context();
      try {
        const { element } = await astToDOM(ast, { api, baseURL: pathToFileURL(root + '/').href });
        await assertRendered(element, errors);
        const plot = /** @type {any} */ (element).value;
        expect(plot.marks[0].filterBy).toBeDefined();
      } finally {
        coordinator.clear();
      }
    }
  }, 30000);

  it('executes the published JavaScript starter against real loaders and renders SVG', async () => {
    for (const directory of directories) {
      const path = resolve(root, directory, `${name}.js`);
      const source = await readFile(path, 'utf8');
      const body = source.replace(/^import \* as vg from ['"]@uwdata\/vgplot['"];?$/m, '').replaceAll('import.meta.url', JSON.stringify(pathToFileURL(path).href)).replace('export default ', 'return ');
      const { coordinator, errors, api } = await context();
      try {
        const element = await new Function('vg', `return (async () => {${body}})();`)(api);
        await assertRendered(element, errors);
      } finally {
        coordinator.clear();
      }
    }
  }, 30000);
});

it('executes the native-only unnest starter through actual mark queries', async () => {
  for (const directory of directories) {
    const source = await readFile(resolve(root, directory, 'unnest.js'), 'utf8');
    const body = source.replace(/^import \* as vg from ['"]@uwdata\/vgplot['"];?$/m, '').replace('export default ', 'return ');
    const { coordinator, errors, api } = await context();
    try {
      const element = await new Function('vg', `return (async () => {${body}})();`)(api);
      await assertRendered(element, errors);
      expect(element.value.marks[0].unnestFields).toEqual(['items']);
      expect(element.value.marks[0].data.numRows).toBe(3);
    } finally {
      coordinator.clear();
    }
  }
}, 30000);
