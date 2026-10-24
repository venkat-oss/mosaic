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

it('routes projection rotation and independent inset parameters through actual geographic rendering', async () => {
  const coordinator = new vg.Coordinator();
  const api = vg.createAPIContext({ coordinator });
  const rotation = vg.Param.value([0, 0, 0]);
  const left = vg.Param.value(5);
  try {
    const element = api.plot(
      api.dot([{ lon: -122, lat: 47 }, { lon: -74, lat: 41 }], { x: 'lon', y: 'lat', r: 4 }),
      api.width(300), api.height(200), api.projectionType('mercator'),
      api.projectionRotate(rotation), api.projectionInsetLeft(left),
      api.projectionInsetRight(10), api.projectionInsetTop(15), api.projectionInsetBottom(20)
    );
    await element.value.synch.promise;
    const first = Number(element.querySelector('circle').getAttribute('cx'));
    const insetRender = nextRender(element);
    left.update(20);
    await left.pending('value');
    await insetRender;
    expect(element.value.getAttribute('projectionInsetLeft')).toBe(20);
    expect(element.value.getAttribute('projectionInsetRight')).toBe(10);
    expect(element.value.getAttribute('projectionInsetTop')).toBe(15);
    expect(element.value.getAttribute('projectionInsetBottom')).toBe(20);
    const afterInset = Number(element.querySelector('circle').getAttribute('cx'));
    expect(afterInset).not.toBe(first);
    const rotationRender = nextRender(element);
    rotation.update([15, 0, 0]);
    await rotation.pending('value');
    await rotationRender;
    expect(element.value.getAttribute('projectionRotate')).toBe(rotation.value);
    expect(element.querySelectorAll('circle')).toHaveLength(2);
    expect(Number(element.querySelector('circle').getAttribute('cx'))).not.toBe(afterInset);
  } finally {
    coordinator.clear();
  }
});
