import { describe, expect, it } from 'vitest';
import { attributeMap, setAttributes } from '../src/plot-attributes.js';

describe('plot/container runtime routes', () => {
  it('preserves the separate route inventory and its original order', () => {
    expect([...attributeMap].slice(0, 15)).toEqual([
      ['style', 'style'], ['width', 'width'], ['height', 'height'], ['margin', 'margin'],
      ['marginLeft', 'marginLeft'], ['marginRight', 'marginRight'], ['marginTop', 'marginTop'], ['marginBottom', 'marginBottom'],
      ['align', 'align'], ['aspectRatio', 'aspectRatio'], ['axis', 'axis'], ['inset', 'inset'], ['grid', 'grid'], ['label', 'label'], ['padding', 'padding']
    ]);
    expect(attributeMap.has('name')).toBe(false);
    expect(attributeMap.has('margins')).toBe(false);
    const spec = {};
    setAttributes({ label: false, grid: undefined }, spec, []);
    expect(spec).toEqual({ label: false });
  });

  it.each(['ariaLabel', 'ariaDescription', 'clip'])('preserves the absent %s route and exact error', name => {
    expect(attributeMap.has(name)).toBe(false);
    expect(() => setAttributes({ [name]: 'value' }, {}, [])).toThrow(`Unrecognized plot attribute: ${name}`);
  });
});
