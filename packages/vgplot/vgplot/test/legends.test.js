// @vitest-environment jsdom
import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { NodeConnector } from '@uwdata/mosaic-core/node-connector';
import { describe, expect, it, vi } from 'vitest';
import * as vg from '../src/index.js';
import { clientsReady } from './util/clients-ready.js';

const legends = /** @type {const} */ ([
  ['colorLegend', 'color'],
  ['opacityLegend','opacity'],
  ['symbolLegend','symbol'],
]);

describe.each(legends)('%s', (name, channel) => {
  it('executes the JavaScript template against DuckDB', async () => {
    const mc = new vg.Coordinator(await NodeConnector.make(), { logger: null });
    const api = vg.createAPIContext({ coordinator: mc });
    const source = channel === 'color' ? await readFile(
      resolve(import.meta.dirname, '../../../../templates/legends/color.js'), 'utf8'
    ) : `await vg.coordinator().exec(vg.loadObjects('legend_data', [{x:1,y:2,category:'A',alpha:0.3},{x:2,y:1,category:'B',alpha:0.7},{x:3,y:3,category:'A',alpha:1}]));
const brush=vg.Selection.crossfilter();
export default vg.plot(vg.dot(vg.from('legend_data',{filterBy:brush}),{x:'x',y:'y',${channel}:${channel==='opacity' ? "'alpha'" : "'category'"}}),vg.${name}({as:brush,field:${channel==='opacity' ? "'alpha'" : "'category'"}}));`;
    const body = source
      .replace(/^import \* as vg from ['"]@uwdata\/vgplot['"];?$/m, '')
      .replace('export default ', 'return ');
    const run = new Function('vg', `return (async () => {${body}})();`);
    const canvas = { fillStyle: '', fillRect: vi.fn() };
    const canvasMocks = channel === 'opacity' ? [
      vi.spyOn(HTMLCanvasElement.prototype, 'getContext').mockReturnValue(
        /** @type {CanvasRenderingContext2D} */ (/** @type {unknown} */ (canvas))
      ),
      vi.spyOn(HTMLCanvasElement.prototype, 'toDataURL').mockReturnValue('data:image/png;base64,'),
    ] : [];
    try {
      const element = await run(api);
      await clientsReady(element);
      const plot = element.value;
      const [{ legend, include }] = plot.legends;
      const [mark] = plot.marks;
      const encoding = channel === 'color' ? 'fill' : channel;
      const field = channel === 'opacity' ? 'alpha' : 'category';

      expect(element.querySelector('svg')).not.toBeNull();
      expect(plot.legends).toHaveLength(1);
      expect(plot.marks).toHaveLength(1);
      expect(include).toBe(true);
      expect(legend.channel).toBe(channel);
      expect(legend.field).toBe(field);
      expect(legend.selection).toBe(mark.filterBy);
      expect(legend.selection).toBeInstanceOf(vg.Selection);
      expect(legend.selection.resolver.cross).toBe(true);
      expect(legend.selection.single).toBe(false);
      expect(mark.type).toBe('dot');
      expect(mark.channelField(encoding).field.column).toBe(field);
      expect(mark.sourceTable()).toBe('legend_data');
      if (channel === 'opacity') expect(canvas.fillRect).toHaveBeenCalledTimes(256);
      const data = await mc.query('SELECT * FROM legend_data ORDER BY x');
      expect(data.toArray()).toEqual([
        { x: 1, y: 2, category: 'A', alpha: 0.3 },
        { x: 2, y: 1, category: 'B', alpha: 0.7 },
        { x: 3, y: 3, category: 'A', alpha: 1 },
      ]);
    } finally {
      mc.clear();
      canvasMocks.forEach(mock => mock.mockRestore());
    }
  });

  it('creates an inline directive with default options', () => {
    const addLegend = vi.fn();
    const directive = vg[name]();
    expect(directive).toBeTypeOf('function');
    if (typeof directive === 'function') directive({ addLegend });

    expect(addLegend).toHaveBeenCalledExactlyOnceWith(expect.objectContaining({
      channel,
      options: {},
    }));
  });

  it('forwards selection, field, and rendering options without mutation', () => {
    const selection = vg.Selection.single();
    const options = Object.freeze({
      as: selection,
      field: 'category',
      label: null,
      columns: 0,
      tickSize: 4,
      className: 'custom-legend',
    });
    const addLegend = vi.fn();
    const directive = vg[name](options);
    if (typeof directive === 'function') directive({ addLegend });

    expect(addLegend).toHaveBeenCalledExactlyOnceWith(expect.objectContaining({
      channel,
      selection,
      field: 'category',
      options: { label: null, columns: 0, tickSize: 4, className: 'custom-legend' },
    }));
  });

  it('attaches a standalone legend to a plot element', () => {
    const addLegend = vi.fn();
    const element = vg[name]({ for: { value: { addLegend } }, width: 180 });

    expect(element).toBeInstanceOf(HTMLElement);
    expect(element).toHaveProperty('className', 'legend');
    expect(addLegend).toHaveBeenCalledExactlyOnceWith(expect.objectContaining({
      channel,
      element,
      options: { width: 180 },
    }), false);
  });

  it('keeps named plot lookup scoped to the API receiver', () => {
    const api = vg.createAPIContext();
    const other = vg.createAPIContext();
    const addLegend = vi.fn();
    const otherAddLegend = vi.fn();
    other.context.namedPlots.set('chart', { addLegend: otherAddLegend });

    const element = api[name]({ for: 'chart', label: 'Categories' });
    expect(addLegend).not.toHaveBeenCalled();
    expect(otherAddLegend).not.toHaveBeenCalled();

    api.context.namedPlots.set('chart', { addLegend });
    expect(addLegend).toHaveBeenCalledExactlyOnceWith(expect.objectContaining({
      channel,
      element,
      options: { label: 'Categories' },
    }), false);
    expect(otherAddLegend).not.toHaveBeenCalled();

    const immediate = api[name].call(api, { for: 'chart', height: 30 });
    expect(addLegend).toHaveBeenLastCalledWith(expect.objectContaining({
      channel,
      element: immediate,
      options: { height: 30 },
    }), false);
  });

  it('uses the default named plot registry for public module calls', () => {
    const plotName = `${name}-compatibility`;
    const addLegend = vi.fn();
    vg.namedPlots.set(plotName, { addLegend });
    try {
      const element = vg[name]({ for: plotName });
      expect(addLegend).toHaveBeenCalledExactlyOnceWith(expect.objectContaining({
        channel,
        element,
        options: {},
      }), false);
    } finally {
      vg.namedPlots.delete(plotName);
    }
  });
});
