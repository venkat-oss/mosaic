// @vitest-environment jsdom
import { geoMercator } from 'd3';
import { expect, it } from 'vitest';
import { renderTemplate, verifyWireAndPython } from './util/attribute-templates.js';

it('round trips the geographic projection starter', async () => {
  const spec = await verifyWireAndPython('projection', 'projectionType');
  expect(spec.projectionType).toBe('mercator');
});

it.each(['native','esm','ast'])('renders the projection starter through %s', async mode => {
  const element = await renderTemplate('projection', 'projectionType', mode);
  const circles = [...element.querySelectorAll('circle')];
  expect(circles).toHaveLength(3);
  expect(circles.every(circle => Number.isFinite(Number(circle.getAttribute('cx'))))).toBe(true);
});

it('executes the native projection initializer starter', async () => {
  const element = await renderTemplate('projection', 'native-initializer', 'host', {geoMercator});
  expect(element.querySelectorAll('circle')).toHaveLength(3);
  expect(typeof element.value.getAttribute('projectionType')).toBe('function');
});
