// @vitest-environment jsdom
import { expect, it } from 'vitest';
import { Fixed, Mark, Plot } from '../src/index.js';
import { plotRenderer } from '../src/plot-renderer.js';

it.each(['rRange', 'lengthRange'])('%s retains its admitted Fixed-range renderer limitation', async name => {
  const plot = new Plot();
  plot.setAttribute(name, Fixed);
  await expect(plotRenderer(plot)).rejects.toThrow(`Unsupported fixed attribute: ${name}`);
});

it.each(['r', 'length'])('%s retains its admitted null-scale renderer limitation', async scale => {
  const plot = new Plot();
  plot.setAttribute(`${scale}Scale`, null);
  plot.addMark(new Mark(scale === 'r' ? 'dot' : 'vector', [{ value: 2 }], { x: 1, y: 1, [scale]: 'value' }));
  await expect(plotRenderer(plot)).rejects.toThrow('unknown scale type: null');
});
