// @vitest-environment jsdom
import { expect, it } from 'vitest';
import { renderTemplate, verifyWireAndPython } from './util/attribute-templates.js';

it('round trips the reactive Cartesian domain starter', async () => {
  const spec = await verifyWireAndPython('cartesian', 'xDomain-parameter');
  expect(spec.xDomain).toBe('$domain');
  expect(spec.params).toEqual({domain: [0,4]});
});

it.each(['native', 'esm', 'ast'])('renders the Cartesian starter through %s', async mode => {
  const element = await renderTemplate('cartesian', 'xDomain-parameter', mode);
  expect(element.querySelectorAll('circle')).toHaveLength(3);
  expect(element.value.getAttribute('xDomain')).toEqual([0,4]);
});
