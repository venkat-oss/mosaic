import assert from 'node:assert/strict';
import { test } from 'vitest';
import { componentMap } from '../src/config/components.js';
import { inputNames } from '../src/config/inputs.js';
import { plotNames } from '../src/config/plots.js';
import * as constants from '../src/constants.js';
import * as api from '@uwdata/vgplot';
import * as sql from '@uwdata/mosaic-sql';
import { Param, Selection } from '@uwdata/mosaic-core';

test('generated component dispatch preserves ordering and Map override semantics', () => {
  const parser = () => 'custom';
  const components = componentMap([['plot', parser], ['custom', parser]]);
  assert.deepEqual([...components.keys()], ['plot', 'mark', 'legend', 'input', 'hconcat', 'vconcat', 'hspace', 'vspace', 'custom']);
  assert.equal(components.get('plot'), parser);
  assert.equal(components.get('custom'), parser);
});

test('input and plot registries preserve custom names and supplied maps', () => {
  assert.deepEqual([...inputNames(['search', 'custom'])], ['menu', 'search', 'slider', 'table', 'custom']);
  const marks = new Set(['custom']);
  assert.equal(plotNames({marks}).marks, marks);
  assert.ok(plotNames().marks.has('dot'));
  assert.ok(plotNames().interactors.has('intervalXY'));
  assert.ok(plotNames().legends.has('colorLegend'));
  assert.ok(plotNames().attributes.has('width'));
});

test('composed public exports retain broader SQL and core bindings', () => {
  assert.equal(api.Param, Param);
  assert.equal(api.Selection, Selection);
  for (const name of ['Query', 'sql', 'cast', 'arrayAgg', 'corr', 'entropy', 'loadSpatial', 'frameRows']) {
    assert.equal(api[name], sql[name], name);
  }
  assert.equal(constants.COLUMPARAMREF, 'columnparamref');
  assert.equal(constants.SQL, 'sql');
  assert.equal(constants.FROM, 'from');
});
