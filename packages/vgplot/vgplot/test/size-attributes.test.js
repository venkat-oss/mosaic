// @vitest-environment jsdom
import { expect, it } from 'vitest';
import * as vg from '../src/index.js';

function nextRender(element) {
  return new Promise(resolve => {
    const observer = new MutationObserver(() => {
      observer.disconnect();
      resolve(undefined);
    });
    observer.observe(element, { childList: true });
  });
}

it('keeps radius and vector length scales independent through live range updates', async () => {
  const coordinator = new vg.Coordinator();
  const api = vg.createAPIContext({ coordinator });
  const radius = vg.Param.value([2, 10]);
  const length = vg.Param.value([5, 25]);
  const data = [{ x: 1, y: 1, value: 1 }, { x: 2, y: 2, value: 3 }];
  try {
    const element = api.plot(
      api.dot(data, { x: 'x', y: 'y', r: 'value' }),
      api.vector(data, { x: 'x', y: 'y', length: 'value', rotate: 0 }),
      api.rScale('linear'), api.rDomain([1, 3]), api.rRange(radius),
      api.lengthScale('linear'), api.lengthDomain([1, 3]), api.lengthRange(length)
    );
    await element.value.synch.promise;
    let svg = element.querySelector('svg');
    expect(svg.scale('r').apply(2)).toBe(6);
    expect(svg.scale('length').apply(2)).toBe(15);
    const rendered = nextRender(element);
    radius.update([4, 12]);
    await radius.pending('value');
    await rendered;
    svg = element.querySelector('svg');
    expect(svg.scale('r').apply(2)).toBe(8);
    expect(svg.scale('length').apply(2)).toBe(15);
    expect(element.value.getAttribute('rRange')).toBe(radius.value);
    expect(element.value.getAttribute('lengthRange')).toBe(length.value);
    expect(svg.querySelector('circle')).not.toBeNull();
    expect(svg.querySelector('path')).not.toBeNull();
  } finally {
    coordinator.clear();
  }
});

it.each(['r', 'length'])('%s caches its inferred Fixed domain when mark values change', async scale => {
  const coordinator = new vg.Coordinator();
  const api = vg.createAPIContext({ coordinator });
  const value = vg.Param.value([2, 3]);
  try {
    const mark = scale === 'r'
      ? api.dot([{}], { x: 1, y: 1, r: value })
      : api.vector([{}], { x: 1, y: 1, length: value, rotate: 0 });
    const element = api.plot(mark, api[`${scale}Domain`](vg.Fixed));
    await element.value.synch.promise;
    const domain = element.value.getAttribute(`${scale}Domain`);
    expect(Array.isArray(domain)).toBe(true);
    expect(domain.every(Number.isFinite)).toBe(true);
    const rendered = nextRender(element);
    value.update([8, 9]);
    await value.pending('value');
    await rendered;
    expect(element.value.marks[0].channel(scale).value).toBe(value.value);
    expect(element.value.getAttribute(`${scale}Domain`)).toBe(domain);
    expect(element.querySelector('svg').scale(scale).domain).toEqual(domain);
  } finally {
    coordinator.clear();
  }
});
