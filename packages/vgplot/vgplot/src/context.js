import { coordinator as _coordinator } from '@uwdata/mosaic-core';
import { NamedPlots } from './plot/named-plots.js';
import * as vgplot from './api.js';
import * as nativeSQL from '@uwdata/mosaic-sql/native';

/** @typedef {Omit<typeof vgplot, keyof typeof nativeSQL> & Pick<typeof nativeSQL, Exclude<Extract<keyof typeof vgplot, keyof typeof nativeSQL>, 'from'>> & Pick<typeof vgplot, 'from'>} NativeAPI */

/** @returns {NativeAPI} */
function nativeAPI() {
  return /** @type {NativeAPI} */ (Object.fromEntries(
    Object.entries(vgplot).map(([name, value]) => [name,
      name !== 'from' && Object.hasOwn(nativeSQL, name) ? nativeSQL[name] : value
    ])
  ));
}

export function createAPIContext({
  coordinator = _coordinator(),
  namedPlots = new NamedPlots,
  extensions = null,
  ...options
} = {}) {
  const native = coordinator.nativeContext;
  const api = native ? {
    ...nativeAPI(),
    Selection: {
      intersect: (options = {}) => native.selection(options),
      union: (options = {}) => native.selection({ ...options, union: true }),
      single: (options = {}) => native.selection({ ...options, single: true }),
      crossfilter: (options = {}) => native.selection({ ...options, cross: true })
    }
  } : vgplot;
  return {
    ...api,
    ...extensions,
    coordinator: () => coordinator,
    context: {
      coordinator,
      namedPlots,
      ...options
    }
  };
}
