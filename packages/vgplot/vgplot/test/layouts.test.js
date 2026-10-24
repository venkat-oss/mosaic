// @vitest-environment jsdom
import { describe, expect, it } from 'vitest';
import * as vg from '../src/index.js';
import { concat, hconcat, vconcat } from '../src/layout/concat.js';
import { hspace, space, vspace } from '../src/layout/space.js';
import * as runtime from '../src/layout/runtime.js';

describe('layout DOM contracts', () => {
  it.each(/** @type {const} */ ([['hconcat', 'row'], ['vconcat', 'column']]))('%s keeps child identities and order while flattening exactly one level', (name, direction) => {
    const first = document.createElement('b');
    const second = document.createElement('i');
    const third = document.createElement('em');
    const oldParent = document.createElement('div');
    oldParent.append(first);
    const result = vg[name]([first, second], third);
    expect([...result.children]).toEqual([first, second, third]);
    expect(oldParent.children).toHaveLength(0);
    expect(result.style.display).toBe('flex');
    expect(result.style.flexDirection).toBe(direction);
    expect(result.style.flexWrap).toBe('nowrap');
    expect(vg[name].length).toBe(0);
    expect(/** @type {any} */ (result).value.element).toBe(result);
    expect(() => vg[name]([[document.createElement('b')]])).toThrow(/not of type 'Node'/);
    expect(vg[name]().children).toHaveLength(0);
  });

  it.each(/** @type {const} */ ([['hspace', 'width'], ['vspace', 'height']]))('%s preserves size coercion and its omitted default', (name, dimension) => {
    for (const [value, expected] of [[12, '12px'], [2.5, '2.5px'], ['12', '12px'], ['1.5em', '1.5em'], ['', ''], [null, ''], [undefined, '10px']]) {
      const result = vg[name](value);
      expect(result.style[dimension]).toBe(expected);
      expect(result.style.display).toBe('inline-block');
      expect(result.value.element).toBe(result);
    }
    expect(vg[name]().style[dimension]).toBe('10px');
    expect(vg[name].length).toBe(1);
  });

  it('retains the deep primitive exports and runtime wrapping behavior', () => {
    expect(concat).toBe(runtime.concat);
    expect(space).toBe(runtime.space);
    expect([vg.hconcat, vg.vconcat, vg.hspace, vg.vspace]).toEqual([hconcat, vconcat, hspace, vspace]);
    expect(space({}).style.width).toBe('10px');
    const child = document.createElement('span');
    expect(concat({ direction: 'horizontal', wrap: true }, [child]).style.flexWrap).toBe('wrap');
    expect(concat(/** @type {any} */ ({ wrap: 'wrap-reverse' }), []).style.flexWrap).toBe('wrap-reverse');
    const api = vg.createAPIContext();
    expect(api.hconcat(child).firstChild).toBe(child);
    expect(api.vspace(3).style.height).toBe('3px');
  });
});
