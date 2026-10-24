// @vitest-environment jsdom
import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { clausePoint, Selection } from '@uwdata/mosaic-core';
import { NodeConnector } from '@uwdata/mosaic-core/node-connector';
import { parseSpec } from '@uwdata/mosaic-spec';
import { Ajv } from 'ajv';
import addFormats from 'ajv-formats';
import { describe, expect, it } from 'vitest';
import { parse as parseYAML } from 'yaml';
import * as vg from '../src/index.js';
import { clientsReady } from './util/clients-ready.js';

const names = ['crossfilter'];
const directory = resolve(import.meta.dirname, '../../../../templates/params');
const schema = JSON.parse(await readFile(resolve(import.meta.dirname, '../../spec/dist/mosaic-schema.json'), 'utf8'));
const ajv = new Ajv({ allowUnionTypes: true, allErrors: true });
addFormats.default(ajv);
const validate = ajv.compile(schema);
const database = NodeConnector.make();

describe.each(names)('%s parameter starter', name => {
  it('admits both declarative formats and preserves the intended parameter wiring', async () => {
    for (const extension of ['json', 'yaml']) {
      const source = await readFile(resolve(directory, `${name}.${extension}`), 'utf8');

      const spec = extension === 'json' ? JSON.parse(source) : parseYAML(source);
      expect(validate(spec), JSON.stringify(validate.errors)).toBe(true);
      expect(spec.vconcat).toHaveLength(2);
      expect(spec.params.upstream).toEqual({ select: 'single' });
      expect(spec.params.brush).toEqual({ select: name, empty: false, include: ['$upstream'] });
      expect(spec.vconcat[0].plot).toContainEqual({ select: 'toggleX', as: '$brush' });
      for (const plot of spec.vconcat) expect(plot.plot[0].data.filterBy).toBe('$brush');
      const normalized = parseSpec(spec).toJSON();
      expect(normalized.params.brush.include).toEqual(['$upstream']);
      expect(normalized.vconcat).toEqual(spec.vconcat);
      expect(parseSpec(normalized).toJSON()).toEqual(normalized);
    }
  });

  it('executes the JavaScript starter and propagates live parameter changes across both views', async () => {
    const source = await readFile(resolve(directory, `${name}.js`), 'utf8');

    const body = source
      .replace(/^import \* as vg from ['"]@uwdata\/vgplot['"];?$/m, '')
      .replace('export default ', 'const element = ');
    const errors = [];
    const mc = new vg.Coordinator(await database, { logger: null });
    mc.logger({ ...mc.logger(), error: error => errors.push(error) });
    const api = vg.createAPIContext({ coordinator: mc });
    try {
      const result = await new Function('vg', `return (async () => {${body}\nreturn {element, brush, upstream};})();`)(api);
      const element = result.element;
      const plots = [...element.children].map(child => child.value);
      expect(plots).toHaveLength(2);
      const marks = plots.map(plot => plot.marks[0]);
      const ready = async () => {
        expect((await clientsReady(element)).map(result => result.status)).toEqual(['fulfilled', 'fulfilled']);
        expect(errors).toEqual([]);
        expect(element.querySelectorAll('svg')).toHaveLength(2);
      };
      await ready();
      expect(marks.map(mark => mark.data?.numRows)).toEqual([3, 3]);
      expect(Number((await mc.query('SELECT COUNT(*) AS n FROM param_data')).get(0).n)).toBe(3);

      const { brush, upstream } = result;
      expect(brush).toBeInstanceOf(Selection);
      expect(upstream).toBeInstanceOf(Selection);
      expect(marks.every(mark => mark.filterBy === brush)).toBe(true);
      expect(brush.resolver).toMatchObject({ cross: true, union: false, single: false, empty: false });
      brush.update(clausePoint(vg.column('x'), 1, { source: marks[0] }));
      await brush.pending('value');
      await ready();
      expect(marks.map(mark => mark.data?.numRows)).toEqual([3, 1]);
      brush.update(clausePoint(vg.column('x'), 2, { source: marks[1] }));
      await brush.pending('value');
      await ready();
      expect(marks.map(mark => mark.data?.numRows)).toEqual([1, 1]);
      brush.reset();
      await brush.pending('value');
      await ready();
      expect(marks.map(mark => mark.data?.numRows)).toEqual([3, 3]);
      upstream.update(clausePoint(vg.column('x'), 3, { source: {} }));
      await upstream.pending('value');
      await brush.pending('value');
      await ready();
      expect(marks.map(mark => mark.data?.numRows)).toEqual([1, 1]);
      expect(brush.clauses[0]).toBe(upstream.clauses[0]);
    } finally {
      mc.clear();
    }
  });
});
