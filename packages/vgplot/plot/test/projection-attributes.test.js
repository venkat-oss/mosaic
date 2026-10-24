// @vitest-environment jsdom
import { geoMercator } from 'd3';
import { expect, it } from 'vitest';
import { Mark, Plot } from '../src/index.js';
import { plotRenderer } from '../src/plot-renderer.js';

function projected(type) {
  const plot = new Plot();
  plot.setAttribute('width', 300);
  plot.setAttribute('height', 200);
  plot.setAttribute('projectionType', type);
  plot.addMark(new Mark('dot', [{ lon: 0, lat: 0 }, { lon: 10, lat: 10 }], { x: 'lon', y: 'lat' }));
  return plot;
}

it('executes a native projection initializer with routed options and frame dimensions', async () => {
  const calls = [];
  const type = options => {
    calls.push(options);
    return geoMercator().scale(50).translate([options.width / 2, options.height / 2]);
  };
  const plot = projected(type);
  plot.setAttribute('projectionInsetLeft', 3);
  plot.setAttribute('projectionInsetRight', 7);
  plot.setAttribute('projectionRotate', [10, 20, 0]);
  const svg = await plotRenderer(plot);
  expect(plot.getAttribute('projectionType')).toBe(type);
  expect(calls).toEqual([{ width: 230, height: 150, clip: 'frame', rotate: [10, 20, 0] }]);
  expect(svg.querySelectorAll('circle')).toHaveLength(2);
  expect([...svg.querySelectorAll('circle')].every(circle => Number.isFinite(Number(circle.getAttribute('cx'))))).toBe(true);
});

it('preserves rejection of a direct D3 projection passed through the projectionType route', async () => {
  const projection = geoMercator();
  const plot = projected(projection);
  expect(plot.getAttribute('projectionType')).toBe(projection);
  await expect(plotRenderer(plot)).rejects.toThrow('projection.stream is not a function');
});

it('preserves rejection of a plain projection object passed through the projectionType route', async () => {
  await expect(plotRenderer(projected({ stream: geoMercator().stream }))).rejects.toThrow('unknown projection type: [object Object]');
});
