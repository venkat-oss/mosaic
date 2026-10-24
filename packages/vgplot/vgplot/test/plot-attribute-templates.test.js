// @vitest-environment jsdom
import {expect, it} from 'vitest';
import {renderTemplate, verifyWireAndPython} from './util/attribute-templates.js';

it('round trips the partial margins starter through wire and Python', async () => {
  const spec = await verifyWireAndPython('plot', 'margins');
  expect(spec.margins).toEqual({top:20,right:12,bottom:26,left:34});
});

it.each(['native','esm','ast'])('renders the margins starter through %s', async mode => {
  const element = await renderTemplate('plot', 'margins', mode);
  const plot = element.value;
  expect(element.querySelectorAll('circle')).toHaveLength(3);
  for (const [side,value] of [['Top',20],['Right',12],['Bottom',26],['Left',34]]) {
    expect(plot.getAttribute('margin'+side)).toBe(value);
  }
});
