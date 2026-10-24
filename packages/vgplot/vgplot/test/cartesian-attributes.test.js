// @vitest-environment jsdom
import { astToDOM, parseSpec } from '@uwdata/mosaic-spec';
import { describe, expect, it } from 'vitest';
import * as vg from '../src/index.js';

function replacedChildren(element) {
  return new Promise(resolve => {
    const observer = new MutationObserver(() => {
      observer.disconnect();
      resolve(undefined);
    });
    observer.observe(element, { childList: true });
  });
}

describe.each(['x', 'y'])('%s Cartesian native authoring baseline', axis => {
  it('retains a formatter callback as the exact native function and invokes it during rendering', async () => {
    const coordinator = new vg.Coordinator();
    const api = vg.createAPIContext({ coordinator });
    const observed = [];
    const formatter = value => { observed.push(value); return `value=${value}`; };
    try {
      const element = api.plot(
        api.dot([{ x: 1, y: 2 }, { x: 2, y: 1 }, { x: 3, y: 3 }], { x: 'x', y: 'y' }),
        api[`${axis}TickFormat`](formatter)
      );
      await element.value.synch.promise;
      expect(element.value.getAttribute(`${axis}TickFormat`)).toBe(formatter);
      expect(observed.length).toBeGreaterThan(0);
      expect(element.querySelector('svg').textContent).toContain('value=');
    } finally {
      coordinator.clear();
    }
  });

  it('infers a Fixed domain once and retains that extent as reactive mark values move', async () => {
    const coordinator = new vg.Coordinator();
    const api = vg.createAPIContext({ coordinator });
    const position = vg.Param.value(2);
    try {
      const element = api.plot(
        api.dot([{}], { x: axis === 'x' ? position : 1, y: axis === 'y' ? position : 1 }),
        api[`${axis}Domain`](vg.Fixed)
      );
      const plot = element.value;
      expect(plot.getAttribute(`${axis}Domain`)).toBe(vg.Fixed);
      await plot.synch.promise;
      const inferred = plot.getAttribute(`${axis}Domain`);
      expect(Array.isArray(inferred)).toBe(true);
      expect(inferred).toEqual([2, 2]);
      const rendered = replacedChildren(element);
      position.update(8);
      await position.pending('value');
      await rendered;
      expect(plot.marks[0].channel(axis).value).toBe(8);
      expect(plot.getAttribute(`${axis}Domain`)).toBe(inferred);
      expect(element.querySelector('svg').scale(axis).domain).toEqual(inferred);
    } finally {
      coordinator.clear();
    }
  });

  it('keeps descending domains and native domain Param identity through updates', async () => {
    const coordinator = new vg.Coordinator();
    const api = vg.createAPIContext({ coordinator });
    const domain = vg.Param.value([4, 0]);
    try {
      const element = api.plot(
        api.dot([{ x: 1, y: 2 }, { x: 3, y: 1 }], { x: 'x', y: 'y' }),
        api[`${axis}Domain`](domain)
      );
      await element.value.synch.promise;
      expect(element.value.getAttribute(`${axis}Domain`)).toBe(domain.value);
      expect(element.querySelector('svg').scale(axis).domain).toEqual([4, 0]);
      const rendered = replacedChildren(element);
      domain.update([0, 6]);
      await domain.pending('value');
      await rendered;
      expect(element.value.getAttribute(`${axis}Domain`)).toBe(domain.value);
      expect(element.querySelector('svg').scale(axis).domain).toEqual([0, 6]);
    } finally {
      coordinator.clear();
    }
  });
});

it('composes a live UTC Date domain from named date params while scale intervals remain strings', async () => {
  const coordinator = new vg.Coordinator();
  const api = vg.createAPIContext({ coordinator });
  const spec = /** @type {import('@uwdata/mosaic-spec').Spec} */ ({
    params: {
      start: { date: '2024-01-01T00:00:00Z' }, end: { date: '2024-01-04T00:00:00Z' },
      when: { date: '2024-01-02T00:00:00Z' }, domain: ['$start', '$end']
    },
    plot: [{ mark: 'dot', data: [{}], x: '$when', y: 1 }],
    xScale: 'utc', xDomain: '$domain', xTicks: 'day', xNice: 'day', xGrid: 'day', xTickFormat: '%b %d'
  });
  try {
    const ast = parseSpec(spec);
    expect(ast.toJSON()).toEqual(spec);
    const { element, params } = /** @type {any} */ (await astToDOM(ast, { api }));
    const plot = element.value;
    await plot.synch.promise;
    expect(plot.getAttribute('xDomain')).toBe(params.get('domain').value);
    expect(plot.getAttribute('xDomain').every(value => value instanceof Date)).toBe(true);
    expect(element.querySelector('svg').scale('x').type).toBe('utc');
    expect(element.querySelector('svg').textContent).toContain('Jan 02');
    for (const name of ['xTicks', 'xNice', 'xGrid']) expect(plot.getAttribute(name)).toBe('day');
    const rendered = replacedChildren(element);
    params.get('end').update(new Date('2024-01-06T00:00:00Z'));
    await params.get('domain').pending('value');
    await rendered;
    expect(plot.getAttribute('xDomain')[1]).toBe(params.get('end').value);
    expect(element.querySelector('svg').scale('x').domain.map(value => value.toISOString())).toEqual([
      '2024-01-01T00:00:00.000Z', '2024-01-06T00:00:00.000Z'
    ]);
  } finally {
    coordinator.clear();
  }
});
