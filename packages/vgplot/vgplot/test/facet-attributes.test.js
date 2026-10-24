// @vitest-environment jsdom
import { Param } from '@uwdata/mosaic-core';
import { Mark, Plot } from '@uwdata/mosaic-plot';
import { expect, it, vi } from 'vitest';
import { fxDomain } from '../src/index.js';

it('preserves parameter identity and updates the facet domain through its public directive', async () => {
  const domain = Param.value(['A', 'B']);
  const plot = new Plot();
  plot.addMark(new Mark('dot', [{ x: 1, group: 'A' }, { x: 2, group: 'B' }], { x: 'x', fx: 'group' }));
  vi.spyOn(plot, 'update').mockResolvedValue(undefined);
  fxDomain(domain)(plot);
  expect(plot.getAttribute('fxDomain')).toBe(domain.value);
  domain.update(['B', 'A', 'Empty']);
  await domain.pending('value');
  expect(plot.update).toHaveBeenCalledOnce();
  expect(plot.getAttribute('fxDomain')).toBe(domain.value);
});
