// @vitest-environment jsdom
import { expect, it } from 'vitest';
import { renderTemplate, verifyWireAndPython } from './util/attribute-templates.js';

it('round trips the parameterized radius-range starter', async () => {
  const spec = await verifyWireAndPython('size', 'radius-range-parameter');
  expect(spec.rRange).toBe('$range');
  expect(spec.params).toEqual({range:[2,14]});
});

it.each(['native','esm','ast'])('renders the radius-range starter through %s', async mode => {
  const element = await renderTemplate('size', 'radius-range-parameter', mode);
  expect(element.querySelectorAll('circle')).toHaveLength(3);
});
