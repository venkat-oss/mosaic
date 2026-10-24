// @vitest-environment jsdom
import { describe, expect, it } from 'vitest';
import * as vg from '../src/index.js';
import { Fixed, Plot } from '@uwdata/mosaic-plot';

describe('plot runtime compatibility', () => {
  it('preserves the plot Fixed symbol identity in the public API', () => {
    expect(vg.Fixed).toBe(Fixed);
    expect(typeof vg.Fixed).toBe('symbol');
  });

  it('renders with the runtime-only label attribute', async () => {
    const plot = new Plot();
    plot.setAttribute('label', 'Measure');
    await plot.render();
    expect(plot.element.querySelector('svg')).not.toBeNull();
    expect(plot.getAttribute('label')).toBe('Measure');
    expect('label' in vg).toBe(false);
  });

  it.each(['ariaLabel', 'ariaDescription', 'clip'])(
    'preserves the missing runtime route for %s', async name => {
      const plot = new Plot();
      vg[name](name === 'clip' ? true : 'Description')(plot);
      expect(plot.getAttribute(name)).toBe(name === 'clip' ? true : 'Description');
      await expect(plot.render()).rejects.toThrow(
        `Unrecognized plot attribute: ${name}`
      );
    }
  );

  it('preserves the vectorX vectoX dispatch defect and its rendering failure', async () => {
    const plot = new Plot();
    vg.vectorX([{ x: 1, y: 2 }], { x: 'x', y: 'y' })(plot);
    const { marks } = plot;
    expect(marks).toHaveLength(1);
    expect(marks[0].type).toBe('vectoX');
    expect(marks[0].plotSpecs()[0]).toHaveProperty('type', 'vectoX');
    await expect(plot.render()).rejects.toThrow(TypeError);
  });
});
