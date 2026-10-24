// @vitest-environment jsdom
import { describe, expect, it, vi } from 'vitest';
import { Param } from '@uwdata/mosaic-core';
import { Plot } from '@uwdata/mosaic-plot';
import * as vg from '../src/index.js';
import { NamedPlots, namedPlots, requestNamedPlot } from '../src/plot/named-plots.js';

const simple = ['width', 'height', 'aspectRatio', 'marginTop', 'marginRight', 'marginBottom', 'marginLeft', 'inset', 'style', 'align', 'padding', 'axis', 'grid', 'ariaLabel', 'ariaDescription', 'clip'];

describe('plot/container directive runtime', () => {
  it.each(simple)('%s retains omitted/null values, arity and native parameter subscriptions', async name => {
    const setAttribute = vi.fn();
    const update = vi.fn();
    const plot = { setAttribute, update };
    expect(vg[name].length).toBe(1);
    expect(vg[name].name).toBe('');
    vg[name]()(plot);
    vg[name](null)(plot);
    expect(setAttribute.mock.calls).toEqual([[name, undefined], [name, null]]);
    setAttribute.mockClear();
    const value = Param.value(undefined);
    vg[name](value)(plot);
    expect(setAttribute).not.toHaveBeenCalled();
    value.update(14);
    await value.pending('value');
    expect(setAttribute).toHaveBeenLastCalledWith(name, 14);
    expect(update).toHaveBeenCalledExactlyOnceWith();
    value.update(undefined);
    await value.pending('value');
    expect(setAttribute).toHaveBeenLastCalledWith(name, undefined);
    expect(update).toHaveBeenCalledTimes(2);
  });

  it('keeps margin expansions ordered, partial and reactive, including literal nulls', async () => {
    const calls = [];
    const plot = { setAttribute: (name, value) => calls.push([name, value]), update: vi.fn() };
    vg.margin(7)(plot);
    expect(calls).toEqual([['marginTop', 7], ['marginBottom', 7], ['marginLeft', 7], ['marginRight', 7]]);
    calls.length = 0;
    const top = Param.value(3);
    vg.margins({ top, right: null, left: undefined, extra: 5 })(plot);
    expect(calls).toEqual([['marginTop', 3], ['marginRight', null]]);
    top.update(8);
    await top.pending('value');
    expect(calls.at(-1)).toEqual(['marginTop', 8]);
    expect(plot.update).toHaveBeenCalledExactlyOnceWith();
    expect(() => vg.margins()(plot)).toThrow();
  });

  it('preserves named plot identity, waiting callbacks and isolated receiver contexts', () => {
    const first = vg.createAPIContext({ namedPlots: new NamedPlots() });
    const second = vg.createAPIContext({ namedPlots: new NamedPlots() });
    const plot = { marker: 'first' };
    const other = { marker: 'second' };
    const callback = vi.fn();
    requestNamedPlot(first, 'shared', callback);
    first.name('shared')(plot);
    second.name('shared')(other);
    expect(first.context.namedPlots.get('shared')).toBe(plot);
    expect(second.context.namedPlots.get('shared')).toBe(other);
    expect(callback).toHaveBeenCalledExactlyOnceWith(plot);
    vg.name('global-fixture')(plot);
    expect(namedPlots.get('global-fixture')).toBe(plot);
    namedPlots.delete('global-fixture');
  });

  it('preserves repeated directive precedence and the runtime-only label route', async () => {
    const plot = new Plot();
    vg.width(300)(plot);
    vg.width(360)(plot);
    expect(plot.getAttribute('width')).toBe(360);
    vg.width()(plot);
    expect(plot.getAttribute('width')).toBeUndefined();
    expect('label' in vg).toBe(false);
    plot.setAttribute('width', 280);
    plot.setAttribute('label', false);
    await plot.render();
    expect(plot.element.querySelector('svg')).not.toBeNull();
  });

  it.each(['ariaLabel', 'ariaDescription', 'clip'])('keeps %s as an exact named rendering rejection', async name => {
    const plot = new Plot();
    vg[name](name === 'clip' ? 'frame' : 'Description')(plot);
    await expect(plot.render()).rejects.toThrow(`Unrecognized plot attribute: ${name}`);
  });
});
