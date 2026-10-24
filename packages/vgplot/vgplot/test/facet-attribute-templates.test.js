// @vitest-environment jsdom
import { expect, it } from 'vitest';
import * as vg from '../src/index.js';
import { renderTemplate, verifyWireAndPython } from './util/attribute-templates.js';

const rows = [{x:1,y:1,column:1,row:10},{x:2,y:3,column:2,row:10},{x:3,y:2,column:1,row:20},{x:4,y:4,column:2,row:20}];

it('round trips the crossed-facet starter', async () => {
  const spec = await verifyWireAndPython('facet', 'fxDomain');
  expect(spec.fxDomain).toEqual([2,1,3]);
  expect(spec.fyDomain).toEqual([20,10]);
});

it.each(['native','esm','ast'])('renders the crossed-facet starter through %s', async mode => {
  const element = await renderTemplate('facet', 'fxDomain', mode);
  expect(element.querySelectorAll('circle')).toHaveLength(4);
});

it('nearest interaction follows actual crossed-facet SVG translations after explicit panel reordering', async () => {
  const coordinator = new vg.Coordinator();
  const api = vg.createAPIContext({ coordinator });
  const position = vg.Param.value(null);
  try {
    const data = rows.map((row, index) => ({ ...row, label: ['A', 'B', 'C', 'D'][index] }));
    const element = api.plot(api.dot(data, { x: 'x', y: 'y', fx: 'column', fy: 'row', title: 'label' }), api.nearest({ as: position }), api.fxDomain([2, 1]), api.fyDomain([20, 10]), api.width(480), api.height(360));
    await element.value.synch.promise;
    const svg = element.querySelector('svg');
    expect(svg.scale('fx').domain).toEqual([2, 1]);
    expect(svg.scale('fy').domain).toEqual([20, 10]);
    const circle = [...svg.querySelectorAll('circle')].find(circle => circle.textContent === 'D');
    expect(circle).toBeDefined();
    let px = Number(circle.getAttribute('cx'));
    let py = Number(circle.getAttribute('cy'));
    for (let parent = circle.parentElement; parent && parent !== svg; parent = parent.parentElement) {
      const match = /translate\(([^)]+)\)/.exec(parent.getAttribute('transform') ?? '');
      if (match) {
        const [x, y = 0] = match[1].split(/[ ,]+/).map(Number);
        px += x;
        py += y;
      }
    }
    svg.dispatchEvent(new MouseEvent('pointermove', { clientX: px, clientY: py }));
    await position.pending('value');
    expect(position.value).toEqual([4, 4]);
  } finally {
    coordinator.clear();
  }
});
