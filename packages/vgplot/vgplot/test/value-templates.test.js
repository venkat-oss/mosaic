// @vitest-environment jsdom
import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { NodeConnector } from '@uwdata/mosaic-core/node-connector';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { describe, expect, it } from 'vitest';
import { parse as parseYAML } from 'yaml';
import { parseSpec } from '@uwdata/mosaic-spec';
import * as vg from '../src/index.js';
import { clientsReady } from './util/clients-ready.js';

const cases = /** @type {Array<[string,string,string|number]>} */ ([['fixed', 'xDomain', 'Fixed']]);
const jsCases = /** @type {const} */ ([...cases, ['numeric-interval', 'interval', 1]]);
const directory = resolve(import.meta.dirname, '../../../../templates/values');
const schema = JSON.parse(await readFile(
  resolve(import.meta.dirname, '../../spec/dist/mosaic-schema.json'), 'utf8'
));
const ajv = new Ajv({ allowUnionTypes: true, allErrors: true });
addFormats.default(ajv);
const validate = ajv.compile(schema);
const database = NodeConnector.make();

describe.each(cases)('%s value starter', (name, key, expected) => {
  it('admits and round trips both declarative formats with the intended value', async () => {
    for (const extension of ['json', 'yaml']) {
      const source = await readFile(resolve(directory, `${name}.${extension}`), 'utf8');

      const spec = extension === 'json' ? JSON.parse(source) : parseYAML(source);
      expect(validate(spec), JSON.stringify(validate.errors)).toBe(true);
      expect(spec[key]).toEqual(expected);
      const ast = parseSpec(spec);
      expect(ast.toJSON()).toEqual(spec);
      expect(parseSpec(ast.toJSON()).toJSON()).toEqual(spec);
    }
  });
});

describe.each(jsCases)('%s JavaScript value starter', (name, key, expected) => {
  it('executes the JavaScript starter against the retained renderer and DuckDB', async () => {
    const source = await readFile(resolve(directory, `${name}.js`), 'utf8');

    const body = source
      .replace(/^import \* as vg from ['"]@uwdata\/vgplot['"];?$/m, '')
      .replace('export default ', 'return ');
    const errors = [];
    const mc = new vg.Coordinator(await database, { logger: null });
    mc.logger({ ...mc.logger(), error: error => errors.push(error) });
    const api = vg.createAPIContext({ coordinator: mc });
    try {
      const element = await new Function('vg', `return (async () => {${body}})();`)(api);
      const results = await clientsReady(element);
      expect(results.map(result => result.status)).toEqual(['fulfilled']);
      expect(errors).toEqual([]);
      expect(element.value.marks).toHaveLength(1);
      expect(element.value.marks[0].type).toBe(name === 'numeric-interval' ? 'dotX' : 'dot');
      if (name === 'numeric-interval') {
        expect(element.value.marks[0].channel(key)).toEqual({ channel: key, value: expected });
      }
      expect(element.value.marks[0].data?.numRows).toBe(3);
      expect(element.querySelector('svg'), element.outerHTML).not.toBeNull();
      expect(Number((await mc.query('SELECT COUNT(*) AS n FROM value_data')).get(0).n)).toBe(3);
    } finally {
      mc.clear();
    }
  });
});
